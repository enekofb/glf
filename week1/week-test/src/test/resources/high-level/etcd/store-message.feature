@high-level-infrastructure
Feature: Store message on the Etcd cluster

  Background:
    Given that all services required for the system exist
    When I setup the services in the way to work as the required system

  Scenario: can store message on etcd cluster
    When I store on path /hellloworld message hello world
    Then I receive a system feature XX response successfully