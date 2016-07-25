provider "aws" {}

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

resource "aws_security_group" "eneko-sg-web-ssh" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  name = "eneko-sg-web-ssh"
  description = "allows web and ssh traffic."
  tags = {
    Name = "eneko"
  }

  ingress {
    from_port = 0
    to_port = 4001
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 22
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

resource "aws_subnet" "eneko-subnet1" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  cidr_block = "10.20.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "eneko"
  }

}

//resource aws_subnet "eneko-subnet2" {
//  vpc_id = "${aws_vpc.eneko-vpc.id}"
//  cidr_block = "10.20.2.0/24"
//  availability_zone = "eu-west-1b"
//
//  tags = {
//    Name = "eneko"
//  }
//}
//
//resource aws_subnet "eneko-subnet3" {
//  vpc_id = "${aws_vpc.eneko-vpc.id}"
//  cidr_block = "10.20.3.0/24"
//  availability_zone = "eu-west-1c"
//
//  tags = {
//    Name = "eneko"
//  }
//}


resource "aws_route_table_association" "eneko-vpc-routing-table-association1" {
  subnet_id = "${aws_subnet.eneko-subnet1.id}"
  route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
}

resource "aws_instance" "etcd-ec2" {
  subnet_id = "${aws_subnet.eneko-subnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.eneko-sg-web-ssh.id}"]
  ami = "ami-cbb5d5b8"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko"
  }

}

resource "aws_eip" "etcd-ec2-eip" {
  vpc = true
}

resource "aws_nat_gateway" "subnet1-nat-gateway" {
  allocation_id = "${aws_eip.etcd-ec2-eip.id}"
  subnet_id = "${aws_subnet.eneko-subnet1.id}"

}

resource "aws_elb" "etcd" {
  name = "etcd-elb"
  subnets = ["${aws_subnet.eneko-subnet1.id}"]
//  availability_zones = ["eu-west-1a"]

//  listener {
//    instance_port = 22
//    instance_protocol = "tcp"
//    lb_port = 22
//    lb_protocol = "tcp"
//  }

  listener {
    instance_port = 4001
    instance_protocol = "tcp"
    lb_port = 4001
    lb_protocol = "tcp"
  }

//  instances = ["${aws_instance.etcd-ec2.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "eneko"
  }
}