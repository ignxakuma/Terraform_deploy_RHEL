pipeline {
    agent any
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/ignxakuma/Terraform_deploy_RHEL.git' credentialsId: 'gitpass' branch: 'master'
            }
        }
        stage('Terraform-Init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('Terraform-plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('Terraform-apply') {
            steps {
                sh 'terraform apply --auto-approve'
            }
        }
    }
}
