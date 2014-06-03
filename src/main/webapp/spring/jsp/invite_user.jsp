<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@page import="org.socialbiz.cog.spring.Constant"
%><%
/*

Request Parameters:

    emailId = This parameter is used to get the email-id of invited user.
*/
    String emailId = ar.reqParam("emailId");
%>

<div class="content tab01">
    <%
    if (!ar.isLoggedIn())
    {
    %>
    <div class="generalContent">
        <fmt:message key="nugen.projectsettings.PermissionsLogin"></fmt:message>
        <div class="clearer">&nbsp;</div>
    </div>
    <%
    }
    else
    {
        if (ar.isMember())
        {
    %>
    <div class="generalArea">
        <p>This User does not have any regsitered profile in the System. If you want you can Invite
            this user to the Project.
        </p>
        <div class="generalHeading"> <fmt:message key="nugen.projectsettings.heading.AddMemberToProject"/> </div>
        <div class="generalContent">
            <!-- Tab Structure Starts Here -->
            <form name="addMemberRoleForm" action="addmemberrole.htm" method="get">
                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                    <tr>
                        <td width="150px;"><b><fmt:message key="nugen.projectsettings.label.AddNewMember"/> :</b></td>
                        <td></td>
                        <td>
                            <input type="text" size="65" name="rolemember" id="rolemember" value="<%ar.writeHtml(emailId); %>" class="wickEnabled" onfocus="initsmartInputWindowVlaue('smartInputFloater','smartInputFloaterContent');" autocomplete="off"  onkeyup="autoComplete(event,this);">
                        </td>
                    </tr>
                    <tr>
                        <td ></td>
                        <td></td>
                        <td>
                            <div style="position:relative;text-align:left">
                                <table  class="floater" style="position:absolute;top:0;left:0;background-color:#cecece;display:none;visibility:hidden"  id="smartInputFloater"  rules="none" cellpadding="0" cellspacing="0">
                                    <tr><td id="smartInputFloaterContent"  nowrap="nowrap" width="100%"></td></tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr><td>&nbsp;</td></tr>
                    <tr>
                        <td width="180px;"><b>Roles:</b></td>
                        <td></td>
                        <td>
                            <select name="roleList" id="roleList">
                                <option value="" selected="selected">Select</option>
                                <%
                                if(roles!=null){
                                    Iterator  iterator=roles.iterator();
                                    while(iterator.hasNext()){
                                        NGRole role = (NGRole)iterator.next();
                                        String roleNme=role.getName();
                                %>
                                <option value="<%ar.writeHtml(roleNme);%>"><%ar.writeHtml(roleNme);%></option>
                                <% }
                                }
                                %>
                            </select>
                            &nbsp;<input type="button" class="inputBtn"  onclick="addRoleMember();" value="<fmt:message key='nugen.projectsettings.button.AddMember'/>">
                            &nbsp;<input type="submit" class="inputBtn"  onclick="document.getElementById('action').value='cancel';" value="<fmt:message key='nugen.button.general.cancel'/>">
                        </td>
                    </tr>
                    <tr><td colspan="3">&nbsp;</td></tr>
                </table>
                <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                <input type="hidden" name="go" value="<%ar.writeHtml( ar.getCompleteURL());%>">
                <input type="hidden" name="role" value="M">
                <input type="hidden" name="invitedUser" value="true">
                <input type="hidden" name="action" id="action" value="">
            </form>
        </div>
        <%
        }
        else{%>
        <p> You are not allowed to perform this operation.</p>
        <% }
    }
    %>
    </div>
    <!-- Content Area Ends Here -->
</div>
