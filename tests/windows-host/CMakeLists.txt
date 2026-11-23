# Build test-only VST3s in the test executable's private search path.
set(SMTG_ENABLE_VST3_PLUGIN_EXAMPLES OFF CACHE BOOL "")
set(SMTG_ENABLE_VST3_HOSTING_EXAMPLES OFF CACHE BOOL "")
set(SMTG_ENABLE_VSTGUI_SUPPORT OFF CACHE BOOL "")
add_subdirectory("${VST3_SDK}" "${CMAKE_CURRENT_BINARY_DIR}/sdk" EXCLUDE_FROM_ALL)

foreach(wrapper IN ITEMS oxford-inflator spectre)
    add_library(fixture-${wrapper} MODULE fixture.cpp
        "${VST3_SDK}/public.sdk/source/main/dllmain.cpp"
        "${VST3_SDK}/public.sdk/source/vst/vstsinglecomponenteffect.cpp")
    set_target_properties(fixture-${wrapper} PROPERTIES SUFFIX ".vst3")
    target_link_libraries(fixture-${wrapper} PRIVATE sdk user32)
    add_executable(probe-${wrapper} probe.cpp)
    target_include_directories(probe-${wrapper} PRIVATE "${WRAPPERS_ROOT}/devices/${wrapper}")
    target_link_libraries(probe-${wrapper} PRIVATE vst3-host-sdk user32 ole32)
    if(wrapper STREQUAL "spectre")
        target_compile_definitions(fixture-${wrapper} PRIVATE TEST_SPECTRE)
        target_compile_definitions(probe-${wrapper} PRIVATE TEST_SPECTRE)
    endif()
    add_dependencies(probe-${wrapper} fixture-${wrapper})
    add_test(NAME exercise-${wrapper} COMMAND probe-${wrapper} "$<TARGET_FILE:fixture-${wrapper}>")
endforeach()
