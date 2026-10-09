
pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        AWS_REGION = 'us-east-1'
        AWS_ACCOUNT_ID = '315553918200'
        ECR_REGISTRY = '315553918200.dkr.ecr.us-east-1.amazonaws.com'
        ECS_CLUSTER = 'techpathway-cluster'
        FRONTEND_SERVICE = 'techpathway-frontend-service'
        BACKEND_SERVICE = 'techpathway-backend-service'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify AWS Access') {
            steps {
                sh '''
                    set -eu
                    aws sts get-caller-identity
                '''
            }
        }

        stage('Build Docker Images') {
            steps {
                sh '''
                    set -eu
                    docker build --platform linux/amd64 \
                      -t ${ECR_REGISTRY}/techpathway-frontend:${BUILD_NUMBER} \
                      -t ${ECR_REGISTRY}/techpathway-frontend:latest ./frontend

                    docker build --platform linux/amd64 \
                      -t ${ECR_REGISTRY}/techpathway-backend:${BUILD_NUMBER} \
                      -t ${ECR_REGISTRY}/techpathway-backend:latest ./backend
                '''
            }
        }

        stage('Push Images to ECR') {
            steps {
                sh '''
                    set -eu
                    aws ecr get-login-password --region ${AWS_REGION} |
                      docker login --username AWS --password-stdin ${ECR_REGISTRY}

                    docker push ${ECR_REGISTRY}/techpathway-frontend:${BUILD_NUMBER}
                    docker push ${ECR_REGISTRY}/techpathway-frontend:latest
                    docker push ${ECR_REGISTRY}/techpathway-backend:${BUILD_NUMBER}
                    docker push ${ECR_REGISTRY}/techpathway-backend:latest
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                    set -eu

                    aws ecs update-service \
                      --region ${AWS_REGION} \
                      --cluster ${ECS_CLUSTER} \
                      --service ${FRONTEND_SERVICE} \
                      --force-new-deployment

                    aws ecs update-service \
                      --region ${AWS_REGION} \
                      --cluster ${ECS_CLUSTER} \
                      --service ${BACKEND_SERVICE} \
                      --force-new-deployment

                    aws ecs wait services-stable \
                      --region ${AWS_REGION} \
                      --cluster ${ECS_CLUSTER} \
                      --services ${FRONTEND_SERVICE} ${BACKEND_SERVICE}
                '''
            }
        }
    }

    post {
        success {
            echo 'SUCCESS: Frontend and backend images deployed to ECS.'
        }
        failure {
            echo 'FAILED: Check the stage logs above to identify the issue.'
        }
    }
}
