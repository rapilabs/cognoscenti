<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGTerm"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@ include file="/spring/jsp/include.jsp"
%><%
/*
Required parameter:
    // TODO
    1. t :

*/

    String t = ar.reqParam("t");

%><%
    String pageTitle = "";
    Vector<NGPageIndex> projects = NGPageIndex.getContainersForTag(t);
%>
    <br/>
    <div class="generalArea">
      <div class="generalHeading">Projects that are tagged with &quot;<%ar.writeHtml(t);%>&quot; &nbsp;</div>
      <div class="generalContent">
        <div style="background-color:#f5f5f5; padding:10px">
        </div>
      </div>
    </div>


    <table>
    <%
    for (NGPageIndex ngpi : projects)
    {
        %>
        <tr>
        <td><% ngpi.writeTruncatedLink(ar, 50); %> &nbsp; </td><td> &nbsp; </td>
        <td>tags:<% for (NGTerm ngt : ngpi.hashTags) { %>
                #<a href="TagLinks.htm?t=<% ar.writeURLData(ngt.sanitizedName);%>"><% ar.writeHtml(ngt.sanitizedName);%></a>,
            <% } %>
        </td>
        </tr>
        <%
    }
    %>
    </table>


