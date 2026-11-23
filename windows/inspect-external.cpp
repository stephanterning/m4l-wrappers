#include <windows.h>
#include <cstdio>

int wmain(int argc, wchar_t** argv) {
    if(argc!=2)return 1;
    // Inspect the actual x64 DLL and Max entry point without requiring Max on the CI runner.
    // Calling the export would require the Max application and its actual initialization context.
    auto dll=LoadLibraryExW(argv[1],nullptr,DONT_RESOLVE_DLL_REFERENCES);
    if(!dll){std::fprintf(stderr,"Cannot map external, error %lu\n",GetLastError());return 1;}
    auto entry=GetProcAddress(dll,"ext_main");
    FreeLibrary(dll);
    if(!entry){std::fputs("Missing Max ext_main export\n",stderr);return 1;}
    return 0;
}
