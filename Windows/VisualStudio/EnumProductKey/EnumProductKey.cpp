// Check Windows Activation Key
// - Read from ACPI / MSDM table
// - or command line
//
// May 2024 philn
//
#include <string.h>
#include <cstdlib>
#include <windows.h>
#include <iostream>
#include "acpi.h"
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
bool verbose = FALSE;

char* enumMSDMTable(DWORD FirmwareTableID)
{
	PVOID pFirmwareTableBuffer = NULL;
	UINT BufferSize = NULL;
	UINT  BufferWritten;
	char* pProductKey = nullptr;
	// first get buffer size
	BufferSize = GetSystemFirmwareTable('ACPI',
		FirmwareTableID,
		NULL,
		NULL);
	pFirmwareTableBuffer = malloc(BufferSize);
	if (verbose) cout << "MSDM Buffer Size " << BufferSize << endl;
	BufferWritten = GetSystemFirmwareTable('ACPI',
		FirmwareTableID,
		pFirmwareTableBuffer,
		BufferSize);
	if (verbose) cout << "MSDM Buffer Written " << BufferSize << endl;
	acpi_MSDM_1* msdm = (acpi_MSDM_1*)pFirmwareTableBuffer;
	if (verbose) {
		//printf("Signature         : %4.4s\n", &msdm->hdr.signature);
		printf("Length            : %d\n", msdm->hdr.length);
		printf("Revision          : %d\n", msdm->hdr.revision);
		printf("Checksum          : %d\n", msdm->hdr.checksum);
		printf("OEMID             : %6.6s\n", &msdm->hdr.oem_id);
		printf("OEM Table ID      : %8.8s\n", &msdm->hdr.oem_table_id);
		printf("OEM Revision      : %d\n", msdm->hdr.oem_revision);
		printf("Creator ID        : %4.4s\n", &msdm->hdr.asl_compiler_id);
		printf("Creator Revision  : %d\n", msdm->hdr.asl_compiler_revision);
		printf("SLS Version       : %d\n", msdm->Version);
		printf("SLS Reserved      : %d\n", msdm->Reserved);
		printf("SLS Data Type     : %d\n", msdm->DataType);
		printf("SLS Data Reserved : %d\n", msdm->DataReserved);
		printf("SLS Data Length   : %d\n", msdm->DataLength);
		printf("Product key       : %29.29s\n\n", &msdm->ProductKey);
	}
	pProductKey = (char*)msdm->ProductKey;
	free(pFirmwareTableBuffer);
	pFirmwareTableBuffer = NULL;
	return pProductKey;
}

