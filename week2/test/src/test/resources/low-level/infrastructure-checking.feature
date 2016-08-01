@low-level-infrastructure
Feature: Ensure that the infrastructure works and meets security requirements

  Background:
    Given that kubernetes cluster infrastructure has been created

  Scenario: can access to etcd
    Given I have details of an etcd instance
    When I check that is alive
    Then I have successfully connected to it
