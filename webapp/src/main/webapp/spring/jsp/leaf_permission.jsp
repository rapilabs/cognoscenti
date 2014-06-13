<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@page import="org.socialbiz.cog.spring.Constant"
%><%@page import="org.socialbiz.cog.MicroProfileMgr"
%>
<script type="text/javascript" language="javascript">

    var isfreezed = '<%=ngp.isFrozen()%>';
    var roleID ="";
    function openModalDialogue(popupId,headerContent,panelWidth,id){
        if(isfreezed == 'false'){
            roleID=id;
            var   header = headerContent+" Role "+ roleID;
            var bodyText= document.getElementById(popupId).innerHTML;
            createPanel(header, bodyText, panelWidth);
            myPanel.beforeHideEvent.subscribe(function() {
                                     if(!isConfirmPopup){
                                         window.location = "permission.htm";
                                     }
                                 });
         }else{
             openFreezeMessagePopup();
         }
    }

    var existing_player_list;

    function addPlayerInRole(popupId,headerContent,panelWidth,id, existing_players){
        existing_player_list = '';
        if(existing_players != ''){
           existing_player_list = existing_players;
        }
        openModalDialogue(popupId,headerContent,panelWidth,id);

    }
    function updateRole(op,id,formId){
        if(isfreezed == 'false'){
            var go='permission.htm';
            url='<%=ar.retPath%>t/<%ar.writeURLData(ngp.getSite().getKey());%>/<%ar.writeURLData(ngp.getKey());%>/pageRoleAction.form?r='+roleID+'&op='+op+'&go='+go +'&id='+id;

            document.getElementById(formId).action = url;
            document.getElementById(formId).submit();
        }else{
            openFreezeMessagePopup();
        }
    }

    function removeRole(op,id,roleName,formId){
        if(isfreezed == 'false'){
            var go= 'permission.htm';
            var r=confirm("Do you really want to remove this User '"+id+"' from Role: '"+ roleName +"'?");
            if(r==true){
                url='<%=ar.retPath%>t/<%ar.writeURLData(ngp.getSite().getKey());%>/<%ar.writeURLData(ngp.getKey());%>/pageRoleAction.form?r='+roleName+'&op='+op+'&go='+go +'&id='+id;

                document.getElementById(formId).action= url;
                document.getElementById(formId).submit();

            }
        }else{
            openFreezeMessagePopup();
        }
    }

    function addRoleMember(op,id,formId){

        var field = document.getElementById(id);
        if(trimme(field.value) == '' || field.value == null){
            alert("Please enter the email id of a player for this role.");
            return false;
        }
        var parsed_val = '';
        var duplicate_ids = '';
        var count = 1;
        if(validateDelimEmails(field)){
            parsed_val = field.value.replace(new RegExp("\n|," , "gi"), ";");
            var new_id_list = parsed_val.split(";");
            for(var i=0; i< new_id_list.length; i++){
                var new_id = trimme(new_id_list[i]);
                if(new_id != ''){
                    var parsed_new_id = new_id;
                    if(new_id.indexOf('<') != -1 && new_id.indexOf('>') != -1){
                        parsed_new_id = new_id.substring(new_id.indexOf('<')+1,new_id.indexOf('>'));
                    }
                    if(existing_player_list.indexOf(parsed_new_id) != -1){
                        duplicate_ids += count+'.    '+new_id+'\n';
                        count++;
                    }
                }
            }
            if(duplicate_ids != ''){
                alert("Below is list of ids which is already a player of this role.\n\n"+duplicate_ids);
                return false;
            }else{
                updateRole(op,parsed_val,formId);
            }
        }
    }

    function validateMultipleEmails(id) {
           id=id.value.replace(new RegExp(",|;" , "gi"), "\n");

           var result=new Array();
           if( id.indexOf("\n") != -1){
                result = id.split("\n");
            }
          if(result==0){
            if(!validateEmail(id)){
                alert("'"+id+ "' email id id wrong. Please provide valid Email id.");
                return false;
            }
          }

            for(var i = 0;i < result.length;i++){
                if(trimme(result[i]) != ""){
                    if(!validateEmail(trimme(result[i]))){
                        alert("'"+result[i]+ "' email id id wrong. Please provide valid Email id.");
                        return false;
                    }
                }
            }
           return true;
        }

     function validateEmail(field) {
            var regex=/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\b/i;
            return (regex.test(field)) ? true : false;
    }

