<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_account_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@page import="org.socialbiz.cog.spring.Constant"
%>
<div class="content tab01">
    <%
    if (!ar.isLoggedIn())
    {
    %>
    <div class="generalContent">
        <fmt:message key="nugen.projectsettings.PermissionsLogin"></fmt:message>
        <div class="clearer">&nbsp;</div>
    </div>
    <%
    }
    else
    {
        if (ar.isMember())
        {
    %>
    <div class="generalArea">
        <div id="container" >
    <%
            if (ngb!=null)
            {
                List<RoleRequestRecord> roleRequestRecordList = ngb.getAllRoleRequest();
    %>
            <div class="generalHeadingBorderLess">New Role Requests</div>
            <div id="listofpagesdiv">
                <table id="pagelist">
                    <thead>
                        <tr>
                            <th >Request Id</th>
                            <th >Role Name</th>
                            <th ><span class="iconArrowDown">Date</span></th>
                            <th >Requested by</th>
                            <th >Description</th>
                            <th >State</th>
                            <th >Time Period</th>
                        </tr>
                    </thead>
                    <tbody>
                <%
                for (RoleRequestRecord requestRecord : roleRequestRecordList)
                {
                     UserProfile uPro=UserManager.findUserByAnyId(requestRecord.getRequestedBy());
                     if (uPro!=null) {
                 %>
                        <tr>
                            <td><%ar.writeHtml(requestRecord.getRequestId()); %></td>
                            <td><%ar.writeHtml(requestRecord.getRoleName()); %></td>
                            <td><%=SectionUtil.getNicePrintDate(requestRecord.getModifiedDate())%></td>
                            <td><a href="<%ar.writeHtml(ar.retPath+"v/"+uPro.getKey()+"/userProfile.htm?active=1");%>"title='access the profile for this user, if it exists'><%ar.writeHtml(uPro.getName());%></a></td>
                            <td><%ar.writeHtml(requestRecord.getRequestDescription()); %></td>
                            <td><%ar.writeHtml(requestRecord.getState());%></td>
                            <td style='display:none'><%= (ar.nowTime - requestRecord.getModifiedDate())/1000%></td>
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
            if (ar.isAdmin()){
                List<RoleRequestRecord> roleRequestRecordHistory = ngb.getAllRoleRequestByState("Approved",true);
                roleRequestRecordHistory.addAll(ngb.getAllRoleRequestByState("rejected",true));
                if (roleRequestRecordHistory!=null)
                {
            %>
            <div class="generalHeadingBorderLess">Role Request History </div>
            <div id="listofpagesdiv2" >
                <table id="pagelist2">
                    <thead>
                        <tr>
                            <th >Request Id</th>
                            <th >Role Name</th>
                            <th ><span class="iconArrowDown">Date</span></th>
                            <th >Requested by</th>
                            <th >Requestee Comment</th>
                            <th >State</th>
                            <th >Description</th>
                            <th >Time Period</th>
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
                            <td><%ar.writeHtml(requestRecord.getRequestId()); %></td>
                            <td><%ar.writeHtml(requestRecord.getRoleName()); %></td>
                            <td><%=SectionUtil.getNicePrintDate(requestRecord.getModifiedDate())%></td>
                            <td><a href="<%ar.writeHtml(ar.retPath+"v/"+uPro.getKey()+"/userProfile.htm?active=1");%>"title='access the profile for this user, if it exists'><%ar.writeHtml(uPro.getName());%></a></td>
                            <td><%ar.writeHtml(requestRecord.getRequestDescription()); %></td>
                            <td><%ar.writeHtml(requestRecord.getState()); %></td>
                            <td><%ar.writeHtml(requestRecord.getResponseDescription()); %></td>
                            <td style='display:none'><%= (ar.nowTime - requestRecord.getModifiedDate())/1000%></td>
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
            %>
        </div>
            <%
        }
    }
    out.flush();
    %>
    </div>
    <!-- Tab Structure Ends Here -->
</div>
</div>
<!-- Content Area Ends Here -->
</div>


    <script type="text/javascript">

        YAHOO.util.Event.addListener(window, "load", function()
        {
            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"requestId",label:"Request Id",sortable:false,resizeable:true,hidden:true},
                    {key:"roleName",label:"Role Name",sortable:false,resizeable:true},
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"requestedby",label:"Requested By",sortable:true,resizeable:true},
                    {key:"description",label:"Description",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
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
                            {key:"state"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
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
                                        openApprovalRejectionForm('approved',accountId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
                                        break;
                                case 1:
                                        openApprovalRejectionForm('rejected',accountId,'<%=ar.retPath%>',roleName,requestedby,requestId,requestedDescription);
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


        function openApprovalRejectionForm(action,accountId,URL,roleName,requestedby,requestId,reqDescription){
            var onClickFunction ="makeRoleRequest('"+action+"','"+URL+"t/approveOrRejectRoleRequest.ajax?pageId="+accountId+"&action="+action+"&requestId="+requestId+"',document.getElementById('responseDescription'),approveOrRejectRoleRequestResult)";
            var body =  '<div class="generalArea">'+
                        '<div class="generalContent">'+
                            '<table width="90%" >'+
                                '<tr>'+
                                    '<td align="left" width="40%">'+
                                        '<label id="nameLbl"><B>Role Name : </B></label>'+
                                    '</td>'+
                                    '<td class="Odd">'+
                                        roleName+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td colspan = "2">&nbsp;</td></tr>'+
                                '<tr>'+
                                    '<td align="left" width="40%">'+
                                        '<label id="nameLbl"><B>Requested by : </B></label>'+
                                    '</td>'+
                                    '<td class="Odd">'+
                                        requestedby+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td colspan = "2">&nbsp;</td></tr>'+
                                '<tr>'+
                                    '<td valign="top"><B>Requestee Comment : </B></td>'+
                                    '<td class="Odd">'
                                        +reqDescription+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td colspan = "2">&nbsp;</td></tr>'+
                                '<tr>'+
                                    '<td valign="top"><B>Reason of Approval / Rejection : </B></td>'+
                                    '<td class="Odd">'+
                                        '<textarea name="responseDescription" id="responseDescription" style="WIDTH:95%; HEIGHT:74px;"></textarea>'+
                                    '</td>'+
                                '</tr>'+
                                '<tr><td colspan = "2">&nbsp;</td></tr>'+
                                '<tr>'+
                                    '<td colspan="2" align="center">'+
                                        '<input type="button" class="inputBtn"  value="Approve / Reject" onclick="'+onClickFunction+'">&nbsp;'+
                                        '<input type="button" class="inputBtn"  value="Cancel" onclick="cancel()" >'+
                                    '</td>'+
                                '</tr>'+

                            '</table>'+
                        '</div>'+
                        '</div>';
            createPanel("Request Approval / Rejection Form",body,"600px");
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
                    var respText = o.responseText;

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
                    {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"requestedby",label:"Requested By",sortable:true,resizeable:true},
                    {key:"requesteeComment",label:"Requestee Comment",sortable:true,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                    {key:"Description",label:"Description",sortable:true,resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
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
                            {key:"Description"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
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