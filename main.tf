provider "google" {
  project     = var.project_name
  region      = var.region_name
  zone        = var.zone_name
}
resource "google_compute_instance" "cribl_master" {
  name         = "cribl-master"
  machine_type = var.machine_size

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  metadata = {
    ssh-keys = "${var.username}:${file(var.public_key_path)}"
  }
  provisioner "remote-exec" {
    script = var.script_path

    connection {
      type        = "ssh"
      host        = google_compute_address.static.address
      user        = var.username
      private_key = file(var.private_key_path)
    }
  }
}
# resource "google_compute_instance" "cribl_worker_01" {
#   name         = "cribl-worker-1"
#   machine_type = var.machine_size

#   boot_disk {
#     initialize_params {
#       image = var.image_name
#     }
#   }

#   network_interface {
#     # A default network is created for all GCP projects
#     network = "default"
#     access_config {
#       nat_ip = google_compute_address.static.address
#     }
#   }
#   provisioner "remote-exec" {
#     script = var.script_path

#     connection {
#       type        = "ssh"
#       host        = google_compute_address.static.address
#       user        = var.username
#       private_key = file(var.private_key_path)
#     }
#   }
# }

# resource "google_compute_instance" "cribl_worker_02" {
#   name         = "cribl-worker-2"
#   machine_type = var.machine_size

#   boot_disk {
#     initialize_params {
#       image = var.image_name
#     }
#   }

#   network_interface {
#     # A default network is created for all GCP projects
#     network = "default"
#     access_config {
#       nat_ip = google_compute_address.static.address
#     }
#   }
#   provisioner "remote-exec" {
#     script = var.script_path

#     connection {
#       type        = "ssh"
#       host        = google_compute_address.static.address
#       user        = var.username
#       private_key = file(var.private_key_path)
#     }
#   }
# }
resource "google_compute_address" "static" {
   name = "vm-public-address"
 }