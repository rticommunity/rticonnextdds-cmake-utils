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
_find_embedsource:

FindEmbedSource
---------------

Find the Python script to embed a text file into a header file. The script
must be in the source code in: 'resources/script/rti-embed-source.py'.
This find module requires Python. A call to find_package(PythonInterp) must be
done prior finding this package.

Output variables:

* EMBEDSOURCE_SCRIPT: Path to the embed source script.
* EMBEDSOURCE_COMMAND: Command to run the embed source script.


_connextdds_embed_source_file:

Embed source file
^^^^^^^^^^^^^^^^^

Embed a text file into a header file.

  connextdds_embed_source_file(<input> <output> <varname> [<visibility>])

``input`` (required)
    The file to embed.

``output`` (required)
    The generated header file.

``varname`` (required)
    Name of the variable to store the embedded file.

``visibility`` (optional)
    ``Public``, ``Peer` or ``Package``.
#]]

if(NOT PYTHON_EXECUTABLE)
    message(FATAL_ERROR
        "This find module requires python. Make sure to call "
        "find_package(PythonInterp) before finding this package."
    )
endif()

# Find the script in our tree.
find_program(EMBEDSOURCE_SCRIPT
    NAMES
        rti-embed-source.py
    HINTS
        "${CMAKE_CURRENT_LIST_DIR}/../../resources/scripts"
    NO_DEFAULT_PATH
)

set(EMBEDSOURCE_COMMAND ${PYTHON_EXECUTABLE} ${EMBEDSOURCE_SCRIPT})

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    EmbedSource
    REQUIRED_VARS
        EMBEDSOURCE_SCRIPT
    FAIL_MESSAGE
        "Could NOT find python script RTI Embed Source. Make sure the file \
        '${CMAKE_CURRENT_LIST_DIR}/../../resources/scripts/rti-embed-source.py' \
        exists."
)
mark_as_advanced(EMBEDSOURCE_SCRIPT EMBEDSOURCE_COMMAND)

function(connextdds_embed_source_file input output varname)
    set(supported_visibilities Public Peer Package)
    set(visibility_flag)
    if(ARGN)
        list(GET ARGN 0 visibility)
        if(NOT visibility IN_LIST supported_visibilities)
            message(FATAL_ERROR "Unsupported visibility: '${visibility}'")
        endif()

        set(visibility_flag "-k" ${visibility})
    endif()

    add_custom_command(
        VERBATIM
        OUTPUT
            ${output}
        COMMAND
            ${EMBEDSOURCE_COMMAND}
                --input ${input}
                --varname ${varname}
                ${visibility_flag}
                -o ${output}
        DEPENDS
            ${input}
    )
endfunction()
