pipeline {
    agent any

    environment {
        AWS_REGION = "us-east-1"
        DB_HOST    = "easycrud-mysql.cwliqc0oaf7s.us-east-1.rds.amazonaws.com"
        DB_PORT    = "3306"
    }

    options {
        timestamps()
    }

    stages {

        stage('Checkout Code') {
            steps {
                echo "Cloning Repository..."
                git branch: 'main',
                    url: 'https://github.com/orion-pax77/EasyCRUD-Docker.git'
            }
        }

        stage('Terraform Init') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh '''
                        terraform -chdir=terraform init -upgrade
                        terraform -chdir=terraform validate
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform -chdir=terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply Infrastructure') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-creds'
                ]]) {
                    sh 'terraform -chdir=terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Create RDS Database & Table') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'rds-creds',
                    usernameVariable: 'DB_USER',
                    passwordVariable: 'DB_PASS'
                )]) {

                    sh '''
                    export MYSQL_PWD="$DB_PASS"

                    mysql -h "$DB_HOST" \
                          -P "$DB_PORT" \
                          -u "$DB_USER" <<EOF

                    CREATE DATABASE IF NOT EXISTS student_db;

                    CREATE USER IF NOT EXISTS 'admin'@'%' IDENTIFIED BY 'redhat123';

                    GRANT ALL PRIVILEGES ON student_db.* TO 'admin'@'%';

                    FLUSH PRIVILEGES;

                    USE student_db;

                    CREATE TABLE IF NOT EXISTS students (
                      id bigint(20) NOT NULL AUTO_INCREMENT,
                      name varchar(255) DEFAULT NULL,
                      email varchar(255) DEFAULT NULL,
                      course varchar(255) DEFAULT NULL,
                      student_class varchar(255) DEFAULT NULL,
                      percentage double DEFAULT NULL,
                      branch varchar(255) DEFAULT NULL,
                      mobile_number varchar(255) DEFAULT NULL,
                      PRIMARY KEY (id)
                    );

EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "✅ Infrastructure + RDS Setup Completed Successfully!"
        }
        failure {
            echo "❌ Pipeline Failed!"
        }
        always {
            echo "Pipeline Execution Finished."
        }
    }
}
