package com.opencredo.glf.week2.steps;

import com.opencredo.glf.week2.Application;
import com.opencredo.glf.week2.common.LowLevelWorld;
import com.opencredo.glf.week2.common.ServiceConfiguration;
import com.opencredo.glf.week2.config.LowLevelConfiguration;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.Then;
import cucumber.api.java.en.When;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.SpringApplicationContextLoader;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;

import static org.assertj.core.api.Java6Assertions.assertThat;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {
        Application.class, LowLevelConfiguration.class
}, loader = SpringApplicationContextLoader.class)
@WebAppConfiguration
@ActiveProfiles("low-level-test")
public class Ec2StepDefs {
    @Autowired
    private LowLevelWorld world;

    private ServiceConfiguration serviceConfiguration;

    @Given("^I have details of an (.*) instance$")
    public void iHaveDetailsOfAnInstance(String instanceType) throws Throwable {
        serviceConfiguration = world.getInstanceByType(instanceType);
        assertThat(serviceConfiguration).isNotNull();
    }

    @When("^I check that is alive$")
    public void iCheckThatIsAlive() throws Throwable {
        assertThat(serviceConfiguration.isReachable(30000)).isTrue();
    }

    @Then("^I have successfully connected to it$")
    public void iHaveSucessfullyConnectToIt() throws Throwable {
    }
}
