# Stage 2 — Cluster Autoscaling

Configure the Kubernetes Cluster Autoscaler on EKS to automatically adjust the number of worker nodes based on pod demand.

## How Cluster Autoscaler Works

```
Pod pending (insufficient resources)
    → Cluster Autoscaler detects unschedulable pods
    → Requests new EC2 instance from Auto Scaling Group
    → New node joins the cluster
    → Pending pod gets scheduled

No pods on a node for 10+ minutes
    → Cluster Autoscaler marks node as underutilized
    → Drains and terminates the EC2 instance
    → Auto Scaling Group scales down
```

## Steps

### 1. Create Autoscaler IAM Policy

The Cluster Autoscaler needs permissions to interact with AWS Auto Scaling Groups.

```bash
# Create the policy (see 01-eks-cluster-manual/docs/iam-roles-setup.md for the JSON)
aws iam create-policy \
  --policy-name EKSClusterAutoscalerPolicy \
  --policy-document file://autoscaler-policy.json
```

### 2. Attach Policy to Node Group Role

```bash
aws iam attach-role-policy \
  --role-name eks-node-group-role \
  --policy-arn arn:aws:iam::<ACCOUNT_ID>:policy/EKSClusterAutoscalerPolicy
```

### 3. Deploy Cluster Autoscaler

```bash
# Apply the autoscaler manifest
kubectl apply -f cluster-autoscaler.yaml

# Verify it's running
kubectl get pods -n kube-system -l app=cluster-autoscaler
```

Key annotations in the manifest:
- `cluster-autoscaler.kubernetes.io/safe-to-evict: "false"` — prevents the autoscaler pod from being evicted
- `--node-group-auto-discovery` — automatically discovers Node Groups by tag
- `--balance-similar-node-groups` — distributes nodes evenly across AZs

### 4. Test Autoscaling

```bash
# Deploy nginx
kubectl apply -f nginx-deployment.yaml

# Scale to 20 replicas to trigger autoscaling
kubectl scale deployment nginx --replicas=20

# Watch new nodes being added
kubectl get nodes -w

# Watch pods going from Pending → Running
kubectl get pods -w
```

### 5. Verify Scale-Down

```bash
# Scale back down
kubectl scale deployment nginx --replicas=1

# After ~10 minutes, excess nodes will be terminated
kubectl get nodes -w
```

## Key Takeaways

- Cluster Autoscaler is **not built into EKS** — it's a separate deployment you manage
- The autoscaler version must match your Kubernetes version (e.g., K8s 1.28 → autoscaler 1.28.x)
- Scaling up is fast (~2-3 minutes for a new node), scaling down is slow by design (~10 minutes) to avoid flapping
- Node Group min/max settings in AWS are the hard limits — the autoscaler works within those bounds

## References

- [Cluster Autoscaler User Guide](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)
- [Autoscaler Releases](https://github.com/kubernetes/autoscaler/tags)
