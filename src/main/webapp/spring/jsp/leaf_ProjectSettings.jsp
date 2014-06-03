<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%@page import="java.util.ArrayList"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@page import="org.socialbiz.cog.dms.ConnectionType"
%><%@page import="org.socialbiz.cog.api.RemoteProject"
%><%@page import="org.socialbiz.cog.api.ProjectSync"
%><%@page import="org.socialbiz.cog.SyncStatus"
%>
<html xmlns="http://www.w3.org/1999/xhtml">
<%
    /*
Required parameter:

    1. pageId : This is the id of a Project and used to retrieve NGPage.

*/

    String p = ar.reqParam("pageId");
    String path = ar.defParam("path",null);
%><%!AuthRequest ar=null;
    String pageTitle="";
    List r=null;%><%
    String activeTab = "active";
    String inactiveTab = "inactive";
    NGPage  ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);

    String[] names = ngp.getPageNames();

    NGBook ngb = ngp.getSite();
    if (ngb==null)
    {
        throw new ProgramLogicError("Logic Error, should never get a null value from getAccount");
    }
    String specialTab = "Project Settings Content";
    List roles = ngp.getAllRoles();

    String pageFullName=ngp.getFullName();
    String bookName =  ngb.getName();
    String pageAddress = ar.getResourceURL(ngp,"projectSettings");

    String pageKey =ngp.getKey();
    boolean isDeleted=ngp.isDeleted();

    if(ngp!=null){
        pageTitle= ngp.getFullName() + " - Settings";
    }

    UserProfile uProf = ar.getUserProfile();

    boolean isTemplate = false;
    int roleListSize = 0;
    if (uProf!=null)
    {
        isTemplate = uProf.findTemplate(pageKey);
        List<RoleRequestRecord> roleRequestRecordList = ngp.getAllRoleRequestByState("Requested",false);
        roleListSize = roleRequestRecordList.size();
    }

    ResourceEntity defaultRemoteFolder = null;
    String selectedfolderSymbol = ar.defParam("selectedFolder", null);

    if (selectedfolderSymbol!=null) {
        defaultRemoteFolder = ar.getUserPage().getResourceFromSymbol(selectedfolderSymbol);
    }
    else {
        defaultRemoteFolder = ngp.getDefRemoteFolder();
    }
    String defConnectionName = null;
    String defUserName = null;
    String defLocation = null;

    if (defaultRemoteFolder!=null) {
        defLocation = defaultRemoteFolder.getFullPath();
        ConnectionType cType = defaultRemoteFolder.getConnection();
        UserProfile defUserProf = UserManager.getUserProfileByKey(cType.getOwnerKey());
        defUserName = defUserProf.getName();
        defConnectionName = cType.getDisplayName();
    }
%>
    <style type="text/css">
        #mycontextmenu ul li {
            list-style:none;
             height:18px;
        }

        .yuimenubaritemlabel,
        .yuimenuitemlabel {
            outline: none;

         }

    </style>
<script type="text/javascript" language = "JavaScript">

    function submitRole(){
        var rolename =  document.getElementById("rolename");

        if(trimme(rolename.value) == ""){
            alert("Please enter Role Name.");
            document.getElementById("rolename").value = "";
            document.getElementById("rolename").focus();
            return false;
        }

    <%
    if(roles!=null){
        Iterator  it=roles.iterator();
        while(it.hasNext()){
            NGRole role = (NGRole)it.next();
            String roleName=role.getName();
    %>
            if(trimme(rolename.value).toLowerCase()== "<%=roleName.toLowerCase()%>"){
                alert("Role Name already exist");
                return false;
            }
    <%
        }
    }%>

        document.getElementById('createRoleForm').submit();
    }


    function cancelRoleRequest(roleName){
        if(confirm("Do you really want to cancel this request?")){
            var transaction = YAHOO.util.Connect.asyncRequest('POST','<%=ar.retPath%>t/approveOrRejectRoleRequest.ajax?pageId=<%ar.writeHtml(p);%>&action=cancel&roleName='+roleName,requestResult)
        }else{
            return false;
        }
    }

    var requestResult = {
        success: function(o) {
            var respText = o.responseText;
            var json = eval('(' + respText+')');
            if(json.msgType == "success"){
                document.getElementById("div_"+json.roleName+"_off").style.display="block";
                document.getElementById("div_"+json.roleName+"_reject").style.display="none";
                document.getElementById("div_"+json.roleName+"_pending").style.display="none";
            }else{
                showErrorMessage("Result", json.msg , json.comments );
            }
        },
        failure: function(o) {
            alert("requestResult Error:" +o.responseText);
        }
    }
</script>
<head>

    <script type="text/javascript" src="<%=ar.baseURL%>jscript/nugen_utils.js"></script>
    <script type="text/javascript" src="<%=ar.baseURL%>jscript/yahoo-dom-event.js"></script>
    <script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/jquery.js"></script>
    <script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/tabs.js"></script>

    <!--script>
        var specialSubTab = '<fmt:message key="${requestScope.subTabId}"/>';

        var tab0_settings = '<fmt:message key="nugen.projectsettings.subtab.personal"/>';
        var tab1_settings = '<fmt:message key="nugen.projectsettings.subtab.Permissions"/>';
        var tab2_settings = '<fmt:message key="nugen.projectsettings.subtab.Admin"/>';
        var tab3_settings = '<fmt:message key="nugen.projectsettings.subtab.role.request"/>(<%=roleListSize%>)';
        var tab4_settings = '<fmt:message key="nugen.projectsettings.subtab.emailRecords"/>';
        var retPath ='<%=ar.retPath%>';

    </script-->

</head>
<body class="yui-skin-sam">
    <!-- Content Area Starts Here -->
    <div class="generalArea">
        <div class="generalContent">
            <!-- Tab Structure Starts Here -->
            <div id="container">
                <div>
                    <ul id="subTabs" class="menu">

                    </ul>
                </div>
                <script>
                 createSubTabs("_settings");
                </script>

    <script language="javascript">
        var time = null;
        var pageChangeTime = null;
        if(document.getElementById('subTime')!=null){
        time = document.getElementById('subTime').value;
        }
        if(document.getElementById('pageChangeTime')!=null){
        pageChangeTime = document.getElementById('pageChangeTime').value;
        }
        if (time>pageChangeTime){
            document.getElementById("01").style.display="";
        }
        else if(time>0){
            document.getElementById("02").style.display="";
        }
        else{
            if(document.getElementById("03")!=null)
                document.getElementById("03").style.display="";
        }
    </script>
