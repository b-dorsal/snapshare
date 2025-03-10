resource "google_cloudfunctions2_function" "signed_url_function" {
  name        = "get-upload-url"
  location    = var.region
  description = "Generate a signed URL for uploading photos to GCS"

  build_config {
    runtime     = "python310"
    entry_point = "get_upload_url"
    source {
      storage_source {
        bucket = google_storage_bucket.source-code.name
        object = google_storage_bucket_object.archive.name
      }
    }
  }

  service_config {
    max_instance_count = 1
    available_memory   = "256M"
    timeout_seconds    = 60
    environment_variables = {
      BUCKET_NAME = google_storage_bucket.event-images.name,
      CORS_DOMAIN = "https://${var.domain_name}"
    }
  }
}

resource "google_project_iam_member" "cloud_function_storage_access" {
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_cloudfunctions2_function.signed_url_function.service_config[0].service_account_email}"
  project = var.project_id
}

resource "google_cloud_run_service_iam_member" "invoker" {
  project  = google_cloudfunctions2_function.signed_url_function.project
  location = google_cloudfunctions2_function.signed_url_function.location
  service  = google_cloudfunctions2_function.signed_url_function.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Source code bucket
resource "google_storage_bucket" "source-code" {
  name     = "${var.project_id}-function-bucket"
  location = "US"
}

resource "google_storage_bucket_object" "archive" {
  name   = "index.zip"
  bucket = google_storage_bucket.source-code.name
  source = "../function.zip"
}

resource "google_service_account" "function_account" {
  account_id   = "upload-function"
  display_name = "Upload Function Service Account"
}

resource "google_project_iam_member" "function_storage_admin" {
  project = var.project_id
  role    = "roles/storage.objectCreator"
  member  = "serviceAccount:${google_service_account.function_account.email}"
}

resource "google_service_account_iam_binding" "function_sa_user" {
  service_account_id = google_service_account.function_account.name
  role               = "roles/iam.serviceAccountUser"
  members = [
    "serviceAccount:${google_service_account.function_account.email}"
  ]
}
