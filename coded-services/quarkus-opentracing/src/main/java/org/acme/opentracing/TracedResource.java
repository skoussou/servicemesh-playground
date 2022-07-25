package org.acme.opentracing;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.UriInfo;

import org.eclipse.microprofile.config.inject.ConfigProperty;
import org.eclipse.microprofile.rest.client.RestClientBuilder;
import org.jboss.logging.Logger;

import java.net.MalformedURLException;

@Path("/")
public class TracedResource {

    private static final Logger LOG = Logger.getLogger(TracedResource.class);

    @Inject
    FrancophoneService exampleBean;

    @ConfigProperty(name = "hello-service-url")
    protected String helloURL;

    @Context
    private UriInfo uriInfo;

    @GET
    @Path("/hello")
    @Produces(MediaType.TEXT_PLAIN)
    public String hello() {
        LOG.info("hello");
        return "hello";
    }

    @GET
    @Path("/chain")
    @Produces(MediaType.TEXT_PLAIN)
    public String chain() throws MalformedURLException {
        ResourceClient resourceClient = RestClientBuilder.newBuilder()
                .baseUri(uriInfo.getBaseUri()).baseUrl(new java.net.URL(helloURL))
                .build(ResourceClient.class);
        return "chain -> " + exampleBean.bonjour() + " -> " + resourceClient.hello();
    }
}
