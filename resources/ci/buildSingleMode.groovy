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

Map pipelineInfo = [:]

pipeline {
    agent {
        label "${nodeManager.labelFromArchitecture(params.ARCHITECTURE)}"
    }

    options {
        skipDefaultCheckout()
        /*
            To avoid excessive resource usage in server, we limit the number
            of builds to keep in pull requests
        */
        buildDiscarder(
            logRotator(
                artifactDaysToKeepStr: '',
                artifactNumToKeepStr: '',
                daysToKeepStr: '',
                /*
                   For pull requests only keep the last 10 builds, for regular
                   branches keep up to 20 builds.
                */
                numToKeepStr: changeRequest() ? '10' : '20'
            )
        )
        // Set a timeout for the entire pipeline
        timeout(time: 2, unit: 'HOURS')
    }

    parameters {
        string(
            name: 'ARCHITECTURE',
            description: 'The architecture string to guess the node from: e.g.: linux, windows...',
            trim: true
        )
        string(
            name: 'EXAMPLES_REPOSITORY_BRANCH',
            description: '''
                The rticonnextdds-examples repository branch to build. E.g.: "master",
                "release/7.3.0", "PR-123"
            ''',
            trim: true,
        )
        string(
            name: 'CMAKE_UTILS_REPOSITORY_BRANCH',
            description: 'The rticonnextdds-cmake-utils repository branch to use',
            defaultValue: 'main',
            trim: true,
        )
    }

    environment {
        CMAKE_UTILS_REPO = "${env.WORKSPACE}/cmake-utils"
    }

    stages {
        stage('Clone repositories') {
            steps {
                checkoutCommunityRepoBranch('rticonnextdds-examples', params.EXAMPLES_REPOSITORY_BRANCH, true)
                dir(env.CMAKE_UTILS_REPO) {
                    checkoutCommunityRepoBranch('rticonnextdds-cmake-utils', params.CMAKE_UTILS_REPOSITORY_BRANCH)
                }
                applyCmakeUtilsPatch(env.CMAKE_UTILS_REPO, env.WORKSPACE, env.EXAMPLES_REPOSITORY_BRANCH)
            }
        }
        stage('Download Packages') {
            steps {
                script {
                    nodeManager.runInsideExecutor(params.ARCHITECTURE) {
                        pipelineInfo.connextDir = installConnext(env.CONNEXTDDS_ARCH, env.WORKSPACE)
                    }
                }
            }
        }
        stage('Build all modes') {
            matrix {
                axes {
                    axis {
                        name 'buildMode'
                        values 'release', 'debug'
                    }
                    axis {
                        name 'linkMode'
                        values 'static', 'dynamic'
                    }
                }
                stages {
                    stage('Build single mode') {
                        steps {
                            script{
                                nodeManager.runInsideExecutor(params.ARCHITECTURE) {
                                    echo("Building ${buildMode}/${linkMode}")
                                    buildExamples(
                                        env.WORKSPACE,
                                        pipelineInfo.connextDir,
                                        buildMode,
                                        linkMode
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
        stage('Static Analysis') {
            steps {
                script {
                    nodeManager.runInsideExecutor(params.ARCHITECTURE) {
                        command.run("""
                            python3 resources/ci_cd/linux_static_analysis.py \
                            --build-dir ${buildExamples.getBuildDirectory('release', 'dynamic')}
                        """)
                    }
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

