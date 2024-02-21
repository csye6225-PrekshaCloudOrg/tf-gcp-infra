resource "google_compute_network" "vpcnetwork" {
  count                           = var.vpc_count
  project                         = var.project
  name                            = var.vpc_names[count.index]
  auto_create_subnetworks         = var.auto_create_subnetworks
  mtu                             = 1460
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  count         = var.vpc_count
  name          = var.subnet_webapp_name[count.index]
  ip_cidr_range = var.subnet_CIDR_webapp[count.index]
  region        = var.region
  network       = google_compute_network.vpcnetwork[count.index].id
}


resource "google_compute_subnetwork" "subnet_db" {
  count         = var.vpc_count
  name          = var.subnet_db_name[count.index]
  ip_cidr_range = var.subnet_CIDR_db[count.index]
  region        = var.region
  network       = google_compute_network.vpcnetwork[count.index].id
}

resource "google_compute_route" "webapp_route" {
  count            = var.vpc_count
  name             = "${var.webapp_route}-${count.index + 1}"
  network          = google_compute_network.vpcnetwork[count.index].self_link
  dest_range       = "0.0.0.0/0"
  next_hop_gateway = "global/gateways/default-internet-gateway"
  priority         = 1000
  tags             = ["webapp"]
}

# Define firewall rule
resource "google_compute_firewall" "allow_web_traffic" {
  count       = var.vpc_count
  name        = "allow-web-traffic-${count.index}"
  network     = google_compute_network.vpcnetwork[count.index].self_link
  target_tags = ["webapp"]
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = var.allow_protocol
    ports    = var.allowed_ports
  }
  source_ranges = ["0.0.0.0/0"]
  priority = var.allow_priority
}

resource "google_compute_firewall" "deny_all_traffic" {
  count       = var.vpc_count
  name        = "deny-all-traffic-${count.index}"
  network     = google_compute_network.vpcnetwork[count.index].self_link
  target_tags = ["webapp"]

  deny {
    protocol = var.deny_protocol
  }

  source_ranges = ["0.0.0.0/0"]

  priority = var.deny_priority
}

# Define Compute Engine instance
resource "google_compute_instance" "my_instance" {
  count        = var.vpc_count
  name         = var.my_instance_name[count.index]
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["webapp"]
  boot_disk {
    initialize_params {
      image = var.packer_image           # Custom image name
      size  = var.initialize_params_size # Boot disk size in GB
      type  = var.initialize_params_type # Boot disk type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.webapp[count.index].name
    access_config {
    }
  }
  depends_on = [google_compute_subnetwork.webapp]
}
