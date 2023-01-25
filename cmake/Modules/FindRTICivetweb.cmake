# (c) 2023 Copyright, Real-Time Innovations, Inc.  All rights reserved.
#
# RTI grants Licensee a license to use, modify, compile, and create derivative
# works of the software solely for use with RTI Connext DDS.  Licensee may
# redistribute copies of the software provided that all such copies are
# subject to this license. The software is provided "as is", with no warranty
# of any type, including any warranty for fitness for any purpose. RTI is
# under no obligation to maintain or support the software.  RTI shall not be
# liable for any incidental or consequential damages arising out of the use or
# inability to use the software.

#[[.rst:
.. _find_rticivetweb:

FindRTICivetweb
--------------

Find the Civetweb libraries.
If no RTICivetweb_ROOT is provided, FindRTICivetweb will try to find the
Civetweb libraries in the Connext installation.

The list of paths to search the libraries are:

- ``RTICivetweb_ROOT``
- Environment variable ``RTICivetweb_ROOT``
- ``${CONNEXTDDS_DIR}/third_party/civetweb-<version>/${CONNEXTDDS_ARCH}/<build_mode>``

The output variables related to the Civetweb libraries are:

- ``RTICivetweb_LIBRARY``: The C library.
- ``RTICivetweb-cpp_LIBRARY``: The C++ library.
- ``RTICivetweb::civetweb``: Imported target for C library.
- ``RTICivetweb::civetweb-cpp``: Imported target for C++ library.
#]]

set(_civetweb_uppercase_build_mode SHARED)
set(_civetweb_location_property IMPORTED_LOCATION)

string(TOLOWER "${CMAKE_BUILD_TYPE}" _civetweb_lowercase_build_type)
if(NOT _civetweb_lowercase_build_type)
    set(_civetweb_lowercase_build_type "release")
endif()
set(_civetweb_build_type_dir_name "${_civetweb_lowercase_build_type}")

if(RTICivetweb_USE_STATIC_LIBS)
    set(_civetweb_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES ${CMAKE_FIND_LIBRARY_SUFFIXES})
    set(_civetweb_uppercase_build_mode STATIC)
    set(CMAKE_FIND_LIBRARY_SUFFIXES .a)
    if(WIN32)
        set(_civetweb_build_type_dir_name "static_${_civetweb_build_type_dir_name}")
        set(CMAKE_FIND_LIBRARY_SUFFIXES .lib)
    endif()
elseif(WIN32)
    set(_civetweb_location_property IMPORTED_IMPLIB)
endif()

if(NOT RTICivetweb_ROOT)
    set(_civetweb_root_hints
        "${CONNEXTDDS_DIR}/third_party/civetweb-${PACKAGE_FIND_VERSION}/${CONNEXTDDS_ARCH}/${_civetweb_build_type_dir_name}"
    )
    if(NOT PACKAGE_FIND_VERSION)
        file(GLOB _civetweb_root_paths_expanded
            LIST_DIRECTORIES true
            "${CONNEXTDDS_DIR}/third_party/civetweb-*/${CONNEXTDDS_ARCH}/${_civetweb_build_type_dir_name}"
        )
    endif()
endif()

find_path(RTICivetweb_ROOT
    "lib/cmake/civetweb/civetweb-config.cmake"
    HINTS
        ${RTICivetweb_ROOT}
        ENV RTICivetweb_ROOT
        ${_civetweb_root_hints}
    PATHS
        ${_civetweb_root_paths_expanded}
)

find_library(RTICivetweb_LIBRARY
        civetweb
    HINTS
        "${RTICivetweb_ROOT}/lib"
)

find_library(RTICivetweb-cpp_LIBRARY
        civetweb-cpp
    HINTS
        "${RTICivetweb_ROOT}/lib"
)

mark_as_advanced(RTICivetweb_LIBRARY RTICivetweb-cpp_LIBRARY)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RTICivetweb
    REQUIRED_VARS
        RTICivetweb_LIBRARY
        RTICivetweb-cpp_LIBRARY
    FAIL_MESSAGE
        "Could not find Civetweb, try to set the path to Civetweb root folder in the system variable RTICivetweb_ROOT"
)

if(RTICivetweb_FOUND)
    if(NOT TARGET RTICivetweb::civetweb AND EXISTS "${RTICivetweb_LIBRARY}")
        add_library(RTICivetweb::civetweb 
            ${_civetweb_uppercase_build_mode}
            IMPORTED
        )
        set_target_properties(RTICivetweb::civetweb PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "CIVETWEB_DLL_IMPORTS"
            INTERFACE_LINK_LIBRARIES "-lpthread;-ldl"
            ${_civetweb_location_property} "${RTICivetweb_LIBRARY}"
            IMPORTED_NO_SONAME TRUE
        )
    endif()
    if(NOT TARGET RTICivetweb::civetweb-cpp AND EXISTS "${RTICivetweb-cpp_LIBRARY}")
        add_library(RTICivetweb::civetweb-cpp
            ${_civetweb_uppercase_build_mode}
            IMPORTED
        )
        set_target_properties(RTICivetweb::civetweb-cpp PROPERTIES
            INTERFACE_COMPILE_DEFINITIONS "CIVETWEB_CXX_DLL_IMPORTS"
            INTERFACE_LINK_LIBRARIES "RTICivetweb::civetweb"
            ${_civetweb_location_property} "${RTICivetweb-cpp_LIBRARY}"
            IMPORTED_NO_SONAME TRUE
        )
    endif()
endif()

# Restore the original find library ordering
if(civetweb_USE_STATIC_LIBS)
    set(CMAKE_FIND_LIBRARY_SUFFIXES
        ${_civetweb_ORIG_CMAKE_FIND_LIBRARY_SUFFIXES}
    )
endif()

unset(_civetweb_uppercase_build_mode)
unset(_civetweb_location_property)
unset(_civetweb_lowercase_build_type)
unset(_civetweb_build_type_dir_name)
