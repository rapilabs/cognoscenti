<!doctype html>
<!-- The DOCTYPE declaration above will set the    -->
<!-- browser's rendering engine into               -->
<!-- "Standards Mode". Replacing this declaration  -->
<!-- with a "Quirks Mode" doctype may lead to some -->
<!-- differences in layout.                        -->
<%@page import="org.socialbiz.cog.AuthRequest"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
%>

<script type="text/javascript" language="javascript" src="<%=ar.retPath%>bewebapp/bewebapp.nocache.js"></script>

<!-- OPTIONAL: include this if you want history support -->
<iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>

<br/><br/>
<table width="100%" align="left">
  <tr>
    <td id="gwt_notes"></td>
  </tr>
</table>
