<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%
    AuthRequest ud_ar = AuthRequest.getOrCreate(request, response, out);
    ud_ar.assertLoggedIn("You need to Login to Upload revised version an attachment.");
    String pageId = ud_ar.reqParam("pageId");
    String aid = ud_ar.reqParam("aid");
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);

    AttachmentRecord attachment = ngp.findAttachmentByIDOrFail(aid);

    UserProfile editorProfile = null;
    String editUser = attachment.getEditModeUser();
    if((editUser!=null) && (editUser.length()>0)){
        editorProfile = UserManager.getUserProfileByKey(editUser);
    }

    UserProfile loggedInUser = ud_ar.getUserProfile();

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <script type="text/javascript" language="javascript" src="<%=ud_ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
        <link href="<%=ud_ar.baseURL%>css/body.css" rel="styleSheet" type="text/css" media="screen" />
    </head>
    <body class="yui-skin-sam">
        <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
        <div>
            <div class="pageHeading">Upload revised version of an attachment </div>
            <div class="pageSubHeading">
                Use this form to upload a revised document to the Project "<%=ngp.getFullName() %>"
            </div>
            <%if(ngp.isFrozen()){ %>
            <div id="loginArea">
                <span class="black">
                    <fmt:message key="nugen.project.freezed.msg" />
                </span>
            </div>
            <%}else{ %>
            <div>
            <%
                if(ud_ar.isLoggedIn())
                {
                    boolean isEditorUser = false;
                    if((editUser!=null) || (editUser.length()>0))
                    {
                        if(loggedInUser!=null)
                        {
                            if(loggedInUser.getKey().equals(editUser))
                            {
                                isEditorUser = true;
                            }
                        }
                    }
                    if((attachment.isInEditMode()) && (isEditorUser))
                    {
                    %>
                    <div id="stopMaintainingDiv" style="margin-left:20px; margin-top:10px; padding:10px;">
                        You are maintaining this document from <%=SectionUtil.getNicePrintDate(attachment.getEditModeDate()) %>
                        </br> </br>
                        <input type="checkbox" name="stopMaintaining" id="stopMaintaining"
                               onclick="stopMaintaining(<%ar.writeQuote4JS(attachment.getId());%>,<%ar.writeQuote4JS(ngp.getKey()); %>)" /> Stop maintaining this document
                    </div>
                    <%
                    }else if((attachment.isInEditMode()) && (!isEditorUser))
                    {%>
                    <div style="margin-left:20px; margin-top:10px; padding:10px;color:red;">
                        User <%if(editorProfile!=null){ editorProfile.writeLink(ar); }%> is maintaining this document from <%=SectionUtil.getNicePrintDate(attachment.getEditModeDate()) %>. If you upload a revised version of this document, then your data might be lost
                    </div>
                    <%}
                }
                %>
            </div>
            <div id="gwt_upload_revised_document"></div>
            <%}
            %>
        </div>
    </body>
</html>

<noscript>
      <div style="width: 22em; position: absolute; left: 50%; margin-left: -11em; color: red; background-color: white; border: 1px solid red; padding: 4px; font-family: sans-serif">
        Your web browser must have JavaScript enabled
        in order for this application to display correctly.
      </div>
</noscript>

<script>
    var isEditingDoc = false;

    function stopMaintaining(aid,pageId){
        var stopMaintain = document.getElementById("stopMaintaining").checked;
        if(stopMaintain){
            isEditingDoc = false;
        }
        var transaction = YAHOO.util.Connect.asyncRequest('POST', "<%=ar.baseURL%>t/setEditMode.ajax?pageId="+pageId+"&aid="+aid+"&editing="+isEditingDoc, getResponse);
    }

    var getResponse ={
        success: function(o) {
            var respText = o.responseText;
            var json = eval('(' + respText+')');
            if(json.msgType == "success"){
                window.location.reload();

                if(document.getElementById("stopMaintainingDiv")!=null){
                    document.getElementById("stopMaintainingDiv").style.display = 'none';
                }
            }else {
                showErrorMessage("Unable to Perform Action", json.msg , json.comments);
            }
        },
        failure: function(o) {
            alert("Error in setEditMode.ajax: "+o.responseText);
        }
    }
</script>
