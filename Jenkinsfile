
pipeline {
    agent any

    parameters {
        choice(
            name: 'ACTION',
            choices: ['apply', 'destroy'],
            description: 'Choose apply to create EC2 or destroy to remove it'
        )
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
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Approve EC2 Creation') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                input message: 'Approve EC2 creation?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Show EC2 Details') {
            when {
                expression { params.ACTION == 'apply' }
            }
            steps {
                sh 'terraform output'
            }
        }

        stage('Terraform Destroy') {
            when {
                expression { params.ACTION == 'destroy' }
            }
            steps {
                input message: 'Confirm: destroy Terraform-managed resources?', ok: 'Destroy'
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding',
                     credentialsId: 'aws-credentials']
                ]) {
                    sh 'terraform destroy -input=false -auto-approve'
                }
            }
        }
    }
}
