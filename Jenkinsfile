pipeline { 
    agent any 
    stages {
        stage('Build') { 
            steps { 
                sh 'make install' 
            }
        }
        stage('Test'){
            steps {
                sh 'make test'
            }
        }
        stage('Deploy') {
            steps {
                sh 'make deploy'
            }
        }
    }
}