char* enumACPITable() {
	PVOID pFirmwareTableBuffer = NULL;
	UINT BufferSize = NULL;
	UINT  BufferWritten;
	DWORD FirmwareTableID;
	DWORD* pFirmwareTableID;
	char* pProductKey = nullptr;
	// first get buffer size
	BufferSize = EnumSystemFirmwareTables('ACPI',
		NULL,
		NULL);
	pFirmwareTableBuffer = malloc(BufferSize);

	// enum acpi tables
	BufferWritten = EnumSystemFirmwareTables('ACPI',
		pFirmwareTableBuffer,
		BufferSize);
	// enumerate ACPI tables, look for MSDM table
	pFirmwareTableID = (DWORD*)pFirmwareTableBuffer;
	const DWORD MSDMTable = _byteswap_ulong('MSDM');
	const DWORD SLICTable = _byteswap_ulong('SLIC');
	char c4[4] = {};
	*(DWORD*)c4 = MSDMTable;
	if (verbose) cout << "Firmware Table ID search " << c4[0] << c4[1] << c4[2] << c4[3] << endl;
	if (verbose) printf("Found %d ACPI Tables: \n", BufferWritten / 4);
	for (UINT i = 0; i < BufferWritten / 4; i++) // 4 == bytesize of DWORD
	{
		FirmwareTableID = *pFirmwareTableID;
		*(DWORD*)c4 = FirmwareTableID;
		if (verbose) cout << i << " " << c4[0] << c4[1] << c4[2] << c4[3] << endl;
		if (FirmwareTableID == MSDMTable) {
			if (verbose) cout << endl;
			pProductKey = enumMSDMTable(FirmwareTableID);
		}
		if (FirmwareTableID == SLICTable) {
			cout << "ACPI has a SLIC table " << endl;
		}
		pFirmwareTableID++;
	}
	free(pFirmwareTableBuffer);
	pFirmwareTableBuffer = NULL;
	if (pProductKey == NULL) {
		cout << "ACPI has no MSDM table" << endl;
		exit(1);
	}
	return pProductKey;
}
int keyCheck(WCHAR* pwszKey, int Edition) {
	typedef HRESULT(__stdcall* PidGenXFn)(WCHAR* szProductKey, // Product Key to decode
		WCHAR* szPKeyConfigPath, // Path to "pkeyconfig.xrm-ms"
		WCHAR* szPID, // Microsoft Product ID Family (use "55041", "12345" or "XXXXX")
		string* OemId, // OEM ID - unknown (use NULL)
		WCHAR* szProductId, // Calculated Product ID ("55041-XXX-XXXXXXX-XXXXX")
		struct DigitalProductId* pDigPid, // Calculated DigitalProductId structure
		struct DigitalProductId4* pDigPid4 // Calculated DigitalProductId4 structure
		);
	PidGenXFn g_pPidGenX = {};
	WCHAR DLLPath7[] = L"./pidgenx7.dll";
	WCHAR DLLPath8[] = L"./pidgenx8.dll";
	WCHAR DLLPath81[] = L"./pidgenx81.dll";
	WCHAR DLLPath10[] = L"./pidgenx10.dll";
	WCHAR DLLPath11[] = L"./pidgenx11.dll";
	WCHAR wszPKeyConfig7[] = L"pkeyconfig7.xrm-ms";  // From C:\Users\user1\Documents\Hyper-v\mount1\Windows\System32\spp\tokens\pkeyconfig
	WCHAR wszPKeyConfig8[] = L"pkeyconfig8.xrm-ms";
	WCHAR wszPKeyConfig81[] = L"pkeyconfig81.xrm-ms";
	WCHAR wszPKeyConfig10[] = L"pkeyconfig10.xrm-ms";
	WCHAR wszPKeyConfig11[] = L"pkeyconfig11.xrm-ms";
	WCHAR* pDLLPath = NULL;
	WCHAR* pwszPKeyConfig = NULL;
	if (Edition == 7) {
		pDLLPath = DLLPath7;
		pwszPKeyConfig = wszPKeyConfig7;
	}
	else if (Edition == 8) {
		pDLLPath = DLLPath8;
		pwszPKeyConfig = wszPKeyConfig8;
	}
	else if (Edition == 81) {
		pDLLPath = DLLPath81;
		pwszPKeyConfig = wszPKeyConfig81;
	}
	else if (Edition == 10) {
		pDLLPath = DLLPath10;
		pwszPKeyConfig = wszPKeyConfig10;
	}
	else if (Edition == 11) {
		pDLLPath = DLLPath11;
		pwszPKeyConfig = wszPKeyConfig11;
	}
	else {
		wcout << L"ERROR: Unexpected Edition: " << Edition << endl;
		wcout << endl;
		return -1;
	}
	HMODULE hPidGenX = LoadLibrary(pDLLPath);
	if (hPidGenX == NULL) {
		wcout << L"Error: Could not load " << pDLLPath << L" - file not found ? " << endl;
		return -1;
	}
	g_pPidGenX = (PidGenXFn)GetProcAddress(hPidGenX, "PidGenX");
	if (g_pPidGenX == NULL) {
		wcout << "Error: Could not load  " << pDLLPath << L" - wrong file?";
		return -1;
	}
	// Call PidGenX function 
	WCHAR wszProductId[24] = {};  // Calculated Product ID ("55041-XXX-XXXXXXX-XXXXX")
	DigitalProductId sDPid = {};
	sDPid.uiSize = sizeof(DigitalProductId);
	DigitalProductId4 sDPid4 = {};
	sDPid4.uiSize = sizeof(DigitalProductId4);
	WCHAR pszName[] = L"XXXXX"; // Microsoft Product ID Family (use "55041", "12345" or "XXXXX")
	HRESULT hResult = g_pPidGenX(pwszKey, pwszPKeyConfig, pszName, NULL, wszProductId, &sDPid, &sDPid4);
	wstring ver = L"";
	switch (hResult) {
	case 0:
		break;
	case 0x8A010001:
		wcout << L"Activation Key: " << pwszKey << L"  Status: Invalid  Edition: Windows " << Edition << endl;
		//wcout << L"Activation Key    : " << pwszKey << endl;
		//wcout << L"Edition           : Windows " << Edition << endl;
		//wcout << L"Key Status        : Invalid" << endl;
		//wcout << endl;
		return -1;
	case 0x8A010101:
		wcout << L"Activation Key: " << pwszKey <<  L"  Status: Invalid  Edition: Windows " << Edition << endl;
		return -1;
	case 0x80070057:
		wcout << L"Activation Key    : " << pwszKey << endl;
		cout << "Error: Malformed or bad Product ID Windows" << endl;
		wcout << endl;
		return -1;
	case 0x80070002:
		wcout << L"Error: Missing Key Config file " << pwszPKeyConfig << endl;
		wcout << endl;
		return -1;
	default:
		wcout << "Error: Failed in call " << pDLLPath << hex << hResult << endl;
		wcout << endl;
		return -1;
	}
	if (wstring(sDPid4.szEditionType) == L"Core")
	{
		//wcout << L"Edition type      : Home" << endl;
		ver = L"Home";
	}
	else
	{
		ver = wstring(sDPid4.szEditionType);
	}
	wcout << L"Activation Key: " << pwszKey << L"  Status: Active   Edition: Windows " << Edition << L" " << ver << endl;
	
	if (verbose) {
		wcout << L"Key type          : " << wstring(sDPid4.szKeyType) << endl;
		wcout << L"Edition ID        : " << wstring(sDPid4.szEditionId) << endl;
		wcout << L"Product ID        : " << wszProductId << endl;
		wcout << L"OEM ID            : " << wstring(sDPid4.szOemID) << endl;
		wcout << L"EULA              : " << wstring(sDPid4.szEULA) << endl;
	}
	wcout << endl;
	return 0;
}
VOID GetWC(char* c, WCHAR* wc, int length) {
	int len = length;
	while (*c != '\0' && len > 0) {
		*(wc++) = (WCHAR) * (c++);
		len--;
	}
	*wc = '\0';
}
int main(int argc, char* argv[]) {
	char* pProductKey = nullptr;
	if (verbose) wcout << "EnumProductKey" << endl;
	for (int i = 1; i < argc; ++i) {
		{
			if (strlen(argv[i]) == 29) {
				pProductKey = argv[i];
			}
			else if (!strcmp(argv[i], "--verbose") ||
				!strcmp(argv[i], "-v")) {
				verbose = TRUE;
			}
			else if (!strcmp(argv[i], "--help") ||
				!strcmp(argv[i], "-h") ||
				!strcmp(argv[i], "-?")) {
				cout << "Usage: EnumProductKey [XXXX-XXXX-XXXX-XXXX-XXXX | -v | --verbose]" << endl;
				exit(1);
			}
		}
	}

	try {
		if (pProductKey == NULL) {
			pProductKey = enumACPITable();
		}
	}
	catch (const std::exception& e) {
		wcout << L"Error: enumACPITables Exception " << e.what() << endl;
		exit(1);
	}
	if (verbose) printf("%29.29s\n", pProductKey);
	WCHAR wszKey[30] = {};
	GetWC(pProductKey, &wszKey[0], 29);
	//WCHAR wszKey[] = L"CV4P2-2NMPF-C9QH6-R6XFD-FM47D"; // Win 7 Product Key
	//WCHAR wszKey[] = L"TTK8X-G3QD6-M2G6Y-4MK6D-93H49";
	// c // Win 8
	// D7YVB-9B8D8-NDJ86-RCBRQ-GFYQH // ??
	//WCHAR wszKey[] = L"W269N-WFGWX-YVC9B-4J6C9-T83GX";  // Win 10 Product Key
	keyCheck(wszKey, 7);
	keyCheck(wszKey, 8);
	keyCheck(wszKey, 81);
	keyCheck(wszKey, 10);
	//keyCheck(wszKey, 11);
	return 0;
}