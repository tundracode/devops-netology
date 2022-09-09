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
  name = "network1"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "subnet"
  network_id     = resource.yandex_vpc_network.net.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1-count" {
  count = local.instance_count[terraform.workspace]
  name  = "${terraform.workspace}-count-${count.index}"

  resources {
    cores  = local.vm_cores[terraform.workspace]
    memory = local.vm_memory[terraform.workspace]
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_compute_instance" "vm-1-fe" {

  for_each = local.vm_foreach[terraform.workspace]
  name     = "${terraform.workspace}-foreach-${each.key}"

  resources {
    cores  = each.value.cores
    memory = each.value.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  instance_count = {
    "prod"  = 2
    "stage" = 1
  }
  vm_cores = {
    "prod"  = 2
    "stage" = 1
  }
  vm_memory = {
    "prod"  = 2
    "stage" = 1
  }
  vm_foreach = {
    prod = {
      "3" = { cores = "2", memory = "2" },
      "2" = { cores = "2", memory = "2" }
    }
    stage = {
      "1" = { cores = "1", memory = "1" }
    }
  }
}