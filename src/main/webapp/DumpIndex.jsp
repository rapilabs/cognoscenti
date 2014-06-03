<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="java.io.File"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Properties"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Unable to dump index.");

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
    <title>Dump Index</title>
    <link href="mystyle.css" rel="stylesheet" type="text/css"/>
</head>
<body>

<ul>
<%
    NGPageIndex[] allPages = NGPageIndex.getAllPageIndex();

    %><li>number of pages = <%
    out.write(Integer.toString(allPages.length));

    for (NGPageIndex iEntry : allPages)
    {
        String key = iEntry.pageKey;
        %><li>Inlinks of <b><%ar.writeHtml( key);%></b><ol><%

        Enumeration e0 = iEntry.getInLinkPages().elements();
        while (e0.hasMoreElements())
        {
            NGPageIndex pi0 = (NGPageIndex)e0.nextElement();
            %><li><%
            ar.writeHtml( pi0.pageName);
        }
        %></ol><li>Outlinks from  <%ar.writeHtml( key);%><ul><%
        Enumeration e1 = iEntry.getOutLinkPages().elements();
        while (e1.hasMoreElements())
        {
            NGPageIndex pi1 = (NGPageIndex)e1.nextElement();
            %><li><%
            ar.writeHtml( pi1.pageName);
        }
        %></ul><li>Pages with preferences to <%ar.writeHtml( key);%><ul><%
        NGPage aPage = iEntry.getPage();
        %></ul><li>Direct Page: <%
        ar.writeHtml(aPage.getFullName());
        %><li>Page Path: <%
        ar.writeHtml(iEntry.pagePath);

        %><li>Links On <%
        Vector pageSections = aPage.getAllSections();
        out.write(Integer.toString(pageSections.size()));
        %> Sections <ul><%
        Enumeration en = pageSections.elements();
        while (en.hasMoreElements())
        {
            Vector tmpRef = new Vector();
            NGSection sec = (NGSection) en.nextElement();
            sec.findLinks(tmpRef);
            %><li><%
            ar.writeHtml( sec.getName());
            %><ul><%
            Enumeration e3 = tmpRef.elements();
            while (e3.hasMoreElements())
            {
                String refVal = (String) e3.nextElement();
                %><li><%
                ar.writeHtml( refVal);
            }
            %></ul><%
        }

        %></ul><br/><%


    }
%>
</ul>

</body>
</html>

<%@ include file="functions.jsp"%>
