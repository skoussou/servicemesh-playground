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

import javax.enterprise.context.ApplicationScoped;


@ApplicationScoped
@Path("/status")
public class StatusSetResource {

    @ConfigProperty(name = "error.flag", defaultValue = "fail")
    String flag;


    @GET
    @Produces(MediaType.TEXT_PLAIN)
    @Path("/set/{flag}")
    public void setStatusFlag(@PathParam("flag")String flagValue) {
        System.out.println("FlagValue(b4)="+this.flag);    
	this.flag=flagValue;
	System.out.println("FlagValue(af)="+this.flag);
    }

    public String getFlag(){
      System.out.println("FlagValue="+this.flag);
      return flag;
    }

}
