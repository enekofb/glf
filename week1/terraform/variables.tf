variable "zone_count" {
  default = "3"
}

variable "eu-west-availablity-zone"{
  default = {
    "0" = "eu-west-1a"
    "1" = "eu-west-1b"
    "2" = "eu-west-1c"
  }
}

variable "public_subnet_cidr_block"{
  default = {
    "0" = "10.20.1.0/24"
    "1" = "10.20.2.0/24"
    "2" = "10.20.3.0/24"
  }
}


variable "private_subnet_cidr_block"{
  default = {
    "0" = "10.20.10.0/24"
    "1" = "10.20.20.0/24"
    "2" = "10.20.30.0/24"
  }
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {
  default = "eu-west-1"
}
