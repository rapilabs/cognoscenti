<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/attachment_forms.jsp"
%><%
    String encodedLoginMsg = URLEncoder.encode("Can't open form","UTF-8");
    String encodedDeleteMsg = URLEncoder.encode("Can't delete attachment","UTF-8");
%>
<div class="pageHeading">Deleted Documents</div>
<div class="pageSubHeading">Old documents marked as 'deleted' can be accessed from this page.</div>

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
    <form name="attachmentForm" id="attachmentForm" action="editDocumentForm.htm">
        <div id="paging"></div>
        <div id="listofpagesdiv<%ar.writeHtml(String.valueOf(SectionDef.PUBLIC_ACCESS)); %>">
            <table id="pagelist">
                <thead>
                    <tr>
                        <th >Attachment Name</th>
                        <th ><span class="iconArrowDown">Date</span></th>
                        <th >Comment</th>
                        <th >State</th>
                        <th >Deleted On</th>
                        <th >Deleted By</th>
                        <th style=\"display:none\">AID</th>
                        <th style=\"display:none\">Display Name</th>
                        <th style=\"display:none\">downloadLinkCount</th>
                        <th style=\"display:none\">Version</th>
                        <th style=\"display:none\">Encoded Access Name</th>
                        <th>Date diff</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    deletedAttachmentSectionDisplay(ar,ngp);
                %>
                </tbody>
            </table>
        </div>
        <input type="hidden" name="p" id="p" value="<%ar.writeHtml(ngp.getKey()); %>">
        <input type="hidden" name="aid" id="aid" value="">
    </form>
</div>
        <%
        out.flush();
    %>
</div></div></div>

    <script type="text/javascript">

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
                    {key:"comment",label:"<fmt:message key='nugen.attachment.Comment'/>",sortable:false,resizeable:true},
                    {key:"deletedon",label:"<fmt:message key='nugen.attachment.deletedon'/>",sortable:false,resizeable:true},
                    {key:"deletedby",label:"<fmt:message key='nugen.attachment.deletedby'/>",sortable:false,resizeable:true},
                    {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:false,resizeable:true,hidden:true},
                    {key:"aid",label:"AID",sortable:false,resizeable:true,hidden:true},
                    {key:"displayName",label:"Display Name",sortable:false,resizeable:false,hidden:true},
                    {key:"downloadLinkCount",label:"downloadLinkCount",sortable:false,resizeable:false,hidden:true},
                    {key:"version",label:"version",sortable:false,resizeable:false,hidden:true},
                    {key:"encodedAccessName",label:"Encoded Access Name",sortable:false,resizeable:false,hidden:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [{key:"attachmentName", parser:YAHOO.util.DataSourceBase.parseString},
                            {key:"date"},
                            {key:"comment"},
                            {key:"deletedon"},
                            {key:"deletedby"},
                            {key:"state"},
                            {key:"aid"},
                            {key:"displayName"},
                            {key:"downloadLinkCount"},
                            {key:"version"},
                            {key:"encodedAccessName"},
                            {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers: 'paging'
                    }),
                    initialRequest: "sort=date&results=999999"

                };


                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv1", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"date",dir: YAHOO.widget.DataTable.CLASS_ASC
                }});

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
                                            var transaction = YAHOO.util.Connect.asyncRequest('POST', '<%=ar.retPath%>t/unDeleteAttachment.ajax?containerId=<%ar.writeHtml(ngp.getKey()); %>&aid='+oRecord.getData("aid"), handleUndeleteAction);
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
                                   [
                                   { text: "Undelete Attachment"}                                       ]
                                ]);

                // Render the ContextMenu instance to the parent container of the DataTable
                myContextMenu.render("listofpagesdiv1");
                myContextMenu.clickEvent.subscribe(onContextMenuClick, myDataTable);

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });
        var downloadAttachmentFormater = function(elCell, oRecord, oColumn, sData)
        {
            elCell.innerHTML = '<a id="downloadLink'
                                + oRecord.getData("downloadLinkCount")
                                + '" href="docinfo'
                                + oRecord.getData("aid") +'.htm?version='
                                + oRecord.getData("version")
                                + '"  title=\"Access the content of this attachment\">'
                                + oRecord.getData("attachmentName") + '</a>';
        };
    </script>


<%!
    public void deletedAttachmentSectionDisplay(AuthRequest ar, NGContainer ngp) throws Exception
    {
        UserProfile up = ar.getUserProfile();
        this.ngp = ngp;
        List<HistoryRecord> histRecs = ngp.getAllHistory();
        int count = 0;
        for(AttachmentRecord attachment : ngp.getAllAttachments()) {
            if (!attachment.isDeleted()) {
                continue;
            }
            writeAttachment(attachment,ar,histRecs,count);
            count++;
        }
    }

%>
