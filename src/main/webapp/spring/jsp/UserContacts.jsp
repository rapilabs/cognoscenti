<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserProfile.jsp"
%><%

    ar.assertLoggedIn("Must be logged in to see anything about a user");

    UserProfile uProf = (UserProfile)request.getAttribute("userProfile");
    if (uProf == null) {
        throw new NGException("nugen.exception.cant.find.user",null);
    }

    UserProfile  operatingUser =ar.getUserProfile();
    if (operatingUser==null) {
        //this should never happen, and if it does it is not the users fault
        throw new ProgramLogicError("user profile setting is null.  No one appears to be logged in.");
    }

    boolean viewingSelf = uProf.getKey().equals(operatingUser.getKey());

%>
<div class="content tab02" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="uploadContactPopup" style="display: none;">
            <div class="generalArea">
                <div class="generalSettings">
                    <form id="uploadDocForm" action="uploadContacts.form" method="post"  enctype="multipart/form-data" >
                        <table>
                            <tr>
                                <td class="gridTableColummHeader">
                                    <label><B>Local File Path:</B></label>
                                </td>
                                <td style="width:20px;"></td>
                                <td>
                                    <input type="file" class="inputGeneral" name="fname" id="fname" value="" />
                                </td>
                            </tr>
                            <tr><td style="height:15px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader">
                                    <label><B>Name Column:</B></label>
                                </td>
                                <td style="width:20px;"></td>
                                <td>
                                    <input type="text" name="nameCol" class="inputGeneral" id="nameCol" value="" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td style="width:20px;"></td>
                                <td>Enter Column no which contains names</td>
                            </tr>
                            <tr><td style="height:15px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader">
                                    <label><B>Email-Id Column: </B></label>
                                </td>
                                <td style="width:20px;"></td>
                                <td>
                                    <input type="text" name="emailCol" class="inputGeneral" id="emailCol" value="" />
                                </td>
                            </tr>
                            <tr>
                                <td></td>
                                <td style="width:20px;"></td>
                                <td>Enter Column no which contains Email-Ids.</td>
                            </tr>
                            <tr><td style="height:15px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"></td>
                                <td style="width:20px;"></td>
                                <td>
                                    <input type="button" class="inputBtn"  value="Upload" onclick="save('uploadDocForm', 'fname', 'Local File')">&nbsp;
                                    <input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >
                                </td>
                            </tr>
                        </table>
                    </form>
                </div>
            </div>
        </div>
        <%if(ar.isLoggedIn() && viewingSelf){ %>
        <div class="generalArea">
            <div class="generalContent">
                <div class="pageHeading">Contacts</div>
                <div class="pageSubHeading">
                    <table cellpadding="0" cellspacing="0" width="100%"  >
                        <tr>
                            <td>You can upload contact list using excel sheet or enter address list.</td>
                            <td>
                                <div style="float:right">
                                    <a href="#" onclick="openUploadPopUp();" >
                                        <img src="<%=ar.retPath %>assets/iconUpload.png" />Upload Contacts
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
                <form id="addContactForm" name="addContactForm" action="updateUserContacts.form" method="post" >
                    <table cellpadding="0" cellspacing="0">
                        <tr><td style="height:15px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader" valign="top">Enter Email Addresses:</td>
                            <td  style="width:20px;"></td>
                            <td valign="top">
                                <textarea id="emailIds" name="emailIds" rows="4" class="textAreaGeneral" ></textarea>
                                <br />
                                Separate email addresses with a semicolon(;) a comma(,) or the enter key.
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader" valign="top"></td>
                            <td  style="width:20px;"></td>
                            <td>
                                <input type="submit" class="inputBtn"  value="Add Contacts" onclick="return validateAndSubmit();">
                                <input type="hidden" id="op" name="op" value="Add"/>
                            </td>
                        </tr>
                        <tr><td style="height:10px"></td></tr>
                    </table>
                </form>
                <table cellpadding="0" cellspacing="0" width="100%" border="0">
                    <tr>
                        <td width="48%" valign="top">
                            <form id="contactForm" name="contactForm" action="updateUserContacts.form" method="post" >
                                <table cellpadding="0" cellspacing="0" width="100%" class="gridTable2" id="contactTable" border="0">
                                    <tr class="gridTableHeader">
                                        <td><b>Preferred Contact List</b></td>
                                        <td style="text-align:right; border-left:0px solid #ccc"></td>
                                        <td style="text-align:right; border-left:0px solid #ccc"></td>
                                    </tr>
                                    <%
                                    List <AddressListEntry> existingContacts = ar.getUserPage().getExistingContacts();
                                    for (AddressListEntry ale : existingContacts)
                                    {
                                     %>
                                    <tr>
                                        <td colspan="2">
                                        <%
                                        String id = ale.getUniversalId();
                                        ale.writeLink(ar);
                                        %>
                                        </td>
                                        <td>
                                            <span onclick="javascript:removeRole(<% ar.writeQuote4JS(id); %>, this,<%ar.writeQuote4JS(ar.getCompleteURL()); %>);">
                                                <a href="javascript:">
                                                       <img src="<%=ar.retPath%>assets/iconDelete.gif" border="0" alt="Delete" />
                                                </a>
                                            </span>
                                            <input type="hidden" id="op" name="op" value="Remove"/>
                                        </td>
                                    </tr>
                                     <%
                                     }
                                     %>
                                </table>
                                <input type="hidden" id="emailIds" name="emailIds" value=""/>
                            </form>
                        </td>
                        <td width="10px"></td>
                        <td valign="top" align="left">
                            <form id="peopleKnowForm" name="peopleKnowForm" action="updateUserContacts.form" method="post">
                                <table cellpadding="0" cellspacing="0" width="100%" border="0">
                                    <tr class="gridTableHeader">
                                        <td style="padding-left:5px;height:30px;width:150px;"><b>People you may know</b></td>
                                        <td>
                                            <input type="text" class="inputGeneralSmall" onkeyup="fillBelowList(this);" >
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                        <div style="height:300px;overflow:auto;" id="peopleYouMayKnowDiv" >
                                            <table cellpadding="0" cellspacing="0" width="96%" class="gridTable2" id="peopleKnowTable" >
                                            <%
                                            List<AddressListEntry> list = ar.getUserPage().getPeopleYouMayKnowList();
                                            for (AddressListEntry ale : list) {
                                                String universalId = ale.getUniversalId();
                                                UserProfile responsible = ale.getUserProfile();
                                                String srcOfPhoto = ar.retPath+"assets/photoThumbnail.gif";
                                                String link = "";
                                                String displayname = ale.getName();
                                                if(responsible != null){
                                                    StringWriter owner = new StringWriter();
                                                    AuthRequest clone = new AuthDummy(ar.getUserProfile(), owner);
                                                    ale.writeLink(clone);
                                                    link = owner.toString();
                                                    if(responsible.getImage().length() > 0){
                                                        srcOfPhoto = ar.retPath+"users/"+responsible.getImage();
                                                    }
                                                }else{
                                                    link = "<a href=\"javascript:\" onclick=\"javascript:editDetail("+ar.getQuote4JS(universalId)+", "+ar.getQuote4JS(displayname)+",this,"+ar.getQuote4JS(ar.getCompleteURL())+");\"><div>"+displayname+"&nbsp;&nbsp;(&nbsp;"+universalId+"&nbsp;)</div></a>";
                                                }
                                            %>
                                                <tr>
                                                    <td width="10%" class="projectStreamIcons">
                                                        <a href="#">
                                                            <img src="<%=srcOfPhoto%>" alt="" width="30" height="30" />
                                                        </a>
                                                    </td>
                                                    <td width="85%">
                                                    <% ale.writeLink(ar);%>
                                                    </td>
                                                    <td>
                                                         <span onclick='javascript:addPlayer(<% ar.writeQuote4JS(universalId); %>, this, <%ar.writeQuote4JS(link); %>,<%ar.writeQuote4JS(ar.getCompleteURL()); %>);'>
                                                             <a href="javascript:"><img src="<%=ar.retPath%>assets/iconBluePlus.gif" border="0" alt="Add" /></a>
                                                         </span>
                                                    </td>
                                                </tr>
                                            <%
                                            }
                                            %>
                                            </table>
                                        </div>
                                        </td>
                                    </tr>
                                </table>
                                <input type="hidden" id="op" name="op" value="Add"/>
                                <input type="hidden" id="emailIds" name="emailIds" value="" />
                            </form>
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <%} %>
    </div>
