pipeline {
    agent any

    environment {
        APP_NAME = 'qlphongtro'
        DOCKER_IMAGE = 'qlphongtro:1.0'
        CONTAINER_NAME = 'qlphongtro-app'
        APP_PORT = '8082'
        JAVA_HOME = 'C:\\Program Files\\Java\\jdk-21.0.12.1'
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                echo 'Checking out QLPhongTro source code...'
                checkout scm
            }
        }

        stage('Check Environment') {
            steps {
                withEnv(["PATH+JAVA=${env.JAVA_HOME}\\bin"]) {
                    bat 'java -version'
                    bat 'docker --version'
                }
            }
        }

        stage('Build Spring Boot Application') {
            steps {
                withEnv(["PATH+JAVA=${env.JAVA_HOME}\\bin"]) {
                    bat 'call mvnw.cmd clean package -DskipTests'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t %DOCKER_IMAGE% .'
            }
        }

        stage('Deploy Application') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'qlphongtro-db',
                        usernameVariable: 'DB_USERNAME',
                        passwordVariable: 'DB_PASSWORD'
                    )
                ]) {
                    bat '''
                        powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = docker ps -aq --filter 'name=^/qlphongtro-app$'; if ($c) { docker rm -f qlphongtro-app; if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE } }"

                        docker run -d --name qlphongtro-app -p 8082:8080 -e SPRING_PROFILES_ACTIVE=docker -e DB_USERNAME -e DB_PASSWORD qlphongtro:1.0
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                bat '''
                    powershell -NoProfile -ExecutionPolicy Bypass -Command "$success = $false; for ($i = 0; $i -lt 30; $i++) { try { $r = Invoke-WebRequest -Uri 'http://localhost:8082' -UseBasicParsing -TimeoutSec 3; if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { $success = $true; break } } catch { Start-Sleep -Seconds 2 } }; if (-not $success) { docker logs qlphongtro-app; exit 1 }"
                '''
                echo 'QLPhongTro has been deployed successfully!'
            }
        }
    }

    post {
        success {
            echo 'CI/CD Pipeline completed successfully!'
            echo 'Application URL: http://localhost:8082'
        }

        failure {
            echo 'CI/CD Pipeline failed. Please check the build logs.'
        }
    }
}