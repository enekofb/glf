package com.opencredo.glf.week1;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.core.env.Environment;

import javax.annotation.PostConstruct;
import java.util.stream.Stream;

import static java.util.stream.Collectors.joining;

@EnableConfigurationProperties
@SpringBootApplication(scanBasePackageClasses = {Application.class})
public class Application {

    private static final Logger LOG = LoggerFactory.getLogger(Application.class);

    @Autowired
    private Environment env;

    @PostConstruct
    public void initApplication() {
        if (env.getActiveProfiles().length == 0) {
            LOG.warn("No Spring profile configured, running with default configuration");
        } else {
            LOG.info("Running with Spring profile(s) : {}", Stream.of(env.getActiveProfiles()).collect(joining(",")));
        }
    }

    public static void main(String[] args) {
        SpringApplication.run(Application.class, args);
    }
}
