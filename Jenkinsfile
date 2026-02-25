pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
}

environment {

    APP_NAME = "erp-project"

    IMAGE_TAG = "${BUILD_NUMBER}"

    DOCKER_IMAGE = "shivsoftapp/sonar-erp"

    DOCKERHUB_CREDS = credentials('dockerhub-creds')

    SONARQUBE_SERVER = "SonarQube"

    TERRAFORM_DIR = "terraform"

    PROMETHEUS_URL = "http://localhost:9090"

    GRAFANA_URL = "http://localhost:3000"

}

stages {

    stage('Checkout') {

        steps {

            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'

        }

    }

    stage('Install Dependencies') {

        steps {

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

            withSonarQubeEnv("${SONARQUBE_SERVER}") {

                bat """
                sonar-scanner ^
                -Dsonar.projectKey=%APP_NAME% ^
                -Dsonar.sources=. ^
                """

            }

        }

    }

    stage('Quality Gate') {

        steps {

            timeout(time: 10, unit: 'MINUTES') {

                waitForQualityGate abortPipeline: true

            }

        }

    }

    stage('Build Docker Image') {

        steps {

            bat "docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% ."

        }

    }

    stage('Docker Login') {

        steps {

            bat """
            docker login ^
            -u %DOCKERHUB_CREDS_USR% ^
            -p %DOCKERHUB_CREDS_PSW%
            """

        }

    }

    stage('Push Docker Image') {

        steps {

            bat "docker push %DOCKER_IMAGE%:%IMAGE_TAG%"

        }

    }

    stage('Terraform Deploy') {

        steps {

            dir("${TERRAFORM_DIR}") {

                bat "terraform init"

                bat """
                terraform plan ^
                -var="docker_image=%DOCKER_IMAGE%" ^
                -var="image_tag=%IMAGE_TAG%" ^
                -out=tfplan
                """

                bat "terraform apply -auto-approve tfplan"

            }

        }

    }

    stage('Verify Deployment') {

        steps {

            bat "kubectl get pods"

            bat "kubectl get svc"

        }

    }

    stage('Monitoring Check') {

        steps {

            bat "curl %PROMETHEUS_URL%"

            bat "curl %GRAFANA_URL%"

        }

    }

}

post {

    success {

        echo "================================="
        echo "PIPELINE SUCCESSFULLY COMPLETED"
        echo "================================="

        echo "Docker Image: %DOCKER_IMAGE%:%IMAGE_TAG%"

        echo "SonarQube: http://localhost:9000"

        echo "Application: http://localhost:30007"

    }

    failure {

        echo "PIPELINE FAILED"

    }

}

}
