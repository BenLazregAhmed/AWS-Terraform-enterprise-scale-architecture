#Front end ec2 and LB
resource "aws_security_group" "front_alb_sg" {
  name   = "cloud-project-front-alb-sg"
  vpc_id = aws_vpc.main-vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*allows all outgoing traffic from load balancer*/
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-project-front-alb-sg"
  }
}

resource "aws_security_group" "front_ec2_sg" {
  name   = "cloud-project-front-ec2-sg"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    /* Accepts all traffic only from Load Balancer */
    security_groups = [aws_security_group.front_alb_sg.id]
    //cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-project-front-ec2-sg"
  }
}

#Back end ec2 and LB
resource "aws_security_group" "back_alb_sg" {
  name   = "cloud-project-back-alb-sg"
  vpc_id = aws_vpc.main-vpc.id
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    //security_groups = [aws_security_group.front_ec2_sg.id]
    cidr_blocks = ["0.0.0.0/0"]
  }
  /*allows all outgoing traffic from load balancer*/
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-project-back-alb-sg"
  }
}

# resource "aws_security_group_rule" "allow_front_ec2" {
#   type                     = "ingress"
#   from_port               = 8080
#   to_port                 = 8080
#   protocol                = "tcp"
#   source_security_group_id = aws_security_group.front_ec2_sg.id
#   security_group_id       = aws_security_group.back_alb_sg.id
# }

resource "aws_security_group" "back_ec2_sg" {
  name   = "cloud-project-back-ec2-sg"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    /* Accepts all traffic only from Load Balancer */
    security_groups = [aws_security_group.back_alb_sg.id]
    //cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-project-back-ec2-sg"
  }
}

