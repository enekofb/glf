@low-level-infrastructure
Feature: Ensure that the infrastructure works and meets security requirements

  Background:
    Given that kubernetes cluster infrastructure has been created

  Scenario: can access to etcd
    Given I have details of an etcd instance
    When I check that is alive
    Then I have successfully connected to it

  Scenario: ssh is enabled
    Given I have details of an etcd instance
    When I try to connect by tcp to port 22
    Then I have successfully connected to it

  Scenario: tcp is enabled
    Given I have details of an etcd instance
    When I try to connect by tcp to port 80
    Then I have successfully connected to it

    #Review so udp checking should not be based on connection
  Scenario: udp is enabled
    Given I have details of an etcd instance
    When I try to connect by udp to port 80
    Then I have successfully connected to it

  Scenario: icmp is enabled
    Given I have details of an etcd instance
    When I try to connect by udp to port 8
    Then I have successfully connected to it


