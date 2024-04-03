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
  count   = var.vpc_count
  name    = "allow-web-traffic-${count.index}"
  network = google_compute_network.vpcnetwork[count.index].self_link

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

# resource "google_compute_subnetwork" "webapp" {
#   count         = var.vpc_count
#   name          = var.subnet_webapp_name[count.index]
#   ip_cidr_range = var.subnet_CIDR_webapp[count.index]
#   region        = var.region
#   network       = google_compute_network.vpcnetwork[count.index].id
# }


# resource "google_compute_subnetwork" "subnet_db" {
#   count                    = var.vpc_count
#   name                     = var.subnet_db_name[count.index]
#   ip_cidr_range            = var.subnet_CIDR_db[count.index]
#   region                   = var.region
#   network                  = google_compute_network.vpcnetwork[count.index].id
#   private_ip_google_access = true

# }

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
  override_special = "!"
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
  password = random_password.password.result
}

resource "google_compute_managed_ssl_certificate" "lb_default" {
  name = "myservice-ssl-cert"
  managed {
    domains = ["preksha.me"]
  }
}

resource "google_service_account" "service_account" {
  account_id   = "csye-preksha"
  display_name = "csye-preksha"
}


resource "google_project_iam_binding" "metricWriter" {
  project = var.project
  role    = var.metricWriter

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "Logging_Admin" {
  project = var.project
  role    = var.Logging_Admin

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_compute_region_instance_template" "vm_template" {
  count                = var.vpc_count
  name                 = "webapp-template"
  description          = "This template is used to create webapp server instances."
  instance_description = "description assigned to instances"
  machine_type         = var.machine_type
  can_ip_forward       = false
  tags                 = ["web-servers"]
  # scheduling {
  #   automatic_restart   = true
  #   on_host_maintenance = "MIGRATE"
  # }
  disk {
    source_image = var.packer_image
    auto_delete  = true
    boot         = true
    disk_size_gb = var.initialize_params_size # Boot disk size in GB
    disk_type    = var.initialize_params_type
  }
  network_interface {
    subnetwork = google_compute_subnetwork.default[count.index].name
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
    INFRA=prod
    INNER_EOF

    # Execute the copy command
    sudo -u csye6225 cp /tmp/.env /tmp/webapp/
  EOF

  service_account {
    email  = google_service_account.service_account.email
    scopes = ["cloud-platform"]
  }
  depends_on = [google_sql_database_instance.instance, google_service_account.service_account]

}


#################### Health Check ####################
resource "google_compute_health_check" "http-health-check" {
  name        = "http-health-check"
  description = "Health check via http"

  timeout_sec         = var.health_check_timeout_sec
  check_interval_sec  = var.health_check_check_interval_sec
  healthy_threshold   = var.health_check_healthy_threshold
  unhealthy_threshold = var.health_check_unhealthy_threshold

  http_health_check {
    port               = var.http_health_check_port
    port_specification = "USE_FIXED_PORT"
    # host               = "1.2.3.4"
    request_path = var.request_path
    response     = ""
  }
  log_config {
    enable = true
  }

}

resource "google_compute_firewall" "health-check" {
  count = var.vpc_count
  name  = "fw-allow-health-check"
  allow {
    protocol = "tcp"
    ports    = var.allowed_ports
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpcnetwork[count.index].id
  priority      = 1000
  source_ranges = var.source_ranges
  target_tags   = ["web-servers"]
}

#################### Autoscaler ####################

resource "google_compute_region_autoscaler" "autoscaler" {
  count  = var.vpc_count
  name   = "my-region-autoscaler"
  region = "us-central1"
  target = google_compute_region_instance_group_manager.appserver[count.index].id

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cooldown_period

    cpu_utilization {
      target = 0.05
    }
  }
}

# #################### Compute Eng Group manager ####################

resource "google_compute_region_instance_group_manager" "appserver" {
  name                      = "appserver-igm"
  count                     = var.vpc_count
  base_instance_name        = "webapp"
  region                    = var.region
  distribution_policy_zones = var.distribution_policy_zones
  version {
    instance_template = google_compute_region_instance_template.vm_template[count.index].self_link
  }

  named_port {
    name = var.group_manager_name
    port = var.group_manager_port
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.http-health-check.id
    initial_delay_sec = 300
  }
}

#################### Load Balancer module ####################

# backend subnet
resource "google_compute_subnetwork" "default" {
  count         = var.vpc_count
  name          = "backend-subnet"
  ip_cidr_range = var.backend_subnet_ip_cidr
  region        = var.region
  # purpose       = "PRIVATE"
  network = google_compute_network.vpcnetwork[count.index].id
  # stack_type    = "IPV4_ONLY"
  private_ip_google_access = true
}

# reserved IP address
resource "google_compute_global_address" "default" {
  # provider = google-beta
  name = "static-address"
}

# forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  count                 = var.vpc_count
  name                  = "l7-xlb-forwarding-rule"
  ip_protocol           = var.ip_protocol
  load_balancing_scheme = var.load_balancing_scheme
  port_range            = var.forwarding_rule_port_range
  target                = google_compute_target_https_proxy.lb_default[count.index].id
  ip_address            = google_compute_global_address.default.id
}


# http proxy
resource "google_compute_target_https_proxy" "lb_default" {
  count = var.vpc_count
  # provider = google-beta
  name    = "myservice-https-proxy"
  url_map = google_compute_url_map.default[count.index].id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.lb_default.name
  ]
  depends_on = [
    google_compute_managed_ssl_certificate.lb_default
  ]
}

