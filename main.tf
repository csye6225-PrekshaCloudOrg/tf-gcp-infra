resource "google_compute_network" "vpcnetwork" {
  count                           = var.vpc_count
  project                         = var.project
  name                            = var.vpc_names[count.index]
  auto_create_subnetworks         = false
  mtu                             = 1460
  routing_mode                    = "REGIONAL"
  delete_default_routes_on_create = true
}

resource "google_compute_subnetwork" "webapp" {
  count         = var.vpc_count
  name          =  var.subnet_webapp_name[count.index]
  ip_cidr_range = var.subnet_CIDR_webapp[count.index]
  region        = var.region
  network       = google_compute_network.vpcnetwork[count.index].id
}


resource "google_compute_subnetwork" "subnet_db" {
  count         = var.vpc_count
  name          =  var.subnet_db_name[count.index]
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