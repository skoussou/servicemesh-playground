package org.acme.getting.started;

import javax.inject.Inject;
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
//import javax.ws.rs.BadRequestException;
import javax.ws.rs.ServerErrorException;

import org.jboss.resteasy.annotations.jaxrs.PathParam;

import org.eclipse.microprofile.config.inject.ConfigProperty;

import org.acme.getting.started.StatusSetResource;

@Path("/status")
public class StatusResource {

	@Inject
	StatusSetResource sr;

 //   @ConfigProperty(name = "error.flag", defaultValue = "fail")
 //   String flag;

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/check")
    public String greeting() {
//        if (flag.equals("fail")){
        if (sr.getFlag().equals("fail")){
          // throw new BadRequestException();
	  throw new ServerErrorException(503);
        }
        return "success";
    }

}
