variable "zone" {
  default = "at-vie-1"
}

variable "template" {
  default = "Linux Ubuntu 20.04 LTS 64-bit"
}

data "exoscale_compute_template" "ubuntu" {
  zone = var.zone
  name = var.template
}

resource "exoscale_instance_pool" "website" {
  name               = "instancepool-website"
  description        = "exercise2"
  template_id        = data.exoscale_compute_template.ubuntu.id
  service_offering   = "micro"
  size               = 3
  zone               = var.zone
  security_group_ids = [exoscale_security_group.web.id]
  user_data          = <<EOF
#!/bin/bash
set -e
apt --yes update
apt --yes upgrade
apt --yes install nginx
ipaddress=$(hostname -I)
name=$(hostname)
echo "<h1>Deployed via Terraform: $ipaddress: $name</h1>" | sudo tee /var/www/html/index.html
systemctl restart nginx
EOF
}

resource "exoscale_nlb" "website" {
  name        = "nlb-website"
  description = "Load balancer for the website"
  zone        = var.zone
}

#one service for tcp and another for udp???
resource "exoscale_nlb_service" "website" {
  zone             = exoscale_nlb.website.zone
  name             = "website-nlb-service-tcp"
  description      = "Network load balancer service for the website"
  nlb_id           = exoscale_nlb.website.id
  instance_pool_id = exoscale_instance_pool.website.id
  protocol         = "tcp"
  port             = 80
  target_port      = 80
  strategy         = "round-robin"

  healthcheck {
    mode     = "tcp"
    port     = 80
    interval = 5
    timeout  = 3
    retries  = 1
    uri      = ""
    #The healthcheck URI, must be set only if mode = http(s).
  }
}
