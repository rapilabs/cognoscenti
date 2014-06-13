<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.License"
%><%@page import="org.socialbiz.cog.LicenseForProcess"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.OptOutAddr"
%><%@page import="org.socialbiz.cog.ReminderMgr"
%><%@page import="org.socialbiz.cog.ReminderRecord"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.StringWriter"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't send email.");

    String go = ar.reqParam("go");
    String action = ar.reqParam("action");
    String p = ar.reqParam("p");
    String rid = ar.reqParam("rid");
    String emailto = ar.defParam("emailto", null);

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);

    ReminderMgr rMgr = ngp.getReminderMgr();
    ReminderRecord rRec = rMgr.findReminderByID(rid);
    if (rRec==null)
    {
        throw new Exception("Problem, can't find a reminder with id '"+rid+"'.");
    }
    String subject = "Reminder to Upload: "+rRec.getSubject();

    if (action.equals("Send Mail"))
    {

        Vector<AddressListEntry> addressList = EmailSender.parseAddressList(emailto);
        for (AddressListEntry ale : addressList)
        {
            OptOutAddr ooa = new OptOutAddr(ale);
            StringWriter bodyWriter = new StringWriter();
            AuthRequest clone = new AuthDummy(ar.getUserProfile(), bodyWriter);
            clone.write("<html><body>");
            writeReminderzzzEmailBody(clone, ngp, rRec);
            NGWebUtils.standardEmailFooter(clone, ar.getUserProfile(), ooa, ngp);
            clone.write("</body></html>");
            EmailSender.containerEmail(ooa, ngp, subject, bodyWriter.toString(), ar.getUserProfile().getEmailWithName());
        }

        HistoryRecord.createHistoryRecord(ngp, rid, HistoryRecord.CONTEXT_TYPE_DOCUMENT,
            ar.nowTime, HistoryRecord.EVENT_DOC_UPDATED, ar, "Reminder Emailed to "+emailto);
    }

    response.sendRedirect(go);

%>
<%!public void writeReminderzzzEmailBody(AuthRequest ar, NGPage ngp, ReminderRecord rRec)
        throws Exception
    {
        String userName = "Guest User";
        UserProfile up = ar.getUserProfile();
        if (up!=null)
        {
            userName = up.getName();
        }
        License lic = new LicenseForProcess(ngp.getProcess());

        String link = ar.baseURL + "RemindAttachment.jsp?p="
                +URLEncoder.encode(ngp.getKey(), "UTF-8")
                +"&lic="
                +URLEncoder.encode(lic.getId(), "UTF-8")
                +"&rid="
                +URLEncoder.encode(rRec.getId(), "UTF-8");

        ar.write("<table>");
        ar.write("<tr><td>From:</td><td>");
        ar.writeHtml(userName);
        ar.write("</td></tr>\n<tr><td>Subject:</td><td>");
        ar.writeHtml(rRec.getSubject());
        ar.write("</td></tr>\n<tr><td>Project: </td><td><a href=\"");
        ar.write(ar.baseURL);
        ar.write(ar.getResourceURL(ngp,""));
        ar.write("\">");
        ar.writeHtml(ngp.getFullName());
        ar.write("</a></td></tr>\n</table>\n<hr/>\n");
        ar.write("\n<p>You have been invited by ");
        ar.writeHtml(userName);
        ar.write(" to upload a file so that it can ");
        ar.write("be shared (in a controlled manner) with others on ");
        ar.write("the project \"");
        ar.writeHtml(ngp.getFullName());
        ar.write("\". Uploading the file will stop the email reminders. </p>");
        ar.write("\n<p><b>Instructions:</b> ");
        ar.writeHtml(rRec.getInstructions());
        ar.write("</p>");
        ar.write("\n<p><b>Description of File:</b> ");
        ar.writeHtml(rRec.getFileDesc());
        ar.write("</p>");
        ar.write("\n<p>Click on the following link or cut and paste the URL into a ");
        ar.write("web browser to access the page for uploading the file:</p>");
        ar.write("\n<p><a href=\"");
        ar.write(link);
        ar.write("\">");
        ar.write(link);
        ar.write("</a>");
        ar.write("</p>");
        ar.write("\n<p>Thank you.</p>");
        ar.write("\n<hr/>");
    }%>
<%@ include file="functions.jsp"%>
