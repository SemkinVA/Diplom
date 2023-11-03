terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}
provider "yandex" {
  token     = "y0_AgAAAAABrtz7AATuwQAAAADvonraLRm6iO3aTcetalI1IDxyPphIAAo"
  cloud_id  = "b1gp9h3u6teudun3llvb"
  folder_id = "b1gthjthrl0bctlhqing"
} 
