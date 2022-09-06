output "service_account_id" {
  description        = "3s service account id"
  value = yandex_iam_service_account.s3account.id
}

output "access_key" {
  description        = "static access key for object storage"
  value = yandex_iam_service_account_static_access_key.sa-static-key.access_key
}

output "secret_key" {
  description        = "static secret key for object storage"
  value = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive = true
}



