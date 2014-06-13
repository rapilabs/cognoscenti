var removecallback = {
    success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    deleteRow();
                }else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
    failure: function(o) {
        alert("removecallback Error:" +o.responseText);
    }
}

function deleteRow(){
    myDataTable2.deleteRow(elRow2);
    window.location.reload();
}

var handleUndeleteAction = {

    success: function(o) {
        var respText = o.responseText;
        var json = eval('(' + respText+')');
         
        if(json.msgType == "success"){
            window.location.reload();
        }
        else if(json.msgType == "failure"){
            showErrorMessage("Error : Undeleting Document", json.msg , json.comments);
        }else{
            window.location  = "<%=ar.retPath%>t/EmailLoginForm.htm?&msg=<%=encodedLoginMsg%>&go=<%ar.writeURLData(ar.getCompleteURL());%>";
        }
    },
    failure: function(o) {
        alert("handleUndeleteAction Error:" +o.responseText);
    }
}

function getRenameForm(aid , attachmentName){
    var body = '<div class="generalArea">'+
               '<div class="generalSettings">'+
               '<form id="renameForm" action="updateAttachment.form" method="post">'+
                   '<table class="popups" width="100%">'+
                       '<tr>'+
                           '<td class="gridTableColummHeader">'+
                               '<label id="nameLbl"><B>Access Name: </B></label>'+
                           '</td>'+
                           '<td style="width:20px;"></td>'+
                           '<td class="Odd"><input type="text" class="inputGeneral" name="accessName" id="accessName" value="'+attachmentName+'" />'+
                           '</td>'+
                       '</tr>'+
                       '<tr><td style="height:10px"></td></tr>'+
                       '<tr>'+
                           '<td class="gridTableColummHeader"></td>'+
                           '<td style="width:20px;"></td>'+
                           '<td>'+
                               '<input type="button" class="inputBtn"  value="Save" onclick="save(\'renameForm\', \'accessName\', \'Access Name\')">&nbsp;'+
                               '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                           '</td>'+
                       '</tr>'+
                   '</table>'+
                   '<input type="hidden" name="aid" id="aid" value="'+aid+'">'+
                   '<input type="hidden" name="actionType" id="actionType" value="renameDoc">'+

               '</form>'+
               '</div>'+
               '</div>';

   createPanel("Rename Document",body,"530px");
}

function getPermissionForm(aid , attachmentName, permission, allowPub){
    var visibility = '';
    if(permission == '2'){
        if(allowPub == 'no'){
            visibility = '<input type="radio" name="visibility" id="visibility" value="MEM" checked="checked"/> <img src="<%=ar.retPath%>assets/images/iconMember.png" name="MEM" alt="Member" title="Member" /> (Member Only Access)';
        
        }else{
            visibility = '<input type="radio" name="visibility" id="visibility" value="PUB"/> <img src="<%=ar.retPath%>assets/images/iconPublic.png" name="PUB" alt="Public" title="Public" /> (Public Access) &nbsp;'+
                     '<input type="radio" name="visibility" id="visibility" value="MEM" checked="checked"/> <img src="<%=ar.retPath%>assets/images/iconMember.png" name="MEM" alt="Member" title="Member" /> (Member Only Access)';
                     }
    }else{
        
            visibility = '<input type="radio" name="visibility" id="visibility"  value="PUB" checked="checked"/> <img src="<%=ar.retPath%>assets/images/iconPublic.png" name="PUB" alt="Public" title="Public" />  (Public Access)&nbsp;'+
             '<input type="radio" name="visibility" id="visibility" value="MEM" /> <img src="<%=ar.retPath%>assets/images/iconMember.png" name="MEM" alt="Member" title="Member" /> (Member Only Access)';

    }
    var body = '<div class="generalArea">'+
               '<div class="generalSettings">'+
               '<form id="permissionForm" action="updateAttachment.form" method="post">'+
                   '<table class="popups" width="100%">'+
                       '<tr>'+
                           '<td class="gridTableColummHeader">'+
                               '<label id="nameLbl"><B>Document Name: </B></label>'+
                           '</td>'+
                           '<td style="width:20px;"></td>'+
                           '<td class="Odd"><B>'+
                               attachmentName+
                           '</B></td>'+
                       '</tr>'+
                       '<tr><td style="height:10px"></td></tr>'+
                       '<tr>'+
                           '<td class="gridTableColummHeader">'+
                               '<label id="nameLbl"><B>Permission: </B></label>'+
                           '</td>'+
                           '<td style="width:20px;"></td>'+
                           '<td class="Odd">'+
                               visibility+
                           '</td>'+
                       '</tr>'+
                       '<tr><td style="height:10px"></td></tr>'+
                       '<tr>'+
                           '<td class="gridTableColummHeader">'+
                           '<td style="width:20px;"></td>'+
                           '<td>'+
                               '<input type="button" class="inputBtn"  value="Save" onclick="save(\'permissionForm\', \'visibility\', \'Permission\')">&nbsp;'+
                               '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                           '</td>'+
                       '</tr>'+
                   '</table>'+
                   '<input type="hidden" name="aid" id="aid" value="'+aid+'">'+
                   '<input type="hidden" name="actionType" id="actionType" value="changePermission">'+
               '</form>'+
               '</div>'+
               '</div>';

   createPanel("Change Permission",body,"550px");
}

