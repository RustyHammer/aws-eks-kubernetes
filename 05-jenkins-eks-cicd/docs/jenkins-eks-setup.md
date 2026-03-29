# Jenkins to EKS — Setup Guide

## Overview

To deploy from Jenkins to EKS, the Jenkins container needs:
1. **kubectl** — to apply Kubernetes manifests
2. **aws-iam-authenticator** — to authenticate with AWS and get EKS tokens
3. **kubeconfig** — to know which cluster to connect to
4. **AWS credentials** — to authenticate the IAM user
5. **envsubst** — to substitute environment variables in manifest templates

## Step-by-Step

### 1. Install Tools in Jenkins Container

```bash
# Enter Jenkins container as root
docker exec -it -u root jenkins-container bash

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install aws-iam-authenticator
curl -Lo aws-iam-authenticator \
  https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/download/v0.6.11/aws-iam-authenticator_0.6.11_linux_amd64
chmod +x aws-iam-authenticator
mv aws-iam-authenticator /usr/local/bin/

# Install envsubst
apt-get update && apt-get install -y gettext-base
```

### 2. Create Kubeconfig

```bash
# On your local machine
aws eks update-kubeconfig --name my-eks-cluster --region eu-west-1

# Copy to Jenkins container
docker cp ~/.kube/config jenkins-container:/var/jenkins_home/.kube/config
```

The kubeconfig file contains:
- **Cluster endpoint** (API server URL)
- **Certificate authority** data
- **Authentication command** (uses aws-iam-authenticator to get a token)

### 3. Configure Jenkins Credentials

In Jenkins → Manage Jenkins → Manage Credentials → Add:

| Credential | Type | ID | Description |
|-----------|------|-----|-------------|
| AWS Access Key ID | Secret text | `aws-access-key-id` | IAM user access key |
| AWS Secret Access Key | Secret text | `aws-secret-access-key` | IAM user secret key |
| DockerHub | Username/Password | `docker-hub-credentials` | DockerHub login |

### 4. Best Practice: Dedicated Jenkins IAM User

Create a dedicated IAM user for Jenkins with minimal permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "eks:DescribeCluster",
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload"
      ],
      "Resource": "*"
    }
  ]
}
```

## How Authentication Works

```
Jenkins Pipeline runs kubectl apply
    → kubectl reads kubeconfig
    → kubeconfig calls aws-iam-authenticator
    → aws-iam-authenticator uses AWS credentials to get a token
    → Token is sent to EKS API server
    → EKS validates the token via IAM
    → kubectl command is executed on the cluster
```
