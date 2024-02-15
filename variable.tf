variable "project" {
  description = "Project name in gcp"
  type        = string
}

variable "region" {
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
