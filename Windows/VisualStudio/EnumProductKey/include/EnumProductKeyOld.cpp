// Read MSDM Table from BIOS ACPI tables.
#include "stdafx.h"
#include <Windows.h>
#include "acpi.h"
#include <iostream>
#include <string>
using namespace std;
BOOL verbose = FALSE;
BOOL debug = TRUE;

char* enumMSDMTable(DWORD FirmwareTableID)
{
	PVOID pFirmwareTableBuffer = NULL;
	DWORD BufferSize = NULL;
	UINT  BufferWritten;

	// first get buffer size
	BufferSize = GetSystemFirmwareTable('ACPI',
		FirmwareTableID,
		NULL,
		NULL);
	pFirmwareTableBuffer = malloc(BufferSize);
	if (debug) cout << "MSDM Buffer Size " << BufferSize << endl;
	BufferWritten = GetSystemFirmwareTable('ACPI',
		FirmwareTableID,
		pFirmwareTableBuffer,
		BufferSize);
	if (debug) cout << "MSDM Buffer Written " << BufferSize << endl;
	acpi_MSDM_1 *msdm = (acpi_MSDM_1*)pFirmwareTableBuffer;
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
		printf("Product key       : %29.29s\n", &msdm->ProductKey);
	}
	free(pFirmwareTableBuffer);
	pFirmwareTableBuffer = NULL;
	return msdm->ProductKey;
}

char* enumACPITable() {
	PVOID pFirmwareTableBuffer = NULL;
	DWORD BufferSize = NULL;
	UINT  BufferWritten;
	DWORD FirmwareTableID;
	DWORD *pFirmwareTableID;
	char* pProductKey = {};
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
	const DWORD SearchMSDMFirmwareTableID = _byteswap_ulong('MSDM');
	char c4[4];
	*(DWORD*)c4 = SearchMSDMFirmwareTableID;
	if (debug) cout << "Firmware Table ID search " << c4[0] << c4[1] << c4[2] << c4[3] << endl;
	if (verbose) printf("Found ACPI Tables: \n");
	for (UINT i = 0; i < BufferWritten / 4; i++) // 4 == bytesize of DWORD
	{
		FirmwareTableID = *pFirmwareTableID;
		*(DWORD*)c4 = FirmwareTableID;
		if (debug) cout << i << " " << c4[0] << c4[1] << c4[2] << c4[3] << endl;
		if (FirmwareTableID == SearchMSDMFirmwareTableID) {
			if (verbose) printf("\n");
			pProductKey = enumMSDMTable(FirmwareTableID);
		}
		pFirmwareTableID++;
	}
	free(pFirmwareTableBuffer);
	pFirmwareTableBuffer = NULL;
	return pProductKey;
}

int _tmain()
{
	char* pProductKey = enumACPITable();
	printf("%29.29s\n", pProductKey);
	return 0;
}
