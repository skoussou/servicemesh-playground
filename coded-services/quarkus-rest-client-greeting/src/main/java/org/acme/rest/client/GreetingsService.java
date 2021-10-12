package org.acme.rest.client;

import java.util.Set;
import java.util.concurrent.CompletionStage;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;

import org.eclipse.microprofile.rest.client.inject.RegisterRestClient;
import org.jboss.resteasy.annotations.jaxrs.PathParam;

import io.smallrye.mutiny.Uni;

@Path("/hello")
@RegisterRestClient
public interface GreetingsService {


    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/greeting/{name}")
    String getGreeting(@PathParam String name);

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    String getSimpleHello() ;

}
