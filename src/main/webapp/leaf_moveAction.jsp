<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AttachmentVersion"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.BaseRecord"
%><%@page import="org.socialbiz.cog.DataFeedServlet"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.NGSession"
%><%@page import="org.socialbiz.cog.RssServlet"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.rest.TaskHelper"
%><%@page import="java.io.Writer"
%><%@page import="java.io.FileInputStream"
%><%@page import="java.net.URLEncoder"
%><%AuthRequest ar = null;
    String goUrl = "";
    String pageTitle = null;
    String newUIResource = "public.htm";
    String specialTab = "";


    ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't manage Task list.");
    UserProfile uProf = ar.getUserProfile();

    String p = ar.reqParam("p");
    String hook = ar.reqParam("hook");
    if (p.equals(hook)) {
        throw new Exception("It is not possible to MOVE resource to the same page you are moving from!");
    }

    try {
        String go = ar.reqParam("go");

        String[] notes = ar.multiParam("note");

        String[] docs = ar.multiParam("doc");
        String[] tasks = ar.multiParam("task");

        ngp = NGPageIndex.getProjectByKeyOrFail(p);
        NGPage hookProj = NGPageIndex.getProjectByKeyOrFail(hook);
        ar.setPageAccessLevels(hookProj);
        if (!ar.isAdmin()) {
            throw new Exception("You must be administrator of the hooked project in order to move resources out of that project.!");
        }

        for (String aNote : notes) {
            NoteRecord leaf = hookProj.getLeaflet(aNote);
            if (leaf==null) {
                throw new Exception("Not able to find the note with id ("+aNote+") so aborting the entire transfer.");
            }
            NoteRecord newLeaf = ngp.createNote();
            newLeaf.copyFrom(leaf);
            newLeaf.setOwner(uProf.getUniversalId());

            ngp.copyHistoryForResource(hookProj, HistoryRecord.CONTEXT_TYPE_LEAFLET, leaf.getId(), newLeaf.getId());

            hookProj.deleteNote(aNote, ar);
            leaf.setMovedTo(ngp.getKey(), newLeaf.getId());
        }
        for (String aDoc : docs) {
            AttachmentRecord oldDoc = hookProj.findAttachmentByIDOrFail(aDoc);

            AttachmentRecord newDoc = ngp.createAttachment();
            newDoc.copyFrom(oldDoc);

            AttachmentVersion oldVers = oldDoc.getLatestVersion(hookProj);
            if (oldVers==null) {
                continue;
            }
            File oldFile = oldVers.getLocalFile();
            FileInputStream fis = new FileInputStream(oldFile);
            newDoc.streamNewVersion(ar,ngp,fis);
            oldVers.releaseLocalFile();

            ngp.copyHistoryForResource(hookProj, HistoryRecord.CONTEXT_TYPE_DOCUMENT, oldDoc.getId(), newDoc.getId());
            oldDoc.setDeleted(ar);
            oldDoc.setMovedTo(ngp.getKey(), newDoc.getId());
        }
        for (String aTask : tasks) {
            GoalRecord task = hookProj.getGoalOrFail(aTask);
            GoalRecord newTask = ngp.createGoal();
            newTask.copyFrom(task);
            newTask.setCreator(uProf.getUniversalId());
            ngp.copyHistoryForResource(hookProj, HistoryRecord.CONTEXT_TYPE_TASK, task.getId(), newTask.getId());

            //disable the old task
            task.setState(BaseRecord.STATE_DELETED);
            task.setMovedTo(ngp.getKey(), newTask.getId());
        }

        hookProj.saveFile(ar, "moved resources to project: "+ngp.getFullName());
        ngp.saveFile(ar, "received resources from project: "+hookProj.getFullName());
        response.sendRedirect(go);
    }
    catch (Exception e) {
        throw new Exception("Entire move operation cancelled.", e);
    }%>
<%@ include file="functions.jsp"%>

