resource "exoscale_security_group" "web" {
  name = "web"
}

resource "exoscale_security_group_rule" "http" {
  security_group_id = exoscale_security_group.web.id
  type              = "INGRESS"
  protocol          = "tcp"
  cidr              = "0.0.0.0/0"
  start_port        = 80
  end_port          = 80
}

