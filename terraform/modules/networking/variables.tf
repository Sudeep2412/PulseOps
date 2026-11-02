variable "vpc_id" {
  type = string
}

variable "authorized_ssh_cidrs" {
  type = list(string)
}
