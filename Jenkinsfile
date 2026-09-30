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

        // ==========================================
        // Firebase Android Configuration
        // ==========================================
        stage('Setup Firebase') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'firebase-google-services-base64',
                        variable: 'GOOGLE_SERVICES_JSON_BASE64'
                    )
                ]) {
                    sh '''
                        set -e

                        echo "===== Setup Firebase Android ====="

                        mkdir -p android/app

                        echo "Creating google-services.json..."

                        printf '%s' "$GOOGLE_SERVICES_JSON_BASE64" \
                            | base64 --decode \
                            > android/app/google-services.json

                        if [ ! -s android/app/google-services.json ]; then
                            echo "❌ google-services.json missing or empty"
                            exit 1
                        fi

                        echo "✅ google-services.json created successfully"

                        ls -lh android/app/google-services.json

                        echo "Checking JSON..."
                        python3 -m json.tool android/app/google-services.json > /dev/null

                        echo "✅ google-services.json is valid JSON"
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "===== Install Dependencies ====="
                    flutter pub get
                '''
            }
        }

        stage('Analyze') {
            steps {
                sh '''
                    echo "===== Flutter Analyze ====="
                    flutter analyze --no-fatal-infos --no-fatal-warnings
                '''
            }
        }

        stage('Test') {
            steps {
                sh '''
                    echo "===== Flutter Test ====="
                    flutter test
                '''
            }
        }

        stage('Build APK') {
            steps {
                sh '''
                    set -e

                    echo "===== Build APK ====="

                    echo "Checking required files..."

                    if [ ! -f .env ]; then
                        echo "❌ .env missing"
                        exit 1
                    fi

                    if [ ! -f android/app/google-services.json ]; then
                        echo "❌ google-services.json missing"
                        exit 1
                    fi

                    echo "✅ .env found"
                    echo "✅ google-services.json found"

                    flutter build apk --release
                '''
            }
        }

        stage('Archive APK') {
            steps {
                echo "===== Archive APK ====="

                archiveArtifacts(
                    artifacts: 'build/app/outputs/flutter-apk/app-release.apk',
                    fingerprint: true
                )
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
            sh '''
                echo "===== Cleaning CI secrets ====="

                rm -f .env
                rm -f android/app/google-services.json

                echo "✅ CI secrets cleaned"
            '''

            echo '===== Jenkins Flutter CI Finished ====='
        }
    }
}