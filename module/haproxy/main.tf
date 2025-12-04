# Fetch the most recent Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Create Security Group for HAProxy
resource "aws_security_group" "haproxy_sg" {
  name        = "${var.name}haproxy-sg"
  description = "k8s Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "k8s port"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.name}-haproxy-sg"
  }
}

# Create HAProxy server instance
resource "aws_instance" "haproxy" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.medium"

  subnet_id = var.private_subnet_ids[count.index]
  key_name  = var.key_name

  vpc_security_group_ids = [aws_security_group.haproxy_sg.id]

  user_data = templatefile("${path.module}/haproxy.sh", {
    master_ip_1 = var.master_private_ips[0]
    master_ip_2 = var.master_private_ips[1]
    master_ip_3 = var.master_private_ips[2]
  })

  tags = {
    Name = "${var.name}-haproxy-${count.index + 1}"
    Role = "haproxy"
  }
}


