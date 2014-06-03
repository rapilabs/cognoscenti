/*
 * Copyright 2013 Keith D Swenson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors Include: Shamim Quader, Sameer Pradhan, Kumar Raja, Jim Farris,
 * Sandia Yang, CY Chen, Rajiv Onat, Neal Wang, Dennis Tam, Shikha Srivastava,
 * Anamika Chaudhari, Ajay Kakkar, Rajeev Rastogi
 */

package org.socialbiz.cog.spring;

import java.io.StringWriter;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.socialbiz.cog.AccessControl;
import org.socialbiz.cog.AddressListEntry;
import org.socialbiz.cog.AttachmentRecord;
import org.socialbiz.cog.AuthDummy;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.DOMFace;
import org.socialbiz.cog.EmailSender;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.HtmlToWikiConverter;
import org.socialbiz.cog.LeafletResponseRecord;
import org.socialbiz.cog.MicroProfileMgr;
import org.socialbiz.cog.NGBook;
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.NGRole;
import org.socialbiz.cog.NoteRecord;
import org.socialbiz.cog.OptOutAddr;
import org.socialbiz.cog.OptOutDirectAddress;
import org.socialbiz.cog.ProfileRequest;
import org.socialbiz.cog.SearchManager;
import org.socialbiz.cog.SearchResultRecord;
import org.socialbiz.cog.SectionAttachments;
import org.socialbiz.cog.SectionDef;
import org.socialbiz.cog.SectionUtil;
import org.socialbiz.cog.UserManager;
import org.socialbiz.cog.UserPage;
import org.socialbiz.cog.UserProfile;
import org.socialbiz.cog.UtilityMethods;
import org.socialbiz.cog.WikiConverter;
import org.socialbiz.cog.WikiToPDF;
import org.socialbiz.cog.dms.FolderAccessHelper;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.socialbiz.cog.util.PDFUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

@Controller
public class MainTabsViewControler extends BaseController {

    private ApplicationContext context;
    @Autowired
    public void setContext(ApplicationContext context) {
        this.context = context;
    }


