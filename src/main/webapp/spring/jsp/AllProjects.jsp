<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserHome.jsp"
%><%

    List<NGBook> bookList = (List<NGBook>) request.getAttribute("bookList");

    String bookKey = ar.defParam("bookKey",null);
    String projectName = ar.defParam("projectName","");
%>
<div class="content tab03" style="display:block;">
    <div class="section_body">
    <%
    if(bookList!=null && bookList.size()<1){
    %>
       <div class="guideVocal">
           User has not created any projects, and does not have any access to sites to create one in.
           <br/>
           When a user create projects, they will be listed here.<br/>
           <br/>
           In order to create a project, you need to be an "Owner" or an "Executive" of an "Site".<br/>
           <br/>
           Use <button class="inputBtn" onClick="location.href='userAccounts.htm'">Settings &gt; Sites</button>
           to view your sites, or request a new site from the system administrator.
           If approved you will be the owner of that new site,
           and can create new projects within it.

       </div>
    <%
    }
    %>
    <br>
        <div class="generalHeadingBorderLess">List of Projects</div>
        <%
        Vector v = NGPageIndex.getAllPagesForAdmin(uProf);
        if(v.size()==0){
        %>
        <p>You have not created any projects yet.</p>
        <%
        }
        else{
        %>
        <div id="pagingProjects"></div>
        <div id="containerProjects">
            <table id="projectslist">
                <thead>
                    <tr>
                        <th>No</th>
                        <th>Project Name</th>
                        <th>Last Modified</th>
                        <th>Comment</th>
                        <th style="display:none">Page N</th>
                        <th style="display:none"><fmt:message key="nugen.userhome.PageKey"/></th>
                        <th style="display:none">found</th>
                        <th style="display:none">timediff</th>
                    </tr>
                </thead>
                <tbody>
        <%
            int size = v.size();
            Enumeration en1 = v.elements();
            for (int i=0; en1.hasMoreElements(); i++)
            {
                NGPageIndex ngpi = (NGPageIndex)en1.nextElement();
                String linkAddr = ar.retPath + "t/" +ngpi.pageBookKey+"/"+ngpi.containerKey + "/history.htm";
                String rowStyleClass="";
                if(i%2 == 0){
                 rowStyleClass = "tableBodyRow odd";
                }else{
                 rowStyleClass = "tableBodyRow even";
                }
        %>
                    <tr>
                        <td>
                            <%=(i+1)%>
                        </td>
                        <td>
                            <a href="<%writeHtml(out, linkAddr);%>" title="navigate to the page"><%writeHtml(out, ngpi.containerName);%></a>
                        </td>
                        <td>
                            <%SectionUtil.nicePrintTime(out, ngpi.lastChange, ar.nowTime);%>
                        </td>
                        <td>
            <%
                if (ngpi.isOrphan())
                {
                    out.write("Orphaned");
                }
                else if (ngpi.requestWaiting)
                {
                    out.write("Pending Requests");
                }
            %>

                        </td>
                        <td style='display:none'><%ar.writeHtml(ngpi.containerName); %></td>
                        <td style='display:none'><%ar.writeHtml(ngpi.containerKey); %></td>
                        <td style='display:none'><%= uProf.findTemplate(ngpi.containerKey)%></td>
                        <td style='display:none'><%= (ar.nowTime - ngpi.lastChange)/1000%></td>
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
</div>
<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var projectColumnDefs = [
                {key:"no",width:5,label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                {key:"pagename",label:"Project Name", sortable:true,sortOptions:{sortFunction:sortNames},resizeable:true},
                {key:"lastmodified",label:"Last Modified", sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"comments",label:"Comments",sortable:true, resizeable:true},
                {key:"pagenameHidden",label:"Page N", sortable:true,resizeable:true,hidden:true},
                {key:"pagekey",label:"<fmt:message key='nugen.userhome.PageKey'/>", sortable:true,resizeable:true,hidden:true},
                {key:"istemplate",label:"istemplate",sortable:true, resizeable:true,hidden:true},
                {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
            ];

            var projectsDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("projectslist"));
            projectsDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            projectsDS.responseSchema = {
                fields: [{key:"no", parser:"number"},
                        {key:"pagename"},
                        {key:"lastmodified"},
                        {key:"comments"},
                        {key:"pagenameHidden"},
                        {key:"pagekey"},
                        {key:"istemplate"},
                        {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
            };
            paginator =  new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers   : 'pagingProjects'
                })
            var projectsConfigs = {
                paginator: paginator,
                initialRequest: "results=999999"
            };



            var projectsDT = new YAHOO.widget.DataTable("containerProjects", projectColumnDefs, projectsDS, projectsConfigs,
            {caption:"",sortedBy:{key:"no",dir:"desc"}});

            // Enable row highlighting
            projectsDT.subscribe("rowMouseoverEvent", projectsDT.onEventHighlightRow);
            projectsDT.subscribe("rowMouseoutEvent", projectsDT.onEventUnhighlightRow);

             var onContextMenuClick = function(p_sType, p_aArgs, p_projectsDT) {
                var task = p_aArgs[1];

                if(task) {
                    var elRow = this.contextEventTarget;
                    elRow = p_projectsDT.getTrEl(elRow);

                    projectsDT2=p_projectsDT;
                    elRow2=elRow;
                    if(elRow) {
                        switch(task.index) {
                        case 0:     // Delete row upon confirmation
                            var oRecord = p_projectsDT.getRecord(elRow);

                            if(trim(oRecord.getData("istemplate")) == "true"){
                                markTemplate(oRecord.getData("pagekey"),'removeTemplate','<%=ar.retPath %>');
                            }else{
                                markTemplate(oRecord.getData("pagekey"),'MarkAsTemplate','<%=ar.retPath %>');
                            }
                        }
                    }
                }
            };
            var projectContextMenu = new YAHOO.widget.ContextMenu("projectContextMenu",
                    {trigger:projectsDT.getTbodyEl()});

            var onBeforeMenuClick = function(){
                var elRow = this.contextEventTarget;
                elRow = projectsDT.getTrEl(elRow);
                var oRecord = projectsDT.getRecord(elRow);
                projectContextMenu.clearContent();
                if(trim(oRecord.getData("istemplate")) == "true"){
                    projectContextMenu.addItem("Stop using as Template");
                }else{
                    projectContextMenu.addItem("Mark as Template");
                }
                 projectContextMenu.render("containerProjects");
            }



            // Render the ContextMenu instance to the parent container of the DataTable
            projectContextMenu.render("containerProjects");
            projectContextMenu.clickEvent.subscribe(onContextMenuClick, projectsDT);
            projectContextMenu.beforeShowEvent.subscribe(onBeforeMenuClick, projectsDT);
            return {
                oDS: projectsDS,
                oDT: projectsDT
            };
        }();
    });

    var projectName = '<%=UtilityMethods.quote4JS(projectName)%>';
    if(projectName!="" && projectName!=null){
        document.getElementById("projectname").value = projectName;
        updateVal();
    }

    function isProjectExist(){
        var projectName = document.getElementById('projectname').value;
        var acct = document.getElementById('accountId');
        var accountId = acct.options[acct.selectedIndex].value;
        var transaction = YAHOO.util.Connect.asyncRequest('POST',"isProjectExist.ajax?projectname="+projectName+"&accountId="+accountId, projectValidationResponse);
        return false;
    }

    function markTemplate(pageId,action,URL){
        var transaction = YAHOO.util.Connect.asyncRequest('POST', URL+"t/markAsTemplate.ajax?pageId="+pageId+"&action="+action, resultMarkTemplate);
    }
    var resultMarkTemplate = {
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
                alert("markAsTemplate.ajax Error:" +o.responseText);
        }
    }

</script>
