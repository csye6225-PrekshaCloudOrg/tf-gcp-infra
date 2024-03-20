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
  default     = ["80", "3000"]
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
