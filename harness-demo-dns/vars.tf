# variable "gcp_sa" {
#   type = string
#   description = "gcp sa"

# }
variable "project" {
  type = string
  description = "gcp project"
  default = "harnesspov"
}
variable "region" {
  type = string
  description = "gcp region"
  default = "harnesspov"
}
variable "subdomain" {
  type = string
  description = "subdomain that will be created behind harness-demo.site domain"
}
variable "ipAddress" {
  type = string
  description = "k8s ingress address"
  default = "34.121.101.100"
}