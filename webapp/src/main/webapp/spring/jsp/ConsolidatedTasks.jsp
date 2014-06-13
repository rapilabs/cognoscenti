<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%!
    String pageTitle = "";
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
    <div class="rightDivContent">
    <form method="post" action="RefreshFromRemoteProfiles.form">
    <input type="hidden" name="go" value="<%=ar.getCompleteURL()%>">
    <input type="hidden" name="" value="">
    <img src="<%= ar.retPath%>assets/iconBluePlus.gif" width="13" height="15" alt="" />
    <button type="submit">Refresh</button>
    </form>
    </div>
    <div class="generalHeadingBorderLess">Goals Gathered from Remote Profiles</div>
    <div id="paging5"></div>
    <div id="reminderDiv1">
        <table id="reminderTable1">
            <thead>
                <tr>From</tr>
                <tr>Subject</tr>
                <tr>DueDate</tr>
                <th>Project</th>
                <th>timePeriod</th>
                <th>rid</th>
                <th>projectKey</th>
                <th>bookKey</th>
            </thead>
        <%
            UserPage uPage2 = uProf.getUserPage();

            for (RemoteGoal tr : uPage2.getRemoteGoals())
            {
        %>

            <tr>
                <td><%=BaseRecord.stateImg(tr.getState())%></td>
                <td><%
                    ar.writeHtml(tr.getSynopsis());
                %></td>
                <td><%
                    SectionUtil.nicePrintDate(ar.w, tr.getDueDate());
                %></td>
                <td>ViewRemoteTask.htm?url=<% ar.writeURLData(tr.getAccessURL());%></td>
                <td>4444</td>
                <td><% ar.writeHtml(tr.getProjectName());%></td>
                <td>xx</td>
                <td>xx</td>
            </tr>
        <%

        }
        %>
        </table>



    <!-- Display the search results here -->

    <form name="taskList">
        <input type="hidden" name="filter" value="<%ar.writeHtml(DataFeedServlet.ALLTASKS);%>"/>
    </form>


<script type="text/javascript">

    YAHOO.util.Event.addListener(window, "load", function()
    {

        YAHOO.example.EnhanceFromMarkup = function()
        {
            var myColumnDefs = [
                {key:"State",    label:"State", formatter:stateUrlFormater2, sortable:true,resizeable:true},
                {key:"synopsis", label:"Synopsis", sortable:true, resizeable:true},
                {key:"Page",label:"Project", formatter:pageNameUrlFormater2, sortable:true,resizeable:true},
                {key:"projectName",label:"Project Name",formatter:prjectNameFormater,sortable:true,resizeable:true},
                {key:"DueDate",label:"DueDate",formatter:YAHOO.widget.DataTable.formatDate,sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true},
                {key:"rid",label:"rid",sortable:true,resizeable:false,hidden:true},
                {key:"pageKey",label:"pageKey",sortable:true,resizeable:false,hidden:true},
                {key:"bookKey",label:"bookKey",sortable:true,resizeable:false,hidden:true}
                ];

            var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("reminderTable1"));
            myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            myDataSource.responseSchema = {
                fields: [
                        {key:"StateImg"},
                        {key:"synopsis"},
                        {key:"DueDate"},
                        {key:"PageURL"},
                        {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber},
                        {key:"PageName"},
                        {key:"pageKey"},
                        {key:"bookKey"}]
            };

             var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers: 'paging5'
                }),
                initialRequest: "results=999999"

            };

            var myDataTable = new YAHOO.widget.DataTable("reminderDiv1", myColumnDefs, myDataSource, oConfigs,
            {caption:""});

            myDataTable.sortColumn(myDataTable.getColumn(4));
            return {
                oDS: myDataSource,
                oDT: myDataTable
            };
        }();
    });
    var reminderNameFormater = function(elCell, oRecord, oColumn, sData)
    {
        var name = oRecord.getData("subject");
        var pageKey = oRecord.getData("pageKey");
        var bookKey = oRecord.getData("bookKey");
        var rid = oRecord.getData("rid");
        elCell.innerHTML = '<a href="<%=ar.baseURL%>t/'+bookKey+'/'+pageKey+'/viewEmailReminder.htm?rid='+rid+'" ><div style="color:gray;">'+name+'</a></div>';

    };
    var prjectNameFormater = function(elCell, oRecord, oColumn, sData)
    {
        var name = oRecord.getData("subject");
        var pageKey = oRecord.getData("pageKey");
        var bookKey = oRecord.getData("bookKey");
        var projectName = oRecord.getData("projectName");
        elCell.innerHTML = '<a href="<%=ar.baseURL%>t/'+bookKey+'/'+pageKey+'/public.htm" >'+projectName+'</a>';

    };

    var stateUrlFormater2 = function(elCell, oRecord, oColumn, sData)
    {
        elCell.innerHTML = '<a name="' + oRecord.getData("StateImg") + '" href="'
                            + oRecord.getData("PageURL") + '"  target=\"_blank\" title=\"Access goal details\">'
                            + '<img src="<%=ar.retPath%>assets/images/'
                            + oRecord.getData("StateImg") +'"/></a>';
    };
    var pageNameUrlFormater2 = function(elCell, oRecord, oColumn, sData)
    {
        elCell.innerHTML = '<a name="' + oRecord.getData("PageName") + '" href="<%=ar.retPath%>'
                            + oRecord.getData("PageURL") +
                            'public.htm" target=\"_blank\" title=\"Navigate to project\">'
                            + oRecord.getData("PageName") + '</a>';
    };



</script>
