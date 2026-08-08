pipeline {
    agent any

    // Triggers automatically at ~2:00 AM on the Friday following 2nd Tuesday (Days 11-17)
    triggers {
        cron('H 2 11-17 * 5')
    }

    parameters {
        booleanParam(
            name: 'USE_CUSTOM_AMI',
            defaultValue: true,
            description: 'Check to build incrementally from last month\'s AMI (Fast). Uncheck to rebuild from AWS official base image.'
        )
    }

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'
        PACKER_DIR         = '2025/Prod'
        ANSIBLE_DIR        = '2025/Prod/provisioners/ansible'
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        disableConcurrentBuilds()
        timeout(time: 2, unit: 'HOURS')
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Ansible Dependencies') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    // Downloads required Ansible collections/roles specified in requirements.yml
                    sh 'ansible-galaxy collection install -r requirements.yml --force'
                }
            }
        }

       stage('Packer Init & Validate') {
            steps {
                // Securely inject AWS Credentials using standard usernamePassword wrapper
                withCredentials([usernamePassword(credentialsId: 'aws-packer-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${PACKER_DIR}") {
                        sh 'packer init .'
                        sh 'packer validate .'
                    }
                }
            }
        }

        stage('Build Windows AMI') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-packer-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    dir("${PACKER_DIR}") {
                        script {
                            // Convert boolean parameter to string for Packer variable
                            def useCustomAmiVar = params.USE_CUSTOM_AMI ? "true" : "false"
                            
                            sh "packer build -var 'use_custom_ami=${useCustomAmiVar}' ."
                        }
                    }
                }
            }
        }

        stage('Archive Artifacts') {
            steps {
                dir("${PACKER_DIR}") {
                    // Saves manifest.json which contains the newly created AMI ID
                    archiveArtifacts artifacts: 'manifest.json', allowEmptyArchive: false
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "Successfully baked and registered new Windows Server 2025 AMI!"
        }
        failure {
            echo "AMI Build Failed. Check console logs above for Packer/Ansible errors."
        }
    }
}