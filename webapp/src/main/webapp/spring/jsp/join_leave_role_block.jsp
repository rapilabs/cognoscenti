<%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%>
<%
    String roleName=role.getName();
    String roleDescription = role.getDescription();
    String roleEligibilty = role.getRequirements();
    boolean isPlayer = role.isExpandedPlayer(up, ngp);

    String leaveRole = "display: block;";
    String joinRole = "display: none;";
    String pending =  "display: none;";
    String rejected =  "display: none;";
    roleRequestRecord = ngp.getRoleRequestRecord(roleName,roleMember);
    String requestDescription = "";
    String responseDescription = "";
    String roleRequestState = "";
    if(roleRequestRecord != null){
        roleRequestState = roleRequestRecord.getState();
        requestDescription = roleRequestRecord.getRequestDescription();
        responseDescription = roleRequestRecord.getResponseDescription();
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
    <%@page import="org.socialbiz.cog.AddressListEntry"%>
<%@page import="org.socialbiz.cog.NGBook"%>
<tr><td style="height:10px;"></td></tr>
<tr>
    <% if(isPersonalTab){ %>
        <td valign="top" width="60%">
            <div class="pageRedHeading2"><%ar.writeHtml(roleName);%>:</div>
            <%ar.writeHtml(roleDescription);%><br><br>
            <b>Eligibility:</b><br>
            <%ar.writeHtml(roleEligibilty);%>
        </td>
        <td width="30px" style="text-align:center"><img src="<%=ar.retPath %>/assets/verticalSeperator.gif" alt="" /></td>
    <%} %>

        <td>
            <div id="div_<%ar.writeHtml(roleName);%>_on" style="<%ar.writeHtml(leaveRole); %>">
                <input type="button" name="action" class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.leaverole'/>" onclick="return leaveRole(<%ar.writeQuote4JS(ngp.getKey());%>,'leave_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,<% ar.writeQuote4JS(String.valueOf(ngp.isFrozen())); %>)">
            </div>
            <div id="div_<%ar.writeHtml(roleName);%>_off" style="<%ar.writeHtml(joinRole); %>">
                <% if(isPersonalTab){ %>
                    <%
                        NGRole adminRole = ngp.getSecondaryRole();
                                NGRole executiveRole = ngp.getSite().getRole("Executives");

                                if(adminRole.isPlayer(ar.getUserProfile())
                                        ||("Members".equals(roleName) && executiveRole.isPlayer(ar.getUserProfile()))){
                    %>
                        <input type="button" name="action" class="inputBtn"
                        value="<fmt:message key='nugen.button.projectsetting.requestrole'/>"
                        onclick="return joinOrLeaveRole(<%ar.writeQuote4JS(ngp.getKey());%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName );%>,<%ar.writeQuote4JS(roleDescription);%>);">
                    <%
                    }else{
                    %>
                        <input type="button" name="action" class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.requestrole'/>" onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(ngp.getKey());%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName );%>,<%ar.writeQuote4JS(roleDescription);%>);">
                    <%
                    }
                    %>



                <%}else{%>
                Click to &nbsp; <input type="button" name="action" class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.joinproject'/>" onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(ngp.getKey());%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,<%ar.writeQuote4JS(roleDescription);%>);">
                &nbsp; or you can go in &nbsp;<B>Project Settings > Personal </B> tab and request to join &nbsp;<B>'Member'</B> role.
                <%} %>
            </div>
            <div id="div_<%ar.writeHtml(roleName);%>_pending" style="<%ar.writeHtml(pending); %>">
                <% if(isPersonalTab){ %>
                Your request is pending...<br><br><input type="button" name="action"  class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.cancelrequest'/>" onclick="return cancelRoleRequest(<%ar.writeQuote4JS(roleName );%>);">
                <%}else{%>
                <I>*Your request to <B>Join Project</B> is pending...</I>
                <%} %>
            </div>
            <div id="div_<%ar.writeHtml(roleName);%>_reject" style="<%ar.writeHtml(rejected); %>">
                <% if(isPersonalTab){ %>
                Your request has been rejected.<br/><br>
                <div id="div_<%ar.writeHtml(roleName);%>_reason">
                    <B>Reason of Rejection:</B><br>
                    <% if(roleRequestRecord != null ){
                        ar.writeHtml(roleRequestRecord.getResponseDescription());
                    }%>
                </div>
                <br>
                <input type="button" name="action" class="inputBtn" value="Make New Request" onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(ngp.getKey());%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,<%ar.writeQuote4JS(roleDescription);%>);"/>
                <%}else{%>
                <I>*Your request to <B>Join Project</B> has been rejected.<a href="#" onclick="return showHideReasonDiv('div_Members_reason');"> See Reason...</a>&nbsp;&nbsp;&nbsp;<input type="button" name="action"  class="inputBtn" value="Make New Request" onclick="return openJoinOrLeaveRoleForm(<%ar.writeQuote4JS(ngp.getKey());%>,'join_role','<%=ar.retPath %>',<%ar.writeQuote4JS(roleName); %>,<%ar.writeQuote4JS(roleDescription);%>);"/>
                </I>
                <%} %>
            </div>
        </td>
        </tr>
        <% if(isPersonalTab){ %>
        <tr><td style="height:10px;"></td></tr>
        <tr><td colspan="3" class="horizontalSeperatorGray"></td></tr>
        <%} %>


