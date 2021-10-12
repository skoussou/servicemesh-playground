package org.acme.getting.started;

import javax.enterprise.context.ApplicationScoped;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class GreetingService {

    @ConfigProperty(name = "greeting.location", defaultValue = "Local")
    String location;

    public String greeting(String name) {
        //return "Greetings (Remotely) " + name;
        return "Greetings ("+location+") " + name;
    }

}
