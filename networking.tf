resource "google_compute_network" "cr460" {
  name					          = "cr460"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "east1-dmz" {
  name				  = "east1-dmz"
  ip_cidr_range = "172.16.1.0/24"
  network			  = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_subnetwork" "east1-internal" {
  name          = "east1-internal"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

resource "google_compute_firewall" "web" {
  name = "web"
  network = "${google_compute_network.cr460.name}"

  allow {
    protocol = "tcp"
    ports = ["80"]
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
  name = "ssh"
  network = "${google_compute_network.cr460.name}"

  allow {
    protocol = "tcp"
    ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"]
}

resource "google_dns_record_set" "www" {
  name = "www.aminkazoura.cr460lab.com."
  type = "A"
  ttl  = "300"
  managed_zone = "aminkazoura-cr460"
  rrdatas = ["${google_compute_instance.instance1.network_interface.0.access_config.0.assigned_nat_ip}"]
}
