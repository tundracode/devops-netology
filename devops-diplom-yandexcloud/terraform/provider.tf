# Provider
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"

  backend "s3" {
    endpoint                    = "storage.yandexcloud.net"
    bucket                      = "s3-tundracode"
    region                      = "ru-central1"
    key                         = "terraform/terraform.tfstate"
    access_key                  = var.yandex_s3_acc_key
    secret_key                  = var.yandex_s3_sec_key
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
}
