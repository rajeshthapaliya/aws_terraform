resource "aws_vpc" "dellvpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "dellvpc"
  }
}

resource "aws_subnet" "dellsubnet1" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet1
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "dellsubnet1"
  }
}

resource "aws_subnet" "dellsubnet2" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet2
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "dellsubnet2"
  }
}

resource "aws_subnet" "dellsubnet3" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet3
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "dellsubnet3"
  }
}

resource "aws_subnet" "dellsubnet4" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet4
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "dellsubnet4"
  }
}

resource "aws_subnet" "dellsubnet5" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet5
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false

  tags = {
    Name = "dellsubnet5"
  }
}

resource "aws_subnet" "dellsubnet6" {
  vpc_id                  = aws_vpc.dellvpc.id
  cidr_block              = var.dellsubnet6
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false

  tags = {
    Name = "dellsubnet6"
  }
}

resource "aws_internet_gateway" "delligw" {
  vpc_id = aws_vpc.dellvpc.id

  tags = {
    Name = "delligw"
  }
}

resource "aws_route_table" "dellpublicroutetable" {
  vpc_id = aws_vpc.dellvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.delligw.id
  }
  tags = {
    Name = "dellpublicroutetable"
  }
}

resource "aws_route_table_association" "dellpublica" {
  subnet_id      = aws_subnet.dellsubnet1.id
  route_table_id = aws_route_table.dellpublicroutetable.id
}

resource "aws_route_table_association" "dellpublicb" {
  subnet_id      = aws_subnet.dellsubnet2.id
  route_table_id = aws_route_table.dellpublicroutetable.id
}

resource "aws_eip" "delleip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "dellngw" {
  allocation_id = aws_eip.delleip.id
  subnet_id     = aws_subnet.dellsubnet1.id
  depends_on    = [aws_internet_gateway.delligw]
}

resource "aws_route_table" "dellprivateroutetable" {
  vpc_id = aws_vpc.dellvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dellngw.id
  }
  tags = {
    Name = "dellprivateroutetable"
  }
}

resource "aws_route_table_association" "dellprivatea" {
  subnet_id      = aws_subnet.dellsubnet3.id
  route_table_id = aws_route_table.dellprivateroutetable.id
}

resource "aws_route_table_association" "dellprivateb" {
  subnet_id      = aws_subnet.dellsubnet4.id
  route_table_id = aws_route_table.dellprivateroutetable.id
}

resource "aws_route_table_association" "dellprivatec" {
  subnet_id      = aws_subnet.dellsubnet5.id
  route_table_id = aws_route_table.dellprivateroutetable.id
}

resource "aws_route_table_association" "dellprivated" {
  subnet_id      = aws_subnet.dellsubnet6.id
  route_table_id = aws_route_table.dellprivateroutetable.id
}


resource "aws_security_group" "webtiersg" {
  name        = "mysg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.dellvpc.id

  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "webtiersg"
  }
}

resource "aws_security_group" "apptiersg" {
  name        = "apptiersg"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = aws_vpc.dellvpc.id

  ingress {
    description = "allow http"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.webtiersg.id, ]
  }
  ingress {
    description = "allow ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.webtiersg.id, ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "myapptiersg"
  }
}


#create a security group for RDS Database Instance
resource "aws_security_group" "myrdsg" {
  description = "Allow MySQL"
  vpc_id      = aws_vpc.dellvpc.id
  name        = "myrdsg"
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "mysql" {
  name        = "db_subnet_group"
  description = "My database subnet group"
  subnet_ids  = [aws_subnet.dellsubnet5.id, aws_subnet.dellsubnet6.id]
  tags = {
    Name = "db_subnet_group"
  }
}