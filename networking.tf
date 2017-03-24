// ==============================================
// Main network cr460
// ==============================================
resource "google_compute_network" "cr460" {
  name = "cr460"
  auto_create_subnetworks = "false"
}

// ==============================================
// Public network (web & mgmt)
// ==============================================
resource "google_compute_subnetwork" "public" {
  name = "public"
  ip_cidr_range = "172.16.1.0/24"
  network = "${google_compute_network.cr460.self_link}"
  region  = "us-east1"
}

// ==============================================
// Workload network
// ==============================================
resource "google_compute_subnetwork" "workload" {
  name          = "workload"
  ip_cidr_range = "10.0.1.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

// ==============================================
// Backend network
// ==============================================
resource "google_compute_subnetwork" "backend" {
  name          = "backend"
  ip_cidr_range = "10.0.2.0/24"
  network       = "${google_compute_network.cr460.self_link}"
  region        = "us-east1"
}

// ==============================================
// Firewall public network management
// ==============================================
resource "google_compute_firewall" "public-mgmt" {
  name = "public-mgmt"
  network = "${google_compute_network.cr460.name}"

  // Used for testing connectivity
  //  allow {protocol = "icmp"}

  allow {
    protocol = "tcp"
    ports = ["22"]
    }
    source_ranges = ["0.0.0.0/0"]
    source_tags = ["public-mgmt"]
}

// ==============================================
// Firewall public network web access
// ==============================================
resource "google_compute_firewall" "public-web" {
  name = "public-web"
  network = "${google_compute_network.cr460.name}"

  // Used for testing connectivity
  //  allow {protocol = "icmp"}

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
    }
    source_ranges = ["0.0.0.0/0"]
    source_tags = ["public-web"]
}

// ==============================================
// Firewall workload network management
// ==============================================
resource "google_compute_firewall" "workload-mgmt" {
  name = "workload-mgmt"
  network = "${google_compute_network.cr460.name}"

// Used for testing connectivity
//  allow {protocol = "icmp"}

  allow {
    protocol = "tcp"
    ports = ["22"]
    }
    source_ranges = ["${google_compute_subnetwork.public.ip_cidr_range}"]
    source_tags = ["workload-mgmt"]
}

// ==============================================
// Firewall backend network management
// ==============================================
resource "google_compute_firewall" "backend-mgmt" {
  name = "backend-mgmt"
  network = "${google_compute_network.cr460.name}"

  // Used for testing connectivity
  //  allow {protocol = "icmp"}

  allow {
    protocol = "tcp"
    ports = ["22", "2379", "2380"]
    }
    source_ranges = ["${google_compute_subnetwork.public.ip_cidr_range}", "${google_compute_subnetwork.workload.ip_cidr_range}"]
}

// ==============================================
// DNS record for jumphost
// ==============================================
resource "google_dns_record_set" "jump" {
  name = "jump.aminkazoura.cr460lab.com."
  type = "A"
  ttl  = "300"
  managed_zone = "aminkazoura-cr460"
  rrdatas = ["${google_compute_instance.jumphost.network_interface.0.access_config.0.assigned_nat_ip}"]
}

// ==============================================
// DNS record for vault
// ==============================================

resource "google_dns_record_set" "vault" {
  name = "vault.aminkazoura.cr460lab.com."
  type = "A"
  ttl  = "300"
  managed_zone = "aminkazoura-cr460"
  rrdatas = ["${google_compute_instance.vault.network_interface.0.access_config.0.assigned_nat_ip}"]
}
