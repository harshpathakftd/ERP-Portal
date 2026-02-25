pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
}

environment {

    APP_NAME = "erp-project"

    // Dynamic Docker tag
    IMAGE_TAG = "${BUILD_NUMBER}"

    DOCKER_IMAGE = "shivsoftapp/sonar-erp"

    DOCKERHUB_CREDS = credentials('dockerhub-creds')

    SONAR_HOST = "http://host.docker.internal:9000"

    SONAR_TOKEN = credentials('sonar-token')

    KUBECONFIG = "C:\\Users\\rahul\\.kube\\config"

    TERRAFORM_DIR = "terraform"

    PROMETHEUS_URL = "http://localhost:9090"

    GRAFANA_URL = "http://localhost:3000"
}

stages {

    stage('Checkout Code') {

        steps {

            echo "Cloning source code..."

            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'
        }
    }

    stage('Install Dependencies') {

        steps {

            echo "Installing Python dependencies..."

            bat """
            docker run --rm ^
            -v "%WORKSPACE%:/app" ^
            -w /app ^
            python:3.11 ^
            pip install -r erp.txt
            """
        }
    }

    stage('SonarQube Analysis') {

        steps {

            echo "Running SonarQube scan..."

            bat """
            docker run --rm ^
            -e SONAR_HOST_URL=%SONAR_HOST% ^
            -e SONAR_LOGIN=%SONAR_TOKEN% ^
            -v "%WORKSPACE%:/usr/src" ^
            sonarsource/sonar-scanner-cli ^
            -Dsonar.projectKey=%APP_NAME% ^
            -Dsonar.sources=. ^
            -Dsonar.host.url=%SONAR_HOST% ^
            -Dsonar.login=%SONAR_TOKEN%
            """
        }
    }

    stage('Quality Gate Check') {

        steps {

            script {

                timeout(time: 10, unit: 'MINUTES') {

                    def qualityGate = waitForQualityGate()

                    if (qualityGate.status != 'OK') {

                        error "SonarQube Quality Gate Failed: ${qualityGate.status}"

                    }

                }

            }

        }

    }

    stage('Django Validation') {

        steps {

            echo "Validating Django project..."

            bat """
            docker run --rm ^
            -v "%WORKSPACE%:/app" ^
            -w /app ^
            python:3.11 ^
            python manage.py check
            """
        }
    }

    stage('Build Docker Image') {

        steps {

            echo "Building Docker image..."

            bat "docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% ."

        }

    }

    stage('DockerHub Login') {

        steps {

            echo "Logging into DockerHub..."

            bat """
            docker login ^
            -u %DOCKERHUB_CREDS_USR% ^
            -p %DOCKERHUB_CREDS_PSW%
            """

        }

    }

    stage('Push Docker Image') {

        steps {

            echo "Pushing Docker image..."

            bat "docker push %DOCKER_IMAGE%:%IMAGE_TAG%"

        }

    }

    stage('Terraform Init') {

        steps {

            echo "Terraform initialization..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform init"

            }

        }

    }

    stage('Terraform Validate') {

        steps {

            echo "Terraform validation..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform validate"

            }

        }

    }

    stage('Terraform Plan') {

        steps {

            echo "Terraform plan..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform plan -out=tfplan"

            }

        }

    }

    stage('Terraform Apply') {

        steps {

            echo "Terraform apply..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform apply -auto-approve tfplan"

            }

        }

    }

    stage('Deploy to Kubernetes') {

        steps {

            echo "Deploying to Kubernetes..."

            bat """
            kubectl --kubeconfig=%KUBECONFIG% apply -f k8s\\deployment.yaml
            kubectl --kubeconfig=%KUBECONFIG% apply -f k8s\\service.yaml
            """

        }

    }

    stage('Verify Deployment') {

        steps {

            echo "Verifying deployment..."

            bat "kubectl --kubeconfig=%KUBECONFIG% get pods"

            bat "kubectl --kubeconfig=%KUBECONFIG% get svc"

        }

    }

    stage('Rollout Status') {

        steps {

            echo "Checking rollout status..."

            bat "kubectl --kubeconfig=%KUBECONFIG% rollout status deployment/erp-deployment"

        }

    }

    stage('Monitoring Check') {

        steps {

            echo "Checking Prometheus..."

            bat "curl %PROMETHEUS_URL%"

            echo "Checking Grafana..."

            bat "curl %GRAFANA_URL%"

        }

    }

}

post {

    success {

        echo "======================================"

        echo "CI/CD PIPELINE COMPLETED SUCCESSFULLY"

        echo "======================================"

        echo "Docker Image: %DOCKER_IMAGE%:%IMAGE_TAG%"

        echo "SonarQube: http://localhost:9000"

        echo "Prometheus: http://localhost:9090"

        echo "Grafana: http://localhost:3000"

    }

    failure {

        echo "PIPELINE FAILED - CHECK LOGS"

    }

    always {

        cleanWs()

    }

}


}
