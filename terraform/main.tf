
resource "google_project_service" "required_services" {
  for_each =toset(var.apis)
  project = var.project_id
  service = each.key
}
