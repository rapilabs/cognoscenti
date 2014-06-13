<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.List"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*
Required parameters:

    1. pageId : This is the id of an project and here it is used to retrieve NGPage (Project's Details).
    2. aid : This is document/attachment id which is used to get information of the attachment being downloaded.

*/

    String pageId   = ar.reqParam("pageId");
    String aid      = ar.reqParam("aid");%>
    <script>
        function trim(s) {
            var temp = s;
            return temp.replace(/^s+/,'').replace(/s+$/,'');
        }

        function check(id, label){
            var val = "";
            if(document.getElementById(id) != null){
                val = trim(document.getElementById(id).value);
                if(val == ""){
                    alert(label+" field is empty.");
                    return false;
                }else{
                    return true;
                }
            }
            return false;
        }
    </script>
    <%!String pageTitle="";%>
    <%
        UserProfile uProf = ar.getUserProfile();
            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);

            AttachmentRecord attachment = ngp.findAttachmentByID(aid);

            if (attachment == null) {
        throw new NGException("nugen.exception.attachment.not.found", new Object[]{aid});
            }


            String name     = attachment.getDisplayName();
            String type     = attachment.getType();
            String comment  = attachment.getComment();
            String fname    = attachment.getStorageFileName();
            String muser    = attachment.getModifiedBy();
            long   mdate    = attachment.getModifiedDate();

            if (type.length() == 0)  { throw new ProgramLogicError("Attachment type should never be empty"); }
            boolean isURL = (type.equals("URL"));
            boolean isFile = !isURL;


            pageTitle = ngp.getFullName() + " / "+ attachment.getNiceNameTruncated(48);

            NGBook ngb = ngp.getSite();
    %>
    <script>

        function enableFileBrowserControl()
        {
            if (document.attachmentForm.chgFile.checked == true)
            {
                document.attachmentForm.fname.disabled = true;
            }
            else
            {
                document.attachmentForm.fname.disabled = false;
            }
        }
        var specialSubTab = '<fmt:message key="${requestScope.subTabId}"/>';
        var tab0_edit_attachments ='<fmt:message key="nugen.projectdocument.subtab.attachmentdetails"/>';
        var tab1_edit_attachments = '<fmt:message key="nugen.projectdocument.subtab.fileversions"/>';
        var retPath ='<%=ar.retPath%>';
        var aid = '<%=aid%>'
    </script>

<body class="yui-skin-sam">
    <div id="mainContent">
        <div class="generalArea">
            <div class="generalContent">
                <div id="container">
                    <ul id="subTabs" class="menu">
                    </ul>
                 <script>
                    createSubTabs("_editDoc");
                 </script>

                 <input type="hidden" name="aid" id="aid" value="<%ar.writeHtml(aid); %>"/>


    <script type="text/javascript">
        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var vlistColumnDefs = [
                    {key:"version",label:"Version",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"modifiedDate",label:"Modified Date",sortable:true,resizeable:true},
                    {key:"fileSize",label:"File Size",sortable:true,resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                    ];

                var vlistDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("attachVersionTable"));
                vlistDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                vlistDataSource.responseSchema = {
                    fields: [
                            {key:"version"},
                            {key:"modifiedDate"},
                            {key:"fileSize"},
                            {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200
                    }),
                    initialRequest: "results=999999"
                };

                var myDataTable = new YAHOO.widget.DataTable("attachVersionList", vlistColumnDefs, vlistDataSource, oConfigs,
                {caption:"",sortedBy:{key:"version",dir:"modifiedDate"}});

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });
        function Cancel(){
            window.location = "attachment.htm";
            return false;
        }
    </script>
