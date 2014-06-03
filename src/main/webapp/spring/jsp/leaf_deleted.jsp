<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectHome.jsp"%>
<%!String pageTitle="";%>
<div class="pageHeading">Deleted Notes</div>
<%displayCreatLeaf(ar,ngp);%>

    <div class="content tab01">
    <%
        int numNotes = displayDeletedNotes(ar, ngp);
    %>
    </div>
</div>

<%
    out.flush();
    if (numNotes==0) {
%>
        <div class="guideVocal">This project does not have any deleted notes.
        </div>
<%
    }
%>
