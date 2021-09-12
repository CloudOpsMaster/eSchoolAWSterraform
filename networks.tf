
# Network configuration


#### VPC Network
variable "vpc_cidr" {
  default = "192.168.0.0/16"
}

#### NETWORK PARAMS
variable "network_http" {
  default = {
    subnet_name = "subnet_http"
    cidr        = "192.168.1.0/24"
  }
}



# VPC creation
resource "aws_vpc" "eSchool" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name    = "vpc-http"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

# http subnet configuration
resource "aws_subnet" "eSchool" {
  vpc_id                  = aws_vpc.eSchool.id
  cidr_block              = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name    = "subnet-eSchool"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }

}

# External gateway configuration
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eSchool.id
  tags = {
    Name    = "internet-gateway"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}


# Create ande associate route

# Routing table configuration
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.eSchool.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate http route
resource "aws_route_table_association" "http" {
  subnet_id      = aws_subnet.eSchool.id
  route_table_id = aws_route_table.public.id
}

# eth interface for mysql
resource "aws_network_interface" "mysql" {
  subnet_id   = aws_subnet.eSchool.id
  private_ips = ["192.168.1.50"]
  security_groups = [
    aws_security_group.administration.id,
    aws_security_group.db.id,
  ]
  tags = {
    Name    = "mysql_etwork_interface"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}


# eth interface for app1
resource "aws_network_interface" "app1" {
  subnet_id   = aws_subnet.eSchool.id
  private_ips = ["192.168.1.20"]
  security_groups = [
    aws_security_group.administration.id,
    aws_security_group.app.id,
  ]
  tags = {
    Name    = "mysql_etwork_interface"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

# eth interface for app2
resource "aws_network_interface" "app2" {
  subnet_id   = aws_subnet.eSchool.id
  private_ips = ["192.168.1.30"]
  security_groups = [
    aws_security_group.administration.id,
    aws_security_group.app.id,
  ]
  tags = {
    Name    = "mysql_etwork_interface"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}



# eth interface for app2
resource "aws_network_interface" "loadbalancer" {
  subnet_id   = aws_subnet.eSchool.id
  private_ips = ["192.168.1.40"]
  security_groups = [
    aws_security_group.administration.id,
    aws_security_group.web.id,
  ]
  tags = {
    Name    = "loadbalancer_etwork_interface"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}


