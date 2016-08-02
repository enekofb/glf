# Kubernetes the hard way in AWS

The objective is to get introduced to Kubernetes by boostrapping a cluster in "the hard way" (manually).
Source used is https://github.com/kelseyhightower/kubernetes-the-hard-way. A main difference between what is in
the project and the course is that instead of using Google Cloud Platform, we are going to use AWS.

## Introduction


Kubernetes is an open-source system for automating deployment, scaling, and management of containerized applications.
It groups containers that make up an application into logical units for easy management and discovery.
Kubernetes builds upon 15 years of experience of running production workloads at Google,
combined with best-of-breed ideas and practices from the community.


## Lab1: Cloud infrastructure provisioning

Goal: this lab will walk you through provisioning the compute instances required for running a H/A Kubernetes cluster.
A total of 9 virtual machines will be created.

We use Terraform (instead of CLI) to create the infrastructure (using knowledge from week1)

### testing

I want to test that infrastructure has been provisioned and it meets requirements.

Scenarios to check security policies have been added. They are cucumber-based.


## Lab2: setting up CA and TLS cert generation

Certification generate by following lab instructions. Noticed that some of ips for ca configuration makes relation to
 google cloud stuff so they have been removed

 Created Ansible playbook to provision instance files

 ### testing
 No testing done for this lab so nothing really needs testing.


## Lab3: Bootstrapping a H/A etcd cluster

Ansible playbook to setup etcd cluster

 ansible-playbook -vvvv -t "etcd" -i ./provisioning/inventories/etcd/ec2.py -u centos --private-key=$HOME/.ssh/eneko-glf.pem ./provisioning/playbook.yml


Difficulties found: with dynamic inventory setup ectd.service configuration file in order to have all the names and ips ready
for the command to start

[Service]
ExecStart=/usr/bin/etcd --name {{ec2_private_dns_name}} \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --initial-advertise-peer-urls https://{{ec2_private_ip_address}}:2380 \
  --listen-peer-urls https://{{ec2_private_ip_address}}:2380 \
  --listen-client-urls https://{{ec2_private_ip_address}}:2379 \
  --advertise-client-urls https://{{ec2_private_ip_address}}:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster ip-10-20-1-10.eu-west-1.compute.internal=https://10.20.1.10:2380,ip-10-20-1-11.eu-west-1.compute.internal=https://10.20.1.11:2380,ip-10-20-1-12.eu-west-1.compute.internal=https://10.20.1.12:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd

Health check
[centos@ip-10-20-1-12 ~]$ sudo etcdctl --ca-file=/etc/etcd/ca.pem cluster-health

member 800208a486493917 is healthy: got healthy result from https://10.20.1.10:2379
member c27ba28489d75dbf is healthy: got healthy result from https://10.20.1.12:2379
member fe3e8dbe8af16beb is healthy: got healthy result from https://10.20.1.11:2379

## Lab4: Bootstrapping a H/A Kubernetes Control Plane

Impr: not to have kube services configuration files

To execute the command for controllers

ansible-playbook -vvvv -t "k8s-controller" -i ./provisioning/inventories/k8s-controllers/ec2.py -u centos --private-key=$HOME/.ssh/eneko-glf.pem ./provisioning/playbook.yml

## Lab5: Bootstrapping a H/A Kubernetes Cluste workers

what is Container Network Interface
