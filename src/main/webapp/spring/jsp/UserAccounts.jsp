<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserProfile.jsp"
%><%@page import="org.socialbiz.cog.spring.SiteRequest"
%><%@page import="org.socialbiz.cog.SiteReqFile"
%><%/*

Required Parameters:

*/

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

    List<NGBook> memberOfSites = uProf.findAllMemberSites();


    List<SiteRequest> allRequests = SiteReqFile.getAllSiteReqs();
    boolean isSuper = ar.isSuperAdmin();
    List<SiteRequest> superRequests = new ArrayList<SiteRequest>();
    List<SiteRequest> myAccountRequests = new ArrayList<SiteRequest>();
    for (SiteRequest oneRequest: allRequests) {
        if(uProf.hasAnyId(oneRequest.getUniversalId())) {
            myAccountRequests.add(oneRequest);
        }
        if (isSuper && oneRequest.getStatus().equalsIgnoreCase("requested")) {
            superRequests.add(oneRequest);
        }
    }


    List accReqs = uProf.getUsersSiteRequests();
    if (accReqs==null) {
        //this should never happen, and if it does it is not the users fault
        throw new ProgramLogicError("user profile returned a null for site requests.");
    }
    ngb = null;

%>
<div class="content tab04" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <%
            if(memberOfSites.size()>0) {
        %>
        <div class="generalHeadingBorderLess">List of Sites</div>
        <div class="generalContent">
            <div id="accountPaging"></div>
            <div id="accountsContainer">
                <table id="accountList">
                    <thead>
                        <tr>
                            <th>No</th>
                            <th>Site Name</th>
                            <th>Site Description</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        int i=0;
                        for (NGBook account : memberOfSites) {
                            i++;
                            String rowStyleClass="tableBodyRow even";
                            if(i%2 == 0){
                                rowStyleClass = "tableBodyRow odd";
                            }
                            String accountLink =ar.baseURL+"t/"+account.getKey()+"/$/accountListProjects.htm";
                    %>
                        <tr>
                           <td>
                                <%=(i)%>
                            </td>
                            <td>
                                <a href="<%ar.writeHtml(accountLink);%>" title="navigate to the site"><%
                                    writeHtml(out, account.getName());
                                %></a>
                            </td>
                            <td>
                                <%
                                    writeHtml(out, account.getDescription());
                                %>
                            </td>
                        </tr>
                       <%
                           }
                       %>
                    </tbody>
                </table>
            </div>
            <br/>
            <br/>
            <div>
                <form name="createAccountForm" method="GET" action="requestAccount.htm">
                    <input type="submit" class="inputBtn"  Value="Request New Site">
                </form>
            </div>
        </div>
        <%
            }else{
        %>
        <div class="guideVocal">
            <%
                if(accReqs.size()>0) {
            %>
            <fmt:message key="requestedaccount.message.0"/> <%=accReqs.size()%>&nbsp;
            <fmt:message key="accounts.title"/></p>
            <%
                }else{
            %>
            <fmt:message key="noaccount.message.0"/>
            <%
                }
            %>
            <fmt:message key="noaccount.message.1"/>
            <fmt:message key="noaccount.message.2"/>
            <form name="createAccountForm" method="GET" action="requestAccount.htm">
                <input type="submit" class="inputBtn"  Value="Request New Site">
            </form>
            <fmt:message key="noaccount.message.3"/>
            <fmt:message key="noaccount.message.4"/>
        </div>
        <%
            }
                //only produce this section if you have some outstanding requests
                if (myAccountRequests.size()>0) {
        %>
        <div class="generalHeadingBorderLess"><br/>Status of Your Site Requests</div>
        <div class="generalContent">
            <div id="accountRequestPaging"></div>
            <div id="accountRequestDiv">
                <table id="pagelistrequest">
                    <thead>
                        <tr>
                            <th>Proposed Name</th>
                            <th>Description</th>
                            <th>Current Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (SiteRequest oneRequest : myAccountRequests)
                                            {
                                                String accountLink =ar.baseURL+"t/"+oneRequest.getSiteId()+"/$/accountListProjects.htm";
                    %><tr><td><%
                        if(oneRequest.getStatus().equalsIgnoreCase("Granted")){
                            %><a href="<%ar.writeHtml(accountLink); %>"><%
                            ar.writeHtml(oneRequest.getName());
                            %></a><%
                        }else{
                            ar.writeHtml(oneRequest.getName());
                        }
                        %></td>
                        <td><%
                        ar.writeHtml(oneRequest.getDescription());
                        %></td>
                        <td><%
                        ar.writeHtml(oneRequest.getStatus());
                        %></td></tr><%
                     }
                     %>
                    </tbody>
                </table>
            </div>
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
                var accountColumnDefs = [
                    {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                    {key:"accountname",label:"Site Name",sortable:true,resizeable:true},
                    {key:"description",label:"Site Description",sortable:true,resizeable:true}];

                var accountDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("accountList"));
                accountDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                accountDS.responseSchema = {
                    fields: [{key:"no", parser:"number"},
                            {key:"accountname"},
                            {key:"description"}]
                };

                var accountConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers:'accountPaging'
                    }),
                    initialRequest: "results=999999"
                };
                var accountDT = new YAHOO.widget.DataTable("accountsContainer", accountColumnDefs, accountDS, accountConfigs,
                {caption:"",sortedBy:{key:"no",dir:"desc"}});
                 // Enable row highlighting
                accountDT.subscribe("rowMouseoverEvent", accountDT.onEventHighlightRow);
                accountDT.subscribe("rowMouseoutEvent", accountDT.onEventUnhighlightRow);

                return {
                    oDS: accountDS,
                    oDT: accountDT
                };
            }();
        });

        YAHOO.util.Event.addListener(window, "load", function()
        {
            YAHOO.example.EnhanceFromMarkup = function()
            {
                var acountRequestCD = [
                    {key:"accountName",label:"Proposed Name",sortable:true,resizeable:true},
                    {key:"members",label:"Description",sortable:true,resizeable:true},
                    {key:"desc",label:"Current Status",sortable:false,resizeable:true}];

                var accountRequestDS = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelistrequest"));
                accountRequestDS.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                accountRequestDS.responseSchema = {
                    fields: [{key:"accountName"},
                            {key:"members"},
                            {key:"desc"}]
                };

                var accountRequestConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers:'accountRequestPaging'
                    }),
                    initialRequest: "results=999999"
                };


                var accountRequestDT = new YAHOO.widget.DataTable("accountRequestDiv", acountRequestCD, accountRequestDS, accountRequestConfigs,
                {caption:"",sortedBy:{key:"bookid",dir:"desc"}});

                 // Enable row highlighting
                accountRequestDT.subscribe("rowMouseoverEvent", accountRequestDT.onEventHighlightRow);
                accountRequestDT.subscribe("rowMouseoutEvent", accountRequestDT.onEventUnhighlightRow);

                return {
                    oDS: accountRequestDS,
                    oDT: accountRequestDT
                };
            }();
        });
</script>
