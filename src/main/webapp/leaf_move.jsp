<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.BaseRecord"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%ar = AuthRequest.getOrCreate(request, response, out);
    ar.retPath="../../";

    String p = ar.reqParam("p");
    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    boolean isMember = ar.isMember();
    boolean isAdmin = ar.isAdmin();

    String go = ar.defParam("go", null);
    if (go==null)
    {
        go = ar.getResourceURL(ngp,"");
    }

    ngb = ngp.getSite();
    pageTitle = ngp.getFullName();
    specialTab = "Stream";
    newUIResource = "history.htm";

    String hookLink = (String) session.getAttribute("hook");
    NGPage hookPage = null;
    if (hookLink!=null)
    {
        NGPageIndex ngpi2 = NGPageIndex.getContainerIndexByKey(hookLink);
        if (ngpi2!=null) {
            hookPage = ngpi2.getPage();
        }
    }%>

<%@ include file="Header.jsp"%>

<%
    headlinePath(ar, "History");
%>

<%
    if (!ar.isLoggedIn() && !ar.isStaticSite())
{
    mustBeLoggedInMessage(ar);
}
else if (!isMember && !isAdmin && !ar.isStaticSite())
{
    mustBeMemberMessage(ar);
}
else
{
%>

<br/>

<h1>Move Resources From Another Project</h1>

<div id="historydiv">

<%
    if (hookPage==null) {
%><p>Hook a project to get its resources to appear here to be moved.</p><%
    }
    else if (!ar.isAdmin()) {
%><p>You have to be administrator of the hooked project in order to move resources from it.</p><%
    }
    else {
%>
        <h3>From Project: <%
            ar.writeHtml(hookPage.getFullName());
        %></h3>
        <h3>To Project: <%
            ar.writeHtml(ngp.getFullName());
        %></h3>
        <form action="../../leaf_moveAction.jsp" method="post">
        <input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
        <input type="hidden" name="hook" value="<%ar.writeHtml(hookLink);%>">
        <input type="hidden" name="go" value="<%ar.writeHtml(ar.getCompleteURL());%>">
        <p>Select resources below to be moved to this current project, along with all the
           history and versions of those resources.<p>
        <input type="submit" value="Move Selected Resources">
        <h3><br/>Notes<br/></h3>
        <table><%
            for (NoteRecord lr : hookPage.getAllNotes()) {

                            //if (lr.isDeleted()) {
                            //    continue;
                            //}
                            int viz = lr.getVisibility();
                            if (viz != SectionDef.PUBLIC_ACCESS && viz != SectionDef.MEMBER_ACCESS) {
                                continue;
                            }
                            ar.write("\n<tr><td align=\"right\" width=\"70\">");
                            if (lr.isDeleted()) {
                                ar.write("Deleted");
                            }
                            else if (viz == SectionDef.PUBLIC_ACCESS) {
                                ar.write("Public");
                            }
                            else if (viz == SectionDef.MEMBER_ACCESS) {
                                ar.write("Member");
                            }
                            else {
                                ar.write("Other");
                            }
                            ar.write("</td><td><input type=\"checkbox\" name=\"note\" value=\"");
                            ar.write(lr.getId());
                            ar.write("\"> ");
                            ar.writeHtml(lr.getSubject());
                            if (lr.isDeleted()) {
                                appendProjectInfo(ar, lr.getMovedToProjectKey(), lr.getMovedToNoteId());
                            }
                            ar.write("</td></tr>");

                        }

                        ar.write("\n</table>\n<h3>Documents</h3>\n<table>");

                        for (AttachmentRecord tar : hookPage.getAllAttachments()) {

                            ar.write("\n<tr><td align=\"right\" width=\"70\">");
                            int viz = tar.getVisibility();
                            if (tar.isDeleted()) {
                                ar.write("Deleted");
                            }
                            else if (viz == SectionDef.PUBLIC_ACCESS) {
                                ar.write("Public");
                            }
                            else if (viz == SectionDef.MEMBER_ACCESS) {
                                ar.write("Member");
                            }
                            else {
                                ar.write("Other");
                            }
                            ar.write("</td><td><input type=\"checkbox\" name=\"doc\" value=\"");
                            ar.write(tar.getId());
                            ar.write("\"> ");
                            ar.writeHtml(tar.getNiceName());
                            if (tar.isDeleted()) {
                                appendProjectInfo(ar, tar.getMovedToProjectKey(), tar.getMovedToAttachId());
                            }
                            ar.write("</td></tr>");

                        }

                        ar.write("\n</table>\n<h3>Goals</h3>\n<table>");

                        for (GoalRecord tr : hookPage.getAllGoals()) {

                            int state = tr.getState();

                            if (state==BaseRecord.STATE_ERROR || state==BaseRecord.STATE_COMPLETE
                             || state==BaseRecord.STATE_SKIPPED ) {
                                continue;
                            }
                            ar.write("\n<tr><td align=\"right\" width=\"70\">");
                            ar.writeHtml(BaseRecord.stateName(state));
                            ar.write("</td><td><input type=\"checkbox\" name=\"task\" value=\"");
                            ar.write(tr.getId());
                            ar.write("\"> ");
                            ar.writeHtml(tr.getSynopsis());
                            if (state==BaseRecord.STATE_DELETED) {
                                appendProjectInfo(ar, tr.getMovedToProjectKey(), tr.getMovedToTaskId());
                            }
                            ar.write("</td></tr>");

                        }
        %></table><%

    }

%>
</div>
<br/>

<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var myColumnDefs = [
                {key:"context",label:"Pict", sortable:false,resizeable:true}
                {key:"context",label:"History", sortable:true,resizeable:true}
            ];

            var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("history"));
            myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            myDataSource.responseSchema = {
                fields: [{key:"context"}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200
                }),
                initialRequest: "results=999999",
                sortedBy : {key:"context", dir:YAHOO.widget.DataTable.CLASS_DESC}
            };


            var myDataTable = new YAHOO.widget.DataTable("historydiv", myColumnDefs, myDataSource, oConfigs);

            return {
                oDS: myDataSource,
                oDT: myDataTable
            };
        }();
    });
</script>


<%
}  //end of access control block
%>

<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
<%!public void protectUserAddress(AuthRequest ar, AddressListEntry ale) throws Exception
{
    //special behavior exists only for static sites, so for non
    //static site, just write out an ALE link.
    if (!ar.isStaticSite())
    {
        ale.writeLink(ar);
    }

    //For static sites, print a name if one exists, but if it
    //looks like an email address, DONT put it in the static site!
    String name = ale.getName();
    int atPos = name.indexOf("@");
    if (atPos>0) {
        name = name.substring(0,atPos);
    }
    ar.writeHtml(name);
}

public void protectComment(AuthRequest ar, String comment) throws Exception
{
    //special behavior exists only for static sites, so for non
    //static site, just write out an ALE link.
    if (!ar.isStaticSite())
    {
        ar.writeHtml(comment);
    }

    //For static sites, check to see if there is an at sign in there.
    //if so, just don't print out the comment.  There were many comments
    //that contain a list of email addresses, so simply avoid the entire
    //comment if there is an at sign.
    int atPos = comment.indexOf("@");
    if (atPos<0) {
        ar.writeHtml(comment);
    }
}

public void appendProjectInfo(AuthRequest ar, String mpkey, String mdid) throws Exception {
    if (mpkey!=null && mdid!=null && mpkey.length()>0  && mdid.length()>0) {
        ar.write(" -- Moved to ");
        NGPage oProj = NGPageIndex.getProjectByKeyOrFail(mpkey);
        oProj.writeContainerLink(ar, 40);
    }
}%>