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

##### Ansible ssh bastion

SSH bastion host:  In this post, I’m going to explore a very specific use of SSH: the SSH bastion host. In this sort of arrangement, SSH traffic to servers that are not directly accessible via SSH is instead directed through a bastion host, which proxies the connection between the SSH client and the remote servers.

My file .ssh/config

Host etcd
  IdentityFile ~/.ssh/eneko-glf.pem
  ProxyCommand ssh ec2-user@bastion -W %h:%p

Host bastion
  IdentityFile ~/.ssh/eneko-bastion.pem
  ForwardAgent yes

##### etcd provisioning with Ansible

From our local machine using ssh bastion we are in position to install etcd
A playbook called etc-playbook has been created. It executes just a role called "etcd" on the inventory host

$ansible.dir>$ ansible-playbook -i inventories/development etcd-playbook.yml

###### etcd role

Very rough an basic one with the following tasks

- name: download etcd
  get_url: url=https://github.com/coreos/etcd/releases/download/v3.0.3/etcd-v3.0.3-linux-amd64.tar.gz dest=/tmp/etcd.tar.gz

- name: create etcd directory
  file: path=/tmp/etcd state=directory mode=0755

- name: untar etcd
  unarchive: src=/tmp/etcd.tar.gz dest=/tmp copy=no
  sudo: true

- name: execute etcd
  shell: nohup /tmp/etcd-v3.0.3-linux-amd64/etcd &
  become: true

