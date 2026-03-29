# VPC Configuration for EKS

## Why a Dedicated VPC?

EKS clusters require specific networking:
- **Public subnets** for the Elastic Load Balancer (external traffic)
- **Private subnets** for Worker Nodes (not directly exposed to internet)
- **Security groups** for Control Plane ↔ Worker Node communication
- Subnets across **multiple Availability Zones** for high availability

## Architecture

```
VPC (192.168.0.0/16)
├── Public Subnet AZ-1 (192.168.0.0/18)
│   └── Internet Gateway → ELB
├── Public Subnet AZ-2 (192.168.64.0/18)
│   └── Internet Gateway → ELB
├── Private Subnet AZ-1 (192.168.128.0/18)
│   └── NAT Gateway → Worker Nodes
└── Private Subnet AZ-2 (192.168.192.0/18)
    └── NAT Gateway → Worker Nodes
```

## CloudFormation Template

AWS provides a ready-to-use template:

```
https://s3.us-west-2.amazonaws.com/amazon-eks/cloudformation/2020-10-29/amazon-eks-vpc-private-subnets.yaml
```

### What it creates

| Resource | Purpose |
|----------|---------|
| VPC | Main network with DNS support enabled |
| 2 Public Subnets | For load balancers, NAT gateways |
| 2 Private Subnets | For EKS worker nodes |
| Internet Gateway | Internet access for public subnets |
| 2 NAT Gateways | Outbound internet for private subnets (pulling images, updates) |
| Route Tables | Routing rules for public/private traffic |
| Security Group | Allows communication between Control Plane and Worker Nodes |

## Subnet Tags

EKS uses specific tags to discover subnets:

```
# All subnets
kubernetes.io/cluster/<cluster-name> = shared

# Public subnets (for ELB)
kubernetes.io/role/elb = 1

# Private subnets (for internal ELB)
kubernetes.io/role/internal-elb = 1
```

## References

- [Creating a VPC for EKS](https://docs.aws.amazon.com/eks/latest/userguide/create-public-private-vpc.html)
- [EKS VPC CloudFormation Template](https://docs.aws.amazon.com/codebuild/latest/userguide/cloudformation-vpc-template.html)
