variable "resource_group_location" {
  type    = string
  default = "australiaeast"
}

variable "container_image_name" {
  type        = string
  default     = "cx-affinity-kiosk-um"
  description = "The docker container name"
}

variable "environment_name" {
  type        = string
  default     = "dev"
  description = "dev or uat or prod"
}
