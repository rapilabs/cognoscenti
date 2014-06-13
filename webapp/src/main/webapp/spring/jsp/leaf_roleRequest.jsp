<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@page import="org.socialbiz.cog.spring.Constant"
%><%/*
Required parameter:

    1. requestId : This is the id of a role request & required only in case of request is generated from mail and
                   used to retrieve RoleRequestRecord.

Optional Parameter:

    1. isAccessThroughEmail : This parameter is used to check if request is generated from mail.
*/

    String isAccessThroughEmail = ar.defParam("isAccessThroughEmail","no");
    boolean canAccessPage = false;
    boolean requestFromMail = false;
    String requestId = null;
    if ("yes".equalsIgnoreCase(isAccessThroughEmail)){
        requestId = ar.reqParam("requestId");
        RoleRequestRecord roleRequestRecord = ngp.getRoleRequestRecordById(requestId);
        canAccessPage = AccessControl.canAccessRoleRequest(ar, ngp, roleRequestRecord);
    }%>
    <%@page import="org.socialbiz.cog.AccessControl"%>
<div class="content tab01">
    <%
        String roleRequestId = null;

        String roleRequest_State = "";
        if ( !requestFromMail && !canAccessPage && !ar.isLoggedIn() )
        {
    %>
        <div class="generalContent">
           <fmt:message key="nugen.projectsettings.PermissionsLogin"></fmt:message>
           <div class="clearer">&nbsp;</div>
        </div>
    <%
        }else
        {
            if ("no".equalsIgnoreCase(isAccessThroughEmail)){
        List<RoleRequestRecord> roleRequestRecordList = ngp.getAllRoleRequestByState("Requested",false);
        if (roleRequestRecordList!=null){
    %>
        <div style="height:20px">&nbsp;</div>
        <div class="generalHeadingBorderLess">New Role Requests</div>
        <div id="paging"></div>
        <div id="listofpagesdiv">
            <table id="pagelist">
                <thead>
                    <tr>
                        <th >Role Name</th>
                        <th ><span class="iconArrowDown">Date</span></th>
                        <th >Requested by</th>
                        <th >Description</th>
                        <th >State</th>
                        <th >Request Id</th>
                        <th >Time Period</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (RoleRequestRecord requestRecord : roleRequestRecordList)
                        {
                            if(requestRecord != null){
                                UserProfile uPro = UserManager.findUserByAnyId(requestRecord.getRequestedBy());
                %>
                    <tr>
                        <td><%
                            ar.writeHtml(requestRecord.getRoleName());
                        %></td>
                        <td><%=SectionUtil.getNicePrintDate(requestRecord.getModifiedDate())%></td>
                        <!--<td><a href="<%ar.writeHtml(ar.retPath+"v/"+uPro.getKey()+"/userProfile.htm?active=1");%>" title='access the profile for this user, if it exists'><%ar.writeHtml(requestRecord.getRequestedBy());%></a></td>-->
                        <td><%
                            (new AddressListEntry(requestRecord.getRequestedBy())).writeLink(ar);
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getRequestDescription());
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getState());
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getRequestId());
                        %></td>
                        <td style='display:none'><%=(ar.nowTime - requestRecord.getModifiedDate())/1000%></td>
                    </tr>
                <%
                    }
                            }
                %>
                </tbody>
            </table>
        </div>
            <%
                }if (ar.isAdmin()){
                    List<RoleRequestRecord> roleRequestRecordHistory = ngp.getAllRoleRequestByState("Approved",true);
                    roleRequestRecordHistory.addAll(ngp.getAllRoleRequestByState("rejected",true));
                    if (roleRequestRecordHistory!=null)
                    {
            %>
        <div style="height:20px">&nbsp;</div>
        <div class="generalHeadingBorderLess">Role Request History </div>
        <div id="paging1"></div>
        <div id="listofpagesdiv2" >
            <table id="pagelist2">
                <thead>
                    <tr>
                        <th >Role Name</th>
                        <th ><span class="iconArrowDown">Date</span></th>
                        <th >Requested by</th>
                        <th >Requestee Comment</th>
                        <th >State</th>
                        <th >Description</th>
                        <th >Request Id</th>
                        <th>Time Period</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        Iterator itr = roleRequestRecordHistory.iterator();
                                long max_days = 0;
                                while (itr.hasNext())
                                {
                                    RoleRequestRecord requestRecord = (RoleRequestRecord) itr.next();
                                    if(requestRecord != null && requestRecord.showRecord()){
                                        UserProfile uPro=UserManager.findUserByAnyId(requestRecord.getRequestedBy());
                    %>
                    <tr>
                        <td><%
                            ar.writeHtml(requestRecord.getRoleName());
                        %></td>
                        <td><%=SectionUtil.getNicePrintDate(requestRecord.getModifiedDate())%></td>
                        <td><a href="<%ar.writeHtml(ar.retPath+"v/"+uPro.getKey()+"/userProfile.htm?active=1");%>"title='access the profile for this user, if it exists'><%
                            ar.writeHtml(uPro.getName());
                        %></a></td>
                        <td><%
                            ar.writeHtml(requestRecord.getRequestDescription());
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getState());
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getResponseDescription());
                        %></td>
                        <td><%
                            ar.writeHtml(requestRecord.getRequestId());
                        %></td>
                        <td style='display:none'><%=(ar.nowTime - requestRecord.getModifiedDate())/1000%></td>
                    </tr>
                    <%
                        }
                                }
                    %>
                </tbody>
            </table>
        </div>
        <%
            }
            }
                }else{
            RoleRequestRecord roleRequestRecord = ngp.getRoleRequestRecordById(requestId);
            if(roleRequestRecord != null){
                roleRequest_State = roleRequestRecord.getState();
                if("Requested".equalsIgnoreCase(roleRequest_State )){
        %>
                    <div style="height:20px">&nbsp;</div>
                    <div class="generalHeading">Request Approval/Rejection Form</div>
                    <div class="generalContent">
                        <table>
                            <tr><td style="height:10px" colspan="3"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader_2">Role Name:</td>
                                    <td style="width:20px;"></td>
                                    <td>
                                        <%
                                            ar.writeHtml(roleRequestRecord.getRoleName());
                                        %>
                                    </td>
                                </tr>
                                <tr><td style="height:8px" colspan="3"></td></tr>
                                <tr>
                                    <td class="gridTableColummHeader_2">Requested By:</td>
                                    <td style="width:20px;"></td>
                                    <td>
                                        <%
                                            ar.writeHtml(roleRequestRecord.getRequestedBy());
                                        %>
                                    </td>
                                </tr>
                                <tr><td style="height:8px" colspan="3"></td></tr>
                                <tr>
                                    <td class="gridTableColummHeader_2">Requestee Comment:</td>
                                    <td style="width:20px;"></td>
                                    <td>
                                        <%
                                            ar.writeHtml(roleRequestRecord.getRequestDescription());
                                        %>
                                    </td>
                                </tr>
                                <tr><td style="height:8px" colspan="3"></td></tr>
                                <tr>
                                    <td class="gridTableColummHeader_2" valign="top">Reason of Approval/Rejection:</td>
                                    <td style="width:20px;"></td>
                                    <td>
                                        <textarea name="respDescription" id="respDescription" class="textAreaGeneral" rows="4"></textarea>
                                    </td>
                                </tr>
                                <tr><td style="height:8px" colspan="3"></td></tr>
                                <tr>
                                    <td class="gridTableColummHeader_2"></td>
                                    <td style="width:20px;"></td>
                                    <td>
                                        <input type="button" class="inputBtn"  value="Approve" onclick="makeRoleRequest('approved','<%=ar.retPath%>t/approveOrRejectRoleRequest.ajax?pageId=<%ar.writeHtml(p);%>&action=approved&requestId=<%ar.writeHtml(requestId);%>',document.getElementById('respDescription'),approveOrRejectRoleRequestResult)">&nbsp;
                                        <input type="button" class="inputBtn"  value="Reject" onclick="makeRoleRequest('rejected','<%=ar.retPath%>t/approveOrRejectRoleRequest.ajax?pageId=<%ar.writeHtml(p);%>&action=rejected&requestId=<%ar.writeHtml(requestId);%>',document.getElementById('respDescription'),approveOrRejectRoleRequestResult)">&nbsp;
                                        <!--<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >-->
                                    </td>
                                </tr>
                            </table>
                        </div>
                        <%
                            }else{
                        %>
                        <div class="generalHeading">Request Approval/Rejection Form</div>
                        <br/>
                        <table width="80%" class="gridTable">
                        <%
                            if("Rejected".equalsIgnoreCase(roleRequest_State)){
                        %>
                            <tr>
                                <td  style="color:gray;font-size: 12px" colspan="2"><b><I>This request has already been Rejected.</I></b><br></td>
                            </tr>
                            <tr >
                                <td width="30%"><b><I>Reason for Rejection:</I></b><br></td>
                                <td><b><I><%
                                    ar.writeHtml(roleRequestRecord.getResponseDescription());
                                %></I></b><br></td>
                            </tr>
                        <%
                            }else if("Approved".equalsIgnoreCase(roleRequest_State)){
                        %>
                            <tr>
                                <td style="color:gray; font-size: 12px" colspan="2"><b><I>This request has already been Approved.</I></b><br></td>
                            </tr>
                            <tr >
                                <td width="30%"><b><I>Description:</I></b><br></td>
                                <td><b><I><%
                                    ar.writeHtml(roleRequestRecord.getResponseDescription());
                                %></I></b><br></td>
                            </tr>
                        <%
                            }
                        %>
                        </table>
            <%
                }
                }else{
            %>
                   <div class="generalHeading">Request Approval/Rejection Form</div>
                        <br/>
                        <table width="80%" class="gridTable">
                            <tr>
                                <td  style="color:gray; font-size: 12px" colspan="2"><b><I>This request is declined or cancelled by Requestee.</I></b><br></td>
                            </tr>
                        </table>


         <%
             }
                 }
             }
             out.flush();
         %>
        </div>
    </div>
    <script type="text/javascript">
        var isfreezed = '<%=ngp.isFrozen()%>';

        var requestedByFormater = function(elCell, oRecord, oColumn, sData)
        {
            var requestedby = oRecord.getData("requestedby");

            elCell.innerHTML = requestedby;

        };

        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [

                    {key:"roleName",label:"Role Name",sortable:false,resizeable:true},
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"requestedby",label:"Requested By",formatter:requestedByFormater,sortable:true,resizeable:true},
                    {key:"description",label:"Description",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                    {key:"requestId",label:"Request Id",sortable:false,resizeable:true,hidden:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [

                            {key:"roleName"},
                            {key:"date"},
                            {key:"requestedby"},
                            {key:"description"},
                            {key:"state"},
                            {key:"requestId"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers: 'paging'
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
                            if(isfreezed == 'false'){
                                switch(task.index) {
                                  case 0:
                                          openApprovalRejectionForm('approved',pageId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
                                          //makeRoleRequest('<%=ar.retPath%>t/approveOrRejectRoleRequest.ajax?pageId='+pageId+'&action=approved&roleName='+roleName+'&requestedBy='+requestedby+'&requestId='+requestId,'approveOrRejectRoleRequestResult');
                                          //var transaction = YAHOO.util.Connect.asyncRequest('POST','<%=ar.retPath%>t/approveOrRejectRoleRequest.ajax?pageId='+pageId+'&action=approved&roleName='+roleName+'&requestedBy='+requestedby+'&requestId='+requestId,approveOrRejectRoleRequestResult);
                                          break;
                                  case 1:
                                          openApprovalRejectionForm('rejected',pageId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
                                          break;
                                }
                            }else{
                                openFreezeMessagePopup();
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
            if(isfreezed == 'false'){
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
                                          '<label id="nameLbl"><B>Requested by: </B></label>'+
                                      '</td>'+
                                      '<td style="width:20px;"></td>'+
                                      '<td>'+
                                          requestedby+
                                      '</td>'+
                                  '</tr>'+
                                  '<tr><td style="height:10px"></td></tr>'+
                                  '<tr>'+
                                      '<td class="gridTableColummHeader"><B>Requestee Comment: </B></td>'+
                                      '<td style="width:20px;"></td>'+
                                      '<td>'
                                          +reqDescription+
                                      '</td>'+
                                  '</tr>'+
                                  '<tr><td style="height:20px"></td></tr>'+
                                  '<tr>'+
                                      '<td class="gridTableColummHeader" valign="top"><B>'+reasonLable+'</B></td>'+
                                      '<td style="width:20px;"></td>'+
                                      '<td>'+
                                          '<textarea name="responseDescription" id="responseDescription" rows="4"></textarea>'+
                                      '</td>'+
                                  '</tr>'+
                                  '<tr><td style="height:20px"></td></tr>'+
                                  '<tr>'+
                                      '<td class="gridTableColummHeader"></td>'+
                                      '<td style="width:20px;"></td>'+
                                      '<td>'+
                                          '<input type="button" class="inputBtn"  value="'+buttonLabel+'" onclick="'+onClickFunction+'">&nbsp;'+
                                          '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                                      '</td>'+
                                  '</tr>'+
                              '</table>'+
                          '</div>'+
                          '</div>';
              createPanel(title,body,"550px");
            }else{
             openFreezeMessagePopup();
            }
        }
        function trim(s) {
            var temp = s;
            return temp.replace(/^s+/,'').replace(/s+$/,'');
        }
        function makeRoleRequest(action,URL,responseDescriptionObj,resultFunction){
            if(isfreezed == 'false'){
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
            }else{
                openFreezeMessagePopup();
            }
        }
        var approveOrRejectRoleRequestResult = {
            success: function(o) {
                    var respText = o.responseText;
                    var json = eval('(' + respText+')');
                    if(json.msgType == "success"){
                        if('<%=isAccessThroughEmail%>' == 'yes'){
                            alert("Operation has been performed successfully.");
                            window.location = '<%=ar.retPath%>t/<%ar.writeHtml(ngp.getSite().getKey());%>/<%ar.writeHtml(p);%>/roleRequest.htm';
                        }else{
                            window.location.reload();
                        }
                    }else{
                        showErrorMessage("Result", json.msg , json.comments );
                    }
                    if('<%=isAccessThroughEmail%>' != 'yes'){
                        myPanel.hide();
                    }

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
                    {key:"roleName",label:"Role Name",sortable:false,resizeable:true},
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,sortOptions:{sortFunction:sortDates}, resizeable:true},
                    {key:"requestedby",label:"Requested By",sortable:true,resizeable:true},
                    {key:"requesteeComment",label:"Requestee Comment",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                    {key:"Description",label:"Description",sortable:true,resizeable:true},
                    {key:"requestId",label:"Request Id",sortable:false,resizeable:true,hidden:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist2"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"roleName"},
                            {key:"date"},
                            {key:"requestedby"},
                            {key:"requesteeComment"},
                            {key:"state"},
                            {key:"Description"},
                            {key:"requestId"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers: 'paging1'
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