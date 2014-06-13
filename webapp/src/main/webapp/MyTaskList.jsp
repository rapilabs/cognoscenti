<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.DataFeedServlet"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.RssServlet"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%
    ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't retrieve the Task list.");

    String p = ar.defParam("p", "main");
    String u = ar.defParam("u", null);

    uProf = findSpecifiedUserOrDefault(ar);

    String filter = ar.defParam(DataFeedServlet.OPERATION_GETTASKLIST, DataFeedServlet.MYACTIVETASKS);

    String rssLink = "Tasks.rss?user="+ java.net.URLEncoder.encode(uProf.getUniversalId(), "UTF-8");

    pageTitle = "User: "+uProf.getName();
    specialTab = "My Goals";
%>

<%@ include file="Header.jsp"%>

    <!-- for the tab view -->
    <div id="tabSet" class="yui-navset">
        <ul class="yui-nav">
            <li class="selected"><a href="#tab1"><em>My Active Goals</em></a></li>
            <li><a href="#tab2"><em>Completed Goals</em></a></li>
            <li><a href="#tab3"><em>Future Goals</em></a></li>
            <li><a href="#tab4"><em>All Goals</em></a></li>
        </ul>
        <div class="yui-content">
            <div id="tab1"></div>
            <div id="tab2"></div>
            <div id="tab3"></div>
            <div id="tab4"></div>
        </div>
    </div>

    <!-- Display the search results here -->
    <div class="section">
        <div class="section_title">
            <h1 class="left">Goals</h1>
            <div class="post_date right">
                <a href="javascript:invokeRSSLink()"><img src="<%=ar.retPath%>rssicon.png"/></a>
            </div>
            <div class="clearer">&nbsp;</div>
        </div>
        <div class="section_body">
            <div id="searchresultdiv"></div>
            <div id="searchresultdiv"></div>
            <div id="searchresultdiv"></div>
        </div>
    </div>

    <form name="taskList">
        <input type="hidden" name="filter" value="<%=DataFeedServlet.MYACTIVETASKS%>"/>
        <input type="hidden" name="rssfilter" value="<%=RssServlet.STATUS_ACTIVE%>"/>
    </form>

    <script type="text/javascript">
        function invokeRSSLink(link) {
            window.location.href = "<%=ar.retPath + rssLink%>&status=" + document.taskList.rssfilter.value ;
        }
    </script>

    <script type="text/javascript">
        var tabSet = new YAHOO.widget.TabView('tabSet');
        function tabChangeHandler(e)
        {

            var numberOfTabs = tabSet.get("tabs").length;
            var activeIndex  = tabSet.get("activeIndex");

            if (activeIndex == 0) {
                document.taskList.filter.value = '<%=DataFeedServlet.MYACTIVETASKS%>';
                document.taskList.rssfilter.value = '<%=RssServlet.STATUS_ACTIVE%>';
            }
            else if (activeIndex == 1) {
                document.taskList.filter.value = '<%=DataFeedServlet.COMPLETEDTASKS%>';
                document.taskList.rssfilter.value = '<%=RssServlet.STATUS_COMPLETED%>';
            }
            else if (activeIndex == 2) {
                document.taskList.filter.value = '<%=DataFeedServlet.FUTURETASKS%>';
                document.taskList.rssfilter.value = '<%=RssServlet.STATUS_FUTURE%>';
            }
            else if (activeIndex == 3) {
                document.taskList.filter.value = '<%=DataFeedServlet.ALLTASKS%>';
                document.taskList.rssfilter.value = '<%=RssServlet.STATUS_ALL%>';
            }
            // perform the search.
            performSearchAndDisplayResults();

        };
        tabSet.addListener('activeTabChange', tabChangeHandler);
    </script>

    <script type="text/javascript">
        function performSearchAndDisplayResults()
        {
            // for the loading Panel
            YAHOO.namespace("example.container");
            if (!YAHOO.example.container.wait)
            {
                // Initialize the temporary Panel to display while waiting for external content to load
                YAHOO.example.container.wait =
                        new YAHOO.widget.Panel("wait",
                                                { width: "240px",
                                                  fixedcenter: true,
                                                  close: false,
                                                  draggable: false,
                                                  zindex:4,
                                                  modal: true,
                                                  visible: false
                                                }
                                            );

                YAHOO.example.container.wait.setHeader("Loading, please wait...");
                YAHOO.example.container.wait.setBody("<img src=\"<%=ar.retPath%>loading.gif\"/>");
                YAHOO.example.container.wait.render(document.body);
            }
            // Show the loading Panel
            YAHOO.example.container.wait.show();

            // for data table.
            YAHOO.example.Local_XML = function()
            {
                var myDataSource, myDataTable, oConfigs;

                var connectionCallback = {
                    success: function(o) {

                        // hide the loading panel.
                        YAHOO.example.container.wait.hide();
                        //alert(o.responseXML.xml);
                        var xmlDoc = o.responseXML;

                        var stateUrlFormater = function(elCell, oRecord, oColumn, sData)
                        {
                            elCell.innerHTML = "<a name='" + oRecord.getData("StateImg") + "' href='<%=ar.retPath%>WorkItem.jsp?p=" +
                                                encodeURIComponent(oRecord.getData("PageKey")) +
                                                "&s=Tasks&id=" + oRecord.getData("Id") +
                                                "&go=" + encodeURIComponent(oRecord.getData("PageURL")) +
                                                "' target=\"_blank\" title=\"View details and modify activity state\">" +
                                                "<img src='<%=ar.retPath%>" + oRecord.getData("StateImg") +"'/>" +
                                                "</a>";
                        };

                        var pageNameUrlFormater = function(elCell, oRecord, oColumn, sData)
                        {
                            elCell.innerHTML = "<a name='" + oRecord.getData("PageName") + "' href='<%=ar.retPath%>" +
                                                 oRecord.getData("PageURL") +
                                                "' target=\"_blank\" title=\"Navigate to project\">" + oRecord.getData("PageName") + "</a>";
                        };

                        var myColumnDefs = [
                            {key:"No",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                            {key:"State",label:"State", formatter:stateUrlFormater, sortable:true,resizeable:true},
                            {key:"NameAndDescription",label:"Task", sortable:true,resizeable:true},
                            {key:"Page",label:"Project", formatter:pageNameUrlFormater, sortable:true,resizeable:true},
                            {key:"Assignee",label:"Assignee",sortable:true,resizeable:true},
                            {key:"Priority",label:"Priority",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                            {key:"DueDate",label:"DueDate",formatter:YAHOO.widget.DataTable.formatDate,sortable:true,resizeable:true}
                        ];

                        myDataSource = new YAHOO.util.DataSource(xmlDoc);
                        myDataSource.responseType = YAHOO.util.DataSource.TYPE_XML;
                        myDataSource.responseSchema = {
                            resultNode: "Result",

                            fields: [{key:"No", parser:"number"},
                                     {key:"Id"},
                                     {key:"State", parser:"number"},
                                     {key:"StateImg"},
                                     {key:"NameAndDescription"},
                                     {key:"Assignee"},
                                     {key:"Priority", parser:"number"},
                                     {key:"DueDate", parser:"date"},
                                     {key:"StartDate", parser:"date"},
                                     {key:"PageKey"},
                                     {key:"PageName"},
                                     {key:"PageURL"}
                            ]};

                        oConfigs = { paginator: new YAHOO.widget.Paginator({rowsPerPage:200}), initialRequest:"results=99999999"};

                        myDataTable = new YAHOO.widget.DataTable(
                                          "searchresultdiv",
                                          myColumnDefs,
                                          myDataSource,
                                          oConfigs,
                                          {caption:"",sortedBy:{key:"No",dir:"desc"}}
                                      );

                    },
                    failure: function(o)
                    {
                        // hide the loading panel.
                        YAHOO.example.container.wait.hide();
                    }
                };

                var servletURL = "servlet/DataFeedServlet?<%=DataFeedServlet.PARAM_OPERATION%>=<%=DataFeedServlet.OPERATION_GETTASKLIST%>" +
                                    "&<%=DataFeedServlet.PARAM_TASKLIST%>=" + document.taskList.filter.value +
                                    "&u=<%=URLEncoder.encode(uProf.getUniversalId(), "UTF-8")%>";

                var getXML = YAHOO.util.Connect.asyncRequest("GET",servletURL, connectionCallback);

                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        }
    </script>

    <script>
        performSearchAndDisplayResults();
    </script>

<%@ include file="Footer.jsp"%>
<%@ include file="functions.jsp"%>

