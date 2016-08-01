## AWS provider
provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

## Setting up VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "eneko.kubernetes"
  }
}

## Setting up public network
resource "aws_internet_gateway" "eneko-vpc-gw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags = {
    Name = "eneko.kubernetes"
  }
}

resource "aws_subnet" "public" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.public_subnet_cidr_block}"

  availability_zone = "${var.eu-west-availablity-zone}"

  tags = {
    Name = "eneko.kubernetes"
  }

}

resource "aws_route_table" "eneko-vpc-routing-table" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eneko-vpc-gw.id}"
  }

  tags = {
    Name = "eneko.kubernetes"
  }

}

resource "aws_route_table_association" "public" {
  subnet_id = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
}


#firewall rules
resource "aws_security_group" "kubernetes" {
  vpc_id = "${aws_vpc.vpc.id}"
  description = "kubernetes subnet: allow icmp, rdp, ssh"

  tags = {
    Name = "eneko.kubernetes"
  }

  #icmp allowed
  ingress {
    from_port = 0
    to_port = 0
    protocol = "icmp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  #tcp allowed
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = [
      "${var.public_subnet_cidr_block}"]
  }

  #udp allowed
  ingress {
    from_port = 0
    to_port = 65535
    protocol = "udp"
    cidr_blocks = [
      "${var.public_subnet_cidr_block}"]
  }

  #ssh allowed
  ingress {
    from_port = 0
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  #healthz allowed
  ingress {
    from_port = 0
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [
      "130.211.0.0/22"]
  }

  #api server allowed
  ingress {
    from_port = 0
    to_port = 6443
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

}

# etcd eips
resource "aws_eip" "etcd-eip" {
  count ="${var.etcd_count}"
  vpc = true
  instance = "${element(aws_instance.etcd.*.id, count.index)}"
}

resource "aws_instance" "etcd" {
  count ="${var.etcd_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.kubernetes.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko.kubernetes.etcd"
  }
}


# k8s controllers eips
resource "aws_eip" "k8s-controller-eip" {
  count ="${var.k8s_controller_count}"
  vpc = true
  instance = "${element(aws_instance.k8scontroller.*.id, count.index)}"
}

resource "aws_instance" "k8scontroller" {
  count ="${var.k8s_controller_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.kubernetes.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko.kubernetes.controllers"
  }
}

# k8s worker eips
resource "aws_eip" "k8s-worker-eip" {
  count ="${var.k8s_workers_count}"
  vpc = true
  instance = "${element(aws_instance.k8sworkers.*.id, count.index)}"
}

resource "aws_instance" "k8sworkers" {
  count ="${var.k8s_workers_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.kubernetes.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko.kubernetes.workers"
  }
}


