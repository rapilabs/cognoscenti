<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.BaseRecord"
%><%@page import="org.socialbiz.cog.DOMFace"
%><%@page import="org.socialbiz.cog.IdGenerator"
%><%@page import="org.socialbiz.cog.License"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Unable to create a licenses.");
    boolean createNewSubPage = false;

    String p = ar.reqParam("p");
    String template = ar.reqParam("template");
    String go = ar.reqParam("go");

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ar.assertAdmin("Unable to copy from a template to this page.");

    NGPage templatePage = NGPageIndex.getProjectByKeyOrFail(template);

    for (GoalRecord tr : templatePage.getAllGoals()) {

        GoalRecord newTask = ngp.createGoal();
        newTask.setSynopsis( tr.getSynopsis() );
        newTask.setDescription( tr.getDescription() );
        newTask.setPriority( tr.getPriority() );
        newTask.setState(BaseRecord.STATE_UNSTARTED);

    }
    for (NGRole rr : templatePage.getAllRoles()) {

        String roleName = rr.getName();
        boolean found = false;
        for (NGRole currentRole : ngp.getAllRoles()) {
            if (roleName.equals(currentRole.getName())) {
                found = true;
                break;
            }
        }
        if (found) {
            //already have a role with this name, so ignore it
            continue;
        }
        String description = rr.getDescription();
        ngp.createRole(roleName, description);
    }

    response.sendRedirect(go);%>
<%@ include file="functions.jsp"%>
