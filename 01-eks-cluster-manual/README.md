# Stage 1 — EKS Cluster (Manual Setup)

Create an EKS cluster step by step through the AWS Management Console.

## Steps

### 1. Create EKS IAM Role

The EKS service needs permissions to manage AWS resources on your behalf.

```
IAM Console → Roles → Create Role
├── Trusted entity: AWS Service → EKS → EKS - Cluster
├── Policy: AmazonEKSClusterPolicy (attached automatically)
└── Role name: eks-cluster-role
```

### 2. Create VPC with CloudFormation

EKS requires a VPC with public and private subnets across multiple Availability Zones.

```bash
# Use the AWS-provided CloudFormation template
# CloudFormation Console → Create Stack → Template URL:
# https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
```

This creates:
- VPC with CIDR 192.168.0.0/16
- 2 public subnets (with Internet Gateway)
- 2 private subnets (with NAT Gateway)
- Security groups for Control Plane ↔ Worker Node communication

See [VPC CloudFormation details](./docs/vpc-cloudformation.md).

### 3. Create EKS Cluster

```
EKS Console → Create Cluster
├── Name: my-eks-cluster
├── Kubernetes version: 1.28
├── Cluster Service Role: eks-cluster-role
├── VPC: (select the one created by CloudFormation)
├── Subnets: select all (public + private)
├── Security Group: (the one created by CloudFormation)
└── Cluster Endpoint Access: Public and Private
```

> Cluster creation takes ~10-15 minutes.

### 4. Connect kubectl Locally

```bash
# Update kubeconfig to point to the new EKS cluster
aws eks update-kubeconfig --name my-eks-cluster --region eu-west-1

# Verify connection
kubectl get svc
# NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
# kubernetes   ClusterIP   10.100.0.1   <none>        443/TCP   10m
```

### 5. Create Node Group IAM Role

Worker nodes (EC2 instances) need their own IAM role with specific policies.

```
IAM Console → Roles → Create Role
├── Trusted entity: AWS Service → EC2
├── Policies:
│   ├── AmazonEKSWorkerNodePolicy
│   ├── AmazonEKS_CNI_Policy
│   └── AmazonEC2ContainerRegistryReadOnly
└── Role name: eks-node-group-role
```

See [IAM Roles Setup](./docs/iam-roles-setup.md) for detailed policy descriptions.

### 6. Create Node Group

```
EKS Console → Cluster → Compute → Add Node Group
├── Name: my-node-group
├── Node IAM Role: eks-node-group-role
├── AMI type: Amazon Linux 2
├── Instance type: t3.medium
├── Scaling:
│   ├── Desired: 2
│   ├── Minimum: 1
│   └── Maximum: 3
└── Subnets: private subnets only
```

### 7. Verify

```bash
kubectl get nodes
# NAME                                       STATUS   ROLES    AGE   VERSION
# ip-192-168-1-xxx.eu-west-1.compute.internal   Ready    <none>   2m    v1.28.x
# ip-192-168-2-xxx.eu-west-1.compute.internal   Ready    <none>   2m    v1.28.x
```

## Key Takeaways

- EKS manages the Control Plane (API server, etcd, scheduler) — you only manage Worker Nodes
- Control Plane is replicated across 3 Availability Zones for high availability
- VPC must have proper networking (public subnet for ELB, private subnet for worker nodes)
- Two separate IAM roles: one for EKS cluster, one for Node Group (EC2 instances)

## References

- [EKS Getting Started (AWS Docs)](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-console.html)
- [EKS VPC CloudFormation Template](https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html)
