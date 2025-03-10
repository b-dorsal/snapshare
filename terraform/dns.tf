resource "google_dns_managed_zone" "website_dns" {
  name        = "website-zone"
  dns_name    = "${var.domain_name}." # Example: "yourdomain.com."
  description = "DNS zone for website"
}

resource "google_dns_record_set" "website_a_record" {
  name    = "${var.domain_name}." # Example: "yourdomain.com."
  type    = "A"
  ttl     = 300
  managed_zone = google_dns_managed_zone.website_dns.name

  rrdatas = [google_compute_global_address.website_ip.address]
}