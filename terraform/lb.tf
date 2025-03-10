# Backend Bucket for Load Balancer
resource "google_compute_backend_bucket" "website_backend" {
  name        = "website-backend"
  bucket_name = google_storage_bucket.website-static.name
  enable_cdn  = false
}

# Reserve a Global IP for Load Balancer
resource "google_compute_global_address" "website_ip" {
  name = "website-ip"
}

# SSL Certificate
resource "google_compute_managed_ssl_certificate" "website_ssl" {
  name = "website-ssl"

  managed {
    domains = [var.domain_name]  # Example: "yourdomain.com"
  }
}

# URL Map (Routes requests to backend bucket)
resource "google_compute_url_map" "website_url_map" {
  name            = "website-url-map"
  default_service = google_compute_backend_bucket.website_backend.id
}

# Target Proxy for HTTPS
resource "google_compute_target_https_proxy" "website_https_proxy" {
  name             = "website-https-proxy"
  url_map          = google_compute_url_map.website_url_map.id
  ssl_certificates = [google_compute_managed_ssl_certificate.website_ssl.id]
}

# Forwarding Rule (Routes traffic to the proxy)
resource "google_compute_global_forwarding_rule" "website_forwarding_rule" {
  name                  = "website-forwarding-rule"
  ip_address            = google_compute_global_address.website_ip.address
  target                = google_compute_target_https_proxy.website_https_proxy.id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL"
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "allow-http-https"
  network = "default" # Change if using a custom VPC

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"] # Ensure your load balancer or VM has these tags
  direction     = "INGRESS"
  priority      = 1000
}