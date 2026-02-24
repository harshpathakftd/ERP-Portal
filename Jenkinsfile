pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
}

environment {

    // GitLab Repository
    GIT_URL = "https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git"
    GIT_BRANCH = "main"

    // DockerHub Image
    DOCKER_IMAGE = "shivsoftapp/monitering-django"
    IMAGE_TAG = "03"

    // SonarQube URL (Docker Desktop container)
    SONAR_HOST_URL = "http://localhost:9000"

}

stages {

    stage('Clean Workspace') {
        steps {
            cleanWs()
        }
    }

    stage('Checkout Code') {
        steps {
            git branch: "%GIT_BRANCH%",
                url: "%GIT_URL%"
        }
    }

    stage('Verify Tools') {
        steps {
            bat '''
            echo Checking Docker...
            docker version

            echo Checking kubectl...
            kubectl version --client

            echo Checking sonar-scanner...
            sonar-scanner.bat -v
            '''
        }
    }

    stage('SonarQube Code Analysis') {
        steps {
            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                bat '''
                sonar-scanner.bat ^
                -Dsonar.projectKey=monitoring-django ^
                -Dsonar.sources=. ^
                -Dsonar.host.url=%SONAR_HOST_URL% ^
                -Dsonar.login=%SONAR_TOKEN%
                '''

            }
        }
    }

    stage('Build Docker Image') {
        steps {
            bat '''
            docker build -t %DOCKER_IMAGE%:%IMAGE_TAG% .
            '''
        }
    }

    stage('Docker Login') {
        steps {
            withCredentials([usernamePassword(
                credentialsId: 'dockerhub-creds',
                usernameVariable: 'DOCKER_USER',
                passwordVariable: 'DOCKER_PASS'
            )]) {

                bat '''
                docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                '''
            }
        }
    }

    stage('Push Docker Image') {
        steps {
            bat '''
            docker push %DOCKER_IMAGE%:%IMAGE_TAG%
            '''
        }
    }

    stage('Deploy Application to Kubernetes') {
        steps {
            bat '''
            kubectl apply -f k8s

            kubectl rollout restart deployment

            kubectl get pods
            '''
        }
    }

    stage('Deploy Prometheus Monitoring') {
        steps {
            script {

                if (fileExists('monitoring/prometheus')) {

                    bat '''
                    kubectl apply -f monitoring/prometheus
                    '''

                } else {

                    echo "Prometheus already running via Docker Desktop"

                }

            }
        }
    }

    stage('Deploy Grafana Monitoring') {
        steps {
            script {

                if (fileExists('monitoring/grafana')) {

                    bat '''
                    kubectl apply -f monitoring/grafana
                    '''

                } else {

                    echo "Grafana already running via Docker Desktop"

                }

            }
        }
    }

    stage('Verify Deployment') {
        steps {
            bat '''
            kubectl get pods -A
            kubectl get svc -A
            '''
        }
    }

}

post {

    success {

        echo "SUCCESS: CI/CD Pipeline completed successfully"

    }

    failure {

        echo "ERROR: Pipeline failed"

    }

    always {

        cleanWs()

    }

}

}
