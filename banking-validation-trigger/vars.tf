
variable "orgId" {
  type = string
  description = "org id"
  default = "default"
}

variable "projectId" {
  type = string
  description = "project id"
  default = "Demo_Sandbox"
}

variable "gitUser" {
  type = string
  description = "git user"
  default = "se-demo"
}

variable "accId" {
  type = string
  description = "account id"
  default = "6_vVHzo9Qeu9fXvj-AcbCQ"
}

variable "apiKey" {
  type = string
  description = "personal api key (pat)"
}
variable "ffKey" {
  type = string
  description = "ff api key (prod env)"
}
variable "serviceId" {
  type = string
  description = "service ref id"
}

