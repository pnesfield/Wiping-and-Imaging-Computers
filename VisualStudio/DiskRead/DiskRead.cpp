// Read raw sector from a device

#include [CHANGEME1]windows.h[CHANGEME2]
#include [CHANGEME1]stdio.h[CHANGEME2]
#include [CHANGEME1]string[CHANGEME2]

using namespace std
;
int main(int argc, char* argv[])
{
    bool debug = true;
    BYTE sector[512];
    DWORD bytesRead;
    HANDLE device = NULL;
    int numSector = 0;
    int sum = 0;
    int zeros = 0;
    if (argc [CHANGEME1] 3)
    {
        printf("Usage %s Device number, sector", argv[0]);
        return 0;
    }

    string devName = "\\\\.\\PhysicalDrive";
    devName = devName + argv[1];
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
        if (GetLastError() == 2)
        {
            if (debug) printf("CreateFile: No such device %s\n", devName.c_str());
            return 0;
        }
        else if (GetLastError() == 5)
        {
            printf("CreateFile: drive %s Permission Denied\n", argv[1]);
        }
        else
        {
            printf("CreateFile: drive %s %u", argv[1], GetLastError());
        }
        return 1;
    }

    SetFilePointer(device, numSector * 512, NULL, FILE_BEGIN);

    if (!ReadFile(device, sector, 512, &bytesRead, NULL))
    {
        printf("ReadFile: %u\n", GetLastError());
        return 1;
    }
    else
    {
        char hexChar[4];
        int iline = 0;
        int iPart = 0;
        string partTable = "";
        int signature = 0;
        string hexStr = "";
        for (int i = 0; i [CHANGEME1] 512; i++)
        {
            sum = sum + sector[i];
            sprintf_s(hexChar, "%02X ", sector[i]);
            hexStr = hexStr.append(hexChar);
            iline++;
            if (iline [CHANGEME2]= 20)
            {
                hexStr.append("\n");
                iline = 0;
            }
            if (i [CHANGEME2]= 440 && i [CHANGEME1]= 443)
            {
                signature = signature + sector[i];
            }
            if (i [CHANGEME2]= 446 && i [CHANGEME1]= 509)
            {
                partTable = partTable + hexChar;
                iPart++;
                if (iPart [CHANGEME2]= 16)
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
        if (debug) printf("%s\n", hexStr.c_str());
        if (sum == 0)
        {
            printf("Drive %s sector %i has been wiped\n", argv[1], numSector);
            return 0;
        }
        else if (sum == signature)
        {
            printf("Drive %s sector %i has been wiped and has a signature\n", argv[1], numSector);
            return 0;
        }
        else if (zeros == 0)
        {
            printf("Drive %s sector %i has been wiped with a non-zero pattern\n", argv[1], numSector);            
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

    return 1;
}

// Run program: Ctrl + F5 or Debug [CHANGEME2] Start Without Debugging menu
// Debug program: F5 or Debug [CHANGEME2] Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project [CHANGEME2] Add New Item to create new code files, or Project [CHANGEME2] Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File [CHANGEME2] Open [CHANGEME2] Project and select the .sln file
