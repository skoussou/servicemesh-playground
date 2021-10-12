package org.acme.getting.started;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.jboss.resteasy.annotations.jaxrs.PathParam;

import org.eclipse.microprofile.config.inject.ConfigProperty;


@Path("/hello")
public class GreetingResource {

    @ConfigProperty(name = "greeting.location", defaultValue = "Local")
    String location;
    
    @Inject
    GreetingService service;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/greeting/{name}")
    public String greeting(@PathParam String name) {
        return service.greeting(name);
    }

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        //return "Hello (Remotely) ";
        return "Hello ("+location+") ";
    }
}
