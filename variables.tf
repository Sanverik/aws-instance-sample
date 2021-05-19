variable "AWS_Region" {
   type = string
   default = "eu-central-1"
}

variable "AWS_ACCESS_KEY" {
  type = string
}

variable "SECRET_ACCESS_KEY" {
  type = string
}

variable "AWS_SSH_KEY" {
  type = string
  default = "main-key"
}