function getUploadRevisedDocForm(aid,attachmentName,description, version){

    var body = '<div class="generalArea">'+
            '<div class="generalSettings">'+
            '<form id="uploadRevisedDocForm" action="updateAttachment.form" method="post"  enctype="multipart/form-data" >'+
                '<table class="popups" width="600px">'+
                    '<tr>'+
                        '<td class="gridTableColummHeader">'+
                            '<label id="nameLbl"><B>Document Name: </B></label>'+
                        '</td>'+
                        '<td style="width:20px;"></td>'+
                        '<td class="Odd"><B>'+
                            attachmentName+
                        '</B></td>'+
                    '</tr>'+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader">'+
                            '<label><B>Local File Path: </B></label>'+
                        '</td>'+
                        '<td style="width:20px;"></td>'+
                        '<td class="Odd">'+
                            '<input type="file" name="fname" id="fname" value="" id="fname" />'+
                        '</td>'+
                    '</tr>'+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader" valign="top"><B>Description: </B></td>'+
                        '<td style="width:20px;"></td>'+
                        '<td class="Odd">'+
                            '<textarea name="comment_panel" id="comment_panel" rows="4" class="textAreaGeneral">'+description+'</textarea>'+
                        '</td>'+
                    '</tr>'+
                    '<tr><td style="height:20px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader"></td>'+
                        '<td style="width:20px;"></td>'+
                        '<td>'+
                            '<input type="button" class="inputBtn"  value="Upload" onclick="save(\'uploadRevisedDocForm\', \'fname\', \'Local File\')">&nbsp;'+
                            '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                        '</td>'+
                    '</tr>'+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader"></td>'+
                        '<td style="width:20px;"></td>'+
                       '<td><font color="blue"><b>Note:</b><I> There is/are '+version+' existing version(s) of this document and you are going to create version '+ (parseInt(version)+1)+'.  </I></font></td>'+
                    '</tr>'+
                '</table>'+
                '<input type="hidden" name="aid" id="aid" value="'+aid+'">'+
                '<input type="hidden" name="actionType" id="actionType" value="UploadRevisedDoc">'+
                '</form>'+
                '</div>'+
                '</div>';

    createPanel("Upload Revised Document",body,"650px");
}

function save(formId, fieldId, label){

    var fileName = document.getElementById(fieldId).value;
    if(fileName == ""){
        alert(label+" Field is mandetory.");
        document.getElementById(fieldId).focus();
        return false;
    }else{
        document.getElementById(formId).submit();
        myPanel.hide();
        return true;
    }
}

function checkVal(type){
    var val = "";

    if(type == "attachment"){
        return check("fname", "Local File");
    }else if(type == "link"){
         return (check("link_comment", "Description of Web Page") && check("taskUrl", "URL"));

    }else if(type == "email"){
         return (check("assignee", "To")
                 && check("subj", "Subject")
                 && check("instruct", "Instuctions")
                 && check("email_comment", "Description of File to Attach")
                 //&& check("pname", "Proposed Name")
                 );
    }
}