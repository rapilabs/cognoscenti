<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserHome.jsp"
%><%
    boolean noneFound = (templates.size()==0);

%>
<div class="content tab04" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="pagingTemplate"></div>
        <div id="templateDiv">
        <%
            if (noneFound) {
        %>
            <div class="guideVocal">You have not specified any templates.<br/>
                <br/>
                Templates are references to normal projects.  When you
                create a new project, you can specify a template, and all the goals
                and roles are copied (empty & unstarted) into the new project.
                This is a convenient way to 'prime' a project with the normal tasks
                and roles that you need. <br/>
                <br/>
                If you visit a project which has a good form, and you might want to use it
                in the future as a template, on that project go the "Project Settings>Personal" page,
                and choose to remember the project as a template.  Then that project will appear here
                and in other places where you can use a template, such as at the time that you
                create a new project.<br/>
                </div>
        <%  }
            else {
        %>
            <table id="templatelist">
                <thead>
                    <tr>
                        <th>No</th>
                        <th><fmt:message key="nugen.userhome.Name"/></th>
                    </tr>
                </thead>
                <tbody>
            <%
            int count = 0;
            if (templateList != null)
            {

                for (NGPageIndex ngpi : templates)
                {
                    String linkAddr = ar.retPath + "t/" +ngpi.pageBookKey+"/"+ngpi.containerKey + "/projectHome.htm";
            %>
                    <tr>
                        <td><%=++count %></td>
                        <td>
                            <a href="<%ar.writeHtml(linkAddr);%>"
                                title="navigate to the template page">
                                <%ar.writeHtml(ngpi.containerName); %>
                            </a>

                            <!--<%ar.writeHtml(ngpi.containerName); %>-->
                        </td>
                    </tr>
            <%
                }
            }
        %>
                </tbody>
            </table>
        <%  }
        %>
        </div>
    </div>
</div>

<% if (!noneFound) { %>

<script type="text/javascript">
    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var templateColumnDefs = [
                {key:"no",label:"No",sortable:true,resizeable:true},
                {key:"templatename",label:"<fmt:message key='nugen.userhome.Name'/>", sortable:true,resizeable:true}
            ];

            var templateDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("templatelist"));
            templateDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            templateDataSource.responseSchema = {
                fields: [{key:"no"},
                        {key:"templatename"}
                        ]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers   : 'pagingTemplate'
                }),
                initialRequest: "results=999999"
            };


            var templateTable = new YAHOO.widget.DataTable("templateDiv", templateColumnDefs, templateDataSource, oConfigs,
            {caption:"",sortedBy:{key:"templatename",dir:"desc"}});

            // Enable row highlighting
            templateTable.subscribe("rowMouseoverEvent", templateTable.onEventHighlightRow);
            templateTable.subscribe("rowMouseoutEvent", templateTable.onEventUnhighlightRow);

            return {
                oDS: templateDataSource,
                oDT: templateTable
            };
        }();
    });
</script>

<% } %>
