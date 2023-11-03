#-------Web1------#
resource "yandex_compute_instance" "webserver1" {
  name                  = "webserver1"
  zone                  = "ru-central1-a"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet1.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id]
    ip_address          = "192.168.10.25" 
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-webs1.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}
 
#-------Web2------#
resource "yandex_compute_instance" "webserver2" {
  name                  = "webserver2"
  zone                  = "ru-central1-b"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet2.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id] 
    ip_address          = "192.168.20.25"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-webs2.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}

#-------Elastic------#
resource "yandex_compute_instance" "elasticsearch" {
  name                  = "elasticsearch"
  zone                  = "ru-central1-b"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
      size              = 10      
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet2.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.logs-sg.id] 
    ip_address          = "192.168.20.10"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-elasticsearch.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}

#-------Kibana------#
resource "yandex_compute_instance" "kibana" {
  name                  = "kibana"
  zone                  = "ru-central1-a"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
      size              = 10
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet1.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.logs-sg.id] 
    ip_address          = "192.168.10.10"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-kibana.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}

#-------Grafana------#
resource "yandex_compute_instance" "grafana" {
  name                  = "grafana"
  zone                  = "ru-central1-a"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
      size              = 10      
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet1.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.monit-sg.id]
    ip_address          = "192.168.10.15"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-grafana.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}

#-------Prometheus------#
resource "yandex_compute_instance" "prometheus" {
  name                  = "prometheus"
  zone                  = "ru-central1-b"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
      size              = 10      
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet2.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.monit-sg.id]
    ip_address          = "192.168.20.15"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-prometheus.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}

#-------Bastion------#
resource "yandex_compute_instance" "bastion" {
  name                  = "bastion"
  zone                  = "ru-central1-c"

  resources {
    cores               = 2
    memory              = 2
  }

  boot_disk {
    initialize_params {
      image_id          = "fd8a67rb91j689dqp60h"
      size              = 10      
    }
  }

  network_interface {
    subnet_id           = "${yandex_vpc_subnet.subnet3.id}"
    security_group_ids  = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.bastion-sg.id] 
    ip_address          = "192.168.30.30"
    nat                 = true
  }
  
  metadata = {
    user-data           = "${file("./meta-bastion.yaml")}"
  }

  scheduling_policy {
    preemptible         = true
  }  
}