</div>
<script type="text/javascript">
        function validateFileExtension(fld) {
            if(!/(\.bmp|\.gif|\.jpg|\.jpeg)$/i.test(fld.value)) {
                alert("Invalid image file type.");
                fld.form.reset();
                fld.focus();
                return false;
            }
            return true;
        }

        var relPath = '<%=ar.retPath%>';
        function openUploadPopUp(){
            var body = document.getElementById("uploadContactPopup").innerHTML;
            createPanel("Upload Contacts File",body,"640px");
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

        function confirmRemoval(id){
            return confirm("Do you really want to remove this User '"+id+"' from Role: 'Contacts'?")
        }

        function validateEmail(field) {
            var regex=/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i;
            return (regex.test(field)) ? true : false;
        }



        function validateAndSubmit(){
            var field = document.forms["addContactForm"].emailIds;
            if(validateDelimEmails(field)){
                document.forms["addContactForm"].submit();
            }else{
                return false;
            }
        }

        var ele;
        var addedId;
        var link;
        var goto;
        function addPlayer(id,obj, linkStr,go){
            ele = obj;
            addedId = id;
            link = linkStr;
            goto = go;
            var transaction = YAHOO.util.Connect.asyncRequest('POST','<%=ar.retPath%>t/updateContacts.ajax?op=Add&emailIds='+id+"&go="+go, updateContactResult);
        }

        function removeRole(id, obj,go){
            ele = obj;
            if(confirmRemoval(id)){
               var transaction = YAHOO.util.Connect.asyncRequest('POST','<%=ar.retPath%>t/updateContacts.ajax?op=Remove&emailIds='+id+"&go="+go, updateContactResult);
            }
        }
        var updateContactResult = {
            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    if(json.action == 'Add'){
                        addRow('contactTable',json);
                    }else if(json.action == 'Remove'){
                        deleteRow('contactTable');
                        refreshPeopleYouMayKnowTable(json);
                    }
                }else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
            failure: function(o) {
                alert("requestResult Error:" +o.responseText);
            }
        }

        function addRow(tableID,jsonparam) {

            var peopleKnowTable = document.getElementById('peopleKnowTable');
            var oRow = ele.parentNode.parentNode;

            peopleKnowTable.deleteRow(oRow.rowIndex);

            var table = document.getElementById(tableID);

            var rowCount = table.rows.length;
            var row = table.insertRow(rowCount);

            var cell1 = row.insertCell(0);
            cell1.innerHTML = '<div>'+link+'</div>';

            var cell2 = row.insertCell(1);
            cell2.innerHTML = '&nbsp;';
            var cell3 = row.insertCell(2);
            cell3.innerHTML = '<span onclick="javascript:removeRole(\''+addedId+'\', this,\''+goto+'\');">'+
                               '<a href="javascript:">'+
                               '<img src="<%=ar.retPath%>assets/iconDelete.gif" border="0" alt="Delete" />'+
                               '</a>'+
                               '</span>';

        }

        function deleteRow(tableID) {
            try {

                var table = document.getElementById(tableID);
                var oRow = ele.parentNode.parentNode;
                table.deleteRow(oRow.rowIndex);
            }catch(e) {
                alert(e);
            }
        }
        function refreshPeopleYouMayKnowTable( jsonParam){

            var tableInnerHtml= '<table cellpadding="0" cellspacing="0" width="100%" class="gridTable2" id="peopleKnowTable" >';

            for(i=0; i<jsonParam.datatable.length; i++){
                var rowVal = jsonParam.datatable[i];
                rowVal = eval('(' + rowVal+')');
                var srcOfPhoto = rowVal.srcOfPhoto;
                var name = rowVal.username;
                var profilelink = rowVal.profilelink;
                var profilelinkwithquote = rowVal.profilelinkwithquote;
                var id = rowVal.userid;
                if(profilelink == ''){
                    profilelink = name;
                }

                var addplayer = " onclick='javascript:addPlayer(\""+id+"\", this,"+profilelinkwithquote+",\""+rowVal.go+"\")'";
                tableInnerHtml +=   '<tr>'+
                                    '<td width="10%" class="projectStreamIcons"><a href="#"><img src="'+relPath+srcOfPhoto+'" alt="" width="30" height="30" /></a></td>'+
                                    '<td width="85%">'+
                                        profilelink+
                                     '</td>'+
                                     '<td>'+
                                       '<span '+addplayer+'>'+
                                           '<a href="javascript:">'+
                                             '<img src="'+relPath+'assets/iconBluePlus.gif" width="12" height="15" border="0" alt="Add" />'+
                                           '</a>'+
                                       '</span>'+
                                     '</td>'+
                                     '</tr>';


            }
            tableInnerHtml += '</table>';
            var container = document.getElementById("peopleYouMayKnowDiv");
            container.innerHTML = tableInnerHtml;
        }



        function fillBelowList(searchStr){
            var searchStr = searchStr.value;
            var transaction = YAHOO.util.Connect.asyncRequest('POST','<%=ar.retPath%>t/getPeopleYouMayKnowList.ajax?go=<%ar.writeURLData(ar.getCompleteURL());%>&searchStr='+searchStr, fillBelowListResult);
        }
        var fillBelowListResult = {
            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    refreshPeopleYouMayKnowTable(json);
                }else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
            failure: function(o) {
                alert("requestResult Error:" +o.responseText);
            }
        }
</script>
