resource "aws_lb" "webtierlb" {
  name               = "webtierlb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_groups_web]
  subnets            = [var.publicsubnet1, var.publicsubnet2]
  tags = {
    Name = "webtierlb"
  }
}

resource "aws_lb_target_group" "webtiertargetgroup" {

  name        = "webtiertargetgroup"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "webtier_alb_http_listener" {
  load_balancer_arn = aws_lb.webtierlb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webtiertargetgroup.arn
  }
}


