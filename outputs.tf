
output "jenkins_dns" {
  value = "${aws_instance.jenkins.public_ip}"
}

output "eks_endpoint" {
  value = module.eks_cluster.endpoint
}

output "eks_id" {
  value = module.eks_cluster.id
}

output "eks_ca_data" {
  value = module.eks_cluster.ca_data
}