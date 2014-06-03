<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectHome.jsp"
%><%!String pageTitle="";%>
<div class="pageHeading">Public Notes</div>
<%
    displayCreatLeaf(ar,ngp);


    %>
    <div class="content tab01">
    <%
    int numNotes = displayAllLeaflets(ar, ngp, SectionDef.PUBLIC_ACCESS);
    %>
    </div>
<%
    if (numNotes==0) {
%>
        <div class="guideVocal">This project does not have any public notes,
            that is, there are no notes that would be viewable by the public.<br/>
            <br/>
            Use the <button class="inputBtn"
            onClick="window.open('<%=getNoteEditorURL(ar, ngp, "")%>&visibility_value=2')">
            Create Note </button> link above
            to create notes both public and member only.
        </div>
<%
    }
%>
