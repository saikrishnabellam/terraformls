# cluster
data "template_file" "user_data" {
  template = "${file("deploy.tpl")}"
  vars {
    SQL_HOST = "${aws_elb.postgres-elb.dns_name}"
    FACILITY_PATH = "/"
  }

}
resource "aws_ecs_cluster" "example-cluster" {
    name = "example-cluster"
}
resource "aws_launch_configuration" "ecs-example-launchconfig" {
  name_prefix          = "ecs-launchconfig"
  image_id             = "${lookup(var.ECS_AMIS, var.AWS_REGION)}"
  instance_type        = "${var.ECS_INSTANCE_TYPE}"
  key_name             = "${aws_key_pair.mykeypair.key_name}"
  iam_instance_profile = "${aws_iam_instance_profile.ec2-ec2-role.id}"
  security_groups      = ["${aws_security_group.ecs-securitygroup.id}"]
  user_data            = "${data.template_file.user_data.rendered}"
  lifecycle              { create_before_destroy = true }
}
resource "aws_autoscaling_group" "ecs-example-autoscaling" {
  name                 = "ecs-example-autoscaling"
  vpc_zone_identifier  = ["${aws_subnet.main-public-1.id}", "${aws_subnet.main-public-2.id}"]
  launch_configuration = "${aws_launch_configuration.ecs-example-launchconfig.name}"
  min_size             = 1
  max_size             = 4
  desired_capacity     = 3
  tag {
      key = "Name"
      value = "ecs-ec2-container"
      propagate_at_launch = true
  }
}
