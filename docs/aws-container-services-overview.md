# AWS Container Services Overview

## The Three Services

| Service | Type | Purpose |
|---------|------|---------|
| **ECR** (Elastic Container Registry) | Registry | Store and manage Docker images |
| **ECS** (Elastic Container Service) | Orchestration | AWS-native container orchestration |
| **EKS** (Elastic Kubernetes Service) | Orchestration | Managed Kubernetes |

## ECS vs EKS

| Aspect | ECS | EKS |
|--------|-----|-----|
| API | AWS-proprietary (ECS Agent) | Standard Kubernetes API |
| Portability | AWS-locked | Portable (any K8s cluster) |
| Complexity | Lower (simpler for basic apps) | Higher (full K8s feature set) |
| Community | Smaller | Huge (Helm charts, operators, tools) |
| Control Plane cost | Free | ~$0.10/hour (~$73/month) |
| Migration | Difficult to move off AWS | Easy to migrate to GKE, AKS, on-prem |
| Best for | Simple microservices on AWS | Complex apps, multi-cloud strategy |

## Worker Node Options (Both ECS and EKS)

### EC2 Instances
- **You manage** the underlying infrastructure
- Full control: SSH access, custom AMIs, GPUs
- Pay for the whole instance whether utilized or not

### AWS Fargate (Serverless)
- **AWS manages** everything — no servers to provision
- Per-pod pricing (vCPU + memory per second)
- Automatic scaling without configuring autoscalers
- No DaemonSets, no privileged containers, no SSH

## EKS Worker Node Spectrum

```
Self-managed EC2 ←——→ Managed Node Group ←——→ Fargate
(full control)       (semi-managed)         (fully managed)
```

| Mode | You manage | AWS manages |
|------|-----------|-------------|
| **Self-managed EC2** | AMI, scaling, updates, everything | Control Plane only |
| **Managed Node Group** | Instance type, scaling config | AMI updates, node provisioning, health |
| **Fargate** | Nothing (just pod specs) | Everything including infrastructure |

## How They Work Together

```
Developer → pushes code
    → CI/CD builds Docker image
    → Image pushed to ECR
    → EKS/ECS pulls image from ECR
    → Application runs in containers
```

ECR integrates natively with both ECS and EKS — same IAM, same VPC, no extra configuration.
