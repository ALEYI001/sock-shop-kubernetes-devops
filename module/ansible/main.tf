# Fetch latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for Ansible server
resource "aws_security_group" "ansible_sg" {
  name        = "${var.name}-ansible-sg"
  description = "Allow ssh"
  vpc_id      = var.vpc_id

  # SSH access ONLY from Bastion Host
  ingress {
    description     = "Allow SSH from Bastion Host"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_sg]
  }
  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-ansible-sg"
  }
}

# Ansible EC2 instance
resource "aws_instance" "ansible_server" {
 ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.keypair_name
  vpc_security_group_ids = [aws_security_group.ansible_sg.id]
  subnet_id              = var.subnet_id[0]
  iam_instance_profile = aws_iam_instance_profile.ansible_profile.id
  depends_on = [aws_s3_object.playbook]
  user_data = templatefile("${path.module}/userdata.sh", {
    private_key         = var.private_key,
    s3_bucket_name     = var.s3_bucket_name,
    master1_private_ip      = var.master1,
    master2_private_ip      = var.master2,
    master3_private_ip      = var.master3,
    haproxy1_private_ip      = var.haproxy1,
    haproxy2_private_ip      = var.haproxy2,
    worker1_private_ip      = var.worker1,
    worker2_private_ip      = var.worker2,
    worker3_private_ip      = var.worker3
  })

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name = "${var.name}-ansible-server"
  }
}

# IAM Role for Ansible
resource "aws_iam_role" "ansible_role" {
  name = "${var.name}-ansible-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_policy" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.ansible_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "ansible_profile" {
  name = "${var.name}-ansible-profile"
  role = aws_iam_role.ansible_role.name
}

# upload Ansible file to S3
resource "aws_s3_object" "playbook" {
  for_each = fileset("${path.module}/playbooks", "*")
  bucket = var.s3_bucket_name
  key    = "playbooks/${each.value}"
  source = "${path.module}/playbooks/${each.value}"
  etag   = filemd5("${path.module}/playbooks/${each.value}")
}
