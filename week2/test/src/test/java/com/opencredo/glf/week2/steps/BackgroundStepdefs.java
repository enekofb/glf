package com.opencredo.glf.week2.steps;

import com.opencredo.glf.week2.common.LowLevelWorld;
import cucumber.api.java.en.Given;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import static org.assertj.core.api.Assertions.assertThat;


public class BackgroundStepdefs {

    private static final Logger LOGGER = LoggerFactory.getLogger(BackgroundStepdefs.class);

    @Autowired
    LowLevelWorld lowLevelWorld;


    @Given("^that kubernetes cluster infrastructure has been created$")
    public void thatKubernetesClusterInfrastructureHasBeenCreated() throws Throwable {
        assertThat(lowLevelWorld.getServices()).hasSize(1);
    }


}
