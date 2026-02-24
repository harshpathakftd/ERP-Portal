pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
}

environment {

    // GitLab Repo
    GIT_URL = "https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git"
    GIT_BRANCH = "main"

    // DockerHub Image
    DOCKER_IMAGE = "shivsoftapp/monitering-django"
    IMAGE_TAG = "03"

    // Jenkins Credentials
    DOCKER_CREDS = "dockerhub-creds"

    // SonarQube running in Docker Desktop
    SONAR_HOST = "http://localhost:9000"

}

stages {

    stage('Clean Workspace') {
        steps {
            cleanWs()
        }
    }

    stage('Clone GitLab Repository') {
        steps {
            git branch: "${GIT_BRANCH}",
                url: "${GIT_URL}"
        }
    }

    stage('Verify Docker') {
        steps {
            bat 'docker version'
        }
    }

    stage('SonarQube Scan') {
        steps {
            bat """
            sonar-scanner ^
            -Dsonar.projectKey=monitoring-django ^
            -Dsonar.sources=. ^
            -Dsonar.host.url=%SONAR_HOST%
            """
        }
    }

    stage('Build Docker Image') {
        steps {
            bat """
            docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% .
            """
        }
    }

    stage('Docker Login') {
        steps {
            withCredentials([usernamePassword(
                credentialsId: "dockerhub-creds",
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {

                bat """
                docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                """
            }
        }
    }

    stage('Push Docker Image') {
        steps {
            bat """
            docker push %DOCKER_IMAGE%:%IMAGE_TAG%
            """
        }
    }

    stage('Deploy to Kubernetes (Docker Desktop)') {
        steps {
            bat """
            kubectl apply -f k8s

            kubectl rollout restart deployment

            kubectl get pods
            """
        }
    }

    stage('Deploy Prometheus (if exists)') {
        steps {
            script {
                if (fileExists('monitoring/prometheus')) {

                    bat """
                    kubectl apply -f monitoring/prometheus
                    """

                } else {
                    echo "Prometheus already running in Docker Desktop"
                }
            }
        }
    }

    stage('Deploy Grafana (if exists)') {
        steps {
            script {
                if (fileExists('monitoring/grafana')) {

                    bat """
                    kubectl apply -f monitoring/grafana
                    """

                } else {
                    echo "Grafana already running in Docker Desktop"
                }
            }
        }
    }

    stage('Verify Deployment') {
        steps {
            bat """
            kubectl get pods -A
            kubectl get svc -A
            """
        }
    }

}

post {

    success {

        echo "SUCCESS: Application deployed successfully"

    }

    failure {

        echo "ERROR: Pipeline failed"

    }

    always {

        cleanWs()

    }

}

}
