resource "aws_db_instance" "db_instance1" {
  allocated_storage   = 20
  storage_type        = "standard"
  engine              = "mysql"
  engine_version      = "8.0.34"
  instance_class      = "db.t3.micro"
  name                = var.db_name
  username            = var.db_user
  password            = var.db_pass
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  skip_final_snapshot = true

}

resource "aws_db_subnet_group" "main" {
  name       = "main-db-subnet-group"
  subnet_ids = aws_subnet.private_subnet[*].id  # Subnets must be in main-vpc

  tags = {
    Name = "main-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name   = "cloud-project-db-sg"
  vpc_id = aws_vpc.main-vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.back_ec2_sg.id,aws_security_group.back_alb_sg.id]  # backend SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cloud-project-db-sg"
  }
}
