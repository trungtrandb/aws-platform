resource "aws_security_group" "ec2" {
  name        = "${local.project}-ec2-sg"
  description = "Security group for K3s control-plane nodes"
  vpc_id      = aws_vpc.main.id

  ingress { // SSH port
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress { // Kubernetes API via NLB
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
    cidr_blocks = [
      var.admin_cidr,
      aws_vpc.main.cidr_block
    ]
  }

  ingress { // HTTP for workloads (optional)
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // HTTPS for workloads (optional)
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // PostgreSQL external access (restricted to admin CIDR)
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress { // Kafka NodePort backend for NLB listener 9094
    from_port   = 30094
    to_port     = 30094
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // Kafka NodePort backend for NLB listener 9095
    from_port   = 30095
    to_port     = 30095
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { // Kafka NodePort backend for NLB listener 9096
    from_port   = 30096
    to_port     = 30096
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow full east-west traffic between control-plane nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  ingress {
    description = "Allow access to Kafka UI"
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { // Allow all outbound traffic
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
