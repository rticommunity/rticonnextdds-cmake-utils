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

String detailsUrl = 'https://community.rti.com/'

/*
 * Write the current state of Jenkins.
 **/
void writeJenkinsOutput() {
    sh('python3 resources/ci_cd/jenkins_output.py')
}

/*
 * Read the current contents of jenkins_output.md.
 **/
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
                    name: 'Waiting for executor',
                    title: 'Waiting',
                    summary: ':hourglass: Waiting for next available executor...',
                    status: 'IN_PROGRESS',
                    detailsURL: detailsUrl,
                )
            }
        }

        stage('Build sequence') {
            agent {
                dockerfile {
                    filename 'resources/docker/Dockerfile.x64Linux'
                    label 'docker'
                }
            }

            environment {
                RTI_INSTALLATION_PATH = "${WORKSPACE}/unlicensed"
                RTI_LOGS_FILE = "${WORKSPACE}/output_logs.txt"
            }

            stages {
                stage('Checkout Examples repository') {
                    steps {
                        publishChecks(
                            name: 'Waiting for executor',
                            title: 'Passed',
                            summary: ':white_check_mark: Build started.',
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
                    }

                    post {
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Failed',
                                summary: ':warning: Failed cloning the Examples repository..',
                                conclusion: 'FAILURE',
                                detailsURL: detailsUrl,
                            )
                        }
                    }
                }
                stage('Checkout CMake Utils repository') {
                    steps {
                        checkout([
                            $class: 'GitSCM',
                            extensions: [[
                                $class: 'RelativeTargetDirectory',
                                relativeTargetDir: 'resources/cmake/rticonnextdds-cmake-utils',
                            ]]
                        ])
                    }

                    post {
                        failure {
                            publishChecks(
                                name: STAGE_NAME,
                                title: 'Failed',
                                summary: ':warning: Failed cloning the CMake Utils repository.',
                                conclusion: 'FAILURE',
                                detailsURL: detailsUrl,
                            )
                        }
                    }
                }
                stage('Download Packages') {
                    steps {
                        writeJenkinsOutput()

                        publishChecks(
                            name: STAGE_NAME,
                            title: 'Downloading',
                            summary: ':arrow_down: Downloading RTI Connext DDS libraries...',
                            status: 'IN_PROGRESS',
                            text: readJenkinsOutput(),
                            detailsURL: detailsUrl,
                        )

                        rtDownload(
                            serverId: 'rti-artifactory',
                            spec: """{
                                "files": [
                                {
                                    "pattern": "connext-ci/pro/weekly/",
                                    "props": "rti.artifact.architecture=${env.CONNEXTDDS_ARCH};rti.artifact.kind=staging",
                                    "sortBy": ["created"],
                                    "sortOrder": "desc",
                                    "limit": 1,
                                    "flat": true
                                }]
                            }""",
                        )

                        // We cannot use the explode option because it is bugged.
                        // https://www.jfrog.com/jira/browse/HAP-1154
                        sh("tar zxvf connextdds-staging-${env.CONNEXTDDS_ARCH}.tgz unlicensed/")

                        writeJenkinsOutput()
                    }

                    post {
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
                            python3 resources/ci_cd/linux_build.py | tee $RTI_LOGS_FILE
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
