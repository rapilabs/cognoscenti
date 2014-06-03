<%@page import="org.socialbiz.cog.NGRole"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%
    String property_msg_key = ar.reqParam("property_msg_key");
    UserProfile uProf = null;
    String pageId = ar.defParam("pageId", null);

    //Note: this page must handle the case that the project does not exist,
    //because that may be part of the warning.
    NGPage ngp = null;
    if (pageId!=null) {
        ngp = (NGPage) NGPageIndex.getContainerByKey(pageId);
    }
    boolean isPersonalTab = false;
%>
<body class="yui-skin-sam">
    <div class="generalArea">
        <div class="generalContent">
            <img src="<%=ar.retPath %>assets/iconAlertBig.gif" title="Alert">&nbsp;&nbsp;
            <fmt:message key="<%=property_msg_key %>">
                <%if((ar.getBestUserId()!=null) && (ar.getBestUserId().length()>0)){ %>
                <fmt:param value='<%=ar.getBestUserId()%>' />
                <%} %>
            </fmt:message>
            <br /><br />
    <%
        //for now two objects for UserProfile is created one will be removed soon
        if(ar.isLoggedIn() && ngp!=null){
            String roleName2 = ar.defParam("roleName", null);
            if (roleName2!=null) {
                NGRole role = ngp.getRole("Members");
                UserProfile up = ar.getUserProfile();
                uProf = ar.getUserProfile();
                String roleMember = up.getUniversalId();
                RoleRequestRecord roleRequestRecord = null;

    %>
            <table>
                <%@include file="join_leave_role_block.jsp"%>
            </table>
            <br /><br /><br /><br /><br /><br />
            <%  }
            } %>
        </div>
    </div>
</body>
