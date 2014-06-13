<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="logininfoblock.jsp"
%><%@ include file="/spring/jsp/leaf_AccountHome.jsp"
%>
    <div class="content tab01">
    <%
    if (!ar.isLoggedIn())
    {
    %>
        <div class="generalArea">
            <div class="generalContent">
                <fmt:message key="nugen.projecthome.projectbulletin.logout"></fmt:message>
            </div>
        </div>
    <%
    }
    else if (!ar.isMember())
    {
    %>
        <div class="generalArea">
            <div class="generalContent">
                <fmt:message key="nugen.projecthome.projectbulletinlogin">
                    <fmt:param value='<%= ar.getBestUserId() %>'></fmt:param>
                </fmt:message>
                <br/>
            </div>
        </div>
    <%
    }
    %>   
    </div>
    <div class="seperator">&nbsp;</div>
    <div id="loginArea">
        <span class="black"><%writeMembershipStatus(ngb, ar);%></span></div>
    </div>