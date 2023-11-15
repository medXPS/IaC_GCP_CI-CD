resource "google_compute_instance" "jenkins-server" {
  name         = "jenkins-server"
  machine_type = "e2-medium"
  zone         = "europe-west2-a"
  allow_stopping_for_update = true
  tags         = ["http-jenkins-server", "ssh", "sonarqube"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = module.gcp-network.network_name

    subnetwork = module.gcp-network.subnets_names[0]  # Use the appropriate subnetwork name
     access_config {
    }
  }

  depends_on = [module.gcp-network]
}