# url map
resource "google_compute_url_map" "default" {
  count           = var.vpc_count
  name            = "url-map-regional"
  default_service = google_compute_backend_service.default[count.index].id
}

# backend service with custom request and response headers
resource "google_compute_backend_service" "default" {
  count                 = var.vpc_count
  name                  = "backend-service"
  load_balancing_scheme = var.load_balancing_scheme
  locality_lb_policy    = var.locality_lb_policy
  health_checks         = [google_compute_health_check.http-health-check.id]
  protocol              = var.backend_service_protocol
  session_affinity      = var.session_affinity
  timeout_sec           = var.timeout_sec
  backend {
    group           = google_compute_region_instance_group_manager.appserver[count.index].instance_group
    balancing_mode  = var.balancing_mode
    capacity_scaler = 1.0
  }
  log_config {
    enable = true
  }
}

#################### DNS ####################
resource "google_dns_record_set" "frontend" {
  count        = var.vpc_count
  name         = var.domain_name
  type         = var.dns_type
  ttl          = var.dns_ttl
  managed_zone = var.managed_zone
  rrdatas      = [google_compute_global_address.default.address]
  depends_on   = [google_compute_backend_service.default]
}


#################### PUB/SUB - TOPIC ####################

resource "google_pubsub_topic" "verify_email" {
  name = var.pubsub_topic

  labels = {
    foo = "bar"
  }
  message_retention_duration = var.retention_time
}

resource "google_pubsub_topic_iam_binding" "binding" {
  project = var.project
  topic   = google_pubsub_topic.verify_email.name
  role    = var.pubsub_publisher
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}


#################### CLOUD FUNCTION ####################

resource "random_id" "bucket_suffix" {
  byte_length = 8
}
resource "google_storage_bucket" "bucket" {
  name     = "csye-webapp-${random_id.bucket_suffix.hex}"
  location = var.bucket_location
}

data "archive_file" "default" {
  type        = "zip"
  output_path = var.archive_file_output
  source_dir  = var.archive_file_input
}

resource "google_storage_bucket_object" "archive" {
  name   = var.archive_file_name
  bucket = google_storage_bucket.bucket.name
  source = data.archive_file.default.output_path
}

resource "google_vpc_access_connector" "connector2" {
  count         = var.vpc_count
  name          = "connector2"
  ip_cidr_range = var.vpc_connector_ip_CIDR
  network       = google_compute_network.vpcnetwork[count.index].self_link
}

resource "google_cloudfunctions_function" "function" {
  count                 = var.vpc_count
  name                  = var.cloud_function_name
  description           = "My function triggered by Pub/Sub"
  runtime               = var.cloud_function_runtime
  available_memory_mb   = var.cloud_function_memory
  timeout               = var.cloud_function_timeout
  entry_point           = var.cloud_function_entry_point
  vpc_connector         = "projects/dev-gcp-414600/locations/us-central1/connectors/connector2"
  source_archive_bucket = google_storage_bucket.bucket.name
  source_archive_object = google_storage_bucket_object.archive.name

  event_trigger {
    event_type = var.cloud_function_event_type
    resource   = google_pubsub_topic.verify_email.id
    failure_policy {
      retry = true
    }
  }

  environment_variables = {
    DB_USERNAME     = google_sql_user.users[count.index].name,
    DB_PASSWORD     = google_sql_user.users[count.index].password,
    DB_HOST         = google_sql_database_instance.instance[count.index].private_ip_address,
    DB_NAME         = google_sql_database.database[count.index].name,
    MAILGUN_API_KEY = var.MAILGUN_API_KEY
  }
  depends_on = [google_vpc_access_connector.connector2]
}

resource "google_cloudfunctions_function_iam_binding" "binding" {
  count          = var.vpc_count
  project        = google_cloudfunctions_function.function[count.index].project
  region         = google_cloudfunctions_function.function[count.index].region
  cloud_function = google_cloudfunctions_function.function[count.index].name
  role           = var.cloud_function_role
  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

