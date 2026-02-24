pipeline {

agent any

environment {

    // Docker Configuration
    DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
    DOCKER_TAG = "555"

    // SonarQube URL (Windows Docker Desktop compatible)
    SONAR_HOST = "http://host.docker.internal:9000"

    // Terraform directory
    TERRAFORM_DIR = "terraform"

    // Kubernetes namespace
    K8S_NAMESPACE = "devops-sonarqube"

}

stages {

    stage('Clean Workspace') {
        steps {
            echo "STEP 1: Cleaning Workspace..."
            deleteDir()
        }
    }

    stage('Clone GitLab Repository') {
        steps {
            echo "STEP 2: Cloning GitLab Repository..."
            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'
        }
    }

    stage('Verify Project Files') {
        steps {
            echo "STEP 3: Verifying Files..."
            bat '''
            echo ================================
            echo Workspace Files
            echo ================================
            dir
            '''
        }
    }

    stage('Verify SonarQube Running') {
        steps {
            echo "STEP 4: Checking SonarQube container..."
            bat '''
            docker ps | findstr sonarqube
            if %errorlevel% neq 0 (
                echo ERROR: SonarQube container not running!
                exit /b 1
            )
            '''
        }
    }

    stage('SonarQube Code Scan') {
        steps {

            echo "STEP 5: Running SonarQube Scan..."

            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                bat """
                docker run --rm ^
                -e SONAR_HOST_URL=%SONAR_HOST% ^
                -e SONAR_LOGIN=%SONAR_TOKEN% ^
                -v %WORKSPACE%:/usr/src ^
                sonarsource/sonar-scanner-cli ^
                -Dsonar.projectKey=devops-sonarqube-project ^
                -Dsonar.sources=. ^
                -Dsonar.host.url=%SONAR_HOST% ^
                -Dsonar.login=%SONAR_TOKEN% ^
                -Dsonar.javascript.node.maxspace=4096
                """

            }
        }
    }

    stage('Build Docker Image') {
        steps {
            echo "STEP 6: Building Docker Image..."
            bat """
            docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
            docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
            """
        }
    }

    stage('DockerHub Login') {
        steps {
            echo "STEP 7: Logging into DockerHub..."
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
            echo "STEP 8: Pushing Docker Image..."
            bat """
            docker push %DOCKER_IMAGE%:%DOCKER_TAG%
            docker push %DOCKER_IMAGE%:latest
            """
        }
    }

    stage('Terraform Init') {
        steps {
            echo "STEP 9: Terraform Initialization..."
            bat """
            cd %TERRAFORM_DIR%
            terraform init
            """
        }
    }

    stage('Terraform Apply (Deploy to Kubernetes)') {
        steps {
            echo "STEP 10: Deploying to Kubernetes..."

            bat """
            cd %TERRAFORM_DIR%

            REM Auto-use Docker Desktop Kubernetes config
            set KUBECONFIG=%USERPROFILE%\\.kube\\config

            terraform apply ^
            -var="docker_image=%DOCKER_IMAGE%:%DOCKER_TAG%" ^
            -auto-approve
            """
        }
    }

    stage('Verify Kubernetes Deployment') {
        steps {
            echo "STEP 11: Verifying Kubernetes Deployment..."

            bat """
            set KUBECONFIG=%USERPROFILE%\\.kube\\config

            echo ================================
            echo Namespaces
            echo ================================
            kubectl get namespaces

            echo ================================
            echo Deployments
            echo ================================
            kubectl get deployment -n %K8S_NAMESPACE%

            echo ================================
            echo Pods
            echo ================================
            kubectl get pods -n %K8S_NAMESPACE%

            echo ================================
            echo Services
            echo ================================
            kubectl get services -n %K8S_NAMESPACE%
            """
        }
    }

    stage('Verify Monitoring Stack') {
        steps {
            echo "STEP 12: Verifying Monitoring Stack..."

            bat '''
            echo ================================
            echo SonarQube
            echo ================================
            docker ps | findstr sonarqube

            echo ================================
            echo Prometheus
            echo ================================
            docker ps | findstr prometheus

            echo ================================
            echo Grafana
            echo ================================
            docker ps | findstr grafana

            echo ================================
            echo Monitoring OK
            echo ================================
            '''
        }
    }

}

post {

    success {
        echo "========================================"
        echo "SUCCESS: CI/CD Pipeline executed!"
        echo "Docker Image: %DOCKER_IMAGE%:%DOCKER_TAG%"
        echo "Application URL: http://localhost:30007"
        echo "SonarQube URL: http://localhost:9000"
        echo "========================================"
    }

    failure {
        echo "========================================"
        echo "FAILED: Pipeline execution failed."
        echo "Check Jenkins Console Output."
        echo "========================================"
    }

    always {
        echo "Pipeline finished."
    }

}

}
