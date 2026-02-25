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

    // SonarQube (Docker container)
    SONAR_HOST = "http://host.docker.internal:9000"
    SONAR_TOKEN = credentials('sonar-token')

    // Kubernetes (Docker Desktop)
    KUBECONFIG = "C:\\Users\\rahul\\.kube\\config"

    // Monitoring tools (already running containers)
    PROMETHEUS_URL = "http://localhost:9090"
    GRAFANA_URL = "http://localhost:3000"

}

stages {

    stage('Checkout Code') {

        steps {

            echo "Cloning source code from Git..."

            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'

        }

    }

    stage('Install Python Dependencies') {

        steps {

            echo "Installing dependencies..."

            bat """
            python -m pip install --upgrade pip
            pip install -r erp.txt
            """

        }

    }

    stage('SonarQube Analysis (Docker Scanner)') {

        steps {

            echo "Running SonarQube analysis..."

            bat """
            docker run --rm ^
            -v "%WORKSPACE%:/usr/src" ^
            -w /usr/src ^
            sonarsource/sonar-scanner-cli:latest ^
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

    stage('Django Application Validation') {

        steps {

            echo "Validating Django application..."

            bat """
            python manage.py check
            """

        }

    }

    stage('Build Docker Image') {

        steps {

            echo "Building Docker image..."

            bat """
            docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% .
            """

        }

    }

    stage('DockerHub Login') {

        steps {

            echo "Logging into DockerHub..."

            bat """
            docker login -u %DOCKERHUB_CREDS_USR% -p %DOCKERHUB_CREDS_PSW%
            """

        }

    }

    stage('Push Docker Image') {

        steps {

            echo "Pushing image to DockerHub..."

            bat """
            docker push %DOCKER_IMAGE%:%IMAGE_TAG%
            """

        }

    }

    stage('Deploy to Kubernetes') {

        steps {

            echo "Deploying to Kubernetes cluster..."

            bat """
            kubectl apply -f k8s\\deployment.yaml
            kubectl apply -f k8s\\service.yaml
            """

        }

    }

    stage('Verify Kubernetes Deployment') {

        steps {

            echo "Checking pods..."

            bat "kubectl get pods"

            echo "Checking services..."

            bat "kubectl get svc"

        }

    }

    stage('Kubernetes Rollout Status') {

        steps {

            echo "Checking rollout status..."

            bat """
            kubectl rollout status deployment/erp-deployment
            """

        }

    }

    stage('Monitoring Verification') {

        steps {

            echo "Verifying Prometheus..."

            bat """
            curl %PROMETHEUS_URL%
            """

            echo "Verifying Grafana..."

            bat """
            curl %GRAFANA_URL%
            """

        }

    }

}

post {

    success {

        echo "====================================="
        echo "CI/CD PIPELINE EXECUTED SUCCESSFULLY"
        echo "====================================="

        echo "SonarQube: http://localhost:9000"
        echo "Prometheus: http://localhost:9090"
        echo "Grafana: http://localhost:3000"

        echo "Docker Image: %DOCKER_IMAGE%:%IMAGE_TAG%"

        echo "Application deployed successfully!"

    }

    failure {

        echo "====================================="
        echo "PIPELINE FAILED"
        echo "Check Jenkins console logs"
        echo "====================================="

    }

    always {

        cleanWs()

    }

}

}
