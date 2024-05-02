/*
 * (c) Copyright, Real-Time Innovations, 2021.  All rights reserved.
 * RTI grants Licensee a license to use, modify, compile, and create derivative
 * works of the software solely for use with RTI Connext DDS. Licensee may
 * redistribute copies of the software provided that all such copies are subject
 * to this license. The software is provided "as is", with no warranty of any
 * type, including any warranty for fitness for any purpose. RTI is under no
 * obligation to maintain or support the software. RTI shall not be liable for
 * any incidental or consequential damages arising out of the use or inability
 * to use the software.
 */

@Library("rticommunity-jenkins-pipelines@feature/INSTALL-944") _

/**
 * Build the desired job in the examples repository multibranch pipeline.
 *
 * @param cmakeUtilsRepoBranch The cmake-utils repository branch or PR to use.
 * @param examplesRepoBranch The branch or PR to build in the examples repository.
 * @param architectureFamily The architecture family of the job.
 * @param architectureString The architecture string of the job.
 */
void runBuildConfigurationJob(
    String cmakeUtilsRepoBranch,
    String examplesRepoBranch,
    String architectureFamily,
    String architectureString
) {
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
                value: cmakeUtilsRepoBranch,
            ),
        ]
    )
}

/**
 * Create a set of jobs over each architecture for a specific rticonnextdds-examples branch.
 *
 * @param cmakeUtilsRepoBranch rticonnextdds-cmake-utils branch to use.
 * @param examplesRepoBranch rticonnextdds-examples branch to build.
 * @param osMap `Architecture family - architecture string` map.
 */
Map architectureJobs(String cmakeUtilsRepoBranch String examplesRepoBranch, Map<String, Map> osMap) {
    return osMap.collectEntries { architectureFamily, architectureString ->
        [
            "Architecture family: ${architectureFamily}": {
                stage("Architecture family: ${architectureFamily}") {
                    runBuildConfigurationJob(
                        cmakeUtilsRepoBranch,
                        examplesRepoBranch,
                        architectureFamily,
                        architectureString
                    )
                }
            }
        ]
    }
}

/**
 * Run all the architectures available for a single examples branch.
 */
pipeline {
    agent any

    parameters {
        string(
            name: 'CMAKE_UTILS_REPOSITORY_BRANCH',
            description: 'The rticonnextdds-cmake-utils repository branch to use',
            trim: true,
        )
        string(
            name: 'EXAMPLES_REPOSITORY_BRANCH',
            description: 'The config Yaml branch to build',
            trim: true
        )
    }

    stages {
        stage('Run CI') {
            steps {
                checkoutCommunityRepoBranch(
                    'rticonnextdds-cmake-utils', params.CMAKE_UTILS_REPOSITORY_BRANCH
                )
                script {
                    parallel architectureJobs(
                        params.CMAKE_UTILS_REPOSITORY_BRANCH,
                        params.EXAMPLES_REPOSITORY_BRANCH,
                        readYaml(
                            file: "${env.WORKSPACE}/resources/ci/config.yaml"
                        ).branches[params.EXAMPLES_REPOSITORY_BRANCH]
                    )
                }
            }
        }
    }
}
