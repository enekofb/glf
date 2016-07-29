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


### Provisioning though VPN
1) provision the bastion with ansible openvpn role

 ansible-playbook -vvvv -i ./week1/ansible/inventories/external/ec2.py ./week1/ansible/openvpn-playbook.yml

2) remove ssh config for routes to host

Host 10.20.*
  IdentityFile ~/.ssh/eneko-glf.pem
  ProxyCommand ssh ec2-user@bastion -W %h:%p

Host 52.*
 IdentityFile ~/.ssh/eneko-bastion.pem
 ForwardAgent yes

3) Provision existing instances as usual with ansible
 ansible-playbook -vvvv -i ./inventories/internal/ec2.py -u ec2-user --private-key=$HOME/.ssh/eneko-glf.pem ./etcd-playbook.yml

#Throubleshooting

##With ansible and dynamic inventory

E.g. when executing ec2.py for internal purposes but you have previously executed the script for external purposes it may
 returns from external --> you should change cache settings below

 API calls to EC2 are slow. For this reason, we cache the results of an API
 call. Set this to the path you want cache files to be written to. Two files
 will be written to this directory:
   - ansible-ec2.cache
   - ansible-ec2.index
cache_path = ~/.ansible/tmp/{internal/external}

 The number of seconds a cache file is considered valid. After this many
 seconds, a new API call will be made, and the cache file will be updated.
 To disable the cache, set this value to 0
cache_max_age = 300

## How to run the example

1) Terraform infrastructure provisioning

terraform apply -var 'access_key={your_access_key}' -var 'secret_key={your_secret_key}'

2) Run vpn server on the bastion with ansible

ansible-playbook -vvvv -i ./week1/ansible/inventories/external/ec2.py ./week1/ansible/openvpn-playbook.yml

3) Setup your vpn client
 - Previous step has created a zip with all client relevant configuration and certificate files.
 - start your vpn client with previous configuration with command
 openvpn --config etcd.ovpn start&

4) Run ansible etcd playbook to provision private instances through vpn

ansible-playbook -vvvv -i ./inventories/internal/ec2.py -u ec2-user --private-key=$HOME/.ssh/eneko-glf.pem ./etcd-playbook.yml

5) Test etcd pointing your balancer

http://etcd-elb-1449198635.eu-west-1.elb.amazonaws.com:2379/v2/keys/helloworld

Notice that load balancer needs the instances to be ready so in case that you do not get response for previous
answer,you should check that the load balancer has every instance in "InService" state.

## Testing

Three layers to test (traditional testing pyramid):

- low testing:
- middle testing:
- high testing: