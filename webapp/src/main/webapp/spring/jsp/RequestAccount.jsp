<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@page import="org.socialbiz.cog.SiteReqFile"
%><%@page import="org.socialbiz.cog.spring.SiteRequest"
%><%
/*
Required parameter:

    1. userKey : This is the key of user .

*/

    String userKey = ar.reqParam("userKey");

%><%!String pageTitle="";%><%
    request.setCharacterEncoding("UTF-8");
    UserProfile  uProf = UserManager.getUserProfileByKey(userKey);
%>
<div class="pageHeading">Request a New Site Space</div>
<div class="pageSubHeading">From here you can request to create a new site from where you can create & handle multiple projects.</div>
<div class="generalSettings">
    <div id="requestAccount">
        <form name="requestNewAccount" action="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/accountRequests.form" method="post">
            <input type="hidden" name="action" id="action" value="">
            <table width="100%" border="0" cellpadding="0" cellspacing="0">
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2" valign="top"><b>Site Name:<span style="color:red">*</span></b></td>
                    <td style="width:20px;"></td>
                    <td><input type="text" name="accountName" id="accountName" class="inputGeneral" /><br/>
                        <span class="formFieldHelp">Enter a descriptive proper name.  This can be changed later.</span></td>
                </tr>
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2" valign="top"><b>Site ID:<span style="color:red">*</span></b></td>
                    <td style="width:20px;"></td>
                    <td><input type="text" name="accountID" id="accountID" class="inputGeneral"/><br/>
                        <span class="formFieldHelp">Enter 4 to 8 letters and numbers to identify this site uniquely.<br/>
                        The value you pick here is permanent, and can not be changed for this site.</span></td>
                </tr>
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2" valign="top"><b>Site Description:<span style="color:red">*</span></b></td>
                    <td style="width:20px;"></td>
                    <td><textarea name="accountDesc" id="accountDesc" class="textAreaGeneral" rows="4"></textarea><br/>
                        <span class="formFieldHelp">The description helps others know what you intend to use this site for.</span></td>
                </tr>
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2"></td>
                    <td style="width:20px;"></td>
                    <td><input type="submit" value="<fmt:message key='nugen.button.general.submit'/>" class="inputBtn"  onclick="javascript:requestAccount('Submit')"/>
                    &nbsp;<input type="submit" value="<fmt:message key='nugen.button.general.cancel'/>" class="inputBtn"  onclick="javascript:requestAccount('Cancel')"/>
                    </td>
                </tr>
            </table>
        </form>
    </div>
    <script>
        function requestAccount(action){
            document.getElementById("action").value=action;
        }
    </script>
<%@ include file="functions.jsp"%>
