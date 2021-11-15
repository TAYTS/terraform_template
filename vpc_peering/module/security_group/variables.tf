variable "sg_tag" {
  description = "Tag of the Security Group"
  type        = string
  default     = "Security Group"
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}
