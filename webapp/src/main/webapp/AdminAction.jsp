<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.ServerInitializer"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.ServerInitializer"
%><%

    //to restart server have to skip all the normal stuff
    //assume server un-pause is the only possible option here
    if (ServerInitializer.serverInitState==ServerInitializer.STATE_PAUSED) {
        ServerInitializer.reinitServer();
        response.sendRedirect("Admin.jsp");
        return;
    }
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't use administration functions.");
    boolean createNewSubPage = false;

    String go = ar.reqParam("go");
    String action = ar.reqParam("action");

    String dataFolder = ar.getSystemProperty("dataFolder");

    if (action.equals("Garbage Collect Pages")) {
        deleteMarkedPages();
        action = "Reinitialize Index";
    }

    if (action.equals("Reinitialize Index") || action.equals("Start Email Sender")) {
        ar.getSession().flushConfigCache();

        // Only if the server is running, then this code will
        // set it into paused mode, wait a few seconds, and then
        // cause the server to be completely reinitialized.
        if (ServerInitializer.isRunning()) {
            ServerInitializer.pauseServer();
            Thread.sleep(20);
            ServerInitializer.reinitServer();
        }
    }
    else if (action.equals("Remove Disabled Users")) {
        UserManager.removeDisabledUsers();
        UserManager.reloadUserProfiles();
    }
    else if (action.equals("Send Test Email")) {
        EmailSender.sendTestEmail();
    }
    else if (action.equals("Pause Server")) {
        ServerInitializer.pauseServer();
    }
    else if (action.equals("Restart Server")) {
        ServerInitializer.reinitServer();
    }
    else {
        throw new Exception ("Unrecognized command: "+action);
    }

    response.sendRedirect(go);

%><%!

public void deleteMarkedPages()
        throws Exception
{
    for (NGPageIndex ngpi : NGPageIndex.getDeletedContainers())
    {
        File deadFile = ngpi.containerPath;
        if (deadFile.exists()) {
            deadFile.delete();
        }
    }
}

%><%@ include file="functions.jsp"
%><%

    NGPageIndex.clearLocksHeldByThisThread();
%>
