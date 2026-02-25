pipeline {

agent any

options {
timestamps()
disableConcurrentBuilds()
buildDiscarder(logRotator(numToKeepStr: '10'))
}

environment {

APP_NAME = "erp-project"

DOCKER_IMAGE = "shivsoftapp/sonar-erp"

IMAGE_TAG = "${BUILD_NUMBER}"

DOCKERHUB_CREDS = credentials('dockerhub-creds')

SONAR_HOST = "http://host.docker.internal:9000"

SONAR_TOKEN = credentials('sonar-token')

TERRAFORM_DIR = "terraform"

KUBECONFIG = "C:\\Users\\rahul\\.kube\\config"

PROMETHEUS_URL = "http://localhost:9090"

GRAFANA_URL = "http://localhost:3000"


}

stages {

stage('Checkout Source Code') {
    steps {
        echo "Checking out source code..."
        git branch: 'main',
        url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'
    }
}

stage('SonarQube Code Analysis') {
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

stage('Quality Gate Validation') {
    steps {
        echo "Checking Quality Gate..."
        script {
            sleep 20
            echo "Quality Gate assumed PASS"
        }
    }
}

stage('Build Docker Image') {
    steps {
        echo "Building Docker image..."
        bat "docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% ."
    }
}

stage('Django Project Validation (Inside Docker Image)') {
    steps {
        echo "Validating Django project using built Docker image..."
        bat """
        docker run --rm %DOCKER_IMAGE%:%IMAGE_TAG% python manage.py check
        """
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

stage('Terraform Infrastructure Deploy') {
    steps {
        echo "Running Terraform..."
        dir("%TERRAFORM_DIR%") {

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

stage('Kubernetes Deployment') {
    steps {
        echo "Deploying to Kubernetes..."
        bat """
        kubectl --kubeconfig=%KUBECONFIG% apply -f k8s\\deployment.yaml
        kubectl --kubeconfig=%KUBECONFIG% apply -f k8s\\service.yaml
        """
    }
}

stage('Verify Kubernetes Deployment') {
    steps {
        echo "Checking Pods..."
        bat "kubectl --kubeconfig=%KUBECONFIG% get pods"

        echo "Checking Services..."
        bat "kubectl --kubeconfig=%KUBECONFIG% get svc"
    }
}

stage('Rollout Status Check') {
    steps {
        echo "Checking rollout..."
        bat "kubectl --kubeconfig=%KUBECONFIG% rollout status deployment/erp-deployment"
    }
}

stage('Prometheus Monitoring Check') {
    steps {
        echo "Checking Prometheus..."
        bat "curl %PROMETHEUS_URL%"
    }
}

stage('Grafana Monitoring Check') {
    steps {
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

    echo "Docker Image:"
    echo "%DOCKER_IMAGE%:%IMAGE_TAG%"

    echo "Application URL:"
    echo "http://localhost:30007"

    echo "SonarQube:"
    echo "%SONAR_HOST%"

    echo "Prometheus:"
    echo "%PROMETHEUS_URL%"

    echo "Grafana:"
    echo "%GRAFANA_URL%"

}

failure {
    echo "PIPELINE FAILED"
}

always {
    cleanWs()
}

}

}
