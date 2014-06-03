<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="java.io.File"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Properties"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%
    ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Unable to list users.");
    if (!ar.isSuperAdmin()) {
        //throw new Exception("Need to be server administrator to list and edit users");
    }

    UserProfile profs[] = UserManager.getAllUserProfiles();

    pageTitle = "Users";
%>
<%@ include file="Header.jsp"%>
<%
    if (ar.isLoggedIn())
    {
%>

    <div class="section">
        <div class="section_title">
            <h1 class="left">List of Users</h1>
            <div class="section_date right"></div>
            <div class="clearer">&nbsp;</div>
        </div>
        <div class="section_body">

            <div id="listofpagesdiv">
                <table id="pagelist">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>User Name</th>
                            <th>Last Login</th>
                            <th>Key</th>
                        </tr>
                    </thead>
                    <tbody>


<%

    for (int i=0; i<profs.length; i++)
    {
        UserProfile profile = profs[i];
        String linkAddr = ar.retPath + "UserProfile.jsp?u="+profile.getKey();
        String userName = profile.getName();
        boolean displayWarning = false;
        if (userName==null || userName.length()==0)
        {
            userName = "~No Name~";
            displayWarning=true;
        }
        if (profile.getDisabled())
        {
            displayWarning=true;
        }
        if (profile.getPreferredEmail()==null)
        {
            displayWarning=true;
        }
%>
        <tr>
            <td><%=(i+1)%></td>
            <td><%ar.writeHtml(userName);%><% if (displayWarning)
                  {%> <a href="<%ar.writeHtml(linkAddr);%>" title="see warnings"><img src="warning.gif"></a><%
                  }%></td>
            <td><%SectionUtil.nicePrintTimestamp(out, profile.getLastLogin());%></td>
            <td><a href="<%ar.writeHtml(linkAddr);%>" title="navigate to the profile for this user"><%ar.write(profile.getKey());%></a></td>
        </tr>
<%
    }
%>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        YAHOO.util.Event.addListener(window, "load", function()
        {
            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                    {key:"username",label:"User Name", sortable:true,resizeable:true},
                    {key:"lastmodified",label:"Last Login", sortable:true,resizeable:true},
                    {key:"comments",label:"Key",sortable:true, resizeable:true}
                ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [{key:"no", parser:"number"},
                            {key:"username"},
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

<%
    }
    else
    {
%>
    <p>please log in to see the list of users</p>

<%  }  %>

<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
