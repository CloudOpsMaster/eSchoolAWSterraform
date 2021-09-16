provider "aws" {
  region = var.region
}


resource "aws_instance" "loadbalancer" {
  #  count                  = 1
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on = [aws_security_group.sg_bastion_host]
  vpc_security_group_ids = [aws_security_group.sg_bastion_host.id]
  subnet_id = aws_subnet.public_subnet.id
  key_name = "aws_key"
  user_data = templatefile("${path.module}/loadbalancer.sh.tpl", {
    APLICATION1 = aws_instance.eSchool_1.private_ip
    APLICATION2 = aws_instance.eSchool_2.private_ip
    }
  )
  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "loadbalancer"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_instance" "mysql" {
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on    = [aws_security_group.sg_mysql, aws_nat_gateway.nat_gateway,
  aws_route_table_association.associate_routetable_to_private_subnet]
  key_name      = "aws_key"
  user_data = templatefile("${path.module}/mysql.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    }
  )
  vpc_security_group_ids = [aws_security_group.sg_mysql.id]
  subnet_id = aws_subnet.private_subnet.id

  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "mysql db"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "eSchool_1" {

  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on = [ aws_security_group.app, aws_instance.mysql]
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id = aws_subnet.private_subnet.id
  key_name               = "aws_key"
  user_data = templatefile("${path.module}/eSchool.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    MYSQL_HOST          = aws_instance.mysql.private_ip
    }
  )
  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "eSchool app_1"
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "eSchool_2" {

  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on = [ aws_security_group.app, aws_instance.mysql]
  vpc_security_group_ids = [aws_security_group.app.id]
  subnet_id = aws_subnet.private_subnet.id
  key_name               = "aws_key"
  user_data = templatefile("${path.module}/eSchool.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    MYSQL_HOST          = aws_instance.mysql.private_ip
    }
  )
  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "eSchool app_2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

