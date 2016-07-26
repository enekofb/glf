# Great dev-leap forward

A learning experience for developers to do a little step into devops.

## Technologies

* AWS
* Terraform
* Ansible

### Exercises

25/07/2016

- etcd deployed in a public subnet on AWS

#### Interesting points

keypairs ec2 generation from aws console management

ssh -i eneko-glf.pem core@52.208.52.48

#### Installing etcd

using coreos ami image

https://coreos.com/os/docs/latest/quickstart.html


#### Testing etcd

wget http://52.208.52.48:4001/v2/keys/helloworld

{"action":"get","node":{"key":"/helloworld","value":"Hello world","modifiedIndex":4,"createdIndex":4}}


### Provisioning private instance with ansible

In order to provision a private instance a bastion/vpn is needed. I follow the bastion approach so an instance in the public
subnet is created to manage private network instances.

#### Prepare bastion for provisioning
- needs to have internet access (like it is in the public network, it has)
- needs to be able to run ansible. Let's setup this machine: 1) setup terraform provisioner for this instance

Project to use ansible as terraform provider
https://github.com/jonmorehouse/terraform-provisioner-ansible




