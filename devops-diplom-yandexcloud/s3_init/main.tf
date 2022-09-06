terraform {
  backend "local" {}
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.75.0"
    }
  }

}

provider "yandex" {
  token     = var.token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = "ru-central1-a"
}


resource "yandex_iam_service_account" "s3account" {
  folder_id = var.yandex_folder_id
  name      = "s3account"
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.yandex_folder_id
  role      = "storage.editor"
  member    = "serviceAccount:${yandex_iam_service_account.s3account.id}"
}

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.s3account.id
  description        = "static access key for object storage"
}

resource "yandex_storage_bucket" "s3" {
  access_key    = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket        = "s3-tundracode"
  force_destroy = true
}
