<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="EditAttachment.jsp"
%><%@page import="java.io.StringWriter"
%><%@page import="org.socialbiz.cog.AuthDummy"
%><%@page import="org.socialbiz.cog.AccessControl"
%><%@page import="org.socialbiz.cog.spring.Constant"
%><%@page import="org.socialbiz.cog.dms.RemoteLinkCombo"
%><%@page import="org.socialbiz.cog.AttachmentVersion"
%><%




    String atype = attachment.getType();
    boolean isExtra    = atype.equals("EXTRA");
    boolean isGone     = atype.equals("GONE");
    List<AttachmentVersion> vers = attachment.getVersions(ngp);
    boolean isGhost = vers.size()==0;
    boolean isModified = attachment.hasUncommittedChanges(vers);


%>
<style>
    .attentionBox {border:1px solid #f30000;padding:20px;margin:20px;background-color:#fef9d8;}
</style>

<div class="content tab01">
    <form name="attachmentForm" method="post" action="updateAttachment.form" enctype="multipart/form-data" onSubmit="return enableAllControls()">
        <input type="hidden" name="aid" value="<% writeHtml(out, aid); %>">
        <table width="100%" border="0">
            <tr><td style="height:20px"></td></tr>
            <tr>
                <td class="gridTableColummHeader" >Type:</td>
                <td style="width:20px;"></td>
                <td>
                    <input type="hidden" name="ftype" value="<%ar.writeHtml(type);%>">
                    <%
                    if (isFile) {
                        if(!attachment.getReadOnlyType().equals("on")) {
                            out.write("File");
                        }
                        else {
                            out.write("Read Only File");
                        }
                    }
                    else if (isURL) {
                       out.write("URL");
                    }
                    %>
                    &nbsp; &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('fileVersions.htm?aid=<%ar.writeHtml(attachment.getId());%>');"
                        value="List Versions" />  &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('editDetails<%ar.writeHtml(attachment.getId());%>.htm');"
                        value="Edit Details" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('docinfo<%ar.writeHtml(attachment.getId());%>.htm');"
                        value="Access Document" />
                    </td>
            </tr>
            <tr><td style="height:10px"></td></tr>
            <tr>
                <td class="gridTableColummHeader">
                    <label id="nameLbl">Access Name:</label>
                </td>
                <td style="width:20px;"></td>
                <td><input type="text" name="name" class="inputGeneral" value="<% writeHtml(out, name); %>" id="name" />
                </td>
            </tr>
            <%
            if (isURL){
            %>
            <tr><td style="height:15px"></td></tr>
            <tr>
                <td class="gridTableColummHeader"><fmt:message key="nugen.attachment.uploadattachment.URL"/></td>
                <td style="width:20px;"></td>
                <td><input type="text" class="inputGeneral" id="taskUrl" name="taskUrl" value="<%ar.writeHtml(attachment.getStorageFileName()); %>"/></td>
            </tr>
            <% }%>
            <tr><td style="height:20px"></td></tr>
            <tr>
                <td class="gridTableColummHeader" style="vertical-align:top">Description:</td>
                <td style="width:20px;"></td>
                <td>
                    <textarea name="comment" class="textAreaGeneral" rows="4"><% writeHtml(out, comment); %></textarea>
                </td>
            </tr>
            <tr><td style="height:10px"></td></tr>


            <% if (isURL) {}
               else if (isGhost) { %>
            <tr class="attentionBox">
                <td class="gridTableColummHeader" >ATTENTION:</td>
                <td style="width:20px;"></td>
                <td>
                    Document has disappeared without a trace.
                    The next time you synchronize it will be removed from the list of attachments.
                </td>
            </tr>
            <% } else if (isGone) { %>
            <tr class="attentionBox">
                <td class="gridTableColummHeader" >ATTENTION:</td>
                <td style="width:20px;"></td>
                <td>
                    <table><tr><td width="200">
                    <button type="submit" class="inputBtn" name="actionType" value="Remove">Remove</button>
                    <br/>
                    <button type="submit" class="inputBtn" name="actionType" value="RefreshWorking">Refresh from History</button>
                    </td><td>
                    Document has disappeared from the directory.  Do you want to mark it as deleted in the
                    project, or refresh from the latest backed up copy?
                    </td></tr></table>
                </td>
            </tr>
            <% } else if (isExtra) { %>
            <tr class="attentionBox">
                <td class="gridTableColummHeader" >ATTENTION:</td>
                <td style="width:20px;"></td>
                <td>
                    <table><tr><td width="100">
                    <button type="submit" class="inputBtn" name="actionType" value="Add">Add</button>
                    </td><td>
                    Document has appeared in the project folder. <br/>Do you want to add it as an attachment?
                    </td></tr></table>
                </td>
            </tr>
            <% } else if (isModified) { %>
            <tr class="attentionBox">
                <td class="gridTableColummHeader" >ATTENTION:</td>
                <td style="width:20px;"></td>
                <td>
                    <table><tr><td width="200">
                    <button type="submit" class="inputBtn" name="actionType" value="Commit">Commit Changes</button>
                    </td><td>
                    Document has been modified in the project directory.  Do you want to commit these
                    changes for safekeeping?
                    </td></tr></table>
                </td>
            </tr>
            <% } %>

            <tr><td style="height:10px"></td></tr>
            <tr>
                <td class="gridTableColummHeader" >Last Modified:</td>
                <td style="width:20px;"></td>
                <td>
                <% SectionUtil.nicePrintTime(out, mdate, ar.nowTime); %>
                &nbsp;&nbsp; by &nbsp;&nbsp;
                <% writeHtml(out, SectionUtil.cleanName(muser)); %>
                </td>
            </tr>
            <tr><td style="height:15px"></td></tr>
            <%if(isFile)
            {
            %>
            <tr>
                <td class="gridTableColummHeader" valign="top">Linked to:</td>
                <td style="width:20px;"></td>
                <td  valign="top">
                   <%
                   if(attachment.hasRemoteLink()) {

                        RemoteLinkCombo rlc = attachment.getRemoteCombo();
                        String folderId = rlc.folderId;
                        UserPage up = ar.getUserPage();
                        ConnectionSettings cSet = up.getConnectionSettingsOrNull(folderId);
                        ConnectionType cType = up.getConnectionOrNull(folderId);
                        if(cType==null){
                            %><div>Connection broken <%ar.writeHtml(rlc.rpath);%></div><%
                        }
                        else if (cSet == null) {
                            String url = cType.getFullPath(rlc.rpath);
                            %><div>Public Web: <a href="<%ar.writeHtml(url);%>"><%ar.writeHtml(url);%></a></div><%
                        }
                        else if (cSet.isDeleted()){
                            String url = cType.getFullPath(rlc.rpath);
                            %><div>Connection Deleted: <%ar.writeHtml(url);%></div><%
                        }
                        else {
                            String connectionName = cSet.getDisplayName();
                            String url = cType.getFullPath(rlc.rpath);
                            AddressListEntry ale = new AddressListEntry(rlc.userKey);
                            %><br/><br/>
                            <b><%ar.writeHtml(connectionName);%></b>&nbsp;&nbsp; by &nbsp;&nbsp;<% ale.writeLink(ar); %>
                            <br/>
                            <a href="<%ar.writeHtml(url);%>"><%ar.writeHtml(url);%></a><%
                        }
                   }else{
                       %><div>Not Linked</div><%
                   } %>
                </td>
            </tr>
            <%
            }
            %>
            <tr><td style="height:20px"></td></tr>
            <tr>
                <td class="gridTableColummHeader"  valign="top">Permission:</td>
                <td style="width:20px;"></td>
                <td  valign="top">
                <% if (attachment.getVisibility()>1) {
                       String publicNotAllowedMsg = "";
                       if("yes".equals(ngp.getAllowPublic())){
                %>
                           <input type="checkbox" name="visPublic"  value="PUB"/>
                           <img src="<%=ar.retPath %>assets/images/iconPublic.png" name="PUB" alt="Public"
                                title="Public"/ > Public Access
                <%
                       }else{
                           publicNotAllowedMsg = ar.getMessageFromPropertyFile("public.attachments.not.allowed", null);
                           ar.writeHtml(publicNotAllowedMsg);
                       }
                   } else {
                %>
                       <input type="checkbox" name="visPublic" value="PUB" checked="checked"/>
                       <img src="<%=ar.retPath %>assets/images/iconPublic.png" name="PUB" alt="Public" title="Public"/ > Public Access
                <% } %>
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="checkbox" name="visMember" value="MEM" checked="checked" disabled="disabled"/>
                <img src="<%=ar.retPath %>assets/images/iconMember.png" name="MEM" alt="Member" title="Member"/ > Member Access
                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="checkbox" name="visUpstream" value="UPS"
                       <%if(attachment.isUpstream()){%> checked="checked" <%}%>/>
                <img src="<%=ar.retPath %>assets/images/iconUpstream.png" /> Upstream Sync
                </td>
            </tr>
            <tr>
                <td class="gridTableColummHeader"  valign="top">Role Access:</td>
                <td style="width:20px;"></td>
                <td  valign="top">
                <table>
                <tr>
                <%
                int count=0;
                for (NGRole role : ngp.getAllRoles()) {
                    count++;
                    String roleName = role.getName();
                    if ("Members".equals(roleName)) {
                        continue;
                    }
                    if ("Administrators".equals(roleName)) {
                        continue;
                    }
                    %><td width="150"><input type="checkbox" name="role" value="<%
                    ar.writeHtml(roleName);
                    if (attachment.roleCanAccess(roleName)) {
                        %>" checked="checked<%
                    }
                    %>"/>  <%
                    ar.writeHtml(roleName);
                    %> &nbsp; </td><%
                    if (count%3==2) {
                        %></tr><tr><%
                    }
                }
                %></tr></table>
                </td>
            </tr>

            <tr><td style="height:20px"></td></tr>
            <tr>
                <td class="gridTableColummHeader"></td>
                <td style="width:20px;"></td>
                <td >
                    <button type="submit" class="inputBtn" name="actionType" value="Update">Update</button>&nbsp;
                    <button class="inputBtn" value="Cancel" onclick="return Cancel();"><fmt:message key='nugen.button.general.cancel'/></button>&nbsp;
                    <button type="submit" onclick="return confirmRemove();" class="inputBtn" name="actionType" value="Remove">Delete Attachment</button>
                    <input type="hidden" id="removebtn" value="no" />
                    &nbsp;&nbsp;<input type="checkbox" name="confirmdel"/> Check to confirm delete
                </td>
            </tr>
            <%
            if(isFile)
            {
            %>

            <tr><td style="height:20px"></td></tr>
            <tr>
                <td class="gridTableColummHeader">Accessible Link:</td>
                <td style="width:20px;"></td>
                <td>
                <%
                    String docLink=ar.retPath+ar.getResourceURL(ngp, "docinfo" + attachment.getId()
                          + ".htm?")+AccessControl.getAccessDocParams(ngp, attachment);
                %>
                Copy this link ( <a href="<%=docLink%>"><% writeHtml(out, name); %></a> ) for unauthenticated access to attachment
                </td>
            </tr>
            <tr><td style="height:5px"></td></tr>
            <tr>
                <td class="gridTableColummHeader">Storage Name:</td>
                <td style="width:20px;"></td>
                <td>
                <% writeHtml(out, attachment.getStorageFileName()); %>
                </td>
            </tr>
            <tr><td style="height:5px"></td></tr>
            <tr>
                <td class="gridTableColummHeader">Mime Type:</td>
                <td style="width:20px;"></td>
                <td>
                <%
                    String mimeType=MimeTypes.getMimeType(attachment.getNiceName());
                    ar.writeHtml(mimeType);
                %>
                </td>
            </tr>
            <%
            }
            %>
        </table>
    </form>
</div>
</div>
</div></div></div>

    <script>
        function confirmRemove(){
            document.getElementById("removebtn").value = "yes";
            if (document.attachmentForm.confirmdel.checked == false){
                if(confirm("Do you really want to remove this attachment?")){
                    return true;
                }else{
                    return false;
                }
            }
        }
        function enableAllControls() {
            document.attachmentForm.fname.disabled = false;
            if(document.getElementById("removebtn").value == "no"){
                if (document.attachmentForm.chgFile.checked == false){
                    var flag = check("fname", "Local File");
                    if(flag){
                        return checkVisibility();
                    }else{
                        return flag;
                    }
                }else{
                    return checkVisibility();
                }
            }
        }
        function checkVisibility(){

            var btn = valButton(document.attachmentForm.visibility);
            if (btn == null){
                alert('No Visibility selected');
                return false;
            }else{
                return true;
            }

        }
        function valButton(btn) {
            var cnt = -1;
            for (var i=btn.length-1; i > -1; i--) {
                if (btn[i].checked) {cnt = i; i = -1;}
            }
            if (cnt > -1) return btn[cnt].value;
            else return null;
        }
    </script>
