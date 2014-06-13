<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%
    ar = AuthRequest.getOrCreate(request, response, out);

    String p = ar.reqParam("p");

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ProcessRecord process = ngp.getProcess();

    pageTitle = ngp.getFullName()+": Forge Link";
%>

<%@ include file="Header.jsp"%>

<!--  here is where the content goes -->

<h1>Create a new link the parent</h1>

<p>This operation will link the project &quot;<% ar.writeHtml(ngp.getFullName()); %>&quot; to another leaf,
as a subprocess of that project.  That other project will become the parent
of &quot;<% ar.writeHtml(ngp.getFullName()); %>&quot;</p>

<table width="600">
<col width="130">
<col width="470">

<form action="ForgeLinkAction.jsp" method="post">
<input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
<tr>
  <td colspan="2">
    <input type="submit" name="action" value="Create Link">
  </td>
</tr>
<tr><td colspan="2">
  <br/>
  <input type="hidden" name="p" value="<%ar.writeHtml( p);%>">
  <input type="radio" name="createTask" value="no"> Specify an existing Goal to link to:
  </td></tr>

<tr>
  <td>
    Goal Link:
  </td>
  <td>
    <input type="text" name="taskUrl" size="60">
  </td>
</tr>
<tr>
  <td></td><td>
    <p>Specify here the Wf-XML link to a goal.  It must be a link that
       includes an access token within it so that the server is able to
       update the goal, and set the subprocess to be this leaf.
       If the goal already has a subprocess setting, it will be overwritten
       to point to this project.</p>

  </td>
</tr>


<tr>
  <td colspan="2"><br/>
    <input type="radio" name="createTask" value="yes"> Create a goal, and link to that:
  </td>
</tr>
<tr>
  <td>Process Link: </td><td><input type="text" name="procUrl" size="60"></td></tr>

<tr>
  <td></td><td>
    <p>Specify here the Wf-XML link to a process.  It must be a link that
       includes an access token within it so that the server is able to
       update the process with a new goal, and set the subprocess of that
       new goal to be this project.
  </td>
</tr>
<tr><td>Goal Subject: </td><td><input type="text" name="taskSub" size="60"
       value="<% ar.writeHtml( process.getSynopsis()); %>"></td></tr>

<tr><td>Goal Description: </td><td><input type="text" name="taskDes" size="60"
       value="<% ar.writeHtml( process.getDescription()); %>"></td></tr>

<tr>
  <td></td><td>
    <p>Specify the subject and description of the goal to be created.</p>
  </td>
</tr>
<tr>
  <td></td><td>
    <input type="radio" name="linkwf" value="yes" checked="checked"> Use Wf-XML (Standard)<br/>
    <input type="radio" name="linkwf" value="no"> Use Browser Redirect (NuGen only)

  </td>
</tr>
</table>
</form>

<br/>
<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>
