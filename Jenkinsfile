
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        TF_IN_AUTOMATION   = 'true'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Check Tools') {
            steps {
                sh '''
                    terraform -version
                    aws --version
                    git --version
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        terraform plan \
                          -input=false \
                          -out=tfplan
                    '''
                }
            }
        }

        stage('Approve EC2 Creation') {
            steps {
                input message: 'Review the Terraform plan. Approve to create the EC2 instance?',
                      ok: 'Approve and Create'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Show EC2 Details') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                        terraform output instance_id
                        terraform output public_ip
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Terraform EC2 deployment completed.'
        }
        failure {
            echo 'FAILED: Check the Jenkins Console Output.'
        }
    }
}
