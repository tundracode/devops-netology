output "yandex_zone" {
  value       = yandex_compute_instance.vm.zone
  description = "Регион Яндекса, в котором создан инстанс"
}

output "yandex_ip_private" {
  value       = yandex_compute_instance.vm.network_interface.0.ip_address
  description = "Приватный IP на Яндексе"
}

output "yandex_vpc_subnet" {
  value       = resource.yandex_vpc_subnet.subnet.id
  description = "Идентификатор подсети в которой создан инстанс"
}