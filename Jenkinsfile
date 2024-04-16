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
@Library("rticommunity-jenkins-pipelines@feature/enhance-examples-jenkinsfile") _

/**
 * The YAML ci file path.
 */
ciYamlFile = File("${env.WORKSPACE}/ci.yaml")

/**
 * Iterate over the list of architectures to build. In each architecture, this will launch a number
 * of branch jobs.
 *
 * @return The list of stages to run in parallel.
 */
Map architectureJobs() {
    return getYamlCi.architectures(ciYamlFile).collectEntries { architecture ->
        [
            "${architecture}": {
                node {
                    stage("${architecture}") {
                        parallel branchJobs(architecture)
                    }
                }
            }
        ]
    }
}

/**
 * Iterate over the list of branches to build. In each branch, this will launch the specified
 * rticonnextdds-examples pipeline.
 *
 * @param architecture The architecture string to build.
 * @return The list of stages to run in parallel.
 */
Map branchJobs(String architecture) {
    return getYamlCi.branchReferences(ciYamlFile).collectEntries { branchReference ->
        [
            "${branchReference}": {
                node {
                    stage("${branchReference}") {
                        steps {
                            runExamplesRepositoryJob(architecture, branchReference)
                        }
                    }
                }
            }
        ]
    }
}

/**
 * Build the desired job in the examples repository multibranch pipeline.
 *
 * @param architecture The multibranch pipeline selected for running the specified branchReference.
 * @param branchReference The branch or PR to build in the specified multibranch pipeline.
 */
void runExamplesRepositoryJob(String architecture, String branchReference) {
    build(
        job: "ci/rticonnextdds-examples/${architecture}/${branchReference}",
        propagate: true,
        wait: true,
        parameters: [
            string(
                name: 'CMAKE_UTILS_REFERENCE',
                value: env.BRANCH_NAME,
            ),
        ]
    )
}

/**
 * Run the rticonnextdds-examples CI for each active Connext LTS versions (release branches), the
 * latest version (master) and the development version (develop) in all the supported architectures.
 */
pipeline {
    agent none

    stages {
        stage('Run CI') {
            parallel architectureJobs()
        }
    }
}
