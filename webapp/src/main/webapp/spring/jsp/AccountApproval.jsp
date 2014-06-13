<%@page import="org.socialbiz.cog.SiteReqFile"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.spring.SiteRequest"
%><%/*
Required parameter:

    1. requestId : This is the id of requested site and here it is used to retrieve requested Site's request Details.

    Optional Parameter:

    2. canAccess : This boolean parameter is used to check if user has special permission to access the page or not.
*/

    String requestId = ar.reqParam("requestId");
    String canAccess = ar.defParam("canAccess", "false");
    boolean canAccessPage = Boolean.parseBoolean(canAccess);

    String userKey = ar.defParam("userId", null);%><%!String pageTitle="";%><%SiteRequest accountDetails=SiteReqFile.getRequestByKey(requestId);%>
<style type="text/css">
    html {
        background-color:#C1BFC0;
        background-image:url('../assets/homePageBg.jpg');
        background-repeat:no-repeat;
        background-position:center top;
    }
    body {
        font-family:Arial,Helvetica,Verdana,sans-serif;
        font-size:100.1%;
        color:#000000;
        background-color:transparent;
    }
    #bodyWrapper {
        margin:0px auto 45px auto;
        width:935px;
        position:relative;
    }
</style>

    <%
    if(accountDetails != null){
        String status = accountDetails.getStatus();
        boolean isGranted = status.equals("Granted");

        UserProfile requester = UserManager.findUserByAnyId(accountDetails.getModUser());

    %>
    <div id="loginDivArea">
        <div class="generalArea">
            <div class="generalContent">
                <form id="acceptOrDenyForm" action="<%=ar.retPath%>t/acceptOrDeny.form" method="post" >
                    <input type="hidden" id="userKey" name="userKey" value="<%ar.write(userKey); %>" />
                    <table width="100%">
                        <tr><td style="height:20px"></td></tr>
                        <tr><td colspan="3" class="generalHeading">Approve/Reject Site Request</td></tr>
                        <tr><td style="height:30px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">
                                <label id="nameLbl"><B>Requested By:</B></label>
                            </td>
                            <td style="width:20px;"></td>
                            <td><%requester.writeLink(ar);%></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Site Name:</td>
                            <td style="width:20px;"></td>
                            <td>
                            <%
                                if (isGranted)
                                                {
                                                    ar.write("<a href=\"");
                                                    ar.write(ar.retPath);
                                                    ar.write("v/");
                                                    ar.write(accountDetails.getSiteId());
                                                    ar.write("/$/public.htm\">");
                                                    ar.writeHtml(accountDetails.getName());
                                                    ar.write(" (click here to visit site)</a>");
                                                }
                                                else
                                                {
                                                    ar.writeHtml(accountDetails.getName());
                                                }
                            %>
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Requested On:</td>
                            <td style="width:20px;"></td>
                            <td>
                            <%ar.writeHtml(SectionUtil.getNicePrintDate(accountDetails.getModTime())); %>
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Status:</td>
                            <td style="width:20px;"></td>
                            <td>
                            <%ar.writeHtml(accountDetails.getStatus());%>
                            </td>
                        </tr>
                        <tr><td style="height:15px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader" valign="top">Description:</td>
                            <td style="width:20px;"></td>
                            <td>
                                <textarea id="description" name="description" rows="4" class="textAreaGeneral"><%ar.writeHtml(accountDetails.getDescription());%></textarea>
                            </td>
                        </tr>
                        <tr><td style="height:15px"></td></tr>
                        <% if (canAccessPage || ar.isSuperAdmin())  { %>
                        <tr>
                            <td width="148" class="gridTableColummHeader"></td>
                            <td style="width:20px;"></td>
                            <td>
                                <input type="button" class="inputBtn"  value="<%ar.writeHtmlMessage("nugen.button.general.grant",null); %>" onclick="acceptOrDeny('accept')">&nbsp;
                                <input type="button" class="inputBtn"  value="<%ar.writeHtmlMessage("nugen.button.general.deny",null); %>" onclick="acceptOrDeny('deny')">&nbsp;
                                <input type="button" class="inputBtn"  value="<%ar.writeHtmlMessage("nugen.button.general.cancel",null); %>" onclick="acceptOrDeny('cancel')" >
                            </td>
                        </tr>
                        <% } %>
                    </table>
                    <input type="hidden" name="action" id="action" value="">
                    <input type="hidden" name="requestId" id="requestId" value="<%ar.writeHtml(accountDetails.getRequestId());%>">
                </form>
            </div>
        </div>
    </div>
    <%
    }else{
    %>
    <div class="generalArea" >
        <table width="100%" class="gridTable">
            <tr>
                <td style="color:green;font-size:12px" colspan="2"><b><I>
                Unable to find that request in the records.
                Maybe that request has already been Approved.</I></b><br></td>
            </tr>
        </table>
    </div>
    <%
    }
    %>

<script>
    function acceptOrDeny(actionType){
        if(actionType == "cancel"){
            document.getElementById('action').value ="Cancel";
        }
        else if(actionType == "deny"){
            document.getElementById('action').value ="Denied";
            var description = document.getElementById('description').value;
            if(description == ""){
                alert("Description Field is mandetory.");
                return false;
            }
        }else{
            document.getElementById('action').value ="Granted";
        }
        document.getElementById("acceptOrDenyForm").submit();
        return true;
    }
</script>

