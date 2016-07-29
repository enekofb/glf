package com.opencredo.glf.week1.steps;

import com.opencredo.glf.week1.Application;
import com.opencredo.glf.week1.conf.HighLevelTestConfiguration;
import com.opencredo.glf.week1.conf.ServiceConfiguration;
import cucumber.api.PendingException;
import cucumber.api.java.en.Given;
import cucumber.api.java.en.When;
import org.junit.runner.RunWith;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.SpringApplicationContextLoader;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.test.context.web.WebAppConfiguration;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.function.Consumer;

import static org.assertj.core.api.Assertions.assertThat;


//@RunWith(SpringJUnit4ClassRunner.class)
//@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.NONE, classes = {Application.class, HighLevelTestConfiguration.class})
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(classes = {
        Application.class, HighLevelTestConfiguration.class
}, loader = SpringApplicationContextLoader.class)
@WebAppConfiguration
@ActiveProfiles("high-level-test")
public class BackgroundStepdefs {

    private static final Logger LOGGER = LoggerFactory.getLogger(BackgroundStepdefs.class);

    @Autowired
    RestTemplate restTemplate;

    @Autowired
    List<ServiceConfiguration> services;

    Consumer<ServiceConfiguration> assertService = new AssertService();

    @Given("^that all services required for the system exist$")
    public void thatAllServicesRequiredForTheSystemExist() throws Throwable {
        //list the services
        assertThat(services).isNotEmpty();
        services.stream().forEach(assertService);
    }

    @When("^I setup the services in the way to work as the required system$")
    public void iSetupTheServicesInTheWayToWorkAsTheRequiredSystem() throws Throwable {
        //list the services
        //get info for the services in aws
        //check that each service is available
        throw new PendingException();
    }

    class AssertService implements Consumer<ServiceConfiguration> {

        @Override
        public void accept(ServiceConfiguration serviceConfiguration) {
            serviceConfiguration.getUri();
            //get info for the services in aws
            ResponseEntity<String> stringResponseEntity = restTemplate.getForEntity(serviceConfiguration.getUri(), String.class);
            LOGGER.info("{}", stringResponseEntity);
            assertThat(stringResponseEntity.getStatusCode()).isEqualTo(HttpStatus.OK);
        }
    }

}
