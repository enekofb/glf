package com.opencredo.glf.week2.common;

import java.io.IOException;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;

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
        return new ServiceConfiguration(type, ip);
    }

    public boolean isReachable(int timeout) throws IOException {
        return InetAddress.getByName(ip).isReachable(timeout);
    }

    public boolean connect(String type, int port) throws IOException {
        switch (type) {
            case "tcp":
                try (Socket socket = connectTcpSocket(ip, port)) {
                    return socket.isConnected();
                }
            case "udp":
                try (DatagramSocket socket = connectUdpSocket(ip, port)) {
                    return socket.isConnected();
                }

            default:
                return false;
        }

    }

    private Socket connectTcpSocket(String ip, int port) throws IOException {
        Socket socket = new Socket();
        socket.connect(new InetSocketAddress(ip, port));
        return socket;

    }

    private DatagramSocket connectUdpSocket(String ip, int port) throws IOException {
        DatagramSocket socket = new DatagramSocket();
        socket.connect(new InetSocketAddress(ip, port));
        return socket;
    }
}
