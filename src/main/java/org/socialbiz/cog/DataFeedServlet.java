/*
 * Copyright 2013 Keith D Swenson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors Include: Shamim Quader, Sameer Pradhan, Kumar Raja, Jim Farris,
 * Sandia Yang, CY Chen, Rajiv Onat, Neal Wang, Dennis Tam, Shikha Srivastava,
 * Anamika Chaudhari, Ajay Kakkar, Rajeev Rastogi
 */

package org.socialbiz.cog;

import java.util.List;
import java.util.Vector;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

@SuppressWarnings("serial")
public class DataFeedServlet extends HttpServlet {

    // all of the supported operations.
    public static final String OPERATION_SEARCH = "SEARCH";
    public static final String OPERATION_GETTASKLIST = "GETTASKLIST";

    // all of the Query parameters.
    public static final String PARAM_OPERATION = "op";
    public static final String PARAM_SEARCHSTRING = "qs";
    public static final String PARAM_TASKLIST = "list";

    // all of the constant values.
    public static final String ALLTASKS = "alltasks";
    public static final String MYACTIVETASKS = "myactivetasks";
    public static final String FUTURETASKS = "futuretasks";
    public static final String COMPLETEDTASKS = "completedtasks";

    public DataFeedServlet() {
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException {
        doPost(request, response);
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException {
        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        try {
            handleAllRequests(ar);
        }
        catch (Exception e) {
            ar.logException("Data Feed Servlet", e);
        }
        finally {
            NGPageIndex.clearLocksHeldByThisThread();
        }
        ar.logCompletedRequest();
    }

    private void handleAllRequests(AuthRequest ar) throws Exception {
        String isNewUI = ar.defParam("isNewUI", "");
        if ("yes".equalsIgnoreCase(isNewUI)) {
            ar.setNewUI(true);
        }

        if (!ar.isLoggedIn()) {
            throw new NGException("nugen.exception.cant.perform.search", null);
        }

        String operation = reqParam(ar.req, PARAM_OPERATION);

        if (OPERATION_SEARCH.equalsIgnoreCase(operation)) {
            handleSearchOperation(ar);
            return;
        }
        if (OPERATION_GETTASKLIST.equalsIgnoreCase(operation)) {
            handleGetTaskList(ar);
            return;
        }
        else {
            throw new ProgramLogicError("Unable to provide data. Unknown operation : " + operation);
        }
    }

    // operation Search.
    private void handleSearchOperation(AuthRequest ar) throws Exception {
        String qs = ar.reqParam(PARAM_SEARCHSTRING);

        List<SearchResultRecord> records = performLuceneSearchOperation(ar, qs);
        writeSearchRecordsToResponse(ar, qs, records);
    }

    // operation get task list.
    private void handleGetTaskList(AuthRequest ar) throws Exception {
        if (ar == null) {
            throw new RuntimeException("handleGetTaskList requires a non-null parameter ar");
        }

        if (!ar.isLoggedIn()) {
            throw new NGException("nugen.exception.login.to.set.tasklist", null);
        }
        String listType = reqParam(ar.req, PARAM_TASKLIST);
        String openId = defParam(ar.req, "u", ar.getBestUserId());

        UserProfile up = UserManager.findUserByAnyId(openId);
        TaskListRecord[] tasks = getTaskList(up, listType);

        writeTaskListToResponse(ar, tasks);
    }

    /************************ internal methods. ************************/
    private void writeSearchRecordsToResponse(AuthRequest ar, String query, List<SearchResultRecord> records)
            throws Exception {
        if (ar == null || records == null) {
            throw new ProgramLogicError("writeSearchRecordsToResponse parameter must not be null");
        }

        // result XML.
        Document doc = DOMUtils.createDocument("ResultSet");
        Element resultSetEle = doc.getDocumentElement();

        int count=0;
        for ( SearchResultRecord sr : records) {
            count++;
            //seems like the following code should be internal to SearchResultRecord
            Element resultEle = DOMUtils.createChildElement(doc, resultSetEle, "Result");
            DOMUtils.createChildElement(doc, resultEle, "No", Integer.toString(count));
            DOMUtils.createChildElement(doc, resultEle, "PageName", sr.getPageName());
            DOMUtils.createChildElement(doc, resultEle, "PageKey", sr.getPageKey());
            DOMUtils.createChildElement(doc, resultEle, "PageLink", sr.getPageLink());

            DOMUtils.createChildElement(doc, resultEle, "BookName", sr.getBookName());
            DOMUtils.createChildElement(doc, resultEle, "NoteSubj", sr.getNoteSubject());

            UserProfile uProf = UserManager.findUserByAnyId(sr.getLastModifiedBy());
            String userName = "unknown";
            String userKey = "unknown";
            if (uProf != null) {
                userName = uProf.getName();
                userKey = uProf.getKey();
            }

            DOMUtils.createChildElement(doc, resultEle, "LastModifiedBy", userKey);
            DOMUtils.createChildElement(doc, resultEle, "LastModifiedName", userName);

            String timeVal = SectionUtil.getNicePrintTime(sr.getLastModifiedTime(), ar.nowTime);
            if (timeVal.trim().length() == 0) {
                timeVal = "unknown";
            }
            DOMUtils.createChildElement(doc, resultEle, "LastModifiedTime", timeVal);
//            DOMUtils.createChildElement(doc, resultEle, "UserLink", "bogus user link");
//            DOMUtils.createChildElement(doc, resultEle, "timePeriod", "8888");
        }

        // TODO Duplicate Code.
        resultSetEle.setAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
        resultSetEle.setAttribute("totalResultsAvailable", Integer.toString(records.size()));
        resultSetEle.setAttribute("totalResultsReturned", Integer.toString(records.size()));
        resultSetEle.setAttribute("firstResultPosition", "0");
        resultSetEle.setAttribute("query", query);

        writeXMLToResponse(ar, doc);
    }

    private void writeTaskListToResponse(AuthRequest ar, TaskListRecord[] records) throws Exception {
        if (ar == null || records == null) {
            throw new ProgramLogicError("writeTaskListToResponse parameter must not be null");
        }

        // result XML.
        Document doc = DOMUtils.createDocument("ResultSet");
        Element resultSetEle = doc.getDocumentElement();

        for (int i = 0; i < records.length; i++) {
            TaskListRecord rec = records[i];
            NGPageIndex ngpi = NGPageIndex.getContainerIndexByKeyOrFail(rec.pageKey);

            Element resultEle = DOMUtils.createChildElement(doc, resultSetEle, "Result");
            DOMUtils.createChildElement(doc, resultEle, "No", String.valueOf((i + 1)));
            DOMUtils.createChildElement(doc, resultEle, "Id", rec.taskId);
            DOMUtils.createChildElement(doc, resultEle, "State", String.valueOf(rec.taskState));
            String imageName = null;
            if (rec.isAttachment) {
                imageName = "ts_attachment.gif";
            }
            else {
                imageName = GoalRecord.stateImg(rec.taskState);
            }
            DOMUtils.createChildElement(doc, resultEle, "StateImg", imageName);
            StringBuffer sb = new StringBuffer(rec.taskSyn);
            if (rec.taskDesc != null && rec.taskDesc.length() > 0) {
                sb.append(" - ").append(rec.taskDesc);
            }
            DOMUtils.createChildElement(doc, resultEle, "NameAndDescription", sb.toString());
            String assignees = UserManager.getUserNamesFromUserId(rec.taskAssignee);
            if (assignees == null || assignees.length() == 0) {
                assignees = "unknown";
            }
            DOMUtils.createChildElement(doc, resultEle, "Assignee", assignees);
            DOMUtils.createChildElement(doc, resultEle, "Priority",
                    String.valueOf(rec.taskPriority));
            if (rec.taskDue > 0) {
                DOMUtils.createChildElement(doc, resultEle, "DueDate",
                        SectionUtil.getNicePrintDate(rec.taskDue));
            }
            // DOMUtils.createChildElement(doc, resultEle, "DueDate" ,
            // SectionUtil.getNicePrintDate(rec.taskDue));
            if (rec.taskStart > 0) {
                DOMUtils.createChildElement(doc, resultEle, "StartDate",
                        SectionUtil.getNicePrintDate(rec.taskStart));
            }
            DOMUtils.createChildElement(doc, resultEle, "PageKey", rec.pageKey);
            DOMUtils.createChildElement(doc, resultEle, "PageName", rec.pageName);
            DOMUtils.createChildElement(doc, resultEle, "PageURL", ar.getResourceURL(ngpi, ""));
            DOMUtils.createChildElement(doc, resultEle, "timePeriod", String.valueOf(rec.taskDue));
        }

        // TODO Duplicate Code.
        resultSetEle.setAttribute("xmlns:xsi", "http://www.w3.org/2001/XMLSchema-instance");
        resultSetEle.setAttribute("totalResultsAvailable", String.valueOf(records.length));
        resultSetEle.setAttribute("totalResultsReturned", String.valueOf(records.length));
        resultSetEle.setAttribute("firstResultPosition", "1");

        writeXMLToResponse(ar, doc);

    }

    public static List<SearchResultRecord> performLuceneSearchOperation(AuthRequest ar,
            String searchText) throws Exception {
        // String b = ar.defParam("b", "All Books");
        // boolean isGlobal = "All Books".equals(b);
        String pf = ar.defParam("pf", "all");
        String u = ar.defParam("u", "old");
        if ("new".equals(u)) {
            ar.setNewUI(true);
        }
        SearchManager.initializeIndex();
        return SearchManager.performSearch(ar, searchText, pf, null);
    }

    // operation get task list.
    public static TaskListRecord[] getTaskList(UserProfile up, String listType) throws Exception {

        Vector<TaskListRecord> allTask = new Vector<TaskListRecord>();
        Vector<TaskListRecord> activeTask = new Vector<TaskListRecord>();
        Vector<TaskListRecord> completedTask = new Vector<TaskListRecord>();
        Vector<TaskListRecord> futureTask = new Vector<TaskListRecord>();

        TaskListRecord[] tasks = new TaskListRecord[0];
        if (up == null || listType == null || listType.length() == 0) {
            return tasks;
        }

        for (NGPageIndex ngpi : NGPageIndex.getAllContainer()) {
            // start by clearing any outstanding locks in every loop
            NGPageIndex.clearLocksHeldByThisThread();

            if (!ngpi.isProject()) {
                continue;
            }
            NGPage aPage = ngpi.getPage();
            String pageKey = aPage.getKey();

            for (GoalRecord gr : aPage.getAllGoals()) {
                if ((!gr.isAssignee(up)) && (!gr.isReviewer(up))) {
                    continue;
                }
                TaskListRecord tr = new TaskListRecord(gr, pageKey, aPage.getFullName(),
                        aPage.getOldUIPermaLink());
                int state = gr.getState();

                allTask.add(tr);

                if (state == BaseRecord.STATE_ERROR) {
                    if (gr.isAssignee(up)) {
                        activeTask.add(tr);
                    }
                }
                else if (state == BaseRecord.STATE_ACCEPTED || state == BaseRecord.STATE_STARTED
                        || state == BaseRecord.STATE_WAITING) {
                    // the assignee should see this task in the active task list.
                    if (gr.isAssignee(up)) {
                        activeTask.add(tr);
                    }

                    // the reviewer should see this task in the future task list.
                    if (gr.isReviewer(up)) {
                        futureTask.add(tr);
                    }
                }
                else if (state == BaseRecord.STATE_REVIEW) {
                    // when the user is THE reviewer and not yet approved this task
                    // then this should be in the active tasks list.
                    if (gr.isNextReviewer(up)) {
                        activeTask.add(tr);
                    }
                    // when user is a reviewer and the task is NOT approved by the reviewer
                    // and the user is NOT the next reviewer then the task should
                    // be listed in the future task list.
                    else if (gr.isReviewer(up) && (gr.isApprovedBy(up) == false)) {
                        futureTask.add(tr);
                    }
                    // when the user is a reviewer and task is approved by the reviewer
                    // and the user then the task should be listed in the completed task list.
                    else if (gr.isReviewer(up) && (gr.isApprovedBy(up))) {
                        completedTask.add(tr);
                    }
                }
                else if (state == BaseRecord.STATE_UNSTARTED) {
                    // when the task is unstarted then assignee and the
                    // approver/ reviewer should see the task in future list.
                    futureTask.add(tr);
                }
                else if (state == BaseRecord.STATE_COMPLETE) {
                    completedTask.add(tr);
                }
            }
        }

        if (listType.equalsIgnoreCase(ALLTASKS)) {
            tasks = new TaskListRecord[allTask.size()];
            allTask.copyInto(tasks);
        }
        else if (listType.equalsIgnoreCase(MYACTIVETASKS)) {
            tasks = new TaskListRecord[activeTask.size()];
            activeTask.copyInto(tasks);
        }
        else if (listType.equalsIgnoreCase(COMPLETEDTASKS)) {
            tasks = new TaskListRecord[completedTask.size()];
            completedTask.copyInto(tasks);
        }
        else if (listType.equalsIgnoreCase(FUTURETASKS)) {
            tasks = new TaskListRecord[futureTask.size()];
            futureTask.copyInto(tasks);
        }
        return tasks;
    }

    private String reqParam(HttpServletRequest request, String paramName) throws Exception {
        String val = defParam(request, paramName, null);
        if (val == null || val.length() == 0) {
            throw new ProgramLogicError("DataFeedServlet requires a parameter named '" + paramName
                    + "'. ");
        }
        return val;
    }

    private void writeXMLToResponse(AuthRequest ar, Document doc) throws Exception {
        if (ar == null) {
            throw new ProgramLogicError(
                    "writeXMLToResponse requires a non-null AuthRequest parameter");
        }

        ar.resp.setContentType("text/xml;charset=UTF-8");
        DOMUtils.writeDom(doc, ar.w);
        ar.flush();
    }

    private String defParam(HttpServletRequest request, String paramName, String defaultValue)
            throws Exception {
        String val = request.getParameter(paramName);
        if (val == null) {
            return defaultValue;
        }
        // this next line should not be needed, but I have seen this hack
        // recommended in many forums.
        String modVal = new String(val.getBytes("iso-8859-1"), "UTF-8");
        return modVal;
    }
}

class TaskListRecord {
    boolean isAttachment = false;
    String taskId;
    int taskState;
    String taskSyn;
    String taskDesc;
    String taskAssignee;
    int taskPriority = 0;
    long taskDue = 0;
    long taskStart = 0;
    String pageLink;
    String pageKey;
    String pageName;
    String taskStatus;

    TaskListRecord(GoalRecord goal, String pKey, String pName, String pLink) throws Exception {
        taskId = goal.getId();
        taskState = goal.getState();
        taskSyn = goal.getSynopsis();
        taskDesc = goal.getDescription();
        taskAssignee = goal.getAssigneeCommaSeparatedList();
        taskPriority = goal.getPriority();
        taskDue = goal.getDueDate();
        taskStart = goal.getStartDate();
        taskStatus = goal.getStatus();
        pageKey = pKey;
        pageName = pName;
        pageLink = pLink;
    }

}
