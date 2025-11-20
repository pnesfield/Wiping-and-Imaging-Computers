// PidGenX.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
//
#include <string.h>
#include <cstdlib>
#include <windows.h>
#include <iostream>
using namespace std;
struct DigitalProductId {
	unsigned int uiSize;
	unsigned short MajorVersion;
	unsigned short MinorVersion;
	char szProductId[24];
	unsigned int uiKeyIdx;
	char szEditionId[16];
	BYTE bCdKey[16];
	unsigned int uiCloneStatus;
	unsigned int uiTime;
	unsigned int uiRandom;
	unsigned int uiLt;
	unsigned int uiLicenseData[2];
	char sOemId[8];
	unsigned int uiBundleId;
	char sHardwareIdStatic[8];
	unsigned int uiHardwareIdTypeStatic;
	unsigned int uiBiosChecksumStatic;
	unsigned int uiVolSerStatic;
	unsigned int uiTotalRamStatic;
	unsigned int uiVideoBiosChecksumStatic;
	char sHardwareIdDynamic[8];
	unsigned int uiHardwareIdTypeDynamic;
	unsigned int uiBiosChecksumDynamic;
	unsigned int uiVolSerDynamic;
	unsigned int uiTotalRamDynamic;
	unsigned int uiVideoBiosChecksumDynamic;
	unsigned int uiCRC32;

};

struct DigitalProductId4 {
	unsigned int uiSize;
	unsigned short MajorVersion;
	unsigned short MinorVersion;
	WCHAR szAdvancedPid[64];
	WCHAR szActivationId[64];
	WCHAR szOemID[8];
	WCHAR szEditionType[260];
	BYTE bIsUpgrade;
	BYTE bReserved[7];
	BYTE bCDKey[16];
	BYTE bCDKey256Hash[32];
	BYTE b256Hash[32];
	WCHAR szEditionId[64];
	WCHAR szKeyType[64];
	WCHAR szEULA[64];
};
typedef int(__cdecl* PidGenXFn)(LPCWSTR);

class PIDXChecker {       // The class
	typedef HRESULT(__stdcall* PidGenXFn)(
		WCHAR* szProductKey, // Product Key to decode
		WCHAR* szPKeyConfigPath, // Path to "pkeyconfig.xrm-ms"
		WCHAR* szPID, // Microsoft Product ID Family (use "55041", "12345" or "XXXXX")
		string* OemId, // OEM ID - unknown (use NULL)
		WCHAR* szProductId, // Calculated Product ID ("55041-XXX-XXXXXXX-XXXXX")
		struct DigitalProductId* pDigPid, // Calculated DigitalProductId structure
		struct DigitalProductId4* pDigPid4 // Calculated DigitalProductId4 structure
		);

public:
	PidGenXFn g_pPidGenX = {};
    string szReturnString;
    int keyCheck(WCHAR* pwszKey, int edition) { 
		WCHAR DLLPath7[] = L"pidgenx7.dll";
		WCHAR DLLPath10[] = L"pidgenx.dll";
		WCHAR wszPKeyConfig7[] = L"pkeyconfig7.xrm-ms";  // Path to "pkeyconfig.xrm-ms" Win7
		WCHAR wszPKeyConfig10[] = L"pkeyconfig10.xrm-ms";  // Path to "pkeyconfig.xrm-ms" Win10
		WCHAR* pDLLPath = NULL;
		WCHAR* pwszPKeyConfig = NULL;
		if (edition == 7) {
			cout << "Edition\t\t: Windows 7\n";
			pDLLPath = DLLPath7;
			pwszPKeyConfig = wszPKeyConfig7;
		}
		else {
			cout << "Edition\t\t: Windows 10\n";
			pDLLPath = DLLPath10;
			pwszPKeyConfig = wszPKeyConfig10;
		}

        HMODULE hPidGenX = LoadLibrary(pDLLPath);
        if (hPidGenX == NULL) {
            cout << "Error: Could not load pidgenx.dll - file not found?";
			return -1;
        }
        g_pPidGenX = (PidGenXFn)GetProcAddress(hPidGenX, "PidGenX");
        if (g_pPidGenX == NULL) {
            cout << "Error: Could not load pidgenx.dll - wrong file?";
			return -1;
        }
        // Call PidGenX function 
		WCHAR wszProductId[24] = {};
		wszProductId[0] = L'\0';  // Calculated Product ID ("55041-XXX-XXXXXXX-XXXXX")
		// not really used, as everything is in DigitalProductId4,
		DigitalProductId sDPid = {};
		sDPid.uiSize = sizeof(DigitalProductId);
		DigitalProductId4 sDPid4 = {};
		sDPid4.uiSize = sizeof(DigitalProductId4);

		// Call PidGenX function
		wchar_t pszName[] = L"55041"; // Microsoft Product ID Family (use "55041", "12345" or "XXXXX")
		HRESULT hResult = g_pPidGenX(pwszKey, pwszPKeyConfig, pszName, NULL, wszProductId, &sDPid, &sDPid4);
		switch (hResult) {
		case 0:
			break;
		case 0x8a010001:
			cout << "Error: Error: Incompatible pidgenx.dll ";
			return -1;
		case 0x8A010101:
			cout << "Error: Invalid Key";
			return -1;
		case 0x80070057:
			cout << "Error: Malformed Key";
			return -1;
		case 0x80070002:
			cout << "Error: Missing Key Config file";
			return -1;
		default:
			cout << "Error: Failed in call pidgenx.dll " << hex << hResult << "\n";
			return -1;
		}
		wcout << L"Activation Key\t: " << pwszKey << "\n";
		wcout << L"Key Status\t: Active\n";
		wcout << L"Key type\t: " << wstring(sDPid4.szKeyType) << "\n";
		wcout << L"Edition ID\t: " << wstring(sDPid4.szEditionId) << "\n";
		wcout << L"Edition type\t: " << wstring(sDPid4.szEditionType) << "\n";
		wcout << L"OEM ID  \t: " << wstring(sDPid4.szOemID) << "\n";
		return 0;
    }
};

int main() {
    PIDXChecker myObj;  // Create an object of PIDXChecker

    // Access attributes and set values
	//WCHAR wszKey[] = L"CV4P2-2NMPF-C9QH6-R6XFD-FM47D"; // Win 7 Product Key to decode
	//WCHAR wszKey[] = L"TTK8X-G3QD6-M2G6Y-4MK6D-93H49";
	WCHAR wszKey[] = L"W269N-WFGWX-YVC9B-4J6C9-T83GX";  // Win 10 Product Key to decode
	//WCHAR wszPKeyConfig[] = L"pkeyconfig10.xrm-ms";  // Path to "pkeyconfig.xrm-ms" Win10
	WCHAR wszPKeyConfig[] = L"pkeyconfig7.xrm-ms";  // Path to "pkeyconfig.xrm-ms" Win7
    myObj.keyCheck(wszKey, 10);
    return 0;
}