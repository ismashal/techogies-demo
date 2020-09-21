module "eks_cluster" {
  source = "git::https://github.com/terrablocks/aws-eks-cluster"

  vpc_id                      = data.terraform_remote_state.server.outputs.vpc_id
  subnet_ids                  = data.terraform_remote_state.server.outputs.private_subnet_ids
  cluster_name                = var.cluster_name
  eks_version                 = var.eks_version
  enable_private_access       = var.enable_private_access
  enable_public_access        = var.enable_public_access
  public_cidrs                = var.cluster_ssh_public_cidrs
  kms_deletion_window_in_days = 7
}

# For kiam
module "kiam_ng" {
  source = "git::https://github.com/terrablocks/aws-eks-unmanaged-node-group.git"

  cluster_name     = module.eks_cluster.id
  ng_name          = "${module.eks_cluster.id}-kiam-ng"
  subnet_ids       = data.terraform_remote_state.server.outputs.private_subnet_ids
  desired_size     = var.ng1_desired_size
  max_size         = var.ng1_max_size
  min_size         = var.ng1_min_size
  instance_type    = var.ng1_instance_type
  volume_size      = var.ng1_disk_size
  user_data_base64 = filebase64("${path.module}/additional-user-data.tpl")
  bootstrap_args   = "--kubelet-extra-args '--node-labels=tavisca.com/asg=${module.eks_cluster.id}-workers,node.kubernetes.io/worker=worker --kube-reserved=cpu=300m,memory=0.5Gi,ephemeral-storage=1Gi --register-with-taints=node=micro:NoSchedule'"
}

resource "aws_iam_role_policy_attachment" "kiam_ng_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = module.kiam_ng.role_name
}

# For remaining workload
module "app_ng" {
  source = "git::https://github.com/terrablocks/aws-eks-unmanaged-node-group.git"

  cluster_name     = module.eks_cluster.id
  ng_name          = "${module.eks_cluster.id}-app-ng"
  subnet_ids       = data.terraform_remote_state.server.outputs.private_subnet_ids
  desired_size     = var.ng3_desired_size
  max_size         = var.ng3_max_size
  min_size         = var.ng3_min_size
  instance_type    = var.ng3_instance_type
  volume_size      = var.ng3_disk_size
  user_data_base64 = filebase64("${path.module}/additional-user-data.tpl")
  bootstrap_args   = "--kubelet-extra-args '--node-labels=tavisca.com/asg=${module.eks_cluster.id}-workers,node.kubernetes.io/worker=worker --kube-reserved=cpu=300m,memory=0.5Gi,ephemeral-storage=1Gi'"
}

resource "aws_iam_role_policy_attachment" "app_ng_ssm_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = module.app_ng.role_name
}


