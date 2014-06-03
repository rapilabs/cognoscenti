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

import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.io.Writer;
import java.net.URLEncoder;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
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
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.NGRole;
import org.socialbiz.cog.NoteRecord;
import org.socialbiz.cog.OptOutAddr;
import org.socialbiz.cog.OptOutDirectAddress;
import org.socialbiz.cog.OptOutIndividualRequest;
import org.socialbiz.cog.OptOutRolePlayer;
import org.socialbiz.cog.OptOutSuperAdmin;
import org.socialbiz.cog.RoleRequestRecord;
import org.socialbiz.cog.SectionUtil;
import org.socialbiz.cog.UserManager;
import org.socialbiz.cog.UserPage;
import org.socialbiz.cog.UserProfile;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.springframework.context.ApplicationContext;

public class NGWebUtils {

    /**
     * This static application context is initialized when SuperAdminController
     * is initialized by "Autowire" capability. Need to figure out how to assure
     * that happens before any of these methods need it.
     */
    public static ApplicationContext srvContext;

    public static void nicePrintDate(Writer out, long timestamp)
            throws Exception {
        SectionUtil.nicePrintDate(out, timestamp);
    }

    public static String getNicePrintDate(long timestamp) throws Exception {
        StringWriter out = new StringWriter();
        nicePrintDate(out, timestamp);
        return out.toString();
    }

//    public static void nicePrintTime(Writer out, long timestamp,
//            long currentTime) throws Exception {
//        SectionUtil.nicePrintTime(out, timestamp, currentTime);
//    }

    public static void writePadded(Writer out, int desiredLen, String value)
            throws Exception {
        int len = desiredLen - value.length();
        while (len > 0) {
            len--;
            out.write(" ");
        }
        out.write(value);
    }

    public static int getNotesCount(NGContainer container, AuthRequest ar,
            int displayLevel) throws Exception {
        int count = 0;
        List<NoteRecord> notes = container.getVisibleNotes(ar, displayLevel);
        if (notes != null) {
            count = notes.size();
        }
        return count;
    }

    public static int getDeletedNotesCount(NGContainer container, AuthRequest ar)
            throws Exception {
        List<NoteRecord> notes = container.getDeletedNotes(ar);
        if (notes == null) {
            return 0;
        }
        return notes.size();
    }

    public static int getDraftNotesCount(NGContainer container, AuthRequest ar)
            throws Exception {
        int count = 0;
        List<NoteRecord> notes = container.getDraftNotes(ar);
        if (notes != null) {
            count = notes.size();
        }
        return count;
    }

    public static int getDocumentCount(NGContainer ngc, int displayLevel)
            throws Exception {
        int noOfDocs = 0;
        for (AttachmentRecord attachment : ngc.getAllAttachments()) {
            if (attachment.getVisibility() != displayLevel
                    || attachment.isDeleted()) {
                continue;
            }
            noOfDocs++;
        }
        return noOfDocs;
    }

    public static int getDeletedDocumentCount(NGContainer ngc) throws Exception {
        int noOfDocs = 0;
        for (AttachmentRecord attachment : ngc.getAllAttachments()) {
            if (!attachment.isDeleted()) {
                continue;
            }
            noOfDocs++;
        }
        return noOfDocs;
    }

    /**
     * Get the users from the role, and add them, only if they are not already
     * in the list. Adds a OptOutRolePlayer type of address.
     */
    public static void appendUsersFromRole(NGContainer ngc, String roleName,
            Vector<OptOutAddr> collector) throws Exception {
        List<AddressListEntry> players = ngc.getRoleOrFail(roleName)
                .getExpandedPlayers(ngc);
        for (AddressListEntry ale : players) {
            appendOneUser(new OptOutRolePlayer(ale, ngc.getKey(), roleName),
                    collector);
        }
    }

    /**
     * Get the users from the role, and add them, only if they are not already
     * in the list. Adds a OptOutDirectAddress type of address.
     */
    public static void appendUsers(List<AddressListEntry> members,
            Vector<OptOutAddr> collector) throws Exception {
        for (AddressListEntry ale : members) {
            appendOneUser(new OptOutDirectAddress(ale), collector);
        }
    }

    public static void appendOneUser(OptOutAddr newser,
            Vector<OptOutAddr> collector) throws Exception {
        for (OptOutAddr ooa : collector) {
            if (ooa.matches(newser)) {
                return;
            }
        }
        collector.add(newser);
    }

