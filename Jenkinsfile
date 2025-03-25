pipeline {
    agent any
    environment {
        DOCKER_CREDENTIALS_ID = 'docker-container-hub-cred'
        FRONTEND_IMAGE = 'tejaroyal/frontend-app'
        BACKEND_IMAGE = 'tejaroyal/backend-app'
    }
    stages {
        stage('Initial Slack Test') {
            steps {
                slackSend(channel: '#jenkins-integration', color: 'good', message: 'Pipeline started! :rocket:')
            }
        }
        stage('Checkout Code') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: '3f601ce9-7463-4bde-bf20-ca21df940366', url: 'https://github.com/teja94411/Docker-Full-Stack-Project.git']])
            }
        }

        stage('Login to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: DOCKER_CREDENTIALS_ID, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        if (isUnix()) {
                            sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                        } else {
                            bat '''
                                echo %DOCKER_PASS% > pass.txt
                                docker login -u %DOCKER_USER% --password-stdin < pass.txt
                                del pass.txt
                            '''
                        }
                    }

                    
                    if (isUnix()) {
                        sh 'docker stack rm compose || true'
                    } else {
                        bat 'docker stack rm compose || exit 0'
                    }
                }
            }
        }

        stage('Build & Push Docker Images') {
            steps {
                script {
                    if (isUnix()) {
                        sh "docker build -t $FRONTEND_IMAGE -f Dockerfile ."
                        sh "docker build -t $BACKEND_IMAGE -f Dockerfile ."
                        sh "docker push $FRONTEND_IMAGE"
                        sh "docker push $BACKEND_IMAGE"
                    } else {
                        bat "docker build -t %FRONTEND_IMAGE% -f Dockerfile ."
                        bat "docker build -t %BACKEND_IMAGE% -f Dockerfile ."
                        bat "docker push %FRONTEND_IMAGE%"
                        bat "docker push %BACKEND_IMAGE%"
                    }
                }
            }
        }

        stage('Deploy Using Docker Swarm') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            echo "Leaving existing Swarm if present..."
                            docker swarm leave --force || true
                            echo "Initializing Docker Swarm..."
                            docker swarm init || true

                            echo "Deploying stack with frontend & backend services..."
                            docker stack deploy -c docker-compose.yml compose
                        '''
                    } else {
                        bat '''
                            echo Leaving existing Swarm if present...
                            docker swarm leave --force || exit 0
                            echo Initializing Docker Swarm...
                            docker swarm init || exit 0

                            echo Deploying stack with frontend & backend services...
                            docker stack deploy -c docker-compose.yml compose
                        '''
                    }
                }
            }
        }

        stage('Wait for All Replicas to be Ready') {
    steps {
        script {
            def maxRetries = 15
            def retryCount = 0
            def allReady = false

            while (retryCount < maxRetries) {
                echo "Checking Docker stack services..."
                def services = bat(script: 'docker service ls', returnStdout: true).trim()

                def notReady = false
                services.split('\n').each { line ->
                    def parts = line.trim().split(/\s+/)
                    if (parts.size() >= 4) {
                        def serviceName = parts[1]
                        def replicas = parts[3]  // Example: "0/2" or "2/2"

                        if (replicas.contains("/")) {
                            def counts = replicas.split("/")
                            def running = counts[0] as Integer
                            def expected = counts[1] as Integer

                            if (running < expected) {
                                notReady = true
                                echo "[WAIT] Service ${serviceName} is not ready. Running: ${running}/${expected}"
                            }
                        }
                    }
                }

                if (!notReady) {
                    allReady = true
                    break
                }

                echo "Retrying in 10 seconds... (${retryCount + 1}/${maxRetries})"
                retryCount++
                sleep(10)
            }

            if (!allReady) {
                error "[ERROR] Max retries reached. Not all replicas are ready!"
            }

            echo "All replicas are ready!"
        }
    }
}

        stage('Final Deployment Verification') {
            steps {
                script {
                    if (isUnix()) {
                        sh '''
                            docker stack services compose
                            docker stack ps compose
                        '''
                    } else {
                        bat '''
                            docker stack services compose
                            docker stack ps compose
                        '''
                    }
                }
            }
        }
    }       
 }
 post {
        success {
            slackSend(channel: '#jenkins-integration', color: 'good', message: 'Build succeeded! :tada: All tests passed and everything is good to go! 🎉')
        }
        failure {
            slackSend(channel: '#jenkins-integration', color: 'danger', message: 'Build failed! :x: Something went wrong. Please check the logs for more details. 🔧')
        }
        unstable {
            slackSend(channel: '#jenkins-integration', color: 'warning', message: 'Build is unstable! :warning: Some tests did not pass. Please review and address the issues. ⚠️')
        }
    }
}
