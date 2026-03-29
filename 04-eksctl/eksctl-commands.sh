#!/bin/bash
# =============================================================
# eksctl Commands Reference
# =============================================================

# --- Cluster Management ---

# Create a cluster with managed node group
eksctl create cluster \
  --name my-cluster \
  --version 1.28 \
  --region eu-west-1 \
  --nodegroup-name worker-nodes \
  --node-type t3.medium \
  --nodes 2 \
  --nodes-min 1 \
  --nodes-max 3

# List clusters
eksctl get cluster --region eu-west-1

# Delete cluster (removes all associated resources)
eksctl delete cluster --name my-cluster --region eu-west-1

# --- Node Group Management ---

# Add a new node group to existing cluster
eksctl create nodegroup \
  --cluster my-cluster \
  --name new-node-group \
  --node-type t3.large \
  --nodes 3

# Scale a node group
eksctl scale nodegroup \
  --cluster my-cluster \
  --name worker-nodes \
  --nodes 5

# Delete a node group
eksctl delete nodegroup \
  --cluster my-cluster \
  --name old-node-group

# --- Fargate ---

# Create Fargate profile
eksctl create fargateprofile \
  --cluster my-cluster \
  --name my-fargate-profile \
  --namespace my-app

# --- Kubeconfig ---

# Write kubeconfig for existing cluster
eksctl utils write-kubeconfig --cluster my-cluster --region eu-west-1
