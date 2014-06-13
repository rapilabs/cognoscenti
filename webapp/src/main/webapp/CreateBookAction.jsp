<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Unable to create a new account.  ");

    String bn = ar.reqParam("bn");

    NGBook ngb = NGBook.createNewSite(bn);
    UserProfile up = ar.getUserProfile();
    ngb.getPrimaryRole().addPlayer(up);
    ngb.getSecondaryRole().addPlayer(up);
    ngb.saveSiteAs(ngb.getKey(), ar.getUserProfile(), "Create Site Action");

    response.sendRedirect("BookPages.jsp?b="+ngb.getKey());%>
<%@ include file="functions.jsp"%>
