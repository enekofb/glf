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


