#-------SNAPSHOTS------#
resource "yandex_compute_snapshot_schedule" "snap" {
  name = "snap"

  schedule_policy {
	expression = "0 2 * * *"
  }
  
  retention_period = "168h"


  snapshot_spec {
	  description = "diplom-snapshot"
  }

  disk_ids = [  yandex_compute_instance.webserver1.boot_disk[0].device_name,
                yandex_compute_instance.webserver2.boot_disk[0].device_name,
                yandex_compute_instance.elasticsearch.boot_disk[0].device_name,
                yandex_compute_instance.kibana.boot_disk[0].device_name,
                yandex_compute_instance.grafana.boot_disk[0].device_name,
                yandex_compute_instance.prometheus.boot_disk[0].device_name,
                yandex_compute_instance.bastion.boot_disk[0].device_name
              ]
}