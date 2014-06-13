<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="java.net.URLDecoder"
%><%@page import="org.socialbiz.cog.AttachmentVersion"
%><%/*
Required parameters:

    1. pageId : This is the id of an project and here it is used to retrieve NGPage (Project's Details).
    2. aid : This is document/attachment id which is used to get information of the attachment being downloaded.

*/

    String pageId   = ar.reqParam("pageId");
    String aid      = ar.reqParam("aid");
    String version  = ar.defParam("version", null);%><%!String pageTitle = "";%><%response.setCharacterEncoding("UTF-8"); // Otherwise platform default encoding will be used to write the characters.
    response.setContentType("text/plain; charset=UTF-8");

    UserProfile uProf = ar.getUserProfile();

    NGPage ngp =NGPageIndex.getProjectByKeyOrFail(pageId);
    pageId = ngp.getKey();
    NGBook account = ngp.getSite();

    AttachmentRecord attachment = ngp.findAttachmentByIDOrFail(aid);
    long fileSize = attachment.getFileSize(ngp);

    boolean canAccessDoc = AccessControl.canAccessDoc(ar, ngp, attachment);


    String access = "Member Only";
    if (attachment.getVisibility()<=1)
    {
        access = "Public";
    }

    String accessName = attachment.getNiceName();
    String relativeLink = "a/"+accessName+"?version="+attachment.getVersion();
    String permaLink = ar.getResourceURL(ngp, relativeLink);
    if("URL".equals(attachment.getType())){
        permaLink = attachment.getStorageFileName();
    }

    UserProfile editorProfile = null;
    String editUser = attachment.getEditModeUser();
    if((editUser!=null) && (editUser.length()>0)){
        editorProfile = UserManager.getUserProfileByKey(editUser);
    }

    AddressListEntry ale = new AddressListEntry(attachment.getModifiedBy());

    pageTitle = ngp.getFullName() + " / "+ attachment.getNiceNameTruncated(48);%>
<%@page import="org.socialbiz.cog.AccessControl"%>
<script type="text/javascript"
    src="<%=ar.retPath%>jscript/attachment.js"></script>
