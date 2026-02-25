pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        DB_PORT    = "3306"
        IMAGE_TAG  = "latest"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/orion-pax77/EasyCRUD-Docker.git'
            }
        }

        stage('Terraform Init & Apply') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds',
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                ]]) {
                    sh """
                        terraform -chdir=terraform init -upgrade
                        terraform -chdir=terraform validate
                        terraform -chdir=terraform apply -auto-approve
                    """
                }
            }
        }

        stage('Fetch RDS Endpoint') {
            steps {
                script {
                    env.RDS_ENDPOINT = sh(
                        script: "terraform -chdir=terraform output -raw rds_endpoint",
                        returnStdout: true
                    ).trim()

                    echo "RDS Endpoint: ${env.RDS_ENDPOINT}"
                }
            }
        }

         stage('Update application.properties') {
     steps {
         script {
             sh """
                 if [ -f backend/src/main/resources/application.properties ]; then
                     sed -i 's|spring.datasource.url=.*|spring.datasource.url=jdbc:mariadb://${RDS_ENDPOINT}:${DB_PORT}/easycrud-mariadb|' backend/src/main/resources/application.properties
                     sed -i 's|spring.datasource.username=.*|spring.datasource.username=admin|' backend/src/main/resources/application.properties
                     sed -i 's|spring.datasource.password=.*|spring.datasource.password=redhat123|' backend/src/main/resources/application.properties
                     sed -i 's|spring.jpa.hibernate.ddl-auto=.*|spring.jpa.hibernate.ddl-auto=update|' backend/src/main/resources/application.properties
                     sed -i 's|spring.jpa.show-sql=.*|spring.jpa.show-sql=true|' backend/src/main/resources/application.properties
                 else
                     echo "application.properties not found!"
                     exit 1
                 fi
             """
        }
    }
}
        
        stage('Build Backend Image') {
            steps {
                dir('backend') {
                    sh "docker build -t orionpax77/easycrud1-jenkins:backend . --no-cache"
                }
            }
        }

        stage('Run Backend Container') {   
            steps {
                sh """
                    docker rm -f easycrud1-jenkins:backend || true
                    docker run -d --name easycrud1-backend -p 8080:8080 orionpax77/easycrud1-jenkins:backend
                """
            }
        }

        stage('Update .env File') {
            steps {
                script {
                    def backendIp = sh(
                        script: "curl -s ifconfig.me",
                        returnStdout: true
                    ).trim()

                    sh """
                        sed -i 's|BACKEND_URL=.*|BACKEND_URL=http://${backendIp}:8080|' .env
                    """
                }
            }
        }

        stage('Build Frontend Image') {
            steps {
                dir('frontend') {
                    sh "docker build -t orionpax77/easycrud1-jenkins:frontend . --no-cache"
                
                }
            }
        }

        stage('Run Frontend Container') {  
            steps {
                sh """
                    docker rm -f easycrud1-jenkins:frontend || true
                    docker run -d --name easycrud1-frontend -p 80:80 orionpax77/easycrud1-jenkins:frontend
                """
            }
        }

        stage('Docker Hub Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-cred',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push orionpax77/easycrud1-jenkins:backend
                        docker push orionpax77/easycrud1-jenkins:frontend}
                        docker logout
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Full Infra + Deployment Successful!"
        }
        failure {
            echo "❌ Pipeline Failed!"
        }
    }
}
