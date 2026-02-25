pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
}

environment {

    // Application
    APP_NAME = "erp-project"

    // DockerHub
    DOCKER_IMAGE = "shivsoftapp/sonar-erp"
    IMAGE_TAG = "033"
    DOCKERHUB_CREDS = credentials('dockerhub-creds')

    // SonarQube
    SONAR_HOST = "http://host.docker.internal:9000"
    SONAR_TOKEN = credentials('sonar-token')

    // Kubernetes
    KUBECONFIG = "C:\\Users\\rahul\\.kube\\config"

    // Terraform
    TERRAFORM_DIR = "terraform"

    // Monitoring
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

    stage('Install Python Dependencies (Docker Based)') {

        steps {

            echo "Installing dependencies using Python Docker container..."

            bat """
            docker run --rm ^
            -v "%WORKSPACE%:/app" ^
            -w /app ^
            python:3.11 ^
            pip install --upgrade pip
            """

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
            -v "%WORKSPACE%:/usr/src" ^
            -w /usr/src ^
            sonarsource/sonar-scanner-cli ^
            -Dsonar.projectKey=erp-project ^
            -Dsonar.projectName=erp-project ^
            -Dsonar.sources=. ^
            -Dsonar.python.version=3 ^
            -Dsonar.host.url=%SONAR_HOST% ^
            -Dsonar.login=%SONAR_TOKEN%
            """

        }

    }

    stage('Quality Gate Check') {

        steps {

            timeout(time: 15, unit: 'MINUTES') {

                waitForQualityGate abortPipeline: true

            }

        }

    }

    stage('Django Validation (Docker Based)') {

        steps {

            echo "Running Django validation..."

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

            echo "DockerHub login..."

            bat "docker login -u %DOCKERHUB_CREDS_USR% -p %DOCKERHUB_CREDS_PSW%"

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

            echo "Terraform init..."

            dir("%TERRAFORM_DIR%") {

                bat "terraform init"

            }

        }

    }

    stage('Terraform Validate') {

        steps {

            echo "Terraform validate..."

            dir("%TERRAFORM_DIR%") {

                bat "terraform validate"

            }

        }

    }

    stage('Terraform Plan') {

        steps {

            echo "Terraform plan..."

            dir("%TERRAFORM_DIR%") {

                bat "terraform plan -out=tfplan"

            }

        }

    }

    stage('Terraform Apply') {

        steps {

            echo "Terraform apply..."

            dir("%TERRAFORM_DIR%") {

                bat "terraform apply -auto-approve tfplan"

            }

        }

    }

    stage('Deploy to Kubernetes') {

        steps {

            echo "Deploying to Kubernetes..."

            bat """
            kubectl apply -f k8s\\deployment.yaml
            kubectl apply -f k8s\\service.yaml
            """

        }

    }

    stage('Verify Deployment') {

        steps {

            echo "Checking Kubernetes pods..."

            bat "kubectl get pods"

            echo "Checking Kubernetes services..."

            bat "kubectl get svc"

        }

    }

    stage('Rollout Status') {

        steps {

            echo "Checking rollout..."

            bat "kubectl rollout status deployment/erp-deployment"

        }

    }

    stage('Monitoring Verification') {

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

        echo "====================================="
        echo "CI/CD PIPELINE SUCCESSFULLY COMPLETED"
        echo "====================================="

        echo "SonarQube → http://localhost:9000"
        echo "Prometheus → http://localhost:9090"
        echo "Grafana → http://localhost:3000"

        echo "Docker Image → %DOCKER_IMAGE%:%IMAGE_TAG%"
        echo "Kubernetes Deployment → SUCCESS"

    }

    failure {

        echo "PIPELINE FAILED - CHECK LOGS"

    }

    always {

        cleanWs()

    }

}

}
