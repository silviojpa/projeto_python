pipeline {
    agent any

    environment {
        // Define a imagem com a sua tag padrão
        IMAGE_NAME = "silvio69luiz/flask-devops"
    }

    tools {
        // Declara a ferramenta do SonarScanner configurada no seu Jenkins
        "hudson.plugins.sonar.SonarRunnerInstallation" 'sonar-scanner'
    }

    stages {
        stage('Pull Code') {
            steps {
                // Baixa o código atualizado do seu repositório Git
                git branch: 'main', url: 'https://github.com/silviojpa/projeto_python.git'
            }
        }

        stage('OWASP Dependency Check') {
            steps {
                // Executa a análise de dependências vulneráveis do OWASP
                dependencyCheck odcInstallation: 'owasp', additionalArguments: '--scan ./ --noupdate'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    // Busca o caminho do executável do SonarScanner e injeta o servidor
                    def scannerHome = tool name: 'sonar-scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                    withSonarQubeEnv('sonar-server') {
                        sh "${scannerHome}/bin/sonar-scanner \
                          -Dsonar.projectKey=flask-app \
                          -Dsonar.sources=."
                    }
                }
            }
        }

        stage('Docker Build') {
            steps {
                // Constrói a imagem Docker localmente com a tag v1
                sh 'docker build -t $IMAGE_NAME:v1 .'
            }
        }

        stage('Trivy Scan') {
            steps {
                // Apenas exibe o relatório completo no console log
                sh 'trivy image --severity LOW,MEDIUM,HIGH,CRITICAL $IMAGE_NAME:v1'
                
                // Bloqueia o pipeline se encontrar vulnerabilidades HIGH ou CRITICAL corrigíveis
                // sh 'trivy image --exit-code 1 --severity HIGH,CRITICAL --ignore-unfixed $IMAGE_NAME:v1'
            }
        }

        stage('Docker Push') {
            steps {
                // Realiza o login e push da imagem v1 para o Docker Hub público
                // IMPORTANTE: Altere 'docker-hub-credentials-id' pelo ID da sua credencial no Jenkins
                withDockerRegistry([url: 'https://index.docker.io/v1/', credentialsId: 'dockerhub-credentials']) {
                    sh 'docker push $IMAGE_NAME:v1'
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                script {
                    echo "Aplicando manifestos no Cluster Minikube..."
                    // Aplica as configurações de Deployment e de Service (SVC) dentro da pasta k8s
                    sh 'kubectl apply -f k8s/deployment.yaml'
                    sh 'kubectl apply -f k8s/service.yaml'
                    
                    echo "Forçando os Pods a reiniciarem para garantir o carregamento da imagem v1 atualizada"
                    sh 'kubectl rollout restart deployment/flask-api-deployment'
                }
            }
        }
    }

    post {
        always {
            script {
                // Limpa caches e imagens órfãs locais para evitar encher o disco do Jenkins/WSL
                echo "Limpando imagens antigas e caches locais..."
                sh 'docker image prune -f'
            }
        }
    }
}