<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserHome.jsp"
%><%Vector<NotificationRecord> notifications = uProf.getNotificationList();
    List<NGContainer> containers = new ArrayList();
    long lastSendTime = SuperAdminLogFile.getLastNotificationSentTime();%>
<div class="content tab02" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <%
            if(notifications.size()>0){
        %>
        <div class="generalHeadingBorderLess">
            <table width="100%">
                <tr>
                    <td>You will receive Notifications on these Projects</td>
                    <td align="right"><input type="button" name="action"  class="inputBtn" value="Block All Notifications"  onclick="blockAllNotifications();"></td>
                </tr>
            </table>
        </div>
        <div id="pagingNotify"></div>
        <div id="notifyContainer">
               <table id="notifyProjectList">
                   <thead>
                       <tr>
                           <th>No</th>
                           <th>Project Name</th>
                           <th>Last Modified</th>
                       </tr>
                   </thead>
                   <tbody>
                   <%
                       int count = 0;
                                  String rowStyleClass = "";
                                  for (NotificationRecord tr : notifications)
                                  {
                                      String pageId = tr.getPageKey();
                                      NGPage ngp = (NGPage)NGPageIndex.getContainerByKey(pageId);
                                      if (ngp==null)
                                      {
                                          continue;
                                      }
                                      containers.add(ngp);
                                      String linkAddr = ar.retPath + "t/" +ngp.getSite().getKey()+"/"+ngp.getKey() + "/history.htm";
                                      if(count%2 == 0){
                                          rowStyleClass = "tableBodyRow odd";
                                      }else{
                                          rowStyleClass = "tableBodyRow even";
                                      }
                   %>
                    <tr>
                        <td>
                            <%=(++count)%>
                        </td>
                        <td>
                            <a href="<%writeHtml(out, linkAddr);%>" title="navigate to the page"><%writeHtml(out, ngp.getFullName());%></a>
                        </td>
                        <td>
                            <%SectionUtil.nicePrintTime(out, ngp.getLastModifyTime(), ar.nowTime);%>
                        </td>
                        <td style='display:none'><%ar.writeHtml(ngp.getKey()); %></td>
                        <td style='display:none'><%= (ar.nowTime - ngp.getLastModifyTime())/1000%></td>
                    </tr>
                <%
                       }

                %>
                   </tbody>
               </table>
        </div>
        <%
        }
        else{
        %>
        <div class="guideVocal">You are not signed up to receive notifications from any project.<br/>
            <br/>
            When visiting a project, go to the "Project Settings>Personal" page and sign up
            to receive notifications.   Then, when things in the project change,
            such as documents added, or notes edited, you will see those changes here,
            and will be automatically notified of the changes by email.<br/>
            <br/>
            Later, you can turn off notifications at any time.</div>
        <%
        }
        %>
    </div>
</div>
<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var notifyColumnDefs = [
                    {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                    {key:"pagename",label:"Project Name", sortable:true,resizeable:true},
                    {key:"lastmodified",label:"Last Modified", sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"pagekey",label:"<fmt:message key='nugen.userhome.PageKey'/>", sortable:true,resizeable:true,hidden:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                ];

            var notifyProjectDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("notifyProjectList"));
                notifyProjectDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                notifyProjectDS.responseSchema = {
                    fields: [{key:"no", parser:"number"},
                            {key:"pagename"},
                            {key:"lastmodified"},
                            {key:"pagekey"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
            };

            var notifyConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers: 'pagingNotify'
                }),
                initialRequest: "results=999999"
            };

             var notifyProjectDT = new YAHOO.widget.DataTable("notifyContainer", notifyColumnDefs, notifyProjectDS, notifyConfigs,
                {caption:"",sortedBy:{key:"no",dir:"desc"}});

            // Enable row highlighting
                notifyProjectDT.subscribe("rowMouseoverEvent", notifyProjectDT.onEventHighlightRow);
                notifyProjectDT.subscribe("rowMouseoutEvent", notifyProjectDT.onEventUnhighlightRow);

                 var onContextMenuClick = function(p_sType, p_aArgs, p_notifyProjectDT) {
                    var task = p_aArgs[1];

                  if(task) {

                        var elRow = this.contextEventTarget;
                        elRow = p_notifyProjectDT.getTrEl(elRow);

                        notifyProjectDT2=p_notifyProjectDT;
                        elRow2=elRow;
                        if(elRow) {
                            switch(task.index) {
                            case 0:     // Delete row upon confirmation
                                    var oRecord = p_notifyProjectDT.getRecord(elRow);
                                    removeNotification(oRecord.getData("pagekey"),"Stop Notifications",'<%=ar.retPath %>');
                                    //oRecord.setData("istemplate","false");
                                    //templateTable.deleteRow(0);

                            }
                        }
                    }
                };
                var notifyProjectContextMenu = new YAHOO.widget.ContextMenu("notifyProjectContextMenu",
                        {trigger:notifyProjectDT.getTbodyEl()});

                var onBeforeMenuClick = function(){
                    var elRow = this.contextEventTarget;
                    elRow = notifyProjectDT.getTrEl(elRow);
                    var oRecord = notifyProjectDT.getRecord(elRow);
                    notifyProjectContextMenu.clearContent();
                    notifyProjectContextMenu.addItem("Block Notification");
                    notifyProjectContextMenu.render("notifyContainer");
                }



                // Render the ContextMenu instance to the parent container of the DataTable
                notifyProjectContextMenu.render("notifyContainer");
                notifyProjectContextMenu.clickEvent.subscribe(onContextMenuClick, notifyProjectDT);
                notifyProjectContextMenu.beforeShowEvent.subscribe(onBeforeMenuClick, notifyProjectDT);

                return {
                    oDS: notifyProjectDS,
                    oDT: notifyProjectDT
                };
        }();
    });

    function blockAllNotifications(){
        var transaction = YAHOO.util.Connect.asyncRequest('POST', '<%=ar.retPath %>'+"t/handlePersonalSubscriptions.ajax?action=Stop All Notifications", resultNotify);
    }

    var resultNotify = {
        success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    window.location.reload();
                }
                else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
        failure: function(o) {
                    alert("AJAX Error:" +o.responseText);
        }
    }

    function removeNotification(pageId,action,URL){
        var transaction = YAHOO.util.Connect.asyncRequest('POST', URL+"t/handlePersonalSubscriptions.ajax?pageId="+pageId+"&action="+action, result_notifications);
    }
    var result_notifications = {
        success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    window.location.reload();
                }
                else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
        failure: function(o) {
            showErrorMessage("Result", "result_notifications Error:", o.responseText );
        }
    }
</script>