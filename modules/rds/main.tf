#create a RDS Database Instance
resource "aws_db_instance" "dbinstance" {
  engine                 = var.engine
  identifier             = var.identifier
  allocated_storage      = var.allocated_storage
  instance_class         = var.instance_type
  username               = var.username
  password               = var.password
  vpc_security_group_ids = [var.vpc_security_group_ids]
  skip_final_snapshot    = true
  publicly_accessible    = false
  db_subnet_group_name   = var.db_subnet_group_name
}