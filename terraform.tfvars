

cluster_name 			 = "devops_demo"
eks_version              = "1.18"
enable_private_access    = false
enable_public_access     = true
cluster_ssh_public_cidrs = ["0.0.0.0/0"]

# For kiam only
ng1_desired_size  = 2
ng1_max_size      = 3
ng1_min_size      = 2
ng1_instance_type = "t3.medium"
ng1_disk_size     = 30

# For remaining workload
ng3_desired_size  = 3
ng3_max_size      = 5
ng3_min_size      = 3
ng3_instance_type = "c5.xlarge"
ng3_disk_size     = 30
