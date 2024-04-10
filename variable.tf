variable "project" {
  description = "Project name in gcp"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "routing_mode" {
  description = "routing_mode"
  type        = string
  default     = "REGIONAL"
}

variable "auto_create_subnetworks" {
  description = "auto_create_subnetworks"
  type        = bool
  default     = false
}

variable "zone" {
  description = "Region"
  type        = string
}


variable "vpc_count" {
  description = "Count of the vpc"
  type        = number
}
variable "vpc_names" {
  description = "List of VPC network names"
  type        = list(string)
}

variable "subnet_CIDR_webapp" {
  description = "List of CIDR range"
  type        = list(string)
}

variable "subnet_CIDR_db" {
  description = "List of CIDR range"
  type        = list(string)
}

variable "webapp_route" {
  description = "webapp-route"
  type        = string
}

variable "subnet_webapp_name" {
  description = "List of CIDR range"
  type        = list(string)
}

variable "subnet_db_name" {
  description = "List of CIDR range"
  type        = list(string)
}

variable "firewall_name" {
  description = "Name of the firewall"
  type        = list(string)
}

variable "webapp_port" {
  description = "The port to which the webapp is listening to"
  type        = number

}

variable "my_instance_name" {
  description = "Instance name"
  type        = list(string)
}

variable "machine_type" {
  description = "machine type"
  type        = string
}

variable "initialize_params_type" {
  description = "Packe image id"
  type        = string
  default     = "pd-balanced"
}

variable "packer_image" {
  description = "Packe image id"
  type        = string
}

variable "initialize_params_size" {
  description = "Count of the vpc"
  type        = string
  default     = "100"
}

variable "allowed_ports" {
  description = "List of allowed ports"
  type        = list(string)
  default     = ["80", "443", "3000"]
}

variable "deny_priority" {
  description = "Priority for the deny-all-traffic firewall rule"
  type        = number
  default     = 1200
}

variable "allow_priority" {
  description = "Priority for the deny-all-traffic firewall rule"
  type        = number
  default     = 1000
}

variable "allow_protocol" {
  description = "allow protocol"
  type        = string
  default     = "tcp"
}

variable "deny_protocol" {
  description = "deny_protocol"
  type        = string
  default     = "all"
}

variable "database_instance_name" {
  description = "Name of the Cloud SQL database instance"
  type        = list(string)
  default     = ["my-cloud-sql-instance"]
}

// Cloud SQL variables

variable "private_ip_address_purpose" {
  description = "Purpose of the private IP address"
  type        = string
  default     = "VPC_PEERING"
}

variable "private_ip_address_type" {
  description = "Type of the private IP address"
  type        = string
  default     = "INTERNAL"
}

variable "private_ip_address_prefix_length" {
  description = "Prefix length of the private IP address"
  type        = number
  default     = 16
}

variable "service_name" {
  description = "Name of the service"
  type        = string
  default     = "servicenetworking.googleapis.com"
}

variable "database_version" {
  description = "Database version for the SQL database instance"
  type        = string
  default     = "POSTGRES_15"
}

variable "tier" {
  description = "Tier for the SQL database instance"
  type        = string
  default     = "db-f1-micro"
}

variable "availability_type" {
  description = "Availability type for the SQL database instance"
  type        = string
  default     = "REGIONAL"
}

variable "disk_type" {
  description = "Disk type for the SQL database instance"
  type        = string
  default     = "pd-ssd"
}

variable "disk_size" {
  description = "Disk size for the SQL database instance"
  default     = "100"
}

variable "ipv4_enabled" {
  description = "Enable IPv4 for the SQL database instance"
  type        = bool
  default     = false
}

// Database reletaed variables 

variable "database_name" {
  description = "Name of the SQL database"
  type        = string
  default     = "webapp"
}

variable "user_name" {
  description = "Name of the SQL user"
  type        = string
  default     = "webapp"
}

variable "domain_name" {
  description = "Name of the domain"
  type        = string
  default     = "preksha.me."
}

variable "dns_type" {
  description = "Name of the domain"
  type        = string
  default     = "A"
}

variable "dns_ttl" {
  description = "dns ttl"
  type        = number
  default     = 21600
}

variable "managed_zone" {
  description = "managed_zone"
  type        = string
  default     = "webapp-zone"
}

variable "metricWriter" {
  description = "metricWriter"
  type        = string
  default     = "roles/monitoring.metricWriter"
}

variable "Logging_Admin" {
  description = "Logging_Admin"
  type        = string
  default     = "roles/logging.admin"
}

variable "cloud_platform_scope" {
  description = "The scope for the service account, such as 'cloud-platform'."
  type        = string
  default     = "cloud-platform"
}

variable "MAILGUN_API_KEY" {
  description = "MailGun Key"
  type        = string
  default     = "da7fe0d397af5ac2359eb405342fc970-309b0ef4-e0e7008f"
}

variable "pubsub_topic" {
  description = "pubsub topic"
  type        = string
  default     = "verify_email"
}

variable "retention_time" {
  description = "retention_time"
  type        = string
  default     = "604800s"
}

variable "pubsub_publisher" {
  description = "pubsub.publisher"
  type        = string
  default     = "roles/pubsub.publisher"
}


variable "bucket_location" {
  description = "pubsub location"
  type        = string
  default     = "us-central1"
}

variable "archive_file_output" {
  description = "archive_file"
  type        = string
  default     = "/tmp/function-source.zip"
}

variable "archive_file_input" {
  description = "archive_file"
  type        = string
  default     = "D:/MS-IS/Cloud/Spring-24Assignments/Workspace/nodejs-docs-samples/functions/v2/helloPubSub"
}

variable "archive_file_name" {
  description = "archive_file"
  type        = string
  default     = "function-source.zip"
}

variable "cloud_function_name" {
  description = "cloud_function_name"
  type        = string
  default     = "function-email"
}

variable "cloud_function_runtime" {
  description = "cloud_function_runtime"
  type        = string
  default     = "nodejs16"
}

variable "cloud_function_memory" {
  description = "cloud_function_memory"
  type        = number
  default     = 128
}

variable "cloud_function_timeout" {
  description = "cloud_function_timeout"
  type        = number
  default     = 60
}

variable "cloud_function_entry_point" {
  description = "cloud_function_entry_point"
  type        = string
  default     = "subscribeMessage"
}

variable "cloud_function_event_type" {
  description = "cloud_function_event_type"
  type        = string
  default     = "google.pubsub.topic.publish"
}

variable "cloud_function_role" {
  description = "cloud_function_role"
  type        = string
  default     = "roles/viewer"
}

variable "connector_name" {
  description = "Name of the VPC Network Connector in GCP"
  type        = string
  default     = "vpc_conn"
}

variable "vpc_connector_path" {
  description = "Name of the VPC Network Connector in GCP"
  type        = string
  default     = "projects/dev-gcp-414600/locations/us-central1/connectors/connector"
}

variable "vpc_connector_ip_CIDR" {
  description = "Name of the VPC Network Connector in GCP"
  type        = string
  default     = "10.8.0.0/28"
}

variable "load_balancing_scheme" {
  description = "load_balancing_scheme"
  type        = string
  default     = "EXTERNAL_MANAGED"
}

variable "locality_lb_policy" {
  description = "locality_lb_policy"
  type        = string
  default     = "ROUND_ROBIN"
}

variable "backend_service_protocol" {
  description = "backend_service_protocol"
  type        = string
  default     = "HTTP"
}

variable "timeout_sec" {
  description = "timeout_sec"
  type        = number
  default     = 30
}

variable "balancing_mode" {
  description = "balancing_mode"
  type        = string
  default     = "UTILIZATION"
}

variable "session_affinity" {
  description = "session_affinity"
  type        = string
  default     = "NONE"
}

variable "forwarding_rule_port_range" {
  description = "forwarding_rule_port_range"
  type        = string
  default     = "443"
}

variable "ip_protocol" {
  description = "ip_protocol"
  type        = string
  default     = "TCP"
}

variable "backend_subnet_ip_cidr" {
  description = "backend-subnet-ip-cidr"
  type        = string
  default     = "10.1.2.0/24"
}

variable "group_manager_name" {
  description = "group_manager_name"
  type        = string
  default     = "http"
}

variable "group_manager_port" {
  description = "group_manager_port"
  type        = number
  default     = 3000
}

variable "distribution_policy_zones" {
  type        = list(string)
  default     = ["us-central1-a", "us-central1-f"]
  description = "distribution_policy_zones"
}

variable "max_replicas" {
  description = "max_replicas"
  type        = number
  default     = 2
}

variable "min_replicas" {
  description = "min_replicas"
  type        = number
  default     = 1
}

variable "cooldown_period" {
  description = "cooldown_period"
  type        = number
  default     = 60
}

variable "cpu_utilization_target" {
  description = "cpu_utilization_target"
  type        = number
  default     = 0.05
}

variable "source_ranges" {
  type        = list(string)
  default     = ["130.211.0.0/22", "35.191.0.0/16"]
  description = "source_ranges"
}

variable "health_check_timeout_sec" {
  description = "health_check_timeout_sec"
  type        = number
  default     = 1
}
variable "health_check_check_interval_sec" {
  description = "health_check_interval_sec"
  type        = number
  default     = 1
}

variable "health_check_healthy_threshold" {
  description = "health_check_healthy_threshold"
  type        = number
  default     = 4
}

variable "health_check_unhealthy_threshold" {
  description = "health_check_healthy_threshold"
  type        = number
  default     = 4
}


variable "http_health_check_port" {
  description = "group_manager_port"
  type        = number
  default     = 3000
}

variable "request_path" {
  description = "/healthz"
  type        = string
  default     = "/healthz"
}

variable "key_name" {
  description = "Name of the KMS key"
  type = string
  default = "key-vm"
}

variable "keyring_name" {
  description = "Name of the KMS Keyring"
  type = string
  default = "key-ring-name1-v5"
}

variable "algorithm" {
  description = "Algorithm for the KMS key"
  type = string
  default = "GOOGLE_SYMMETRIC_ENCRYPTION"
}

variable "rotation_period" {
  description = "Time in seconds to rotate key"
  type = string
  default = "2592000s"
}

variable "google_kms_key_ring" {
  description = "google_kms_key_ring"
  type = string
  default = "my-key-ring-v2"
}