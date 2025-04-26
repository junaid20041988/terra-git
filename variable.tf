variable "cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "cidr range"
}

variable "cidr_pub" {
  type        = string
  default     = "10.0.1.0/24"
  description = "cidr pub range"
}

variable "cidr_pri" {
  type        = string
  default     = "10.0.2.0/24"
  description = "cidr pri range"
}
