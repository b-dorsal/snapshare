resource "google_storage_bucket" "event-images" {
  name                     = "${var.project_id}-event-images"
  public_access_prevention = "enforced"
  location                 = var.region

  cors {
    origin          = ["https://${var.domain_name}"]
    method          = ["GET", "HEAD", "OPTIONS", "PUT"]
    response_header = ["Content-Type", "Authorization"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket" "website-static" {
  name                        = "${var.project_id}-website-static"
  public_access_prevention    = "inherited"
  location                    = var.region
  uniform_bucket_level_access = true

  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
}

resource "google_storage_bucket_iam_binding" "public_read" {
  bucket = google_storage_bucket.website-static.name
  role   = "roles/storage.objectViewer"

  members = [
    "allUsers",
  ]
}
