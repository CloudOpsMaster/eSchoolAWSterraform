variable "region" {
  description = "AWS Deployment region.."
  default = "us-west-1"
}


#### VPC Network
variable "vpc_cidr" {
  default = "192.168.0.0/16"
}
