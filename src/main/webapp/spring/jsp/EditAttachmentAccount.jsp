<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.List"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameters:

    1. accountId : This is the id of an project and here it is used to retrieve NGBook (Site's Details).
    2. aid : This is document/attachment id which is used to get information of the attachment being downloaded.

*/

    String accountId   = ar.reqParam("accountId");
    String aid      = ar.reqParam("aid");

    ar.assertLoggedIn("Can't edit an attachment.");

    UserProfile uProf = ar.getUserProfile();
    NGContainer ngp = NGPageIndex.getContainerByKeyOrFail(accountId);
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

%>
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
    <%!
        String pageTitle="";
    %>
    <%
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
                    <ul id="subTabs" class="menu"></ul>
                </div>
                <script>
                    createAccountSubTabs("_editDoc");
                </script>
                <input type="hidden" name="aid" id="aid" value="<%ar.writeHtml(aid); %>">
</body>

    <script type="text/javascript">
        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"version",label:"Version",sortable:true, sortOptions:{sortFunction:sortDates}, resizeable:true},
                    //{key:"author",label:"Author",sortable:true,resizeable:true},
                    {key:"modifiedDate",label:"Modified Date",sortable:true,resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("attachVersionTable"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"version"},
                            //{key:"author"},
                            {key:"modifiedDate"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200
                    }),
                    initialRequest: "results=999999"
                };


                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"version",dir:"modifiedDate"}});

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });

    </script>
