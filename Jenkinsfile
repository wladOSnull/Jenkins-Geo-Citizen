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
                slackSend color: 'good', message: "Terraform checkout"                
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

        stage ('Rebuild Geo Citizen + DB configuring') {
            steps {
                parallel(
                    a: {
                        slackSend color: 'warning', message: "Rebuild Geo Citizen ..."
                        build job: 'GitHub-Nexus-Geo-Citizen'                        
                    },
                    b: {
                        slackSend color: 'warning', message: "DB configuring ..."                        
                        ansibleTower(
                            jobTemplate: 'Geo Citizen db LB', 
                            jobType: 'run', 
                            throwExceptionWhenFail: false, 
                            towerCredentialsId: '', 
                            towerLogLevel: 'false', 
                            towerServer: 'Geo Citizen AWX'
                        )
                    }
                )
            }
        }
       
        stage('Slack final message') {
            steps {
                slackSend color: 'good', message: "${currentBuild.durationString}"
                slackSend color: 'good', message: "${currentBuild.currentResult}"                
                slackSend color: 'good', message: "> *End pipeline*"
            }
        }         
        
    }
}
