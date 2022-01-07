pipeline {
  
    agent {
        node {
            label 'master'
        }
    }

    stages {
        stage('SonarQube analysis') {
        steps {
            script {
                scannerHome = tool 'sonar-scanner-client'
            }
            withSonarQubeEnv('sonar') {
                sh "${scannerHome}/bin/sonar-scanner"
            }
          }
        }
       
        stage("Quality gate") {
            steps {
                waitForQualityGate abortPipeline:  false
            }
        }
     }
  }