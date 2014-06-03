<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="java.io.File"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Properties"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%//constructing the AuthRequest object should always be the first thing
    //that a page does, so that everything can be set up correctly.
    ar = AuthRequest.getOrCreate(request, response, out);

    String b = ar.reqParam( "b");

    ngb = NGPageIndex.getSiteByIdOrFail(b);

    boolean isMember = false;
    uProf = ar.getUserProfile();
    if (uProf!=null)
    {
        isMember = ngb.primaryOrSecondaryPermission(uProf);
    }
    pageTitle = "Site: "+ngb.getName();%>


<%@ include file="Header.jsp"%>


    <div class="pagenavigation">
        <div class="pagenav">
            <div class="left"><%ar.writeHtml(ngb.getName());%> &raquo; List of Leaves</div>
            <div class="right"></div>
            <div class="clearer">&nbsp;</div>
        </div>
        <div class="pagenav_bottom"></div>
    </div>


    <div class="section">
        <div class="section_title">
            <h1 class="left">List of Leaves</h1>
            <div class="section_date right"></div>
            <div class="clearer">&nbsp;</div>
        </div>
        <div class="section_body">

<%
    Vector<NGPageIndex> v = NGPageIndex.getAllProjectsInSite(ngb.key);
    if (v.size()>0)
    {
%>
        <div id="listofpagesdiv">
        <table id="pagelist">
            <thead>
                <tr>
                    <th>No</th>
                    <th>Project Name</th>
                    <th>Last Modified</th>
                    <th>Comment</th>
                </tr>
            </thead>
            <tbody>


<%

        int count=0;
        for (NGPageIndex ngpi : v)
        {
            count++;
            String linkAddr = ar.retPath + "p/" + ngpi.containerKey + "/public.htm";
%>
            <tr>
                <td>
                    <%=(count+1)%>
                </td>
                <td>
                    <a href="<%ar.writeHtml(linkAddr);%>"><%ar.writeHtml(ngpi.containerName);%></a>
                </td>
                <td>
                    <a href=\"<%=Long.toString(2222222222L-ngpi.lastChange)%>\"></a><%SectionUtil.nicePrintTime(ar, ngpi.lastChange, ar.nowTime);%>
                </td>
                <td>
<%
            String comma = "";
            if (ngpi.isOrphan())
            {
                out.write("Orphaned");
                comma = ", ";
            }
            if (ngpi.isDeleted)
            {
                out.write("DELETED");
                comma = ", ";
            }
            if (ngpi.requestWaiting)
            {
                out.write(comma);
                out.write("Pending Requests");
                comma = ", ";
            }
%>

            </td>
        </tr>
<%
        }
%>
                </tbody>
            </table>
            </div>
<%
    }
    else
    {

        %><h1>Welcome to the new account: </h1>
        <p>This account does not have any projects in it yet.</p><%
    }
%>

        </div>
    </div>

<%

//if you are a member of the account, you are allowed to create
//a project in it proactively
if (isMember)
{
%>
    <div class="section">
        <div class="section_title">
            <h1 class="left">Create a new project in this account</h1>
            <div class="section_date right"></div>
            <div class="clearer">&nbsp;</div>
        </div>
        <div class="section_body">
        <form action="CreatePage.jsp" method="post">
            <input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
            <input type="submit" name="action" value="New Project:">
            <input type="hidden" name="b" value="<%=ngb.getKey()%>">
            <input type="text" name="pt" value="">
        </form>
        </div>
    </div>

<%
}
%>

    <script type="text/javascript">
        YAHOO.util.Event.addListener(window, "load", function()
        {
            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                    {key:"pagename",label:"Project Name", sortable:true,resizeable:true},
                    {key:"lastmodified",label:"Last Modified", sortable:true,resizeable:true},
                    {key:"comments",label:"comments",sortable:true, resizeable:true}
                ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [{key:"no", parser:"number"},
                            {key:"pagename"},
                            {key:"lastmodified"},
                            {key:"comments"}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200
                    }),
                    initialRequest: "results=999999"
                };


                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"no",dir:"desc"}});

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });
    </script>


<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
