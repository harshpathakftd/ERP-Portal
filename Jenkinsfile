pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
}

environment {

    DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
    DOCKER_TAG = "33"

    SONAR_HOST = "http://host.docker.internal:9000"

    GIT_URL = "https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git"
    GIT_BRANCH = "main"

}

stages {

    stage('Clean Workspace') {
        steps {
            echo "Cleaning Workspace..."
            deleteDir()
        }
    }

    stage('Clone GitLab Repository') {
        steps {

            echo "Cloning GitLab Repository..."

            git branch: "${GIT_BRANCH}",
                url: "${GIT_URL}"

        }
    }

    stage('Verify Workspace Files') {
        steps {

            bat '''
            echo ===================================
            echo Workspace Files
            echo ===================================
            dir
            echo ===================================
            '''

        }
    }

    stage('Verify Required Tools') {
        steps {

            bat '''
            git --version
            docker version
            kubectl version --client
            terraform version
            '''

        }
    }

    stage('SonarQube Scan') {
        steps {

            echo "Running SonarQube Scan..."

            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                bat '''
                docker run --rm ^
                -v "%WORKSPACE%:/usr/src" ^
                -w /usr/src ^
                sonarsource/sonar-scanner-cli ^
                -Dsonar.projectKey=devops-sonarqube-project ^
                -Dsonar.sources=. ^
                -Dsonar.host.url=%SONAR_HOST% ^
                -Dsonar.login=%SONAR_TOKEN%
                '''

            }

        }
    }

    stage('Build Docker Image') {
        steps {

            echo "Building Docker Image..."

            bat '''
            docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
            '''

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

                bat '''
                echo %DOCKER_PASS% | docker login -u %DOCKER_USER% --password-stdin
                '''

            }

        }
    }

    stage('Push Docker Image') {
        steps {

            echo "Pushing Docker Image..."

            bat '''
            docker push %DOCKER_IMAGE%:%DOCKER_TAG%
            '''

        }
    }

    stage('Terraform Init') {
        steps {

            script {

                if (fileExists('terraform')) {

                    bat '''
                    cd terraform
                    terraform init
                    '''

                } else {

                    echo "Terraform folder not found, skipping Terraform."

                }

            }

        }
    }

    stage('Terraform Apply') {
        steps {

            script {

                if (fileExists('terraform')) {

                    bat '''
                    cd terraform
                    terraform apply -auto-approve
                    '''

                } else {

                    echo "Terraform folder not found, skipping Terraform."

                }

            }

        }
    }

    stage('Deploy to Kubernetes') {
        steps {

            echo "Deploying Application to Kubernetes..."

            bat '''
            kubectl apply -f k8s/

            kubectl rollout restart deployment

            kubectl get pods
            kubectl get svc
            '''

        }
    }

    stage('Verify Kubernetes Deployment') {
        steps {

            bat '''
            echo ===================================
            kubectl get pods -o wide
            kubectl get svc
            echo ===================================
            '''

        }
    }

    stage('Monitoring Verification') {
        steps {

            bat '''
            echo Checking SonarQube...
            docker ps | findstr sonarqube

            echo Checking Prometheus...
            docker ps | findstr prometheus

            echo Checking Grafana...
            docker ps | findstr grafana

            echo Monitoring Stack Verification SUCCESS
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

    always {
        echo "Pipeline Finished."
    }

}

}
