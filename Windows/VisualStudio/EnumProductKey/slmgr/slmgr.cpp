// https://stackoverflow.com/questions/43483541/programmatically-check-if-windows-is-activated-with-c
#define _WIN32_WINNT 0x600
#include <iostream>
#include <windows.h>
#include <slpublic.h>
#include <tchar.h>
#pragma comment(lib, "Slwga.lib")
#pragma comment(lib, "Rpcrt4.lib")

using namespace std;

bool isGenuineWindows()
{
    // Genuine means the key has been activated properly
    GUID uid;
    RPC_WSTR rpc = (RPC_WSTR)_T("55c92734-d682-4d71-983e-d6ec3f16059f");
    // Line 482 slmgr.vbs windowsApId
    RPC_STATUS stat = UuidFromString(rpc, &uid);
    if (stat != 0) {
        cout << "UuidFromString failed";
        return FALSE;
    }
    SL_GENUINE_STATE state;
    try {
        SLIsGenuineLocal(&uid, &state, NULL);
    }
    catch (const std::exception& e) {
        wcout << L"Error: Function Exception " << e.what() << endl;
        exit(1);
    }
    wcout << "state " << state << endl;
    /*
    SL_GEN_STATE_IS_GENUINE         = 0,
    SL_GEN_STATE_INVALID_LICENSE,
    SL_GEN_STATE_TAMPERED,
    SL_GEN_STATE_OFFLINE,
    SL_GEN_STATE_LAST
    */
    return state == SL_GEN_STATE_IS_GENUINE;
}

int main()
{
    cout << "slmgr" << endl;
    try
    {
        if (isGenuineWindows()) {
            cout << "Licensed" << endl;
        }
        else {
            cout << "Unlicensed" << endl;
        }
    }
    catch (const std::exception& e) {
        wcout << L"Error: Function Exception " << e.what() << endl;
        exit(1);
    }
    return 0;
}