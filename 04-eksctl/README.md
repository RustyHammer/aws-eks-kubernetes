# Stage 4 — Create EKS Cluster with eksctl

Use the `eksctl` CLI to create a fully configured EKS cluster with a single command — automating all the manual steps from Stage 1.

## What eksctl Does Automatically

Everything that took 6 manual steps in Stage 1, eksctl does in one command:

```
eksctl create cluster
├── Creates EKS IAM Role
├── Creates VPC with public + private subnets
├── Creates EKS Cluster (Control Plane)
├── Creates Node Group IAM Role
├── Creates Node Group (Worker Nodes)
└── Updates kubeconfig locally
```

## Steps

### 1. Install eksctl

```bash
# macOS
brew tap weaveworks/tap
brew install weaveworks/tap/eksctl

# Linux
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

# Windows (chocolatey)
choco install eksctl

# Verify
eksctl version
```

### 2. Configure AWS Credentials

```bash
aws configure
# AWS Access Key ID: <your-key>
# AWS Secret Access Key: <your-secret>
# Default region name: eu-west-1
# Default output format: json

# Verify
aws sts get-caller-identity
```

### 3. Create EKS Cluster

```bash
# Basic cluster (uses defaults)
eksctl create cluster \
  --name my-cluster \
  --version 1.28 \
  --region eu-west-1 \
  --nodegroup-name worker-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3
```

> This takes ~15-20 minutes. eksctl uses CloudFormation under the hood.

### 4. Verify

```bash
# eksctl automatically updates kubeconfig
kubectl get nodes
kubectl get svc
```

### 5. Delete Cluster

```bash
# Clean up everything (VPC, Node Group, IAM Roles, etc.)
eksctl delete cluster --name my-cluster --region eu-west-1
```

## eksctl vs Manual vs Terraform

| Approach | Pros | Cons |
|----------|------|------|
| **Manual** (Stage 1) | Full understanding, fine-grained control | Slow, error-prone, not reproducible |
| **eksctl** | Fast, single command, good defaults | Hard to version control, limited customization |
| **Terraform** | Reproducible, version-controlled, full customization | More complex, requires Terraform knowledge |

## Key Takeaways

- eksctl is the fastest way to get an EKS cluster running for development/testing
- Under the hood, eksctl creates CloudFormation stacks — you can see them in the AWS Console
- For production, Terraform/Pulumi is preferred for reproducibility and state management
- eksctl can also manage existing clusters (scale nodes, add Fargate profiles, etc.)

## References

- [eksctl - Installation](https://github.com/eksctl-io/eksctl)
- [eksctl - Getting Started](https://eksctl.io/getting-started/)