<body class="yui-skin-sam">
    <div class="pageHeading">Access Document</div>
    <div class="pageSubHeading">You can view the document details and also download it from here.</div>
    <div class="generalSettings">
        <table border="0px solid red" width="800">
            <tr>
                <td colspan="3">
                    <table>
                        <tr>
                            <td class="gridTableColummHeader">
                                <%if("FILE".equals(attachment.getType())){
                                %> Document Name:
                                <%}else if("URL".equals(attachment.getType())){
                                %> Link Name:
                                <%} %>
                            </td>
                            <td style="width: 20px;"></td>
                            <td><b>
                                <% ar.writeHtml(attachment.getNiceName()); %>
                                </b> <%if(attachment.isDeleted()) {%> &nbsp;&nbsp;<img
                                src="<%=ar.retPath %>deletedLink.gif"> <font color="red">(DELETED)</font>
                                <%} %>
                            </td>
                            <td style="width:50px;"></td>
                            <td rowspan="9" style="width:215px;height:150px" valign="top">
                              <%
                            if("FILE".equals(attachment.getType()))
                            {
                                if(ar.isLoggedIn())
                                {
                                    boolean isEditorUser = false;
                                    if((editUser!=null) || (editUser.length()>0))
                                    {
                                        if(uProf!=null)
                                        {
                                            if(uProf.getKey().equals(editUser))
                                            {
                                                isEditorUser = true;
                                            }
                                        }
                                    }
                                    if(!attachment.isInEditMode())
                                    {
                            %>
                                <div class="alertMessageArea">
                                    <b>Responsibility:</b><br>
                                    <span class="alertMessageGreen">Nobody is maintaining this document</span><br><br>
                                    <input type="button" name="editingDoc" id="editingDoc"
                                        value="<fmt:message key="nugen.attachment.uploadattachment.button.maintainDoc"/>" class="inputBtn"
                                        onclick="maintainDoc(<%ar.writeQuote4JS(attachment.getId());%>,<%ar.writeQuote4JS(ngp.getKey()); %>,<%ar.writeQuote4JS("editingDoc"); %>)" />
                                </div>
                            <%      }else if((attachment.isInEditMode()) && (isEditorUser))
                                    {
                            %>
                                <div class="alertMessageArea">
                                    <b>Responsibility:</b><br>
                                    <span class="alertMessageYellow">You are maintaining this document from <%=SectionUtil.getNicePrintDate(attachment.getEditModeDate()) %></span><br><br>
                                    <input type="button" name="stopMaintaining" id="stopMaintaining"
                                        class="inputBtn" value="<fmt:message key="nugen.attachment.uploadattachment.button.stopMaintain"/>"
                                        onclick="stopMaintaining(<%ar.writeQuote4JS(attachment.getId());%>,<%ar.writeQuote4JS(ngp.getKey()); %>)" />
                                </div>
                            <%
                                    }else
                                    {
                            %>
                                <div class="alertMessageArea">
                                    <b>Responsibility:</b><br>
                                    <span class="alertMessageYellow">User
                                        <%
                                        if(editorProfile!=null){
                                            editorProfile.writeLink(ar);
                                        }%>
                                        is maintaining this document from <%=SectionUtil.getNicePrintDate(attachment.getEditModeDate()) %></span><br><br>
                                    <input type="button" name="takePrivilege" id="takePrivilege"
                                        value="<fmt:message key="nugen.attachment.uploadattachment.button.maintainDoc"/>" class="inputBtn"
                                        onclick="maintainDoc(<%ar.writeQuote4JS(attachment.getId());%>,<%ar.writeQuote4JS(ngp.getKey()); %>,<%ar.writeQuote4JS("takePrivilege"); %>)" />
                                </div>
                            <%      }
                                }
                            }
                            %>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 5px"></td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader">Description:</td>
                            <td style="width: 20px;"></td>
                            <td>
                            <% writeHtml(out, attachment.getComment()); %>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 5px"></td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader">
                            <%if("FILE".equals(attachment.getType())){ %> Uploaded by: <%}else if("URL".equals(attachment.getType())){ %>
                            Attached by <%} %>
                            </td>
                            <td style="width: 20px;"></td>
                            <td>
                            <% ale.writeLink(ar); %> on <% SectionUtil.nicePrintTime(ar, attachment.getModifiedDate(), ar.nowTime); %>
                            </td>
                        </tr>
                        <tr>
                            <td style="height: 5px"></td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader">Accessibility:</td>
                            <td style="width: 20px;"></td>
                            <%if(!attachment.getReadOnlyType().equals("on")){ %>
                            <td>
                            <% ar.writeHtml(access);%>
                            </td>
                            <%}else{ %>
                            <td>
                            <% ar.writeHtml(access);%> and Read only Type</td>
                            <%} %>
                        </tr>
                        <%if("FILE".equals(attachment.getType())){ %>
                        <tr>
                            <td style="height: 5px"></td>
                        </tr>
                        <tr>
                            <td class="gridTableColummHeader">Version:</td>
                            <td style="width: 20px;"></td>
                            <td><%=attachment.getVersion()%>
                             - Size: <%=fileSize%> bytes</td>
                        </tr>
                        <%
                        }%>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="height: 10px"></td>
            </tr>
            <tr>
                <td class="gridTableColummHeader"></td>
                <td style="width: 20px;"></td>
                <%
                    if (attachment.getVisibility() == SectionDef.PUBLIC_ACCESS || (attachment.getVisibility() == SectionDef.MEMBER_ACCESS && (ar.isLoggedIn() || canAccessDoc)))
                    {
                %>
                <td>
                <%if("FILE".equals(attachment.getType())){ %> <a
                    href="<%=ar.retPath%><%ar.writeHtml(permaLink); %>"><img
                    src="<%=ar.retPath%>download.gif" border="0"></a> <%}else if("URL".equals(attachment.getType())){ %>
                <a href="#"
                    onclick="return openWin(<%ar.writeQuote4JS(permaLink); %>);"><img
                    src="<%=ar.retPath%>assets/btnAccessLinkURL.gif" border="0"></a> <%} %>

                </td>
            </tr>
            <% if (ar.isLoggedIn() && !attachment.isDeleted() && "FILE".equals(attachment.getType()) ) { %>
            <tr>
                <td style="height: 20px"></td>
            </tr>
            <tr>
                <td class="gridTableColummHeader"></td>
                <td style="width: 20px;"></td>
                <td><input type="button" class="inputBtn"
                    onclick="return gotoSendNoteByEmail('<%=ar.retPath%>t/sendNoteByEmail.htm?p=<%ar.writeHtml(pageId);%>&oid=x&selectedAttachemnt=attach<%ar.writeHtml(attachment.getId()); %>&encodingGuard=%E6%9D%B1%E4%BA%AC'); "
                    value="Send By Email" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('uploadRevisedDocument.htm?aid=<%ar.writeHtml(attachment.getId());%>');"
                        value="Upload New Version" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('editDetails<%ar.writeHtml(attachment.getId());%>.htm');"
                        value="Edit Details" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('fileVersions.htm?aid=<%ar.writeHtml(attachment.getId());%>');"
                        value="List Versions" />
                </td>
            </tr>
                    <% }
                }
                else{
            %>
            <tr>
                <td class="gridTableColummHeader"></td>
                <td style="width: 20px;"></td>
                <td><a href="#"><img
                    src="<%=ar.retPath%>downloadInactive.gif" border="0"></a><br />
                <span class="red">* You need to log in to download this
                document.</span></td>
            </tr>
            <%
                            }
                        %>
            <tr>
                <td style="height: 10px"></td>
            </tr>
            <tr>
                <td class="gridTableColummHeader"></td>
                <td style="width: 20px;"></td>
                <td><span class="tipText">This web page is a secure and
                convenient way to send documents to others collaborating on projects.
                The email message does not carry the document, but only a link to this
                page, so that email is small. Then, from this page, you can get the
                very latest version of the document. Documents can be protected by
                access controls.</span></td>
            </tr>
        </table>
    </div>
