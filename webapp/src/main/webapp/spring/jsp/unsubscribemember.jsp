<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserProfile.jsp"
%><%
    throw new Exception("is this used");

    String emailadd = ar.reqParam("emailId");
    AddressListEntry ale = new AddressListEntry(emailadd);
%>
<script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/jquery.ui.js"></script>
<div >
    <div class="section_body">
        <div class="pageHeading">
            Notifications Settings for <% ar.write(emailadd);%>
        </div>

        <div class="pageSubHeading">
            Below is a list of things you are subscribed to that might cause you to receive email.
            If you wish to avoid email in the future, you can unsubscribe to any of them below.
            <%
            ar.write("  Note, you are able to access this page because you used a special link from an email message that gives you acces to this page only.");


            %>
        </div>
        <div style="height:10px;"></div>
        <div class="leafLetArea">
        <%
            String formId= "";
            int counter = 0;
            Vector<NGPageIndex> v = NGPageIndex.getProjectsUserIsPartOf(ale);
            if(v.size() > 0){
            for(NGPageIndex ngpi : v){
                NGPage ngp = ngpi.getPage();

                if (ngp != null)
                {
        %>
                <div class="leafHeading" id="leafHeading<%ar.write(String.valueOf(counter)); %>" onMouseOver="this.style.backgroundColor='#fdf9e1'"
                onMouseOut="this.style.backgroundColor='#f7f7f7'" onclick="expandCollapseLeaflets('leafContent<%ar.write(String.valueOf(counter)); %>','<%=ar.baseURL %>','leafHeading<%ar.write(String.valueOf(counter)); %>')">
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td id="leafHeading<%ar.write(String.valueOf(counter)); %>_leafContent<%ar.write(String.valueOf(counter)); %>">
                                <img src="<%=ar.baseURL %>assets/images/expandIcon.gif" name="img_leafContent<%ar.write(String.valueOf(counter)); %>" id="img_leafContent<%ar.write(String.valueOf(counter)); %>" border="0" />
                                &nbsp;&nbsp;<b>
                                <%
                                    String projectName = ngp.getFullName();
                                    if(ngp.getFullName().length() >= 100){
                                        projectName = projectName.substring(0,100)+"...";
                                    }
                                    ar.write(projectName);
                                %>
                                </b>
                                <a href="<%=ar.baseURL %>t/<%=ngp.getKey() %>/history.htm">
                                    <img height="15" width="15" alt="go to project" src="<%=ar.baseURL %>assets/images/iconGoInside.gif" />
                                </a>
                            </td>
                            <td></td>
                            <td class="leafNote"></td>
                        </tr>
                    </table>
                </div>
            <%
                formId = "notificationSettingsForm"+counter;
            %>
                <form id="<%=formId%>"
                    action="<%=ar.baseURL %>v/unsubscribemember.form" method="post">

                    <input type="hidden" id="pageId" name="pageId" value="<%ar.write(ngp.getKey()); %>">
                    <input type="hidden" id="emailId" name="emailId" value="<%ar.write(emailadd); %>">

                    <div class="leafContentArea" id="leafContent<%ar.write(String.valueOf(counter)); %>" style="display:none">
                        <div class="notificationContent">
                            <table width="100%" cellpadding="0" cellspacing="0">

                                <tr>
                                    <td class="notificationSubHeading">Stop being a player of roles</td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>
                                    <%
                                        List<NGRole> roles = ngp.getAllRoles();
                                    %>
                                        <input type="checkbox" id="stoproleplayerAll" name="stoproleplayerAll" onclick="selectAll(this,'stoproleplayer','<%=formId%>');"/>&nbsp;&nbsp;<b>All Roles</b><br />

                                        <%
                                            for(NGRole role : roles){
                                                if(role.isExpandedPlayer(ale, ngp)){
                                                    %>

                                                    <input type="checkbox" id="stoproleplayer" name="stoproleplayer" value="<%ar.write(role.getName()); %>" onclick="unSelect('stoproleplayerAll','<%=formId%>')"/>
                                                    &nbsp;&nbsp;<a href="<%=ar.baseURL %>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey() %>/EditRole.htm?roleName=<%ar.write(role.getName()); %>"><b><%ar.write(role.getName()); %></b></a><br />

                                                    <%
                                                }
                                            }
                                        %>
                                    </td>
                                </tr>
                                <tr><td style="height:10px;"></td></tr>
                                <tr>
                                    <td><input type="submit" id="savebutton" name="savebutton" class="inputBtn" value="Save"  /> <input type="button" class="inputBtn" value="Cancel" onclick="cancel();" /></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </form>
            <%
                }
                counter++;
            }
            }else{
            %>
            You are not member of any role.

            <%
            }
            %>
        </div>
    </div>
</div>
