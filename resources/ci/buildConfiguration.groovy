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

pipeline {
    agent {
        label "${runInsideExecutor.labelFromArchitectureFamily(params.ARCHITECTURE_FAMILY)}"
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
            name: 'ARCHITECTURE_FAMILY',
            description: 'The architecture family to guess the node from (linux, windows, ...)',
            trim: true,
        )
        string(
            name: 'ARCHITECTURE_STRING',
            description: 'The architecture string (x64Linux4gcc7.3.0, x64Win64VS2015, ...)',
            trim: true,
        )
        string(
            name: 'EXAMPLES_REPOSITORY_BRANCH',
            description: (
                'The rticonnextdds-examples repository branch to build. E.g.: "master",'
                + ' "release/7.3.0", "PR-123"'
            ),
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
        CMAKE_UTILS_DOCKER_DIR = "${env.WORKSPACE}/cmake-utils/resources/ci/docker/"
        CONNEXT_DIR = ''
        STATIC_ANALYSIS_RESULTS_DIR = "${env.WORKSPACE}/static_analysis_report"
    }

    stages {
        stage('Repository configuration') {
            steps {
                checkoutCommunityRepoBranch(
                    'rticonnextdds-examples', params.EXAMPLES_REPOSITORY_BRANCH, true,
                )
                dir(env.CMAKE_UTILS_REPO) {
                    checkoutCommunityRepoBranch(
                        'rticonnextdds-cmake-utils', params.CMAKE_UTILS_REPOSITORY_BRANCH,
                    )
                }
                applyCmakeUtilsPatch(
                    env.CMAKE_UTILS_REPO, env.WORKSPACE, env.EXAMPLES_REPOSITORY_BRANCH,
                )
            }
        }
        stage('Download Packages') {
            steps {
                runInsideExecutor(
                    params.ARCHITECTURE_STRING, env.CMAKE_UTILS_DOCKER_DIR,
                ) {
                    script {
                        env.CONNEXT_DIR = installConnext(
                            env.ARCHITECTURE_STRING, env.WORKSPACE,
                        )
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
                            runInsideExecutor(
                                params.ARCHITECTURE_STRING, env.CMAKE_UTILS_DOCKER_DIR
                            ) {
                                echo("Building ${buildMode}/${linkMode}")
                                buildExamples(
                                    env.WORKSPACE,
                                    env.CONNEXT_DIR,
                                    buildMode,
                                    linkMode,
                                )
                            }
                        }
                    }
                }
            }
        }
        stage('Static Analysis') {
            steps {
                runInsideExecutor(
                    params.ARCHITECTURE_STRING, env.CMAKE_UTILS_DOCKER_DIR
                ) {
                    runStaticAnalysis(
                        buildExamples.getBuildDirectory('release', 'dynamic'),
                        env.CONNEXT_DIR,
                        env.STATIC_ANALYSIS_RESULTS_DIR,
                    )
                }
            }
            post {
                failure {
                    publishHTML(target: [
                        allowMissing: true,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: env.STATIC_ANALYSIS_RESULTS_DIR,
                        reportFiles: 'index.html',
                        reportName: 'LLVM Scan build static analysis',
                    ])
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

