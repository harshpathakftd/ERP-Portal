pipeline {

agent any

environment {

    DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
    DOCKER_TAG = "555"

    SONAR_HOST = "http://host.docker.internal:9000"

    TERRAFORM_DIR = "terraform"

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
            dir
            '''
        }
    }

    stage('SonarQube Code Scan') {
        steps {

            echo "STEP 4: Running SonarQube Scan..."

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
            echo "STEP 5: Building Docker Image..."
            bat """
            docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
            docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
            """
        }
    }

    stage('DockerHub Login') {
        steps {

            echo "STEP 6: DockerHub Login..."

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
            echo "STEP 7: Push Docker Image..."
            bat """
            docker push %DOCKER_IMAGE%:%DOCKER_TAG%
            docker push %DOCKER_IMAGE%:latest
            """
        }
    }

    stage('Terraform Deploy') {
        steps {

            echo "STEP 8: Terraform Deploy..."

            bat """
            cd %TERRAFORM_DIR%

            set KUBECONFIG=%USERPROFILE%\\.kube\\config

            terraform init

            terraform apply ^
            -var="docker_image=%DOCKER_IMAGE%:%DOCKER_TAG%" ^
            -auto-approve
            """
        }
    }

    stage('Verify Kubernetes') {
        steps {

            echo "STEP 9: Verify Kubernetes..."

            bat """
            set KUBECONFIG=%USERPROFILE%\\.kube\\config

            kubectl get pods -n %K8S_NAMESPACE%
            kubectl get services -n %K8S_NAMESPACE%
            """

        }
    }

}

post {

    success {
        echo "SUCCESS: Pipeline executed successfully!"
        echo "App URL: http://localhost:30007"
    }

    failure {
        echo "FAILED: Check Jenkins logs"
    }

}

}
