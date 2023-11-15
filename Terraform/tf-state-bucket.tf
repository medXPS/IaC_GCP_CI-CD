resource "google_storage_bucket" "tf-state-backup" { 
    name                        = "${var.project_id}-tf-state-bucket"
    location                   = var.region
    uniform_bucket_level_access = true
   }