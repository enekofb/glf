variable "access_key" {
}
variable "secret_key" {
}
variable "region" {
  default = "eu-west-1"
}

variable "eu-west-availablity-zone" {
  default = "eu-west-1a"
}

variable "public_subnet_cidr_block" {
  default = "10.20.1.0/24"
}

variable "etcd_count" {
  default = "3"
}

variable "k8s_controller_count" {
  default = "1"
}

variable "k8s_workers_count" {
  default = "1"
}
