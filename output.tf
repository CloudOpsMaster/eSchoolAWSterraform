output "loadbalancer_public_ip" {
  value =  aws_instance.loadbalancer.public_ip
}


data "aws_availability_zones" "working" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "my_vpcs" {}

output "eschool_vpc_id" {
  value = resource.aws_vpc.eSchool.id
}

output "eSchool_vpc_cidr" {
  value = resource.aws_vpc.eSchool.cidr_block
}

output "aws_vpcs" {
  value = data.aws_vpcs.my_vpcs.ids
}


output "data_aws_availability_zones" {
  value = data.aws_availability_zones.working.names
}


output "data_aws_caller_identity" {
  value = data.aws_caller_identity.current.account_id
}

output "data_aws_region_name" {
  value = data.aws_region.current.name
}

output "data_aws_region_description" {
  value = data.aws_region.current.description
}