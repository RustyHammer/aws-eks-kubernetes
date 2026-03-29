# Stage 3 — EKS with Fargate

Deploy pods on AWS Fargate for fully managed, serverless worker nodes — no EC2 instances to manage.

## EC2 Node Group vs Fargate

| Aspect | Node Group (EC2) | Fargate |
|--------|------------------|---------|
| Management | Semi-managed (you configure instance types, scaling) | Fully managed (AWS handles everything) |
| Pricing | Pay for whole EC2 instance | Pay per pod (vCPU + memory per second) |
| Scaling | Cluster Autoscaler needed | Automatic, per-pod |
| Control | Full access to nodes (SSH, custom AMIs) | No node access |
| Best for | Predictable workloads, GPU, DaemonSets | Bursty workloads, batch jobs |

## Steps

### 1. Create Fargate Pod Execution Role

```
IAM Console → Roles → Create Role
├── Trusted entity: AWS Service → EKS - Fargate Pod
├── Policy: AmazonEKSFargatePodExecutionRolePolicy
└── Role name: eks-fargate-role
```

### 2. Create Fargate Profile

```
EKS Console → Cluster → Compute → Add Fargate Profile
├── Name: my-fargate-profile
├── Pod Execution Role: eks-fargate-role
├── Subnets: private subnets only
└── Selectors:
    └── Namespace: my-app
        Label (optional): profile=fargate
```

A Fargate Profile tells EKS: "Any pod matching these selectors should run on Fargate instead of EC2."

### 3. Deploy a Pod through Fargate

```bash
# Create the namespace that matches the Fargate profile selector
kubectl create namespace my-app

# Deploy nginx in the Fargate namespace
kubectl run nginx --image=nginx --namespace=my-app

# Verify it's running on Fargate (node name starts with "fargate-")
kubectl get pods -n my-app -o wide
# NAME    READY   STATUS    IP             NODE
# nginx   1/1     Running   192.168.x.x    fargate-ip-192-168-x-x.eu-west-1.compute.internal
```

### 4. Verify Fargate Node

```bash
kubectl get nodes
# You'll see a Fargate node alongside any EC2 nodes
# Fargate nodes are created per-pod and have "fargate-" prefix
```

## Key Takeaways

- Fargate profiles use **namespace + label selectors** to decide which pods run on Fargate
- Fargate pods can only run in **private subnets**
- Each Fargate pod gets its own **dedicated micro-VM** (strong isolation)
- You can mix Node Groups and Fargate in the same cluster
- Limitations: no DaemonSets, no privileged containers, no GPU workloads

## References

- [AWS Fargate for EKS](https://docs.aws.amazon.com/eks/latest/userguide/fargate.html)
