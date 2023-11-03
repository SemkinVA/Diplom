#-------NET------#
resource "yandex_vpc_network" "diplom" {
  name           = "diplom"
}

#-------SUBNETS------#
resource "yandex_vpc_subnet" "subnet1" {
  name           = "subnet1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}
resource "yandex_vpc_subnet" "subnet2" {
  name           = "subnet2"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.20.0/24"]
}
resource "yandex_vpc_subnet" "subnet3" {
  name           = "subnet3"
  zone           = "ru-central1-c"
  network_id     = yandex_vpc_network.diplom.id
  v4_cidr_blocks = ["192.168.30.0/24"]
}

#-------Gateway------#
#resource "yandex_vpc_gateway" "diplom-nat-gateway" {
#  name = "diplom-nat-gateway"
#  shared_egress_gateway {}
#}

#-------Route table------#
resource "yandex_vpc_route_table" "diplom-route-t" {
  name       = "diplom-route-t"
  network_id = yandex_vpc_network.diplom.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.bastion.network_interface.0.ip_address
#    gateway_id         = yandex_vpc_gateway.diplom-nat-gateway.id
  }
}
