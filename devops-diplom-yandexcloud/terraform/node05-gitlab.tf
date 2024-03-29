resource "yandex_compute_instance" "node05gitlab" {
  name                      = "node05gitlab"
  zone                      = "ru-central1-a"
  hostname                  = "gitlab.${var.my_domain}"
  platform_id               = "standard-v2"
  allow_stopping_for_update = true

  resources {
    cores         = 4
    memory        = 8
    
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu-latest
      name     = "root-node05gitlab"
      type     = "network-nvme"
      size     = "10"
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.priv-subnet.id
    #    nat       = true
    ip_address = "192.168.101.15"
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

