<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/attachment_forms.jsp"
%>
<%
    String encodedLoginMsg = URLEncoder.encode("Can't open form","UTF-8");
    String encodedDeleteMsg = URLEncoder.encode("Can't delete document","UTF-8");

    String allowPub =  ngp.getAllowPublic();


%>


    <div class="pageHeading">List Documents</div>
    <div class="pageSubHeading">
        These documents are attached to this project.
    </div>
<script type="text/javascript">
    var isLoggedIn = "<%=ar.isLoggedIn()%>";
    function onClickAction(flagX){
        <%if(ngp.isFrozen()){%>
            openFreezeMessagePopup();
        <%}else{%>
            if(flagX == "addDocument"){
                document.getElementById("createDocForm").action = "addDocument.htm";
                document.getElementById("createDocForm").submit();
            }else if(flagX == "emailReminder"){
                document.getElementById("createDocForm").action = "emailReminder.htm";
                document.getElementById("createDocForm").submit();
            }else if(flagX == "syncDocuments"){
                document.getElementById("createDocForm").action = "SyncAttachment.htm";
                document.getElementById("createDocForm").submit();
            }else if(flagX == "sendDocsByEmail"){
               openWin('sendDocsByEmail.htm?oid=x');
            }
        <% } %>
    }

</script>
<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/container/assets/skins/sam/container.css">
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/animation/animation-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/container/container-min.js"></script>
<style type="text/css">
    #mycontextmenu ul li {
        list-style:none;
        height:18px;
    }

    .yuimenubaritemlabel,
    .yuimenuitemlabel {
        outline: none;
    }

    .mywidth{ width:100%; }


</style>

<div class="content tab01">

    <form name="createDocForm" id="createDocForm" action="uploadDocument.htm" method="get">
    <%
    if (ar.isMember())
    {

    %>
        <table width="100%">
            <tr>
                <td align="right">
                    <img src="<%=ar.retPath %>assets/iconUpload.png" />
                    <a href="javascript:onClickAction('addDocument')"  title="<fmt:message key='nugen.attachment.button.UploadDocument'/>">
                        <fmt:message key='nugen.attachment.button.UploadDocument'/>
                    </a>&nbsp;&nbsp;
                    <img src="<%=ar.retPath %>assets/images/iconEmailNote.gif" />
                    <a href="javascript:onClickAction('sendDocsByEmail');"  title="<fmt:message key='nugen.attachment.uploadattachment.send.doc.by.email'/>" >
                        <fmt:message key='nugen.attachment.uploadattachment.send.doc.by.email'/>
                    </a>&nbsp;&nbsp;
                    <img src="<%=ar.retPath %>assets/iconSync.gif" />
                    <a href="javascript:onClickAction('syncDocuments')"  title="<fmt:message key='nugen.attachment.uploadattachment.Synchronize'/>">
                         <fmt:message key='nugen.attachment.uploadattachment.Synchronize'/>
                    </a>
                </td>
            </tr>
        </table>
    <%

    }
    %>
    </form>
    <%
    if(!ar.isLoggedIn() && memberDocCount > 0){
    %>
        Note : There is/are <%ar.writeHtml(String.valueOf(memberDocCount)); %> more document(s) but to see
               you must logged in and need to be a member of this (<%ar.writeHtml(ngp.getFullName()); %>)
               project.
    <%
    }
    %>
    <form name="attachmentForm" id="attachmentForm" action="updateAttachment.form" method="post">
       <div id="paging"></div>
       <div id="listofpagesdiv<%ar.writeHtml(String.valueOf(SectionDef.PUBLIC_ACCESS)); %>">
           <table id="pagelist">
               <thead>
                    <tr>
                       <th >Attachment Name</th>
                       <th ><span class="iconArrowDown">Date</span></th>
                       <th >Permission</th>
                       <th >Type</th>
                       <th style=\"display:none\">isLinked</th>
                       <th >Comment</th>
                       <th >State</th>
                       <th style=\"display:none\">AID</th>
                       <th style=\"display:none\">Display Name</th>
                       <th style=\"display:none\">downloadLinkCount</th>
                       <th style=\"display:none\">Version</th>
                       <th style=\"display:none\">Encoded Access Name</th>
                       <th>Date diff</th>
                       <th>Visibility</th>
                       <th style=\"display:none\">Ftype</th>
                       <th style=\"display:none\">Readonly</th>
                   </tr>
               </thead>
               <tbody>
               <%


                   writeAttachmentList(ar, ngp, SectionDef.PUBLIC_ACCESS);
               %>
               </tbody>
           </table>
       </div>
       <input type="hidden" name="p" id="p" value="<%ar.writeHtml(ngp.getKey()); %>">
       <input type="hidden" name="aid" id="aid" value="">
       <input type="hidden" name="actionType" id="actionType" value="">
    </form>
