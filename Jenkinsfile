pipeline {
    agent any
    triggers {
        pollSCM '* * * * *'
    }
    parameters {
        string(name: 'CommitID', defaultValue: 'default', description: 'Short Commit ID of last successful deployment (Staging, Production)')
        choice(name: 'BuildENV', choices: ['dev', 'stage', 'prod'], description: 'Select the environment to deploy')
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: "10"))
        timeout(time: 30, unit: 'MINUTES')
    }
    environment {
        AWS_REGION = "eu-west-1"
        TIER = "${params.BuildENV}"
        NAMESPACE = "devops-ns"
        COMMIT_ID = "${env.TIER == "dev" ? sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim() : params.CommitID}"
        
        DEV_ECR_CRED = "ecr:eu-west-1:dev-ecr"
        STAGE_ECR_CRED = "ecr:eu-west-1:prod-ecr"
        PROD_ECR_CRED = "ecr:eu-west-1:new-prod-ecr"

        PROJECT_NAME = "devops-demo"

        DEV_ECR_URI = "ACCOUNT_NO.dkr.ecr.eu-west-1.amazonaws.com/${env.PROJECT_NAME}"
        STAGE_ECR_URI = "ACCOUNT_NO.dkr.ecr.eu-west-1.amazonaws.com/${env.PROJECT_NAME}"
        PROD_ECR_URI = "ACCOUNT_NO.dkr.ecr.eu-west-1.amazonaws.com/${env.PROJECT_NAME}"
        
    }
    stages {
        stage('Build Docker Image') {
            when {
                expression {
                    return(params.BuildENV == "dev" && (env.BRANCH_NAME == "${env.DEV_BUILD_BRANCH}" || env.BRANCH_NAME == "${env.BUILD_BRANCH}"))
                }
            }
            environment {
                IMAGE_NAME = "${env.DEV_ECR_URI}" + ":" + "${env.COMMIT_ID}"
            }
            steps {
                script {
                    app = docker.build(IMAGE_NAME)
                }
            }
        } 
        stage('Uploading to Dev ECR') {
            when {
                expression {
                    return(params.BuildENV == "dev" && (env.BRANCH_NAME == "${env.DEV_BUILD_BRANCH}" || env.BRANCH_NAME == "${env.BUILD_BRANCH}"))
                }
            }
            steps {
                echo "Uploading to Dev ECR"
                script {
                        docker.withRegistry("https://" + "${env.DEV_ECR_URI}", "${env.DEV_ECR_CRED}") {
                        app.push("${COMMIT_ID}")
                    }
                }
            }
            post {
                always {
                    echo "Removing image locally"
                    sh "docker rmi -f ${env.DEV_ECR_URI}:${env.COMMIT_ID}"
                }
            }
        }
        stage('Deploying to Dev EKS') {
            when {
                expression {
                    return(env.BRANCH_NAME == "${env.DEV_BUILD_BRANCH}" && params.BuildENV == "dev")
                }
            }
            environment {
                IMAGE_NAME = "${env.DEV_ECR_URI}:${env.COMMIT_ID}"
            }
            steps {
                echo "Deploying to Dev EKS"
                kubernetesDeploy(
                    kubeconfigId: "dev_eks_config",
                    configs: "kube.yaml",
                    enableConfigSubstitution: true
                )

                //Waiting for deployment to rollout successfully
                timeout(time: 650, unit: 'SECONDS') {
                    sh "kubectl rollout status --watch -n ${env.NAMESPACE} deployments ${PROJECT_NAME}-${env.COMPONENT}-deployment --kubeconfig ~/.kube/${env.TIER}-config.yaml"
                }
            }
        }
        stage('Uploading to Stage ECR') {
            when {
                expression {
                    return(env.BRANCH_NAME == "${env.BUILD_BRANCH}" && params.BuildENV == "stage")
                }
            }
            steps {
                echo "Uploading to Stage ECR"
                
                script {
                    docker.withRegistry("https://" + "${env.DEV_ECR_URI}", "${env.DEV_ECR_CRED}") {
                        DevImage = docker.image("${env.DEV_ECR_URI}:${env.COMMIT_ID}")
                        sh "docker image pull ${DEVImage.imageName()}"
                        sh "docker image tag ${env.DEV_ECR_URI}:${env.COMMIT_ID} ${env.STAGE_ECR_URI}:${env.COMMIT_ID}"
                    }

                    docker.withRegistry("https://" + "${env.STAGE_ECR_URI}", "${env.STAGE_ECR_CRED}") {
                        stageImage = docker.image("${env.STAGE_ECR_URI}:${env.COMMIT_ID}")
                        stageImage.push("${env.COMMIT_ID}")
                    }
                }
            }
            post {
                always {
                    echo "Removing image locally"
                    sh "docker image rm -f ${env.DEV_ECR_URI}:${env.COMMIT_ID}"
                    sh "docker image rm -f ${env.STAGE_ECR_URI}:${env.COMMIT_ID}"
                }
            }
        }
        stage('Deploying to Stage EKS') {
            when {
                expression {
                    return(env.BRANCH_NAME == "${env.BUILD_BRANCH}" && params.BuildENV == "stage")
                }
            }
            environment {
                IMAGE_NAME = "${env.STAGE_ECR_URI}:${env.COMMIT_ID}"
            }
            steps {
                echo "Deploying to Stage EKS"
                
                kubernetesDeploy(
                    kubeconfigId: "stage_eks_config",
                    configs: "kube.yaml",
                    enableConfigSubstitution: true
                )

                //Waiting for deployment to rollout successfully
                timeout(time: 650, unit: 'SECONDS') {
                    sh "kubectl rollout status --watch -n ${env.NAMESPACE} deployments ${PROJECT_NAME}-${env.COMPONENT}-deployment --kubeconfig ~/.kube/${env.TIER}-config.yaml"
                }
            }
        }
        stage('Uploading to Prod ECR') {
            when {
                expression {
                    return(env.BRANCH_NAME == "${env.BUILD_BRANCH}" && params.BuildENV == "prod" )
                }
            }
            steps {
                echo "Uploading to Prod ECR"
                
                script {
                    docker.withRegistry("https://" + "${env.STAGE_ECR_URI}", "${env.STAGE_ECR_CRED}") {
                        stageImage = docker.image("${env.STAGE_ECR_URI}:${env.COMMIT_ID}")
                        sh "docker image pull ${stageImage.imageName()}"
                        sh "docker image tag ${env.STAGE_ECR_URI}:${env.COMMIT_ID} ${env.PROD_ECR_URI}:${env.COMMIT_ID}"
                    }

                    docker.withRegistry("https://" + "${env.PROD_ECR_URI}", "${env.PROD_ECR_CRED}") {
                        prodImage = docker.image("${env.PROD_ECR_URI}:${env.COMMIT_ID}")
                        prodImage.push("${env.COMMIT_ID}")
                    }
                }
            }
            post {
                always {
                    echo "Removing image locally"
                    sh "docker image rm -f ${env.STAGE_ECR_URI}:${env.COMMIT_ID}"
                    sh "docker image rm -f ${env.PROD_ECR_URI}:${env.COMMIT_ID}"
                }
            }
        }
        stage('Deploying to Prod EKS') {
            when {
                expression {
                    return(env.BRANCH_NAME == "${env.BUILD_BRANCH}" && params.BuildENV == "prod" )
                }
            }
            environment {
                IMAGE_NAME = "${env.PROD_ECR_URI}:${env.COMMIT_ID}"
            }
            steps {
                echo "Deploying to Prod EKS"
                kubernetesDeploy(
                    kubeconfigId: "prod_eks_config",
                    configs: "kube.yaml",
                    enableConfigSubstitution: true
                )

                //Waiting for deployment to rollout successfully
                timeout(time: 650, unit: 'SECONDS') {
                    sh "kubectl rollout status --watch -n ${env.NAMESPACE} deployments ${PROJECT_NAME}-${env.COMPONENT}-deployment --kubeconfig ~/.kube/${env.TIER}-config.yaml"
                }
            }
        }
    }
    post {
        always {
            echo "One way or another, I have finished"
            deleteDir()     // clean up our workspace
        }
        
        // trigger when successful
        success {
            echo "I succeeeded!"
       }

        // trigger when failed
        failure {
            echo "I failed :("
        }
        
        // trigger when aborted
        aborted {
            echo "Build aborted!"
       }
    }
}