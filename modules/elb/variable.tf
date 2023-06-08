variable "vpc_id" {
  default = ""
}

variable "security_groups_web" {
  type    = string
  default = ""
}

variable "security_groups_app" {
  type    = string
  default = ""
}

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