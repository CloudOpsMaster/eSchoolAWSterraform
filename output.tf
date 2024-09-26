data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "my_vpcs" {}

output "eSchool_vpc_cidr" {
  value = resource.aws_vpc.vpc.cidr_block
}
output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "data_aws_region_name" {
  value = data.aws_region.current.name
}

output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}
output "data_aws_region_description" {
  value = data.aws_region.current.description
}

output "loadbalancer_public_ip" {
  value =  aws_instance.loadbalancer.public_ip
}

output "mysql_private_ip" {
  value =  aws_instance.mysql.private_ip
}

output "app1_private_ip" {
  value =  aws_instance.eSchool_1.private_ip
}

output "app2_private_ip" {
  value =  aws_instance.eSchool_2.private_ip
}