</div>
</div>
</div>
</div>


<script type="text/javascript">
    var myContextMenu = null;
    var attachmentName= "";
    var description = "";
    var version = "";
    var aid= "";
    var go ="";
    // Custom function to sort  Column  by another Column

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var myColumnDefs = [
                {key:"attachmentName",label:"<fmt:message key='nugen.attachment.pagelist.AttachmentName'/>",formatter:downloadAttachmentFormater,sortable:true,resizeable:true},
                {key:"date",label:"<fmt:message key='nugen.attachment.Date'/>",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"permission",label:"<fmt:message key='nugen.attachment.Permission'/>",formatter:permissionFormater,sortable:false,resizeable:true},
                {key:"type",label:"<fmt:message key='nugen.attachment.Type'/>",sortable:false,resizeable:true},
                {key:"isLinked",label:"isLinked",sortable:true,resizeable:false,hidden:true},
                {key:"comment",label:"<fmt:message key='nugen.attachment.Comment'/>",sortable:false,resizeable:true},
                {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:false,resizeable:true,hidden:true},
                {key:"aid",label:"AID",sortable:false,resizeable:true,hidden:true},
                {key:"displayName",label:"Display Name",sortable:false,resizeable:false,hidden:true},
                {key:"downloadLinkCount",label:"ID",sortable:false,resizeable:false,hidden:true},
                {key:"version",label:"version",sortable:false,resizeable:false,hidden:true},
                {key:"encodedAccessName",label:"Encoded Access Name",sortable:false,resizeable:false,hidden:true},
                {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true},
                {key:"visibility",label:"visibility",sortable:true,resizeable:false,hidden:true},
                {key:"ftype",label:"ftype",sortable:true,resizeable:false,hidden:true},
                {key:"readonly",label:"readonly",sortable:true,resizeable:false,hidden:true}
                ];

            var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
            myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            myDataSource.responseSchema = {
                fields: [{key:"attachmentName"},
                        {key:"date"},
                        {key:"permission"},
                        {key:"type"},
                        {key:"isLinked"},
                        {key:"comment" ,width: 80},
                        {key:"state"},
                        {key:"aid"},
                        {key:"displayName"},
                        {key:"downloadLinkCount"},
                        {key:"version"},
                        {key:"encodedAccessName"},
                        {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber},
                        {key:"visibility"},
                        {key:"ftype"},
                        {key:"readonly"}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers: 'paging'
                })
             };

            var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv1", myColumnDefs, myDataSource, oConfigs,
                                                            {
                                                                caption:""
                                                            }
                                                        );

            var onContextMenuClick = function(p_sType, p_aArgs, p_myDataTable) {
                    var task = p_aArgs[1];
                    if(task) {
                      // Extract which TR element triggered the context menu

                        var elRow = this.contextEventTarget;
                        elRow = p_myDataTable.getTrEl(elRow);
                        myDataTable2=p_myDataTable;
                        elRow2=elRow;
                        var oRecord = p_myDataTable.getRecord(elRow);
                        attachmentName = oRecord.getData("displayName");
                        aid = oRecord.getData("aid");
                        description = oRecord.getData("comment");
                        version =  oRecord.getData("version");
                        var visibility = oRecord.getData("visibility");

                        if(elRow) {
                            <% if( !ngp.isFrozen()){ %>
                            if(task.groupIndex==0){
                                switch(task.index) {

                                    case 0:
                                        document.location = '<%=ar.baseURL%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/docinfo'+oRecord.getData("aid") +'.htm?version='+ oRecord.getData("version");
                                        break;
                                    case 1:
                                        if(oRecord.getData("ftype") != 'URL'){
                                            if(isLoggedIn == "false"){
                                                window.location  = "<%=ar.baseURL%>t/EmailLoginForm.htm?&msg=<%ar.writeHtml(encodedLoginMsg);%>&go=<%ar.writeURLData(ar.getCompleteURL());%>";
                                            }else{
                                                if(oRecord.getData("readonly") != 'on')
                                                {
                                                    window.location  = "<%=ar.retPath%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/uploadRevisedDocument.htm?aid="+aid;
                                                }else
                                                {
                                                    alert("Document is read only type and can't be changed.");
                                                }
                                            }
                                        }
                                        break;
                                    case 2:
                                        window.location  = "<%=ar.retPath%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/editDetails"+aid+".htm";
                                        break;
                                    case 3:
                                        if(oRecord.getData("ftype") != 'URL'){
                                            window.location  = "<%=ar.retPath%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/fileVersions.htm?aid="+aid;
                                        }
                                        break;
                                }
                            }else if(task.groupIndex==1){
                                switch( task.index){
                                    case 0:
                                           getRenameForm(aid , attachmentName);
                                           break;
                                    case 1:
                                           getPermissionForm(aid , attachmentName , visibility, '<%=allowPub %>');
                                           break;
                                    case 2:
                                           if(isLoggedIn == "false"){
                                               window.location  = "<%=ar.retPath%>t/EmailLoginForm.htm?&msg=<%ar.writeHtml(encodedDeleteMsg);%>&go=<%ar.writeURLData(ar.getCompleteURL());%>";
                                           }else{
                                            // Delete row upon confirmation
                                                if(confirm("Are you sure you want to remove '" +
                                                    oRecord.getData("displayName") +"' document?")) {

                                                    document.getElementById("aid").value = aid;
                                                    document.getElementById("actionType").value = "Remove";
                                                    document.getElementById("attachmentForm").submit();
                                               }
                                            }
                                           break;
                                    case 3:
                                           if(oRecord.getData("ftype") != 'URL'){
                                               openWin('<%=ar.retPath%>t/sendNoteByEmail.htm?p=<%ar.writeHtml(pageId);%>&oid=x&selectedAttachemnt=attach'+oRecord.getData("aid")+"&encodingGuard=%E6%9D%B1%E4%BA%AC");
                                           }
                                           break;
                                }
                            }else if(task.groupIndex==2){
                                switch( task.index){
                                    case 0:
                                        if(oRecord.getData("ftype") != 'URL'){
                                            onClickAction('addDocument');
                                        }
                                        break;
                                    case 1:
                                        myDataTable.sortColumn(myDataTable.getColumn("attachmentName"));
                                        break;
                                    case 2:
                                        myDataTable.sortColumn(myDataTable.getColumn("date"));
                                        break;
                                    case 3:
                                        if(oRecord.getData("isLinked") == 'true'){
                                            // Unlink Document from repository upon confirmation
                                                if(confirm("Are you sure you want to unlink Document '" +
                                                    oRecord.getData("displayName") +"' document from repository?")) {

                                                    document.getElementById("aid").value = aid;
                                                    document.getElementById("actionType").value = "Unlink";
                                                    document.getElementById("attachmentForm").submit();
                                               }
                                        }else{
                                            document.getElementById("aid").value = aid;
                                            window.location  = "<%=ar.retPath%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/CreateCopy.htm?aid="+aid;
                                            //onClickAction('createCopy');
                                        }
                                        break;
                                }
                            }
                            <%}else{%>
                                if(task.groupIndex==0){
                                    switch(task.index) {

                                        case 0:
                                            document.location = '<%=ar.baseURL%>t/<%ar.writeHtml(ngb.getKey());%>/<%ar.writeHtml(pageId);%>/docinfo'+oRecord.getData("aid") +'.htm?version='+ oRecord.getData("version");
                                            break;
                                    }
                                }else if(task.groupIndex==2){
                                    switch( task.index){
                                        case 0:
                                            openFreezeMessagePopup();
                                            break;
                                        case 1:
                                            myDataTable.sortColumn(myDataTable.getColumn("attachmentName"));
                                            break;
                                        case 2:
                                            myDataTable.sortColumn(myDataTable.getColumn("date"));
                                            break;
                                        case 3:
                                            openFreezeMessagePopup();
                                            break;
                                    }
                                }else{
                                    openFreezeMessagePopup();
                                }
                            <%}%>
                            myDataTable.unselectAllCells();
                        }
                    }
                };

                myContextMenu = new YAHOO.widget.ContextMenu("menuwithgroups",
                    {trigger:myDataTable.getTbodyEl()});

                 // Render the ContextMenu instance to the parent container of the DataTable
                myContextMenu.render("listofpagesdiv1");
                myContextMenu.clickEvent.subscribe(onContextMenuClick, myDataTable);

                myContextMenu.beforeShowEvent.subscribe(onMenuBeforeShow, myContextMenu, true);


                myDataTable.subscribe("cellMouseoverEvent", function(oArgs){
                 var oRecord = this.getRecord(oArgs.target);
                 var column = this.getColumn(oArgs.target);
                 if(column.key != "attachmentName"){
                    return false;
                 }
                 document.getElementById(oRecord.getData("aid")).style.display="";
                });

                myDataTable.subscribe("rowMouseoverEvent", function(oArgs){myDataTable.unselectAllCells();});



                myDataTable.subscribe("cellMouseoutEvent", function(oArgs){
                    var oRecord = this.getRecord(oArgs.target);
                    document.getElementById(oRecord.getData("aid")).style.display="none";
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
                    if(okForContextMenu){
                        myContextMenu.show();
                    }
                    okForContextMenu = true;
                 }
                });

                function onMenuBeforeShow(p_sType, p_sArgs, p_oMenu) {
                    var eRow = myDataTable.getTrEl(this.contextEventTarget);
                    var oRecord = myDataTable.getRecord(eRow);
                       var ftype = oRecord.getData("ftype");
                        if(ftype == 'URL'){
                            myContextMenu.getItems()[0].cfg.setProperty("text", "Access Link URL");
                            myContextMenu.getItems()[1].cfg.setProperty("disabled", true);
                            myContextMenu.getItems()[2].cfg.setProperty("text", "Edit Attachment Details");
                            myContextMenu.getItems()[3].cfg.setProperty("disabled", true);
                            myContextMenu.getItems()[4].cfg.setProperty("text", "Rename Attachment");
                            myContextMenu.getItems()[6].cfg.setProperty("text", "Delete Attachment");
                            myContextMenu.getItems()[7].cfg.setProperty("disabled", true);
                            myContextMenu.getItems()[8].cfg.setProperty("disabled", true);
                        }else{
                            myContextMenu.getItems()[0].cfg.setProperty("text", "Go to download document");
                            myContextMenu.getItems()[1].cfg.setProperty("disabled", false);
                            myContextMenu.getItems()[2].cfg.setProperty("text", "Edit Document Details");
                            myContextMenu.getItems()[3].cfg.setProperty("disabled", false);
                            myContextMenu.getItems()[4].cfg.setProperty("text", "Rename Document");
                            myContextMenu.getItems()[6].cfg.setProperty("text", "Delete Document");
                            myContextMenu.getItems()[7].cfg.setProperty("disabled", false);
                            myContextMenu.getItems()[8].cfg.setProperty("disabled", false);
                            if(oRecord.getData("isLinked") == "true"){
                                myContextMenu.getItems()[11].cfg.setProperty("text", "Unlink Document");
                            }else{
                                myContextMenu.getItems()[11].cfg.setProperty("text", "Push to Repository");
                            }
                        }
                  }

                myDataTable.sortColumn(myDataTable.getColumn(12)); // sorting on timePeriod column
                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            } ();
        });
        var okForContextMenu = true;
        var downloadAttachmentFormater = function(elCell, oRecord, oColumn, sData)
        {
            var href = '';
            var onclick = '';
            if(oRecord.getData("ftype")=='URL'){
                href = '#';
                onclick = 'return handleURIClick(\''+oRecord.getData("encodedAccessName") +'\');';
            }else{
                href = '<%=ar.baseURL%>t/<%=ngb.getKey()%>/<%= ngp.getKey()%>/a/'+oRecord.getData("encodedAccessName");
                onclick = 'return handleClick()';
            }
            elCell.innerHTML = '<a id="downloadLink'+oRecord.getData("downloadLinkCount")
                 + '" href="'+href+'"  title=\"Access the content of this document\" onclick=\"'+onclick+'\">'
                 +'<img src="<%=ar.baseURL%>assets/iconDownload.png"/>'
                 + oRecord.getData("attachmentName") + '</a>';

        };

        var permissionFormater = function(elCell, oRecord, oColumn, sData)
        {
            var val = oRecord.getData("visibility");
            if(val == '1' || val == '3'){
                a = '<a href="editDetails'+oRecord.getData("aid")+'.htm"><img src="<%=ar.baseURL%>assets/images/iconPublic.png"/></a>';
            }else{
                a = '<a href="editDetails'+oRecord.getData("aid")+'.htm"><img src="<%=ar.baseURL%>assets/images/iconMember.png"/></a>';
            }
            var b = '';
            if(val == '4' || val == '3'){
                b = '<img src="<%=ar.baseURL%>assets/images/iconUpstream.png"/>';
            }
            elCell.innerHTML = a+b;
        }
        function handleURIClick(url){
            okForContextMenu = false;
            openWin(url);
            return true;
        }
        function handleClick(){
            okForContextMenu = false;
            return true;
        }
