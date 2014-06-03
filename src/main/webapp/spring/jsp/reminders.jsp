<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/attachment_forms.jsp"
%><%

    String encodedLoginMsg = URLEncoder.encode("Can't open form","UTF-8");

%>
    <div class="pageHeading">Document Reminders</div>
    <div class="pageSubHeading">
        This is a list of the reminders to attach documents to this project.
    </div>
<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/container/assets/skins/sam/container.css">
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/animation/animation-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/container/container-min.js"></script>

<script>
function onClickAction(){
    <%if(ngp.isFrozen()){%>
        openFreezeMessagePopup();
    <%}else{%>
        document.getElementById("createDocForm").action = "emailReminder.htm";
        document.getElementById("createDocForm").submit();
    <%}%>
}
</script>
<div class="content tab01">
    <%if (!ar.isLoggedIn())
    {
    %>
    <div class="generalArea">
        <div class="generalContent">
            In order to see this section, you need to be logged in.
        </div>

    </div>
    <%
    }
    else
    {
    %>
    <form name="createDocForm" id="createDocForm" action="uploadDocument.htm" method="get">
        <table width="100%">
            <tr>
                <td align="right">
                    <img src="<%=ar.retPath %>assets/iconEmailReminder.gif" />
                    <a href="javascript:onClickAction()"  title="<fmt:message key='nugen.attachment.uploadattachment.EmailReminder'/>">
                        <fmt:message key='nugen.attachment.uploadattachment.EmailReminder'/>
                    </a>
                </td>
            </tr>
        </table>
    </form>

    <div id="paging"></div>
    <div id="listofpagesdiv">
        <table id="pagelist">
            <thead>
                <tr>
                    <th>Subject</th>
                    <th><fmt:message key="nugen.attachment.pagelist.Recipient"/></th>
                    <th>Status</th>
                    <th><fmt:message key="nugen.attachment.pagelist.ResendEmail"/></th>
                    <th>timePeriod</th>
                    <th>rid</th>
                </tr>
            </thead>
            <tbody>
        <%
        ReminderMgr rMgr = ngp.getReminderMgr();
        Vector rVec = rMgr.getOpenReminders();
        Enumeration e2 = rVec.elements();
        int reminderCount = 0;
        while(e2.hasMoreElements())
        {
            ReminderRecord rRec = (ReminderRecord)e2.nextElement();
            reminderCount++;
            String link = ar.retPath + "RemindAttachment.jsp?p="+URLEncoder.encode(ngp.getKey(), "UTF-8")
                    +"&rid="+URLEncoder.encode(rRec.getId(), "UTF-8");
            String update = ar.retPath + "ReminderEdit.jsp?p="+URLEncoder.encode(ngp.getKey(), "UTF-8")
                    +"&rid="+URLEncoder.encode(rRec.getId(), "UTF-8");
            String email = "sendemailReminder.htm?rid="+URLEncoder.encode(rRec.getId(), "UTF-8");
            String dName = rRec.getSubject();
            if (dName==null || dName.length()==0)
            {
                dName = "Reminder"+rRec.getId();
            }

            AddressListEntry ale = new AddressListEntry(rRec.getAssignee());

            %>
                <tr>
                    <td><%ar.writeHtml(dName);%></td>
                    <td>
                        To: <b><%ale.writeLink(ar);%></b><br/>
                        On: <%SectionUtil.nicePrintTime(out, rRec.getModifiedDate(), ar.nowTime);%>
                    </td>

                    <td>
                        <%
                        if(rRec.isOpen()){
                            ar.writeHtml("Open");
                        }else{
                            ar.writeHtml("Closed");
                        }
                        %>
                    </td>
                    <td>
                        <%
                        if(ngp.isFrozen())
                        {
                        %>
                        <a href="#" onclick="javascript:openFreezeMessagePopup();" >
                        <img src="<%=ar.retPath%>emailIcon.gif" title="<fmt:message key='nugen.attachment.ResendReminder'/>">
                        </a>
                        <%
                        }else{
                        %>
                        <a href="<%writeHtml(out, email);%>" title="<fmt:message key='nugen.attachment.SendReminderAsEmail'/>">
                            <img src="<%=ar.retPath%>emailIcon.gif" title="<fmt:message key='nugen.attachment.ResendReminder'/>">
                        </a>
                        <%} %>
                    </td>
                    <td><%ar.writeHtml(String.valueOf((ar.nowTime - rRec.getModifiedDate())/1000 ));%></td>
                    <td><%ar.writeHtml(rRec.getId());%></td>
                </tr>
                <%
                }
                %>
            </tbody>
        </table>
    </div>
    <%
    }
    %>
