<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.MimeTypes"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AttachmentVersion"
%><%@page import="org.socialbiz.cog.NGLeafServlet"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGProj"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@page import="java.io.File"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.io.FileOutputStream"
%><%@page import="java.util.Properties"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Must be logged in to run Unfold Files page");
    if (!ar.isSuperAdmin()) {
        throw new Exception("must be site administrator to use this Site Admin page");
    }

    /*
    * As a security precaution, this works only to a specific fixed folder, and that
    * folder must be created separately, and must be manually entered here.
    * This is purposeful to make it hard, because it is not expected that people
    * will need this page in the future, once the data repositories have been converted.
    */
    File destFolder = new File("c:/unfold/");

    if (!destFolder.exists()) {
        throw new Exception("you need to set up the destination directory first");
    }

%>
<html><body>
<h1>Project Convert</h1>
<%
    int limit=800;

    for (NGPageIndex pi : NGPageIndex.getAllContainer()) {

        if (!pi.isProject()) {
            continue;
        }
        NGPage ngp = pi.getPage();
        if (ngp instanceof NGProj) {
            continue;
        }
        if (--limit<=0) {
            break;
        }

        %>
        <p>Project <%
        ar.writeHtml(pi.containerName);
        %></p>
        <ul><%
            NGBook ngb = ngp.getSite();

                File accountFolder = new File(destFolder, stripBadChars(ngb.getFullName()));

                File projectFolder = new File(accountFolder, stripBadChars(ngp.getFullName()));

                projectFolder.mkdirs();

                File projectFile = new File(projectFolder, ngp.getKey()+".sp");

                ngp.saveAs(projectFile);

                for (AttachmentRecord att : ngp.getAllAttachments()) {

            String docName = att.getNiceName();
        %>
            <li><% ar.writeHtml(docName); %></li><%
            if (att.getVersions(ngp).size()==0) {
                //skip the error cases
                continue;
            }
            File docFile = new File(projectFolder, docName);
            if (docFile.exists()) {
                continue;
            }
            AttachmentVersion av = att.getLatestVersion(ngp);
            if (av==null) {
                //only happens if, for some reason, there is a GONE attachment
                continue;
            }
            File sourceFile = av.getLocalFile();
            FileInputStream fis = new FileInputStream(sourceFile);

            FileOutputStream fos = null;
            try {
                fos = new FileOutputStream(docFile);
            }
            catch (Exception e) {
                continue;
            }
            byte[] buf = new byte[2000];
            int amt = fis.read(buf);
            while (amt>0) {
                fos.write(buf, 0, amt);
                amt = fis.read(buf);
            }
            fos.close();
            fis.close();
            out.flush();

        }

        %>
        </ul><%
        out.flush();
    }

    %>
<p>    Handled <%= (800-limit) %> projects</p>
</body></html>

<%!

    public String stripBadChars(String sin) {

        StringBuffer sout = new StringBuffer();

        int last = sin.length();
        for (int i=0; i<last; i++) {

            char ch = sin.charAt(i);
            switch (ch) {

                case '<':
                case '>':
                case ':':
                case '"':
                case '/':
                case '\\':
                case '|':
                case '?':
                case '*':
                    continue;
                default:
                    sout.append(ch);
            }
        }
        return sout.toString();
    }

%>