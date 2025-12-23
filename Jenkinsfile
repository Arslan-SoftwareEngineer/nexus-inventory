pipeline {
    agent any

    tools {
        // These names must match what you entered in Step 2
        maven 'Maven'
        jdk 'JAVA_HOME'
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code from GitHub...'
                // Jenkins automatically pulls code here
            }
        }

        stage('Build') {
            steps {
                echo 'Building the application...'
                // UBUNTU CHANGE: We use 'sh' instead of 'bat'
                // We also make the file executable just in case
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Test') {
            steps {
                echo 'Running Unit Tests...'
                sh 'mvn test'
            }
        }
    }

    post {
        success {
            echo 'Build Successful! War file generated.'
            archiveArtifacts artifacts: 'target/*.war', fingerprint: true
        }
        failure {
            echo 'Build Failed. Please check the logs.'
        }
    }
}
