package com.fujitsu.gwt.bewebapp.server;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Enumeration;
import java.util.List;
import org.socialbiz.cog.ConfigFile;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class FileUploadServlet extends HttpServlet {
    private String BES_ROOT = null;
    @Override
   protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        //super.doGet(req, resp);
        try{
            BES_ROOT = ConfigFile.getProperty("BusinessEntityRoot");
            if(!BES_ROOT.endsWith("/")){
                BES_ROOT = BES_ROOT + "/";
            }
        }catch(Exception e){
            throw new ServletException(e);
        }

        String action = req.getParameter("action");
        String prjName = req.getParameter("basename");
        //System.out.println("**** OPEN:" + action + ":");
        //System.out.println("**** prjName:" + prjName + ":");

        if("open".equalsIgnoreCase(action)){
            try {
                this.openFile(prjName, resp);
            }catch(Exception e){
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                   "An error occurred while opening the file : " + e.getMessage());
            }
            return;
        }
   }

     @Override
     protected void doPost(HttpServletRequest req, HttpServletResponse resp)
             throws ServletException, IOException {

         try{
            BES_ROOT = ConfigFile.getProperty("BusinessEntityRoot");
            if(!BES_ROOT.endsWith("/")){
                BES_ROOT = BES_ROOT + "/";
            }
        }catch(Exception e){
            throw new ServletException(e);
        }

        String action = req.getParameter("action");

        boolean opSuccess = true;
        String besname = null;
        String besdesc = null;
        String besloc = null;
        boolean formHasFile = false;


        // process only multipart requests
        if (ServletFileUpload.isMultipartContent(req)) {
             // Create a factory for disk-based file items
             FileItemFactory factory = new DiskFileItemFactory();

            // Create a new file upload handler
            ServletFileUpload upload = new ServletFileUpload(factory);

            // Parse the request
             try {

                 List<FileItem> items = upload.parseRequest(req);
                 for (FileItem item : items) {
                     if (item.isFormField()){
                         String fname = item.getFieldName();
                         if(fname.equals("besname"))
                             besname = item.getString();
                         else if(fname.equals("besdesc"))
                             besdesc = item.getString();
                         else if(fname.equals("besloc"))
                             besloc = item.getString();

                         //System.out.println("This is a FormField: "
                                // + item.getContentType() + " name: " + fname
                                // + " value: " + item.getString());
                     }else {
                         String fname = item.getName();
                         if(fname != null && fname.length() > 0){
                             formHasFile = true;
                         }
                        // System.out.println("This is NOT a FormField: "
                            //   + item.getContentType() + " name: " + fname
                                // + " value: " + item.getString());
                     }
                 }

                 for (FileItem item : items) {
                     // process only file upload - discard other form item types
                     if (item.isFormField()) {
                         continue;
                     }

                     String fileName = "";

                     if(besname == null || besname.length() == 0){
                         fileName = item.getName();
                         // get only the file name not whole path
                         if (fileName != null) {
                             fileName = FilenameUtils.getName(fileName);
                         }
                         besname = fileName;
                     }else{
                         fileName = besname + ".xml";
                     }
                     String upLoadDir = BES_ROOT + besloc + "/";
             // System.out.println("upLoadDir:" + upLoadDir);
                     File uploadedFile = new File(upLoadDir, fileName);
                     if (uploadedFile.createNewFile()) {
                         item.write(uploadedFile);
                         resp.setStatus(HttpServletResponse.SC_CREATED);
                         resp.getWriter().print("The file was created successfully.");
                         resp.flushBuffer();
                     } else {
                         opSuccess = false;
                         throw new IOException("The file already exists in repository.");
                     }

                 }

                 if(!formHasFile){
                    String filePath = BES_ROOT + besloc + "/" + besname + ".xml";
            //System.out.println("filePath:" + filePath);
                    File f = new File(filePath);
                    try {
                        Document doc = DOMUtils.createDocument(besname);
                        DOMUtils.writeDomToFile(doc, f);
                    } catch (Exception e) {
                        // TODO Auto-generated catch block
                        e.printStackTrace();
                    }

                  }


             } catch (Exception e) {
                 opSuccess = false;
                 resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                         "An error occurred while creating the file : " + e.getMessage());
             }

         } else {
             resp.sendError(HttpServletResponse.SC_UNSUPPORTED_MEDIA_TYPE,
                 "Request contents type is not supported by the servlet.");
         }

        try {
            if(opSuccess){
                int prjindx = besloc.indexOf("/");
                String prj = besloc.substring(prjindx+1);
                String bconf = BES_ROOT + besloc + "/" + prj + ".bes";
                String[] metaData = {besname, besdesc};
                updateBesProperties(bconf, metaData);
            }
        }catch(Exception e){
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR,
                    "Failed to Update BUsiness Entity Properties");
        }

     }

     private void updateBesProperties(
             String bConfFile,
             String metaData[]) throws Exception{

       InputStream is = new FileInputStream(bConfFile);
       Document doc = DOMUtils.convertInputStreamToDocument(is, false, false);
       is.close();

       if(metaData != null){
           Element root = doc.getDocumentElement();
           Element nChild = doc.createElement("entity");
           nChild.setAttribute("name", metaData[0]);
           nChild.setAttribute("desc", metaData[1]);
           root.appendChild(nChild);
       }

       DOMUtils.writeDomToFile(doc, new File(bConfFile));
     }

     private void openFile(
             String besname,
             HttpServletResponse resp)throws Exception{

         resp.setContentType("application/xml");
         String filePath = BES_ROOT + besname + ".xml";
         FileInputStream fis = new FileInputStream(filePath);

         byte[] buf = new byte[2048];
         int amtRead = fis.read(buf);
         OutputStream out = resp.getOutputStream();
         while (amtRead>0)
         {
             out.write(buf, 0, amtRead);
             amtRead = fis.read(buf);
         }
         fis.close();
         out.flush();
     }

}