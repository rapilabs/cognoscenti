<%@page errorPage="/spring/jsp/error.jsp"
%><%
    goalListType = "All Goals for User on this Server";

%><%@ include file="UserLocalGoalCommon.jsp"
%>


    <form name="taskList">
        <input type="hidden" name="filter" value="<%ar.writeHtml(DataFeedServlet.ALLTASKS);%>"/>
        <input type="hidden" name="rssfilter" value="<%ar.writeHtml(RssServlet.STATUS_ALL);%>"/>
    </form>


