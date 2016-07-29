package com.opencredo.glf.week1.conf;

import com.sun.istack.internal.NotNull;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.List;

@ConfigurationProperties(prefix="glf.services")
@Component
public class ServicesProperties {

    @NotNull
    private List<ServiceConfiguration> services;

    public void setServices(List<ServiceConfiguration> services) {
        this.services = services;
    }

    public List<ServiceConfiguration> getServices() {
        return services;
    }
}
