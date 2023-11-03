
#-------TARGET-GROUP------#
resource "yandex_alb_target_group" "diplom-tg" {
  name            = "diplom-tg"

  target {
    subnet_id     = yandex_vpc_subnet.subnet1.id
    ip_address    = yandex_compute_instance.webserver1.network_interface.0.ip_address
  }

  target {
    subnet_id     = yandex_vpc_subnet.subnet2.id
    ip_address    = yandex_compute_instance.webserver2.network_interface.0.ip_address
  }
}

#-------BACKEND-GROUP------#
resource "yandex_alb_backend_group" "diplom-bg" {
  name                = "diplom-bg"

  http_backend {
    name              = "http-diplom-bg"
    target_group_ids  = ["${yandex_alb_target_group.diplom-tg.id}"]
    port              = 80
    healthcheck {
      timeout         = "1s"
      interval        = "1s"
      http_healthcheck {
        path          = "/"
      }
    }
  }
}

#-------HTTP-ROUTER------#
resource "yandex_alb_http_router" "diplom-router" {
  name                    = "diplom-router"
}

#-------VIRTUAL-HOST------#
resource "yandex_alb_virtual_host" "diplom-host" {
  name                    = "diplom-host"
  http_router_id          = yandex_alb_http_router.diplom-router.id
  route {
    name                  = "diplom-route-1"
    http_route {
      http_match {
        path {
          prefix          = "/"
        }
      }       
      http_route_action {
        backend_group_id  = yandex_alb_backend_group.diplom-bg.id
      }
    }
  }
}

#-------L7-LOAD-BALANCER------#

resource "yandex_alb_load_balancer" "diplom-lb" {
  name                    = "diplom-lb"
  network_id              = yandex_vpc_network.diplom.id
  security_group_ids      = [yandex_vpc_security_group.inner-sg.id, yandex_vpc_security_group.balancer-sg.id]  

  allocation_policy {
    location {
      zone_id             = "ru-central1-a"
      subnet_id           = yandex_vpc_subnet.subnet1.id
    }

    location {
      zone_id             = "ru-central1-b"
      subnet_id           = yandex_vpc_subnet.subnet2.id
    }
  }

  listener {
    name                  = "diplom-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports               = [ "80" ]
    }
    http {
      handler {
        http_router_id    = yandex_alb_http_router.diplom-router.id
      }
    }
  }
}