</script>

<div class="content tab01">
    <div class="generalArea">
        <div class="generalContent">
            <!-- Tab Structure Starts Here -->
            <div id="dialog1" class="yui-pe-content" style="display: none;">
                <form name="addMemberForm" id="addMemberForm"  method="post">
                <table>
                    <tr><td style="height:30px"></td></tr>
                    <tr>
                        <td valign="top" class="gridTableColummHeader_3">Add Players:</td>
                        <td style="width: 20px;"></td>
                        <td>
                            <textarea type="text" rows="5" class="wickEnabled" name="rolemember" id="rolemember" onfocus="initsmartInputWindowVlaue('smartInputFloater','smartInputFloaterContent');" autocomplete="off" onkeyup="autoComplete(event,this);"></textarea>
                            <div style="position: relative; text-align: left;">
                                <table class="floater"
                                    style="position:absolute;top:0;left:0;background-color:#cecece;display:none;visibility:hidden;width:394px"
                                    id="smartInputFloater" rules="none" cellpadding="0" cellspacing="0">
                                    <tr>
                                        <td id="smartInputFloaterContent" nowrap="nowrap" width="100%"></td>
                                    </tr>
                                </table>
                            </div>
                        </td>
                    </tr>
                    <tr><td style="height:15px"></td></tr>
                    <tr>
                        <td valign="top" class="gridTableColummHeader_3"></td>
                        <td style="width: 20px;"></td>
                        <td><input type="button" class="inputBtn" onclick="addRoleMember('Add Member','rolemember','addMemberForm');" value="<fmt:message key='nugen.projectsettings.button.AddMember'/>">
                            &nbsp; &nbsp; <input type="checkbox" name="sendEmail" value="yes"> Send Email Notification</td>
                    </tr>
                    <tr><td style="height:25px"></td></tr>
                </table>
                <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                <input type="hidden" name="go" value="<%ar.writeHtml( ar.getCompleteURL());%>">
                <input type="hidden" name="role" value="M">
            </form>
         </div>
        </div>

        <div id="container" ></div>
        <div class="generalContent">
            <table width="100%">
                <tr>
                    <td class="pageHeading">
                        <fmt:message key="nugen.projectsettings.heading.Roles"/> of Project
                    </td>
                       <td></td>
                       <td align="right">
                       <img src="<%=ar.retPath%>/assets/iconBluePlus.gif" alt="" />&nbsp;<a href="#createNewRole" onclick="openModalDialogue('NewRole','Create New','630px','')" title="Create New Role">Create New Role</a></td>
                   </tr>
                   <tr><td style="height:5px;"></td></tr>
                   <tr><td colspan="3" class="horizontalSeperatorBlue"></td></tr>
            </table>
            <table width="100%">
                <%
                    writeAllRolesOnPage(ar, ngp);
                %>
            </table>
        </div>
        <br><br>
        <div class="generalSettings"><a name="inheritedRoles"></a>
            <table width="100%">
                <tr>
                    <td class="pageHeading">Roles inherited from Site '<%
                        ar.writeHtml(ngp.getSite().getFullName());
                    %>'</td>
                </tr>
                <tr><td style="height:5px;"></td></tr>
                <tr><td class="horizontalSeperatorBlue"></td></tr>
            </table>
            <table width="100%">
                <%
                   writeAllRolesFromAccount(ar, ngb,ngp);
                %>
            </table>
        </div>
        <br><br>
    <div id="NewRole" class="yui-pe-content" style="display: none;">
          <div class="generalContent">
            <form name="createRoleForm" id="createRoleForm"  action="CreateRole.form" method="post">
                <table>
                    <tr><td style="height:30px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2" style="width:150px;">Role Name:</td>
                        <td style="width:20px;"></td>
                        <td><input type="text" name="rolename" id="rolename" class="inputGeneral" /></td>
                     </tr>
                     <tr><td style="height:15px"></td></tr>
                     <tr>
                        <td class="gridTableColummHeader_2" style="width:150px;" valign="top"><fmt:message key="nugen.projectsettings.label.MessageCriteria"/>:</td>
                        <td style="width:20px;"></td>
                        <td><textarea name="description" id="description" class="textAreaGeneral" rows="4"></textarea></td>
                     </tr>
                     <tr><td style="height:15px"></td></tr>
                     <tr>
                        <td class="gridTableColummHeader_2" style="width:150px;"></td>
                        <td style="width:20px;"></td>
                        <td><input type="button" class="inputBtn" value="<fmt:message key="nugen.button.projectsetting.addrole"/>" onclick="submitRole();"></td>
                     </tr>
                     <tr><td style="height:25px"></td></tr>
                </table>
            </form>
        </div>
    <%
    out.flush();
    %>
