# AWS ECR Setup Guide

## What is ECR?

Elastic Container Registry (ECR) is AWS's private Docker registry — an alternative to DockerHub or Nexus.

**Advantages over DockerHub:**
- No pull rate limits
- Same IAM authentication as other AWS services
- Lower latency when pulling from EKS (same AWS network)
- Built-in image scanning for vulnerabilities

## Setup Steps

### 1. Create ECR Repository

```bash
aws ecr create-repository \
  --repository-name java-maven-app \
  --region eu-west-1 \
  --image-scanning-configuration scanOnPush=true

# Output includes the repository URI:
# <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/java-maven-app
```

### 2. Authenticate Docker with ECR

```bash
# Get a temporary login token (valid 12 hours)
aws ecr get-login-password --region eu-west-1 | \
  docker login --username AWS --password-stdin \
  <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com
```

### 3. Push an Image

```bash
# Tag with ECR repository URI
docker tag java-maven-app:latest \
  <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/java-maven-app:1.0

# Push
docker push <ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/java-maven-app:1.0
```

### 4. Create ECR Pull Secret in EKS

```bash
# Create a K8s secret so EKS can pull from ECR
aws ecr get-login-password --region eu-west-1 | \
  kubectl create secret docker-registry ecr-secret \
  --docker-server=<ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password-stdin
```

Then reference it in your Deployment:

```yaml
spec:
  imagePullSecrets:
    - name: ecr-secret
```

### 5. Jenkins Credentials for ECR

Add AWS credentials in Jenkins:
- **ID**: `aws-ecr-credentials`
- **Type**: Username with Password
- **Username**: AWS Access Key ID
- **Password**: AWS Secret Access Key

## ECR Image Lifecycle

```bash
# Set a lifecycle policy to clean up old images
aws ecr put-lifecycle-policy \
  --repository-name java-maven-app \
  --lifecycle-policy-text '{
    "rules": [{
      "rulePriority": 1,
      "description": "Keep only last 10 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 10
      },
      "action": { "type": "expire" }
    }]
  }'
```
