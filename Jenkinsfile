pipeline {

```
agent any

environment {

    // Docker settings
    DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
    DOCKER_TAG = "555"

    // SonarQube
    SONAR_HOST = "http://host.docker.internal:9000"

    // Terraform directory
    TERRAFORM_DIR = "terraform"

    // Kubernetes namespace
    K8S_NAMESPACE = "devops-sonarqube"

    // Windows kubeconfig automatic path
    KUBECONFIG = "${env.USERPROFILE}\\.kube\\config"

}

stages {

    stage('Clean Workspace') {
        steps {
            echo "Cleaning workspace..."
            deleteDir()
        }
    }

    stage('Clone Repository') {
        steps {
            echo "Cloning GitLab repository..."
            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'
        }
    }

    stage('Verify Files') {
        steps {
            bat '''
            echo ====================================
            echo Project Files:
            echo ====================================
            dir
            '''
        }
    }

    stage('SonarQube Scan') {
        steps {

            echo "Running SonarQube scan..."

            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                bat """
                docker run --rm ^
                --add-host=host.docker.internal:host-gateway ^
                -v %WORKSPACE%:/usr/src ^
                sonarsource/sonar-scanner-cli ^
                -Dsonar.projectKey=devops-sonarqube-project ^
                -Dsonar.sources=. ^
                -Dsonar.host.url=%SONAR_HOST% ^
                -Dsonar.login=%SONAR_TOKEN%
                """

            }
        }
    }

    stage('Build Docker Image') {
        steps {

            echo "Building Docker image..."

            bat """
            docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% .
            docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest
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

            echo "Pushing Docker image..."

            bat """
            docker push %DOCKER_IMAGE%:%DOCKER_TAG%
            docker push %DOCKER_IMAGE%:latest
            """

        }
    }

    stage('Terraform Deploy to Kubernetes') {
        steps {

            echo "Deploying to Kubernetes using Terraform..."

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

    stage('Verify Kubernetes Deployment') {
        steps {

            echo "Verifying deployment..."

            bat """

            set KUBECONFIG=%USERPROFILE%\\.kube\\config

            kubectl get namespaces

            kubectl get deployments -n %K8S_NAMESPACE%

            kubectl get pods -n %K8S_NAMESPACE%

            kubectl get services -n %K8S_NAMESPACE%

            """

        }
    }

    stage('Verify Monitoring Containers') {
        steps {

            echo "Checking SonarQube, Prometheus, Grafana..."

            bat '''
            docker ps | findstr sonarqube
            docker ps | findstr prometheus
            docker ps | findstr grafana
            '''

        }
    }

}

post {

    success {

        echo "SUCCESS: Full CI/CD pipeline executed successfully!"
        echo "Application URL: http://localhost:30007"

    }

    failure {

        echo "FAILED: Pipeline execution failed. Check logs."

    }

    always {

        echo "Pipeline finished."

    }

}
```

}