</div>

<div id="AddExistingRole" class="yui-pe-content" style="display: none;">
  <div class="generalContent">
    <form name="updateRoleForm" id="updateRoleForm" method="post" action="pageRoleAction.form">
     <table cellpadding="0" cellspacing="0" width="100%">
            <tr><td height="30px"></td></tr>
            <tr>
                <td class="gridTableColummHeader_2" style="width:150px;"><fmt:message key="nugen.projectsettings.label.AddExistingRole"/>:</td>
                <td style="width:20px;"></td>
                <td>
                    <select class="selectGeneralSmall" name="newRoleName" id="newRoleName" onChange="selectList();">
                        <option value="" selected="selected">Select</option>
                        <%
                        if(roles!=null){
                        Iterator  iterator=roles.iterator();
                         while(iterator.hasNext()){
                             NGRole ngRole = (NGRole)iterator.next();
                             String roleNme=ngRole.getName();
                         %>
                             <option value="<%ar.writeHtml(roleNme);%>"><%ar.writeHtml(roleNme);%></option>
                       <%} }%>
                    </select>
                </td>
            </tr>
            <tr><td style="height:8px"></td></tr>
            <tr>
               <td class="gridTableColummHeader_2" style="width:150px;"></td>
               <td style="width:20px;"></td>
               <td>
                   <input type="button" class="inputBtn"  onclick="updateRole('Add Role',newRoleName.value,'updateRoleForm');" value="<fmt:message key='nugen.projectsettings.button.AddRole'/>">

               </td>
           </tr>
           <tr><td height="20px"></td></tr>
        </table>
    </form>