</div>
    <script type="text/javascript">

        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"attachmentName",label:"Subject",formatter:reminderNameFormater,sortable:true,resizeable:true},
                    {key:"to",label:"<fmt:message key='nugen.attachment.pagelist.Recipient'/>",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"Status",label:"Status",sortable:true,resizeable:false},
                    {key:"resendEmail",label:"<fmt:message key='nugen.attachment.pagelist.ResendEmail'/>",sortable:false,resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true},
                    {key:"rid",label:"rid",sortable:true,resizeable:false,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"attachmentName"},
                            {key:"to"},
                            {key:"Status"},
                            {key:"resendEmail"},
                            {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber},
                            {key:"rid"}]
                };

                 var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers: 'paging'
                    }),
                    initialRequest: "results=999999"

                };

                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv", myColumnDefs, myDataSource, oConfigs,
                {caption:""});

                var onContextMenuClick = function(p_sType, p_aArgs, p_myDataTable) {
                    var task = p_aArgs[1];
                  if(task) {
                        var elRow = this.contextEventTarget;
                        elRow = p_myDataTable.getTrEl(elRow);
                        myDataTable2=p_myDataTable;
                        elRow2=elRow;
                        var oRecord = p_myDataTable.getRecord(elRow);
                        rid = oRecord.getData("rid");
                        if(elRow) {
                        <%
                            if(ngp.isFrozen())
                            {
                        %>
                                openFreezeMessagePopup();
                        <%
                            }else{
                        %>
                                if(task.groupIndex==0){
                                    switch(task.index) {
                                        case 0:
                                                if(confirm("Are you sure you want to delete '" +
                                                    oRecord.getData("attachmentName") +"' reminder?")) {

                                                    var transaction = YAHOO.util.Connect.asyncRequest('POST', '<%=ar.retPath%>t/deleteReminder.ajax?containerId=<%ar.writeHtml(ngp.getKey()); %>&rid='+oRecord.getData("rid"), handleDeleteReminderAction);
                                                }
                                                break;
                                    }
                                }
                        <%
                            }
                        %>
                        }
                        }
                    };


                var myContextMenu = new YAHOO.widget.ContextMenu("mycontextmenu",
                        {trigger:myDataTable.getTbodyEl()});

                 myContextMenu.addItems([
                                          { text: "Delete Reminder"}
                                        ]);

                // Render the ContextMenu instance to the parent container of the DataTable
                myContextMenu.render("listofpagesdiv");
                myContextMenu.clickEvent.subscribe(onContextMenuClick, myDataTable);

                myDataTable.subscribe("cellMouseoverEvent", function(oArgs){
                    var oRecord = this.getRecord(oArgs.target);
                    var column = this.getColumn(oArgs.target);
                    if(column.key != "attachmentName"){
                       return false;
                    }
                });
                myDataTable.subscribe("rowMouseoverEvent", function(oArgs){myDataTable.unselectAllCells();});
                myDataTable.subscribe("cellMouseoutEvent", function(oArgs){
                    var oRecord = this.getRecord(oArgs.target);
                    myDataTable.hideColumn("Actions");
                });

                myDataTable.subscribe("cellClickEvent", function(oArgs){
                    var oRecord = this.getRecord(oArgs.target);
                    var column = this.getColumn(oArgs.target);
                    if(column.key == "attachmentName"){
                       var xy = YAHOO.util.Event.getXY(oArgs.event);

                       myContextMenu.cfg.setProperty("xy", xy);
                       myContextMenu.contextEventTarget = oArgs.target;
                       myDataTable.unselectAllCells();
                       myDataTable.selectCell(oArgs.target);
                       myContextMenu.show();

                    }
                });


                myDataTable.sortColumn(myDataTable.getColumn(4));
                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });

        var reminderNameFormater = function(elCell, oRecord, oColumn, sData)
        {
            var name = oRecord.getData("attachmentName");
            elCell.innerHTML = '<div style="color:gray;">'+name+'</div>';

        };

        var handleDeleteReminderAction={

            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');

                if(json.msgType == "success"){
                    window.location.reload();
                }
                else if(json.msgType == "failure"){
                    showErrorMessage("Unable to Restore Reminder", json.msg , json.comments);
                }else{
                    window.location  = "<%=ar.retPath%>t/EmailLoginForm.htm?&msg=<%=encodedLoginMsg%>&go=<%ar.writeURLData(ar.getCompleteURL());%>";
                }
            },
            failure: function(o) {
                alert("handleDeleteReminderAction Error:" +o.responseText);
            }
        }
    </script>
