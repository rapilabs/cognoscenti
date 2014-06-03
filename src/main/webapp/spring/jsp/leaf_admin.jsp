<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%>
<%
    ar.assertLoggedIn("This VIEW only for logged in use cases");
    ar.assertMember("This VIEW only for members in use cases");

    UserProfile up = ar.getUserProfile();
    String userKey = "";
    if(up!=null){
        userKey = up.getKey();
    }

    Vector<NGPageIndex> templates = new Vector<NGPageIndex>();
    if(uProf != null){
        for(TemplateRecord tr : up.getTemplateList()){
    NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(tr.getPageKey());
    if (ngpi!=null) {
        //silently ignore templates that no longer exist
        templates.add(ngpi);
    }
        }
        NGPageIndex.sortInverseChronological(templates);
    }
    String thisPage = ar.getResourceURL(ngp,"admin.htm");
    String allTasksPage = ar.getResourceURL(ngp,"projectAllTasks.htm");

    String upstreamLink = ngp.getUpstreamLink();
%>
<script type="text/javascript" language="JavaScript">
    var isfreezed = '<%=ngp.isFrozen()%>';

    function validateFields(){
        if((document.getElementById('txtGoal') == null) || (document.getElementById('txtGoal').value == "")){
            alert('Please enter Goal');
            return false;
        }else if((document.getElementById('txtPurpose') == null) || (document.getElementById('txtPurpose').value == "")){
            alert('Please enter Purpose');
            return false;
        }else{
            return true;
        }
    }

    function updateProjectSettings(obj){
        if(confirm("Are you sure you want to change Project Settings?")){
            var allowPublic = "no";
            if(obj.checked){
                allowPublic = "yes";
            }
            var transaction = YAHOO.util.Connect.asyncRequest('POST',"updateProjectSettings.ajax?allowPublic="
                              +allowPublic+"&operation=publicPermission", updateResponse);
        }else{
            unChangedCheckBox(obj);
        }
    }
    var updateResponse ={
        success: function(o) {
            var respText = o.responseText;
            var json = eval('(' + respText+')');
            if(json.msgType == "success"){
                alert("Operation has been performed successfully.");
            }
            else{
                showErrorMessage("Result", json.msg, json.comments);
            }
        },
        failure: function(o) {
            alert("projectValidationResponse Error:" +o.responseText);
        }
    }

    function browse(){
        window.location = "<%=ar.retPath%>v/<%ar.writeHtml(userKey);%>/ListConnections.htm?pageId=<%ar.writeHtml(ngp.getKey());%>&fndDefLoctn=true";
    }

    function freezeOrUnfreezeProject(obj){
        var freezeUnfreezeProject = "unfreezeProject";
        var confirmation_msg = "This operation will unfreeze the project and user can modify the project. Are you sure you want to unfreeze this Project?";
        if(obj.checked){
            freezeUnfreezeProject = "freezeProject";
            confirmation_msg = "This operation will freeze the project and user can only view the project but can not modify. Are you sure you want to freeze this Project?";
        }
        if(confirm(confirmation_msg)){
            var transaction = YAHOO.util.Connect.asyncRequest('POST',"updateProjectSettings.ajax?operation="+freezeUnfreezeProject, updateResponse);
        }else{
            unChangedCheckBox(obj);
        }
    }

    function unChangedCheckBox(obj){
        if(obj.checked){
            obj.checked = false;
        }else{
            obj.checked = true;
        }
    }
    function checkFreezed(){
        if(isfreezed == 'false'){
            return true;
        }else{
            return openFreezeMessagePopup();
        }
    }
</script>
<%
    String thisPageAddress = ar.getResourceURL(ngp,"admin.htm");
