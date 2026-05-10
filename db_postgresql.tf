
# -------------------
# Security Group
# -------------------

# resource "aws_security_group" "db" {
#   name        = "${local.project}-db-sg"
#   description = "Database security group"
#   vpc_id      = aws_vpc.main.id

#   ingress {
#     from_port = 5432
#     to_port   = 5432
#     protocol  = "tcp"

#     #TODO: Nên giới hạn IP hoặc SG thay vì mở toàn bộ
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${local.project}-db-sg"
#   }
# }

# -------------------
# DB Subnet Group
# -------------------

# resource "aws_db_subnet_group" "main" {
#   name = "${local.project}-db-subnet-group"

#   subnet_ids = aws_subnet.private[*].id

#   tags = {
#     Name = "${local.project}-db-subnet-group"
#   }
# }

# -------------------
# PostgreSQL RDS
# -------------------

# resource "aws_db_instance" "postgres" {
#   identifier        = "${local.project}-postgres"
#   allocated_storage = 20

#   engine         = "postgres"
#   engine_version = "15"

#   instance_class = "db.t3.micro"

#   db_name  = var.db_name
#   username = var.db_username
#   password = var.db_password

#   publicly_accessible = false
#   skip_final_snapshot = true
#   multi_az            = false

#   vpc_security_group_ids = [
#     aws_security_group.db.id
#   ]

#   db_subnet_group_name = aws_db_subnet_group.main.name

#   tags = {
#     Name = "${local.project}-postgres"
#   }
# }