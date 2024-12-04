provider "aws" {
  region = "us-west-2" 
}

# Create a VPC
resource "aws_vpc" "hello-world-webserver_eks_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "hello-world-webserver-eks-vpc"
  }
}


# Create Subnets
resource "aws_subnet" "eks_subnet" {
  count = 3 # Create 3 subnets

  vpc_id     = aws_vpc.hello-world-webserver_eks_vpc.id
  cidr_block = cidrsubnet(aws_vpc.hello-world-webserver_eks_vpc.cidr_block, 8, count.index)

  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "hello-world-webserver-eks-subnet-${count.index}"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.hello-world-webserver_eks_vpc.id

  tags = {
    Name = "hello-world-webserver-eks-igw"
  }
}

# Route Table
resource "aws_route_table" "eks_rt" {
  vpc_id = aws_vpc.hello-world-webserver_eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "hello-world-webserver-eks-rt"
  }
}

# Associate Subnets with Route Table
resource "aws_route_table_association" "eks_rta" {
  count          = length(aws_subnet.eks_subnet)
  subnet_id      = aws_subnet.eks_subnet[count.index].id
  route_table_id = aws_route_table.eks_rt.id
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "hello-world-webserver-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = aws_subnet.eks_subnet[*].id
  }

  tags = {
    Name = "hello-world-webserver-eks-cluster"
  }
}

# Create EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster_role" {
  name = "hello-world-webserver-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "eks.amazonaws.com" }
      },
    ]
  })
}

# Attach IAM Policies to Cluster Role
resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "hello-world-webserver_eks_vpc_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

# Create security group for EKS nodes
resource "aws_security_group" "eks_node_sg" {
  vpc_id = aws_vpc.hello-world-webserver_eks_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.hello-world-webserver_eks_vpc.cidr_block]  # Restrict to VPC range
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic (can restrict further if needed)
  }

  tags = {
    Name = "hello-world-webserver-eks-node-sg"
  }
}

# Create EKS Node Grou
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "hello-world-webserver-eks-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.eks_subnet[*].id

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]

  # # Assign the security group to the node group
  # remote_access {
  #   source_security_group_ids = [aws_security_group.eks_node_sg.id]
  # }

  tags = {
    Name = "hello-world-webserver-eks-node-group"
  }
}



# Create Node Group IAM Role
resource "aws_iam_role" "eks_node_role" {
  name = "hello-world-webserver-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
      },
    ]
  })
}

# Attach IAM Policies to Node Role
resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_ec2_container_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Fetch Availability Zones
data "aws_availability_zones" "available" {}



#aws eks update-kubeconfig --name eks_cluster --region hello-world-webserver-eks-cluster


