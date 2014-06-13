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

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.socialbiz.cog.AccessControl;
import org.socialbiz.cog.AttachmentRecord;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.ReminderMgr;
import org.socialbiz.cog.ReminderRecord;
import org.socialbiz.cog.UserPage;
import org.socialbiz.cog.dms.FolderAccessHelper;
import org.socialbiz.cog.dms.ResourceEntity;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.support.ByteArrayMultipartFileEditor;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class UploadFileController extends BaseController {

    public static final String BOOK = "book";
    public static final String TAB_ID = "tabId";
    public static final String PAGE_ID = "pageId";


    @Autowired
    public void setContext(ApplicationContext context) {
    }

    protected void initBinder(HttpServletRequest request,
            ServletRequestDataBinder binder) throws ServletException {

        binder.registerCustomEditor(byte[].class,new ByteArrayMultipartFileEditor());
    }

    private ModelAndView displayException(HttpServletRequest request, Exception extd) {
        request.setAttribute("display_exception", extd);
        return new ModelAndView("DisplayException");
    }

    @RequestMapping(value = "/{siteId}/{pageId}/upload.form", method = RequestMethod.POST)
    protected ModelAndView uploadFile(  @PathVariable String siteId,
                                        @PathVariable String pageId,
                                        HttpServletRequest request,
                                        HttpServletResponse response,
                                        @RequestParam("fname") MultipartFile file) throws Exception {

        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            //Handling special case for Multipart request
            ar.req = request;

            ReminderRecord reminderRecord = null;

            boolean requestFromReminder = false;
            String rid = ar.defParam("rid", null);
            String go = ar.defParam("go", null);

            boolean canAccessToReminder = false;
            if(rid != null){
                // rid is not null its mean request to upload a document has come from 'Reminders To Share Document'
                requestFromReminder = true;
                ReminderMgr mgr = ngp.getReminderMgr();
                reminderRecord = mgr.findReminderByIDOrFail(rid);
                canAccessToReminder = AccessControl.canAccessReminder(ar, ngp, reminderRecord);
            }
            if(!requestFromReminder ||  !canAccessToReminder){
                ar.assertLoggedIn(ar.getMessageFromPropertyFile("message.can.not.upload.attachment", null));
            }

            ar.assertNotFrozen(ngp);
            request.setCharacterEncoding("UTF-8");

            if (file.getSize() == 0) {
                throw new NGException("nugen.exceptionhandling.no.file.attached",null);
            }

            if(file.getSize() > 500000000){
                throw new NGException("nugen.exceptionhandling.file.size.exceeded", new Object[]{"500000000"});
            }

            String fileName = file.getOriginalFilename();

            if (fileName == null || fileName.length() == 0) {
                throw new NGException("nugen.exceptionhandling.filename.empty", null);
            }

            String visibility = ar.defParam("visibility", "*MEM*");
            String comment = ar.defParam("comment", "");
            String name = ar.defParam("name", null);

            AttachmentHelper.uploadNewDocument(ar, ngp, file, name, visibility, comment, "");

            if(reminderRecord != null){
                reminderRecord.setClosed();
                ngp.save();
            }
            if (go==null) {
                modelAndView = createRedirectView(ar, "attachment.htm");
            }
            else {
                response.sendRedirect(go);
            }
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/emailReminder.form", method = RequestMethod.POST)
    protected ModelAndView submitEmailReminderForAttachment(
            @PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.send.email");
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertNotFrozen(ngp);

            String comment = ar.reqParam("comment");
            String pname = ar.defParam("pname", "");
            String assignee = ar.reqParam("assignee");
            String instruct = ar.reqParam("instruct");
            String subj = ar.reqParam("subj");
            String visibility = ar.reqParam("visibility");

            ReminderMgr rMgr = ngp.getReminderMgr();
            ReminderRecord rRec = rMgr.createReminder(ngp.getUniqueOnPage());
            rRec.setFileDesc(comment);
            rRec.setInstructions(instruct);
            rRec.setAssignee(assignee);
            rRec.setFileName(pname);
            rRec.setSubject(subj);
            rRec.setModifiedBy(ar.getBestUserId());
            rRec.setModifiedDate(ar.nowTime);
            rRec.setDestFolder(visibility);
            rRec.setSendNotification("yes");
            HistoryRecord.createHistoryRecord(ngp, rRec.getId(), HistoryRecord.CONTEXT_TYPE_DOCUMENT,
                    ar.nowTime, HistoryRecord.EVENT_DOC_ADDED, ar, "Added Reminder for "+assignee);

            ngp.saveFile(ar, "Modified attachments");
            modelAndView = createRedirectView(ar, "reminders.htm");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.email.reminder", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;

    }

    @RequestMapping(value = "/{siteId}/{pageId}/sendemailReminder.htm", method = RequestMethod.GET)
    protected ModelAndView sendEmailReminderForAttachment(
            @PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                request.setAttribute("property_msg_key", "nugen.project.send.email.reminder.login.msg");
                modelAndView = createNamedView(siteId, pageId, ar, "Warning", "Project Documents");
            }else if(!ar.isMember()){
                request.setAttribute("property_msg_key", "nugen.attachment.send.email.reminder.memberlogin");
                modelAndView = createNamedView(siteId, pageId, ar, "Warning","Project Documents");
            }else{
                modelAndView = createNamedView(siteId, pageId, ar, "ReminderEmail","Project Documents");
                request.setAttribute("isNewUpload", "yes");
            }
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.send.email.reminder", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/resendemailReminder.htm", method = RequestMethod.POST)
    protected ModelAndView resendEmailReminderForAttachment(
            @PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.resend.email.reminder");
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            String reminderId = ar.reqParam("rid");
            String emailto = ar.defParam("emailto", null);
            ReminderRecord.reminderEmail(ar, pageId, reminderId, emailto, ngp);

            modelAndView = createRedirectView(ar, "reminders.htm");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.resend.email.reminder", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }


    @RequestMapping(value = "/{siteId}/{pageId}/updateAttachment.form", method = RequestMethod.POST)
    protected ModelAndView updateAttachment(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response,
            @RequestParam(value = "fname", required = false) MultipartFile file)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.must.be.login.to.perform.action");
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);
            //Handling special case for Multipart request
            ar.req = request;

            ar.assertNotFrozen(ngp);

            String action = ar.defParam("actionType", "");
            if(action.equals("Unlink"))
            {
                String aid = ar.reqParam("aid");
                AttachmentHelper.unlinkDocFromRepository(ar, aid, ngp);
            }else
            {
                AttachmentHelper.updateAttachment(ar, file, ngp);
            }

            modelAndView = createRedirectView(ar, "attachment.htm");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.update.document", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/createLinkURL.form", method = RequestMethod.POST)
    protected ModelAndView createLinkURL(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.create.link.url");
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);
            ar.assertNotFrozen(ngp);

            String visibility = ar.reqParam("visibility");

            String comment = ar.reqParam("comment");
            String taskUrl = ar.reqParam("taskUrl");
            String ftype = ar.reqParam("ftype");

            AttachmentRecord attachment = ngp.createAttachment();
            String proposedName = taskUrl;

            if(taskUrl.contains("/")){
                proposedName = taskUrl.substring(taskUrl.lastIndexOf("/")+1);
            }

            AttachmentHelper.setDisplayName(ngp, attachment, proposedName);

            attachment.setComment(comment);
            attachment.setModifiedBy(ar.getBestUserId());
            attachment.setModifiedDate(ar.nowTime);
            attachment.setType(ftype);
            if (visibility.equals("PUB")) {
                attachment.setVisibility(1);
            } else {
                attachment.setVisibility(2);
            }

            HistoryRecord.createHistoryRecord(ngp, attachment.getId(), HistoryRecord.CONTEXT_TYPE_DOCUMENT,
                    ar.nowTime, HistoryRecord.EVENT_DOC_ADDED, ar, "Created Link URL");

            attachment.setStorageFileName(taskUrl);
            ngp.saveFile(ar, "Created Link URL");
            modelAndView = createRedirectView(ar, "attachment.htm");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.create.link.url.to.project", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    /**
     * Let the user decide how to add a document to the project
     */
    @RequestMapping(value = "/{siteId}/{pageId}/addDocument.htm", method = RequestMethod.GET)
    protected ModelAndView addDocument(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.uploadattachment.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "addDocument","Project Documents");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/uploadDocument.htm", method = RequestMethod.GET)
    protected ModelAndView getUploadDocumentForm(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.uploadattachment.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "uploadDocumentForm","Project Documents");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/uploadRevisedDocument.htm", method = RequestMethod.GET)
    protected ModelAndView getUploadDocument2Form(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.revised.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.uploadattachment.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }
            String aid = ar.reqParam("aid");
            ngp.findAttachmentByIDOrFail(aid);

            modelAndView = createNamedView(siteId, pageId, ar, "UploadRevisedDocument","Project Documents");
            ar.req.setAttribute("aid", aid);
            request.setAttribute("subTabId", "nugen.projecthome.subtab.upload.document");
            request.setAttribute("isNewUpload", "yes");

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/linkURLToProject.htm", method = RequestMethod.GET)
    protected ModelAndView getLinkURLToProjectForm(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.link.url.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.linkurltoproject.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "createLinkUrlProjectForm", "Project Documents");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.linkurl.to.project.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/emailReminder.htm", method = RequestMethod.GET)
    protected ModelAndView getEmailRemainderForm(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.email.reminder.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.emailreminders.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "emailreminder_form", "Project Documents");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.emailreminder");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.email.reminder.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/linkRepository.htm", method = RequestMethod.GET)
    protected ModelAndView linkRepository(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
            ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.link.doc.to.project.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.linkattachmenttoproject.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            String symbol = ar.reqParam("symbol");
            ResourceEntity remoteFile = ar.getUserPage().getResourceFromSymbol(symbol);
            modelAndView = createNamedView(siteId, pageId, ar, "linkfromrepository_form", "Project Documents");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.link.from.repository");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("symbol", remoteFile.getSymbol());
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.link.to.repository.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }
    @RequestMapping(value = "/{siteId}/{pageId}/remoteAttachmentAction.form", method = RequestMethod.POST)
    protected void remoteAttachmentAction(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.create.attachment");
            ar.req = request;
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);
            ar.assertNotFrozen(ngp);
            ar.assertMember("Unable to create attachments.");

            String action   = ar.reqParam("action");
            String symbol   =  ar.reqParam("symbol");
            String visibility = ar.defParam("visibility","*MEM*");
            String comment = ar.defParam("comment","");
            String attachmentDisplayName = ar.defParam("name","");
            String isNewUpload = ar.defParam("isNewUpload", "yes");
            String readonly  = ar.defParam("readOnly","off");

            UserPage uPage    = ar.getUserPage();
            ResourceEntity ent = uPage.getResourceFromSymbol(symbol);

            if ("Link Document".equalsIgnoreCase(action))
            {
                FolderAccessHelper fah = new FolderAccessHelper(ar);
                if(isNewUpload.equals("yes"))
                {
                    fah.attachDocument(ent, ngp, comment, attachmentDisplayName, visibility, readonly);
                }else
                {
                    AttachmentHelper.updateRemoteAttachment(ar, ngp, comment, ent.getPath(), ent.getFolderId(), attachmentDisplayName, visibility);
                }

            }else{
                throw new ProgramLogicError("Don't understand the operation: "+ action);
            }

            ngp.saveFile(ar, "Modified attachments");
            response.sendRedirect(ar.baseURL+"t/"+siteId+"/"+pageId+"/attachment.htm");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.remote.attachment", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/folderDisplay.htm", method = RequestMethod.GET)
    protected ModelAndView folderDisplay(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.display.repository.folder");
            registerRequiredProject(ar, siteId, pageId);

            modelAndView = createNamedView(siteId, pageId, ar, "FolderDisplay", "Project Documents");
            request.setAttribute("fid",ar.defParam("fid",null));
            request.setAttribute("realRequestURL", ar.getRequestURL());
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.folder.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/editDocumentForm.htm", method = RequestMethod.GET)
    protected ModelAndView getEditDocumentForm(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        String aid = ar.reqParam("aid");
        return editDetails(siteId, pageId, aid, request, response);
    }

    @RequestMapping(value = "/{siteId}/{pageId}/editDetails{aid}.htm", method = RequestMethod.GET)
    protected ModelAndView editDetails(@PathVariable String siteId,
            @PathVariable String pageId, @PathVariable String aid, HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.edit.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.edit.doc.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }
            ngp.findAttachmentByIDOrFail(aid);

            modelAndView = createNamedView(siteId, pageId, ar, "editDetails", "Project Documents");
            request.setAttribute("subTabId", "nugen.projectdocument.subtab.attachmentdetails");
            request.setAttribute("aid",aid);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.edit.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/fileVersions.htm", method = RequestMethod.GET)
    protected ModelAndView getFileVersion(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.file.version.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.file.version.memberlogin");
            }
            String aid = ar.reqParam("aid");
            ngp.findAttachmentByIDOrFail(aid);

            modelAndView = createNamedView(siteId, pageId, ar, "fileVersions", "Project Documents");
            request.setAttribute("subTabId", "nugen.projectdocument.subtab.fileversions");
            request.setAttribute("aid",aid);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title",ngp.getFullName());


        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.file.version.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/unDeleteAttachment.ajax", method = RequestMethod.POST)
    protected void unDeleteAttachment( HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        String message="";
        AuthRequest ar = null;
        try {
            ar = getLoggedInAuthRequest(request, response, "message.must.be.login");
            String containerId=  ar.reqParam("containerId") ;
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(containerId);
            ar.setPageAccessLevels(ngc);
            String aid = ar.reqParam("aid");
            AttachmentRecord attachment = ngc.findAttachmentByID(aid);
            if(attachment == null){
                throw new NGException("nugen.exception.no.attachment.found", new Object[]{aid, ngc.getFullName()});
            }
            attachment.clearDeleted();
            message = NGWebUtils.getJSONMessage(Constant.SUCCESS , "" , "");
            ngc.saveContent( ar, "Modified attachments");
        }
        catch(Exception ex){
            message = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by getFileAccessName.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, message);
    }

     @RequestMapping(value = "/{siteId}/{pageId}/remindAttachment.htm", method = RequestMethod.GET)
     protected ModelAndView remindAttachment(@PathVariable String siteId,
                @PathVariable String pageId, HttpServletRequest request,
                HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        try{
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);
            ar.setPageAccessLevels(ngp);

            String rid = ar.reqParam("rid");
            ReminderMgr mgr = ngp.getReminderMgr();
            ReminderRecord reminderRecord = mgr.findReminderByIDOrFail(rid);
            if (AccessControl.canAccessReminder(ar, ngp, reminderRecord)) {
                request.setAttribute("subTabId", "nugen.projecthome.subtab.upload.document");
                return createNamedView(siteId, pageId, ar, "remind_attachment", "Project Documents");
            }

            if(!ar.isLoggedIn()){
                request.setAttribute("property_msg_key", "nugen.project.remind.doc.login.msg");
            }else if(!ar.isMember()){
                request.setAttribute("property_msg_key", "nugen.attachment.remind.doc.memberlogin");
            }else {
                //basically, the reminder should have been display, and we have no idea now why not
                throw new Exception("Program Logic Error ... something is wrong with the canAccessReminder method");
            }
            return createNamedView(siteId, pageId, ar, "Warning", "Project Documents");

        }catch(Exception ex){
            Exception extd = new NGException("nugen.operation.fail.project.reminder.attachment.page",
                    new Object[]{pageId,siteId} , ex);
            return displayException(request, extd);
        }
     }

     @RequestMapping(value = "/{siteId}/{pageId}/sendDocsByEmail.htm", method = RequestMethod.GET)
     protected void getDocumentsByEmailForm(@PathVariable String siteId,
             @PathVariable String pageId, HttpServletRequest request,
             HttpServletResponse response) throws Exception {

        try{
            AuthRequest ar = getLoggedInAuthRequest(request, response, "message.can.not.send.docs.by.email");
            registerRequiredProject(ar, siteId, pageId);

            String oid = ar.reqParam("oid");
            response.sendRedirect(ar.retPath+"t/sendNoteByEmail.htm?p="+pageId+"&oid="+oid+"&encodingGuard=%E6%9D%B1%E4%BA%AC");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.send.doc.by.email.page", new Object[]{pageId,siteId} , ex);
        }
    }


    @RequestMapping(value = "/{siteId}/{pageId}/docinfo{docId}.htm", method = RequestMethod.GET)
    protected ModelAndView docInfoView(@PathVariable String siteId,
             @PathVariable String pageId, @PathVariable String docId,
             HttpServletRequest request,  HttpServletResponse response) throws Exception
    {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ngp.findAttachmentByIDOrFail(docId);

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("subTabId", "nugen.projectdocument.subtab.attachmentdetails");
            request.setAttribute("aid", docId);
            return createNamedView(siteId, pageId, ar, "docinfo", "Project Documents");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.download.document.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/getDocumentDetail.ajax", method = RequestMethod.POST)
    public void createLeaflet(HttpServletRequest request, HttpServletResponse response)
           throws Exception {
       String responseText = null;
       AuthRequest ar = null;
       try {
           ar = getLoggedInAuthRequest(request, response, "message.must.be.login");
           String aid = ar.reqParam("aid");
           String pageId = ar.reqParam("pageId");

           NGContainer ngp = NGPageIndex.getContainerByKeyOrFail( pageId );
           AttachmentRecord attachment = ngp.findAttachmentByIDOrFail(aid);

           JSONObject paramMap = new JSONObject();
           paramMap.put(Constant.MSG_TYPE, Constant.SUCCESS);
           paramMap.put("aid", aid);
           paramMap.put("description", attachment.getComment());
           paramMap.put("permission", String.valueOf(attachment.getVisibility()));
           paramMap.put("accessName", attachment.getDisplayName());
           responseText = paramMap.toString();
       }
       catch (Exception ex) {
           responseText = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
           ar.logException("Caught by getDocumentDetail.ajax", ex);
       }
       NGWebUtils.sendResponse(ar, responseText);
   }

    @RequestMapping(value = "/{siteId}/{pageId}/CreateCopy.htm", method = RequestMethod.GET)
    protected ModelAndView CreateCopy(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response,
            @RequestParam(value = "fname", required = false) MultipartFile file)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.create.copy.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.createcopy.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }


            modelAndView = createNamedView(siteId, pageId, ar, "CreateCopy", "Project Documents");
            request.setAttribute("subTabId", "nugen.projecthome.subtab.emailreminder");
            String aid = ar.reqParam("aid");

            AttachmentRecord attachment = ngp.findAttachmentByID(aid);

            if (attachment == null) {
                throw new NGException("nugen.exception.attachment.not.found" ,new Object[]{ aid});
            }
            request.setAttribute("aid", aid);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title",  ngp.getFullName());


        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.create.copy.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    @RequestMapping(value = "/deleteReminder.ajax", method = RequestMethod.POST)
    protected void deleteReminder( HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        String message="";
        AuthRequest ar = null;
        try
        {
            ar = getLoggedInAuthRequest(request, response, "message.must.be.login");
            String containerId=  ar.reqParam("containerId") ;
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(containerId);
            ar.setPageAccessLevels(ngc);
            String rid = ar.reqParam("rid");

            ReminderMgr rMgr = ngc.getReminderMgr();

            ReminderRecord rRec = rMgr.findReminderByID(rid);

            if(rRec != null){
                rMgr.removeReminder(rid);
                message = NGWebUtils.getJSONMessage(Constant.SUCCESS , "" , "");
            }else{
                throw new NGException("nugen.exception.no.attachment.found", new Object[]{rid, ngc.getFullName()});
            }
            ngc.saveContent( ar, "Modified attachments");
        }
        catch(Exception ex){
            message = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by deleteReminder.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, message);
    }

    @RequestMapping(value = "/setEditMode.ajax", method = RequestMethod.POST)
    protected void setEditAttachmentMode( HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        String responseText = null;
        AuthRequest ar = null;
        try {
            ar = getLoggedInAuthRequest(request, response, "message.must.be.login");
            String aid = ar.reqParam("aid");
            String pageId = ar.reqParam("pageId");
            String isEditMode = ar.reqParam("editing");

            NGContainer ngp = NGPageIndex.getContainerByKeyOrFail( pageId );
            AttachmentRecord attachment = ngp.findAttachmentByIDOrFail(aid);

            //attachment.clearDeleted();
            if(attachment != null){
                if(isEditMode.equals("true")){
                    attachment.setEditMode(ar);
                }else{
                    attachment.clearEditMode();
                }
                responseText = NGWebUtils.getJSONMessage(Constant.SUCCESS , "" , "");
            }else{
                throw new NGException("nugen.exception.no.attachment.found", new Object[]{aid, ngp.getFullName()});
            }
            ngp.saveContent( ar, "Modified attachments");
        }
        catch (Exception ex) {
            responseText = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by setEditMode.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, responseText);
    }

    @RequestMapping(value = "/{siteId}/{pageId}/viewEmailReminder.htm", method = RequestMethod.GET)
    protected ModelAndView viewEmailReminderForAttachment(
            @PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.send.email.reminder.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.send.email.reminder.memberlogin");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "viewReminder","Project Documents");
            request.setAttribute("isNewUpload", "yes");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("title", ngp.getFullName());
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.send.email.reminder", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    /**
     * The first step in validating XBRL documents
     */
    @RequestMapping(value = "/{siteId}/{pageId}/xbrlValidate.htm", method = RequestMethod.GET)
    protected ModelAndView xbrlValidate(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.uploadattachment.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "xbrlValidate","XBRL Documents");
//            request.setAttribute("realRequestURL", ar.getRequestURL());
//            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    /**
     * The first step in validating XBRL documents
     */
    @RequestMapping(value = "/{siteId}/{pageId}/xbrlResults.htm", method = RequestMethod.GET)
    protected ModelAndView xbrlResults(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp =  registerRequiredProject(ar, siteId, pageId);

            if(!ar.isLoggedIn()){
                return showWarningView(ar, "nugen.project.upload.doc.login.msg");
            }
            if(!ar.isMember()){
                request.setAttribute("roleName", "Members");
                return showWarningView(ar, "nugen.attachment.uploadattachment.memberlogin");
            }
            if(ngp.isFrozen()){
                return showWarningView(ar, "nugen.generatInfo.Frozen");
            }

            modelAndView = createNamedView(siteId, pageId, ar, "xbrlResults","XBRL Validation Results");
//            request.setAttribute("realRequestURL", ar.getRequestURL());
//            request.setAttribute("title", ngp.getFullName());

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.upload.document.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }



}
