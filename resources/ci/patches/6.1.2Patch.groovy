/*
 * (c) Copyright, Real-Time Innovations, 2024.  All rights reserved.
 * RTI grants Licensee a license to use, modify, compile, and create derivative
 * works of the software solely for use with RTI Connext DDS. Licensee may
 * redistribute copies of the software provided that all such copies are subject
 * to this license. The software is provided "as is", with no warranty of any
 * type, including any warranty for fitness for any purpose. RTI is under no
 * obligation to maintain or support the software. RTI shall not be liable for
 * any incidental or consequential damages arising out of the use or inability
 * to use the software.
 */

/**
 * Apply the 6.1.2 release branch patch.
 *
 * @param cmakeUtilsRepoRoot rticonnextdds-cmake-utils repository root directory.
 * @param examplesRepoRoot rticonnextdds-examples repository root directory.
 */
void apply(String cmakeUtilsRepoRoot, String examplesRepoRoot) {
    echo(
        'Applying 6.1.2 patch:\n- Dump the contents of the'
        + ' rticonnextdds-cmake-utils:/cmake/Modules/ repository directory into the CMake resource'
        + ' directory inside the rticonnextdds-examples repository\n- Create a VERSION file'
        + ' containing the text 6.1.2\n- Add missing CMakeLists.txt files and apply a minor git'
        + ' path'
    )
    command.run("cp -r ${cmakeUtilsRepoRoot}/cmake/Modules/* ${examplesRepoRoot}/resources/cmake/")
    writeFile(file: 'VERSION', text: '6.1.2')
    command.run(
        "git apply ${cmakeUtilsRepoRoot}/resources/ci/patches/6.1.2.diff -C ${examplesRepoRoot}"
    )
}

return this
