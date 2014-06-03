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

package org.socialbiz.cog.spring;

import java.util.Arrays;
import java.util.List;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.socialbiz.cog.AccessControl;
import org.socialbiz.cog.AddressListEntry;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.BaseRecord;
import org.socialbiz.cog.GoalRecord;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.LicensedURL;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.NGRole;
import org.socialbiz.cog.ProcessRecord;
import org.socialbiz.cog.SectionUtil;
import org.socialbiz.cog.UserProfile;
import org.socialbiz.cog.UtilityMethods;
import org.socialbiz.cog.exception.NGException;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

/**
 * This class will handle all requests managing process/tasks. Currently this is
 * handling only requests that are coming to create a new task, update/modify
 * task and also reassign the task to other member.
 *
 */
@Controller
public class ProcessController extends BaseController {

    public static final String CREATE_TASK = "Create Task";
    public static final String BOOK_ATT = "book";
    public static final String PROCESS_HTML = "projectActiveTasks.htm";
    public static final String PROJECT_TASKS="Project Tasks";
    public static final String SUCCESS_LOCAL = "success_local";
    public static final String SUCCESS_REMOTE = "success_remote";
    public static final String REMOTE_PROJECT = "Remote_project";
    public static final String LOCAL_PROJECT = "Local_Project";

