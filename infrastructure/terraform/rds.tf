resource "aws_db_subnet_group" "mlops" {
  name       = "mlops-db-subnet-group"
  subnet_ids = [aws_subnet.private_a.id]

  tags = {
    Name = "mlops-db-subnet-group"
  }
}

resource "aws_db_instance" "mlflow_rds" {
  identifier             = "mlops-postgres-db"
  engine                 = "postgres"
  engine_version         = "15.3"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_encrypted      = true
  db_name                = "mlflow_db"
  username               = "mlflow"
  password               = var.db_password
  publicly_accessible    = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.mlops.name

  tags = {
    Name = "mlflow-db"
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "mlops-rds-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # EKS and airflow services can access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mlops-rds-sg"
  }
}
