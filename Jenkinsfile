pipeline {
    
    agent any

    stages {
        
        stage('Slack initial message') {
            steps {
                slackSend color: 'good', message: "> *Start pipeline*: ${BUILD_TAG}"
            }
        }        
        
        stage('Terraform repository checkout') {
            steps {
                slackSend color: 'good', message: "Terraform checkout ..."                
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/wladOSnull/Jenkins-Terraform-Geo-Citizen']]])
            }
        }
        
        stage('Terraform build') {
            steps {
                slackSend color: 'good', message: "Terraform build ..."                
                sh ("terraform init");
                sh ("terraform validate");
                sh ("terraform apply --auto-approve");
            }
        }
        
        stage('AWX configuration') {
            steps {
                slackSend color: 'good', message: "AWX configuration ..."                
                ansibleTower jobTemplate: 'Geo Citizen workflow', jobType: 'run', templateType: 'workflow', throwExceptionWhenFail: false, towerCredentialsId: '18b16ffa-2c4f-410a-9805-beb077bfe01a', towerLogLevel: 'false', towerServer: 'Geo Citizen AWX'
            }
        }
    
        stage('Geo Citizen results') {

            environment {
                IP = sh (
                        script: "terraform output -raw server-external-ip", 
                        returnStdout: true
                        ).trim()
            }            
            
            steps {
                sh ("terraform output -raw server-external-ip");
                slackSend color: 'warning', message: "Worflow results:"
                slackSend color: 'good', message: "Geo Citizen server: ${IP}:8080/citizen"
                slackSend color: 'good', message: "${currentBuild.durationString}"
                slackSend color: 'good', message: "${currentBuild.currentResult}"
            }         
        }
        
        stage('Slack final message') {
            steps {
                slackSend color: 'good', message: '> *End pipeline*'
            }
        }         
        
    }
}