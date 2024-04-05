resource "google_compute_instance" "nginx-vm" {
  name         = "nginx-vm-${local.rid}"
  machine_type = "n2-standard-8"
  tags         = ["http-server", "syslog-${local.rid}"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2310-amd64"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    ssh-keys  = "ubuntu:${file("${var.ssh_pub_key}")}"
    user-data = file("user-data.yaml")
  }
}

# resource "google_compute_firewall" "syslog" {
#   name    = "syslog-${local.rid}"
#   network = "default"

#   allow {
#     protocol = "tcp"
#     ports    = ["514"]
#   }

#   source_ranges = ["0.0.0.0/0"]

#   target_tags = ["syslog-${local.rid}"]
# }

resource "fastly_service_vcl" "front-nginx" {
  name = "front nginx"

  domain {
    name = "front-nginx-${local.rid}.global.ssl.fastly.net"
  }

  backend {
    address = google_compute_instance.nginx-vm.network_interface.0.access_config.0.nat_ip
    name    = "nginx-vm"
    port    = 80
    use_ssl = "false"
    # shield  = "atlanta-ga-us"
  }

  # logging_syslog {
  #   name    = "nginx-vm"
  #   address = google_compute_instance.nginx-vm.network_interface.0.access_config.0.nat_ip
  # }

  force_destroy = true
}