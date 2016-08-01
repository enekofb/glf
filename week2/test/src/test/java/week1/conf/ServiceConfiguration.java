package week1.conf;

public class ServiceConfiguration {

    private final String name;
    private final String uri;

    public ServiceConfiguration(String name, String uri) {
        this.name = name;
        this.uri = uri;
    }

    public String getName() {
        return name;
    }

    public String getUri() {
        return uri;
    }
}
