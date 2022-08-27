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

pipeline {
    agent none

    options {
        skipDefaultCheckout()
    }

    stages {
        stage('Executor Check') {
            steps {
                publishChecks(
                    name: 'Waiting for a clone executor',
                    title: 'Waiting',
                    summary: ':hourglass: Waiting for next available executor to clone the repositories...',
                    status: 'IN_PROGRESS',
                    detailsURL: detailsUrl,
                )
            }
        }

        stage('Checkout the repositories') {
            agent any

            steps {
                publishChecks(
                    name: 'Waiting for a clone executor',
                    title: 'Passed',
                    summary: ':white_check_mark: Clone started.',
                    detailsURL: detailsUrl,
                )
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: 'feature/503-cmake-utils-git-submodule']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/lulivi/rticonnextdds-examples.git'
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
                        name: 'Waiting for the build executor',
                        title: 'Waiting',
                        summary: ':hourglass: Waiting for next available executor to build...',
                        status: 'IN_PROGRESS',
                        detailsURL: detailsUrl,
                    )
                }
                failure {
                    publishChecks(
                        name: 'Waiting for a clone executor',
                        title: 'Failed',
                        summary: ':warning: Failed cloning the repositories.',
                        conclusion: 'FAILURE',
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
                            name: 'Waiting for the build executor',
                            title: 'Passed',
                            summary: ':white_check_mark: Build started.',
                            detailsURL: detailsUrl,
                        )

                        writeJenkinsOutput()

                        publishChecks(
                            name: STAGE_NAME,
                            title: 'Downloading',
                            summary: ':arrow_down: Downloading RTI Connext DDS libraries...',
                            status: 'IN_PROGRESS',
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
                                title: 'Passed',
                                summary: ':white_check_mark: RTI Connext DDS libraries downloaded.',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Failed',
                                summary: ':warning: Failed downloading RTI Connext DDS libraries.',
                                conclusion: 'FAILURE',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        aborted {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Aborted',
                                summary: ':no_entry: The download of RTI Connext DDS libraries was aborted.',
                                conclusion: 'CANCELED',
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
                            status: 'IN_PROGRESS',
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
                                title: 'Passed',
                                summary: ':white_check_mark: All the examples were built succesfully.',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Failed',
                                summary: ':warning: There was an error building the examples.',
                                conclusion: 'FAILURE',
                                text: readJenkinsOutput(),
                                detailsURL: detailsUrl,
                            )
                        }
                        aborted {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Aborted',
                                summary: ':no_entry: The examples build was aborted',
                                conclusion: 'CANCELED',
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
                        name: 'Waiting for executor',
                        title: 'Aborted',
                        summary: ':no_entry: The pipeline was aborted',
                        conclusion: 'CANCELED',
                        detailsURL: detailsUrl,
                    )
                }
            }
        }
    }
}