    @RequestMapping(value = "/{siteId}/{pageId}/CreateTask.form", method = RequestMethod.POST)
    public ModelAndView createTask(@PathVariable String siteId, @PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertLoggedIn("Must be logged in to create a task.");

            // call a method for creating new task
            taskActionCreate(ar, ngp, request, null);

            String assignto= ar.defParam("assignto", "");
            NGWebUtils.updateUserContactAndSaveUserPage(ar, "Add",assignto);

            return redirectBrowser(ar,PROCESS_HTML);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.create.task", new Object[]{pageId,siteId} , ex);
        }
    }

    public static String parseEmailId(String assigneTo) throws Exception {

        String assignessEmail = "";
        String[] emails = UtilityMethods.splitOnDelimiter(assigneTo, ',');

        for (String email : emails) {
            if (!email.equals("")) {
                int bindx = email.indexOf('<');
                int length = email.length();
                if (bindx > 0) {
                    email = email.substring(bindx + 1, length - 1);
                }

                assignessEmail = assignessEmail + "," + email;
            }
        }
        if (assignessEmail.startsWith(",")) {
            assignessEmail = assignessEmail.substring(1);
        }
        return assignessEmail;
    }

    @RequestMapping(value = "/{siteId}/{pageId}/createSubTask.form", method = RequestMethod.POST)
    public ModelAndView createSubTask(@PathVariable String siteId,
            @PathVariable String pageId, @RequestParam String taskId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertLoggedIn("Must be logged in to manipulate tasks.");

            //TODO: taskId should really be parentTaskId
            taskActionCreate(ar, ngp, request, taskId);

            String assignto= ar.defParam("assignto", "");
            NGWebUtils.updateUserContactAndSaveUserPage(ar, "Add",assignto);

            String go = ar.reqParam("go");
            return new ModelAndView(new RedirectView(go));

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.create.sub.task", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/subtask.htm", method = RequestMethod.GET)
    public ModelAndView showSubTask(@PathVariable
    String siteId, @PathVariable
    String pageId, @RequestParam
    String taskId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            ar.assertLoggedIn("Must be logged in to open a sub task");

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", PROJECT_TASKS);
            request.setAttribute("taskId", taskId);
            request.setAttribute("title", " : " + nGPage.getFullName());
            return new ModelAndView("subtask");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.create.task.page", new Object[]{pageId,siteId} , ex);
        }
    }

    private void taskActionUpdate(AuthRequest ar, NGPage ngp, String parentTaskId)
            throws Exception
    {
       // final boolean updateTask =  true;
        ar.setPageAccessLevels(ngp);
        ar.assertMember("Must be a member of a project to manipulate tasks.");
        ar.assertNotFrozen(ngp);

        UserProfile userProfile = ar.getUserProfile();

        String taskState = ar.reqParam("state");
        String priority = ar.reqParam("priority");

        GoalRecord task = ngp.getGoalOrFail(parentTaskId);
        int eventType = HistoryRecord.EVENT_TYPE_MODIFIED;
        task.setSynopsis(ar.reqParam("taskname_update"));

        task.setDueDate(SectionUtil.niceParseDate(ar.defParam("dueDate_update","")));
        task.setStartDate(SectionUtil.niceParseDate(ar.defParam("startDate_update","")));
        task.setEndDate(SectionUtil.niceParseDate(ar.defParam("endDate_update","")));

        String assignto= ar.defParam("assignto", null);
        String assigneeAddress = null;

        if (assignto!=null && assignto.length()>0) {
            assigneeAddress = parseEmailId(assignto);
        }
        if(assigneeAddress!=null) {
            //if the assignee is set, use it
            task.getAssigneeRole().addPlayer(new AddressListEntry(assigneeAddress));
        }
        else {
            //if the assignee is not set, then set assignee to the current user.
            task.getAssigneeRole().addPlayer(new AddressListEntry(userProfile));
        }


        String processLink = ar.defParam("processLink", "");
        if (processLink.length()>0) {
            task.setSub(processLink);
        }

        task.setPriority(Integer.parseInt(priority));
        task.setDescription(ar.defParam("description", ""));
        task.setState(Integer.parseInt(taskState));
        if(task.getState()==5){
            task.setPercentComplete(100);
        }


        task.setCreator(userProfile.getUniversalId());
        task.setModifiedDate(ar.nowTime);
        task.setModifiedBy(ar.getBestUserId());

        HistoryRecord.createHistoryRecord(ngp, task.getId(),
                        HistoryRecord.CONTEXT_TYPE_TASK, eventType, ar, "");

        ngp.saveFile(ar, CREATE_TASK);
    }


    private void taskActionCreate(AuthRequest ar, NGPage ngp,
            HttpServletRequest request, String parentTaskId)
            throws Exception
    {
        ar.setPageAccessLevels(ngp);
        ar.assertMember("Must be a member of a project to manipulate tasks.");
        ar.assertNotFrozen(ngp);

        UserProfile userProfile = ar.getUserProfile();

        int eventType;

        GoalRecord task = null;
        GoalRecord parentTask = null;


        boolean isSubTask = (parentTaskId != null && parentTaskId.length() > 0);
        if (isSubTask) {
            parentTask = ngp.getGoalOrFail(parentTaskId);
            task = ngp.createSubGoal(parentTask);
            eventType = HistoryRecord.EVENT_TYPE_SUBTASK_CREATED;
        } else {
            task = ngp.createGoal();
            eventType = HistoryRecord.EVENT_TYPE_CREATED;
        }
        task.setSynopsis(ar.reqParam("taskname"));

        if (isSubTask) {
            // set the subtask's due date.
            task.setDueDate(parentTask.getDueDate());
        } else {
            String duedate = ar.defParam("dueDate","");
            if(duedate.length()>0){
                task.setDueDate(SectionUtil.niceParseDate(duedate));
            }
        }

        String assignto= ar.defParam("assignto", null);

        if (assignto==null || assignto.length()==0) {
            //The assignee is not set, then set assignee to the current user.
            //They can change that later.
            task.getAssigneeRole().addPlayer(new AddressListEntry(userProfile));
        }
        else {
            String assignee = parseEmailId(assignto);
            if(assignee!=null) {
                //if the assignee is set, use it
                task.getAssigneeRole().addPlayer(new AddressListEntry(assignee));
            }
            else {
                //if the assignee is not set, then set assignee to the current user.
                task.getAssigneeRole().addPlayer(new AddressListEntry(userProfile));
            }
        }


        String processLink = ar.defParam("processLink", "");
        if (processLink.length()>0) {
            task.setSub(processLink);
        }

        task.setPriority(Integer.parseInt(ar.reqParam("priority")));
        task.setDescription(ar.defParam("description", ""));
        // should allow the user to specify the desired state, but if not specified,
        // the default should be "offered" when creating a task.

        String startOption=ar.defParam("startActivity", "");
        if(startOption.length()>0){
            task.setState(BaseRecord.STATE_STARTED);
        }else{
            task.setState(BaseRecord.STATE_UNSTARTED);
        }


        task.setCreator(ar.getBestUserId());
        task.setModifiedDate(ar.nowTime);
        task.setModifiedBy(ar.getBestUserId());

        HistoryRecord.createHistoryRecord(ngp, task.getId(),
                        HistoryRecord.CONTEXT_TYPE_TASK, eventType, ar, "");
        ngp.saveFile(ar, CREATE_TASK);
    }


    @RequestMapping(value = "/{siteId}/{pageId}/task{taskId}.htm", method = RequestMethod.GET)
    public ModelAndView displayTask(@PathVariable String siteId,
        @PathVariable String pageId,  @PathVariable String taskId,
        HttpServletRequest request,   HttpServletResponse response)
            throws Exception
    {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);

            GoalRecord task = ngp.getGoalOrFail(taskId);
            boolean canAccessGoal = AccessControl.canAccessGoal(ar, ngp, task);

            if(!canAccessGoal){
                if(!ar.isLoggedIn()){
                    return showWarningView(ar, "message.login.to.see.task.detail");
                }
                if(!ar.isMember()){
                    return showWarningView(ar, "nugen.process.edit.task.memberlogin");
                }
                throw new Exception("Program Logic Error: logged in member should be able to see task.");
            }

            ModelAndView modelAndView = null;
            if(!ar.isLoggedIn()){
                modelAndView=new ModelAndView("displayTaskInfo");
            }else{
                modelAndView=new ModelAndView("editprocess");
                request.setAttribute("bookList",ar.getUserProfile().findAllMemberSites());
            }

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", PROJECT_TASKS);
            request.setAttribute("taskId", taskId);
            return modelAndView;

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.edit.task.page", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/updateTaskStatus.ajax", method = RequestMethod.POST)
    public void handleActivityUpdates(@PathVariable String siteId, @PathVariable String pageId,@RequestParam String pId,
                HttpServletRequest request, HttpServletResponse response) throws Exception
    {
        AuthRequest ar = null;
        try{
            ar = AuthRequest.getOrCreate(request, response);
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertLoggedIn("Can't edit a work item.");
            ar.assertMember("Must be a member of a project to update tasks.");

            String id = ar.reqParam("id");
            GoalRecord task = ngp.getGoalOrFail(id);
            String index=ar.reqParam("index");
            int eventType = HistoryRecord.EVENT_TYPE_MODIFIED;
            String comments = "";
            String action = ar.reqParam("action");
            if (action.equals("Start Offer")) {
                long beginTime = task.getStartDate();
                if (beginTime == 0) {
                    task.setStartDate(ar.nowTime);
                }
                task.setState(BaseRecord.STATE_STARTED);
                eventType = HistoryRecord.EVENT_TYPE_STATE_CHANGE_STARTED;
            } else if (action.equals("Mark Accepted") || action.equals("Accept Activity")) {
                long beginTime = task.getStartDate();
                if (beginTime == 0) {
                    task.setStartDate(ar.nowTime);
                }
                task.setState(BaseRecord.STATE_ACCEPTED);
                eventType = HistoryRecord.EVENT_TYPE_STATE_CHANGE_ACCEPTED;
            } else if (action.equals("Complete Activity")) {
                task.setEndDate(ar.nowTime);
                task.setState(BaseRecord.STATE_COMPLETE);
                task.setPercentComplete(100);
                eventType = HistoryRecord.EVENT_TYPE_STATE_CHANGE_COMPLETE;
            } else if (action.equals("Update Status")) {
                String newStatus = ar.defParam("status", null);
                task.setStatus(newStatus);
            } else if (action.equals("Approve")) {
                eventType = HistoryRecord.EVENT_TYPE_APPROVED;
                task.approve(ar.getBestUserId());
                comments = ar.defParam("reason", "");
            } else if (action.equals("Reject")) {
                eventType = HistoryRecord.EVENT_TYPE_REJECTED;
                task.reject(ar.getBestUserId());
                comments = ar.defParam("reason", "");
            } else {
                throw new NGException("nugen.exceptionhandling.did.not.understand.option", new Object[]{action});
            }

            task.setModifiedDate(ar.nowTime);
            task.setModifiedBy(ar.getBestUserId());
            HistoryRecord.createHistoryRecord(ngp, task.getId(),
                    HistoryRecord.CONTEXT_TYPE_TASK, eventType, ar, comments);

            ngp.saveFile(ar, "Edit Work Item");

            JSONObject jo = new JSONObject();
            jo.put("msgType", "success");
            jo.put("taskId", task.getId());
            jo.put("index", index);
            jo.put("taskState", String.valueOf(task.getState()));
            jo.put("stateImage",BaseRecord.stateImg(task.getState()));
            NGWebUtils.sendResponse(ar, jo.toString());
        }catch (Exception ex) {
            ar.logException("Caught by updateTaskStatus.ajax", ex);
            NGWebUtils.sendResponse(ar, NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale()));
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/reassignTask.htm", method = RequestMethod.GET)
    public ModelAndView showReassignTask(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            ar.assertLoggedIn("Must be logged in to reassign task.");
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertMember("Must be a member of a project to reassign tasks.");

            String taskId = ar.reqParam("taskid");
            GoalRecord task = ngp.getGoalOrFail(taskId);

            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("task", task);
            request.setAttribute("tabId", PROJECT_TASKS);
            return new ModelAndView("reassigntask");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.reassign.task.page",
                    new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/reassignTaskSubmit.form", method = RequestMethod.POST)
    public ModelAndView reassignTask(@PathVariable String siteId,
            @PathVariable String pageId, HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            ar.assertLoggedIn("Must be logged in to reassign task.");
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            ar.assertMember("Must be a member of a project to reassign tasks.");
            ar.assertNotFrozen(ngp);

            String taskId = ar.reqParam("taskid");
            GoalRecord task = ngp.getGoalOrFail(taskId);
            String go = ar.reqParam("go");

            String assignee = null;
            UserProfile userProfile = ar.getUserProfile();

            String assignto = ar.defParam("assignto","");
            if (assignto == null || "".equals(assignto)) {
                assignee = userProfile.getPreferredEmail();
            } else {
                assignee = parseEmailId(assignto);
            }

            String removeUser=ar.defParam("remove","");
            NGRole goalRole = task.getAssigneeRole();
            if(removeUser!=""){
                String removeAssignee= ar.defParam("removeAssignee","") ;
                goalRole.removePlayer(new AddressListEntry(removeAssignee));
            }
            else{
                goalRole.clear();
                goalRole.addPlayer(new AddressListEntry(assignee));
                NGWebUtils.updateUserContactAndSaveUserPage(ar, "Add" ,assignto);
            }

            task.setModifiedDate(ar.nowTime);
            task.setModifiedBy(ar.getBestUserId());
            HistoryRecord.createHistoryRecord(ngp, task.getId(),
                    HistoryRecord.CONTEXT_TYPE_TASK,
                    HistoryRecord.EVENT_TYPE_MODIFIED, ar, "");

            ngp.saveFile(ar, CREATE_TASK);

            return redirectBrowser(ar,go);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.reassign.task",
                    new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/updateTask.form", method = RequestMethod.POST)
    public ModelAndView updateTask(@PathVariable String siteId,
            @PathVariable String pageId,
            @RequestParam String taskId,HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            ar.assertLoggedIn("Must be logged in to update task.");
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);
            String go = ar.reqParam("go");

            taskActionUpdate(ar, ngp, taskId);

            return redirectBrowser(ar,go);
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.update.task", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/errorPage.htm", method = RequestMethod.GET)
     public ModelAndView errorPage(HttpServletRequest request,
            HttpServletResponse response) throws Exception {
        return new ModelAndView(Constant.COMMON_ERROR);
    }

    @RequestMapping(value = "/subProcess.ajax", method = RequestMethod.POST)
    public void searchSubProcess(HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        String responseMessage = "";
        AuthRequest ar = null;
        try{
            ar = AuthRequest.getOrCreate(request, response);
            ar.assertLoggedIn("You need to login to perform this function.");

            String processURL = ar.reqParam("processURL");
            int pcolon = processURL.indexOf(":");
            int pfs = processURL.indexOf("/");

            String processLocation = processURL.substring(0, pcolon);
            String accoundID = processURL.substring(pcolon + 1, pfs);
            String projectID = processURL.substring(pfs + 1, processURL.length());

            JSONObject param = new JSONObject();
            if (processLocation.equalsIgnoreCase("local")) {
                param.put(Constant.MSG_TYPE, SUCCESS_LOCAL);
                param.put(LOCAL_PROJECT, getLocalProcess(accoundID, projectID, ar));
            }else if(processLocation.equalsIgnoreCase("http")){
                param.put(Constant.MSG_TYPE, SUCCESS_REMOTE);
                param.put(Constant.MESSAGE, REMOTE_PROJECT);
            }
            responseMessage = param.toString();
        }catch(Exception ex){
            responseMessage = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by subProcess.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, responseMessage);
    }

    public String getLocalProcess(String siteId, String projectID,
            AuthRequest ar) throws Exception {

        for (NGPageIndex ngpi : NGPageIndex.getAllProjectsInSite(siteId)) {
            NGPage page = ngpi.getPage();
            if (page.getKey().equalsIgnoreCase(projectID)) {
                ar.setPageAccessLevels(page);
                ProcessRecord process = page.getProcess();
                LicensedURL thisProcessUrl = process.getWfxmlLink(ar);
                return thisProcessUrl.getCombinedRepresentation();
            }
            NGPageIndex.releaseLock(page);
        }

        return "No project found";
    }

    @RequestMapping(value = "/{siteId}/{pageId}/statusUpdateForTask.form", method = RequestMethod.POST)
    public ModelAndView statusUpdateForTask(@PathVariable
    String siteId, @PathVariable
    String pageId, @RequestParam
    String taskId,HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            if(!ar.isLoggedIn()){
                super.redirectToLoginPage(ar, "Must be logged in to update task.", new Exception("Must be logged in"));
                return null;
            }
            NGPageIndex.assertBook(siteId);

            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);
            ar.assertMember("Must be a member of a project to manipulate tasks.");
            ar.assertNotFrozen(ngp);

            String accomp=ar.defParam("accomp", "");
            String status=ar.defParam("status", "");
            GoalRecord task  = ngp.getGoalOrFail(taskId);
            task.setStatus(status);
            task.setState(Integer.parseInt(ar.reqParam("states")));
            if(task.getState()==5){
                task.setPercentComplete(100);
            }else{
                task.setPercentComplete(Integer.parseInt(ar.defParam("percentage", "0")));
            }
            int eventType = HistoryRecord.EVENT_TYPE_MODIFIED;

            task.setModifiedDate(ar.nowTime);
            task.setModifiedBy(ar.getBestUserId());
            HistoryRecord.createHistoryRecord(ngp, task.getId(),
                            HistoryRecord.CONTEXT_TYPE_TASK, eventType,
                            ar, accomp);
            String go = ar.reqParam("go");

            ngp.saveFile(ar, "updated a task status");

            return redirectBrowser(ar,go);

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.update.status", new Object[]{pageId,siteId} , ex);
        }
    }

    @RequestMapping(value = "/{siteId}/{pageId}/setOrderTasks.ajax", method = RequestMethod.POST)
    public void updateOrderTasks( @PathVariable String pageId,@RequestParam String indexString,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

        AuthRequest ar = AuthRequest.getOrCreate(request, response);
        String responseMessage = "";
        try{
            ar.assertLoggedIn("You need to login to perform this function.");

            NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);
            ar.assertMember("Must be a member of a project to reorder tasks.");

            List<GoalRecord> tasks = ngp.getAllGoals();

            //Get the ranks of all the tasks from the browser
            Vector<String> idlist = UtilityMethods.splitString(indexString, ',');
            int last = idlist.size();
            int[] previous = new int[last];

            for (int i=0; i<last; i++){
                String taskId=idlist.elementAt(i);
                boolean found = false;
                for (GoalRecord task : tasks) {
                    if(task.getId().equals(taskId)){
                        previous[i] = task.getRank();
                        found = true;
                        break;
                    }
                }
                if (!found) {
                    throw new NGException("nugen.exception.task.not.found", new Object[]{taskId});
                }
            }

            //sort the array so that the tasks will be in order
            Arrays.sort(previous);

            //set the ranks back into the tasks so they take the spot that the
            //other task was in.  In effect, when you reorder tasks, they take
            //the same absolute position that the other task used to have.
            for (int i=0; i<last; i++){
                String taskId=idlist.elementAt(i);
                for (GoalRecord task : tasks) {
                    if(task.getId().equals(taskId)){
                        task.setRank(previous[i]);
                        break;
                    }
                }
            }

            //clean up and normalize into canonical form
            ngp.renumberGoalRanks();

            JSONObject paramMap = new JSONObject();
            paramMap.put(Constant.MSG_TYPE,SUCCESS_LOCAL);
            paramMap.put(Constant.MSG_DETAIL,"Update Order Successfull");
            responseMessage = paramMap.toString();
            ngp.saveFile(ar, "Reordered the tasks");
        }catch (Exception ex) {
            responseMessage = NGWebUtils.getExceptionMessageForAjaxRequest(ex, ar.getLocale());
            ar.logException("Caught by SUCCESS_LOCAL.ajax", ex);
        }
        NGWebUtils.sendResponse(ar, responseMessage);
    }


    @RequestMapping(value = "/{siteId}/{projectId}/tasks.csv", method = RequestMethod.GET)
    public void getTasks( @PathVariable String siteId, @PathVariable String projectId,
            HttpServletRequest request,
            HttpServletResponse response) throws Exception
    {
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            NGPageIndex.assertBook(siteId);
            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(projectId);
            ar.setPageAccessLevels(ngp);
            ar.assertMember("Must be a member of a project to get tasks.");

            response.setContentType("text/csv;charset=UTF-8");
            MultiLevelNumber numbers = new MultiLevelNumber();

            ar.write("Task,Assignee,Status,Percent,StartDate,EndDate,DueDate,Description,ID\n");

            List<GoalRecord> tasks = ngp.getAllGoals();
            for (GoalRecord task : tasks) {

                int percent = task.getCorrectedPercentComplete();
                int taskLevel = determineTaskLevel(task);
                String taskNums = numbers.nextAtLevel(taskLevel);

                writeWithoutCommas(ar,taskNums);
                writeWithoutCommas(ar," ");
                writeWithoutCommas(ar,task.getSynopsis());
                ar.write(",");
                NGRole assignee = task.getAssigneeRole();
                List<AddressListEntry> players = assignee.getExpandedPlayers(ngp);
                boolean needspace = false;
                for (AddressListEntry ale : players) {
                    if (needspace) {
                        ar.write(" ");
                    }
                    writeWithoutCommas(ar,ale.getName());
                    needspace = true;
                }
                ar.write(",");
                writeWithoutCommas(ar,BaseRecord.stateName(task.getState()));
                ar.write(",");
                ar.write(Integer.toString(percent));
                ar.write("%,");
                writeDateForCsv(ar, task.getStartDate());
                ar.write(",");
                writeDateForCsv(ar, task.getEndDate());
                ar.write(",");
                writeDateForCsv(ar, task.getDueDate());
                ar.write(",");
                writeWithoutCommas(ar,task.getDescription());
                ar.write(",");
                writeWithoutCommas(ar,task.getId());
                ar.write("\n");
            }
            ar.flush();

        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.task.csv", new Object[]{projectId,siteId} , ex);
        }
    }

    private int determineTaskLevel(GoalRecord task) throws Exception
    {
        int level=0;
        GoalRecord g3 = task.getParentGoal();
        while (g3 != null)
        {
            level++;
            g3 = g3.getParentGoal();
        }
        return level;
    }

    private void writeWithoutCommas(AuthRequest ar, String str) throws Exception
    {
        StringBuffer stripped = new StringBuffer();
        for (int i=0; i<str.length(); i++)
        {
            char ch = str.charAt(i);

            // just strip commas and returns (all control characters) from text for now
            // there is another mode that uses quotes to allow commas, but not supported yet
            if (ch!=',' && ch>=' ') {
                stripped.append(ch);
            }
        }
        ar.write( stripped.toString() );
    }

    private void writeDateForCsv(AuthRequest ar, long date) throws Exception
    {
        //TODO: figure out how CSV dates are stored
        SectionUtil.nicePrintTimestamp(ar.w, date);
    }
}
