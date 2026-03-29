# IAM Roles for EKS

## EKS Cluster Role

Allows the EKS service to manage AWS resources for the cluster.

| Policy | Purpose |
|--------|---------|
| `AmazonEKSClusterPolicy` | Allows EKS to create and manage cluster resources (ENIs, security groups, logs) |

**Trust relationship:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Node Group Role

Allows EC2 instances (worker nodes) to communicate with the EKS cluster and pull container images.

| Policy | Purpose |
|--------|---------|
| `AmazonEKSWorkerNodePolicy` | Allows worker nodes to connect to EKS cluster |
| `AmazonEKS_CNI_Policy` | Allows the VPC CNI plugin to manage pod networking (assign IPs) |
| `AmazonEC2ContainerRegistryReadOnly` | Allows pulling container images from ECR |

**Trust relationship:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Fargate Pod Execution Role

Required for EKS Fargate profiles.

| Policy | Purpose |
|--------|---------|
| `AmazonEKSFargatePodExecutionRolePolicy` | Allows Fargate to pull images and send logs |

**Trust relationship:**

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks-fargate-pods.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

## Autoscaler Policy (Custom)

Attached to the Node Group Role to allow the Cluster Autoscaler to manage Auto Scaling Groups.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeScalingActivities",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:DescribeInstanceTypes",
        "eks:DescribeNodegroup"
      ],
      "Resource": ["*"]
    }
  ]
}
```
