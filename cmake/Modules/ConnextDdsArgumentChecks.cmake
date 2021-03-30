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
.. _connextdds_argument_checks:

ConnextDdsArgumentChecks
------------------------

Function helpers to check function arguments

``connextdds_check_required_arguments``
    Checks that all of the arguments are present and defined

#]]

function(connextdds_check_required_arguments)
    foreach(arg ${ARGN})
        if(NOT ${arg})
            message(FATAL_ERROR "Argument ${arg} is missing")
        endif()
    endforeach()
endfunction()

macro(connextdds_check_no_extra_arguments)
    if(ARGN)
        message(FATAL_ERROR "Function has more arguments than expected")
    endif()
endmacro()
