
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

# public http subnet configuration
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



############ PRIVATE network ##################

resource "aws_instance" "nat" {
  ami = "ami-0046c079820366dc3" # this is a special ami preconfigured to do NAT
  # availability_zone           = "eu-west-1a"
  instance_type               = "t2.micro"
  key_name                    = "aws_key"
  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
  subnet_id                   = aws_subnet.private.id
  associate_public_ip_address = true
  source_dest_check           = false

  tags = {
    Name    = "VPC NAT"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

resource "aws_eip" "nat" {
  instance = aws_instance.nat.id
  vpc      = true
}



# private subnet configuration
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.eSchool.id
  cidr_block              = "192.168.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name    = "private-subnet-eSchool"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }

}

resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.eSchool.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat.id
  }

  tags = {
    Name    = "Private Subnet"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

resource "aws_route_table_association" "ass_private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private_table.id
}



#resource "aws_route_table_association" "association_private_public" {
#  subnet_id = aws_subnet.private.id
#  route_table_id = aws_route_table.public.id
#}

# Associate http route
#resource "aws_route_table_association" "http" {
#  subnet_id      = aws_subnet.eSchool.id
#  route_table_id = aws_route_table.public.id
#}


# eth interface for db mysql private network
resource "aws_network_interface" "db_private" {
  subnet_id   = aws_subnet.private.id
  private_ips = ["192.168.2.50"]
  security_groups = [
    aws_security_group.db_private.id
  ]
  tags = {
    Name    = "DB_private_network_interface"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}
