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

At this level the project uses Terraform to provision an infrastructure on a given cloud provider. Terraform has several command useful
for testing purposes:

- _terraform validate_ in order to validate syntax on terraform files
- _terraform plan_ in order to validate changes on infrastructure
- _terraform show_ to verify current state of either infrastructure or plan

So in this level a strategy could be:

1) terraform validate for any change on the infrastructure in order to catch any syntax error
2) terraform plan for any change in order to determine changes to be done in the infrastructure (to make sure desired outcome?)
3) after terraform apply using terraform show or the could provider api (AWS api for instance) to run some test that ensure that current state is the desired.


### Middle level testing

_Goals: services has been provisioned in the infrastructure_

BDD kind scenario could be expressed like

Given that exists a provisioned empty infrastructure
And valid services provisioning resources exist
When the infrastructure has been provisioned
Then all the services for the system has been provisioned and work properly

At this level the project uses Ansible to provision services at the given infrastructure. Ansible provide several testing strategies.

http://docs.ansible.com/ansible/test_strategies.html

With the following recommendations

1) Use the same playbook all the time with embedded tests in development
2) Use the playbook to deploy to a staging environment (with the same playbooks) that simulates production
3) Run an integration test battery written by your QA team against staging
4) Deploy to production, with the same integrated tests.

the 3rd point encourages to run a small set of test after sucesfully provisioned with ansible

So in this level a strategy could be:

1) Design ansible-playbook with testing features available on ansible following fail-fast approach
2) Run a set of integration test for the services provisioned.

### High level testing

_Goals: system works properly in the infrastructure_

BDD kind scenario could be expressed like

Background:

Given that all services required for the system exist
When I setup the services in the way to work as the required system

Scenario for feature XX

When I execute a system feature XX
Then I receive a system feature XX response successfully
