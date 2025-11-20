#define MAX_LINE_LENGTH 4096
#include <string.h>
#include <cstring>
#include <atlstr.h>
#include <cstdlib>
#include <windows.h>
#include <iostream>
#include <winver.h>
static CString GetFileVersion(LPCTSTR filePath)
{
	CString ret = L"";
	DWORD dummy;
	DWORD dwSize = GetFileVersionInfoSizeEx(FILE_VER_GET_LOCALISED, filePath, &dummy);
	if (dwSize == 0)
	{
		//wprintf(L"%d\n", dwSize);
		DWORD error = ::GetLastError();
		//std::string message = std::system_category().message(error);
		//printf("%s %s\n",filePath, message.c_str());
		ret = L"Not Found";
	}
	else
	{
		BYTE* data = new BYTE[dwSize];
		BOOL err = GetFileVersionInfoEx(FILE_VER_GET_LOCALISED, filePath, 0, dwSize, &data[0]);
		if (! err)
			ret = L"Error retriving version (Version Data Not Retrived";
		else
		{
			UINT infoLen = 0;
			CString OS = L"";
			VS_FIXEDFILEINFO* pFixedInfo = NULL;
			err = VerQueryValue(&data[0], L"\\", (LPVOID*)&pFixedInfo, &infoLen);
			if (!err) 
				ret = L"Error retriving version(Version Data Query Failed)";
			else
			{
				DWORD dwFileVersionMS = pFixedInfo->dwFileVersionMS;
				DWORD dwFileVersionLS = pFixedInfo->dwFileVersionLS;

				DWORD dwLeftMost = HIWORD(dwFileVersionMS);
				DWORD dwSecondLeft = LOWORD(dwFileVersionMS);
				DWORD dwBuild = HIWORD(dwFileVersionLS);
				if (dwBuild < 6000) OS = "XP or earlier";
				else if (dwBuild < (unsigned int)7600) OS = "Vista";
				else if (dwBuild < (unsigned int)9200) OS = "Windows 7";
				else if (dwBuild < (unsigned int)9600) OS = "Windows 8";
				else if (dwBuild < (unsigned int)10240) OS = "Windows 8.1";
				else if (dwBuild < (unsigned int)22000) OS = "Windows 10";
				else OS = "Windows 11";
				DWORD dwRightMost = LOWORD(dwFileVersionLS);
				ret.Format(L"%s Version: %d.%d.%d.%d %s\n", OS, dwLeftMost, dwSecondLeft, dwBuild, dwRightMost);
			}
		}
		delete[] data;
	}
	return ret;
}
int main(int argc, char* argv[]) {
	CString ans =  GetFileVersion(L"C:\\Windows\\System32\\ntoskrnl.exe");
	wprintf(L"C: %s\n", (LPCTSTR)GetFileVersion(L"C:\\Windows\\System32\\ntoskrnl.exe"));
	wprintf(L"E: %s\n", (LPCTSTR)GetFileVersion(L"E:\\Windows\\System32\\ntoskrnl.exe"));
	wprintf(L"X: %s\n", (LPCTSTR)GetFileVersion(L"X:\\Windows\\System32\\ntoskrnl.exe"));
	//std::wcout << ans.GetString() << std::endl;
}