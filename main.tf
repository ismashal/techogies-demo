// k8s cluster Key pair the instances
resource "aws_key_pair" "ssh-key" {
  key_name    = "k8s"
  public_key  = var.k8s_ssh_key

  lifecycle {
    create_before_destroy = true
  }
}

// VPC resources
resource "aws_vpc" "devops-vpc" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    {
      Name        = "devops-vpc",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

// Internet gateway
resource "aws_internet_gateway" "devops-ig" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = merge(
    {
      Name        = "devops-ig",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

// Private route table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.devops-vpc.id
  tags = merge(
    {
      Name        = "PrivateRouteTable",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "private" {
  route_table_id          = aws_route_table.private.id
  destination_cidr_block  = var.public_cidr_address
  nat_gateway_id          = aws_nat_gateway.devops-ng.id
}

// Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.devops-vpc.id

  tags = merge(
    {
      Name        = "PublicRouteTable",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.public_cidr_address
  gateway_id             = aws_internet_gateway.devops-ig.id
}

// public subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.devops-vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(
    {
      Name        = "PrivateSubnet",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

// public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.devops-vpc.id
  cidr_block              = var.public_subnet_cidr_blocks[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name        = "PublicSubnet",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

// Route table association
resource "aws_route_table_association" "private" {
  count           = length(var.private_subnet_cidr_blocks)
  subnet_id       = aws_subnet.private[count.index].id
  route_table_id  = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count           = length(var.public_subnet_cidr_blocks)
  subnet_id       = aws_subnet.public[count.index].id
  route_table_id  = aws_route_table.public.id
}

// Elastic ip address
resource "aws_eip" "eip" {
  vpc = true
}

// NAT resources
resource "aws_nat_gateway" "devops-ng" {
  depends_on    = ["aws_internet_gateway.devops-ig"]
 // count         = length(var.public_subnet_cidr_blocks)
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(
    {
      Name        = "devops-nat",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

