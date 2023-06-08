variable "publicsubnet1" {
  type    = string
  default = ""
}

variable "publicsubnet2" {
  type    = string
  default = ""
}

variable "privatesubnet1" {
  type    = string
  default = ""
}

variable "privatesubnet2" {
  type    = string
  default = ""
}

variable "target_group_arns" {
  type    = string
  default = ""
}

variable "security_groups" {
  type    = string
  default = ""
}

variable "max_size" {
  default = ""
}

variable "min_size" {
  default = ""
}

variable "desired_capacity" {
  default = ""
}