    @RequestMapping(value = "/{siteId}/{pageId}/projectHome.htm", method = RequestMethod.GET)
    public ModelAndView showProjectHomeTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return redirectBrowser(ar, "public.htm");
    }

    @RequestMapping(value = "/{siteId}/{pageId}/public.htm", method = RequestMethod.GET)
    public ModelAndView public_htm(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Notes");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.public");
            request.setAttribute("visibility_value", "1");
            return new ModelAndView("public");
        }catch(Exception ex){
            System.out.println("An exception occurred in public_htm"+ex.toString());
            throw new NGException("nugen.operation.fail.project.public.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/member.htm", method = RequestMethod.GET)
    public ModelAndView member_htm(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            request.setAttribute("subTabId", "nugen.projecthome.subtab.member");
            request.setAttribute("visibility_value", "2");

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Notes");
            return new ModelAndView("member");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.member.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/deletedNotes.htm", method = RequestMethod.GET)
    public ModelAndView deletedNotes_htm(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Notes");

            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            modelAndView=new ModelAndView("leaf_deleted");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.deletedNotes");
            request.setAttribute("visibility_value", "4");
            return modelAndView;
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.delete.notes.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/draftNotes.htm", method = RequestMethod.GET)
    public ModelAndView draftNotes(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
           throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            modelAndView=new ModelAndView("leaf_draftNotes");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.draftNotes");
            request.setAttribute("visibility_value", "4");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Notes");
            return modelAndView;
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.draft.notes.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/projectSettings.htm", method = RequestMethod.GET)
    public ModelAndView showProjectSettingsTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return redirectBrowser(ar, "personal.htm");
    }

    @RequestMapping(value = "/{siteId}/{pageId}/attachment.htm", method = RequestMethod.GET)
    public ModelAndView showAttachmentTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("subTabId", "nugen.projecthome.subtab.documents");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Documents");

            registerRequiredProject(ar, siteId, pageId);

            return new ModelAndView("leaf_attach");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.attachment.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/deletedAttachments.htm", method = RequestMethod.GET)
    public ModelAndView showDeletedAttachments(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Documents");

            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }
            request.setAttribute("subTabId", "nugen.projecthome.subtab.deleted");
            return new ModelAndView("leaf_deleted_attach");
        }
        catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.delete.attachment.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/process.htm", method = RequestMethod.GET)
    public ModelAndView showProcessTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return redirectBrowser(ar, "projectActiveTasks.htm");
    }



    @RequestMapping(value = "/{siteId}/{pageId}/ganttchart.htm", method = RequestMethod.GET)
    public ModelAndView showGanttChart(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Tasks");

            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }
            request.setAttribute("active", ar.defParam("active", "1"));
            return new ModelAndView("ganttchart");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/permission.htm", method = RequestMethod.GET)
    public ModelAndView showPermissionTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.Permissions");

            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            List<NGRole> roles = nGPage.getAllRoles();

            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            modelAndView = new ModelAndView("permission");

            //TODO: eliminate these unnecessary parameters
            request.setAttribute("roles", roles);
            modelAndView.addObject("page", nGPage);

            return modelAndView;
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.permission.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/history.htm", method = RequestMethod.GET)
    public ModelAndView showHistoryTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Stream");

            registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            request.setAttribute("messages", context);
            return new ModelAndView("history");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.history.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value="/{siteId}/{pageId}/a/{docName}.{ext}", method = RequestMethod.GET)
     public void loadDocument(
           @PathVariable String siteId,
           @PathVariable String pageId,
           @PathVariable String docName,
           @PathVariable String ext,
           HttpServletRequest request,
           HttpServletResponse response) throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);

            String attachmentName = docName+"."+ext;
            AttachmentRecord att = nGPage.findAttachmentByNameOrFail(attachmentName);

            boolean canAccessDoc = AccessControl.canAccessDoc(ar, nGPage, att);

            if(!canAccessDoc){
                String msgKey = "message.loginalert.access.attachment";
                if(att.getVisibility() != SectionDef.PUBLIC_ACCESS){
                    msgKey = "message.loginalert.access.non.public.attachment";
                }
                sendRedirectToLogin(ar, msgKey,null);
                return;
            }

            String version = ar.defParam("version", null);
            if(version != null && !"".equals(version)){
               SectionAttachments.serveUpFileNewUI(ar, nGPage, attachmentName,Integer.parseInt(version));
            }else{
               SectionAttachments.serveUpFile(ar, nGPage, attachmentName);
            }
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.download.document", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value="/{siteId}/{pageId}/f/{docId}.{ext}", method = RequestMethod.GET)
    public void loadRemoteDocument(
            @PathVariable String siteId,
            @PathVariable String pageId,
            @PathVariable String docId,
            @PathVariable String ext,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        try{
            AuthRequest ar  = AuthRequest.getOrCreate(request, response);

            NGPageIndex.assertBook(siteId);
            NGPageIndex.getProjectByKeyOrFail(pageId);

            String symbol = ar.reqParam("fid");

            FolderAccessHelper fah = new FolderAccessHelper(ar);
            fah.serveUpRemoteFile(symbol);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.download.document", new Object[]{pageId,siteId} , ex);
        }
    }

    /**
    * note that the docid in the path is not needed, but it will be different for
    * every file for convenience of auto-generating a file name to save to.
    *
    * following the name is a bunch of query paramters listing the notes to include in the output.
    */
    @RequestMapping(value="/{siteId}/{pageId}/pdf/{docId}.pdf", method = RequestMethod.GET)
    public void generatePDFDocument(
            @PathVariable String siteId,
            @PathVariable String pageId,
            @PathVariable String docId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPageIndex.assertBook(siteId);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);

            //this constructs and outputs the PDF file to the output stream
            WikiToPDF.handlePDFRequest(ar, ngp);

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.download.document", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value="/{siteId}/{pageId}/pdf1/{docId}.{ext}", method = RequestMethod.POST)
    public void generatePDFDocument(
            @PathVariable String siteId,
            @PathVariable String pageId,
            @PathVariable String docId,
            @PathVariable String ext,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);

            PDFUtil pdfUtil = new PDFUtil();
            pdfUtil.serveUpFile(ar, pageId);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.download.document", new Object[]{pageId,siteId} , ex);
        }
    }


     @RequestMapping(value = "/index.htm", method = RequestMethod.GET)
     public ModelAndView showLandingPage(HttpServletRequest request, HttpServletResponse response)
                throws Exception {
         ModelAndView modelAndView = null;
         try{
             AuthRequest ar = AuthRequest.getOrCreate(request, response);
             NGPageIndex.assertInitialized();
             //if the user is logged in, redirect to their own home page instead
             if (ar.isLoggedIn())
             {
                 response.sendRedirect(ar.retPath+"v/"+ar.getUserProfile().getKey()+"/watchedProjects.htm");
                 return null;
             }

             modelAndView=new ModelAndView("landingPage");
             request.setAttribute("realRequestURL", ar.getRequestURL());
             List<NGBook> list=new ArrayList<NGBook>();
             for (NGBook ngb : NGBook.getAllSites()) {
                 list.add(ngb);
             }

             request.setAttribute("headerType", "index");
             //TODO: see if bookList is really needed
             modelAndView.addObject("bookList",list);
         }catch(Exception ex){
             throw new NGException("nugen.operation.fail.project.welcome.page", null , ex);
         }
         return modelAndView;
     }


     @RequestMapping(value = "/texteditor.htm", method = RequestMethod.GET)
     public ModelAndView openTextEditor(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

         ModelAndView modelAndView = null;

         try{
             modelAndView = new ModelAndView("texteditor");
             AuthRequest ar = AuthRequest.getOrCreate(request, response);
             if(!ar.isLoggedIn()){
                 return showWarningView(ar, "message.loginalert.see.page");
             }

             String p = ar.reqParam("pid");
             NGContainer ngp = NGPageIndex.getContainerByKeyOrFail(p);
             ar.setPageAccessLevels(ngp);
             ar.assertMember("Need Member Access to Create a Note.");
             modelAndView.addObject("pageTitle",ngp.getFullName());
             request.setAttribute("title",ngp.getFullName());
         }catch(Exception ex){
             throw new NGException("nugen.operation.fail.project.create.note.page", null , ex);
         }
         return modelAndView;
     }



     @RequestMapping(value = "/sendNoteByEmail.htm", method = RequestMethod.GET)
     public ModelAndView sendNoteByEmail(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

         ModelAndView modelAndView = null;
         try{
             AuthRequest ar = AuthRequest.getOrCreate(request, response);
             if(!ar.isLoggedIn()){
                 return showWarningView(ar, "message.loginalert.see.page");
             }

             modelAndView=new ModelAndView("SendNoteByEmail");
             request.setAttribute(ar.defParam("selectedAttachemnt",""), "true");
             ar.preserveRealRequestURL();
         }catch(Exception ex){
             throw new NGException("nugen.operation.fail.project.sent.note.by.email.page", null , ex);
         }
         return modelAndView;
     }

    //allow a user to change their email subscriptions, including opt out
    //even when not logged in.
    @RequestMapping(value = "/EmailAdjustment.htm", method = RequestMethod.GET)
    public ModelAndView emailAdjustment(HttpServletRequest request, HttpServletResponse response)
        throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            ar.preserveRealRequestURL();
            return new ModelAndView("EmailAdjustment");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.sent.note.by.email.page", null , ex);
        }
    }

    //allow a user to change their email subscriptions, including opt out
    //even when not logged in.
    @RequestMapping(value = "/EmailAdjustmentAction.form", method = RequestMethod.POST)
    public void emailAdjustmentActionForm(HttpServletRequest request, HttpServletResponse response)
        throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            ar.preserveRealRequestURL();

            String p = ar.reqParam("p");
            String email = ar.reqParam("email");
            String mn = ar.reqParam("mn");
            String go = ar.defParam("go", ar.baseURL);

            NGContainer ngp = NGPageIndex.getContainerByKeyOrFail(p);
            String expectedMn = ngp.emailDependentMagicNumber(email);
            if (!expectedMn.equals(mn)) {
                throw new Exception("Something is wrong, improper request for email address "+email);
            }

            String cmd = ar.reqParam("cmd");
            if ("Remove Me".equals(cmd)) {
                String role = ar.reqParam("role");
                NGRole specRole = ngp.getRoleOrFail(role);
                specRole.removePlayer(new AddressListEntry(email));
            }
            else {
                throw new Exception("emailAdjustmentActionForm does not understand the cmd "+cmd);
            }

            response.sendRedirect(go);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.sent.note.by.email.page", null , ex);
        }
    }


     @RequestMapping(value = "/{siteId}/{pageId}/leaflet{lid}.htm", method = RequestMethod.GET)
     public ModelAndView displayOneLeaflet(@PathVariable String lid, @PathVariable String pageId,
            @PathVariable String siteId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            NoteRecord note = nGPage.getNoteOrFail(lid);


            request.setAttribute("lid", lid);
            request.setAttribute("zoomMode", true);
            request.setAttribute("noteName", note.getSubject() );
            request.setAttribute("title", note.getSubject()+" - "+nGPage.getFullName());
            request.setAttribute("tabId", "Project Notes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            return new ModelAndView("NoteZoomView");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.zoom.note.page", new Object[]{lid,pageId,siteId} , ex);
        }
    }

     @RequestMapping(value = "/previewNoteForEmail.htm", method = RequestMethod.GET)
     public ModelAndView previewNoteForEmail(HttpServletRequest request, HttpServletResponse response)
            throws Exception {

         ModelAndView modelAndView = null;
         try{
             AuthRequest ar = AuthRequest.getOrCreate(request, response);
             if(!ar.isLoggedIn()){
                 return showWarningView(ar, "message.loginalert.see.page");
             }
             modelAndView = new ModelAndView("PreviewNoteForEmail");
             String editedSubject = ar.defParam("subject", "");
             request.setAttribute("subject", editedSubject);
         }catch(Exception ex){
             throw new NGException("nugen.operation.fail.project.preview.note.email.page", null , ex);
         }
         return modelAndView;
     }

     @RequestMapping(value = "/createLeafletSubmit.ajax", method = RequestMethod.POST)
     public void createLeaflet(HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        String responseText = null;
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        try {
            ar.assertLoggedIn("Must be logged in to create a note.");
            String p = ar.reqParam("p");
            NGContainer ngp = NGPageIndex.getContainerByKeyOrFail( p );
            ar.setPageAccessLevels(ngp);

            JSONObject paramMap = new JSONObject();
            String noteId = "";
            String action = ar.reqParam("action");
            if (!"Save".equals(action) && !"Undelete".equals(action) && !"SaveAsDraft".equals(action)) {
                String oid = ar.reqParam("oid");
                NoteRecord note = ngp.getNoteOrFail(oid);

                if(note.isDeleted()){
                    paramMap.put(Constant.MSG_TYPE, Constant.FAILURE);
                    paramMap.put(Constant.MESSAGE, "Note has already been deleted.");
                    paramMap.put(Constant.COMMENTS , "");
                }else{
                    if("publish".equals(action)){
                        note.setSaveAsDraft("no");
                        paramMap.put("visibility", String.valueOf(note.getVisibility()));
                        paramMap.put("subject", String.valueOf(note.getSubject()));
                    }else{
                        noteId = handleCreateLeaflet(ar, ngp);
                        if("UpdateAndPublish".equals(action)){
                            note.setSaveAsDraft("no");
                        }
                        note = ngp.getNoteOrFail(oid);
                    }
                    ngp.saveContent( ar, responseText);
                    paramMap.put(Constant.MSG_TYPE, Constant.SUCCESS);
                    paramMap.put("noteId", noteId);
                }
            }else{
                noteId = handleCreateLeaflet(ar, ngp);
                ngp.saveContent( ar, responseText);
                paramMap.put(Constant.MSG_TYPE, Constant.SUCCESS);
                paramMap.put("noteId", noteId);
            }

            responseText = paramMap.toString();
        }
        catch (Exception ex) {
            responseText = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by createLeafletSubmit.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, responseText);
    }

    private String handleCreateLeaflet(AuthRequest ar, NGContainer ngp) throws Exception {

        ar.assertLoggedIn("Must be logged in to create a new note.");

        String action = ar.reqParam("action");
        int visibility = DOMFace.safeConvertInt(ar.reqParam("visibility"));
        String subject = ar.defParam("subj", "");
        if ("Save".equals(action) || "SaveAsDraft".equals(action)) {

            HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
            String val = ar.defParam("val",  "");
            String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL, val);

            NoteRecord note = ngp.createNote();
            note.setSubject( subject );
            note.setVisibility(visibility);
            note.setEditable(DOMFace.safeConvertInt(ar.reqParam("editable")));
            note.setData(wikiText);
            note.setEffectiveDate(ar.nowTime);
            note.setLastEdited(ar.nowTime);
            note.setLastEditedBy(ar.getBestUserId());
            if("SaveAsDraft".equals(action)){
                note.setSaveAsDraft("yes");
            }
            HistoryRecord.createHistoryRecord(ngp, note.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_CREATED,
                    ar, "");

            return note.getId();
        }

         //everything after this point requires an existing comment
        String oid =ar.reqParam("oid");
        if ("Update".equals(action) || "UpdateAndPublish".equals(action)) {
            NoteRecord note = ngp.getNoteOrFail(oid);
            assertEditNote(ngp, note, ar);

            HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
            String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL, ar.defParam("val",  ""));

            note.setVisibility(DOMFace.safeConvertInt(ar.reqParam("visibility")));
            note.setEditable(DOMFace.safeConvertInt(ar.reqParam("editable")));
            note.setEffectiveDate(SectionUtil.niceParseDate(ar.defParam("effDate", "")));
            note.setSubject(subject);
            note.setData(wikiText);

            String pin = ar.defParam("pin", null);
            if (pin!=null) {
                note.setPinOrder(DOMFace.safeConvertInt(pin));
            }
            String choices = ar.defParam("choices", null);
            if (choices!=null) {
                note.setChoices(choices);
            }

            note.setLastEdited(ar.nowTime);
            note.setLastEditedBy(ar.getBestUserId());
            HistoryRecord.createHistoryRecord(ngp, note.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_MODIFIED,
                    ar, "");

            return note.getId();
        }
        else if("Change Visibility".equals( action )){
            NoteRecord note = ngp.getNoteOrFail( oid );
            assertEditNote(ngp,note,ar);
            note.setVisibility(visibility);
            note.setEffectiveDate(SectionUtil.niceParseDate(ar.defParam("effDate", "")));
            HistoryRecord.createHistoryRecord(ngp, note.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_LEVEL_CHANGE,
                    ar, "");
            return oid;
        }
        else if ("Remove".equals(action))
        {
            NoteRecord note = ngp.getNoteOrFail(oid);
            assertEditNote(ngp,note,ar);
            ngp.deleteNote(oid,ar);
            HistoryRecord.createHistoryRecord(ngp, note.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_DELETED,
                    ar, "");
            return oid;
        }
        else if ("Undelete".equals(action))
        {
            ngp.unDeleteNote( oid,ar);
            return oid;
        }

        throw new NGException("nugen.exceptionhandling.system.not.understand.action",new Object[]{action});
    }


    //Does this work on Page as well?
    public NoteRecord updateNoteBook(NGBook ngb, String id, String subject, AuthRequest ar)
            throws Exception {

        ar.assertLoggedIn("Must be logged in to update a note.");
        UserProfile up = ar.getUserProfile();

        String val = ar.defParam("val",  "");
        String choices = ar.defParam("choices", null);

        HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
        String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL,val);

        int visibility = DOMFace.safeConvertInt(ar.reqParam("visibility"));
        int editable   = DOMFace.safeConvertInt(ar.reqParam("editable"));

        NoteRecord note = ngb.getNoteOrFail( id );
        assertEditNote(ngb, note, ar);

        note.setLastEdited(ar.nowTime);
        note.setLastEditedBy(up.getUniversalId());
        note.setSubject(subject);
        note.setData(wikiText);
        note.setVisibility(visibility);
        note.setEditable(editable);
        String effDate = ar.defParam("effDate", null);
        if (effDate != null)
        {
            note.setEffectiveDate(SectionUtil.niceParseDate(effDate));
        }
        String pin = ar.defParam("pin", null);
        if (pin!=null)
        {
            note.setPinOrder(DOMFace.safeConvertInt(pin));
        }
        note.setChoices(choices);
        HistoryRecord.createHistoryRecord(ngb, note.getId(),
                HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_MODIFIED,
                ar, "");
        ngb.saveFile(ar, "updating a note");

        return note;
    }

    /**
     * Throws an exception if the currently logged in user does not have the right to
     * edit the passed in note.
     */
    private void assertEditNote(NGContainer ngc, NoteRecord note, AuthRequest ar)
            throws Exception {
        UserProfile up = ar.getUserProfile();

        //admins of the container can do anything
        if (ngc.primaryPermission(up)) {
            return;
        }
        if (note.getEditable() == NoteRecord.EDIT_OWNER) {
            if (!up.hasAnyId(note.getOwner())) {
                throw new Exception( "Unable to edit this note because it is marked "
                        + "to only be edited only by the owner: " + note.getOwner());
            }
        }
        else if (note.getEditable() == NoteRecord.EDIT_MEMBER) {
            if (!ngc.primaryOrSecondaryPermission(up)) {
                throw new Exception("User '" + up.getName() + "' can not edit note '"
                        + note.getId() + "'");
            }
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/leafletResponse.htm", method = RequestMethod.POST)
    public ModelAndView handleLeafletResponse(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try {
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);

            String go = ar.reqParam("go");
            String action = ar.reqParam("action");

            String lid = ar.reqParam("lid");
            String data = ar.defParam("data", null);
            String choice = ar.defParam("choice", null);

            NoteRecord note = ngp.getNoteOrFail(lid);
            LeafletResponseRecord llr;

            String uid = ar.reqParam("uid");
            UserProfile designatedUser = UserManager.findUserByAnyId(uid);
            if (designatedUser == null) {
                // As Micro-profile concept has been introduced, so
                // Micro-profile will be created
                // instead of creating a new user profile.
                MicroProfileMgr.setDisplayName(uid, uid);
                MicroProfileMgr.save();
                //finds or creates a response for a user ID that has no profile.
                llr = note.accessResponse(uid);
            }
            else {
                //finds the response for a user with a profile
                llr = note.getOrCreateUserResponse(designatedUser);
            }

            if (action.startsWith("Update")) {
                //Note: we do not need to have "note edit" permission here
                //because we are only changing a response record.  We only need
                //note 'access' permissions which might come from magic number
                if (AccessControl.canAccessNote(ar, ngp, note)) {
                    llr.setData(data);
                    llr.setChoice(choice);
                    llr.setLastEdited(ar.nowTime);
                    ngp.save(uid, ar.nowTime, "Updated response to note");
                }
            }
            modelAndView = new ModelAndView(new RedirectView(go));
        }
        catch (Exception ex) {
            throw new NGException("nugen.operation.fail.project.note.response", new Object[] {
                    pageId, siteId }, ex);
        }
        return modelAndView;
    }


    @RequestMapping(value = "/{siteId}/{pageId}/personal.htm", method = RequestMethod.GET)
    public ModelAndView showPersonalTab(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try {
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);

            if (!ar.isLoggedIn()) {
                return showWarningView(ar, "nugen.project.personal.login.msg");
            }

            //signing up as member or other operations require name and email address
            if (needsToSetName(ar)) {
                return new ModelAndView("requiredName");
            }
            if (needsToSetEmail(ar)) {
                return new ModelAndView("requiredEmail");
            }

            ModelAndView modelAndView = new ModelAndView("personal");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.personal");
            request.setAttribute("visibility_value", "4");

            modelAndView.addObject("page", nGPage);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
            return modelAndView;
        }
        catch (Exception ex) {
            throw new NGException("nugen.operation.fail.project.personal.page", new Object[] {
                    pageId, siteId }, ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/admin.htm", method = RequestMethod.GET)
    public ModelAndView showAdminTab(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.login.msg");
            }
            //signing up as member or other operations require name and email address
            if (needsToSetName(ar)) {
                return new ModelAndView("requiredName");
            }
            if (needsToSetEmail(ar)) {
                return new ModelAndView("requiredEmail");
            }
            if(!ar.isMember()){
                ar.req.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.project.member.msg");
            }


            request.setAttribute("tabId", "Project Settings");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.Admin");
            request.setAttribute("visibility_value", "3");
            return new ModelAndView("leaf_admin");
        }catch (Exception ex) {
            throw new NGException("nugen.operation.fail.project.admin.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/streamingLinks.htm", method = RequestMethod.GET)
    public ModelAndView streamingLinks(@PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            modelAndView = new ModelAndView("leaf_streamingLinks");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.personal");
            request.setAttribute("visibility_value", "4");

            modelAndView.addObject("page", nGPage);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
            return modelAndView;
        }
        catch (Exception ex) {
            throw new NGException("nugen.operation.fail.project.personal.page", new Object[] {
                    pageId, siteId }, ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/synchronizeUpstream.htm", method = RequestMethod.GET)
    public ModelAndView synchronizeUpstream(@PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response) throws Exception {
        try {
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            ModelAndView modelAndView= memberCheckViews(ar);
            if (modelAndView!=null) {
                return modelAndView;
            }

            modelAndView = new ModelAndView("synchronizeUpstream");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.personal");
            request.setAttribute("visibility_value", "4");

            modelAndView.addObject("page", nGPage);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
            return modelAndView;
        }
        catch (Exception ex) {
            throw new NGException("nugen.operation.fail.project.personal.page", new Object[] {
                    pageId, siteId }, ex);
        }
    }


    @RequestMapping(value = "/{userKey}/TagLinks.htm", method = RequestMethod.GET)
    public ModelAndView TagLinks(@PathVariable String userKey,
        HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        try {
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            if(!ar.isLoggedIn()){
                return showWarningView(ar, "message.loginalert.see.page");
            }

            request.setAttribute("headerType", "user");
            request.setAttribute("tabId", "Home");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("userKey",userKey);
            return new ModelAndView("TagLinks");
        }
        catch(Exception ex) {
            throw new NGException("nugen.operation.fail.project.taglinks.page",null , ex);
        }
    }

    /**
     * This is search page that you get when NOT LOGGED IN from the
     * landing page.  However, you can also see this when logged in.
     */
    @RequestMapping(value = "/searchPublicNotes.htm")
    public ModelAndView searchPublicNotes(
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            String searchText   = ar.reqParam("searchText");
            String b = ar.defParam("b", null);
            if ("All Books".equals(b)) {
                b = null;
            }
            String pf = ar.defParam("pf", "all");

            SearchManager.initializeIndex();
            List<SearchResultRecord> searchResults = SearchManager.performSearch(ar, searchText, pf, b);
            request.setAttribute("searchResults",searchResults);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.search.public.note.page", null , ex);
        }
        return  new ModelAndView("showSearchResult");
    }

    @RequestMapping(value = "/{siteId}/{pageId}/subprocess.htm", method = RequestMethod.GET)
    public ModelAndView showSubProcessTab(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response,@RequestParam String subprocess)
              throws Exception {

        ModelAndView modelAndView = null;
        try{
            request.setAttribute("book", siteId);
            request.setAttribute("pageId", pageId);
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPageIndex.assertBook(siteId);
            modelAndView=new ModelAndView("ProjectActiveTasks");

            request.setAttribute("subprocess", subprocess);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Tasks");
        }
        catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.subprocess.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/reminders.htm", method = RequestMethod.GET)
    public ModelAndView remindersTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.reminders.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.projecthome.reminders.memberlogin");
            }

            request.setAttribute("subTabId", "nugen.projecthome.subtab.reminders");

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Documents");
            return new ModelAndView("reminders");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.reminder.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/inviteUser.htm", method = RequestMethod.GET)
    public ModelAndView inviteUers(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);

            // Set the Index page name
            List<NGRole> roles=nGPage.getAllRoles();

            String userId = ar.reqParam( "emailId" );
            ModelAndView modelAndView = new ModelAndView("inviteUser");
            modelAndView.addObject("page", nGPage);
            modelAndView.addObject("emailId", userId);

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("roles", roles);
            request.setAttribute("tabId", "Project Settings");
            request.setAttribute("subTabId", "nugen.projectsettings.subtab.Permissions");
            return modelAndView;
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.invite.user.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/CommentEmailAction.form", method = RequestMethod.POST)
    public void commentEmailAction(HttpServletRequest request, HttpServletResponse response)
        throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        if(!ar.isLoggedIn()){
            sendRedirectToLogin(ar, "message.loginalert.send.email",null);
            return;
        }

        String go = ar.reqParam("go");
        String encodingGuard  = ar.reqParam("encodingGuard");
        if (!"\u6771\u4eac".equals(encodingGuard)) {
            throw new Exception("values are corrupted");
        }

        String action = ar.reqParam("action");
        String p = ar.reqParam("p");
        String oid = ar.reqParam("oid");
        String emailto = ar.defParam("emailto", null);
        boolean fromPerson = "person".equals(ar.defParam("emailFrom", "person"));
        String toRole = ar.defParam("toRole", null);
        String note = ar.defParam("note", "");
        boolean exclude = (ar.defParam("exclude", null)!=null);
        boolean self    = (ar.defParam("self", null)!=null);
        boolean makeMember = (ar.defParam("makeMember", null)!=null);
        boolean includeBodyInMail = (ar.defParam("includeBody", null)!=null);
        NGContainer ngp = NGPageIndex.getContainerByKeyOrFail(p);
        ar.setPageAccessLevels(ngp);
        ar.assertNotFrozen(ngp);

        String subject = ar.defParam("subject", null);

        NoteRecord noteRec = null;
        if (!oid.equals("x")) {
            noteRec = ngp.getNoteOrFail(oid);
        }

        StringBuffer outParams = new StringBuffer();
        appendIfNotNull(outParams, "?p=", p);
        appendIfNotNull(outParams, "&oid=", oid);
        appendIfNotNull(outParams, "&note=", note);
        appendIfNotNull(outParams, "&go=", go);
        appendIfNotNull(outParams, "&encodingGuard=", "\u6771\u4eac");
        if (exclude)
        {
            outParams.append("&exclude=true");
        }
        appendIfNotNull(outParams, "&toRole=", toRole);
        if (includeBodyInMail)
        {
            outParams.append("&includeBody=true");
        }
        appendIfNotNull(outParams, "&emailto=", emailto);
        appendIfNotNull(outParams, "&subject=", subject);
        for (AttachmentRecord att : ngp.getAllAttachments())
        {
            String paramId = "attach"+att.getId();
            String attParam = ar.defParam(paramId, null);
            if (attParam!=null)
            {
                outParams.append("&");
                outParams.append(paramId);
                outParams.append("=true");
            }
        }
        if (action.equals("Edit Mail"))
        {
            response.sendRedirect(ar.retPath+"t/sendNoteByEmail.htm"+outParams.toString());
            return;
        }
        if (action.equals("Preview Mail"))
        {
            response.sendRedirect(ar.retPath+"t/previewNoteForEmail.htm"+outParams.toString());
            return;
        }
        if (action.equals("Send Mail"))
        {
            if(!(ngp instanceof NGPage)) {
                throw new ProgramLogicError("The Send Mail Function is currently only able to handle NGPage objects");
                //the Members, Administrators, and Executives roles may not be available on other
                //classes, and may cause null pointer exceptions.
            }
            Vector<OptOutAddr> sendTo = new Vector<OptOutAddr>();
            if(toRole!=null){
                String[] sentToRole = UtilityMethods.splitOnDelimiter(toRole, ',');
                for(int i=0; i<sentToRole.length; i++){
                    String roleName = sentToRole[i];
                    NGRole role = ngp.getRole(roleName);
                    if (role!=null) {
                        NGWebUtils.appendUsersFromRole(ngp, roleName, sendTo);
                    }
                }
            }
            if (emailto!=null && emailto.length()>0) {
                NGRole memberRole = ngp.getRoleOrFail("Members");
                for (AddressListEntry enteredAddress : AddressListEntry.parseEmailList(emailto)) {
                    NGWebUtils.appendOneUser(new OptOutDirectAddress(enteredAddress), sendTo);
                    if(makeMember && !ngp.primaryOrSecondaryPermission(enteredAddress)) {
                        memberRole.addPlayer(enteredAddress);
                    }
                }
            }
            if (exclude) {
                for (LeafletResponseRecord llr : noteRec.getResponses()) {
                    String responder = llr.getUser();
                    removeFromList(sendTo, responder);
                }
            }
            if (self) {
                AddressListEntry aleself = new AddressListEntry(ar.getUserProfile());
                NGWebUtils.appendOneUser(new OptOutDirectAddress(aleself), sendTo);
            }

            StringBuffer historyNameList = new StringBuffer();
            boolean needComma = false;
            for (OptOutAddr ooa : sendTo)
            {
                String addr = ooa.getEmail();
                if (addr!=null && addr.length()>0)
                {
                    sendMessageToUser(ar, ngp, noteRec, ooa, fromPerson);
                    if (needComma)
                    {
                        historyNameList.append(",");
                    }
                    historyNameList.append(addr);
                    needComma= true;
                }
            }

            if(ngp instanceof NGPage){
                //OK, done, so write history about it
                HistoryRecord.createHistoryRecord(ngp,
                        oid, HistoryRecord.CONTEXT_TYPE_LEAFLET,0,
                        HistoryRecord.EVENT_EMAIL_SENT, ar, historyNameList.toString());
                ngp.saveContent(ar, "Sent a note by email");
                //note this also may save some of the new members if there are any
            }
        }
        response.sendRedirect(go);
    }




    private void appendIfNotNull(StringBuffer outParams, String prompt, String value) throws Exception {
        if (value!=null)
        {
            outParams.append(prompt);
            outParams.append(URLEncoder.encode(value, "UTF-8"));
        }
    }

    private void removeFromList(Vector<OptOutAddr> sendTo, String email) {
        OptOutAddr found = null;
        for (OptOutAddr ooa : sendTo) {
            if (ooa.matches(email)) {
                found = ooa;
                break;
            }
        }
        if (found!=null) {
            sendTo.remove(found);
        }
    }


      public void sendMessageToUser(AuthRequest ar, NGContainer ngp, NoteRecord noteRec, OptOutAddr ooa, boolean fromPerson)
          throws Exception
      {
          String userAddress = ooa.getEmail();
          if (userAddress==null || userAddress.length()==0)
          {
              //don't send anything if the user does not have an email address
              return;
          }
          String note = ar.defParam("note", "");

          StringWriter bodyWriter = new StringWriter();
          AuthRequest clone = new AuthDummy(ar.getUserProfile(), bodyWriter);
          clone.setNewUI(true);
          clone.retPath = ar.baseURL;
          clone.write("<html><body>");
          List<AttachmentRecord> attachList = NGWebUtils.getSelectedAttachments(ar, ngp);
          Vector<String> attachIds = new Vector<String>();

          //if you really want the files attached to the email message, then include a list of
          //their attachment ids here
          boolean includeFiles = (ar.defParam("includeFiles", null)!=null);
          if (includeFiles) {
              for (AttachmentRecord att : attachList) {
                  attachIds.add(att.getId());
              }
          }

          boolean tempmem = (ar.defParam("tempmem", null)!=null);
          boolean includeBody = (ar.defParam("includeBody", null)!=null);
          writeNoteAttachmentEmailBody(clone, ar.ngp, noteRec, tempmem, ooa.getAssignee(), note,
                includeBody, attachList);

          NGWebUtils.standardEmailFooter(clone, ar.getUserProfile(), ooa, ngp);

          clone.write("</body></html>");

          String subject = ar.defParam("subject", "Documents from Project "+ngp.getFullName());
          String fromAddress = null;
          if (fromPerson) {
              UserProfile up = ar.getUserProfile();
              if (up==null) {
                  throw new Exception("Problem with session: no user profile.  In order to send an email message usermust be logged in.");
              }
              fromAddress = up.getEmailWithName();
          }
          EmailSender.containerEmail(ooa, ngp, subject, bodyWriter.toString(), fromAddress, attachIds);
      }

      public static void writeNoteAttachmentEmailBody(AuthRequest ar,
              NGContainer ngp, NoteRecord selectedNote, boolean tempmem,
              AddressListEntry ale, String note, boolean includeBody,
              List<AttachmentRecord> selAtt) throws Exception {
          ar.write("<p><b>Note From:</b> ");
          ar.getUserProfile().writeLink(ar);
          ar.write(" &nbsp; <b>Project:</b> ");
          ngp.writeContainerLink(ar, 100);
          ar.write("</p>");
          ar.write("\n<p>");
          ar.writeHtml(note);
          ar.write("</p>");
          if (selAtt != null && selAtt.size() > 0) {
              ar.write("</p>");
              ar.write("\n<p><b>Attachments:</b> (click links for secure access to documents)<ul> ");
              for (AttachmentRecord att : selAtt) {
                  ar.write("<li><a href=\"");
                  ar.write(ar.retPath);
                  ar.write(ar.getResourceURL(ngp, "docinfo" + att.getId()
                          + ".htm?"));
                  ar.write(AccessControl.getAccessDocParams(ngp, att));
                  ar.write("\">");
                  ar.writeHtml(att.getNiceName());
                  ar.write("</a></li> ");
              }
              ar.write("</ul></p>");
          }
          if (selectedNote != null) {
              String noteURL = ar.retPath + ar.getResourceURL(ngp, selectedNote)
                      + "?" + AccessControl.getAccessNoteParams(ngp, selectedNote)
                      + "&emailId=" + URLEncoder.encode(ale.getEmail(), "UTF-8");
              if (includeBody) {
                  ar.write("\n<p><i>The note is copied below. You can access the most recent, ");
                  ar.write("most up to date version on the web at the following link:</i> <a href=\"");
                  ar.write(noteURL);
                  ar.write("\" title=\"Access the latest version of this message\"><b>");
                  if (selectedNote.getSubject() != "" && selectedNote.getSubject() != null) {
                      ar.writeHtml(selectedNote.getSubject());
                  }
                  else {
                      ar.writeHtml("Note Link");
                  }
                  ar.write("</b></a></p>");
                  ar.write("\n<hr/>\n");
                  ar.write("\n<div class=\"leafContent\" >");
                  WikiConverter.writeWikiAsHtml(ar, selectedNote.getData());
                  ar.write("\n</div>");
              }
              else {
                  ar.write("\n<p><i>Access the web page using the following link:</i> <a href=\"");
                  ar.write(noteURL);
                  ar.write("\" title=\"Access the latest version of this note\"><b>");
                  String noteSubj = selectedNote.getSubject();
                  if (noteSubj==null || noteSubj.length()==0) {
                      noteSubj = "Note has no name.";
                  }
                  ar.writeHtml(noteSubj);
                  ar.write("</b></a></p>");
              }

              String choices = selectedNote.getChoices();
              String[] choiceArray = UtilityMethods
                      .splitOnDelimiter(choices, ',');
              UserProfile up = ale.getUserProfile();
              if (up != null && choiceArray.length > 0) {
                  selectedNote.getOrCreateUserResponse(up);
              }
              if (choiceArray.length > 0 & includeBody) {
                  ar.write("\n<p><font color=\"blue\"><i>This request has some response options.  Use the <a href=\"");
                  ar.write(noteURL);
                  ar.write("#Response\" title=\"Response form on the web\">web page</a> to respond to choose between: ");
                  int count = 0;
                  for (String ach : choiceArray) {
                      count++;
                      ar.write(" ");
                      ar.write(Integer.toString(count));
                      ar.write(". ");
                      ar.writeHtml(ach);
                  }
                  ar.write("</i></font></p>\n");
              }
          }
      }

      /**
       * This is a view that prompts the user to specify how they want the PDF to be produced.
       */
    @RequestMapping(value = "/{siteId}/{pageId}/exportPDF.htm", method = RequestMethod.GET)
    public ModelAndView exportPDF(HttpServletRequest request, HttpServletResponse response,
            @PathVariable String pageId,
            @PathVariable String siteId)
            throws Exception {

        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            registerRequiredProject(ar, siteId, pageId);
            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.export.pdf.login.msg");
            }
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Notes");
            return new ModelAndView("exportPDF");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.export.pdf.page", new Object[]{pageId,siteId} , ex);
        }
    }

      @RequestMapping(value = "/isNoteDeleted.ajax", method = RequestMethod.POST)
      public void isNoteDeleted(HttpServletRequest request, HttpServletResponse response)
             throws Exception {
         String responseText = null;
         AuthRequest ar = AuthRequest.getOrCreate(request, response);
         try {
             ar.assertLoggedIn("Must be logged in to create a note.");
             String p = ar.reqParam("p");
             NGContainer ngp = NGPageIndex.getContainerByKeyOrFail( p );
             ar.setPageAccessLevels(ngp);

             String oid = ar.reqParam("oid");
             JSONObject paramMap = new JSONObject();
             NoteRecord note = ngp.getNoteOrFail(oid);
             if(note.isDeleted()){
                 paramMap.put(Constant.MSG_TYPE, Constant.YES);
             }else{
                 paramMap.put(Constant.MSG_TYPE, Constant.No);
             }

             responseText = paramMap.toString();
         }
         catch (Exception ex) {
             responseText = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
             ar.logException("Caught by isNoteDeleted.ajax", ex);
         }
         NGWebUtils.sendResponse(ar, responseText);
     }

      @RequestMapping(value = "/closeWindow.htm", method = RequestMethod.GET)
      public ModelAndView closeWindow(HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          ModelAndView modelAndView = null;
          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "message.loginalert.see.page");
              }
              modelAndView=new ModelAndView("closeWindow");
              request.setAttribute("realRequestURL", ar.getRequestURL());
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.close.window", null , ex);
          }
          return modelAndView;
      }

      @RequestMapping(value = "/{siteId}/{pageId}/statusReport.form", method = RequestMethod.POST)
      public ModelAndView statusReport( @PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response) throws Exception {
          try{
              request.setAttribute("book", siteId);
              request.setAttribute("pageId", pageId);
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "message.loginalert.see.page");
              }
              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Status");

              String PROCESS_HTML = "statusReport.htm?startDate="+ ar.defParam("startDate", "")+"&endDate="+ar.defParam("endDate", "");
              return redirectBrowser(ar,PROCESS_HTML);
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.status.report.page", new Object[]{pageId,siteId} , ex);
          }
      }

      @RequestMapping(value = "/{siteId}/{pageId}/emailrecords.htm", method = RequestMethod.GET)
      public ModelAndView getEmailRecordsPage( @PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response) throws Exception {
          ModelAndView modelAndView = null;

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);

              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.upload.email.reminder.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projectsettings.emailRecords.memberlogin");
              }

              modelAndView=new ModelAndView("emailrecords");
              request.setAttribute("subTabId", "nugen.projectsettings.subtab.emailRecords");
              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Settings");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.emailrecords.page", new Object[]{pageId,siteId} , ex);
          }
          return modelAndView;
      }

      @RequestMapping(value = "/{siteId}/{pageId}/projectActiveTasks.htm", method = RequestMethod.GET)
      public ModelAndView projectActiveTasks(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);
              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.task.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projecthome.task.memberlogin");
              }


              //this page has a required parameter 'active', test it here so that any error
              //happens in the controller, not the page.
              String active = ar.defParam("active", "1");

              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Tasks");
              request.setAttribute("active", active);
              request.setAttribute("subTabId", "nugen.projecttasks.subtab.active.tasks");
              return new ModelAndView("ProjectActiveTasks");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
          }

      }

      @RequestMapping(value = "/{siteId}/{pageId}/projectCompletedTasks.htm", method = RequestMethod.GET)
      public ModelAndView projectCompletedTasks(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);

              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.task.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projecthome.task.memberlogin");
              }

              //this page has a required parameter 'active', test it here so that any error
              //happens in the controller, not the page.
              String active = ar.defParam("active", "1");

              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Tasks");
              request.setAttribute("active", active);
              request.setAttribute("subTabId", "nugen.projecttasks.subtab.completed.tasks");
              return new ModelAndView("ProjectCompletedTasks");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
          }
      }

      @RequestMapping(value = "/{siteId}/{pageId}/projectFutureTasks.htm", method = RequestMethod.GET)
      public ModelAndView projectFutureTasks(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);

              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.task.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projecthome.task.memberlogin");
              }

              //this page has a required parameter 'active', test it here so that any error
              //happens in the controller, not the page.
              String active = ar.defParam("active", "1");

              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Tasks");
              request.setAttribute("active", active);
              request.setAttribute("subTabId", "nugen.projecttasks.subtab.future.tasks");
              return new ModelAndView("ProjectFutureTasks");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
          }
      }

      @RequestMapping(value = "/{siteId}/{pageId}/projectAllTasks.htm", method = RequestMethod.GET)
      public ModelAndView projectAllTasks(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);

              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.task.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projecthome.task.memberlogin");
              }

              //this page has a required parameter 'active', test it here so that any error
              //happens in the controller, not the page.
              String active = ar.defParam("active", "1");

              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Tasks");
              request.setAttribute("active", active);
              request.setAttribute("subTabId", "nugen.projecttasks.subtab.all.tasks");
              return new ModelAndView("ProjectsAllTasks");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
          }
      }

      @RequestMapping(value = "/{siteId}/{pageId}/statusReport.htm", method = RequestMethod.GET)
      public ModelAndView projectStatusReport(@PathVariable String siteId,@PathVariable String pageId,
              HttpServletRequest request, HttpServletResponse response)
              throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              registerRequiredProject(ar, siteId, pageId);

              if(!ar.isLoggedIn()){
                  return showWarningView(ar, "nugen.project.task.login.msg");
              }
              if(!ar.isMember()){
                  request.setAttribute("roleName", "Members");
                  return showWarningView(ar, "nugen.projecthome.task.memberlogin");
              }

              //this page has a required parameter 'active', test it here so that any error
              //happens in the controller, not the page.
              String active = ar.defParam("active", "1");

              request.setAttribute("realRequestURL", ar.getRequestURL());
              request.setAttribute("tabId", "Project Tasks");
              request.setAttribute("active", active);
              request.setAttribute("subTabId", "nugen.projecttasks.subtab.status.report");
              return new ModelAndView("ProjectStatusReport");
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.process.page", new Object[]{pageId,siteId} , ex);
          }
      }

      //A very simple form with a prompt for a user's display name  (dName)
      //and the user name is set with whatever is posted in.
      //Can only set the current logged in user name.
      //User session must be logged in (so you have a profile to set)
      @RequestMapping(value = "/requiredName.form", method = RequestMethod.POST)
      public void requireName_form(HttpServletRequest request, HttpServletResponse response)
          throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              String go = ar.defParam("go", ar.baseURL);
              if (ar.isLoggedIn()) {
                  UserProfile up = ar.getUserProfile();
                  String dName = ar.reqParam("dName");
                  up.setName(dName);
                  up.setLastUpdated(ar.nowTime);
                  UserManager.writeUserProfilesToFile();
              }
              response.sendRedirect(go);
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.sent.note.by.email.page", null , ex);
          }
      }


      //A very simple form with a prompt for a user's email address which is
      //user to send a confirmation message, and another prompt to enter the
      //confirmation message.
      @RequestMapping(value = "/requiredEmail.form", method = RequestMethod.POST)
      public void requiredEmail_form(HttpServletRequest request, HttpServletResponse response)
          throws Exception {

          try{
              AuthRequest ar = AuthRequest.getOrCreate(request, response);
              String go = ar.defParam("go", ar.baseURL);
              String cmd = ar.reqParam("cmd");
              if (ar.isLoggedIn()) {
                  UserProfile up = ar.getUserProfile();
                  UserPage uPage = ar.getAnonymousUserPage();
                  if ("Send Email".equals(cmd)) {
                      String email = ar.reqParam("email");
                      ProfileRequest newReq = uPage.createProfileRequest(
                              ProfileRequest.ADD_EMAIL, email, ar.nowTime);
                      newReq.sendEmail(ar, go);
                      newReq.setUserKey(up.getKey());
                      uPage.save();
                  }
                  else if ("Confirmation Key".equals(cmd)) {
                      String cKey = ar.reqParam("cKey");

                      //look through the requests by email, and if the confirmation key matches
                      //then add the email, and remove the profile request.
                      for (ProfileRequest profi : uPage.getProfileRequests()) {
                          if (cKey.equals(profi.getSecurityToken())  &&
                                  up.getKey().equals(profi.getUserKey())) {
                              //ok, can only happen if same person received the message
                              String email = profi.getEmail();
                              String id = profi.getId();

                              //use it only ONCE
                              uPage.removeProfileRequest(id);
                              uPage.save();

                              //go ahead and add email to profile.
                              up.addId(email);
                              up.setPreferredEmail(email);
                              up.setLastUpdated(ar.nowTime);
                              UserManager.writeUserProfilesToFile();

                              break;
                          }
                      }
                  }
              }
              response.sendRedirect(go);
          }catch(Exception ex){
              throw new NGException("nugen.operation.fail.project.sent.note.by.email.page", null , ex);
          }
      }


}
