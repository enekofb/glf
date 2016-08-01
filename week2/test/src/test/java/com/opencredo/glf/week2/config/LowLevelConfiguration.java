
package com.opencredo.glf.week2.config;


import com.opencredo.glf.week2.common.LowLevelWorld;
import com.opencredo.glf.week2.common.ServiceConfiguration;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.util.Collection;
import java.util.Collections;

@Configuration
@ComponentScan
@EnableConfigurationProperties
@Profile("low-level-test")
public class LowLevelConfiguration {

//    @Autowired
//    List<ServiceConfiguration> services ;
//
    @Bean
    public LowLevelWorld lowLevelWorld(){
        return LowLevelWorld.with(createServices());
    }

    private Collection<ServiceConfiguration> createServices() {
        return Collections.singletonList(ServiceConfiguration.with("etcd",("52.209.184.168")));
    }


}
