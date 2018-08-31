variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "facilityPath" {}
variable "AWS_REGION" {
  default = "us-west-2"
}
variable "PATH_TO_PRIVATE_KEY" {
  default = "mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "mykey.pub"
}
variable "ECS_INSTANCE_TYPE" {
  default = "t2.large"
}
variable "ECS_AMIS" {
  type = "map"
  default = {

    us-west-2 = "ami-56ed4936"

  }
}
