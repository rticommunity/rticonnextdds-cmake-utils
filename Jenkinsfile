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

/*
 * Base URL to show in the App page.
 */
String detailsUrl = 'https://community.rti.com/'

/*
 * Relative directory to the CMake utils repository inside the examples
 * repository
 */
String cmakeUtilsRepoDir = 'resources/cmake/rticonnextdds-cmake-utils'

/*
 * Write the current state of Jenkins.
 */
void writeJenkinsOutput() {
    sh('python3 resources/ci_cd/jenkins_output.py')
}

/*
 * Read the current contents of jenkins_output.md.
 */
String readJenkinsOutput() {
    return readFile('jenkins_output.md')
}

/*
 * Static string variables.
 */
String waitingForCloneExecutorCheckName = 'Waiting for a clone executor'
String waitingForBuildExecutorCheckName = 'Waiting for a build executor'
String checkTitleWaiting = 'Waiting'
String checkTitlePassed = 'Passed'
String checkTitleFailed = 'Failed'
String checkTitleAborted = 'Aborted'
String checkStatusInProgress = 'IN_PROGRESS'
String checkConclusionCanceled = 'CANCELED'
String checkConclusionFailure = 'FAILURE'

pipeline {
    agent none

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Executor Check') {
            steps {
                publishChecks(
                    name: waitingForCloneExecutorCheckName,
                    title: checkTitleWaiting,
                    summary: ':hourglass: Waiting for next available executor to clone the repositories...',
                    status: checkStatusInProgress,
                    detailsURL: detailsUrl,
                )
            }
        }

        stage('Clone repositories') {
            agent {
                label 'docker'
            }

            steps {
                publishChecks(
                    name: waitingForCloneExecutorCheckName,
                    title: checkTitlePassed,
                    summary: ':white_check_mark: Clone started.',
                    detailsURL: detailsUrl,
                )

                publishChecks(
                    name: STAGE_NAME,
                    title: 'Cloning',
                    summary: ':sparkles: Cloning the example and cmake-utils repositories...',
                    status: checkStatusInProgress,
                    detailsURL: detailsUrl,
                )
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'master']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/rticommunity/rticonnextdds-examples.git'
                    ]],
                    extensions: [[
                        $class: 'SubmoduleOption',
                        recursiveSubmodules: false,
                    ]]
                ])
                dir("${cmakeUtilsRepoDir}") {
                    checkout(scm)
                }
            }

            post {
                success {
                    publishChecks(
                        name: STAGE_NAME,
                        title: checkTitlePassed,
                        summary: ':white_check_mark: Cloning successfull!',
                        detailsURL: detailsUrl,
                    )
                    publishChecks(
                        name: waitingForBuildExecutorCheckName,
                        title: checkTitleWaiting,
                        summary: ':hourglass: Waiting for next available executor to build the examples...',
                        status: checkStatusInProgress,
                        detailsURL: detailsUrl,
                    )
                }
                failure {
                    publishChecks(
                        name: STAGE_NAME,
                        title: checkTitleFailed,
                        summary: ':warning: Failed cloning the repositories.',
                        conclusion: checkConclusionFailure,
                        detailsURL: detailsUrl,
                    )
                }
                aborted {
                    publishChecks(
                        name: STAGE_NAME,
                        title: checkTitleAborted,
                        summary: ':warning: Aborted cloning the repositories.',
                        conclusion: checkConclusionCanceled,
                        detailsURL: detailsUrl,
                    )
                }
            }
        }

        stage('Build sequence') {
            agent {
                dockerfile {
                    filename "${cmakeUtilsRepoDir}/resources/docker/Dockerfile.x64Linux"
                    label 'docker'
                }
            }

            environment {
                RTI_LOGS_FILE = "${WORKSPACE}/output_logs.txt"
                RTI_INSTALLATION_PATH = "${WORKSPACE}"
            }

            stages {
                stage('Download Connext') {
                    steps {
                        publishChecks(
                            name: waitingForBuildExecutorCheckName,
                            title: checkTitlePassed,
                            summary: ':hourglass: Build sequence started!',
                            detailsURL: detailsUrl,
                        )

                        writeJenkinsOutput()

                        publishChecks(
                            name: STAGE_NAME,
                            title: 'Downloading',
                            summary: ':arrow_down: Downloading RTI Connext libraries...',
                            status: checkStatusInProgress,
                            text: readJenkinsOutput(),
                            detailsURL: detailsUrl,
                        )

                        withCredentials([
                            string(credentialsId: 'minimal_package_url', variable: 'RTI_MIN_PACKAGE_URL')
                        ]) {
                            sh("""#!/bin/bash
                                set -o pipefail
                                python3 resources/ci_cd/linux_install.py | tee ${env.RTI_LOGS_FILE}
                            """)
                        }
                    }

                    post {
                        always {
                            writeJenkinsOutput()
                        }
                        success {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitlePassed,
                                summary: ':white_check_mark: RTI Connext libraries downloaded.',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitleFailed,
                                summary: ':warning: Failed downloading RTI Connext libraries.',
                                conclusion: checkConclusionFailure,
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        aborted {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitleAborted,
                                summary: ':no_entry: The download of RTI Connext libraries was aborted.',
                                conclusion: checkConclusionCanceled,
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                    }
                }

                stage('Build') {
                    steps {
                        publishChecks(
                            name: STAGE_NAME,
                            title: 'Building',
                            summary: ':wrench: Building all the examples...',
                            status: checkStatusInProgress,
                            text: readJenkinsOutput(),
                            detailsURL: detailsUrl,
                        )

                        sh("""#!/bin/bash
                            set -o pipefail
                            python3 resources/ci_cd/linux_build.py | tee ${env.RTI_LOGS_FILE}
                        """)
                    }

                    post {
                        always{
                            writeJenkinsOutput()
                        }
                        success {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitlePassed,
                                summary: ':white_check_mark: All the examples were built succesfully.',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitleFailed,
                                summary: ':warning: There was an error building the examples.',
                                conclusion: checkConclusionFailure,
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        aborted {
                            publishChecks(
                                name: STAGE_NAME,
                                title: checkTitleAborted,
                                summary: ':no_entry: The examples build was aborted',
                                conclusion: checkConclusionCanceled,
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                    }
                }
            }

            post {
                cleanup {
                    cleanWs()
                }
                aborted {
                    publishChecks(
                        name: waitingForExecutorCheckName,
                        title: checkTitleAborted,
                        summary: ':no_entry: The pipeline was aborted',
                        conclusion: checkConclusionCanceled,
                        detailsURL: detailsUrl,
                    )
                }
            }
        }
    }
}
