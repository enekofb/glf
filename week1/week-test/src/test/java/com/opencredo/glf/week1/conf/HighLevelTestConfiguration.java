
package com.opencredo.glf.week1.conf;


import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Configuration
@ComponentScan
@EnableConfigurationProperties
@Profile("high-level-test")
public class HighLevelTestConfiguration {

    @Autowired
    ServicesProperties servicesProperties;

    @Bean
    public RestTemplate restTemplate(){
        return new RestTemplate();
    }

    @Bean
    public List<ServiceConfiguration> serviceConfigurations(){
        return servicesProperties.getServices();
    }
}
