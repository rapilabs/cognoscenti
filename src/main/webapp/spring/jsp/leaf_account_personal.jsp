<%@page import="org.socialbiz.cog.spring.NGWebUtils"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.CustomRole"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@ include file="leaf_account_ProjectSettings.jsp"
%><%
    request.setAttribute("pageTitle",pageTitle);
%>
    <div class="content tab01">
    <%
    if (!ar.isLoggedIn())
    {
    %>
        <div class="generalContent">
            <fmt:message key="nugen.projecthome.personal.logout"></fmt:message>
        </div>
    <%
    }
    else
    {
    %>
        <div class="generalContent">
            <fmt:message key="nugen.projecthome.privatelogin">
                <fmt:param value='<%= ar.getBestUserId() %>'></fmt:param>
            </fmt:message>
        </div>
    <%
    }
    out.flush();

    if (ar.isLoggedIn()) {
    %>
        <div class="generalContent">
            <br>
            <table width="100%" class="gridTable" >
                <tr>
                    <td colspan="2" ><b>Roles of site:</b><br></td>
                </tr>

    <%
        if(roles!=null){
            UserProfile up = ar.getUserProfile();
            String roleMember = up.getUniversalId();
            String roleRequestState = "";
            Iterator  iterator=roles.iterator();
            RoleRequestRecord roleRequestRecord = null;
            String requestDescription = "";
            String responseDescription = "";
            while(iterator.hasNext()){
                roleRequestState = "";
                NGRole role = (NGRole)iterator.next();

                String roleName=role.getName();
                String roleDescription = role.getDescription();
                boolean isPlayer = role.isExpandedPlayer(up, ngb);

                String leaveRole = "display: block;";
                String joinRole = "display: none;";
                String pending =  "display: none;";
                String rejected =  "display: none;";
                roleRequestRecord = ngb.getRoleRequestRecord(roleName,roleMember);
                if(roleRequestRecord != null){
                    roleRequestState = roleRequestRecord.getState();
                    requestDescription = roleRequestRecord.getRequestDescription();
                    responseDescription =roleRequestRecord.getResponseDescription();

                }
                if(!isPlayer){
                    if("Requested".equalsIgnoreCase(roleRequestState )){
                        pending =  "display: block;";
                        joinRole = "display: none;";
                        rejected =  "display: none;";
                        leaveRole = "display: none;";
                    }else  if("Rejected".equalsIgnoreCase(roleRequestState)){
                        pending =  "display: none;";
                        joinRole = "display: none;";
                        leaveRole = "display: none;";
                        rejected =  "display: block;";
                    }else  if("Cancelled".equalsIgnoreCase(roleRequestState)){
                        pending =  "display: none;";
                        joinRole = "display: block;";
                        leaveRole = "display: none;";
                        rejected =  "display: none;";
                    }else{
                        joinRole = "display: block;";
                        leaveRole = "display: none;";
                    }
                }
        %>
                <tr>
                    <td class="gridTableColummHeader"  width="35%" valign="top">
                        <%writeHtml(out, roleName);%>
                    </td>
                    <td width="65%">
                        <div id="div_<%=roleName%>_on" style="<%=leaveRole %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <input type="button" name="action"  class="inputBtn" value="Leave the Role"  onclick="return joinOrLeaveRole(<%ar.writeQuote4JS(accountId);%>,'leave_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,'');">
                        </div>
                        <div id="div_<%=roleName%>_off" style="<%=joinRole %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <input type="button" name="action"  class="inputBtn" value="Join the Role   "  onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(accountId);%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,<%ar.writeQuote4JS(roleDescription);%>);">
                        </div>
                        <div id="div_<%=roleName%>_pending" style="<%=pending %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            Request is pending...&nbsp;&nbsp;&nbsp;<input type="button" name="action"  class="inputBtn" value="Cancel Request"  onclick="return cancelRoleRequest(<%ar.writeQuote4JS(roleName); %>);">
                        </div>
                        <div id="div_<%=roleName%>_reject" style="<%=rejected %>">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            Request has been rejected.<a href="#" onclick="return showHideReasonDiv('div_<%=roleName%>_reason');">(See Reason)</a>&nbsp;&nbsp;&nbsp;<input type="button" name="action"  class="inputBtn" value="Make New Request"  onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(accountId);%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,'');"/>
                            <font color="red">
                                <div id="div_<%=roleName%>_reason" style="display: none;" >
                                    <B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Reason : </B>
                                    <div align="right" style="">
                                        <div  style="width:80%;border: red 1px dashed;height:35px;overflow-x:auto;overflow-y:scroll" title="Reason" align="left" >
                                            <I>&nbsp;<% writeHtml(out,roleRequestRecord != null? roleRequestRecord.getResponseDescription():"" ); %></I>
                                        </div>
                                    </div>
                                </div>
                            </font>
                        </div>
                    </td>
                </tr>
    <%
            }
        }
    %>
            </table>
        </div>
    <%
    }
    %>
    </div>
</div>
</div>
</div>
</body>
</html>
