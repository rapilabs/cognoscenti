<%@page import="org.springframework.context.ApplicationContext"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameters:

    1. pageId : This is the id of a Project and here it is used to retrieve NGPage.

*/

    String pageId = ar.reqParam("pageId");

%><%
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);
    ar.setPageAccessLevels(ngp);
    UserProfile uProf = ar.getUserProfile();
%><%!
        String pageTitle="";
%>
<body class="yui-skin-sam">
    <div>
        <div class="generalArea">
            <div class="pageHeading">Project Stream</div>
            <div class="pageSubHeading">You can view all the latest updates on the project.</div>
            <div class="generalSettings">
                <table>
        <%

        // use this hashtable for "name" lookup.
        List<HistoryRecord> histRecs = ngp.getAllHistory();
        int i=0;
        for (HistoryRecord history : histRecs)
        {
            i++;
            AddressListEntry ale = new AddressListEntry(history.getResponsible());
            UserProfile responsible = ale.getUserProfile();
            String photoSrc = ar.retPath+"assets/photoThumbnail.gif";
            if(responsible!=null && responsible.getImage().length() > 0){
                photoSrc = ar.retPath+"users/"+responsible.getImage();
            }
        %>
                    <tr>
                        <td class="projectStreamIcons"><img src="<%=photoSrc%>" alt="" width="50" height="50" /></td>
                        <td class="projectStreamText">
            <%
            //dummy link for the sorting purpose.
            ar.write("<a href=\"");
            ar.write(Long.toString(history.getTimeStamp()));
            ar.write("\"></a>");

            //Get Localized string
            NGWebUtils.writeLocalizedHistoryMessage(history, ngp, ar);
            ar.write("<br/>");
            SectionUtil.nicePrintTime(out, history.getTimeStamp(), ar.nowTime);

            %>
                        </td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
        <%
        }
        %>
                </table>
            </div>
            <br/>
        </div>

        <script type="text/javascript">
            YAHOO.util.Event.addListener(window, "load", function()
            {
                YAHOO.example.EnhanceFromMarkup = function()
                {
                    var myColumnDefs = [
                        {key:"context",label:"History", sortable:true,resizeable:true}
                    ];

                    var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("history"));
                    myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                    myDataSource.responseSchema = {
                        fields: [{key:"context"}]
                    };

                    var oConfigs = {
                        paginator: new YAHOO.widget.Paginator({
                            rowsPerPage: 200
                        }),
                        initialRequest: "results=999999",
                        sortedBy : {key:"context", dir:YAHOO.widget.DataTable.CLASS_DESC}
                    };


                    var myDataTable = new YAHOO.widget.DataTable("historydiv", myColumnDefs, myDataSource, oConfigs);

                    return {
                        oDS: myDataSource,
                        oDT: myDataTable
                    };
                }();
            });
        </script>
</div>
</body>
