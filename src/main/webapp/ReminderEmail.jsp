<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.License"
%><%@page import="org.socialbiz.cog.LicenseForProcess"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.ReminderMgr"
%><%@page import="org.socialbiz.cog.ReminderRecord"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%
    ar = AuthRequest.getOrCreate(request, response, out);

    String p = ar.reqParam("p");
    String rid = ar.reqParam("rid");

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);

    pageTitle = "Send Email: "+ngp.getFullName();
    ar.assertMember("Can not send email reminder");

    ReminderMgr rMgr = ngp.getReminderMgr();
    ReminderRecord rRec= rMgr.findReminderByID(rid);
    if (rRec==null)
    {
        throw new Exception("Can't find a reminder with id: "+rid);
    }
    String subject = "Please upload File ";

%>

<%@ include file="Header.jsp"%>

<!--  here is where the content goes -->


<table width="600">
<col width="130">
<col width="470">

<form action="ReminderEmailAction.jsp" method="post">
<input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
<input type="hidden" name="p"       value="<%ar.writeHtml(p);%>"/>
<input type="hidden" name="rid"     value="<%ar.writeHtml(rid);%>"/>
<input type="hidden" name="go"      value="<%ar.writeHtml(ar.getResourceURL(ngp,"attach.htm"));%>"/>
<tr>
  <td></td>
  <td>
    <input type="submit" name="action"  value="Send Mail"/> &nbsp;
  </td>
</tr>
<tr>
  <td>To:</td><td>
    <input type="text" size="60" name="emailto" value="<%ar.writeHtml(rRec.getAssignee());%>"/>
  </td>
</tr>
<tr>
  <td>
    Subject:
  </td>
  <td>
    <b>Please Upload File <%ar.writeHtml(subject);%></b>
  </td>
</tr>
<tr>
  <td colspan="2">
    <hr/>
  </td>
</tr>
<tr>
  <td></td>
  <td>
    <%writeReminderxxxEmailBody(ar, ngp, rRec);%>
  </td>
</tr>
</table>
</form>

<br/>
<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>

<%!

    public void writeReminderxxxEmailBody(AuthRequest ar, NGPage ngp, ReminderRecord rRec)
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
        ar.write("</td></tr>\n<tr><td>Subject:</td><td>Please Upload File ");
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
    }


%>
