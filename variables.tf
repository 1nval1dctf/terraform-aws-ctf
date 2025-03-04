
variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version for the EKS cluster"
  default     = "1.32"
}

variable "aws_region" {
  default     = "ap-southeast-2"
  description = "Region to deploy into"
  type        = string
}


variable "registry_server" {
  description = "Private docker registry hosting images."
  type        = string
  default     = "gitlab.com"
}

variable "registry_username" {
  description = "Username for private docker registry hosting images. Needed if registry_server set."
  type        = string
  default     = null
}

variable "registry_password" {
  description = "Username for private docker registry hosting images. Needed if registry_server set."
  type        = string
  default     = null
}

variable "registry_email" {
  description = "Email to use for private docker registry credendials. Needed if registry_server set."
  type        = string
  default     = null
}


variable "chal_domain" {
  description = "Domain for chalenges"
  type        = string
  default     = null
}

variable "ctf_domain" {
  description = "Domain for ctfd frontend"
  type        = string
  default     = null
}

variable "ctf_domain_zone_id" {
  description = "zone id for the route53 zone for the ctfd_domain"
  type        = string
  default     = null
}

variable "ctfd_image" {
  type        = string
  description = "Docker image for the ctfd frontend."
  default     = "ctfd/ctfd"
}

variable "https_certificate_arn" {
  description = "SSL Certificate ARN to be used for the HTTPS server."
  type        = string
  default     = null
}