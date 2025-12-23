pipeline {
    agent any

    tools {
        maven 'Maven'
        jdk 'JAVA_HOME'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                echo 'Running Unit Tests...'
                sh 'mvn test'
            }
        }

        stage('Deploy') {
            steps {
                echo 'Deploying to Tomcat...'
                // REPLACE THIS PATH with your actual Tomcat webapps folder path
                sh 'cp target/*.war /opt/tomcat/webapps/NexusInventory.war'
            }
        }
    }

    post {
        success {
            echo 'Build & Deployment Successful!'
            // Optional: Archive the artifact in Jenkins too
            archiveArtifacts artifacts: 'target/*.war', fingerprint: true
        }
        failure {
            echo 'Pipeline Failed. Check logs.'
        }
    }
}
