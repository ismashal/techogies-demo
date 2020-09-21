### Techogies assigement 

### Infra desgin 

![Alt text](infra_flow.png?raw=true "Infra-flow")


1. Create the infra using terrafrom on AWS 
2. Configure AWS Cli and profile on local 
3. Run `terrafrom plan` command from local 

Note : It will create the following resoucres 

1. VPC - private/public subnets, RouteTables, IG,NAT gateway
2. Jenkins Server for deployment with configuration 
3. EKS cluster with ECR Repo


### Deployment CI/CD Flow 

![Alt text](ci_cd_flow.png?raw=true "Infra-flow")

1. Create jenkins job as pipeline type and provide the application github url with credinatioal
2. Execute the job 


### About

Shrishail Mashal ( shrimashal@gmail.com )
