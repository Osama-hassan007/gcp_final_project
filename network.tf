#------------------------------------------------VPC----------------------------
resource "google_compute_network" "vpc_network" {
  name = "osama-vpc"
  auto_create_subnetworks = false
}
#-----------------------------------------------Subnets----------------------------
resource "google_compute_subnetwork" "Management-Subnet" {
  name          = "management-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "Restricted-Subnet" {
  name          = "restricted-subnet"
  ip_cidr_range = "10.1.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.self_link
}
#-----------------------------------------------cloud router---------------------------

resource "google_compute_router" "router" {
  name    = "osama-router"
  region  = google_compute_subnetwork.Management-Subnet.region
  network = google_compute_network.vpc_network.self_link
}

#-----------------------------------------------Nat-----------------------------------

resource "google_compute_router_nat" "nat" {
  name                               = "osama-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.Management-Subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}
#-----------------------------------------------Firewall---------------------------
resource "google_compute_firewall" "bastion-ssh" {
  name          = "osama-ssh-firewall"
  network       = google_compute_network.vpc_network.self_link
  direction     = "INGRESS"
  
  source_ranges = ["0.0.0.0/0"] 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]
}
