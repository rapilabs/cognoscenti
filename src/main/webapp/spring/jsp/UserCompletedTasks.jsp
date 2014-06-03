<%@page errorPage="/spring/jsp/error.jsp"
%><%
    goalListType = "Goals on this Server Completed by User";

%><%@ include file="UserLocalGoalCommon.jsp"
%>

    <form name="taskList">
        <input type="hidden" name="filter" value="<%ar.writeHtml(DataFeedServlet.COMPLETEDTASKS);%>"/>
        <input type="hidden" name="rssfilter" value="<%ar.writeHtml(RssServlet.STATUS_COMPLETED);%>"/>
    </form>


