variable "region" {
  type        = string
  description = "Región donde se crearan los recursos de Azure."
  sensitive   = false
  default     = "westus2"
}