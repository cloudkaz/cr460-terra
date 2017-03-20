resource "google_compute_instance" "instance1" {
name          = "instance1"
machine_type  = "f1-micro"
zone          = "us-east1-b"

disk {
  image = "debian-cloud/debian-8"
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.east1-dmz.name}"
  access_config {}
}

metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
}
