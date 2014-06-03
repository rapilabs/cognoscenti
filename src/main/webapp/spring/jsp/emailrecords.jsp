<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.EmailRecordMgr"
%><%@page import="org.socialbiz.cog.EmailRecord"
%><%@page import="org.socialbiz.cog.EmailRecordMgr"
%><%@page import="org.socialbiz.cog.OptOutAddr"
%>
<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/container/assets/skins/sam/container.css">
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/animation/animation-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/container/container-min.js"></script>

<div class="content tab01">
    <div class="generalSettings">
    <%if (!ar.isLoggedIn())
    {
    %>
    <div class="generalArea">
        <div class="generalContent">
            In order to see this section, you need to be logged in.
        </div>

    </div>
    <%
    }else
    {
    %>

    <div id="paging"></div>
    <div id="listofpagesdiv">
        <table id="pagelist">
            <thead>
                <tr>
                    <th>From</th>
                    <th>Subject</th>
                    <th><fmt:message key="nugen.attachment.pagelist.Recipient"/></th>
                    <th>Status</th>
                    <th>Send Date</th>
                    <th>timePeriod</th>
                    <th>emailId</th>
                </tr>
            </thead>
            <tbody>
            <%


                int emailCount = 0;
                for (EmailRecord eRec : ngp.getAllEmail() )
                {
                    emailCount++;
                    List<OptOutAddr> toList = eRec.getAddressees();
                %>
                    <tr>
                        <td>
                            <%ar.writeHtml(eRec.getFromAddress());%>
                        </td>
                        <td>
                            <%writeHtml(out, eRec.getSubject());%><br/>
                            <%ar.writeHtml(eRec.getExceptionMessage());%>
                        </td>
                        <td>
                        <%
                        int i=0;
                        for (OptOutAddr ooa : toList) {
                            if (i>0) {
                                writeHtml(out, ",");
                            }
                            ooa.getAssignee().writeLink(ar);
                            i++;
                        }
                        %>
                        </td>
                        <td>
                            <%=eRec.getStatus()%>
                        </td>
                        <td>
                            <%SectionUtil.nicePrintTime(out, eRec.getLastSentDate(), ar.nowTime);%>
                        </td>
                        <td><%ar.writeHtml(String.valueOf((ar.nowTime - eRec.getLastSentDate())/1000 ));%></td>
                        <td><%ar.writeHtml(eRec.getId());%></td>
                    </tr>
                <%
                    }

                %>
            </tbody>
        </table>
    </div>
    <%
    }
    %>
    </div>
</div>

    <script type="text/javascript">

        YAHOO.util.Event.addListener(window, "load", function()
        {

            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"from",label:"From",sortable:true,resizeable:true},
                    {key:"subject",label:"Subject",sortable:true,resizeable:true},
                    {key:"recipient",label:"Recipient",sortable:true,resizeable:true},
                    {key:"status",label:"Status",sortable:true,resizeable:true},
                    {key:"sendDate",label:"Send Date",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true},
                    {key:"emailId",label:"emailId",sortable:true,resizeable:false,hidden:true}
                    ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [
                            {key:"from"},
                            {key:"subject"},
                            {key:"recipient"},
                            {key:"status"},
                            {key:"sendDate"},
                            {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber},
                            {key:"emailId"}]
                };

                 var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 100,
                        containers: 'paging'
                    }),
                    initialRequest: "results=999999"

                };

                var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv", myColumnDefs, myDataSource, oConfigs,
                {caption:""});

                myDataTable.sortColumn(myDataTable.getColumn(5));
                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });

    </script>