    /**
     * Call this routine to include standard information at the bottom of hte
     * message. It will print out a line saying who the email was addressed to.
     * Then, when that person does not have a profile, it will add a small
     * section inviting them to register, since this is an email going to them,
     * it will serve to prove that they received the email as well.
     */
    public static void standardEmailFooter(AuthRequest ar,
            UserProfile requestingUser, OptOutAddr ooa, NGContainer container)
            throws Exception {
        AddressListEntry addressee = ooa.getAssignee();

        if (addressee.getUserProfile() != null) {
            // they have a profile, so there is nothing more to add
            return;
        }
    }

    /*
    public static void writeUsers(AuthRequest clone,
            Vector<AddressListEntry> toList, Vector<String> addressOnlyOutput)
            throws Exception {
        clone.write("\n<p>This message sent to: ");
        for (AddressListEntry ale : toList) {
            String email = ale.getEmail();
            ale.writeLink(clone);
            if (email != null && email.length() > 0) {
                addressOnlyOutput.add(email);
            } else {
                clone.write("(no email) ");
            }
        }
        clone.write("</p>");
    }
    */

    public static void sendInviteEmail(AuthRequest ar, String pageId,
            String emailId, String role) throws Exception {
        StringWriter bodyWriter = new StringWriter();
        NGContainer container = NGPageIndex.getContainerByKey(pageId);
        UserProfile up = UserManager.findUserByAnyId(emailId);
        AuthRequest clone = new AuthDummy(up, bodyWriter);
        UserProfile requestingUser = ar.getUserProfile();
        String dest = null;

        if (up != null) {
            dest = up.getPreferredEmail();
            if (dest == null) {
                // User does not have an email address, so we can't send an
                // invite.
                // This does not seems like a situation that we should bomb out
                // on
                // So silently return.
                return;
            }
        } else {
            // first check to see if the passed value looks like an email
            // address
            // if not, OK, it may be an Open ID, and simply don't send the email
            // in that case.
            if (emailId.indexOf('@') < 0) {
                // this is not an email address. Simply return silently, can't
                // send email.
                return;
            }
            dest = emailId;
        }

        AddressListEntry ale = new AddressListEntry(emailId);
        OptOutAddr ooa = new OptOutAddr(ale);

        clone.setNewUI(true);
        clone.retPath = ar.baseURL;

        clone.write("<html><body>\n");
        clone.write("<p>");
        requestingUser.writeLink(clone);
        clone.write(" has added you to the '");
        clone.writeHtml(role);
        clone.write("' role of the ");
        container.writeContainerLink(clone, 100);
        clone.write(" project.</p>");
        standardEmailFooter(clone, requestingUser, ooa, container);
        clone.write("</body></html>");

        EmailSender.containerEmail(ooa, container, "Added to " + role
                + " role of " + container.getFullName(), bodyWriter.toString(),
                null, new Vector<String>());
        NGPageIndex.releaseLock(container);
    }

    /**
     * get a list of email assignees for all server super admin users.
     */
    public static Vector<OptOutAddr> getSuperAdminMailList(AuthRequest ar)
            throws Exception {
        Vector<OptOutAddr> sendTo = new Vector<OptOutAddr>();
        for (UserProfile superAdmin : UserManager.getAllSuperAdmins(ar)) {
            sendTo.add(new OptOutSuperAdmin(new AddressListEntry(superAdmin
                    .getPreferredEmail())));
        }
        if (sendTo.size() == 0) {
            throw new NGException(
                    "nugen.exceptionhandling.account.no.super.admin", null);
        }
        return sendTo;
    }



    public static void setSiteGrantedEmail(AuthRequest ar,
            UserProfile owner, SiteRequest accountDetails) throws Exception {
        StringWriter bodyWriter = new StringWriter();
        AuthRequest clone = new AuthDummy(ar.getUserProfile(), bodyWriter);
        clone.setNewUI(true);
        clone.retPath = ar.baseURL;
        clone.write("<html><body>\n");
        clone.write("<p>This message was sent automatically from Cognoscenti to keep you up ");
        clone.write("to date on the status of your Site.</p>");
        clone.write("\n<table>");
        clone.write("\n<tr><td>Purpose: &nbsp;</td><td>You requested a new account</td></tr>\n");

        if (ar.getUserProfile() != null) {
            clone.write("<tr><td>Updated by: &nbsp;</td><td>");
            clone.getUserProfile().writeLink(clone);
        }

        clone.write("</td></tr>");
        clone.write("\n<tr><td>Result: &nbsp;</td><td>");
        clone.writeHtml(accountDetails.getStatus());
        clone.write("</td></tr>");
        clone.write("\n<tr><td>Site Name: &nbsp;</td><td><a href=\"");
        clone.write(ar.baseURL);
        clone.write("v/approveAccountThroughMail.htm?requestId=");
        clone.write(accountDetails.getRequestId());
        clone.write("\">");
        clone.writeHtml(accountDetails.getName());
        clone.write("</a></td></tr>");
        clone.write("\n<tr><td>Description: &nbsp;</td><td>");
        clone.writeHtml(accountDetails.getDescription());
        clone.write("</td></tr>");
        clone.write("\n<tr><td>Requested by: &nbsp; </td><td>");
        owner.writeLink(clone);
        clone.write("</td></tr>\n</table>\n</body></html>");

        Vector<OptOutAddr> v = new Vector<OptOutAddr>();
        v.add(new OptOutIndividualRequest(new AddressListEntry(owner
                .getUniversalId())));

        EmailSender.simpleEmail(v, null,
                "Site Approval for " + owner.getName(),
                bodyWriter.toString());
    }



