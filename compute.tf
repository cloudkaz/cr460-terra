// ==============================================
// Instance: jumphost debian-8 on public subnetwork
// ==============================================
resource "google_compute_instance" "jumphost" {
name          = "jumphost"
machine_type  = "f1-micro"
zone          = "us-east1-b"
tags          = ["public-mgmt"]

disk {
  image = "debian-cloud/debian-8"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.public.name}"
  access_config {}
    }
}

// ==============================================
// Instance: Vault CoreOS/apache2 on public subnetwork
// ==============================================
resource "google_compute_instance" "vault" {
name          = "vault"
machine_type  = "f1-micro"
zone          = "us-east1-b"
tags          = ["public-web"]

disk {
  image = "coreos-cloud/coreos-stable"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.public.name}"
  access_config {}
    }

metadata_startup_script = "apt-get -y install apache2 && systemctl start apache2"
}

// ==============================================
// Instance: Master CoreOS on backend subnetwork
// ==============================================
resource "google_compute_instance" "master" {
name          = "master"
machine_type  = "f1-micro"
zone          = "us-east1-b"
// tags          = ["workload-mgmt"]

disk {
  image = "coreos-cloud/coreos-stable"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

// ==============================================
// Instance: etcd1 CoreOS on backend subnetwork
// ==============================================
resource "google_compute_instance" "etcd1" {
name          = "etcd1"
machine_type  = "f1-micro"
zone          = "us-east1-b"
// tags          = ["backend-mgmt"]

disk {
  image = "coreos-cloud/coreos-stable"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

// ==============================================
// Instance: etcd2 CoreOS on backend subnetwork
// ==============================================
resource "google_compute_instance" "etcd2" {
name          = "etcd2"
machine_type  = "f1-micro"
zone          = "us-east1-b"
// tags          = ["backend-mgmt"]

disk {
  image = "coreos-cloud/coreos-stable"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

// ==============================================
// Instance: etcd3 CoreOS on backend subnetwork
// ==============================================
resource "google_compute_instance" "etcd3" {
name          = "etcd3"
machine_type  = "f1-micro"
zone          = "us-east1-b"
// tags          = ["backend-mgmt"]

disk {
  image = "coreos-cloud/coreos-stable"
  auto_delete = true
     }

network_interface {
  subnetwork = "${google_compute_subnetwork.backend.name}"
    }
}

// ==============================================
// Worker instance template
// ==============================================
resource "google_compute_instance_template" "worker-template" {
  name           = "worker-template"
  description    = "worker instance template"
  machine_type   = "f1-micro"
  can_ip_forward = false
//  tags           = ["workload-mgmt"]

  disk {
    source_image = "coreos-cloud/coreos-stable"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    subnetwork = "${google_compute_subnetwork.workload.name}"
  }
}

// ==============================================
// Instance group manager
// ==============================================
resource "google_compute_instance_group_manager" "group-manager" {
  name        = "group-manager"
  description = "Workker instance group manager"
  base_instance_name = "worker"
  instance_template  = "${google_compute_instance_template.worker-template.self_link}"
  zone               = "us-east1-b"
}

// ==============================================
// Instance autoscaler
// ==============================================
resource "google_compute_autoscaler" "autoscaler" {
  name   = "autoscaler"
  zone   = "us-east1-b"
  target = "${google_compute_instance_group_manager.group-manager.self_link}"

  autoscaling_policy = {
    max_replicas    = 5
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.5
    }
  }
}
