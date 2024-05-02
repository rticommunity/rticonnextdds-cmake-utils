/*
 * (c) Copyright, Real-Time Innovations, 2022.  All rights reserved.
 * RTI grants Licensee a license to use, modify, compile, and create derivative
 * works of the software solely for use with RTI Connext DDS. Licensee may
 * redistribute copies of the software provided that all such copies are subject
 * to this license. The software is provided "as is", with no warranty of any
 * type, including any warranty for fitness for any purpose. RTI is under no
 * obligation to maintain or support the software. RTI shall not be liable for
 * any incidental or consequential damages arising out of the use or inability
 * to use the software.
 */

// TODO: Remove when merged
@Library("rticommunity-jenkins-pipelines@feature/INSTALL-944") _

/**
 * Build the desired job in the examples repository multibranch pipeline.
 *
 * @param examplesRepoBranch The branch or PR to build in the examples repository.
 * @param architectureFamily The architecture family of the job.
 * @param architectureString The architecture string of the job.
 */
void runBuildSingleModeJob(String examplesRepoBranch, String architectureFamily, String architectureString) {
    build(
        job: 'ci/rticonnextdds-cmake-utils/build-cfg',
        propagate: true,
        wait: true,
        parameters: [
            string(
                name: 'ARCHITECTURE_FAMILY',
                value: architectureFamily,
            ),
            string(
                name: 'ARCHITECTURE_STRING',
                value: architectureString,
            ),
            string(
                name: 'EXAMPLES_REPOSITORY_BRANCH',
                value: examplesRepoBranch,
            ),
            string(
                name: 'CMAKE_UTILS_REPOSITORY_BRANCH',
                value: env.BRANCH_NAME,
            ),
        ]
    )
}

/**
 * Create a set of jobs over each architecture for a specific rticonnextdds-examples branch.
 *
 * @param branch rticonnextdds-examples branch to build.
 * @param osMap Architecture family - architecture string map.
 */
Map architectureJobs(String branch, Map<String, Map> osMap) {
    echo("osMap: ${osMap}")
    return osMap.each { architectureFamily, architectureString ->
        [
            "Architecture faimly: ${architectureFamily}": {
                stage("Architecture faimly: ${architectureFamily}") {
                    runBuildSingleModeJob(branch, architectureFamily, architectureString)
                }
            }
        ]
    }
}

/**
 * Create a set of jobs over each rticonnextdds-examples branch.
 *
 * @param branches Map of the available branches.
 */
def branchJobs(branches) {
    echo("branches: ${branches}")
    return branches.each { branch, osMap ->
        [
            "Branch: ${branch}": {
                stage("Branch: ${branch}") {
                    parallel architectureJobs(branch, osMap)
                }
            }
        ]
    }
}

/**
 * Run a complete set of tests for all the Connext versions and architectures the FindPackage
 * supports.
 */
pipeline {
    agent any

    stages {
        stage('Run CI') {
            steps {
                script {
                    parallel branchJobs(
                        readYaml(file: "${env.WORKSPACE}/resources/ci/config.yaml").branches
                    )
                }
            }
        }
    }
}
