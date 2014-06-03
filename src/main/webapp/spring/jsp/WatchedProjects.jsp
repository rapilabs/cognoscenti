<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserHome.jsp"
%><%
    Vector<WatchRecord> watchList = uProf.getWatchList();
    boolean noneFound = watchList.size()==0;

%>
<div class="content tab01" style="display:block;" >
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="pagingWatchedProject"></div>
        <div id="watchedProjectContainer">
        <%
            if (noneFound) {
        %>
            <div class="guideVocal">You are not watching any projects.<br/>
                <br/>
                As you visit projects, go to the "Project Settings>Personal" page, and choose
                to watch the project.  Then that project will appear here.  It is a convenient
                way to keep track of the projects that you are currently working on.<br/>
                <br/>
                Later, when you are no longer interested, it is easy to stop watching a project.</div>
        <%  }
            else {
        %>
            <table id="watchedProjectList">
                <thead>
                    <tr>
                        <th><fmt:message key="nugen.userhome.Name"/></th>
                        <th><fmt:message key="nugen.userhome.MostRecentChange"/></th>
                        <th><fmt:message key="nugen.userhome.Visited"/></th>
                        <th style="display:none"><fmt:message key="nugen.userhome.PageKey"/></th>
                        <th style="display:none">timePeriod</th>
                        <th style="display:none">PageBookKey</th>
                        <th style="display:none">visitedTimePeriod</th>
                    </tr>
                </thead>
                <tbody>
            <%
                Hashtable visitDate = new Hashtable();
                Vector<NGPageIndex> watchedProjects = new Vector<NGPageIndex>();
                for (WatchRecord wr : watchList)
                {
                    String pageKey = wr.getPageKey();
                    NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(pageKey);
                    if (ngpi!=null)
                    {
                        watchedProjects.add(ngpi);
                        visitDate.put(ngpi.containerKey, new Long(wr.getLastSeen()));
                    }
                }

                NGPageIndex.sortInverseChronological(watchedProjects);
                int count=0;
                for (NGPageIndex ngpi : watchedProjects)
                {
                    String rowStyleClass="";
                    if(count%2 == 0){
                        rowStyleClass = "tableBodyRow odd";
                    }
                    else{
                        rowStyleClass = "tableBodyRow even";
                    }
                    ar.write("\n<tr>\n  <td>");
                    ar.writeHtml(ngpi.containerName);
                    long changeTime = ngpi.lastChange;
                    ar.write("</td>\n  <td>");
                    SectionUtil.nicePrintTime(ar.w, changeTime, ar.nowTime);
                    ar.write("</td>\n  <td>");
                    Long lastSeen = (Long) visitDate.get(ngpi.containerKey);
                    SectionUtil.nicePrintTime(ar.w, lastSeen.longValue(), ar.nowTime);
                    ar.write("</td>\n  <td style='display:none'>");
                    ar.writeHtml(ngpi.containerKey);
                    ar.write("</td>");
                    ar.write("\n  <td>");
                    ar.write(String.valueOf(ar.nowTime-changeTime));
                    ar.write("</td>");
                    ar.write("\n  <td>");
                    ar.writeHtml(ngpi.pageBookKey);
                    ar.write("</td>");
                    ar.write("\n  <td>");
                    ar.write(String.valueOf(ar.nowTime-lastSeen.longValue()));
                    ar.write("</td>");
                    ar.write("\n</tr>");
                    count++;
                }
            %>
                </tbody>
            </table>
        <%
            }
        %>
        </div>
    </div>
</div>

<% if (!noneFound) { %>

<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var WatchedProjectColumn = [
                {key:"name",label:"<fmt:message key='nugen.userhome.Name'/>",sortable:true,formatter:nameFormater,resizeable:true},
                {key:"recent",label:"<fmt:message key='nugen.userhome.MostRecentChange'/>", sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"visited",label:"<fmt:message key='nugen.userhome.Visited'/>", sortable:true,sortOptions:{sortFunction:sortVisitedDates},resizeable:true},
                {key:"pagekey",label:"<fmt:message key='nugen.userhome.PageKey'/>", sortable:true,resizeable:true,hidden:true},
                {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true, hidden:true},
                {key:"pageBookKey",label:"PageBookKey",sortable:true, resizeable:true, hidden:true},
                {key:"visitedTimePeriod",label:"visitedTimePeriod",sortable:true, resizeable:true, hidden:true}
            ];

            var WatchedProjectDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("watchedProjectList"));
            WatchedProjectDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            WatchedProjectDS.responseSchema = {
                fields: [{key:"name"},
                        {key:"recent"},
                        {key:"visited"},
                        {key:"pagekey"},
                        {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber},
                        {key:"pageBookKey"},
                        {key:"visitedTimePeriod", parser:YAHOO.util.DataSource.parseNumber}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers: 'pagingWatchedProject'
                }),
                initialRequest: "results=999999"
            };


            var WatchedProjectDT = new YAHOO.widget.DataTable("watchedProjectContainer", WatchedProjectColumn, WatchedProjectDS, oConfigs,
            {caption:"",sortedBy:{key:"name",dir:"desc"}});

            // Enable row highlighting
            WatchedProjectDT.subscribe("rowMouseoverEvent", WatchedProjectDT.onEventHighlightRow);
            WatchedProjectDT.subscribe("rowMouseoutEvent", WatchedProjectDT.onEventUnhighlightRow);

            var onContextMenuClick = function(p_sType, p_aArgs, p_WatchedProjectDT) {
                var task = p_aArgs[1];
              if(task) {
                    // Extract which TR element triggered the context menu
                    var elRow = this.contextEventTarget;
                    elRow = p_WatchedProjectDT.getTrEl(elRow);
                    WatchedProjectDT2=p_WatchedProjectDT;
                    elRow2=elRow;
                    var oRecord = p_WatchedProjectDT.getRecord(elRow);
                    if(elRow) {
                        switch(task.index) {
                        case 0:     // Delete row upon confirmation

                                if(confirm("Are you sure you want to Stop Watching " +
                                    oRecord.getData("fullName") +" Project?")) {
                                    ajaxChangeWatching(oRecord.getData("pagekey"),'Stop Watching','<%=ar.retPath%>');
                                }
                        }
                    }
                }
            };

            var WatchedProjectCM = new YAHOO.widget.ContextMenu("WatchedProjectCM",
                    {trigger:WatchedProjectDT.getTbodyEl()});
            WatchedProjectCM.addItem("Stop Watching");
            // Render the ContextMenu instance to the parent container of the DataTable
            WatchedProjectCM.render("watchedProjectContainer");
            WatchedProjectCM.clickEvent.subscribe(onContextMenuClick, WatchedProjectDT);

            return {
                oDS: WatchedProjectDS,
                oDT: WatchedProjectDT
            };
        }();
    });
</script>
<% } %>
