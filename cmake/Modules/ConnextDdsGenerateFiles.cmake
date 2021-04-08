# (c) 2017 Copyright, Real-Time Innovations, Inc.  All rights reserved.
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
.. _connextdds_generate_files:

ConnextDdsGenerateFiles
-----------------------

Copy or configure files.

Copy files
^^^^^^^^^^
::

    connextdds_copy_file(<input> <output>)

Copies the ``<input>`` file into the ``<output>`` file. It doesn't apply any
transformation in the file. It sets the property ``GENERATED`` in the output
file.

------------------------------------------------------------------------------

::

    connextdds_copy_files(
        INPUT_FILES file1 [file2 file3 ...]
        OUTPUT_DIR dir
    )

Copy the list of files from ``INPUT_FILES`` argument to the ``OUTPUT_DIR``
directory. If ``OUTPUT_DIR`` doesn't exist, it will be created.

Generate file
^^^^^^^^^^^^^
::

    connextdds_generate_file(<input> <output>)

Copies the ``<input>`` file into the ``<output>`` file and substitues variable
values references as ``${VAR}`` (recommended format) or ``@VAR@`` with CMake
variables.
#]]

include(CMakeParseArguments)
include(ConnextDdsArgumentChecks)

function(connextdds_generate_file INPUT OUTPUT)
    connextdds_check_no_extra_arguments()
    configure_file("${INPUT}" "${OUTPUT}")
endfunction()

function(connextdds_copy_file INPUT OUTPUT)
    connextdds_check_no_extra_arguments()
    configure_file("${INPUT}" "${OUTPUT}" COPYONLY)
endfunction()

function(connextdds_copy_files)
    cmake_parse_arguments(COPY "" "OUTPUT_DIR" "INPUT_FILES" ${ARGN})

    connextdds_check_required_arguments(COPY_INPUT_FILES COPY_OUTPUT_DIR)

    if(EXISTS "${COPY_OUTPUT_DIR}" AND NOT IS_DIRECTORY "${COPY_OUTPUT_DIR}")
        message(FATAL_ERROR "The OUTPUT_DIR argument must be a directory")
    endif()

    file(MAKE_DIRECTORY "${COPY_OUTPUT_DIR}")
    foreach(file ${COPY_INPUT_FILES})
        connextdds_copy_file("${file}" "${COPY_OUTPUT_DIR}")
    endforeach()
endfunction()
