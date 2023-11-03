resource "local_file" "ip-list" {
  content = <<-EOT
    [elastic]
    ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh
    [grafana]
    ${yandex_compute_instance.grafana.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh
    [kibana]
    ${yandex_compute_instance.kibana.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh
    [prom]
    ${yandex_compute_instance.prometheus.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh
    [webs]
    ${yandex_compute_instance.webserver1.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh
    ${yandex_compute_instance.webserver2.network_interface.0.ip_address} ansible_user=semkin ansible_ssh_private_key_file=/home/semkin/.ssh/id_ed25519 ansible_connection=ssh


    ssh ${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} 

    ssh -i ~/.ssh/id_ed25519 -J semkin@${yandex_compute_instance.bastion.network_interface.0.nat_ip_address} semkin@192.168.


    [bastion]
    ${yandex_compute_instance.bastion.network_interface.0.ip_address} bastion
    [elasticsearch]
    ${yandex_compute_instance.elasticsearch.network_interface.0.ip_address} elastic
    [grafana]
    ${yandex_compute_instance.grafana.network_interface.0.ip_address} grafana
    [kibana]
    ${yandex_compute_instance.kibana.network_interface.0.ip_address} kibana
    [prometheus]
    ${yandex_compute_instance.prometheus.network_interface.0.ip_address} prom
    [webs]
    ${yandex_compute_instance.webserver1.network_interface.0.ip_address} web-1
    ${yandex_compute_instance.webserver2.network_interface.0.ip_address} web-2


    EOT
  filename = "ip-list"
}













