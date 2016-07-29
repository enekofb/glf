package com.opencredo.glf.week1;

import cucumber.api.CucumberOptions;

@CucumberOptions(
        features = "classpath:com.opencredo.glf",
        tags = {"@high-level-infrastructure"},
        strict = true,
        format = {"html:target/cucumber-report/high-level-infrastructure",
                "json:target/cucumber-report/high-level-infrastructure.json"})
public class HighLevelTests {
}
