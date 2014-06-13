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

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.NGBook;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.UserManager;
import org.socialbiz.cog.UserProfile;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ServletExit;

@Controller
public class BaseController {

    public static final String ACCOUNT_ID = "book";
    public static final String TAB_ID = "tabId";
    public static final String PAGE_ID = "pageId";

    @ExceptionHandler(Exception.class)
    public ModelAndView handleException(Exception ex, HttpServletRequest request,
            HttpServletResponse response) {

        //if a ServletExit has been thrown, then the browser has already been redirected,
        //so just return null and get out of here.
        if (ex instanceof ServletExit) {
            return null;
        }
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        return displayException(ar, ex);
    }

    /**
     * Logs the exception in the tracker, and generates a 'nice' display of an exception.
     * This can be used when the exception
     * is predictable, such a parsing a URL and not finding the data that it should display.
     * You should also be aware of the problems of displaying an exception when the
     * system is truly breaking -- the support necessary to create the nice display
     * might not be functioning well enough to display anything.
     */
    protected ModelAndView displayException(AuthRequest ar, Exception extd) {
        long exceptionNO=ar.logException("Caught in user interface", extd);
        ar.req.setAttribute("display_exception", extd);
        ar.req.setAttribute("log_number", exceptionNO);
        return new ModelAndView("DisplayException");
    }

    protected static ModelAndView showWarningView(AuthRequest ar, String why) {
        ar.req.setAttribute("property_msg_key", why);
        return new ModelAndView("Warning");
    }



    /**
     * This is a convenience function for all handlers that have the account and project
     * in the URL.
     *
     * (1) This will validate those values.
     * (2) Read the project.
     * (3) Sets the access level to the page
     * (4) Set the header type to be project
     * (5) Throws and exception if anything is wrong.
     *
     * Will ALSO set two request attributes needed by the JSP files.
     */
    public static NGPage registerRequiredProject(AuthRequest ar, String siteId, String projectId) throws Exception
    {
        ar.req.setAttribute("pageId",     projectId);
        ar.req.setAttribute("book",       siteId);
        ar.req.setAttribute("headerType", "project");
        NGPageIndex.assertBook(siteId);
        NGPage ngp = NGPageIndex.getProjectByKeyOrFail( projectId );
        if (!siteId.equals(ngp.getSiteKey())) {
            throw new NGException("nugen.operation.fail.account.match", new Object[]{projectId,siteId});
        }
        ar.setPageAccessLevels(ngp);
        ar.req.setAttribute("title", ngp.getFullName());
        return ngp;
    }

    public static NGBook prepareSiteView(AuthRequest ar, String siteId) throws Exception
    {
        ar.req.setAttribute("accountId", siteId);
        ar.req.setAttribute("book",      siteId);
        ar.req.setAttribute("headerType", "site");
        NGBook account = NGPageIndex.getSiteByIdOrFail( siteId );
        ar.setPageAccessLevels(account);
        ar.req.setAttribute("title", account.getFullName());
        return account;
    }


