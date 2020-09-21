// Jenkins User Data
data "template_file" "jenkins_userdata" {
    template = "${file("${var.jenkins_userdata}")}"
    vars = {
        k8stoken = "${var.k8stoken}"
    }
}

resource "aws_security_group" "jenkins" {
  name        = "jenkins"
  description = "Allow inbound ssh and http traffic"
  vpc_id      = aws_vpc.devops-vpc.id

  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["${var.public_cidr_address}"]
  }

   ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["${var.public_cidr_address}"]
  }

  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["${var.public_cidr_address}"]
  }

  tags = merge(
    {
      Name        = "jenkinsSG",
      Project     = var.project,
      Environment = var.environment
    },
    var.tags
  )
}

resource "aws_instance" "jenkins" {
  ami           = var.ami
  instance_type = var.instances_type[2]
  subnet_id     = "${aws_subnet.public[0].id}"
  user_data     = "${data.template_file.jenkins_userdata.rendered}"
  key_name      = "${aws_key_pair.ssh-key.key_name}"
  associate_public_ip_address = true
  security_groups = ["${aws_security_group.jenkins.id}"]

  tags = merge(
  {
      Name        = "jenkins",
      Project     = var.project,
      Environment = var.environment
  },
    var.tags
  )

  lifecycle {
    create_before_destroy = true
  }

}
