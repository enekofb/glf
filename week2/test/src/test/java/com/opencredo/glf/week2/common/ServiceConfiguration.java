package com.opencredo.glf.week2.common;

import java.io.IOException;
import java.net.InetAddress;

public class ServiceConfiguration {

    private final String type;
    private final String ip;

    private ServiceConfiguration(String type, String ip) {
        this.type = type;
        this.ip = ip;
    }

    public String getType() {
        return type;
    }

    public String getIp() {
        return ip;
    }

    public static ServiceConfiguration with(String type, String ip) {
        return new ServiceConfiguration(type,ip);
    }

    public boolean isReachable(int timeout) throws IOException {
        return InetAddress.getByName(ip).isReachable(timeout);
    }
}
