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

import java.net.URLEncoder;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

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
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.NGBook;
import org.socialbiz.cog.NGPageIndex;

/**
 * Sites (NGBook) used to have documents.
 * This capability was deprecated Oct 2013
 * After four years of use in Fujitsu, nobody EVER
 * attached a document to a site!
 *
 * These can be removed after suitable time (a few months)
 *
 */
@Controller
public class AccountsDocumentController extends BaseController {

    public static final String TAB_ID = "tabId";
    public static final String ACCOUNT_ID = "accountId";

    @Autowired
    public void setContext(ApplicationContext context) {
    }

    protected void initBinder(HttpServletRequest request,
            ServletRequestDataBinder binder) throws ServletException {

        binder.registerCustomEditor(byte[].class,new ByteArrayMultipartFileEditor());

    }

    @RequestMapping(value = "/{siteId}/$/upload.form", method = RequestMethod.POST)
    protected ModelAndView uploadFile(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response,
            @RequestParam("fname") MultipartFile file) throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/getEditAttachmentForm.form", method = RequestMethod.GET)
    protected ModelAndView getEditAttachmentForm(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/emailReminder.form", method = RequestMethod.POST)
    protected ModelAndView submitEmailReminderForAttachment(
            @PathVariable String siteId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/sendemailReminder.htm", method = RequestMethod.GET)
    protected ModelAndView sendEmailReminderForAttachment(
            @PathVariable String siteId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/resendemailReminder.htm", method = RequestMethod.POST)
    protected ModelAndView resendEmailReminderForAttachment(
            @PathVariable String siteId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/editAttachment.form", method = RequestMethod.POST)
    protected ModelAndView editAttachment(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response,
            @RequestParam(value = "fname", required = false) MultipartFile file)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/createLinkURL.form", method = RequestMethod.POST)
    protected ModelAndView createLinkURL(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/uploadDocument.htm", method = RequestMethod.GET)
    public ModelAndView uploadDocumentForm(@PathVariable String siteId, HttpServletRequest request,
            HttpServletResponse response) throws Exception
    {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/linkURLToProject.htm", method = RequestMethod.GET)
    protected ModelAndView getLinkURLToProjectForm(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/emailReminder.htm", method = RequestMethod.GET)
    protected ModelAndView getEmailRemainderForm(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/editDocumentForm.htm", method = RequestMethod.GET)
    protected ModelAndView getEditDocumentForm(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/fileVersions.htm", method = RequestMethod.GET)
    protected ModelAndView getFileVersion(@PathVariable String siteId, HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

    @RequestMapping(value = "/{siteId}/$/updateAttachment.form", method = RequestMethod.POST)
    protected ModelAndView updateAttachment(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response,
            @RequestParam(value = "fname", required = false) MultipartFile file)
            throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

     public String loginCheckMessage(AuthRequest ar) throws Exception {
         String errorMsg = "";
        if (!ar.isLoggedIn()){
            String go = ar.getCompleteURL();
            errorMsg = "redirect:"+URLEncoder.encode(go,"UTF-8")+":"+URLEncoder.encode("Can not open form","UTF-8");
        }
        return errorMsg;
     }

    @RequestMapping(value = "/{siteId}/$/remindAttachment.htm", method = RequestMethod.GET)
    protected ModelAndView remindAttachment(@PathVariable String siteId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }


    @RequestMapping(value="/{siteId}/$/a/{docId}", method = RequestMethod.GET)
    public void loadDocument(@PathVariable String siteId, @PathVariable String docId,
        HttpServletRequest request, HttpServletResponse response) throws Exception
    {
        throw new NGException("nugen.operation.fail.account.download.document", new Object[]{docId, siteId});
    }

    @RequestMapping(value = "/{siteId}/$/account_reminders.htm", method = RequestMethod.GET)
    public ModelAndView remindersTab(@PathVariable String siteId,
                                        HttpServletRequest request, HttpServletResponse response)
                                        throws Exception {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }


    @RequestMapping(value = "/{siteId}/$/docinfo{docId}.htm", method = RequestMethod.GET)
    protected ModelAndView accountDocInfo(@PathVariable String siteId,
            @PathVariable String docId, HttpServletRequest request,
            HttpServletResponse response) throws Exception
    {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return showWarningView(ar, "nugen.deprecatedView");
    }

     @RequestMapping(value = "/{siteId}/$/leaflet{lid}.htm", method = RequestMethod.GET)
     public ModelAndView displayZoomedLeaflet(@PathVariable String lid,@PathVariable String siteId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            if(!ar.isLoggedIn()){
                return showWarningView(ar, "message.loginalert.see.page");
            }
            NGBook ngb = NGPageIndex.getSiteByIdOrFail(siteId);
            ar.setPageAccessLevels(ngb);

            modelAndView=new ModelAndView("AccountNoteZoomView");
            request.setAttribute("lid", lid);
            request.setAttribute("p", siteId);
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Site Notes");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.account.note", new Object[]{siteId} , ex);
        }
        return modelAndView;
    }

}
