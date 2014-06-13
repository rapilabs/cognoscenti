<%@page errorPage="/spring/jsp/error.jsp"
%><%
    goalListType = "Active Goals on this Server";

%><%@ include file="UserLocalGoalCommon.jsp"
%>

    <form name="taskList">
        <input type="hidden" name="filter" value="<%ar.writeHtml(DataFeedServlet.MYACTIVETASKS);%>"/>
        <input type="hidden" name="rssfilter" value="<%ar.writeHtml(RssServlet.STATUS_ACTIVE);%>"/>
    </form>

