variable "container_name" {
  description = "Name of the Nginx container"
  type        = string
  default     = "nginx-container"
}

variable "external_port" {
  description = "External port for the Nginx container"
  type        = number
  default     = 8080
}

variable "environment_variables" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "content_path" {
  description = "Host path for custom HTML content"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment (dev, prod, etc.)"
  type        = string
  default     = "dev"
}