%>
    <c:set var="adminSect"> <fmt:message key="nugen.adminSection.title"/> </c:set>
    <div class="generalArea">
        <div class="content tab01">
        <%
            if (!ar.isAdmin()) {
        %>
            <div class="generalContent">
                <fmt:message key="nugen.generatInfo.Admin.administration">
                    <fmt:param value='<%=ar.getBestUserId()%>'/>
                </fmt:message><br/>
            </div>
            <div class="generalHeading"><fmt:message key="nugen.generatInfo.PageNameCaption"/> </div>
            <div class="generalContent">
                <ul class="bulletLinks">
                <%
                    for (int i = 0; i < names.length; i++) {
                            out.write("<li>");
                            writeHtml(out, names[i]);
                            out.write("</li>\n");
                        }
                %>
                </ul>
            </div>
        <%
            }else
                {
        %>

            <div class="generalContent">
            <div style="height:20px">&nbsp;</div>
            <div class="generalHeading">Change Project's Name</div>
                <table>
                    <form action="changeProjectName.form" method="post" onsubmit="return checkFreezed();">
                        <tr>
                            <td class="gridTableColummHeader_2"><fmt:message key="nugen.generatInfo.PageNameCaption"/>:</td>
                            <td style="width:20px;"></td>
                            <td><input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
                                <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                                <input type="hidden" name="go" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                                <input type="text" class="inputGeneral" name="newName" value="<%writeHtml(out, pageFullName);%>">
                            </td>
                        </tr>
                        <tr><td style="height:5px" colspan="3"></td></tr>
                        <tr>

                            <td class="gridTableColummHeader_2"></td>
                            <td style="width:20px;"></td>
                            <td>
                                <input type="submit" value='<fmt:message key="nugen.generatInfo.Button.Caption.Admin.ChangePage"/>'
                                       name="action" class="inputBtn">
                            </td>
                        </tr>
                    </form>
                    <tr>
                        <td class="gridTableColummHeader_2"><fmt:message key="nugen.generatInfo.Admin.Page.PreviousDelete"/></td>
                        <td style="width:20px;"></td>
                        <td></td>
                    </tr>
                    <input type="hidden" name="p"
                            value="<%writeHtml(out,pageFullName);%>">
                    <input type="hidden" name="go"
                            value="<%writeHtml(out,pageAddress);%>">
                    <input type="hidden" name="encodingGuard"
                            value="%E6%9D%B1%E4%BA%AC" />
        <%
            for (int i = 1; i < names.length; i++) {
                String delLink = ar.retPath+"t/"+ngp.getSite().getKey()+"/"+ngp.getKey()
                    + "/deletePreviousProjectName.htm?action=delName&p="
                    + URLEncoder.encode(pageFullName, "UTF-8")
                    + "&oldName="
                    + URLEncoder.encode(names[i], "UTF-8");
                out.write("<tr><td></td><td></td><td>");
                writeHtml(out, names[i]);
                out.write(" &nbsp; <a href=\"");
                if(ngp.isFrozen()){
                    out.write("#\" onclick=\"javascript:openFreezeMessagePopup();\" ");
                }else{
                    writeHtml(out, delLink);
                }
                out.write("\" title=\"delete this name from project\"><img src=\"");
                out.write(ar.retPath);
                out.write("/assets/iconDelete.gif\"></a></td></tr>\n");
                out.write("</td></tr>\n");
            }
        %>
                </table>
            </div>
            <div class="generalContent">
                <div class="generalHeading paddingTop">Project Settings</div>
                <table width="720px">
            <%
            ProcessRecord process = ngp.getProcess();

            String goal = process.getSynopsis();
            String purpose = process.getDescription();
            %>
                    <form action="changeProjectSettings.form" method="post" >
                        <input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
                        <input type="hidden" name="go" value="<%ar.writeHtml(thisPageAddress);%>">
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Goal:</td>
                            <td style="width:20px;"></td>
                            <td><input type="text" name="goal" id="txtGoal" class="inputGeneral"
                                value="<%ar.writeHtml(goal);%>"></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2" valign="top">Purpose:</td>
                            <td style="width:20px;"></td>
                            <td><textarea name="purpose" id="txtPurpose" class="textAreaGeneral"
                                  rows="4"><%ar.writeHtml(purpose);%></textarea></td>
                        </tr>
                        <tr><td style="height:8px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2" valign="top">Project Mode:</td>
                            <td style="width:20px;"></td>
                            <td  valign="top">

                                <input type="radio" id="normalMode" name="projectMode" value="normalMode"
                                <% if(!ngp.isDeleted() && !ngp.isFrozen()){ %>
                                    checked="checked"
                                 <%} %>
                                 /> Normal &nbsp;&nbsp;<br/>

                                <input type="radio" id="freezedMode" name="projectMode" value="freezedMode"
                                <% if(ngp.isFrozen()){ %>
                                    checked="checked"
                                 <%} %>
                                 /> Frozen &nbsp;&nbsp;<br/>

                                <input type="radio" id="deletedMode" name="projectMode" value="deletedMode"
                                <% if(ngp.isDeleted()){ %>
                                    checked="checked"
                                 <%} %>
                                 /> Deleted &nbsp;&nbsp;
                            </td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Allow Public:</td>
                            <td style="width:20px;"></td>
                            <td>
                                <%
                                    String checkedStr = "" ;
                                    if (ngp.getAllowPublic().equals("yes")) {
                                        checkedStr = "checked=\"checked\"" ;
                                    }
                                %>
                                <input type="checkbox" name="allowPublic" id="allowPublic" value="yes"
                                <%ar.writeHtml(checkedStr);%>  />
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Project Email id:</td>
                            <td style="width:20px;"></td>
                            <td>
                                <input type="text" class="inputGeneral" style="width: 250px" id="projectMailId"
                                       name="projectMailId" value="<% ar.writeHtml(ngp.getProjectMailId()); %>" />
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Upstream Link:</td>
                            <td style="width:20px;"></td>
                            <td>
                                <input type="text" class="inputGeneral" style="width: 250px" id="upstream"
                                       name="upstream" value="<% ar.writeHtml(ngp.getUpstreamLink()); %>" />
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Default Location:</td>
                            <td  style="width:20px;"></td>
                            <td>
                                <input type="button" class="inputBtn" name="action" value="Browse" onclick="browse()">
                            </td>
                        </tr>
<% if (defaultRemoteFolder!=null) { %>
                        <input type="hidden" name="symbol" value="<%ar.writeHtml(defaultRemoteFolder.getSymbol());%>"/>
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Connection Owner:</td>
                            <td style="width:20px;"></td>
                            <td><%ar.write(defUserName);%></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Connection Name:</td>
                            <td style="width:20px;"></td>
                            <td><%ar.write(defConnectionName);%></td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader_2">Path:</td>
                            <td style="width:20px;"></td>
                            <td><%ar.write(defLocation);%></td>
                        </tr>
<%} else { %>
                        <tr>
                            <td class="gridTableColummHeader_2"></td>
                            <td style="width:20px;"></td>
                            <td><i>No default location set.</i></td>
                        </tr>
<%} %>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader_2"></td>
                            <td style="width:20px;"></td>
                            <td>
                                <input type="submit" value="Update" class="inputBtn" />
                            </td>
                        </tr>
                        <tr><td style="height:10px" colspan="3"></td></tr>
                    </form>
                </table>
            </div>


            <div class="generalContent">
                <div class="generalHeading paddingTop">Copy From Template</div>
                <table width="720px">
                  <form action="<%=ar.retPath%>CopyFromTemplate.jsp" method="post">
                  <input type="hidden" name="go" value="<%ar.writeHtml(allTasksPage);%>">
                  <input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
                    <tr>
                        <td class="gridTableColummHeader_2">Template:</td>
                        <td style="width:20px;"></td>
                        <td><select name="template">
                        <%
                            for (NGPageIndex temp : templates) {
                            %>
                            <option name="template" value="<%ar.writeHtml(temp.containerKey);%>"><%
                            ar.writeHtml(temp.containerName);
                            %></option>
                            <%
                            }
                        %>
                        </select></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2"></td>
                        <td style="width:20px;"></td>
                        <td> <input type="submit" value="Copy From Template" class="inputBtn"> </td>
                    </tr>
                  </form>
                </table>
            </div>

            <%
        }
        %>
        </div>
    </div>
</div>
