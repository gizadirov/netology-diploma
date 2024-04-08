pipeline {
    agent {
        kubernetes {
            yaml '''
        apiVersion: v1
        kind: Pod
        spec:
          containers:
          - name: dind
            image: docker:latest
            securityContext:
              privileged: true
            volumeMounts:
              - name: dind-storage
                mountPath: /var/lib/docker
          - name: k8s-tools
            image: tabwizard/k8s-tools:latest
            tty: true
          volumes:
            - name: dind-storage
              emptyDir: {}
                '''
        }
    }
    environment {
        REGISTRY = 'cr.yandex/crp0c81tkbq1dub8dc8c/'
        IMAGE_NAME = 'app'
        LABEL = 'latest'
        BRANCH_NAME = 'main'
    }
    stages {
        stage('Checkout from github repo') {
            steps {
                git branch: env.BRANCH_NAME, url: 'https://github.com/gizadirov/netology-diploma-app'
                script {
                    env.LABEL = env.BRANCH_NAME.startsWith('v') ? env.BRANCH_NAME : env.LABEL
                }
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                container('dind') {
                    script {
                        // Сборка Docker-образа
                        docker.build("${env.REGISTRY}${env.IMAGE_NAME}:${env.LABEL}")

                        // Пушим Docker-образ в Docker Registry
                        docker.withRegistry("https://${env.REGISTRY}", 'cr_yandex') {
                            // Пушим образ с тегом "latest"
                            docker.image("${env.REGISTRY}${env.IMAGE_NAME}:${env.LABEL}").push(env.LABEL)
                        }
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            when {
                 expression { env.BRANCH_NAME.startsWith('v') }
            }
            steps {
                git branch: 'main', url: 'https://github.com/gizadirov/netology-diploma'
                container('k8s-tools') {
                    withCredentials([file(credentialsId: 'kube_cred', variable: 'KUBECONFIG')]) {
                        sh 'mkdir .kube'
                        sh "echo $KUBECONFIG > .kube/config"
                        sh 'qbec apply default --vm:ext-str imageTag=latest --root k8s/deploy/app --yes'
                    }
                }
            }
        }
    }
}
