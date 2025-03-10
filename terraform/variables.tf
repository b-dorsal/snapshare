variable "project_id" {
    type = string
}

variable "environment_name" {
    type = string
}

variable "region" {
    default = "us-central1"
}

variable "apis" {
    default = [
        "compute.googleapis.com",
        "dns.googleapis.com",
        "certificatemanager.googleapis.com",
        "cloudresourcemanager.googleapis.com",
        "iap.googleapis.com",
        "cloudfunctions.googleapis.com",
        "run.googleapis.com",
        "cloudbuild.googleapis.com"
    ]
}

variable "domain_name" {
    type = string
}