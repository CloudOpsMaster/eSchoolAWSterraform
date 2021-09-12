provider "aws" {
  region = "us-west-1"
}


resource "aws_instance" "loadbalancer" {
  #  count                  = 1
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on = [aws_vpc.eSchool, aws_subnet.eSchool, aws_instance.mysql,
  aws_instance.eSchool_1, aws_instance.eSchool_2]
  key_name = "aws_key"
  user_data = templatefile("${path.module}/loadbalancer.sh.tpl", {
    name_instance = "loadbalancer"
    name_group_h  = "load balancer group"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.loadbalancer.id
    device_index         = 0
  }


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
  # count         = 1
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on    = [aws_vpc.eSchool, aws_subnet.eSchool]
  key_name      = "aws_key"
  user_data = templatefile("${path.module}/mysql.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.mysql.id
    device_index         = 0
  }

  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "mysql db"
  }

  lifecycle {
    create_before_destroy = true
  }

}





# # Attach floating ip on instance mysql
# resource "aws_eip" "public_mysql" {
#   vpc        = true
#   instance   = aws_instance.mysql.id
#   depends_on = [aws_internet_gateway.gw]
#   tags = {
#     Name    = "public-app1"
#     Owner   = "Vadim Tailor"
#     Project = "awsEschool"
#   }
# }






resource "aws_instance" "eSchool_1" {

  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on    = [aws_vpc.eSchool, aws_subnet.eSchool, aws_instance.mysql]
  key_name      = "aws_key"
  user_data = templatefile("${path.module}/eSchool.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.app1.id
    device_index         = 0
  }

  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "eSchool app_1"
  }

  lifecycle {
    create_before_destroy = true
  }
}


## Attach floating ip on instance loadbalancer
#resource "aws_eip" "public_eSchool_1" {
#  vpc        = true
#  instance   = aws_instance.eSchool_1.id
#  depends_on = [aws_internet_gateway.gw]
#  tags = {
#    Name    = "public-app1"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}




resource "aws_instance" "eSchool_2" {
  count         = 1
  ami           = "ami-0d382e80be7ffdae5"
  instance_type = "t2.micro"
  depends_on    = [aws_vpc.eSchool, aws_subnet.eSchool, aws_instance.mysql]
  key_name      = "aws_key"
  user_data = templatefile("${path.module}/eSchool.sh.tpl", {
    DATASOURCE_USERNAME = "eschool"
    DATASOURCE_PASSWORD = "b1dnijpesvseshesre"
    MYSQL_ROOT_PASSWORD = "legme876FCTFEfg1"
    }
  )

  network_interface {
    network_interface_id = aws_network_interface.app2.id
    device_index         = 0
  }


  tags = {
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
    Name    = "eSchool app_2"
  }

  lifecycle {
    create_before_destroy = true
  }

}