    public static void sendRoleRequestEmail(AuthRequest ar,
            RoleRequestRecord roleRequestRecord, NGContainer container)
            throws Exception {
        UserProfile up = ar.getUserProfile();
        if (up == null) {
            throw new Exception(
                    "Program Logic Error: only logged in users can request to join a role, and got such a request when there appears to be nobody logged in");
        }
        Vector<OptOutAddr> initialList = new Vector<OptOutAddr>();
        NGWebUtils
                .appendUsersFromRole(container, "Administrators", initialList);
        NGWebUtils.appendUsersFromRole(container, "Members", initialList);

        // filter out users that who have no profile and have never logged in.
        // Only send this request to real users, not just email addresses
        Vector<OptOutAddr> sendTo = new Vector<OptOutAddr>();
        for (OptOutAddr ooa : initialList) {
            if (ooa.isUserWithProfile()) {
                sendTo.add(ooa);
            }
        }

        if (sendTo.size() == 0) {
            throw new Exception(
                    "sendRoleRequestEmail has been called when there are no valid Members or Administrators of the project to send the email to.");
        }

        String baseURL = ar.baseURL;

        StringWriter bodyWriter = new StringWriter();
        AuthRequest clone = new AuthDummy(ar.getUserProfile(), bodyWriter);
        clone.setNewUI(true);
        clone.retPath = baseURL;
        clone.write("<html><body>\n");
        clone.write("<p>");
        ar.getUserProfile().writeLink(clone);
        clone.write(" has requested to join the role <b>'");
        clone.writeHtml(roleRequestRecord.getRoleName());
        clone.write("'</b> in the project '");
        container.writeContainerLink(clone, 100);
        clone.write("'.   <br/>Comment: <i>");
        clone.writeHtml(roleRequestRecord.getRequestDescription());
        clone.write("</i></p>\n");

        clone.write("<p><a href=\"");
        clone.write(baseURL);
        clone.write("t/approveOrRejectRoleReqThroughMail.htm?requestId=");
        clone.writeURLData(roleRequestRecord.getRequestId());
        clone.write("&pageId=");
        clone.writeURLData(container.getKey());
        clone.write("&isAccessThroughEmail=yes");
        clone.write("&");
        clone.write(AccessControl.getAccessRoleRequestParams(container,
                roleRequestRecord));
        clone.write("\">Click here to Accept/Deny</a></p>");

        clone.write("<p>You can accept or deny this request because you are either an ");
        clone.write("Administrator or Member of this project.   If you are not responsible for ");
        clone.write("approving/rejecting this request  you can safely ignore and delete this message.</p>");
        clone.write("\n<hr/>\n");
        clone.write("</body></html>");

        EmailSender.queueEmailNGC(sendTo, container,
                "Role Requested by " + ar.getBestUserId(),
                bodyWriter.toString(), null, new Vector<String>());

    }


    public static void writeLocalizedHistoryMessage(HistoryRecord hr,
            NGContainer ngp, AuthRequest ar) throws Exception {
        if (srvContext == null) {
            throw new ProgramLogicError(
                    "NGWebUtils has not been initialized yet with an applicatin context.  "
                            + "Must be initialized before anything can be localized by writeLocalizedHistoryMessage.");
        }

        String key = hr.getCombinedKey();
        String[] args = null;

        String template = srvContext.getMessage(key, null, ar.getLocale());
        if (template == null || template.length() == 0) {
            template = key + " item {1n}; by user {2u}; comments {3}";
        }
        args = new String[] { hr.getContext(), hr.getResponsible(),
                hr.getComments() };

        writeWithParams(ar, template, args, ngp);
    }

