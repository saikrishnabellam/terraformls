data "template_file" "hedwig-web-template" {
  template               = "${file("hedwig-web.json.tpl")}"
  vars {
   REPOSITORY_URL = "${aws_alb.service-load-balancer.dns_name}"
   REPOSITORY1_URL = "${data.aws_ecr_repository.hedwigweblatest.repository_url}"
  }
}
data "template_file" "hedwig-services-template" {
  template               = "${file("hedwig-service.json.tpl")}"
  vars {
   REPOSITORY_URL = "${aws_elb.postgres-elb.dns_name}"
   facility_path  = "/"
   REPOSITORY1_URL = "${data.aws_ecr_repository.labshare_servicev2.repository_url}"
  }
}


data "aws_ecs_task_definition" "hedwig-web" {
  task_definition = "${aws_ecs_task_definition.hedwig-web.family}"
}
data "aws_ecs_task_definition" "hedwig-services" {
  task_definition = "${aws_ecs_task_definition.hedwig-services.family}"
}
data "aws_ecs_container_definition" "hedwig-web" {
  task_definition = "${data.aws_ecs_task_definition.hedwig-web.id}"
  container_name  = "hedwig-web"
}
data "aws_ecs_container_definition" "hedwig-services" {
  task_definition = "${data.aws_ecs_task_definition.hedwig-services.id}"
  container_name  = "hedwig-services"
}
resource "aws_ecs_task_definition" "hedwig-web" {
  family = "hedwig-web"
  container_definitions = "${data.template_file.hedwig-web-template.rendered}"
   volume {
    name      = "APP_DATA"
    host_path = "/home/ec2-user/hedwig-services/app.conf"
 }

}
resource "aws_ecs_task_definition" "hedwig-services" {
  family = "hedwig-services"
  container_definitions = "${data.template_file.hedwig-services-template.rendered}"
  volume {
    name      = "HEDWIG_DATA"
    host_path = "/mnt/HEDWIG_DATA"
 }
  volume {
    name      = "CONFIG_DATA"
    host_path = "/home/ec2-user/hedwig-services/config.json"
 }
}


resource "aws_alb" "hedwig-load-balancer" {
   name                = "hedwig-load-balancer"
   subnets = ["${aws_subnet.main-public-1.id}","${aws_subnet.main-public-2.id}"]
   security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
   tags {
     Name = "hedwig-load-balancer"
   }
}
resource "aws_alb_target_group" "hedwig-target-group" {
   name                = "hedwig-target-group"
   port                = "80"
   protocol            = "HTTP"
   vpc_id              = "${aws_vpc.main.id}"
   health_check {
       healthy_threshold   = "2"
       unhealthy_threshold = "2"
       interval            = "60"
       matcher             = "200"
       path                = "/#/login"
       #port                = "80"
       protocol            = "HTTP"
       timeout             = "5"
   }
   tags {
     Name = "hedwig-target-group"
   }
}
resource "aws_alb_listener" "halb-listener" {
   load_balancer_arn = "${aws_alb.hedwig-load-balancer.arn}"
   port              = "80"
   protocol          = "HTTP"
   default_action {
       target_group_arn = "${aws_alb_target_group.hedwig-target-group.arn}"
       type             = "forward"
   }
}
resource "aws_ecs_service" "hedwig-web" {
  name          = "hedwig-web"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.hedwig-web.family}:${max("${aws_ecs_task_definition.hedwig-web.revision}", "${data.aws_ecs_task_definition.hedwig-web.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_alb.hedwig-load-balancer"]
  load_balancer {
    target_group_arn= "${aws_alb_target_group.hedwig-target-group.arn}"
    container_name = "hedwig-web"
    container_port = 8000
  }
  lifecycle { ignore_changes = ["task_definition"] }
}

resource "aws_alb" "service-load-balancer" {
   name                = "service-load-balancer"
   subnets = ["${aws_subnet.main-public-1.id}","${aws_subnet.main-public-2.id}"]
   security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
   tags {
     Name = "service-load-balancer"
   }
}
resource "aws_alb_target_group" "service-target-group" {
   name                = "service-target-group"
   port                = "80"
   protocol            = "HTTP"
   vpc_id              = "${aws_vpc.main.id}"
   health_check {
       healthy_threshold   = "2"
       unhealthy_threshold = "2"
       interval            = "60"
       matcher             = "200"
       path                = "/ls/facility/settings"
       #port                = "80"
       protocol            = "HTTP"
       timeout             = "5"
   }
   tags {
     Name = "service-target-group"
   }
}
resource "aws_alb_listener" "salb-listener" {
   load_balancer_arn = "${aws_alb.service-load-balancer.arn}"
   port              = "80"
   protocol          = "HTTP"
   default_action {
       target_group_arn = "${aws_alb_target_group.service-target-group.arn}"
       type             = "forward"
   }
}
resource "aws_ecs_service" "hedwig-services" {
  name          = "hedwig-services"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.hedwig-services.family}:${max("${aws_ecs_task_definition.hedwig-services.revision}", "${data.aws_ecs_task_definition.hedwig-services.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_alb.service-load-balancer"]
  load_balancer {
    target_group_arn= "${aws_alb_target_group.service-target-group.arn}"
    container_name = "hedwig-services"
    container_port = 8605
  }
  lifecycle { ignore_changes = ["task_definition"] }
}
