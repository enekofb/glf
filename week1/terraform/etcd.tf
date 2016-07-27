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
//  main_route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
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


resource "aws_internet_gateway" "eneko-vpc-gw" {
  vpc_id = "${aws_vpc.eneko-vpc.id}"
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
    Name = "eneko.public"
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

resource "aws_route_table_association" "public" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.eneko-vpc-routing-table.id}"
}

resource "aws_elb" "etcd" {
  name = "etcd-elb"
  subnets = [
    "${element(aws_subnet.public.*.id, 0)}",
    "${element(aws_subnet.public.*.id, 1)}",
    "${element(aws_subnet.public.*.id, 2)}"]
  instances = [
    "${element(aws_instance.etcd-ec2.*.id,0)}",
    "${element(aws_instance.etcd-ec2.*.id,1)}",
    "${element(aws_instance.etcd-ec2.*.id,2)}"]
  security_groups = [
    "${aws_security_group.eneko-sg-all.id}"]

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

resource "aws_subnet" "private" {
  count ="${var.zone_count}"
  vpc_id = "${aws_vpc.eneko-vpc.id}"

  cidr_block = "${lookup(var.private_subnet_cidr_block, count.index)}"
  availability_zone = "${lookup(var.eu-west-availablity-zone, count.index)}"

  tags = {
    Name = "eneko.private"
  }

}

resource "aws_nat_gateway" "private" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.private.*.id, count.index)}"
}

resource "aws_eip" "private" {
  count ="${var.zone_count}"
  vpc = true
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

resource "aws_route_table_association" "private" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_instance" "etcd-ec2" {
  count ="${var.zone_count}"
  subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.eneko-sg-all.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-glf"

  tags = {
    Name = "eneko.private"
  }
}

resource "aws_eip" "eneko-bastion-eip" {
  vpc = true
  instance = "${aws_instance.eneko-bastion.id}"
}

resource "aws_instance" "eneko-bastion" {
  count ="1"
  subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
  vpc_security_group_ids = [
    "${aws_security_group.eneko-sg-all.id}"]
  ami = "ami-f9dd458a"
  instance_type = "t2.nano"
  key_name = "eneko-bastion"
//  provisioner "ansible" {
//    connection {
//      user = "ec2-user"
//      private_key = "/home/eneko/.ssh/eneko-development.pem"
//    }
//    playbook = "ansible/etcd-playbook.yml"
//  }

  tags = {
    Name = "eneko.public"
  }

}