package com.opencredo.glf.week2;

import cucumber.api.CucumberOptions;

@CucumberOptions(
        features = "classpath:com.opencredo.glf",
        tags = {"@low-level-infrastructure"},
        strict = true,
        format = {"html:target/cucumber-report/low-level-infrastructure",
                "json:target/cucumber-report/low-level-infrastructure.json"})
public class LowLevelTests {
}
