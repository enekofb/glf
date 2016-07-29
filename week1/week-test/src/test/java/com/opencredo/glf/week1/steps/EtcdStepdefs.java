package com.opencredo.glf.week1.steps;

import cucumber.api.PendingException;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;

public class EtcdStepdefs {

    @When("^I store on path (.*) message (.*)$")
    public void iStoreMessageOnPathHellloworld(String messageValue, String messageKey) throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        throw new PendingException();
    }

    @Then("^I receive a system feature XX response successfully$")
    public void iReceiveASystemFeatureXXResponseSuccessfully() throws Throwable {
        // Write code here that turns the phrase above into concrete actions
        throw new PendingException();
    }
}
