<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.RssServlet"
%>
<head>
    <!-- for calender -->
    <script language="javascript">
       var userTasks=true;
    </script>
</head>
<%!
    String pageTitle = "";
    String goalListType = "Goals";
%><%
    request.setCharacterEncoding("UTF-8");
    ar.assertLoggedIn("Must be logged in to see anything about a user");

    UserProfile uProf = (UserProfile)request.getAttribute("userProfile");
    if (uProf == null) {
        throw new NGException("nugen.exception.cant.find.user",null);
    }

    UserProfile  operatingUser =ar.getUserProfile();
    if (operatingUser==null) {
        //this should never happen, and if it does it is not the users fault
        throw new ProgramLogicError("user profile setting is null.  No one appears to be logged in.");
    }

    boolean viewingSelf = uProf.getKey().equals(operatingUser.getKey());
    String loggingUserName=uProf.getName();

%>
<body class="yui-skin-sam">
<script type="text/javascript">

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var connectionCallback = {
                    success: function(o) {
                        var xmlDoc = o.responseXML;
                        var stateUrlFormater = function(elCell, oRecord, oColumn, sData)
                        {
                            elCell.innerHTML = '<a name="' + oRecord.getData("StateImg") + '" href="<%=ar.retPath%>'
                                                + oRecord.getData("PageURL") + 'task'
                                                + oRecord.getData("Id") + '.htm"  target=\"_blank\" title=\"View details and modify activity state\">'
                                                + '<img src="<%=ar.retPath%>assets/images/'
                                                + oRecord.getData("StateImg") +'"/></a>';
                        };

                        var pageNameUrlFormater = function(elCell, oRecord, oColumn, sData)
                        {
                            elCell.innerHTML = '<a name="' + oRecord.getData("PageName") + '" href="<%=ar.retPath%>'
                                                + oRecord.getData("PageURL") +
                                                'public.htm" target=\"_blank\" title=\"Navigate to project\">'
                                                + oRecord.getData("PageName") + '</a>';
                        };


                        var assigneeFormater = function(elCell, oRecord, oColumn, sData)
                        {
                            var assignee=oRecord.getData("Assignee") ;
                            var loggingUser=<%=UtilityMethods.quote4JS(loggingUserName)%>;
                            if(assignee!=loggingUser){
                                 elCell.innerHTML =assignee;
                             }
                        };

                        var activeTasksCD = [
                            {key:"State",label:"State", formatter:stateUrlFormater, sortable:true,resizeable:true},
                            {key:"NameAndDescription",label:"Goal", sortable:true,resizeable:true},
                            {key:"Page",label:"Project", formatter:pageNameUrlFormater, sortable:true,resizeable:true},
                            {key:"Assignee",label:"Assignee",sortable:true,resizeable:true,formatter:assigneeFormater},
                            {key:"Priority",label:"Priority",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                            {key:"DueDate",label:"DueDate",formatter:YAHOO.widget.DataTable.formatDate,sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                            {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true}
                        ];

                        var activeTasksDS = new YAHOO.util.DataSource(xmlDoc);
                        activeTasksDS.responseType = YAHOO.util.DataSource.TYPE_XML;
                        activeTasksDS.responseSchema = {
                            resultNode: "Result",

                            fields: [{key:"Id"},
                                     {key:"State", parser:"number"},
                                     {key:"StateImg"},
                                     {key:"NameAndDescription"},
                                     {key:"Assignee"},
                                     {key:"Priority", parser:"number"},
                                     {key:"DueDate"},
                                     {key:"PageKey"},
                                     {key:"PageName"},
                                     {key:"PageURL"},
                                     {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber}
                            ]};

                        var oConfigs = { paginator: new YAHOO.widget.Paginator({rowsPerPage:200,containers:'activeTasksPaging'}), initialRequest:"results=99999999"};

                        var activeTasksDT = new YAHOO.widget.DataTable(
                                          "activeTasksDiv",
                                          activeTasksCD,
                                          activeTasksDS,
                                          oConfigs,
                                          {caption:"",sortedBy:{key:"No",dir:"desc"}}
                                      );

                        var oColumn = activeTasksDT.getColumn(3);
                        activeTasksDT.hideColumn(oColumn);




                    },
                    failure: function(o)
                    {
                        // hide the loading panel.
                        YAHOO.example.activeTasksContainer.wait.hide();
                    }
                };

            var servletURL = "<%=ar.retPath%>servlet/DataFeedServlet?<%ar.writeHtml(DataFeedServlet.PARAM_OPERATION);%>=<%ar.writeHtml(DataFeedServlet.OPERATION_GETTASKLIST);%>"+
                                    "&<%ar.writeHtml(DataFeedServlet.PARAM_TASKLIST);%>="+document.taskList.filter.value+
                                    "&u=<%ar.writeHtml(URLEncoder.encode(uProf.getUniversalId(), "UTF-8"));%>&isNewUI=yes";

            var getXML = YAHOO.util.Connect.asyncRequest("GET",servletURL, connectionCallback);


        }();
    });

</script>

<%@ include file="functions.jsp"%>

    <div class="generalHeadingBorderLess"><%ar.writeHtml(goalListType);%> </div>
        <div class="content tab04" style="display: block;">
            <div class="section_body">
                <div style="height:10px;"></div>
                <div id="activeTaskscontainer">
                    <div id="activeTasksPaging"></div>
                    <div id="activeTasksDiv"></div>
                </div>
            </div>
        </div>
    </div>
