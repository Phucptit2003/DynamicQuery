pipeline {
    agent any

    environment {
        COMPOSE_PROJECT_NAME = 'dynamic-query'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo 'Đang lấy mã nguồn mới nhất từ Repository...'
                checkout scm
            }
        }

        stage('2. Check Docker') {
            steps {
                echo 'Kiểm tra Docker...'
                sh 'docker --version'
                sh 'docker-compose --version'
            }
        }

        stage('3. Build Docker Image') {
            steps {
                echo 'Đang build Docker image...'
                sh 'docker-compose build app'
            }
        }

        stage('4. Deploy App') {
            steps {
                echo 'Đang deploy ứng dụng...'
                sh 'docker-compose up -d --force-recreate app'
            }
        }

        stage('5. Clean Up') {
            steps {
                echo 'Dọn dẹp Docker...'
                sh 'docker image prune -f'
            }
        }
    }

    post {
        success {
            echo '✅ Deploy thành công: http://localhost:8080'
        }
        failure {
            echo '❌ Pipeline thất bại. Kiểm tra log!'
        }
        always {
            echo 'Hoàn tất CI/CD.'
        }
    }
}
