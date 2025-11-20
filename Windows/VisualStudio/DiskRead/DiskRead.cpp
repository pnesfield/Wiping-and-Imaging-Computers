// Read raw sector from a device
// Version 2 read past 2Gb
// version 2.1 read device name eg. \\.\PHYSICALDRIVE0
// version 2.2 add Blancco Fingerprint
#include <windows.h>
#include <stdio.h>
#include <string>

using namespace std;
int main(int argc, char* argv[])
{
    bool debug = false;
    bool blancco = false;
    BYTE sector[512];
    DWORD bytesRead;
    HANDLE device = NULL;
    int numSector = 0;
    int ret = 0;
    if (argc < 3)
    {
        printf("Usage %s Device number | \\\\.\\PHYSICALDRIVEn sector [ verbose | blancco]", argv[0]);
        return 1;
    }
    if (argc == 4)
    {
        if (!strcmp(argv[3], "blancco"))
        {
            blancco = true;
        }       
        else
        {
            debug = true;
        }
    }
    string devName = "\\\\.\\PhysicalDrive";
    if (strlen(argv[1]) > 2) 
    {
        devName = argv[1];
    }
    else
    {
        devName = devName + argv[1];
    }
    if (debug) printf("devName %s\n", devName.c_str());
    numSector = stoi(argv[2]);
    //device = CreateFile(L"\\\\.\\C:",
    device = CreateFileA(devName.c_str(),
        GENERIC_READ,           // Access mode
        FILE_SHARE_READ | FILE_SHARE_WRITE,        // Share Mode
        NULL,                   // Security Descriptor
        OPEN_EXISTING,          // How to create
        0,                      // File attributes
        NULL);                  // Handle to template

    if (device == INVALID_HANDLE_VALUE)
    {
        if (GetLastError() == ERROR_FILE_NOT_FOUND)
        {
            printf("CreateFile: No such device %s\n", devName.c_str());
            return 0;
        }
        else if (GetLastError() == ERROR_ACCESS_DENIED)
        {
            printf("CreateFile: drive %s Permission Denied\n", argv[1]);
        }
        else
        {
            printf("CreateFile: drive %s %u", argv[1], GetLastError());
        }
        return 1;
    }
    LARGE_INTEGER li, lip;
    li.QuadPart = numSector;
    li.QuadPart = li.QuadPart * 512;
    if (! SetFilePointerEx(device, li, &lip, FILE_BEGIN))
    {
        printf("ReadFile: %i\n", GetLastError());
        return 1;
    }
    if (debug) printf("ReadFile: Pointer was %lli now %lli\n", li.QuadPart/512, lip.QuadPart/512);
    if (!ReadFile(device, sector, 512, &bytesRead, NULL))
    {
        printf("ReadFile error: %u\n", GetLastError());
        return 1;
    }
    else
    {
        char hexChar[4];
        byte firstb, nextb; // bytes
        unsigned short firsts, nexts; // 16 bits
        unsigned long firsti, nexti;  //32 bits
        // unsigned long firstl, nextl; //64 bits
        int countb = 0, counts = 0, counti = 0, countl = 0;
        string hexStr = "";
        int iline = 0;
        int iPart = 0;
        string partTable = "";
        int signature = 0;
        int sum = 0;
        int zeros = 0;
        // Blancco Fingerprint
        if (blancco)
        {
            for (int i = 0; i < 512; i++)
            {
                if (sector[i] == 59)
                {
                    sector[i] = 10;
                    ret++;
                }
            }
            if (ret > 5)
            {
                printf(" ");
                printf("%s\n", (char*)sector);
            }
        }
        for (int i = 0; i < 512; i++)
        {
            if (i == 0) firstb = sector[0]; 
            else if (i == 1) 
            {
                if (firstb == sector[1]) countb++;
                firsts = firstb << 8 | sector[1];  
            }
            else if (i == 3) 
            { 
                if (firstb == sector[3]) countb++;
                firsti = firsts << 16 | sector[2] << 8 | sector[3]; 
            }
            else 
            {
                nextb = sector[i];
                if (firstb == nextb) countb++;
                if ((i+1) % 2 == 0)
                {
                    nexts = nextb << 8 | sector[i];
                    if (firsts == nexts) counts++;
                }
                if ((i+1) % 4 == 0)
                {
                    nexti = sector[i - 3] << 24 | sector[i - 2] << 16 | sector[i - 1] << 8 | sector[i];
                    if (firsti == nexti) counti++;
                }
            }
            sum = sum + sector[i];
            sprintf_s(hexChar, "%02X ", sector[i]);
            hexStr = hexStr.append(hexChar);
            iline++;
            if (iline >= 20)
            {
                hexStr.append("\n");
                iline = 0;
            }
            if (i >= 440 && i <= 443)
            {
                signature = signature + sector[i];
            }
            if (i >= 446 && i <= 509)
            {
                partTable = partTable + hexChar;
                iPart++;
                if (iPart >= 16)
                {
                    partTable.append("\n");
                    iPart = 0;
                }
            }
            if (sector[i] == 0)
            {
                zeros++;
            }
        }
        if (debug)
        {
            printf("%s\n", hexStr.c_str());
            printf("counti %i nexti %lu first %lu\n", counti, nexti, firsti);
        }
        if (blancco)
        {
            ;
        }
        else if (sum == 0)
        {
            printf("Drive %s sector %i has been wiped with 0x00\n", argv[1], numSector);
            return 0;
        }
        else if (countb == 511)
        {
            printf("Drive %s sector %i has been wiped with random data byte 0x%02X\n", argv[1], numSector, firstb);
            return 0;
        }
        else if (counts == 255)
        {
            printf("Drive %s sector %i has been wiped with 16 bit random data short 0x%04X\n", argv[1], numSector, firsts);
            return 0;
        }
        else if (counti == 127)
        {
            printf("Drive %s sector %i has been wiped with 32 bit random data int 0x%08X\n", argv[1], numSector, firsti);
            return 0;
        }
        else if (sum == signature)
        {
            printf("Drive %s sector %i has been wiped and has a signature\n", argv[1], numSector);
            return 0;
        }
        else if (sector[510] == 85 && sector[511] == 170)
        {
            if (debug) printf("%s\n", partTable.c_str());
            printf("Drive %s sector %i contains data and is bootable\n", argv[1], numSector);
        }
        else
        {
            printf("Drive %s sector %i contains data\n", argv[1], numSector);
        }
    }

    return ret;
}