<script>
 var isFrozen = "<%=ngp.isFrozen()%>";
    function openJoinOrLeaveRoleForm(pageId,action,URL,roleName,rolDescription){
        if(isFrozen == 'false' ){
          var onClickFunction ="joinOrLeaveRole('"+pageId+"','"+action+"','"+URL+"','"+roleName+"',document.getElementById('requestDescription'))";
          var body =  '<div class="generalArea">'+
                        '<div class="generalSettings">'+
                            '<table >'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader">'+
                                        '<label id="nameLbl"><B>Role Name: </B></label>'+
                                    '</td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td><B>'+
                                        roleName+
                                    '</B></td>'+
                                '</tr>'+
                                '<tr><td style="height:10px"></td></tr>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader">'+
                                        '<label id="nameLbl"><B>Role Description: </B></label>'+
                                    '</td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        rolDescription+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:20px"></td></tr>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader" valign="top"><B>Reason: </B></td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        '<textarea name="requestDescription" id="requestDescription" rows="4"></textarea>'+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:20px"></td></tr>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader"></td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td><div id="btnDivId">'+
                                        '<input type="button" class="inputBtn" value="Request to Join Role" onclick="'+onClickFunction+'">&nbsp;'+
                                        '<input type="button" class="inputBtn" value="Cancel" onclick="cancelPanel()" >'+
                                    '</div><div id="loadDivId" style="display:none">Please wait while your request is being processed...<img src="<%=ar.retPath%>loading.gif"/></div></td>'+
                                '</tr>'+

                            '</table>'+
                        '</div>'+
                        '</div>';
                        <% if(isPersonalTab){ %>
                        createPanel("Request to Join Role",body,"550px");
                        <%}else{%>
                        createPanel("Request to Join Project",body,"550px");
                        <%}%>
            }else{
                openFreezeMessagePopup();
            }
        }

        function joinOrLeaveRole(pageId,action,URL,roleName,requestDescriptionObj){
            if(isFrozen == 'false' ){
                var transaction = YAHOO.util.Connect.asyncRequest('POST', URL+"t/requestToJoinOrLeaveRole.ajax?pageId="+pageId+"&action="+action+"&roleName="+roleName+"&requestDescription="+requestDescriptionObj.value, joinOrLeaveRoleResult);
                document.getElementById("btnDivId").style.display = 'none';
                document.getElementById("loadDivId").style.display = 'block';
            }else{
                openFreezeMessagePopup();
            }
        }

        var joinOrLeaveRoleResult = {
            success: function(o) {
                    var respText = o.responseText;
                    var json = eval('(' + respText+')');
                    if(json.msgType == "success" || json.msgType == "emailfailure"){
                        if(myPanel){
                            myPanel.hide();
                        }
                        if(json.msgType == "emailfailure"){
                            showErrorMessage("Result", json.msg , json.comments );
                        }
                        var action = json.action;
                        var leave_role_div = document.getElementById("div_"+json.roleName+"_on");
                        var join_role_div = document.getElementById("div_"+json.roleName+"_off");
                        var pending_div = document.getElementById("div_"+json.roleName+"_pending");
                        var rejected_div = document.getElementById("div_"+json.roleName+"_reject");
                        rejected_div.style.display="none";
                        leave_role_div.style.display="none";
                        if(action == "join_role"){
                            join_role_div.style.display="none";
                            pending_div.style.display="block";
                            if(json.isAdminOrExecutive == 'yes'){
                                pending_div.style.display="none";
                                leave_role_div.style.display="block";
                                alert(json.previlageMsg);
                            }
                        }else{
                            pending_div.style.display="none";
                            join_role_div.style.display="block";
                        }

                    }else{
                        showErrorMessage("Result", json.msg , json.comments );
                    }

                },
            failure: function(o) {
                alert("joinOrLeaveRoleResult Error:" +o.responseText);
            }
        }

</script>
