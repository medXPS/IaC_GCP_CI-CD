resource "google_container_registry" "registry" {
  project  = var.project_id
  location = "us"  # Change to a valid GCR location
}
