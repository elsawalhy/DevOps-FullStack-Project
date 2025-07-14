pipeline {
    agent any

    stages{
        stage('Docker Login ') {
            steps{
                withCredentials([usernamePassword(credentialsId:'dockerhub',usernameVariable: 'DOCKER_USER',passwordVariable: 'DOCKER_PASS')]){
                sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin '
                }
            }
        }

        stage ('Docker Build & Push') {

            steps{
               sh """
                 cd Python
                 docker rmi abdo133/python_app || true 
                 docker build -t abdo133/python_app .
                 docker push abdo133/python_app
               """
            }
        }
        stage ('Create EKS Cluster On AWS') {
           steps{

               withCredentials([[
                                   
                 $class: 'AmazonWebServicesCredentialsBinding',
                 credentialsId: "aws-credentials",
                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'

               ]]){
               sh 'eksctl create cluster --name pyton-app-cluster --region us-east-2 --nodes-min=2'
               sh 'aws eks update-kubeconfig --name pyton-app-cluster --region us-east-2 '
               }
           }
        }

        stage ('Craete NameSpace For App'){
            steps{
                
              withCredentials([[
                                   
                 $class: 'AmazonWebServicesCredentialsBinding',
                 credentialsId: "aws-credentials",
                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'

              ]]){
              sh 'kubectl get namespace python-app || kubectl create namespace python-app'
              }
            }
        }

        stage ('Deployment'){

            steps{
                
              withCredentials([[
                                   
                 $class: 'AmazonWebServicesCredentialsBinding',
                 credentialsId: "aws-credentials",
                 accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                 secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'

              ]]){
              sh """
              cd kubernetes 
              kubectl -n python-app apply -f deployment.yml
              kubectl -n python-app apply -f service.yml 
              kubectl -n python-app get svc 
              kubectl -n python-app get nodes -o wide 
              """
              }
            }
        }
    }
}