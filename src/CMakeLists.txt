# CMakeLists.txt for WebView2Helper.dll
# Author: Ralle1976
#
# Usage:
# 32-bit: cmake -A Win32 -B build32 && cmake --build build32 --config Release
# 64-bit: cmake -A x64 -B build64 && cmake --build build64 --config Release

cmake_minimum_required(VERSION 3.16)
project(WebView2Helper C)

# Set C standard
set(CMAKE_C_STANDARD 99)

# Create shared library (DLL)
add_library(WebView2Helper SHARED
    WebView2Helper.c
    WebView2Helper.def
)

# Link with required Windows libraries
target_link_libraries(WebView2Helper
    ole32
    user32
)

# Set output name and properties
set_target_properties(WebView2Helper PROPERTIES
    OUTPUT_NAME "WebView2Helper"
    PREFIX ""
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
)

# For multi-config generators (like Visual Studio)
foreach(CONFIG_TYPE ${CMAKE_CONFIGURATION_TYPES})
    string(TOUPPER ${CONFIG_TYPE} CONFIG_TYPE_UPPER)
    set_target_properties(WebView2Helper PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
        LIBRARY_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
        ARCHIVE_OUTPUT_DIRECTORY_${CONFIG_TYPE_UPPER} "${CMAKE_CURRENT_SOURCE_DIR}/../bin"
    )
endforeach()

# Add architecture suffix to output name
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_target_properties(WebView2Helper PROPERTIES OUTPUT_NAME "WebView2Helper_x64")
else()
    set_target_properties(WebView2Helper PROPERTIES OUTPUT_NAME "WebView2Helper_x86")
endif()
