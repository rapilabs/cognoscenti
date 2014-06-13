<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.MimeTypes"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGLeafServlet"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@page import="java.io.File"
%><%@page import="java.util.Properties"
%><%@page import="org.socialbiz.cog.ServerInitializer"
%><%AuthRequest ar = AuthRequest.getOrCreate(request, response, out);

    if (ServerInitializer.serverInitState==ServerInitializer.STATE_PAUSED) {

        %>
        <html>
        <body>
        <h1>Server Paused</h1>
        <form action="AdminAction.jsp" method="POST">
            <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
            <input type="hidden" name="go" value="Admin.jsp"/>
            <input type="submit" name="action" value="Restart Server"/>
        </form>
        </body>
        </html>
        <%
        return;
    }

    ar.assertLoggedIn("Must be logged in to run Admin page");
    if (!ar.isSuperAdmin()){
        throw new Exception("must be site administrator to use this Site Admin page");
    }

    //clear the session setting to force re-read of config file
    //maybe this should be done only on an error.
    ar.getSession().flushConfigCache();

    String startupProblem = "";
    if (NGLeafServlet.initializationException!=null)
    {
        startupProblem = NGLeafServlet.initializationException.toString();
    }

    long lastSentTime = SuperAdminLogFile.getLastNotificationSentTime();

    Runtime rt = Runtime.getRuntime();%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
    <head>
        <title>main</title>
    </head>
    <body>
            <table>
        <form action="AdminAction.jsp" method="POST">
            <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
            <input type="hidden" name="go" value="Admin.jsp"/>

                <tr>
                    <td>
                        <input type="submit" name="action" value="Reinitialize Index"/>
                        Discard the cached index, and create a new index from the files on the disk.
                    </td>
               </tr>
                <tr>
                    <td>
                        <input type="submit" name="action" value="Remove Disabled Users"/>
                        Discard disabled users from the list of users.
                    </td>
               </tr>
                <tr>
                    <td>
                        <input type="submit" name="action" value="Garbage Collect Pages"/>
                        Really delete the deleted pages.
                    </td>
               </tr>
                <tr>
                    <td>
                        <input type="submit" name="action" value="Send Test Email"/>
                        See if the server can send an email.
                    </td>
               </tr>
                <tr>
                    <td>
                        <input type="submit" name="action" value="Pause Server"/>
                        Put the server into paused mode.
                    </td>
               </tr>
                <tr>
                    <td>
                        <input type="submit" name="action" value="Restart Server"/>
                        Return to running from paused mode.
                    </td>
               </tr>
        </form>

            </table>
    <br/>
    <p><b><% ar.writeHtml(startupProblem); %></b></p>
    <ul>
    <li>Runtime.freeMemory: <% writeCommas(out, Long.toString(rt.freeMemory())); %></li>
    <li>Runtime.totalMemory: <% writeCommas(out, Long.toString(rt.totalMemory())); %></li>
    <%

    Cookie[] cs = request.getCookies();
    for (Cookie c : cs)
    {
        %>
        <li>cookie: <%= c.getName() %>, path: <%= c.getPath() %>, domain: <%= c.getDomain() %></li>
        <%
    }
    %>

    <li>Mime type for doc: <%= MimeTypes.getMimeType("xxxx.doc") %></li>
    <li>Mime type for jpg: <%= MimeTypes.getMimeType("xxxx.jpg") %></li>
    <li>Mime type for gif: <%= MimeTypes.getMimeType("xxxx.gif") %></li>
    <li>Mime type for doc: <%= MimeTypes.getMimeType("xxxx.doc") %></li>
    <li>Mime type for xls: <%= MimeTypes.getMimeType("xxxx.xls") %></li>
    <li>Mime type for ppt: <%= MimeTypes.getMimeType("xxxx.ppt") %></li>
    <li>Mime type for docx: <%= MimeTypes.getMimeType("xxxx.docx") %></li>
    <li>Mime type for xlsx: <%= MimeTypes.getMimeType("xxxx.xlsx") %></li>
    <li>Mime type for pptx: <%= MimeTypes.getMimeType("xxxx.pptx") %></li>
    </ul>
    <h3>Deleted Pages</h3>
    <ul>
    <%

    {
        for (NGPageIndex ngpi : NGPageIndex.getDeletedContainers())
        {
            ar.write("\n<li><a href=\"");
            ar.writeHtml(ar.getResourceURL(ngpi,"public.htm"));
            ar.write("\">");
            ar.writeHtml(ngpi.containerPath.toString());
            File deadFile = ngpi.containerPath;
            ar.write("</a>");
            if (deadFile.exists())
            {
                ar.write(" (file is there)");
            }
            ar.write("</li>");
        }
    }

    %>
    </ul>
    <h3>Last Notification Sent on: </h3><%SectionUtil.nicePrintDate(out,lastSentTime); %>(<%SectionUtil.nicePrintTime(ar,lastSentTime,ar.nowTime); %>)
    </body>
</html>

<%@ include file="functions.jsp"%>
<%
    NGPageIndex.clearLocksHeldByThisThread();
%>
<%!public void writeCommas(Writer out, String val)
        throws Exception
    {
        int first =  val.length()%3;
        if (first>0)
        {
            out.write(val.substring(0,first));
            val = val.substring(first);
            out.write(",");
        }
        while (val.length()>3)
        {
            out.write(val.substring(0,3));
            val = val .substring(3);
            out.write(",");
        }
        if (val.length()>0)
        {
            out.write(val);
        }
    }%>
