<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameter:

    1. pageId   : This is the id of a Project and used to retrieve NGPage.
    2. rLink    : This is the url of the document

*/

    String p = ar.reqParam("pageId");
    String rlink = ar.reqParam("rLink");
%>
<%!
    String pageTitle="";
%>
<%
    UserProfile uProf = ar.getUserProfile();

    NGPage ngp = NGPageIndex.getProjectByKeyOrFail(p);

    FolderAccessHelper fdh = new FolderAccessHelper(ar);

    pageTitle = "Add Remote Attachment to "+ngp.getFullName();
    ar.assertMember("Can not attach a document to this project.");

%>


<script type="text/javascript">
   function submitWebDevURLForm(actionName){
       document.getElementById("actionType").value = actionName;
       document.getElementById("webDevURL").submit();
   }
</script>
<div>
        <div class="pageHeading">
            <fmt:message key="nugen.attachment.uploadattachment.LinkDocumentFromRepository" />
        </div>
        <div class="pageSubHeading">
            <fmt:message key="nugen.attachment.uploadattachment.LinkRepository"/>
        </div>
        <div class="generalSettings">
            <form name="webDevURL" id="webDevURL" action="webDevURL.form" method="post">
                <input type="hidden" name="action" id="actionType" value=""/>
                <input type="hidden" name="rlink" value="<%ar.writeHtml(rlink);%>"/>
                <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                <input type="hidden" name="p" value="<%ar.writeHtml(p);%>"/>
                <table border="0px solid red" class="linkWizard">
                    <tr><td style="height:40px"></td></tr>
                    <tr>
                        <td colspan="3" class="linkWizardHeading">To access the document:</td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader"></td>
                        <td style="width:20px;"></td>
                        <td><span style="font-size:14px;"><% ar.writeHtml(rlink); %></span></td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td colspan="3" class="linkWizardHeading">Do you want to:</td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader">1.</td>
                        <td style="width:20px;"></td>
                        <td>
                            <select name="folderId">
                            <%
                            for(ConnectionSettings cSet : fdh.getAvailableConnections(rlink)){
                                if(!cSet.isDeleted()){
                                    %>
                                    <option value="<% ar.writeHtml(cSet.getId());%>"><% ar.writeHtml(cSet.getDisplayName());%></option>
                                    <%
                                }
                            }
                            %>
                            </select>
                        </td>
                    </tr>
                    <tr><td style="height:5px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader"></td>
                        <td style="width:20px;"></td>
                        <td>
                            <input type="button" class="inputBtn"
                                value="<fmt:message key="nugen.button.repository.useexistingconnection" />"
                                onclick="submitWebDevURLForm('UseExistingConnection')">
                        </td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td colspan="3" class="linkWizardHeading">Or:</td>
                    </tr>
                    <tr><td style="height:15px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader">2.</td>
                        <td style="width:20px;"></td>
                        <td>
                            <input type="button" class="inputBtn"
                                value="<fmt:message key="nugen.button.repository.createnewconnection" />"
                                onclick="submitWebDevURLForm('CreateNewConnection')">
                        </td>
                    </tr>
                    <tr>
                        <td colspan="3" class="linkWizardHeading">Or:</td>
                    </tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader">3.</td>
                        <td style="width:20px;"></td>
                        <td>
                            <input type="button" class="inputBtn"
                                value="<fmt:message key="nugen.button.repository.accesspublicdocument" />"
                                onclick="submitWebDevURLForm('AccessPublicDocument')">
                        </td>
                    </tr>
                    <tr><td style="height:40px"></td></tr>
                </table>
            </form>
    </div>
</div>
</div>
</div>
</div>

