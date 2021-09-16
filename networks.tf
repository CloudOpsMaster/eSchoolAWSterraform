# vpc
resource "aws_vpc" "vpc" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "vpc"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }

  enable_dns_hostnames = true
}


# public subnet
resource "aws_subnet" "public_subnet" {
  depends_on = [ aws_vpc.vpc]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.0.0/24"

  # availability_zone_id = "us-west-1b"

  tags = {
    Name = "public_subnet"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }

  map_public_ip_on_launch = true
}

# private subnet
resource "aws_subnet" "private_subnet" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"

  # availability_zone_id = "us-west-1b"

  tags = {
    Name = "private-subnet"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

# internet gateway
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc,
  ]

  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "internet-gateway"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

# route table with target as internet gateway
resource "aws_route_table" "IG_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.internet_gateway,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "IG-route-table"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}

# associate route table to public subnet
resource "aws_route_table_association" "associate_routetable_to_public_subnet" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_route_table.IG_route_table,
  ]
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.IG_route_table.id
}


# elastic ip
resource "aws_eip" "elastic_ip" {
  vpc      = true
}

# NAT gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [
    aws_subnet.public_subnet,
    aws_eip.elastic_ip,
  ]
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "nat-gateway"
    Owner   = "Vadim Tailor"
    Project = "awsEschool"
  }
}


# route table with target as NAT gateway
resource "aws_route_table" "NAT_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.nat_gateway,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "NAT-route-table"
  }
}

# associate route table to private subnet
resource "aws_route_table_association" "associate_routetable_to_private_subnet" {
  depends_on = [
    aws_subnet.private_subnet,
    aws_route_table.NAT_route_table,
  ]
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.NAT_route_table.id
}



# bastion host security group
resource "aws_security_group" "sg_bastion_host" {
  depends_on = [
    aws_vpc.vpc,
  ]
  name        = "sg bastion host"
  description = "bastion host security group"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow TCP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "allow TCP"
    from_port   = 443
    to_port     = 443
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


# wordpress security group
resource "aws_security_group" "app" {
  depends_on = [
    aws_vpc.vpc,
  ]

  name        = "sg app"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow TCP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_bastion_host.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# mysql security group
resource "aws_security_group" "sg_mysql" {
  depends_on = [
    aws_vpc.vpc,
  ]
  name        = "sg mysql"
  description = "Allow mysql inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow TCP"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description = "allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.sg_bastion_host.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



































##### NETWORK PARAMS
#variable "network_http" {
#  default = {
#    subnet_name = "subnet_http"
#    cidr        = "192.168.1.0/24"
#  }
#}
#
#
#
## VPC creation
#resource "aws_vpc" "eSchool" {
#  cidr_block           = var.vpc_cidr
#  enable_dns_hostnames = true
#
#  tags = {
#    Name    = "vpc-http"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
## public http subnet configuration
#resource "aws_subnet" "eSchool" {
#  vpc_id                  = aws_vpc.eSchool.id
#  cidr_block              = "192.168.1.0/24"
#  map_public_ip_on_launch = true
#  tags = {
#    Name    = "subnet-eSchool"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#
#}
#
## External gateway configuration
#resource "aws_internet_gateway" "gw" {
#  vpc_id = aws_vpc.eSchool.id
#  tags = {
#    Name    = "internet-gateway"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
## Create ande associate route
#
## Routing table configuration
#resource "aws_route_table" "public" {
#  vpc_id = aws_vpc.eSchool.id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = aws_internet_gateway.gw.id
#  }
#}
#
## Associate http route
#resource "aws_route_table_association" "http" {
#  subnet_id      = aws_subnet.eSchool.id
#  route_table_id = aws_route_table.public.id
#}
#
## eth interface for mysql
#resource "aws_network_interface" "mysql" {
#  subnet_id   = aws_subnet.eSchool.id
#  private_ips = ["192.168.1.50"]
#  security_groups = [
#    aws_security_group.administration.id,
#    aws_security_group.db.id,
#  ]
#  tags = {
#    Name    = "mysql_etwork_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
## eth interface for app1
#resource "aws_network_interface" "app1" {
#  subnet_id   = aws_subnet.eSchool.id
#  private_ips = ["192.168.1.20"]
#  security_groups = [
#    aws_security_group.administration.id,
#    aws_security_group.app.id,
#  ]
#  tags = {
#    Name    = "mysql_etwork_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
## eth interface for app2
#resource "aws_network_interface" "app2" {
#  subnet_id   = aws_subnet.eSchool.id
#  private_ips = ["192.168.1.30"]
#  security_groups = [
#    aws_security_group.administration.id,
#    aws_security_group.app.id,
#  ]
#  tags = {
#    Name    = "mysql_etwork_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
#
## eth interface for app2
#resource "aws_network_interface" "loadbalancer" {
#  subnet_id   = aws_subnet.eSchool.id
#  private_ips = ["192.168.1.40"]
#  security_groups = [
#    aws_security_group.administration.id,
#    aws_security_group.web.id,
#  ]
#  tags = {
#    Name    = "loadbalancer_etwork_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
#
############# PRIVATE network ##################
#
#resource "aws_instance" "nat" {
#  ami = "ami-0046c079820366dc3" # this is a special ami preconfigured to do NAT
#  # availability_zone           = "eu-west-1a"
#  instance_type               = "t2.micro"
#  key_name                    = "aws_key"
#  vpc_security_group_ids      = ["${aws_security_group.nat.id}"]
#  subnet_id                   = aws_subnet.private.id
#  associate_public_ip_address = true
#  source_dest_check           = false
#
#  tags = {
#    Name    = "VPC NAT"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
## private subnet configuration
#resource "aws_subnet" "private" {
#  vpc_id                  = aws_vpc.eSchool.id
#  cidr_block              = "192.168.2.0/24"
#  map_public_ip_on_launch = true
#  tags = {
#    Name    = "private-subnet-eSchool"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#
#}
#
#resource "aws_route_table" "private_table" {
#  vpc_id = aws_vpc.eSchool.id
#
#  route {
#    cidr_block  = "0.0.0.0/0"
#    instance_id = aws_instance.nat.id
#  }
#
#  tags = {
#    Name    = "Private Subnet"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#resource "aws_route_table_association" "ass_private" {
#  subnet_id      = aws_subnet.private.id
#  route_table_id = aws_route_table.private_table.id
#}
#
#
## eth interface for db mysql private network
#resource "aws_network_interface" "db_private" {
#  subnet_id   = aws_subnet.private.id
#  private_ips = ["192.168.2.50"]
#  security_groups = [
#    aws_security_group.nat.id
#  ]
#  tags = {
#    Name    = "DB_private_network_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
## eth interface for db app1 private network
#resource "aws_network_interface" "app1_private" {
#  subnet_id   = aws_subnet.private.id
#  private_ips = ["192.168.2.40"]
#  security_groups = [
#    aws_security_group.nat.id
#  ]
#  tags = {
#    Name    = "DB_private_network_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
#
## eth interface for db app2 private network
#resource "aws_network_interface" "app2_private" {
#  subnet_id   = aws_subnet.private.id
#  private_ips = ["192.168.2.30"]
#  security_groups = [
#    aws_security_group.nat.id
#  ]
#  tags = {
#    Name    = "DB_private_network_interface"
#    Owner   = "Vadim Tailor"
#    Project = "awsEschool"
#  }
#}
#
