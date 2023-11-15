module "gcp-network" {
  source  = "terraform-google-modules/network/google"
  version = "6.0.0"

  project_id   = var.project_id
  network_name = "${var.network}-${var.env_name}"

  subnets = [
    {
      subnet_name   = "${var.subnetwork}-${var.env_name}"
      subnet_ip     = "10.10.0.0/16"
      subnet_region = var.region
    },
  ]

  secondary_ranges = {
    "${var.subnetwork}-${var.env_name}" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "10.20.0.0/16"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "10.30.0.0/16"
      },
    ]
  }
}

resource "google_compute_firewall" "allow-ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = module.gcp-network.network_name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]  
  depends_on = [module.gcp-network]
}

resource "google_compute_firewall" "allow-http-jenkins-server" {
  name = "allow-http-jenkins"
  allow {
    ports    = ["80", "8080"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = module.gcp-network.network_name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-jenkins-server"]  
  depends_on = [module.gcp-network]
}

resource "google_compute_firewall" "allow-sonarqube" {
  name = "allow-sonarqube"
  allow {
    ports    = ["9000"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = module.gcp-network.network_name
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["sonarqube"]  
  depends_on = [module.gcp-network]
}
