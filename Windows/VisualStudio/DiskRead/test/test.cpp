
#include <windows.h>
#include <winioctl.h>
#include <stdio.h>
#include <string>

using namespace std;

int main(int argc, char* argv[])
{

	byte firstb;
	unsigned short firsts;
	unsigned int firsti;
	firstb = stoi(argv[1]);
	firsts = firstb << 8 | stoi(argv[2]);
	firsti = firsts << 16 | stoi(argv[3]) << 8 | stoi(argv[4]);
	printf("result %i %i %i\n", firstb, firsts, firsti);
	printf("Integer 0x%X\n", firstb);
	printf("Integer 0x%X%X\n", firstb, stoi(argv[3]));
	printf("Integer 0x%X%X%X%X\n", firstb, stoi(argv[3]), stoi(argv[3]), stoi(argv[4]));
}