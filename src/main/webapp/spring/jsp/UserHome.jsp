<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.IDRecord"
%><%@page import="org.socialbiz.cog.NotificationRecord"
%><%@page import="org.socialbiz.cog.RssServlet"
%><%@page import="org.socialbiz.cog.SectionWiki"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@page import="org.socialbiz.cog.ValueElement"
%><%@page import="org.socialbiz.cog.WatchRecord"
%><%@page import="org.springframework.context.ApplicationContext"
%>
<head>
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
</head>
<%!String pageTitle = "";%><%

    request.setCharacterEncoding("UTF-8");
    UserProfile  uProf =(UserProfile)request.getAttribute("userProfile");
    ApplicationContext context = (ApplicationContext)request.getAttribute("messages");

    List templateList = uProf.getTemplateList();

    Vector<NGPageIndex> templates = new Vector();
    if (templateList != null)
    {
        Hashtable visitDate = new Hashtable();

        for(int i=0;i<templateList.size();i++){
            TemplateRecord tr = (TemplateRecord)templateList.get(i);
            String pageKey = tr.getPageKey();
            NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(pageKey);
            if (ngpi!=null)
            {
                templates.add(ngpi);
                visitDate.put(ngpi.containerKey, new Long(tr.getLastSeen()));
            }
        }

        NGPageIndex.sortInverseChronological(templates);
    }

%>
<script>
        var specialSubTab = '<fmt:message key="${requestScope.subTabId}"/>';

        var tab0_userProjects = '<fmt:message key="nugen.userprojects.subtab.watched.project"/>';
        var tab1_userProjects = '<fmt:message key="nugen.userprojects.subtab.notified.project"/>';
        var tab2_userProjects = '<fmt:message key="nugen.userprojects.subtab.all.projects"/>';
        var tab3_userProjects = '<fmt:message key="nugen.userprojects.subtab.templates"/>';

    </script>
<body class="yui-skin-sam">
    <!-- for the tab view -->
    <div id="container">
        <div>
            <ul id="subTabs" class="menu">

            </ul>
        </div>
        <script>
            createSubTabs("_userProjects");
        </script>
    </div>

    <!-- Display the search results here -->
    <script type="text/javascript">

    var flag = false;
    var projectNameRequiredAlert = '<fmt:message key="nugen.project.name.required.error.text"/>';
    var projectNameTitle = '<fmt:message key="nugen.project.projectname.textbox.text"/>';

    function trim(s) {
        var temp = s;
        return temp.replace(/^s+/,'').replace(/s+$/,'');
    }

    var paginator;
    var d = document;

    var projectValidationResponse ={
            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "no"){
                    document.forms["projectform"].submit();
                }
                else{
                    showErrorMessage("Result", json.msg, json.comments);
                }
            },
            failure: function(o) {
                alert("projectValidationResponse Error:" +o.responseText);
            }
    }

    var sortVisitedDates = function(a, b, desc) {
        if(!YAHOO.lang.isValue(a)) {
            return (!YAHOO.lang.isValue(b)) ? 0 : 1;
        }
        else if(!YAHOO.lang.isValue(b)) {
            return -1;
        }
        var comp = YAHOO.util.Sort.compare;
        var compState = comp(a.getData("visitedTimePeriod"), b.getData("visitedTimePeriod"), desc);
        return compState;
    };

    var WatchedProjectDT2;
    var elRow2;
    var nameFormater = function(elCell, oRecord, oColumn, sData)
       {
           elCell.innerHTML = "<a href='<%=ar.retPath%>t/"+oRecord.getData("pageBookKey")+"/"+oRecord.getData("pagekey")+"/projectHome.htm' "+
                              "  title=\"navigate to the watched page\">" + oRecord.getData("name") + "</a>";
       };

    function deleteRow(){
        WatchedProjectDT2.deleteRow(elRow2);
    }

    var sortNames = function(a, b, desc) {
        if(!YAHOO.lang.isValue(a)) {
            return (!YAHOO.lang.isValue(b)) ? 0 : 1;
        }
        else if(!YAHOO.lang.isValue(b)) {
            return -1;
        }
        var comp = YAHOO.util.Sort.compare;
        var compState = comp(a.getData("pagenameHidden"), b.getData("pagenameHidden"), desc);
        return compState;
    };

    </script>
</body>
<%@ include file="functions.jsp"%>
