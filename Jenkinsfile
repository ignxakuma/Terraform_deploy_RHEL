pipeline {
    agent any
    parameters {
        string defaultValue: 'bundle01', description: 'Enter bundle name', name: 'Bundle_name', trim: true 
        string defaultValue: 'dev', description: 'Enter Env name', name: 'Env_name', trim: true
    }
    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/ignxakuma/Terraform_deploy_RHEL.git', credentialsId: 'gitpass', branch: 'master'
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
                sh 'terraform apply -var 'bundle_name=$(Bundle_name)' -var 'env_name=$(Env_name)' --auto-approve'
            }
        }
    }
}
