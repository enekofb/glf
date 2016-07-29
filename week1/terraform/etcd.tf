## AWS provider
provider "aws" {
  region = "${var.region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

## Setting up VPC
resource "aws_vpc" "eneko-vpc" {
  cidr_block = "10.20.0.0/16"
  tags = {
    Name = "eneko"
  }
}

## Setting up public network
resource "aws_internet_gateway" "eneko-vpc-gw" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  tags = {
    Name = "eneko"
  }
}

resource "aws_subnet" "public" {
  count ="${var.zone_count}"
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  cidr_block = "${lookup(var.public_subnet_cidr_block, count.index)}"

  availability_zone = "${lookup(var.eu-west-availablity-zone, count.index)}"

  tags = {
    Name = "eneko.public"
  }

}

resource "aws_route_table" "eneko-vpc-routing-table" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eneko-vpc-gw.id}"
  }

  tags = {
    Name = "eneko.public"
  }

}

resource "aws_route_table_association" "public" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
}


#bastion setup

resource "aws_eip" "eneko-bastion-eip" {
  vpc = true
  instance = "${aws_instance.eneko-bastion.id}"
//  provisioner "ansible" {
//    playbook = "../ansible/etcd-playbook.yml"
//    connection {
//      user = "ec2-user"
//      key_file = "/home/eneko/.ssh/eneko-bastion.pem"
//      host = "${aws_eip.eneko-bastion-eip.public_ip}"
//    }
//  }
}

resource "aws_instance" "eneko-bastion" {
  count ="1"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.bastion.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-bastion"
  tags = {
    Name = "eneko.public"
  }

}

resource "aws_security_group" "bastion" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  description = "allows input ssh to bastion instance"

  tags = {
    Name = "eneko.public"
  }

  ingress {
    from_port = 0
    to_port = 1194
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

resource "aws_elb" "etcd" {
  name = "etcd-elb"
  subnets = [
    "${element(aws_subnet.public.*.id, 0)}",
    "${element(aws_subnet.public.*.id, 1)}",
    "${element(aws_subnet.public.*.id, 2)}"]
  instances = [
    "${element(aws_instance.etcd.*.id,0)}",
    "${element(aws_instance.etcd.*.id,1)}",
    "${element(aws_instance.etcd.*.id,2)}"]
  security_groups = [
    "${aws_security_group.elb.id}"]

  listener {
    instance_port = 2379
    instance_protocol = "http"
    lb_port = 2379
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "http:2379/v2/keys"
    interval = 30
  }

  tags {
    Name = "eneko"
  }
}

resource "aws_security_group" "elb" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  description = "allows etcd traffic to elb"

  tags = {
    Name = "eneko.public"
  }

  ingress {
    from_port = 0
    to_port = 2379
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


# Private subnets
resource "aws_subnet" "private" {
  count ="${var.zone_count}"
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  cidr_block = "${lookup(var.private_subnet_cidr_block, count.index)}"
  availability_zone = "${lookup(var.eu-west-availablity-zone, count.index)}"

  tags = {
    Name = "eneko.private"
  }

}


# NAT gateways
resource "aws_eip" "private" {
  count ="${var.zone_count}"
  vpc = true
}

resource "aws_nat_gateway" "private" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.private.*.id, count.index)}"
}

resource "aws_route_table" "private" {
  count ="${var.zone_count}"
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.private.*.id, count.index)}"
  }

  tags {
    Name = "eneko.private"
  }
}


# ETCD ec2 instances
resource "aws_route_table_association" "private" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_security_group" "etcd" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
  description = "allows ssh and etcd traffic to etcd instances"

  tags = {
    Name = "eneko.private"
  }

  ingress {
    from_port = 0
    to_port = 2379
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


resource "aws_instance" "etcd" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.etcd.id}"]
  ami = "ami-f9dd452a"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko.private"
  }
}
