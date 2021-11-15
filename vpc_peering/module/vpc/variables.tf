variable "vpc_tag" {
  description = "Tag of the VPC"
  type        = string
  default     = "VPC"
}

variable "vpc_cidr" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "public_subnet" {
  description = "List of public subnet to create"
  type = list(object({
    AZ   = string
    cidr = string
  }))

  validation {
    condition     = length(var.public_subnet) > 0
    error_message = "Required at least one public subnet."
  }
}

variable "private_subnet" {
  description = "List of private subnet to create"
  type = list(object({
    AZ   = string
    cidr = string
  }))

  validation {
    condition     = length(var.private_subnet) > 0
    error_message = "Required at least one private subnet."
  }
}