    public static AuthRequest getLoggedInAuthRequest(HttpServletRequest request,
            HttpServletResponse response, String assertLoggedInMsgKey) throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        ar.assertLoggedIn(ar.getMessageFromPropertyFile(assertLoggedInMsgKey, null));
        return ar;
    }

    public ModelAndView createRedirectView(AuthRequest ar, String redirectAddress) throws Exception {
        return new ModelAndView(new RedirectView(redirectAddress));
    }

    public ModelAndView createNamedView(String siteId, String pageId,
            AuthRequest ar,  String viewName, String tabId)
            throws Exception {
        ar.req.setAttribute(ACCOUNT_ID, siteId);
        ar.req.setAttribute(TAB_ID, tabId);
        ar.req.setAttribute(PAGE_ID, pageId);
        ar.req.setAttribute("realRequestURL", ar.getRequestURL());
        return new ModelAndView(viewName);
    }

    /*
    * Redirect from a fetched page to the login page.  Returns to this page.
    * Should not have two of these.  Clean up and have just one
    */
    public static ModelAndView redirectToLoginView(AuthRequest ar, String msgKey, Object[] param) throws Exception {
        sendRedirectToLogin(ar, msgKey, param);
        return null;
    }

    public static void sendRedirectToLogin(AuthRequest ar, String msgKey, Object[] param) throws Exception {
        String go = ar.getCompleteURL();
        String message = ar.getMessageFromPropertyFile(msgKey, param);
        String loginUrl = ar.baseURL+"t/EmailLoginForm.htm?go="+URLEncoder.encode(go,"UTF-8")
        +"&msg="+URLEncoder.encode(message,"UTF-8");
        ar.resp.sendRedirect(loginUrl);
        return;
    }


    /**
    * Redirect to the login page from a form POST controller when an error occurred.
    * parameter go is the web address to redirect to on successful login
    * parameter error is an exception that represents the message to display to the user
    * Error message is displayed only once.  Refreshing the page will clear the message.
    */
    protected void redirectToLoginPage(AuthRequest ar, String go, Exception error) throws Exception
    {
        //pass the 'last' error message to the login page through the session (not parameter)
        String msgtxt = NGException.getFullMessage(error, ar.getLocale());
        ar.session.setAttribute("error-msg", msgtxt);

        String err1return = ar.retPath+"t/EmailLoginForm.htm?go="+URLEncoder.encode(go, "UTF-8");
        ar.resp.sendRedirect(err1return);
        return;
    }

    /*
    * Pass in the relative URL and
    * this will redirect the browser to that address.
    * It will return a null ModelAndView object so that you can
    * say "return redirectToURL(myurl);"
    */
    protected ModelAndView redirectBrowser(AuthRequest ar, String pageURL) throws Exception
    {
        ar.resp.sendRedirect(pageURL);
        return null;
    }

    protected boolean needsToSetName(AuthRequest ar) throws Exception {
        if (!ar.isLoggedIn()) {
            return false;
        }
        UserProfile up = ar.getUserProfile();
        String displayName = up.getName();
        return displayName == null || displayName.length()==0;
    }

    protected boolean needsToSetEmail(AuthRequest ar) throws Exception {
        if (!ar.isLoggedIn()) {
            return false;
        }
        UserProfile up = ar.getUserProfile();
        String email = up.getPreferredEmail();
        return email == null || email.length()==0;
    }

    /**
     * This is a set of checks that results in different views depending on the state
     * of the user.  Particularly: must be logged in, must have a name, must have an email
     * address, and must be a member of the page.
     * @return a ModelAndView object that will tell the user what is wrong.
     */
    protected ModelAndView memberCheckViews(AuthRequest ar) throws Exception {
        if(!ar.isLoggedIn()){
            return showWarningView(ar, "nugen.project.login.msg");
        }
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
        if (UserManager.getAllSuperAdmins(ar).size()==0) {
            return showWarningView(ar, "nugen.missingSuperAdmin");
        }
        return null;
    }

    /**
     * This is a set of checks that results in different views depending on the state
     * of the user.  Particularly: must be logged in, must have a name, must have an email
     * address, and must be a member of the page.
     * @return a ModelAndView object that will tell the user what is wrong.
     */
    protected ModelAndView executiveCheckViews(AuthRequest ar) throws Exception {
        if(!ar.isLoggedIn()){
            return showWarningView(ar, "nugen.project.login.msg");
        }
        if (needsToSetName(ar)) {
            return new ModelAndView("requiredName");
        }
        if (needsToSetEmail(ar)) {
            return new ModelAndView("requiredEmail");
        }
        if(!ar.isMember()){
            ar.req.setAttribute("roleName", "Executive");
            return showWarningView(ar, "nugen.project.executive.msg");
        }
        if (UserManager.getAllSuperAdmins(ar).size()==0) {
            return showWarningView(ar, "nugen.missingSuperAdmin");
        }
        return null;
    }
}


