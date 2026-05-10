# -------------------
# Latest Ubuntu 24.04 AMI
# -------------------

data "aws_ami" "ubuntu_24" {
  most_recent = true

  owners = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -------------------
# EC2 Instance
# -------------------

resource "aws_instance" "public" {
  count = 3

  ami           = data.aws_ami.ubuntu_24.id
  instance_type = var.instance_type

  subnet_id = aws_subnet.public[count.index].id

  vpc_security_group_ids = [
    aws_security_group.ec2.id
  ]

  associate_public_ip_address = true
  key_name                    = aws_key_pair.my_key.key_name
  instance_market_options {
    market_type = "spot"

    spot_options {
      spot_instance_type = "one-time"
      #   instance_interruption_behavior = "stop"
    }
  }

  user_data = <<-EOF
              #!/bin/bash
              set -euo pipefail

              apt-get update -y
              apt-get install -y curl

              if [ "${count.index}" -eq 0 ]; then
                curl -sfL https://get.k3s.io | K3S_TOKEN='${var.k3s_token}' sh -s - server \
                  --cluster-init \
                  --tls-san '${aws_lb.main.dns_name}' \
                  --write-kubeconfig-mode 644
              else
                until curl -skf https://${aws_lb.main.dns_name}:6443/ping; do
                  sleep 5
                done

                curl -sfL https://get.k3s.io | K3S_TOKEN='${var.k3s_token}' sh -s - server \
                  --server https://${aws_lb.main.dns_name}:6443 \
                  --tls-san '${aws_lb.main.dns_name}' \
                  --write-kubeconfig-mode 644
              fi
              EOF
  tags = {
    Name = "${local.project}-k3s-server-${count.index + 1}"
  }
}

resource "aws_key_pair" "my_key" {
  key_name   = "${local.project}-key"
  public_key = file(pathexpand("~/.ssh/id_rsa.pub"))
}