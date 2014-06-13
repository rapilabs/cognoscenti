<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectHome.jsp"
%><%!String pageTitle="";%>
<div class="pageHeading">Your Draft Notes</div>
<%displayCreatLeaf(ar,ngp);%>

    <div class="content tab01">
    <%
        int numNotes = displayDraftNotes(ar, ngp);
    %>
    </div>
</div>


<%
    out.flush();
    if (numNotes==0) {
%>
        <div class="guideVocal">You do not have any draft notes in this project.
            Draft notes can be created and edited without letting anyone else see
            them.  Later, they can be published to the members or to the public.<br/>
            <br/>
            Use the <button class="inputBtn"
            onClick="window.open('<%=getNoteEditorURL(ar, ngp, "")%>&visibility_value=2')">
            Create Note </button> link above
            to create notes and the "Save as Draft" option will create a draft note.
        </div>
<%
    }
%>