</script>
<div id="menuwithgroups" class="yuimenu">
    <div class="bd">
        <ul class="first-of-type">
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Go to Download Document</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Upload Revised Document</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Edit Document Details</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">List Versions</a></li>
        </ul>
        <ul>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Rename Document</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Make Public / Make Member Only</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Delete Document</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Send Document By Email</a></li>
        </ul>
        <ul>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Upload New Document</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Sort by Name</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Sort by Date</a></li>
            <li class="yuimenuitem"><a class="yuimenuitemlabel">Unlink Document</a></li>
        </ul>
    </div>
</div>

<%!

    public void writeAttachmentList(AuthRequest ar, NGPage ngp, int displayLevel) throws Exception
    {
        UserProfile up = ar.getUserProfile();
        List<NGRole> rolesPlayed = ngp.findRolesOfPlayer(up);
        this.ngp = ngp;
        List<HistoryRecord> histRecs = ngp.getAllHistory();
        boolean canAccessAllDocs = false;
        if (up!=null) {
            canAccessAllDocs = ngp.primaryOrSecondaryPermission(up);
        }
        int count = 0;
        for(AttachmentRecord attachment : ngp.getAllAttachments()) {
            if (attachment.isDeleted()) {
                continue;
            }
            boolean canAccess = canAccessAllDocs;
            for (NGRole ngr : rolesPlayed) {
                if (attachment.roleCanAccess(ngr.getName())) {
                    canAccess = true;
                }
            }
            if (!canAccess) {
                continue;
            }
            writeAttachment(attachment,ar,histRecs,count);
            count++;
        }
    }



%>
