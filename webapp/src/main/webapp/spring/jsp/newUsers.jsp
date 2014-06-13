<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@ include file="administration.jsp"
%><%

    ar.assertLoggedIn("New Users page should never be accessed when not logged in");
    if (!ar.isSuperAdmin()) {
        throw new Exception("New Users page should only be accessed by Super Admin");
    }
    List<UserProfile> newUsers = SuperAdminLogFile.getInstance().getAllNewRegisteredUsers();

%>
<div class="content tab04" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div class="generalHeadingBorderLess"><br>New Users</div>
        <div id="newUserPaging"></div>
        <div id="newUserDiv">
            <table id="newUserList">
                <thead>
                    <tr>
                        <th>User Name</th>
                        <th>Registration Date</th>
                        <th>Email Id</th>

                    </tr>
                </thead>
                <tbody>
                <%
                for (UserProfile profile : newUsers) {
                    String profileLink = ar.baseURL + "v/"
                                + profile.getKey()
                                + "/userProfile.htm?active=1";
                %>
                    <tr>
                        <td><%profile.writeLink(ar);%></td>
                        <td><%SectionUtil.nicePrintDate(out,profile.getLastLogin());%></td>
                        <td><%ar.writeHtml(profile.getPreferredEmail());%></td>
                    </tr>
                <%
                }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
<script type="text/javascript">

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var newUserCD = [
                {key:"userName",label:"User Name",sortable:true,resizeable:true},
                {key:"regdate",label:"Registration Date",sortable:false,resizeable:true},
                {key:"email",label:"Email Address",sortable:true,resizeable:true}
                ];

            var newUserDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("newUserList"));
            newUserDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            newUserDS.responseSchema = {
                fields: [{key:"userName"},
                        {key:"regdate"},
                        {key:"email"}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers   : 'newUserPaging'
                }),
                initialRequest: "results=999999"

            };

            var newUserDT = new YAHOO.widget.DataTable("newUserDiv", newUserCD, newUserDS, oConfigs,
            {caption:"",sortedBy:{key:"email",dir:"regdate"}});

             // Enable row highlighting
            newUserDT.subscribe("rowMouseoverEvent", newUserDT.onEventHighlightRow);
            newUserDT.subscribe("rowMouseoutEvent", newUserDT.onEventUnhighlightRow);
            return {
                oDS: newUserDS,
                oDT: newUserDT
            };
        }();
    });

</script>
