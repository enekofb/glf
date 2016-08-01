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

I want to test that infrastructure has been provisioned and it meets requirements. If Terraform has been successfully executed
we could make sure that it works pretty much.




