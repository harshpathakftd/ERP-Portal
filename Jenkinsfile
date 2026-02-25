pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
    buildDiscarder(logRotator(numToKeepStr: '10'))
}

environment {

    APP_NAME = "erp-project"

    // Dynamic image tag from Jenkins build number
    IMAGE_TAG = "${BUILD_NUMBER}"

    DOCKER_IMAGE = "shivsoftapp/sonar-erp"

    DOCKERHUB_CREDS = credentials('dockerhub-creds')

    SONAR_HOST = "http://host.docker.internal:9000"

    SONAR_TOKEN = credentials('sonar-token')

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

            echo "Running SonarQube analysis..."

            bat """
            docker run --rm ^
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

                        error "Quality Gate Failed: ${qualityGate.status}"

                    } else {

                        echo "Quality Gate PASSED"

                    }

                }

            }

        }

    }

    stage('Django Validation') {

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

            echo "Terraform Init..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform init"

            }

        }

    }

    stage('Terraform Validate') {

        steps {

            echo "Terraform Validate..."

            dir("${TERRAFORM_DIR}") {

                bat "terraform validate"

            }

        }

    }

    stage('Terraform Plan') {

        steps {

            echo "Terraform Plan with dynamic image..."

            dir("${TERRAFORM_DIR}") {

                bat """
                terraform plan ^
                -var="docker_image=%DOCKER_IMAGE%" ^
                -var="image_tag=%IMAGE_TAG%" ^
                -out=tfplan
                """

            }

        }

    }

    stage('Terraform Apply') {

        steps {

            echo "Terraform Apply..."

            dir("${TERRAFORM_DIR}") {

                bat """
                terraform apply ^
                -auto-approve ^
                tfplan
                """

            }

        }

    }

    stage('Verify Kubernetes Deployment') {

        steps {

            echo "Verifying Kubernetes deployment..."

            bat "kubectl get pods"

            bat "kubectl get svc"

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

        echo "========================================"
        echo "CI/CD PIPELINE EXECUTED SUCCESSFULLY"
        echo "========================================"

        echo "Docker Image:"
        echo "%DOCKER_IMAGE%:%IMAGE_TAG%"

        echo "SonarQube:"
        echo "http://localhost:9000"

        echo "Prometheus:"
        echo "http://localhost:9090"

        echo "Grafana:"
        echo "http://localhost:3000"

        echo "Application URL:"
        echo "http://localhost:30007"

    }

    failure {

        echo "PIPELINE FAILED - CHECK LOGS"

    }

    always {

        cleanWs()

    }

}


}
