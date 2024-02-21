variable "project" {
  description = "Project name in gcp"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

variable "routing_mode"{
  description = "routing_mode"
  type = string
  default = "REGIONAL" 
}

variable "auto_create_subnetworks" {
  description = "auto_create_subnetworks"
  type = bool
  default = false 
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