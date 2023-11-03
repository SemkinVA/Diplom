#-------Output PUB------#
#output "Pub-Webserver1" {
#  value = yandex_compute_instance.webserver1.network_interface.0.nat_ip_address
#}

#output "Pub-Webserver2" {
#  value = yandex_compute_instance.webserver2.network_interface.0.nat_ip_address
#}

output "Pub-Grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
} 

#output "Pub-Prometh" {
#  value = yandex_compute_instance.prometheus.network_interface.0.nat_ip_address
#}

#output "Pub-Elastic" {
#  value = yandex_compute_instance.elasticsearch.network_interface.0.nat_ip_address
#} 

output "Pub-Kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "Pub-Bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

#-------Output PRIV------#
output "Priv-Webserver1" {
  value = yandex_compute_instance.webserver1.network_interface.0.ip_address
}

output "Priv-Webserver2" {
  value = yandex_compute_instance.webserver2.network_interface.0.ip_address
}

output "Priv-Grafana" {
  value = yandex_compute_instance.grafana.network_interface.0.ip_address
} 

output "Priv-Prometh" {
  value = yandex_compute_instance.prometheus.network_interface.0.ip_address
} 

output "Priv-Elastic" {
  value = yandex_compute_instance.elasticsearch.network_interface.0.ip_address
} 

output "Priv-Kibana" {
  value = yandex_compute_instance.kibana.network_interface.0.ip_address
} 

output "Priv-Bastion" {
  value = yandex_compute_instance.bastion.network_interface.0.ip_address
} 

#-------Output L7 load balancer------#
output "L7_load_balancer-pub" {
  value = yandex_alb_load_balancer.diplom-lb.listener[0].endpoint[0].address[0].external_ipv4_address
}