package com.opencredo.glf.week2.common;

import java.net.UnknownHostException;
import java.util.Collection;
import java.util.Map;
import java.util.stream.Collectors;

public class LowLevelWorld {

    public static LowLevelWorld with(Collection<ServiceConfiguration> services){
        return new LowLevelWorld(services);
    }

    private final Map<String,ServiceConfiguration> services;

    private LowLevelWorld(Collection<ServiceConfiguration> services) {
        this.services = services.stream().collect(Collectors.toMap( service -> service.getType(),service -> service));
    }

    public ServiceConfiguration getInstanceByType(String instanceType) throws UnknownHostException {
        return services.get(instanceType);
    }

    public Collection<ServiceConfiguration> getServices() {
        return services.values();

    }
}
