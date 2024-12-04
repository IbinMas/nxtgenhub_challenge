
# AWS EKS Cluster Terraform Configuration

This Terraform configuration creates an Amazon Elastic Kubernetes Service (EKS) cluster with the necessary networking infrastructure and IAM roles.

## Infrastructure Components

- **VPC** with 3 public subnets across different availability zones
- **Internet Gateway**
- **Route Table** with public routes
- **EKS Cluster**
- **EKS Node Group**
- Required **IAM roles and policies**
- **Security Groups**

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- Proper AWS IAM permissions to create resources

## Resources Created

### Networking
- **VPC** with CIDR block `10.0.0.0/16`
- 3 **public subnets** in different availability zones
- **Internet Gateway**
- **Route Table** with public routes
- **Route Table Associations**

### EKS Cluster
- EKS Cluster with name **`hello-world-webserver-eks-cluster`**
- **Node Group** with `t3.medium` instances
- Scaling configuration:
  - **Min**: 1
  - **Desired**: 2
  - **Max**: 3

### Security
- Security Group for EKS nodes
- IAM roles for EKS cluster
- IAM roles for worker nodes
- Required policy attachments

---

## Usage

### Step 1: Initialize Terraform
```bash
terraform init
```

### Step 2: Review the Planned Changes
```bash
terraform plan
```

### Step 3: Apply the Configuration
```bash
terraform apply
```

### Step 4: Configure `kubectl`
After successful creation, run the following command to update your Kubernetes configuration:
```bash
aws eks update-kubeconfig --name hello-world-webserver-eks-cluster --region us-west-2
```

---

## Configuration Details

### Provider Configuration
- **Region**: `us-west-2`

### VPC Configuration
- **CIDR Block**: `10.0.0.0/16`
- **Public subnets** are automatically created in available AZs
- All subnets have **auto-assign public IP enabled**

### Node Group Configuration
- **Instance Type**: `t3.medium`
- **Desired Capacity**: 2 nodes
- **Maximum Size**: 3 nodes
- **Minimum Size**: 1 node

---

## Clean Up

To destroy all resources created by this configuration:
```bash
terraform destroy
```

---

## Important Notes
- This configuration creates **public subnets**. For production environments, consider using **private subnets** with **NAT Gateways**.
- The security group allows **all outbound traffic** and **inbound traffic** within the VPC.
- The EKS cluster and nodes will incur **AWS charges**.
