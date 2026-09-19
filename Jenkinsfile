pipeline {
    agent any

    environment {
        PATH = "/Users/chhairin/development/flutter/bin:/Users/chhairin/development/flutter/bin/cache/dart-sdk/bin:/Users/chhairin/.nvm/versions/node/v24.14.1/bin:/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Flutter Version') {
            steps {
                sh '''
                    echo "===== Flutter ====="
                    which flutter
                    flutter --version

                    echo "===== Dart ====="
                    which dart
                    dart --version
                '''
            }
        }
        stage('Setup Environment') {
            steps {
                withCredentials([
                    file(credentialsId: 'eshop-env', variable: 'ENV_FILE')
                ]) {
                    sh '''
                        echo "===== Setup Environment ====="

                        test -f "$ENV_FILE"
                        echo "Jenkins credential file exists"

                        cp "$ENV_FILE" .env

                        test -f .env
                        echo "Workspace .env exists"
                        ls -la .env
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    flutter pub get
                '''
            }
        }

        stage('Analyze') {
            steps {
                sh '''
                    flutter analyze
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    flutter test
                '''
            }
        }

        stage('Build APK') {
            steps {
                sh '''
                    flutter build apk --release
                '''
            }
        }

        stage('Archive APK') {
            steps {
                archiveArtifacts artifacts: 'build/app/outputs/flutter-apk/app-release.apk',
                                  fingerprint: true
            }
        }
    }

    post {
        success {
            echo '🎉 Flutter CI passed successfully!'
            echo '📦 Release APK archived successfully!'
        }

        failure {
            echo '❌ Flutter CI failed!'
        }

        always {
            sh 'rm -f .env'
            echo '===== Jenkins Flutter CI Finished ====='
        }
    }
}