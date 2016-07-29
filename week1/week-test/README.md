# Great dev-leap forward testing week1

## Technologies

* AWS
* Terraform
* Ansible

## Testing

Business objective: to deploy an etcd cluster so from the exercise there are three main tasks. The etcd cluster could be
seen as the system to create. In order to create the system we need to:

1 - Provision the infrastructure.
2 - Provision the services needed for the system.
3 - Setup the system based on provisioned services.

So in terms of testing there are three main layers identified

1 - Infrastructure testing that we could identify as "low level"
2 - Service testing that we could identify as "middle level"
3 - System testing that we could identify as "high level"

Lets discuss a little bit about them ...

### Low level testing

_Goals: infrastructure has been provisioned_

BDD kind scenario could be expressed like

Given that exists no infrastructure
And valid infrastructure provisioning resources exist
When the infrastructure is provisioned
Then the infrastructure has been provisioned and is empty

At this level the project uses Terraform for provision infrastructure on a given cloud provider so there are the following

The functionality could be achieved by using

### Middle level testing

_Goals: services has been provisioned in the infrastructure_

BDD kind scenario could be expressed like

Given that exists a provisioned empty infrastructure
And valid services provisioning resources exist
When the infrastructure has been provisioned
Then all the services for the system has been provisioned and work properly

### High level testing

_Goals: system works properly in the infrastructure_

BDD kind scenario could be expressed like

Background:

Given that all services required for the system exist
When I setup the services in the way to work as the required system

Scenario for feature XX

When I execute a system feature XX
Then I receive a system feature XX response successfully
