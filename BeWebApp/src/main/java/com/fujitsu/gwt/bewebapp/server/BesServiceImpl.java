package com.fujitsu.gwt.bewebapp.server;

import java.io.File;

import org.w3c.dom.Document;

import com.fujitsu.gwt.bewebapp.client.BesService;
import org.socialbiz.cog.ConfigFile;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;



/**
 * The server side implementation of the RPC service.
 */
@SuppressWarnings("serial")
public class BesServiceImpl extends RemoteServiceServlet implements BesService {

    public String getBusinessEntity(String beid) throws IllegalArgumentException{
        try {
            String path = ConfigFile.getProperty("BusinessEntityRoot");
            if(!path.endsWith("/")){
                path = path + "/";
            }
            path = path + beid + ".xml";
            FileReader fReader = new FileReader(path,"UTF-8");
            return fReader.read();
        }catch(Exception e){
            throw new IllegalArgumentException(e);
        }
    }

    public String saveBusinessEntity(String beid, String data) throws IllegalArgumentException{
        try {
            String path = ConfigFile.getProperty("BusinessEntityRoot");
            if(!path.endsWith("/")){
                path = path + "/";
            }
            path = path + beid + ".xml";
            FileReader fReader = new FileReader(path,"UTF-8");
            fReader.write(data);
            return beid;
        }catch(Exception e){
            throw new IllegalArgumentException(e);
        }
    }

    public String createBusinessEntity(String[] beMetaData, String data) throws IllegalArgumentException {
        throw new IllegalArgumentException("Not Implemented");
    }

    public String getBusinessEntityList(String projetcId) throws IllegalArgumentException{
        try {

            //System.out.println("Server:GET BUSINESS ENTITY list");
            String filePath = getBesPath(projetcId);
            //System.out.println("Server:GET BUSINESS ENTITY" + filePath);
            FileReader fReader = new FileReader(filePath,"UTF-8");
            return fReader.read();
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException(e);
        }
    }

   public String deleteBusinessEntity(String beid) throws IllegalArgumentException{
        try{
            String path = ConfigFile.getProperty("BusinessEntityRoot");
            if(!path.endsWith("/")){
                path = path + "/";
            }
            path = path + beid + ".xml";
            File f = new File(path);
            f.delete();
            return beid;
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException(e);
        }
    }

   private String getBesPath(String root)throws Exception{

       int prjindx = root.indexOf("/");
       String prj = root.substring(prjindx+1);

       String path = ConfigFile.getProperty("BusinessEntityRoot");
       if(!path.endsWith("/")){
            path = path + "/";
        }
        path = path + root + "/";

       String besFile = path + prj + ".bes";
       File f = new File(besFile);

       if(!f.exists()){
           int indx = besFile.lastIndexOf("/");
           String besFolder = besFile.substring(0,indx);
           File dir = new File(besFolder);
           if(!dir.exists()){
               dir.mkdirs();
           }
           f.createNewFile();

           Document doc = DOMUtils.createDocument("entityList");
           DOMUtils.writeDomToFile(doc, f);

           //FileReader fReader = new FileReader(besFile,"UTF-8");
           //fReader.write(doc.toString());
       }

       return besFile;
   }

}

