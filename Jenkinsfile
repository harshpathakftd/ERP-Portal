pipeline {

agent any

environment {

    DOCKER_IMAGE = "shivsoftapp/devops-sonarqube-image"
    DOCKER_TAG   = "33"

    // CRITICAL FIX for Windows Jenkins Docker networking
    SONAR_HOST   = "http://172.17.0.1:9000"

}

stages {

    stage('Clean Workspace') {
        steps {
            deleteDir()
        }
    }

    stage('Clone GitLab Repository') {
        steps {

            echo "Cloning GitLab Repository..."

            git branch: 'main',
            url: 'https://gitlab.com/SOFTAPP-TECHNOLOGIES/complete-industry-level-devops-ci-cd-pipeline-with-sonarqube.git'

        }
    }

    stage('Verify Workspace Files') {
        steps {

            bat '''
            echo ===================================
            echo VERIFYING WORKSPACE FILES
            echo ===================================
            dir
            '''

        }
    }

    stage('Create SonarQube Cache Volumes') {
        steps {

            bat '''
            docker volume inspect sonar-cache >nul 2>&1 || docker volume create sonar-cache
            docker volume inspect sonar-engine-cache >nul 2>&1 || docker volume create sonar-engine-cache
            '''

        }
    }

    stage('SonarQube Scan') {
        steps {

            echo "Running SonarQube Analysis..."

            withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {

                bat """
                docker run --rm ^
                --network bridge ^
                -e SONAR_SCANNER_OPTS="-Dsonar.scanner.socketTimeout=600 -Dsonar.scanner.connectTimeout=600" ^
                -v %cd%:/usr/src ^
                -v sonar-cache:/opt/sonar-scanner/.sonar ^
                -v sonar-engine-cache:/opt/sonar-scanner/.cache ^
                sonarsource/sonar-scanner-cli ^
                -Dsonar.host.url=%SONAR_HOST% ^
                -Dsonar.login=%SONAR_TOKEN%
                """

            }

        }
    }

    stage('Build Docker Image') {
        steps {

            echo "Building Docker Image..."

            bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% app"

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

            echo "Pushing Docker Image..."

            bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"

        }
    }

    stage('Terraform Init & Apply') {
        steps {

            echo "Deploying Infrastructure using Terraform..."

            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {

                bat """
                set KUBECONFIG=%KUBECONFIG_FILE%

                cd terraform

                terraform init

                terraform apply -auto-approve
                """

            }

        }
    }

    stage('Verify Kubernetes Deployment') {
        steps {

            echo "Verifying Kubernetes Resources..."

            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG_FILE')]) {

                bat """
                set KUBECONFIG=%KUBECONFIG_FILE%

                kubectl get namespaces

                kubectl get deployments -n devops-sonarqube

                kubectl get pods -n devops-sonarqube

                kubectl get svc -n devops-sonarqube
                """

            }

        }
    }

    stage('Monitoring Verification') {
        steps {

            bat '''
            echo ===================================
            echo VERIFYING SONARQUBE
            echo ===================================
            docker ps | findstr sonarqube || exit 1

            echo ===================================
            echo VERIFYING PROMETHEUS
            echo ===================================
            docker ps | findstr prometheus || exit 1

            echo ===================================
            echo VERIFYING GRAFANA
            echo ===================================
            docker ps | findstr grafana || exit 1

            echo ===================================
            echo MONITORING STACK VERIFIED
            echo ===================================
            '''

        }
    }

}

post {

    success {

        echo "==================================="
        echo "PIPELINE EXECUTED SUCCESSFULLY"
        echo "==================================="

        echo "SonarQube URL: http://localhost:9000"
        echo "Kubernetes App URL: http://localhost:30007"

    }

    failure {

        echo "==================================="
        echo "PIPELINE FAILED"
        echo "Check Jenkins Console Logs"
        echo "==================================="

    }

}

}
