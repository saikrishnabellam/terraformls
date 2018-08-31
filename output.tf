output "postgres" {
  value = "${aws_elb.postgres-elb.dns_name}"
}
output "omero-master" {
  value = "${aws_elb.omero-master-elb.dns_name}"
}
output "redis" {
  value = "${aws_elb.redis-elb.dns_name}"
}
output "omero-web" {
  value = "${aws_alb.omero-load-balancer.dns_name}"
}
output "hedwig-master" {
  value = "${aws_alb.hedwig-load-balancer.dns_name}"
}
output "service" {
  value = "${aws_alb.service-load-balancer.dns_name}"
}