    private static void writeContainerLinkIfExists(AuthRequest ar, String id)
            throws Exception {
        NGContainer cx = NGPageIndex.getContainerByKey(id);
        if (cx == null) {
            ar.write("(container ");
            ar.writeHtml(id);
            ar.write(")");
        } else {
            cx.writeContainerLink(ar, 100);
        }
    }

    /**
     * Write the template to the output stream, substituting in the data
     * parameter values into the appropriate places in the specified template.
     *
     * Template must be of this format:
     *
     * Added user {1u} to role {2r} by {4u} in project {3p}
     *
     * Each token has curley braces around a number a letter. The lowest number
     * should be 1, and the highest is the number of tokens. Here are the
     * meanings of the various letters:
     *
     * (nothing) just take the parameter and output it directly as text u - find
     * a user with that key, and output a link to that user p - find a project
     * with that key, and output a link to that project a - find an account
     * (book) with that key, and output a link to the account. r - find a role
     * with that name, and output a link to that role t - find a task with that
     * id, and output a link to the task d - find a document with that id, and
     * output a link to that document n - find a note with that id, and output a
     * link to that note m - find a reminder with that id, and output a link to
     * that reminder x - don't display anything, hide this parameter and do not
     * display
     *
     * there must be no spaces in the token, and the lower case letter must be
     * the last character
     *
     * @param ar
     *            The AuthRequest output stream, including locale and request
     *            context
     * @param template
     *            The message to be displayed that can containe placeholders for
     *            the parameters or causing exception.
     * @return Nothing, this writes the output to the stream
     * @throws Exception
     */
    private static void writeWithParams(AuthRequest ar, String template,
            String[] params, NGContainer container) throws Exception {
        // It should never happen that a null is passed to this method.
        if (template == null) {
            throw new ProgramLogicError(
                    "a null template was passed to writeWithParams.");
        }
        if (params == null) {
            // null can be passed as a convenience, and it means no parameters
            params = new String[0];
        }
        boolean used[] = new boolean[params.length];

        int start = 0;
        int openPos = template.indexOf("{", start);
        while (openPos >= 0) {
            ar.writeHtml(template.substring(start, openPos));
            openPos++;

            int closePos = template.indexOf("}", openPos);
            if (closePos < 0) {
                // make a lot of noise about this so the translator takes care
                // of the
                // problem
                throw new NGException("nugen.exception.incorrect.template",
                        new Object[] { template });
            }

            String token = template.substring(openPos, closePos);
            int tokenNum = DOMFace.safeConvertInt(token);
            int tokenLetter = token.charAt(token.length() - 1);
            if (tokenNum <= 0) {
                throw new ProgramLogicError(
                        "UI message template has no number, or has number 0.  "
                                + "Token must have a number 1 or greater.");
            }
            if (tokenNum > params.length) {
                throw new ProgramLogicError(
                        "UI message template has a token number '" + tokenNum
                                + "' but only '" + params.length
                                + "' values were passed.");
            }

            tokenNum--;

            String tokenVal = params[tokenNum];
            used[tokenNum] = true;

            switch (tokenLetter) {
            case 'u':
                AddressListEntry.writeParsedLinks(ar, tokenVal);
                break;
            case 'p':
                writeContainerLinkIfExists(ar, tokenVal);
                break;
            case 'a':
                writeContainerLinkIfExists(ar, tokenVal);
                break;
            case 'r':
                String roleAddress = ar.getResourceURL(
                        container,
                        "permission.htm#"
                                + URLEncoder.encode(tokenVal, "UTF-8"));
                ar.write("<a href=\"");
                ar.writeHtml(ar.retPath);
                ar.writeHtml(roleAddress);
                ar.write("\">");
                ar.writeHtml(tokenVal);
                ar.write("</a>");
                break;
            case 'm':
                container.writeReminderLink(ar, tokenVal, 60);
                break;
            case 't':
                container.writeTaskLink(ar, tokenVal, 60);
                break;
            case 'd':
                container.writeDocumentLink(ar, tokenVal, 60);
                break;
            case 'n':
                container.writeNoteLink(ar, tokenVal, 60);
                break;
            case 'x':
                // don't display anything for this, hide the value
                break;
            default:
                // this case includes any other letters that might be placed
                // there. Might want to complain about it...
                ar.writeHtmlWithLines(tokenVal);
            }
            start = closePos + 1;
            openPos = template.indexOf("{", start);
        }

        if (start < template.length()) {
            // write out the tail of the template.
            ar.writeHtml(template.substring(start));
        }

        for (int i = 0; i < params.length; i++) {
            if (!used[i]) {
                throw new ProgramLogicError(
                        "UI message template did not have a token for parameter '"
                                + i + ".  Should have '" + params.length
                                + "' tokens in all.");
            }
        }
    }

