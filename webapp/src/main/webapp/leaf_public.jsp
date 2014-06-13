<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%ar = AuthRequest.getOrCreate(request, response, out);
    ar.retPath="../../";

    String p = ar.reqParam("p");
    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ngb = ngp.getSite();

    String pageMode = ar.defParam("pageMode", "all");

    pageTitle = ngp.getFullName();
    specialTab = "Public Notes";

    String testwait = "false";
    try{
        testwait = ar.getSystemProperty("pageNotification");
        if(testwait == null)
            testwait = "false";
    }catch(Exception e){
        //Property is not set no need to do the wait test
        testwait = "false";
    }

     String gwtcUrl = ar.retPath + "GWTNoteEditor.jsp?pid="
            + SectionUtil.encodeURLData(ngp.getKey()) + "&nid=";%>

<%@ include file="Header.jsp"%>

<%
    headlinePath(ar, "Public Section");
        if (!ar.isStaticSite())
        {
            String pdflink =ar.retPath + "t/" + ngb.getKey()+"/"+ngp.getKey()+"/pdf/page.pdf";
%>
            <form action="<%= ar.retPath %>EditLeaflet.jsp" method="get" target="_blank">
            <input type="hidden" name="p" value="<% ar.writeHtml(p); %>">
            <input type="hidden" name="viz" value="1">
            <input type="hidden" name="go" value="<% ar.writeHtml(ar.getCompleteURL()); %>">
            <input type="submit" value="Create New Public Note">
            <a href="<%=gwtcUrl%>" title="GWT Create Note" target="_blank">
                <img src="<%=ar.retPath%>gwt-logo.png" width="30" height="30" />
            </a>

            </form>
            <h3 ALIGN="CENTER"><a align=right href="<%=pdflink%>">View AS PDF</a></h3>

<%          if(ar.isLoggedIn() && testwait.trim().equalsIgnoreCase("true")){
%>
                <script type="text/javascript" language="javascript" src="<%=ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
                <table width="60%" align="center">
                    <tr>
                        <td id="gwt_wait"></td>
                    </tr>
                </table>
<%          }
%>
<%
        }
        writeLeaflets(ngp, ar, SectionDef.PUBLIC_ACCESS);
        out.flush();
%>
<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
<!-- Generated in <%= (System.currentTimeMillis()-ar.nowTime) %> milliseconds -->
