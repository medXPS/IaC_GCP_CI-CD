# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
  # version                = "~> 2.10"
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google"
  version                    = "26.1.1"
  project_id                 = var.project_id
  name                       = "${var.cluster_name}-${var.env_name}"
  regional                   = true
  region                     = var.region
  zones                      = var.zones
  network                    = module.gcp-network.network_name
  subnetwork                 = module.gcp-network.subnets_names[0]
  ip_range_pods              = var.ip_range_pods_name
  ip_range_services          = var.ip_range_services_name
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = false
  filestore_csi_driver       = false
  create_service_account     = true
  

  node_pools = [
    {
      name            = "node-pool"
      machine_type    = "e2-standard-2"
      node_locations  = "europe-west2-b,europe-west2-c"
      min_count       = 1
      max_count       = 1
      disk_size_gb    = 30
      spot            = false
      auto_upgrade    = true
      auto_repair     = true
      autoscaling     = true
      service_account = "ansible@${var.project_id}.iam.gserviceaccount.com"
    },
  ]



  node_pools_labels = {
    all = {}

    default-node-pool = {
      default-node-pool = true
    }
  }

  node_pools_metadata = {
    all = {}
    node-pool = {
      shutdown-script                 = "kubectl --kubeconfig=/var/lib/kubelet/kubeconfig drain --force=true --ignore-daemonsets=true --delete-local-data \"$HOSTNAME\""
      node-pool-metadata-custom-value = "node-pool"
    }
  }

  node_pools_taints = {
    all = []

    node-pool = [
      {
        key    = "node-pool"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
  }

  node_pools_tags = {
    all = []
    node-pool = [
      "node-pool",
    ]
  }
  depends_on = [
        module.gcp-network
        ]
}