variable "region" {
  default = "us-east-1"
}

variable "project" {
  default     = "devops"
  type        = string
  description = "Name of project this VPC is meant to house"
}

variable "environment" {
  default     = "dev"
  type        = string
  description = "Name of environment this VPC is targeting"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}

variable "k8stoken" {
  default = ""
}

variable "access_key" {
  default = ""
}

variable "secret_key" {
  default = ""
}

variable "jenkins_userdata" {
    default = "jenkins.sh"
}

variable "ami" {
    default = "ami-0620d12a9cf777c87"
}

variable "instances_type" {
  default     = ["t2.micro", "t2.small", "t2.medium", "t2.large" ]
  type        = list
  description = "List of aws instances type"
}

variable "public_cidr_address" {
    default = "0.0.0.0/0"
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "Extra tags to attach to the VPC resources"
}

variable "ecr_repo_name" {
  default = "devops-demo"
}

variable "cluster_name" {}

variable "brand" {}

variable "region" {}

variable "component" {}

variable "eks_version" {}

variable "enable_private_access" {}

variable "enable_public_access" {}

variable "cluster_ssh_public_cidrs" {
  type = list
}

variable "ng1_desired_size" {}

variable "ng1_max_size" {}

variable "ng1_min_size" {}

variable "ng1_instance_type" {}

variable "ng1_disk_size" {}

variable "ng2_desired_size" {}

variable "ng2_max_size" {}

variable "ng2_min_size" {}

variable "ng2_instance_type" {}

variable "ng2_disk_size" {}

variable "ng3_desired_size" {}

variable "ng3_max_size" {}

variable "ng3_min_size" {}

variable "ng3_instance_type" {}

variable "ng3_disk_size" {}