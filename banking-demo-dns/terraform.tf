
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

// Configure the Google Cloud provider
provider "google" {
// credentials = "${file("${var.gcp_sa}")}" //
 project     = var.project //
 //region      = var.region //"us-central1-a"
}

resource "google_dns_record_set" "dns_record" {
  name         = "${trim(var.gitUser, "\"")}-payments-validation.harness-demo.site."
  managed_zone = "harness-demo"
  type         = "A"
  ttl          = 300

  rrdatas = [var.ipAddress]
}

# resource "google_dns_managed_zone" "prod" {
#   name     = "harness-demo"
#   dns_name = "harness-demo.site."
# }