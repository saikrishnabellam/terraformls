data "aws_ecs_task_definition" "postgres" {
  task_definition = "${aws_ecs_task_definition.postgres.family}"
}

data "aws_ecs_container_definition" "postgres" {
  task_definition = "${data.aws_ecs_task_definition.postgres.id}"
  container_name  = "postgres"
}

resource "aws_ecs_task_definition" "postgres" {
  family = "postgres"
  container_definitions = "${file("postgres.json")}"
}

resource "aws_elb" "postgres-elb" {
  name = "postgres-elb"
  listener {
    instance_port = 5432
    instance_protocol = "TCP"
    lb_port = 5432
    lb_protocol = "TCP"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 5
    target = "TCP:5432"
    interval = 30
  }
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  subnets = ["${aws_subnet.main-public-1.id}","${aws_subnet.main-public-2.id}"]
  security_groups = ["${aws_security_group.myapp-elb-securitygroup.id}"]
  tags {
    Name = "postgres-elb"
  }
}

resource "aws_ecs_service" "postgres" {
  name          = "postgres"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.postgres.family}:${max("${aws_ecs_task_definition.postgres.revision}", "${data.aws_ecs_task_definition.postgres.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_iam_policy_attachment.ecs-service-attach1"]
  load_balancer {
    elb_name = "${aws_elb.postgres-elb.name}"
    container_name = "postgres"
    container_port = 5432
  }
  lifecycle { ignore_changes = ["task_definition"] }
}

data "aws_ecs_task_definition" "redis" {
  task_definition = "${aws_ecs_task_definition.redis.family}"
}

data "aws_ecs_container_definition" "redis" {
  task_definition = "${data.aws_ecs_task_definition.redis.id}"
  container_name  = "redis"
}

resource "aws_ecs_task_definition" "redis" {
  family = "redis"
  container_definitions = "${file("redis.json")}"
}
resource "aws_elb" "redis-elb" {
  name = "redis-elb"
  listener {
    instance_port = 6379
    instance_protocol = "TCP"
    lb_port = 6379
    lb_protocol = "TCP"
  }
  health_check {
    healthy_threshold = 3
    unhealthy_threshold = 5
    timeout = 5
    target = "TCP:6379"
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

resource "aws_ecs_service" "redis" {
  name          = "redis"
  cluster       = "${aws_ecs_cluster.example-cluster.id}"
  desired_count = 1
  task_definition = "${aws_ecs_task_definition.redis.family}:${max("${aws_ecs_task_definition.redis.revision}", "${data.aws_ecs_task_definition.redis.revision}")}"
  iam_role = "${aws_iam_role.ecs-service-role.arn}"
  depends_on = ["aws_iam_policy_attachment.ecs-service-attach1"]
  load_balancer {
    elb_name = "${aws_elb.redis-elb.name}"
    container_name = "redis"
    container_port = 6379
  }
  lifecycle { ignore_changes = ["task_definition"] }
}
