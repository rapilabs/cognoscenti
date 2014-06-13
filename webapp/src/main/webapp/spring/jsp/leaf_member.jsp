<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.UserRef"
%><%@ include file="leaf_ProjectHome.jsp"
%><%!String pageTitle="";%>
<div class="pageHeading">Member Notes</div>
<%
    displayCreatLeaf(ar,ngp);
%>

<div class="content tab01">
    <div class="leafLetArea">
    <%
        int numNotes = displayAllLeaflets(ar, ngp, SectionDef.MEMBER_ACCESS);
    %>
    </div>
    <%
        out.flush();
    %>
</div>
</div>

<%
    if (numNotes==0) {
%>
        <div class="guideVocal">This project does not have any member notes,
        that is, there are no notes that would be viewable only by the members.<br/>
            <br/>
            Use the <button class="inputBtn"
            onClick="window.open('<%=getNoteEditorURL(ar, ngp, "")%>&visibility_value=2')">
            Create Note </button> link above
            to create notes both public and member only.
        </div>
<%
    }
%>
