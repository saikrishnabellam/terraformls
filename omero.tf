
data "template_file" "omero-master-template" {
  template               = "${file("omero-master.json.tpl")}"
  vars {
   REPOSITORY_URL = "${aws_elb.postgres-elb.dns_name}"

  }
}
data "template_file" "omero-web-template" {
  template               = "${file("omero-web.json.tpl")}"
  vars {

   REPOSITORY_URL = "${aws_elb.omero-master-elb.dns_name}"
   REPOSITORY1_URL = "${aws_elb.redis-elb.dns_name}:6379/0"
  }
}

data "aws_ecs_task_definition" "omero-master" {
  task_definition = "${aws_ecs_task_definition.omero-master.family}"
}
data "aws_ecs_task_definition" "omero-web" {
  task_definition = "${aws_ecs_task_definition.omero-web.family}"
   depends_on = [ "aws_ecs_task_definition.omero-web" ]
}
data "aws_ecs_container_definition" "omero-master" {
  task_definition = "${data.aws_ecs_task_definition.omero-master.id}"
  container_name  = "omero-master"
}
data "aws_ecs_container_definition" "omero-web" {
  task_definition = "${data.aws_ecs_task_definition.omero-web.id}"
  container_name  = "web"
}
resource "aws_ecs_task_definition" "omero-master" {
  family = "omero-master"
  container_definitions = "${data.template_file.omero-master-template.rendered}"
  volume {
    name      = "OMERO_DATA"
    host_path = "/mnt/OMERO_DATA"
  }
}
resource "aws_ecs_task_definition" "omero-web" {
  family = "omero-web"
  container_definitions = "${data.template_file.omero-web-template.rendered}"
   depends_on = [
    "data.template_file.omero-web-template",
  ]
}
resource "aws_elb" "omero-master-elb" {
  name = "omero-master-elb"
  listener  {
    instance_port = 4064
    instance_protocol = "TCP"
    lb_port = 4064
    lb_protocol = "TCP"
    }
  listener  {
    instance_port = 4063
    instance_protocol = "TCP"
    lb_port = 4063
    lb_protocol = "TCP"
    }


  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 5
    target = "TCP:4064"
    interval = 30
  }
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  subnets = ["${aws_subnet.main-public-1.id}","${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
  tags {
    Name = "omero-master-elb"
  }
}
resource "aws_alb" "omero-load-balancer" {
   name                = "omero-load-balancer"
   subnets = ["${aws_subnet.main-public-1.id}","${aws_subnet.main-public-2.id}"]
   security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
   tags {
     Name = "omero-load-balancer"
   }
}
resource "aws_alb_target_group" "omero-target-group" {
   name                = "omero-target-group"
   port                = "80"
   protocol            = "HTTP"
   vpc_id              = "${aws_vpc.main.id}"
   health_check {
       healthy_threshold   = "2"
       unhealthy_threshold = "2"
       interval            = "60"
       matcher             = "200"
       path                = "/webclient/login/"
       #port                = "80"
       protocol            = "HTTP"
       timeout             = "5"
   }
   tags {
     Name = "omero-target-group"
   }
}
resource "aws_alb_listener" "oalb-listener" {
   load_balancer_arn = "${aws_alb.omero-load-balancer.arn}"
   port              = "80"
   protocol          = "HTTP"
   default_action {
       target_group_arn = "${aws_alb_target_group.omero-target-group.arn}"
       type             = "forward"
   }
}
resource "aws_ecs_service" "omero-master" {
  name          = "omero-master"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.omero-master.family}:${max("${aws_ecs_task_definition.omero-master.revision}", "${data.aws_ecs_task_definition.omero-master.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_iam_policy_attachment.ecs-service-attach1"]
  load_balancer {
    elb_name = "${aws_elb.omero-master-elb.name}"
    container_name = "omero-master"
    container_port = 4064
  }
  lifecycle { ignore_changes = ["task_definition"] }
}
resource "aws_ecs_service" "omero-web" {
  name          = "omero-web"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.omero-web.family}:${max("${aws_ecs_task_definition.omero-web.revision}", "${data.aws_ecs_task_definition.omero-web.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_alb.omero-load-balancer"]
  load_balancer {
    target_group_arn= "${aws_alb_target_group.omero-target-group.arn}"
    container_name = "nginx"
    container_port = 80
  }
  lifecycle { ignore_changes = ["task_definition"] }
}