<%@ include file="functions.jsp"%>

<script>
     var isfreezed = '<%=ngp.isFrozen() %>';
     var isReadOnly = '<%=attachment.getReadOnlyType() %>';
     var isEditingDoc = false;

    function uploadRevisedDocForm(aid,attachmentName,description, version){
        <% if(ngp.isFrozen()){ %>
            return openFreezeMessagePopup();
        <% } else if ("on".equals(attachment.getReadOnlyType())) { %>
            alert('You can not edit this document. This is read only type');
        <% } else { %>
            window.location ="<%=ar.retPath%>t/<%ar.writeHtml(ngp.getSiteKey());%>/<%ar.writeHtml(ngp.getKey());%>/uploadRevisedDocument.htm?aid="+aid;
        <% } %>
    }

    function gotoSendNoteByEmail(url){
        <% if(ngp.isFrozen()){ %>
            return openFreezeMessagePopup();
        <% } else { %>
            return openWin(url);
        <% } %>
    }
    function login(){
        window.location ="<%=ar.retPath%>t/EmailLoginForm.htm?go=<%ar.writeURLData(ar.getCompleteURL());%>";
    }
    function maintainDoc(aid,pageId,checkBoxId){
        var transaction = YAHOO.util.Connect.asyncRequest('POST', "<%=ar.baseURL%>t/setEditMode.ajax?pageId="+pageId+"&aid="+aid+"&editing=true", getResponse);
    }

    function stopMaintaining(aid,pageId){
        var transaction = YAHOO.util.Connect.asyncRequest('POST', "<%=ar.baseURL%>t/setEditMode.ajax?pageId="+pageId+"&aid="+aid+"&editing=false", getResponse);
    }

    var getResponse ={
        success: function(o) {
            var respText = o.responseText;
            var json = eval('(' + respText+')');
            if(json.msgType == "success"){
                window.location.reload();
            }else {
                showErrorMessage("Unable to Perform Action", json.msg , json.comments);
            }
        },
        failure: function(o) {
            alert("Error in setEditMode.ajax: "+o.responseText);
        }
    }



</script>
</body>
