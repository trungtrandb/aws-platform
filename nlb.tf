# -------------------
# Network Load Balancer for K3s API
# -------------------

resource "aws_lb" "main" {
  name               = "${local.project}-nlb"
  internal           = false
  load_balancer_type = "network"

  subnets = aws_subnet.public[*].id

  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Name = "${local.project}-nlb"
  }
}

# -------------------
# Target Group for K3s API servers
# -------------------

resource "aws_lb_target_group" "k3s_api_tg" {
  name        = "${local.project}-k3s-api-tg"
  port        = 6443
  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "6443"
  }

  tags = {
    Name = "${local.project}-k3s-api-tg"
  }
}

resource "aws_lb_target_group_attachment" "k3s_api_attach" {
  count = 3

  target_group_arn = aws_lb_target_group.k3s_api_tg.arn
  target_id        = aws_instance.public[count.index].id
  port             = 6443
}

resource "aws_lb_listener" "k3s_api" {
  load_balancer_arn = aws_lb.main.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.k3s_api_tg.arn
  }
}

# -------------------
# Target Group for Kafka Brokers
# -------------------

resource "aws_lb_target_group" "kafka_broker0_tg" {
  name        = "${local.project}-kafka-9094-tg"
  port        = 30094
  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "30094"
  }

  tags = {
    Name = "${local.project}-kafka-9094-tg"
  }
}

resource "aws_lb_target_group_attachment" "kafka_broker0_attach" {
  count = 3

  target_group_arn = aws_lb_target_group.kafka_broker0_tg.arn
  target_id        = aws_instance.public[count.index].id
  port             = 30094
}

resource "aws_lb_listener" "kafka_broker0" {
  load_balancer_arn = aws_lb.main.arn
  port              = 9094
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kafka_broker0_tg.arn
  }
}

resource "aws_lb_target_group" "kafka_broker1_tg" {
  name        = "${local.project}-kafka-9095-tg"
  port        = 30095
  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "30095"
  }

  tags = {
    Name = "${local.project}-kafka-9095-tg"
  }
}

resource "aws_lb_target_group_attachment" "kafka_broker1_attach" {
  count = 3

  target_group_arn = aws_lb_target_group.kafka_broker1_tg.arn
  target_id        = aws_instance.public[count.index].id
  port             = 30095
}

resource "aws_lb_listener" "kafka_broker1" {
  load_balancer_arn = aws_lb.main.arn
  port              = 9095
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kafka_broker1_tg.arn
  }
}

resource "aws_lb_target_group" "kafka_broker2_tg" {
  name        = "${local.project}-kafka-9096-tg"
  port        = 30096
  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "30096"
  }

  tags = {
    Name = "${local.project}-kafka-9096-tg"
  }
}

resource "aws_lb_target_group_attachment" "kafka_broker2_attach" {
  count = 3

  target_group_arn = aws_lb_target_group.kafka_broker2_tg.arn
  target_id        = aws_instance.public[count.index].id
  port             = 30096
}

resource "aws_lb_listener" "kafka_broker2" {
  load_balancer_arn = aws_lb.main.arn
  port              = 9096
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.kafka_broker2_tg.arn
  }
}

# -------------------
# Target Group for Gateway HTTP entrypoint
# -------------------

resource "aws_lb_target_group" "gateway_http_tg" {
  name        = "${local.project}-gateway-80-tg"
  port        = 80
  protocol    = "TCP"
  target_type = "instance"

  vpc_id = aws_vpc.main.id

  health_check {
    protocol = "TCP"
    port     = "80"
  }

  tags = {
    Name = "${local.project}-gateway-80-tg"
  }
}

resource "aws_lb_target_group_attachment" "gateway_http_attach" {
  count = 3

  target_group_arn = aws_lb_target_group.gateway_http_tg.arn
  target_id        = aws_instance.public[count.index].id
  port             = 80
}

resource "aws_lb_listener" "gateway_http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.gateway_http_tg.arn
  }
}