</div>
</div>

    <script type="text/javascript">

        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"requestId",label:"Request Id",sortable:false,resizeable:true,hidden:true},
                    {key:"roleName",label:"Role Name",sortable:false,resizeable:true},
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,resizeable:true},
                    {key:"requestedby",label:"Requested By",sortable:true,resizeable:true},
                    {key:"description",label:"Description",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"requestId"},
                            {key:"roleName"},
                            {key:"date"},
                            {key:"requestedby"},
                            {key:"description"},
                            {key:"state"}
                            ]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200
                    }),
                    initialRequest: "results=999999"

                };


                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"requestedby",dir:"date"}});

                var onContextMenuClick = function(p_sType, p_aArgs, p_myDataTable) {
                    var task = p_aArgs[1];
                  if(task) {
                        // Extract which TR element triggered the context menu

                        var elRow = this.contextEventTarget;
                        elRow = p_myDataTable.getTrEl(elRow);
                        myDataTable2=p_myDataTable;
                        elRow2=elRow;
                        var oRecord = p_myDataTable.getRecord(elRow);
                        var roleName = oRecord.getData("roleName");
                        var requestId = oRecord.getData("requestId");
                        var state = oRecord.getData("state");
                        var date = oRecord.getData("date");
                        var requestedby = oRecord.getData("requestedby");
                        var requestedDescription = oRecord.getData("description");
                        if(elRow) {
                           switch(task.index) {

                                case 0:
                                        openApprovalRejectionForm('approved',pageId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
                                        break;
                                case 1:
                                        openApprovalRejectionForm('rejected',pageId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
                                        break;
                                }
                            }
                        }
                    };


                var myContextMenu = new YAHOO.widget.ContextMenu("mycontextmenu",
                        {trigger:myDataTable.getTbodyEl()});

                 myContextMenu.addItems(
                                        [
                                        { text: "Approve Request"},
                                        { text: "Reject Request"}
                                        ]
                                       );

                // Render the ContextMenu instance to the parent container of the DataTable
                myContextMenu.render("listofpagesdiv");
                myContextMenu.clickEvent.subscribe(onContextMenuClick, myDataTable);

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });


        function openApprovalRejectionForm(action,pageId,URL,roleName,requestedby,requestId,reqDescription){
            var title = "Request Approval Form";
            var reasonLable = "Reason of Approval : ";
            var buttonLabel = "Approve";
            if(action == "rejected"){
                var title = "Request Rejection Form";
                var reasonLable = "Reason of Rejection : ";
                var buttonLabel = "Reject";
            }
            var onClickFunction ="makeRoleRequest('"+action+"','"+URL+"t/approveOrRejectRoleRequest.ajax?pageId="+pageId+"&action="+action+"&requestId="+requestId+"',document.getElementById('responseDescription'),approveOrRejectRoleRequestResult)";
            var body =  '<div class="generalArea">'+
                        '<div class="generalSettings">'+
                            '<table>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader">'+
                                        '<label id="nameLbl"><B>Role Name: </B></label>'+
                                    '</td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        roleName+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:10px"></td></tr>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader">'+
                                        '<label id="nameLbl"><B>Requested By: </B></label>'+
                                    '</td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        requestedby+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:10px"></td></tr>'+
                                '<tr>'+
                                    '<td class="gridTableColummHeader" valign="top"><B>Requestee Comment: </B></td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'
                                        +reqDescription+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:10px"></td></tr>'+
                                '<tr>'+
                                    '<td valign="top"><B>'+reasonLable+'</B></td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        '<textarea name="responseDescription" id="responseDescription" class="textAreaGeneral" rows="4"></textarea>'+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td style="height:10px"></td></tr>'+
                                '<tr>'+
                                    '<td valign="top"><B>'+reasonLable+'</B></td>'+
                                    '<td style="width:20px;"></td>'+
                                    '<td>'+
                                        '<input type="button" class="inputBtn"  value="'+buttonLabel+'" onclick="'+onClickFunction+'">&nbsp;'+
                                        '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                                    '</td>'+
                                '</tr>'+
                            '</table>'+
                        '</div>'+
                        '</div>';
            createPanel(title,body,"600px");
        }

        function trim(s) {
            var temp = s;
            return temp.replace(/^s+/,'').replace(/s+$/,'');
        }

        function makeRoleRequest(action,URL,responseDescriptionObj,resultFunction){
            if(responseDescriptionObj != null){
                if(action =="rejected" && trim(responseDescriptionObj.value) == ""){
                    alert("Please provide the reason of rejection");
                    responseDescriptionObj.focus();
                    return false;
                }else{

                    URL  = URL+"&responseDescription="+responseDescriptionObj.value
                    var transaction = YAHOO.util.Connect.asyncRequest('POST',URL,resultFunction);
                }
            }
        }

        var approveOrRejectRoleRequestResult = {
            success: function(o) {
                    var json = eval('(' + respText+')');
                    if(json.msgType == "success"){
                        window.location.reload();
                    }else{
                        showErrorMessage("Result", json.msg , json.comments );
                    }
                    myPanel.hide();
                },
            failure: function(o) {
                    alert("approveOrRejectRoleRequestResult Error:" +o.responseText);
            }
        }

        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"requestId",label:"Request Id",sortable:false,resizeable:true,hidden:true},
                    {key:"roleName",label:"Role Name",sortable:false,resizeable:true},
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,resizeable:true},
                    {key:"requestedby",label:"Requested By",sortable:true,resizeable:true},
                    {key:"requesteeComment",label:"Requestee Comment",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                    {key:"Description",label:"Description",sortable:true,resizeable:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist2"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"requestId"},
                            {key:"roleName"},
                            {key:"date"},
                            {key:"requestedby"},
                            {key:"requesteeComment"},
                            {key:"state"},
                            {key:"Description"}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200
                    }),
                    initialRequest: "results=999999"

                };


                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv2", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"requestedby",dir:"date"}});

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });
    </script>

    <%!public void writeAllRolesOnPage(AuthRequest ar, NGPage ngp) throws Exception
        {
            for (NGRole aRole : ngp.getAllRoles())
            {

                ar.write("<tr>");
                ar.write("<td valign=\"top\" class=\"columnRole\" width=\"40%\">");

                ar.write("<div class=\"pageRedHeading\"><a name=\"");
                ar.writeHtml(aRole.getName());
                ar.write("\">");
                ar.writeHtml(aRole.getName());
                ar.write("</a>");
                ar.write("</div>");



                ar.writeHtml(aRole.getDescription());
                ar.write("<br /><br />");
                ar.write("<b>Eligibility:</b><br />");
                ar.writeHtml(aRole.getRequirements());
                ar.write("<br /><br />");

                ar.write("<a href=\"");
                if(ngp.isFrozen()){
                    ar.write("#\" onclick=\"javascript:openFreezeMessagePopup();\" ");
                }else{
                    ar.write(ar.retPath);
                    ar.write("t/");
                    ar.writeURLData(ngp.getSite().getKey().toString());
                    ar.write("/");
                    ar.writeURLData(ngp.getKey());
                    ar.write("/EditRole.htm?roleName=" );
                    ar.writeURLData(aRole.getName());
                }
                ar.write("\">Edit Role</a>");
                ar.write("&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;");

                List<AddressListEntry> allUsersRole = aRole.getDirectPlayers();
                StringBuffer existingPlayer = new StringBuffer();
                for (AddressListEntry ale : allUsersRole)
                {
                    if(!ale.isRoleRef())
                    {
                        existingPlayer.append(ale.getEmail());
                    }else{
                        existingPlayer.append(ale.getInitialId());
                    }
                    existingPlayer.append(";");
                }
                //ar.write("<a href=\"#\" onclick=\"openModalDialogue('dialog1','Add Player to','620px','");
                ar.write("<a href=\"#\" onclick=\"addPlayerInRole('dialog1','Add Players to','570px','");
                ar.writeHtml(aRole.getName());
                ar.write("','");
                ar.write(existingPlayer.toString());
                ar.write("')\" title=\"Add Players\">Add Players</a>");
                ar.write("&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;");
                ar.write("<a href=\"#\" onclick=\"openModalDialogue('AddExistingRole','Add Existing ','460px','");
                ar.writeURLData(aRole.getName());
                ar.write("')\" title=\"Add Existing Role\">Add Existing Role</a>");
                ar.write("</td>");
                ar.write("<td valign=\"top\" width=\"60%\">");
                ar.write("<table class=\"gridTable3\" width=\"100%\">");
                ar.write("<tr><th colspan=\"3\">");
                ar.write("</th></tr>");

                for (AddressListEntry ale : allUsersRole)
                {
                    if(!ale.isRoleRef())
                    {
                        String nameToRemove = ale.getStorageRepresentation();
                        UserProfile uProf = ale.getUserProfile();
                        if (uProf!=null) {
                            nameToRemove = aRole.whichIDForUser(uProf);
                        }
                        ar.write("<tr><th width=\"40%\">");
                        ale.writeLink(ar);
                        ar.write("</th><td width=\"58%\">");
                        ar.writeHtml(ale.getEmail());
                        ar.write("</td><td width=\"2%\" style=\"text-align:center\">");
                        ar.write("<a href=\"javascript:removeRole('Remove','");
                        ar.writeHtml(nameToRemove);
                        ar.write("','");
                        ar.writeHtml(aRole.getName());
                        ar.write("','updateRoleForm')\">");
                        ar.write("<img src=\"");
                        ar.writeHtml(ar.retPath);
                        ar.write("/assets/iconDelete.gif\" alt=\"Delete\"/> ");
                        ar.write("</a></td></tr>");

                    }
                }

                for (AddressListEntry ale : allUsersRole)
                {
                     if(ale.isRoleRef()){

                        ar.write("<tr><td colspan=\"3\" class=\"noBorder\"><table width=\"100%\"><tr><th colspan=\"3\">");
                        ar.write("<b>Role: <a href=\"#");
                        ar.writeHtml(ale.getInitialId());
                        ar.write("\">");
                        ar.writeHtml(ale.getInitialId());
                        ar.write("</a></b>");
                        ar.write("</th></tr></table></td></tr>");
                    }
                }

                ar.write("<tr><td colspan=\"3\" class=\"noBorder\">");
                ar.write("</td></tr>");
                ar.write("</table>");
                ar.write("</tr>");
                ar.write("<tr><td colspan=\"2\" class=\"horizontalSeperatorBlue\"></td></tr>");
            }
        }


        public void writeAllRolesFromAccount(AuthRequest ar, NGBook ngb, NGPage ngp) throws Exception
        {
            for (NGRole aRole : ngb.getAllRoles())
            {
                ar.write("<tr>");
                ar.write("<td valign=\"top\" class=\"columnRole\" width=\"40%\">");


                ar.write("<div class=\"pageRedHeading\"><a name=\"");
                ar.writeHtml(aRole.getName());
                ar.write("\">");
                ar.writeHtml(aRole.getName());
                ar.write("</a>");
                ar.write("</div>");

                ar.writeHtml(aRole.getDescription());
                ar.write("<br /><br />");
                ar.write("<b>Eligibility:</b><br />");
                ar.writeHtml(aRole.getRequirements());
                ar.write("<br /><br />");
                ar.write("</td>");
                ar.write("<td valign=\"top\" width=\"60%\">");
                ar.write("<table class=\"gridTable3\" width=\"100%\">");
                ar.write("<tr><th colspan=\"3\">");
                ar.write("</th></tr>");

                List <AddressListEntry> allUsers = aRole.getExpandedPlayers(ngp);
                for (AddressListEntry ale : allUsers)
                {
                    ar.write("<tr><th width=\"40%\">");
                    ale.writeLink(ar);
                    ar.write("</th><td width=\"58%\">");
                    ar.writeHtml(ale.getEmail());
                    ar.write("</td><td width=\"2%\" style=\"text-align:center\">");
                    ar.write("<img src=\"");
                    ar.writeHtml(ar.retPath);
                    ar.write("/assets/iconDeleteDisable.gif\" alt=\"\"/> ");
                    ar.write("</td></tr>");
                }
                ar.write("<tr><td colspan=\"3\" class=\"noBorder\">");
                ar.write("</td></tr>");
                ar.write("</table>");
                ar.write("</tr>");
                ar.write("<tr><td colspan=\"2\" class=\"horizontalSeperatorBlue\"></td></tr>");
            }
        }%>
