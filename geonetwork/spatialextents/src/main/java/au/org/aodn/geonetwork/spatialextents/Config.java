package au.org.aodn.geonetwork.spatialextents;

import it.geosolutions.geonetwork.GNClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class Config {

    @Value("${geonetwork.gnServiceUrl}")
    protected String gnServiceUrl;

    @Value("${geonetwork.gnUsername}")
    protected String gnUsername;

    @Value("${geonetwork.gnPassword}")
    protected String gnPassword;

    @Bean
    public GNClient createGNClient() {
        System.out.println(String.format("Connect to %s", gnServiceUrl));
        return new GNClient(gnServiceUrl,gnUsername,gnPassword);
    }
}
