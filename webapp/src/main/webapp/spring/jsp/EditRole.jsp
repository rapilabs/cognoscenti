<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%@page import="org.socialbiz.cog.NGRole"
%><%/*
Required parameters:

    1. pageId : This is the id of an project and here it is used to retrieve NGPage (Project's Details).
    2. roleName : This request parameter is required to get NGRole detail of given role.

    3. roles    : This parameter is used to get List of all existing roles , this list is required to check
                  if provided 'role name' is already exists in the system or not.
*/

    String pageId   = ar.reqParam("pageId");
    String roleName = ar.reqParam("roleName");

    List roles=(List)request.getAttribute("roles");%><%!String pageTitle="";%><%NGPage ngp =NGPageIndex.getProjectByKeyOrFail(pageId);
    String projectKey = ngp.getKey();

    UserProfile uProf = ar.getUserProfile();
    NGRole role = ngp.getRoleOrFail(roleName);
    pageTitle = roleName+" Role of "+ngp.getFullName();
    NGBook ngb = ngp.getSite();

    ar.setPageAccessLevels(ngp);
    ar.assertMember("Unable to edit the roles of this page");

    String go = "permission.htm";
    List<AddressListEntry> allUsers = role.getExpandedPlayers(ngp);

%>

    <div id="listRole" class="generalArea">
        <form name="updateRoleForm" id="updateRoleForm" method="post" action="pageRoleAction.form">
            <input type="hidden" name="go" value="<% ar.writeHtml(go); %>">
            <% //code requires this id parameter but not really needed for this form %>
            <input type="hidden" name="id" value="na">
            <input type="hidden" name="r" value="<%ar.writeHtml(role.getName());%>">

            <div class="pageHeading">Details of Role '<%ar.writeHtml(roleName);%>'</div>
            <div class="pageSubHeading">You can modify the details of a particular role</div>
            <div class="generalSettings">


                <table width="720px">
                    <tr><td style="height:10px" colspan="3"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2">Name:</td>
                        <td style="width:20px;"></td>
                        <td><%ar.writeHtml(roleName);%></td>
                    </tr>
                    <tr><td style="height:8px" colspan="3"></td></tr>
                    <tr>
                         <td class="gridTableColummHeader_2" valign="top">Description:</td>
                         <td style="width:20px;"></td>
                         <td><textarea name="desc" id="description" class="textAreaGeneral" rows="4"><%ar.writeHtml(role.getDescription());%></textarea></td>
                    </tr>
                    <tr><td style="height:8px" colspan="3"></td></tr>
                    <tr>
                         <td class="gridTableColummHeader_2" valign="top">Eligibility:</td>
                         <td style="width:20px;"></td>
                         <td><textarea name="reqs" id="description" class="textAreaGeneral" rows="4"><%ar.writeHtml(role.getRequirements());%></textarea></td>
                    </tr>
                    <tr><td style="height:8px" colspan="3"></td></tr>
                    <tr>
                         <td class="gridTableColummHeader_2"></td>
                         <td style="width:20px;"></td>
                         <td><input type="submit" name="op" class="inputBtn" value="Update Details">
                             &nbsp; &nbsp; &nbsp;
                             <input type="submit" name="op" class="inputBtn" value="Delete Role">
                             <input type="checkbox" name="confirmDelete" value="yes"> Confirm delete</td>
                    </tr>
                    <tr><td style="height:10px" colspan="3"></td></tr>
                </table>
            </div>

        </form>

        <div class="generalHeadingBorderLess">Expanded List of Players of Role '<%ar.writeHtml(roleName);%>'</div>
        <div class="generalContent">
        <table cellpadding="0" cellspacing="0" width="100%" class="gridTable">
        <%
        for (AddressListEntry ale : allUsers) {
            ar.write("<tr>");
            ar.write("<td width=\"230px\" >");
            ale.writeLink(ar);
            ar.write("</td>");
            ar.write("<td>");
            ar.writeHtml(ale.getEmail());
            ar.write("</td>");
            ar.write("</tr>");
        }
        %>
        </table>
        </div>
    </div>
