# TechPathway: Full-Stack Deployment with Jenkins, Docker and AWS

## Project Overview

This project deploys a React frontend and an Express backend to Amazon ECS using Docker, Amazon ECR, Terraform and Jenkins.

The Jenkins pipeline checks out the GitHub repository, verifies AWS access, builds both Docker images, pushes the images to Amazon ECR, and triggers ECS service deployments automatically.

## Live Application

- Frontend: http://techpathway-alb-509339923.us-east-1.elb.amazonaws.com
- Backend health check: http://techpathway-alb-509339923.us-east-1.elb.amazonaws.com/api/health

The frontend displays SUCCESS and a GUID when the application is working. The backend health endpoint should return `{"status":"ok"}`.

## GitHub Repository

https://github.com/laces147/techpathway-tech-challenge-2

## Architecture

1. GitHub hosts the application code, Dockerfiles, Jenkinsfile and Terraform configuration.
2. Jenkins runs on an Amazon EC2 instance and executes the CI/CD pipeline.
3. Docker builds separate frontend and backend images.
4. Amazon ECR stores the container images.
5. Amazon ECS runs the frontend and backend services using AWS Fargate.
6. An Application Load Balancer provides public access to the application and routes requests to the appropriate service.
7. Terraform provisions the application infrastructure, including the VPC, subnets, internet gateway, routes, security groups, ECS cluster, task definitions and services.

## AWS Resources Supporting Jenkins

The Jenkins server runs on an Ubuntu EC2 instance in the `us-east-1` region.

- EC2 instance: `i-0ccbec15512d3ec57`
- Instance type: `t3.small`
- Public Jenkins URL: http://98.80.178.170:8080
- Security group: `techpathway-jenkins-sg`
- IAM role: `techpathway-jenkins-ec2-role`
- IAM instance profile: `techpathway-jenkins-instance-profile`

The Jenkins security group permits HTTP access on port 8080 for the challenge and SSH access on port 22 restricted to an authorized IP address.

The EC2 instance has Docker and the AWS CLI installed. Its IAM instance role provides permissions for Amazon ECR image operations and the required ECS deployment operations. The pipeline uses the instance role rather than storing long-lived AWS access keys in Jenkins.

The Jenkins server is publicly accessible for demonstration purposes. Access should be protected with a strong password, and public access should be restricted or removed when the project no longer needs to be available.

## Container Images and ECS Services

Amazon ECR repositories:

- `techpathway-frontend`
- `techpathway-backend`

ECS cluster: `techpathway-cluster`

ECS services:

- `techpathway-frontend-service`
- `techpathway-backend-service`

The Jenkins pipeline tags images with the Jenkins build number and `latest`, pushes them to ECR, and triggers a new deployment of both ECS services.

## CI/CD Pipeline

The pipeline is defined in `Jenkinsfile` and includes these stages:

1. Checkout the GitHub repository.
2. Verify AWS identity and permissions.
3. Build the frontend and backend Docker images.
4. Authenticate to Amazon ECR and push both images.
5. Trigger deployments for both ECS services and wait for the services to become stable.

To deploy, open the Jenkins job `TechPathway-FullStack-Deploy` and select **Build Now**. Jenkins then performs the pipeline stages without requiring manual image builds or ECS updates.

## Terraform

The Terraform configuration is located in the `infra/` directory.

It defines the AWS networking, internet access, security groups, ECS cluster, task definitions, services and related application infrastructure.

To inspect or deploy the infrastructure, use an AWS CLI profile or other approved AWS authentication method with the necessary permissions:

```bash
cd infra
terraform init
terraform fmt -check
terraform validate
terraform plan
```

Review the plan before applying changes. Run `terraform apply` only when you intend to create or update AWS resources. The Terraform state file is required to manage existing resources and must be kept private; it should not be committed to GitHub.

The Jenkins EC2 instance is managed separately from the application Terraform configuration.

## Testing

### Test the deployed frontend

Open the frontend URL in a browser and confirm that the page displays `SUCCESS` and a GUID.

### Test the backend

```bash
curl http://techpathway-alb-509339923.us-east-1.elb.amazonaws.com/api/health
```

Expected response:

```json
{"status":"ok"}
```

### Test the CI/CD pipeline

1. Open the Jenkins URL and sign in.
2. Open `TechPathway-FullStack-Deploy`.
3. Select **Build Now**.
4. Open the build's Console Output and confirm that it finishes with `SUCCESS`.
5. Verify the frontend and backend health endpoint again.

### Run locally

Backend:

```bash
cd backend
npm ci
npm start
```

Frontend, in a separate terminal:

```bash
cd frontend
npm ci
npm start
```

The backend runs on `localhost:8080` and the frontend on `localhost:3000`, according to the starter project's configuration.

## Security and Cost Notes

Do not commit passwords, private keys, AWS credentials, Terraform state files or sensitive configuration to the public repository.

The Jenkins instance, Application Load Balancer, ECS/Fargate tasks and related AWS resources may incur charges while running. Review the resources and remove them when they are no longer required.

## Project Status

The Jenkins pipeline completed successfully and reported:

`SUCCESS: Frontend and backend images deployed to ECS.`

The deployment was completed as part of Tech Challenge 2.
