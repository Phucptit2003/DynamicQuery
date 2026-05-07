pipeline {
    // Chạy trên bất kỳ Agent (Node) nào có sẵn của Jenkins
    agent any

    environment {
        // Khai báo các biến môi trường nếu cần
        COMPOSE_PROJECT_NAME = 'dynamic-query'
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo 'Đang lấy mã nguồn mới nhất từ Repository...'
                // Jenkins tự động checkout code từ Git (nếu bạn cấu hình Pipeline from SCM)
                checkout scm
            }
        }

        stage('2. Build Maven & Docker Image') {
            steps {
                echo 'Đang biên dịch code và đóng gói Docker Image...'
                // Lệnh này sẽ gọi Dockerfile. Dockerfile sẽ tự động chạy 'mvn clean package'
                // và build ra image cuối cùng
                sh 'docker-compose build app'
            }
        }

        stage('3. Deploy App (Docker Compose)') {
            steps {
                echo 'Đang triển khai ứng dụng...'
                // Tắt container app cũ và khởi động bản mới, giữ nguyên Oracle Database
                sh 'docker-compose up -d --force-recreate app'
            }
        }

        stage('4. Clean Up') {
            steps {
                echo 'Dọn dẹp các Docker image rác (dangling) để giải phóng ổ cứng...'
                sh 'docker image prune -f'
            }
        }
    }

    post {
        // Các hành động sau khi pipeline chạy xong
        success {
            echo '✅ Triển khai thành công! Ứng dụng đã sẵn sàng tại http://localhost:8080'
        }
        failure {
            echo '❌ Pipeline thất bại. Vui lòng kiểm tra lại log của Jenkins.'
        }
        always {
            echo 'Hoàn tất luồng CI/CD.'
        }
    }
}
