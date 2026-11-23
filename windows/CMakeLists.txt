cmake_minimum_required(VERSION 3.25)
project(m4l_wrappers_windows LANGUAGES CXX)

if(NOT MSVC OR NOT CMAKE_SIZEOF_VOID_P EQUAL 8 OR NOT CMAKE_VS_PLATFORM_NAME STREQUAL "x64")
    message(FATAL_ERROR "Configure with Visual Studio and -A x64")
endif()

get_filename_component(WRAPPERS_ROOT "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
set(VST3_SDK "${WRAPPERS_ROOT}/deps/vst3sdk" CACHE PATH "Steinberg VST 3 SDK checkout")
set(MAX_SDK_BASE "${WRAPPERS_ROOT}/deps/max-sdk-base" CACHE PATH "Cycling '74 Max SDK base checkout")
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# Follow the Max SDK's Windows runtime choice so each external is self-contained.
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
add_compile_options(/utf-8 /Zc:__cplusplus)
add_compile_definitions(NOMINMAX WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0A00)

add_library(vst3-host-sdk STATIC
    "${VST3_SDK}/pluginterfaces/base/coreiids.cpp"
    "${VST3_SDK}/pluginterfaces/base/funknown.cpp"
    "${VST3_SDK}/pluginterfaces/base/ustring.cpp"
    "${VST3_SDK}/public.sdk/source/common/commoniids.cpp"
    "${VST3_SDK}/public.sdk/source/common/commonstringconvert.cpp"
    "${VST3_SDK}/public.sdk/source/common/memorystream.cpp"
    "${VST3_SDK}/public.sdk/source/common/threadchecker_win32.cpp"
    "${VST3_SDK}/public.sdk/source/vst/vstinitiids.cpp"
    "${VST3_SDK}/public.sdk/source/vst/utility/stringconvert.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/module.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/module_win32.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/plugprovider.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/hostclasses.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/pluginterfacesupport.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/parameterchanges.cpp"
    "${VST3_SDK}/public.sdk/source/vst/hosting/connectionproxy.cpp")
target_include_directories(vst3-host-sdk PUBLIC "${VST3_SDK}" "${WRAPPERS_ROOT}/shared")
target_compile_definitions(vst3-host-sdk PUBLIC RELEASE=1)
target_link_libraries(vst3-host-sdk PUBLIC ole32 shell32 uuid user32 comctl32)

function(add_max_external device)
    set(folder "${WRAPPERS_ROOT}/devices/${device}")
    file(READ "${folder}/device.json" config)
    string(JSON external GET "${config}" external)
    set(source "${folder}/external.mm")
    set_source_files_properties("${source}" PROPERTIES LANGUAGE CXX COMPILE_FLAGS "/TP")
    add_library("${device}" MODULE "${source}")
    set(max "${MAX_SDK_BASE}/c74support/max-includes")
    set(msp "${MAX_SDK_BASE}/c74support/msp-includes")
    target_include_directories("${device}" PRIVATE "${max}" "${msp}")
    target_link_libraries("${device}" PRIVATE vst3-host-sdk "${max}/x64/MaxAPI.lib" "${msp}/x64/MaxAudio.lib")
    set_target_properties("${device}" PROPERTIES OUTPUT_NAME "${external}" SUFFIX ".mxe64" PREFIX ""
        LIBRARY_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}/externals")
endfunction()

add_max_external(oxford-inflator)
add_max_external(spectre)

include(CTest)
if(BUILD_TESTING)
    set(SMTG_USE_STATIC_CRT ON CACHE BOOL "Use the same runtime in the test plug-ins")
    add_executable(meter-test "${WRAPPERS_ROOT}/tests/meters.cpp")
    add_test(NAME meter-readings COMMAND meter-test)
    add_executable(parameter-test "${WRAPPERS_ROOT}/tests/vst3-parameters.cpp")
    target_compile_options(parameter-test PRIVATE /UNDEBUG)
    target_link_libraries(parameter-test PRIVATE vst3-host-sdk)
    add_test(NAME parameter-mapping COMMAND parameter-test)
    add_executable(inspect-external inspect-external.cpp)
    foreach(device IN ITEMS oxford-inflator spectre)
        add_test(NAME exports-${device} COMMAND inspect-external "$<TARGET_FILE:${device}>")
    endforeach()
    add_subdirectory("${WRAPPERS_ROOT}/tests/windows-host" "${CMAKE_BINARY_DIR}/windows-host")
endif()
