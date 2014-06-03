<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="administration.jsp"
%><%ar.assertLoggedIn("New Site page should never be accessed when not logged in");
    if (!ar.isSuperAdmin()) {
        throw new Exception("New Site page should only be accessed by Super Admin");
    }
    if (uProf==null) {
        throw new Exception("Program Logic Error: The 'uProf' object must be set up for requestedAccounts.jsp");
    }%>
<div class="content tab04" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div class="generalHeadingBorderLess"><br>System Administrator: Site Requests</div>
        <div id="accountRequestPaging"></div>
        <div id="accountRequestDiv">
            <table id="pagelist11">
                <thead>
                    <tr>
                        <th >Request Id</th>
                        <th >Site Name</th>
                        <th >State</th>
                        <th >Description</th>
                        <th >Date</th>
                        <th >Requested by</th>
                        <th >timePeriod</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (SiteRequest requestRecord : superRequests)
                        {
                            UserProfile userProfile =  UserManager.findUserByAnyId(requestRecord.getModUser());
                %>
                    <tr>
                        <td><%ar.writeHtml(requestRecord.getRequestId()); %></td>
                        <td><%ar.writeHtml(requestRecord.getName());%></td>
                        <td><%ar.writeHtml(requestRecord.getStatus()); %></td>
                        <td><%ar.writeHtml(requestRecord.getDescription());%></td>
                        <td><%ar.writeHtml(SectionUtil.getNicePrintDate(requestRecord.getModTime())); %></td>
                        <td><%
                            if (userProfile==null) {
                                ar.writeHtml(requestRecord.getModUser());
                            }
                            else
                            {
                                userProfile.writeLink(ar);
                            }
                        %></td>
                        <td><%ar.writeHtml(String.valueOf(requestRecord.getModTime()));%></td>
                    </tr>
                <%
                }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var newAccountCD = [
                {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                {key:"accountname",label:"Site Name", sortable:true,resizeable:true},
                {key:"description",label:" Site Description", sortable:true,resizeable:true}

            ];

            var newAccountDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("newAccountList"));
            newAccountDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            newAccountDS.responseSchema = {
                fields: [{key:"no", parser:"number"},
                        {key:"accountname"},
                        {key:"description"},
                        ]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200
                }),
                initialRequest: "results=999999"
            };


            var newAccountDT = new YAHOO.widget.DataTable("newAccountContainer", newAccountCD, newAccountDS, oConfigs,
            {caption:"",sortedBy:{key:"no",dir:"desc"}});

             // Enable row highlighting
            newAccountDT.subscribe("rowMouseoverEvent", newAccountDT.onEventHighlightRow);
            newAccountDT.subscribe("rowMouseoutEvent", newAccountDT.onEventUnhighlightRow);

            return {
                oDS: newAccountDS,
                oDT: newAccountDT
            };
        }();
    });

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var newUserCD = [
                {key:"userName",label:"User Name",sortable:true,resizeable:true},
                {key:"regdate",label:"Registration Date",sortable:false,resizeable:true},
                {key:"email",label:"Email Address",sortable:true,resizeable:true}
                ];

            var newUserDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("newUserList"));
            newUserDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            newUserDS.responseSchema = {
                fields: [{key:"userName"},
                        {key:"regdate"},
                        {key:"email"}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers   : 'newUserPaging'
                }),
                initialRequest: "results=999999"

            };

            var newUserDT = new YAHOO.widget.DataTable("newUserDiv", newUserCD, newUserDS, oConfigs,
            {caption:"",sortedBy:{key:"email",dir:"regdate"}});

             // Enable row highlighting
            newUserDT.subscribe("rowMouseoverEvent", newUserDT.onEventHighlightRow);
            newUserDT.subscribe("rowMouseoutEvent", newUserDT.onEventUnhighlightRow);
            return {
                oDS: newUserDS,
                oDT: newUserDT
            };
        }();
    });

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var accountRequestCD = [
                {key:"requesteId",label:"Request Id",sortable:true,resizeable:true},
                {key:"accountName",label:"Site Name",sortable:false,resizeable:true},
                {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:true,resizeable:true},
                {key:"description",label:"Description",sortable:false,resizeable:true},
                {key:"date",label:"Date",formatter:YAHOO.widget.DataTable.formatDate,sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"requestedby",label:"Requested by",sortable:true,resizeable:true},
                {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true}
                ];

            var accountRequestDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist11"));
            accountRequestDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            accountRequestDS.responseSchema = {
                fields: [{key:"requesteId"},
                        {key:"accountName"},
                        {key:"state"},
                        {key:"description"},
                        {key:"date"},
                        {key:"requestedby"},
                        {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers   : 'accountRequestPaging'
                }),
                initialRequest: "results=999999"

            };

            var accountRequestDT = new YAHOO.widget.DataTable("accountRequestDiv", accountRequestCD, accountRequestDS, oConfigs,
            {caption:"",sortedBy:{key:"requestedby",dir:"date"}});

             // Enable row highlighting
            accountRequestDT.subscribe("rowMouseoverEvent", accountRequestDT.onEventHighlightRow);
            accountRequestDT.subscribe("rowMouseoutEvent", accountRequestDT.onEventUnhighlightRow);

            var onContextMenuClick = function(p_sType, p_aArgs, p_accountRequestDT) {
                var task = p_aArgs[1];
              if(task) {
                    // Extract which TR element triggered the context menu

                    var elRow = this.contextEventTarget;
                    elRow = p_accountRequestDT.getTrEl(elRow);
                    accountRequestDT2=p_accountRequestDT;
                    elRow2=elRow;
                    var oRecord = p_accountRequestDT.getRecord(elRow);

                    if(elRow) {
                       switch(task.index) {

                            case 0:
                                    var accountName = oRecord.getData("accountName");
                                    var requesteId = oRecord.getData("requesteId");
                                    var state = oRecord.getData("state");
                                    var description = oRecord.getData("description");
                                    var date = oRecord.getData("date");
                                    var requestedby = oRecord.getData("requestedby");
                                    var body = '<div class="generalArea">'+
                                                '<div class="generalSettings">'+
                                                '<form id="acceptOrDenyForm" action="<%=ar.retPath%>t/acceptOrDeny.form" method="post" >'+
                                                    '<table>'+
                                                        '<tr>'+
                                                            '<td class="gridTableColummHeader">'+
                                                                '<label id="nameLbl"><B>Requested By: </B></label>'+
                                                            '</td>'+
                                                            '<td style="width:20px;"></td>'+
                                                            '<td><B>'+
                                                                requestedby+
                                                            '</B></td>'+
                                                        '</tr>'+
                                                        '<tr><td style="height:10px"></td></tr>'+
                                                        '<tr>'+
                                                            '<td class="gridTableColummHeader"><B>Site Name: </B></td>'+
                                                            '<td style="width:20px;"></td>'+
                                                            '<td>'+
                                                                accountName+
                                                            '</td>'+
                                                        '</tr>'+
                                                        '<tr><td style="height:10px"></td></tr>'+
                                                        '<tr>'+
                                                            '<td class="gridTableColummHeader">'+
                                                                '<label><B>Requested On: </B></label>'+
                                                            '</td>'+
                                                            '<td style="width:20px;"></td>'+
                                                            '<td>'+
                                                                date+
                                                            '</td>'+
                                                        '</tr>'+
                                                        '<tr><td style="height:20px"></td></tr>'+
                                                        '<tr>'+
                                                            '<td class="gridTableColummHeader" valign="top"><B>Description: </B></td>'+
                                                            '<td style="width:20px;"></td>'+
                                                            '<td>'+
                                                                '<textarea id="description" name="description" row="4">'+description+'</textarea>'+
                                                            '</td>'+
                                                        '</tr>'+
                                                        '<tr><td style="height:20px"></td></tr>'+
                                                        '<tr>'+
                                                            '<td class="gridTableColummHeader"></td>'+
                                                            '<td style="width:20px;"></td>'+
                                                            '<td>'+
                                                                '<input type="button" class="inputBtn"  value="Accept" onclick="acceptOrDeny(\'accept\',\''+state+'\')">&nbsp;'+
                                                                '<input type="button" class="inputBtn"  value="Deny" onclick="acceptOrDeny(\'deny\',\''+state+'\')">&nbsp;'+
                                                                '<input type="button" class="inputBtn"  value="Cancel" onclick="cancel()" >'+
                                                            '</td>'+
                                                      '</table>'+
                                                      '<input type="hidden" name="action" id="action" value="">'+
                                                      '<input type="hidden" name="requestId" id="requestId" value="'+ requesteId +'">'+
                                                    '</form>'+
                                                    '</div>'+
                                                    '</div>';
                                    createPanel("Accept or Deny Request",body,"600px");
                                    break;
                            }
                        }
                    }
                };

            var myContextMenu = new YAHOO.widget.ContextMenu("mycontextmenu",
                    {trigger:accountRequestDT.getTbodyEl()});

             myContextMenu.addItems(
                                    [{ text: "Accept/Deny Request"}]
                                   );

            // Render the ContextMenu instance to the parent container of the DataTable
            myContextMenu.render("accountRequestDiv");
            myContextMenu.clickEvent.subscribe(onContextMenuClick, accountRequestDT);

            return {
                oDS: accountRequestDS,
                oDT: accountRequestDT
            };
        }();
    });

</script>
