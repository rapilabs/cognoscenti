<%@page import="org.socialbiz.cog.NotificationRecord"%>
<%@page errorPage="/spring/jsp/error.jsp"
%><%@include file="/spring/jsp/include.jsp"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.WatchRecord"
%><%@page import="org.socialbiz.cog.rest.TaskHelper"
%><%@page import="org.springframework.context.ApplicationContext"
%><%@page import="org.w3c.dom.Element"
%><%
    /*

Required Parameters:

    1. userProfile  : This parameter is used to retrieve UserProfile of a user.
    2. messages     : Its used to get ApplicationContext from request.

*/

    UserProfile  uProf =(UserProfile)request.getAttribute("userProfile");
    ApplicationContext context = (ApplicationContext)request.getAttribute("messages");
%><%!String pageTitle = "";%><%
    Vector<NotificationRecord> notifications = uProf.getNotificationList();
    List<NGContainer> containers = new ArrayList();
    long lastSendTime = SuperAdminLogFile.getLastNotificationSentTime();
%>

<div class="generalArea">
<%
    if(notifications.size()>0) {
    int count = 0;
    String rowStyleClass = "";
    for (NotificationRecord tr : notifications) {
        String pageId = tr.getPageKey();
        NGPage ngp = (NGPage)NGPageIndex.getContainerByKey(pageId);
        if (ngp==null) {
    continue;
        }
        containers.add(ngp);
        String linkAddr = ar.retPath + "t/" +ngp.getSite().getKey()+"/"+ngp.getKey() + "/history.htm";
        if(count%2 == 0){
    rowStyleClass = "tableBodyRow odd";
        }
        else{
    rowStyleClass = "tableBodyRow even";
        }
    }
}
%>
<div class="generalHeading" style="padding-top:35px">Project Notifications Since Last Digest
        <%SectionUtil.nicePrintDateAndTime(out, lastSendTime);%></div>
    <p>These notifications, if any, will be included in your next daily digest email.</p>

    <%
    EmailSender.constructDailyDigestEmail(ar,containers,context,lastSendTime,ar.nowTime);

    out.flush();

%><%@ include file="functions.jsp"%>
</div>
