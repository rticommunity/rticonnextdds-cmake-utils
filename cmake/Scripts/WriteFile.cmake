# (c) 2018 Copyright, Real-Time Innovations, Inc.  All rights reserved.
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
.. _connextdds_scripts_writefile:

WriteFile
---------
::

    cmake -DOUTPUT=outputfile -DCONTENT=HelloWorld [-DAPPEND=1] -PWriteFile.cmake

Write a string in the output file. If the ``APPEND`` argument is not specified,
the file will be truncated with the new content, otherwise it will be appended.

Arguments:

``CONTENT`` (required)
  String content to write in the file.

``OUTPUT`` (required)
  The path to the output file.

``APPEND`` (optional)
  If set the content will be append.
#]]

if(NOT CONTENT)
    message(FATAL_ERROR "Missing CONTENT argument")
endif()

if(NOT OUTPUT)
    message(FATAL_ERROR "Missing OUTPUT argument")
endif()

set(write_mode WRITE)
if(APPEND)
    set(write_mode APPEND)
endif()

file(${write_mode} "${OUTPUT}" "${CONTENT}")