    public static String getExceptionMessageForAjaxRequest(Exception e,
            Locale locale) throws Exception {
        StringWriter stackOutput = new StringWriter();
        e.printStackTrace(new PrintWriter(stackOutput));
        return getJSONMessage(Constant.FAILURE,
                NGException.getFullMessage(e, locale), stackOutput.toString());
    }

    public static String getJSONMessage(String msgType, String message,
            String comments) throws Exception {
        JSONObject jsonMsg = new JSONObject();
        jsonMsg.put(Constant.MSG_TYPE, msgType);
        jsonMsg.put(Constant.MESSAGE, message);
        jsonMsg.put(Constant.COMMENTS, comments);
        String res = jsonMsg.toString();
        return res;
    }

    public static void sendResponse(AuthRequest ar, String responseMessage)
            throws IOException {
        ar.resp.setContentType("text/xml; charset=UTF-8");
        ar.resp.setHeader("Cache-Control", "no-cache");
        Writer writer = ar.resp.getWriter();
        writer.write(responseMessage);
        writer.close();
    }


    public static AuthRequest getAuthRequest(HttpServletRequest request,
            HttpServletResponse response, String assertLoggedInMsg)
            throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        ar.assertLoggedIn(assertLoggedInMsg);
        return ar;
    }

    public static List<AttachmentRecord> getSelectedAttachments(AuthRequest ar,
            NGContainer ngp) throws Exception {
        List<AttachmentRecord> res = new ArrayList<AttachmentRecord>();
        for (AttachmentRecord att : ngp.getAllAttachments()) {
            String paramId = "attach" + att.getId();
            if (ar.defParam(paramId, null) != null) {
                res.add(att);
            }
        }
        return res;
    }

    public static List<AddressListEntry> getExistingContacts(UserPage up)
            throws Exception {
        List<AddressListEntry> existingContacts = null;
        NGRole aRole = up.getRole("Contacts");
        if (aRole != null) {
            existingContacts = aRole.getExpandedPlayers(up);
        } else {
            existingContacts = new ArrayList<AddressListEntry>();
        }
        return existingContacts;
    }

    public static void addMembersInContacts(AuthRequest ar,
            List<AddressListEntry> contactList) throws Exception {
        UserPage up = ar.getUserPage();
        if (contactList != null) {
            NGRole role = up.getContactsRole();
            for (AddressListEntry ale : contactList) {
                role.addPlayerIfNotPresent(ale);
            }
            up.saveFile(ar, "Added contacts");
        }
    }

    public static void updateUserContactAndSaveUserPage(AuthRequest ar,
            String op, String emailIds) throws Exception {
        int eventType = 0;
        UserPage up = ar.getUserPage();
        if (emailIds.length() > 0) {
            if (op.equals("Remove")) {
                NGRole role = up.getContactsRole();
                AddressListEntry ale = AddressListEntry
                        .newEntryFromStorage(emailIds);
                eventType = HistoryRecord.EVENT_PLAYER_REMOVED;
                role.removePlayer(ale);
                up.saveFile(ar, "removed user " + emailIds + " from role "
                        + role.getName());
            } else if (op.equals("Add")) {
                eventType = HistoryRecord.EVENT_PLAYER_ADDED;

                Vector<AddressListEntry> contactList = AddressListEntry
                        .parseEmailList(emailIds);
                NGWebUtils.addMembersInContacts(ar, contactList);
            }
        }
        HistoryRecord.createHistoryRecord(up, "Updating contacts",
                HistoryRecord.CONTEXT_TYPE_ROLE, 0, eventType, ar, "");
    }


    /*
     * Use redirectToLoginView in baseController instead, It uses the message key instead of
     * message and pick the message from properties file to make translatable. This method will be replaced by BaseController method
     * from every where in code soon.
     *
    public static ModelAndView redirectToLoginView(AuthRequest ar,
            String message) throws Exception {
        ModelAndView redirectView = new ModelAndView(new RedirectView(
                ar.baseURL + "t/EmailLoginForm.htm"));
        redirectView.addObject("msg", message);
        redirectView.addObject("go", ar.getCompleteURL());
        return redirectView;
    }*/

    /*
     * public static String getCombinedRepresentation(String url, String token)
     * throws Exception { if (url == null) { throw new
     * ProgramLogicError("LicensedURL has a null url value, that is not allowed."
     * ); } if (url.length()<6) { throw new ProgramLogicError(
     * "getCombinedRepresentation does not know how to handle url: "+url); } int
     * pos = url.indexOf('?'); char separator = '?'; if (pos>0) { separator =
     * '&'; } return url + separator + token; }
     */

}
