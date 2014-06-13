<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/leaf_AccountHome.jsp"
%><%
    if (ar.isMember()){
        displayCreatLeafOnSite(ar,ngb);
    }
%>
<div class="content tab01">
    <%
    if (!ar.isMember())
    {
        if (!ar.isLoggedIn())
        {
    %>
    <div class="generalArea">
        <div class="generalContent">
            <br/>
            In order to see the member notes of the site, you need to be
            logged in, and you need to be an executive of the site.
            <br/>
            <br/>
            <br/>
            <br/>
        </div>
    </div>
    <%
        }
        else
        {
    %>
    <div class="generalArea">
        <div class="generalContent">
            <fmt:message key="nugen.member.section.memberlogin">
            <fmt:param value='<%=ar.getBestUserId()%>'/>
            </fmt:message><br/>
        </div>
    </div>
    <%
        }
    }
    else
    {
        displayAllLeaflets(ar, ngb, SectionDef.MEMBER_ACCESS);
    }
    out.flush();
    %>
</div>
