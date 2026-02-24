pipeline {

    agent any

    environment {

        DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
        DOCKER_TAG = "33"

        SONAR_HOST = "http://host.docker.internal:9000"

    }

    stages {

        stage('Clean Workspace') {

            steps {
                deleteDir()
            }

        }

        stage('Clone GitLab Repository') {

            steps {

                echo "Cloning GitLab Repository..."

                git branch: 'main',
                url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'

            }

        }

        stage('Verify Files') {

            steps {

                bat '''
                echo ===================================
                echo Verifying Workspace Files
                echo ===================================
                dir
                '''

            }

        }

        stage('SonarQube Scan') {

            steps {

                echo "Running SonarQube Scan..."

                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                    bat """
                    docker run --rm ^
                    -v %cd%:/usr/src ^
                    sonarsource/sonar-scanner-cli ^
                    -Dsonar.host.url=%SONAR_HOST% ^
                    -Dsonar.login=%SONAR_TOKEN%
                    """

                }

            }

        }

        stage('Build Docker Image') {

            steps {

                echo "Building Docker Image..."

                bat """
                docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
                """

            }

        }

        stage('DockerHub Login') {

            steps {

                echo "Logging into DockerHub..."

                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    bat """
                    echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                    """

                }

            }

        }

        stage('Push Docker Image') {

            steps {

                echo "Pushing Docker Image..."

                bat """
                docker push %DOCKER_IMAGE%:%DOCKER_TAG%
                """

            }

        }

        stage('Terraform Init') {

            steps {

                echo "Initializing Terraform..."

                bat """
                cd terraform
                terraform init
                """

            }

        }

        stage('Terraform Apply') {

            steps {

                echo "Applying Terraform Infrastructure..."

                bat """
                cd terraform
                terraform apply -auto-approve
                """

            }

        }

        stage('Deploy to Kubernetes') {

            steps {

                echo "Deploying Application to Kubernetes..."

                bat """
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                """

            }

        }

        stage('Verify Kubernetes Deployment') {

            steps {

                echo "Verifying Kubernetes Deployment..."

                bat """
                kubectl get pods
                kubectl get services
                """

            }

        }

        stage('Monitoring Verification (SonarQube, Prometheus, Grafana)') {

            steps {

                echo "Verifying Monitoring Stack..."

                bat '''
                echo ===================================
                echo Checking SonarQube Container
                echo ===================================
                docker ps | findstr sonarqube || (
                    echo ERROR: SonarQube container not running
                    exit 1
                )

                echo ===================================
                echo Checking Prometheus Container
                echo ===================================
                docker ps | findstr prometheus || (
                    echo ERROR: Prometheus container not running
                    exit 1
                )

                echo ===================================
                echo Checking Grafana Container
                echo ===================================
                docker ps | findstr grafana || (
                    echo ERROR: Grafana container not running
                    exit 1
                )

                echo ===================================
                echo Monitoring Stack Verification SUCCESS
                echo ===================================
                '''

            }

        }

    }

    post {

        success {

            echo "SUCCESS: Full DevOps CI/CD Pipeline executed successfully!"

        }

        failure {

            echo "FAILED: Pipeline execution failed. Check Jenkins console logs."

        }

    }

}