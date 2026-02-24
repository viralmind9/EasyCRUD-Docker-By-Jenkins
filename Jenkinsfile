pipeline {
    agent any

    environment {
        // Docker Hub
        DOCKERHUB_FRONT = "orionpax77/easycrud-frontend"
        DOCKERHUB_BACK  = "orionpax77/easycrud-backend"

        // Terraform vars
        AWS_REGION = "us-east-1"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git url: "https://github.com/orion-pax77/EasyCRUD-Docker.git", branch: "main"
            }
        }

        stage('Terraform Init & Apply Infra') {
            steps {
                dir('Terraform') {
                    withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                        terraform init
                        terraform apply -auto-approve
                    '''
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh """
                docker build -t $DOCKERHUB_FRONT:latest ./frontend
                docker build -t $DOCKERHUB_BACK:latest ./backend
                """
            }
        }

        stage('Docker Hub Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',
                    usernameVariable: 'DOCKERHUB_USER',
                    passwordVariable: 'DOCKERHUB_PASS'
                )]) {
                    sh '''
                    echo $DOCKERHUB_PASS | docker login -u $DOCKERHUB_USER --password-stdin
                    '''
                }
            }
        }

        stage('Push Images to Docker Hub') {
            steps {
                sh """
                docker push $DOCKERHUB_FRONT:latest
                docker push $DOCKERHUB_BACK:latest
                """
            }
        }

        stage('Deploy to Provisioned EC2') {
            steps {
                script {
                    def publicIp = sh(
                        script: "terraform -chdir=terraform output -raw public_ip",
                        returnStdout: true
                    ).trim()

                    sh """
                    ssh -o StrictHostKeyChecking=no -i /path/to/your/key.pem ubuntu@$publicIp << 'EOF'
                        docker rm -f easycrud_frontend || true
                        docker rm -f easycrud_backend || true

                        docker pull $DOCKERHUB_FRONT:latest
                        docker pull $DOCKERHUB_BACK:latest

                        docker run -d --name easycrud_frontend -p 80:80 $DOCKERHUB_FRONT:latest
                        docker run -d --name easycrud_backend -p 8081:8081 $DOCKERHUB_BACK:latest
                    EOF
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🚀 Deployment Completed Successfully!"
        }
        failure {
            echo "❌ Deployment Failed!"
        }
    }
}
