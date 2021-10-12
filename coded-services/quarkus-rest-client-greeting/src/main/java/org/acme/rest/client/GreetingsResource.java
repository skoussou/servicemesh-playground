package org.acme.rest.client;

import java.util.Set;
import java.util.concurrent.CompletionStage;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.rest.client.inject.RestClient;
import org.jboss.resteasy.annotations.jaxrs.PathParam;

import io.smallrye.mutiny.Uni;

@Path("/say")
public class GreetingsResource {

    @Inject
    @RestClient
    GreetingsService greetingsServiceService;

    @GET
    @Path("/hello")
    @Produces(MediaType.APPLICATION_JSON)
    public String hello(@PathParam String name) {
        return greetingsServiceService.getSimpleHello();
    }

    @GET
    @Path("/goodday-to/{name}")
    @Produces(MediaType.APPLICATION_JSON)
    public String goodday(@PathParam String name) {
        return greetingsServiceService.getGreeting(name)+ ". And have a good day!";
    }

}
