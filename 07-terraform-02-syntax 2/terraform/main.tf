provider "yandex" {
  token     = "..."
  cloud_id  = "b1g72svo67706rdk1ego"
  folder_id = "b1go323tfuedmc7ac54e"
  zone      = "ru-central1-a"
}

data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2004-lts"
}

resource "yandex_vpc_network" "net" {
  name = "net"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["10.2.0.0/16"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "vm" {
  name        = "tundracode"
  hostname    = "tundracode.local"
  platform_id = "standard-v1"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      type     = "network-hdd"
      size     = "20"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
    ipv6      = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}