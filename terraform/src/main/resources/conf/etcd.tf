provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_vpc" "eneko-vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "eneko"
  }
}

resource "aws_internet_gateway" "eneko-vpc-gw" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  tags = {
    Name = "eneko"
  }
}

resource "aws_elb" "etcd" {
  name = "etcd-elb"
  subnets = [
    "${aws_subnet.eneko-subnet1.id}"]
  instances = [
    "${aws_instance.etcd-ec2.id}"]
  security_groups = [
    "${aws_security_group.eneko-sg-all.id}"]

  listener {
    instance_port = 4001
    instance_protocol = "http"
    lb_port = 4001
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "http:4001/v2/keys/helloworld"
    interval = 30
  }

  tags {
    Name = "eneko"
  }
}

resource "aws_security_group" "eneko-sg-all" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  name = "eneko-sg-all"
  description = "allows all traffic"

  tags = {
    Name = "eneko"
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
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

resource "aws_subnet" "eneko-subnet1" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  cidr_block = "10.20.1.0/24"
  availability_zone = "eu-west-1a"
  tags = {
    Name = "eneko"
  }

}

resource "aws_route_table" "eneko-vpc-routing-table" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eneko-vpc-gw.id}"
  }

  tags = {
    Name = "eneko"
  }

}

resource "aws_route_table_association" "eneko-vpc-routing-table-association1" {
  subnet_id = "${aws_subnet.eneko-subnet1.id}"
  route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
}

resource "aws_subnet" "eneko-private-subnet1" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  cidr_block = "10.20.10.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "eneko.private"
  }

}

resource "aws_eip" "eneko-private-subnet1-gw-eip" {
  vpc = true
}

resource "aws_nat_gateway" "eneko-private-subnet1-gw" {
  subnet_id = "${aws_subnet.eneko-subnet1.id}"
  allocation_id = "${aws_eip.eneko-private-subnet1-gw-eip.id}"

}

resource "aws_route_table" "eneko-private-subnet1-route-table" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.eneko-private-subnet1-gw.id}"
  }

  tags {
    Name = "eneko"
  }
}

resource "aws_route_table_association" "eneko-private-subnet1-route-table-assoc" {
  subnet_id = "${aws_subnet.eneko-private-subnet1.id}"
  route_table_id = "${aws_route_table.eneko-private-subnet1-route-table.id}"
}

resource "aws_instance" "etcd-ec2" {
  subnet_id = "${aws_subnet.eneko-private-subnet1.id}"
  vpc_security_group_ids = [
    "${aws_security_group.eneko-sg-all.id}"]
  ami = "ami-cbb5d5b8"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko"
  }
}