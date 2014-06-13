<!doctype html>
<!-- The DOCTYPE declaration above will set the    -->
<!-- browser's rendering engine into               -->
<!-- "Standards Mode". Replacing this declaration  -->
<!-- with a "Quirks Mode" doctype may lead to some -->
<!-- differences in layout.                        -->
<%@page import="org.socialbiz.cog.AuthRequest"%>
<%@page import="org.socialbiz.cog.NGPageIndex"%>

<%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    String pageTitle  = "Gantt Chart";
%>

<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <script type="text/javascript" language="javascript" src="<%=ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
    <link rel="stylesheet" type="text/css" href="<%=ar.retPath%>css/jsgantt.css">
    <script type="text/javascript" src="<%=ar.retPath%>jscript/jsgantt.js"></script>
  </head>
 <body>
    <!-- OPTIONAL: include this if you want history support -->
    <!-- RECOMMENDED if your web app will not function without JavaScript enabled -->
    <noscript>
      <div style="width: 22em; position: absolute; left: 50%; margin-left: -11em; color: red; background-color: white; border: 1px solid red; padding: 4px; font-family: sans-serif">
        Your web browser must have JavaScript enabled
        in order for this application to display correctly.
      </div>
    </noscript>
    <div id="gwt_gantt"></div>
    <div style="position: relative;" id="GanttChartDIV"></div>
    <iframe id="__gwt_historyFrame" style="width:0;height:0;border:0"></iframe>
  </body>
</html>

<%@ include file="functions.jsp"%>