resource "aws_lb" "back_app_lb" {
  name               = "back-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.back_alb_sg.id]
  subnets            = [for subnet in aws_subnet.private_subnet : subnet.id]
  depends_on         = [aws_internet_gateway.internet_gw]
}

resource "aws_lb_target_group" "back_app_lb_tg" {
  name     = "back-app-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main-vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = {
    Name = "cloud-project-back-app-lb-tg"
  }
}

resource "aws_lb_listener" "back_app_lb_listener" {
  load_balancer_arn = aws_lb.back_app_lb.arn
  port              = "8080"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.back_app_lb_tg.arn
  }
  tags = {
    Name = "cloud-project-app-lb-listener"
  }
}
#Launch Template
resource "aws_launch_template" "back_ec2_launch_template" {
  name = "cloud-project-back-server"
  image_id      = var.ami  # Amazon Linux 2 (verify region)
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.back_ec2_sg.id]
  }
  user_data = base64encode(<<-EOF
  #!/bin/bash
  sudo apt-get update
  sudo apt-get install -y ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo usermod -aG docker ubuntu
  sudo systemctl enable docker
  sudo systemctl start docker
  DB_ENDPOINT=$(echo "${aws_db_instance.db_instance1.endpoint}" | cut -d':' -f1)
  docker run -p 8080:3000 --name back \
  -e DB_HOST=$DB_ENDPOINT \
  -e DB_PASSWORD=${var.db_pass} \
  -e DB_NAME=${var.db_name} \
  -e DB_USER=${var.db_user} \
  ahmedevops/cloud-project-backend
  EOF
  )
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "cloud-project-back-server"
    }
  }
  depends_on = [aws_db_instance.db_instance1]
}
# Auto Scaling Group
resource "aws_autoscaling_group" "back_ec2_asg" {
  name                = "cloud-project-back-servers-asg"
  desired_capacity    = 2
  min_size            = 2
  max_size            = 3
  target_group_arns   = [aws_lb_target_group.back_app_lb_tg.arn]
  vpc_zone_identifier = aws_subnet.private_subnet[*].id
  launch_template {
    id      = aws_launch_template.back_ec2_launch_template.id
    version = "$Latest"
  }
  health_check_type = "EC2"
}
