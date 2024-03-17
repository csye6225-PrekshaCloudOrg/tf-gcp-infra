resource "google_compute_network" "vpcnetwork" {
  count                           = var.vpc_count
  project                         = var.project
  name                            = var.vpc_names[count.index]
  auto_create_subnetworks         = var.auto_create_subnetworks
  mtu                             = 1460
  routing_mode                    = var.routing_mode
  delete_default_routes_on_create = true
}

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
  priority      = var.allow_priority
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

resource "google_compute_subnetwork" "webapp" {
  count         = var.vpc_count
  name          = var.subnet_webapp_name[count.index]
  ip_cidr_range = var.subnet_CIDR_webapp[count.index]
  region        = var.region
  network       = google_compute_network.vpcnetwork[count.index].id
}


resource "google_compute_subnetwork" "subnet_db" {
  count                    = var.vpc_count
  name                     = var.subnet_db_name[count.index]
  ip_cidr_range            = var.subnet_CIDR_db[count.index]
  region                   = var.region
  network                  = google_compute_network.vpcnetwork[count.index].id
  private_ip_google_access = true

}

resource "google_compute_global_address" "private_ip_address" {
  count         = var.vpc_count
  name          = "private-ip-address"
  purpose       = var.private_ip_address_purpose
  address_type  = var.private_ip_address_type
  prefix_length = var.private_ip_address_prefix_length
  network       = google_compute_network.vpcnetwork[count.index].id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  count                   = var.vpc_count
  network                 = google_compute_network.vpcnetwork[count.index].id
  service                 = var.service_name
  reserved_peering_ranges = [google_compute_global_address.private_ip_address[count.index].name]
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

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "instance" {
  count            = var.vpc_count
  name             = "private-instance-${random_id.db_name_suffix.hex}"
  region           = var.region
  database_version = var.database_version
  depends_on       = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_type         = var.disk_type
    disk_size         = var.disk_size
    disk_autoresize   = true
    ip_configuration {
      ipv4_enabled    = var.ipv4_enabled
      private_network = google_compute_network.vpcnetwork[count.index].id
    }
  }
  deletion_protection = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_database" "database" {
  count    = var.vpc_count
  name     = var.database_name
  instance = google_sql_database_instance.instance[count.index].name
}


resource "google_sql_user" "users" {
  count    = var.vpc_count
  name     = var.user_name
  instance = google_sql_database_instance.instance[count.index].name
  password = "password"
}

resource "google_service_account" "service_account" {
  account_id   = "csye-preksha"
  display_name = "csye-preksha"
}


resource "google_project_iam_binding" "metricWriter" {
  project = var.project
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "Logging_Admin" {
  project = var.project
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}



# Define Compute Engine instance
resource "google_compute_instance" "my_instance" {
  count        = var.vpc_count
  name         = var.my_instance_name[count.index]
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["webapp"]
  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Retrieve the SQL instance IP address and store it in .env
    cat <<INNER_EOF > /tmp/.env
    DB_USERNAME=${google_sql_user.users[count.index].name}
    DB_PASSWORD=${google_sql_user.users[count.index].password}
    DB_HOST=${google_sql_database_instance.instance[count.index].private_ip_address}
    DB_NAME=${google_sql_database.database[count.index].name}
    PORT=8080
    INNER_EOF

    # Execute the copy command
    sudo -u csye6225 cp /tmp/.env /tmp/webapp/
  EOF

  boot_disk {
    initialize_params {
      image = var.packer_image           # Custom image name
      size  = var.initialize_params_size # Boot disk size in GB
      type  = var.initialize_params_type # Boot disk type
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.webapp[count.index].name
    access_config {}
  }

  depends_on = [google_compute_subnetwork.webapp, google_sql_database_instance.instance, google_service_account.service_account]
}


resource "google_dns_record_set" "frontend" {
  count        = var.vpc_count
  name = "preksha.me."
  type = "A"
  ttl  = 21600
  managed_zone = "webapp-zone"
  rrdatas      = [google_compute_instance.my_instance[count.index].network_interface[0].access_config[0].nat_ip]
  depends_on = [google_compute_instance.my_instance]

}