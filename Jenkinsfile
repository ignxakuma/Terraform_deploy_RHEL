pipeline {
    agent any
    parameters {
        string defaultValue: 'bundle01', description: 'Enter bundle name', name: 'Bundle_name', trim: true 
        string defaultValue: 'dev', description: 'Enter Env name', name: 'Env_name', trim: true
        choice choices: ['No', 'Yes'], description: 'Do you want to use terraform destroy command?', name: 'Destroy_infra'
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
                sh "terraform plan -var 'bundle_name=${params.Bundle_name}' -var 'env_name=${params.Env_name}'"
            }
        }
        stage('Terraform-apply') {
            steps {
                sh "terraform apply -var 'bundle_name=${params.Bundle_name}' -var 'env_name=${params.Env_name}' --auto-approve"
            }
        }
        stage("Terraform-destroy")
        {
            when{
                expression
                {
                    return params.Destroy_infra == 'Yes'
                }
                }
            steps{
                sh "terraform destroy -var 'bundle_name=${params.Bundle_name}' -var 'env_name=${params.Env_name}' --auto-approve"
            }
        }           
    }
}
