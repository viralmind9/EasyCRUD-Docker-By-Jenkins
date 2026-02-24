pipeline {
    agent any

    environment {
        DOCKERHUB_REPO_FRONT = "orionpax77/easycrud-frontend"
        DOCKERHUB_REPO_BACK = "orionpax77/easycrud-backend"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: "https://github.com/orion-pax77/EasyCRUD-Docker.git", branch: "main"
            }
        }

        stage('Build Frontend Image') {
            steps {
                sh "docker build -t $DOCKERHUB_REPO_FRONT:latest ./frontend"
            }
        }

        stage('Build Backend Image') {
            steps {
                sh "docker build -t $DOCKERHUB_REPO_BACK:latest ./backend"
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh """
                    echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                    """
                }
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                sh """
                docker push $DOCKERHUB_REPO_FRONT:latest
                docker push $DOCKERHUB_REPO_BACK:latest
                """
            }
        }

        stage('Stop Old Containers') {
            steps {
                sh '''
                docker rm -f easycrud_frontend || true
                docker rm -f easycrud_backend || true
                '''
            }
        }

        stage('Run Containers') {
            steps {
                sh """
                docker run -d --name easycrud_frontend -p 80:80 $DOCKERHUB_REPO_FRONT:latest
                docker run -d --name easycrud_backend -p 8081:8081 $DOCKERHUB_REPO_BACK:latest
                """
            }
        }
    }

    post {
        success {
            echo "🚀 Application Deployed Successfully!"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
