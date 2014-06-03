<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%
/*
Required parameters:

    1. pageId : This is the id of an project and here it is used to retrieve NGPage (Project's Details).
    2. roleName : This request parameter is required to get NGRole detail of given role.
    3. projectName : This is name of project here it is used to submit project name when any role is updated.
*/

    String book   = ar.reqParam("accountId");
    String roleName = ar.reqParam("roleName");
    String projectName = ar.reqParam("projectName");
    //String projectName = book;

%><%!
    String pageTitle="";
%><%
    NGContainer ngb =NGPageIndex.getContainerByKeyOrFail(book);
    UserProfile uProf = ar.getUserProfile();
    NGRole role = ngb.getRoleOrFail(roleName);
    pageTitle = roleName+" Role of "+ngb.getFullName();

    List<NGRole> roles= ngb.getAllRoles();

    ar.setPageAccessLevels(ngb);
    ar.assertMember("Unable to edit the roles of this page");

    String go = ar.getCompleteURL();

%>

<script type="text/javascript" language = "JavaScript">
    function submitRole(){
        var rolename =  document.getElementById("rolename");

        if(!(!rolename.value=='' || !rolename.value==null)){
                alert("Role Name Required");
                    return false;
        }
         <%if(roles!=null){
           Iterator  it=roles.iterator();
            while(it.hasNext()){%>
                if(rolename.value=='<%=UtilityMethods.quote4JS(((NGRole)it.next()).getName())%>'){
                    alert("Role Name already exist");
                   return false;
               }
          <%} }%>
        document.forms["createRoleForm"].submit();
    }

    function updateRole(op,id){
        url='<%=ar.retPath%>PageRoleAction.jsp?p=<%ar.writeURLData(projectName);%>&r=<%ar.writeURLData(roleName);%>&op='+op+'&id='+id;
        document.forms["updateRoleForm"].action = url;
        document.forms["updateRoleForm"].submit();
    }

    function removeRole(op,id){
        document.getElementById('id').value=id;
        document.forms["updateRoleForm"].action = '<%=ar.retPath%>PageRoleAction.jsp?p=<%ar.writeURLData(projectName);%>&r=<%ar.writeURLData(roleName);%>&op='+op;

        document.forms["updateRoleForm"].submit();
    }

    function addRoleMember(op,id){

        var role ='<%=UtilityMethods.quote4JS(roleName)%>';
        var member =document.getElementById("rolemember");

        if(!(!member.value=='' || !member.value==null)){
            alert("Member Required");
            return false;
        }
        updateRole(op,id);
    }

</script>
<%
    if (role == null)
    {
%>
    <div class="section_title">
        <p>No role exists named '<%ar.writeHtml(roleName);%>', would you like to create one?</p>
    </div>
    <!-- Content Area Starts Here -->
    <div id="createRole" class="generalArea">
        <div class="generalHeading"><fmt:message key="nugen.projectsettings.heading.CreateNewRole"/></div>
        <div class="generalContent">
            <form name="createRoleForm" action="CreateRole.form" method="post">
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td><b><fmt:message key="nugen.projectsettings.label.RoleName"/> :</b></td>
                        <td><input type="text" name="rolename" id="rolename" size="73" value =""/>&nbsp;
                        <input type="button" class="inputBtn" value="Add Role" onclick="submitRole();"></td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td><b><fmt:message key="nugen.projectsettings.label.MessageCriteria"/> :</b></td>
                        <td><textarea name="description" id="description" cols="70" rows="2"></textarea></td>
                    </tr>
                </table>
            </form>
        </div>
    </div>
<%
    }else{

%>
    <!-- Content Area Starts Here -->
    <div id="listRole" class="generalArea">
        <form name="updateRoleForm" method="post">
            <input type="hidden" name="go" value="<% ar.writeHtml(go); %>">
            <%List<AddressListEntry> allUsers = role.getDirectPlayers();%>
            <div class="generalHeading"> Details of Role</div>
            <div class="generalContent">
                <input type="hidden" name="id" value="na">
                <input type="hidden" name="pageId" value="<%ar.writeHtml(ngb.getKey());%>">
                <input type="hidden" name="roleName" value="<%ar.writeHtml(role.getName());%>">
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td><b>Name:</b></td>
                        <td><b><%ar.writeHtml(roleName);%></b></td>
                    </tr>
                    <tr>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                       <td><b>Description:</b></td>
                       <td><textarea name="desc" id="description" cols="70" rows="2"><%ar.writeHtml(role.getDescription());%></textarea></td>
                   </tr>
                   <tr>
                        <td>&nbsp;</td>
                    </tr>
                    <tr>
                       <td><b>Eligibility:</b></td>
                       <td><textarea name="reqs" id="description" cols="70" rows="2"><%ar.writeHtml(role.getRequirements());%></textarea>
                       <input type="button" class="inputBtn" value="Update Details" onclick="updateRole('Update Details','na');"></td>
                    </tr>
                </table>
            </div>
            <div class="generalHeading"> Expanded List of Players</div>
            <div class="generalContent">
            <%
            allUsers = role.getExpandedPlayers(ngb);
            ar.write("<table cellpadding=\"0\" cellspacing=\"0\" width=\"100%\" class=\"gridTable\">");
            for (AddressListEntry ale : allUsers)
            {
                ar.write("<tr>");
                ar.write("<td>");
                ale.writeLink(ar);
                ar.write("</td>");
                ar.write("<td>");
                ar.writeHtml(ale.getEmail());
                ar.write("</td>");
                ar.write("</tr>");
            }
            ar.write("</table>");
            %>
            </div>
        </form>
    </div>
<%
    }
%>
