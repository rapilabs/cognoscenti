<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.ReminderMgr"
%><%@page import="org.socialbiz.cog.ReminderRecord"
%><%@page import="org.socialbiz.cog.SectionDef"
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
    assureNoParameter(ar, "s");
    String rid  = ar.reqParam("rid");

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ar.assertMember("Unable to upload files to this page.");

    ReminderMgr rMgr = ngp.getReminderMgr();
    ReminderRecord rRec = rMgr.findReminderByID(rid);
    if (rRec == null)
    {
        throw new Exception("Unable to find the attachment with the id : " + rid);
    }

    String destFolder = rRec.getDestFolder();
    if ("*PUB*".equals(destFolder))
    {
        destFolder = "Public Attachments";
    }
    else if ("*MEM*".equals(destFolder))
    {
        destFolder = "Member Only Attachments";
    }
    boolean isFolder = false;
    String actionName = "Upload Attachment File";
    String dfolder = rRec.getDestFolder();
    if(!dfolder.equals("*PUB*") && !dfolder.equals("*MEM*")){
         actionName =  "Upload Folder File";
         NGSection fngs = ngp.getSectionOrFail("Folders");
         destFolder = dfolder;
         isFolder = true;
    }

    pageTitle = "Add File to "+ngp.getFullName();
%>

<%@ include file="Header.jsp"%>

<h1>Reminder to Upload: <%=ar.writeHtml(rRec.getSubject());%></h1>

<p>You are invited to upload a file so that it can be shared (in a controlled manner) with others
   on the project &quot;<% ar.writeHtml(ngp.getFullName());%>&quot;.
   Upload the file will complete and close the reminder.  Enter a description that will help
   others know what the file contains, or on what occasion it was produced.  Browse your local
   disk to locate and select the file.  Press "Upload Attachment" to send the file to the server.
</p>

<%
    if (!rRec.isOpen()) {
%>
<p><b>Note:</b> This reminder is marked to indicate that the requested file has <i>already been
uploaded</i> to the server, and is no longer being requested.  However, you may upload another
in case you believe the one uploaded previously is incorrect.
</p>
<%
    }
%>

<table width="600">
<col width="130">
<col width="470">

<form action="CreateAttachmentActionMime.jsp" method="post" enctype="multipart/form-data">
<input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
<input type="hidden" name="p"       value="<%ar.writeHtml( p);%>"/>
<input type="hidden" name="reminderid" value="<%ar.writeHtml( rid);%>"/>
<input type="hidden"  name="ftype" value="FILE"/>
<input type="hidden"  name="destFolder" value="<%ar.writeHtml( rRec.getDestFolder());%>"/>

<% if(!isFolder) { %>
<tr>
  <td>
    Description of<br/>
    Attachment:
  </td>
  <td>
    <textarea name="comment" id="fname"
              style="WIDTH:95%;"><%ar.writeHtml( rRec.getFileDesc());%></textarea>
  </td>
</tr>
<% } %>
<tr>
  <td>
    Local File:
  </td>
  <td>
    <input type="file"   name="fname"   id="fname" size="60"/>
  </td>
</tr>
<tr>
  <td></td><td>
    <input type="submit" name="action" value="<%ar.writeHtml(actionName);%>">
  </td>
</tr>
<tr>
    <td>&nbsp;</td>
    <td class="Odd"></td>
</tr>
<tr>
    <td>Destination Folder</td>
    <td class="Odd"><%ar.writeHtml( destFolder);%></td>
</tr>
<tr>
    <td>Requested by</td>
    <td class="Odd"><% ar.writeHtml( SectionUtil.cleanName(rRec.getModifiedBy())); %>,
                <% SectionUtil.nicePrintTime(ar, rRec.getModifiedDate(), ar.nowTime); %>
    </td>
</tr>
</table>
</form>

<br/>
<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
