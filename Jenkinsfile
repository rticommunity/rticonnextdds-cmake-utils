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

/**
 * Build the desired job in the examples repository multibranch pipeline.
 *
 * @param examplesRepoBranch The branch or PR to build in the examples repository.
 */
void runBuildArchitectureConfigurationsJob(String examplesRepoBranch) {
    build(
        job: 'ci/rticonnextdds-cmake-utils/build-arch-cfgs',
        propagate: true,
        wait: true,
        parameters: [
            string(
                name: 'CMAKE_UTILS_REPOSITORY_BRANCH',
                value: env.BRANCH_NAME,
            ),
            string(
                name: 'EXAMPLES_REPOSITORY_BRANCH',
                value: examplesRepoBranch,
            ),
        ]
    )
}

/**
 * Create a set of jobs over each rticonnextdds-examples branch.
 *
 * @param branches List of branch names.
 */
Map branchJobs(String[] branches) {
    return branches.collectEntries { branch ->
        [
            "${branch}",
            {
                stage("${branch}") {
                    runBuildArchitectureConfigurationsJob(branch)
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
    agent none

    stages {
        stage('Versions') {
            when {
                changeset(
                    pattern: 'cmake/Modules/FindRTIConnextDDS.cmake',
                    comparator: 'EQUALS',
                )
            }
            steps {
                script {
                    String[] examplesBranches = readYaml(
                        file: "${env.WORKSPACE}/resources/ci/config.yaml"
                    ).versions.keySet()
                    parallel branchJobs(examplesBranches)
                }
            }
        }
    }
    post {
        cleanup {
            cleanWs()
        }
    }
}
