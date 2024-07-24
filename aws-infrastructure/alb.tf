# Create an Application Load Balancer (ALB)
resource "aws_lb" "final_project_alb" {
  name               = "final-project-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_subnet_1.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "final-project-alb"
  }
}

# Create a target group for the ALB
resource "aws_lb_target_group" "final_project_tg" {
  name     = "final-project-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.final_project.id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
    matcher             = "200-399"
  }

  tags = {
    Name = "final-project-tg"
  }
}

# Create a listener for the ALB
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.final_project_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.final_project_tg.arn
  }
}

# Register the EC2 instances in the private subnets with the target group
resource "aws_lb_target_group_attachment" "web_tg_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.final_project_tg.arn
  target_id        = aws_instance.final_web[count.index].id
  port             = 80
}
