pipeline {

agent any

options {
    timestamps()
    disableConcurrentBuilds()
}

environment {

    // DockerHub
    DOCKER_IMAGE = "shivsoftapp/monitering-django"
    IMAGE_TAG = "03"

    // SonarQube
    SONAR_HOST_URL = "http://localhost:9000"

}

stages {

    stage('Initialize Variables') {
        steps {
            script {

                // Define Git variables here
                env.GIT_REPO_URL = "https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git"

                env.GIT_REPO_BRANCH = "main"

                echo "Repository URL: ${env.GIT_REPO_URL}"
                echo "Branch: ${env.GIT_REPO_BRANCH}"
            }
        }
    }

    stage('Clean Workspace') {
        steps {
            cleanWs()
        }
    }

    stage('Checkout Source Code') {
        steps {

            git branch: "${env.GIT_REPO_BRANCH}",
                url: "${env.GIT_REPO_URL}"

        }
    }

    stage('Verify Tools') {
        steps {
            bat '''
            git --version
            docker version
            kubectl version --client
            sonar-scanner.bat -v
            '''
        }
    }

    stage('SonarQube Analysis') {
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

    stage('Deploy to Kubernetes') {
        steps {

            bat '''
            kubectl apply -f k8s
            kubectl rollout restart deployment
            kubectl get pods
            '''

        }
    }

    stage('Deploy Prometheus') {
        steps {
            script {

                if (fileExists('monitoring/prometheus')) {

                    bat 'kubectl apply -f monitoring/prometheus'

                } else {

                    echo "Prometheus already running"

                }

            }
        }
    }

    stage('Deploy Grafana') {
        steps {
            script {

                if (fileExists('monitoring/grafana')) {

                    bat 'kubectl apply -f monitoring/grafana'

                } else {

                    echo "Grafana already running"

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

        echo "PIPELINE SUCCESSFULLY COMPLETED"

    }

    failure {

        echo "PIPELINE FAILED"

    }

    always {

        cleanWs()

    }

}


}
