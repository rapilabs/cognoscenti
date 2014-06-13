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

package org.socialbiz.cog.rest;

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.socialbiz.cog.AddressListEntry;
import org.socialbiz.cog.BaseRecord;
import org.socialbiz.cog.DOMUtils;
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.GoalRecord;
import org.socialbiz.cog.RemoteGoal;
import org.socialbiz.cog.UserPage;
import org.socialbiz.cog.UtilityMethods;
import java.util.Hashtable;
import java.util.Vector;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
 * This class represents holds the global id of a particular user, and it
 * helps to build the XML representation of that user's tasks.
 */
public class TaskHelper
{
    private String lserverURL;
    private AddressListEntry ale = null;

    private Hashtable<GoalRecord,NGPage> pageMap = new Hashtable<GoalRecord,NGPage>();
    private Vector<GoalRecord> allTask = new Vector<GoalRecord>();
    private Vector<GoalRecord> activeTask = new Vector<GoalRecord>();
    private Vector<GoalRecord> completedTask = new Vector<GoalRecord>();
    private Vector<GoalRecord> futureTask = new Vector<GoalRecord>();

    private boolean isFilled = false;

    public TaskHelper(String uopenid, String serverURL)
    {
        lserverURL = serverURL;
        ale = new AddressListEntry(uopenid);
    }

    /**
     * This method GENERATES a list of XML document elements representing the
     * current collection of tasks so that they can be sent out in response to a
     * REST request.
     */
    public void fillInTaskList(Document doc, Element element_activities, String filter)
            throws Exception {
        if (!isFilled) {
            throw new ProgramLogicError(
                    "Attempt to produce a task list, but the tasks have not been collected yet.");
        }
        Vector<GoalRecord> taskList = null;
        if (NGResource.DATA_ALLTASK_XML.equals(filter)) {
            taskList = allTask;
        }
        else if (NGResource.DATA_ACTIVETASK_XML.equals(filter)) {
            taskList = activeTask;
        }
        else if (NGResource.DATA_COMPLETETASK_XML.equals(filter)) {
            taskList = completedTask;
        }
        else if (NGResource.DATA_FUTURETASK_XML.equals(filter)) {
            taskList = futureTask;
        }
        else {
            // this is a program logic error
            throw new ProgramLogicError("Don't understand the filter: " + filter);
        }

        for (GoalRecord tr : taskList) {
            Element actEle = DOMUtils.createChildElement(doc, element_activities, "activity");
            NGPage ngp = pageMap.get(tr);
            String processurl = lserverURL + "p/" + ngp.getKey() + "/process.xml";
            tr.fillInWfxmlActivity(doc, actEle, processurl);
        }
    }


    public void scanAllTask() throws Exception
    {
        if (isFilled) {
            throw new ProgramLogicError("Attempting to fill a TaskHelper twice!  Probably an error.");
            //could change the logic to clear out the collections at this point, but
            //adding an exception here so we can learn if this ever happens.
        }
        NGPageIndex pindxlist[] = NGPageIndex.getAllPageIndex();
        if (pindxlist==null)
        {
            //this can happen if the server has been restarted and not yet
            //initialized.  What to do?  Thos exception
            throw new NGException("nugen.exception.server.uninitialized",null);
        }
        for (NGPageIndex ngpi : pindxlist)
        {
            //only includes tasks from projects at this point
            if (ngpi.isProject())
            {
                NGPage aProject = ngpi.getPage();
                scanPageTask(aProject, false);
            }
        }
        isFilled = true;
    }

    private void scanPageTask(NGPage aProject, boolean ignoreUser) throws Exception
    {
        for(GoalRecord tr : aProject.getAllGoals())
        {
            boolean myWi = true;
            if(!ignoreUser)
            {
                myWi = tr.isAssignee(ale);
            }
            if(myWi)
            {
                pageMap.put(tr, aProject);
                allTask.add(tr);
                int state = tr.getState();
                if(state == BaseRecord.STATE_ERROR){
                    activeTask.add(tr);
                }else if(state == BaseRecord.STATE_ACCEPTED){
                    activeTask.add(tr);
                }else if(state == BaseRecord.STATE_STARTED){
                    activeTask.add(tr);
                }else if(state == BaseRecord.STATE_WAITING){
                    activeTask.add(tr);
                }else if(state == BaseRecord.STATE_UNSTARTED){
                    futureTask.add(tr);
                }else if(state == BaseRecord.STATE_COMPLETE){
                    completedTask.add(tr);
                }

            }
        }
    }

    /**
    * loads the tasks from all pages, and then, given a list of task ids, it
    * generate an XML dom tree from the tasks specifically mentioned by ID.
    */
    public void loadTasData(NGPage ngp, Document doc, Element element_activities, String dataIds)
        throws Exception
    {
        String[] idList = null;
        if (dataIds!= null) {
            idList = UtilityMethods.splitOnDelimiter(dataIds,',');
        }
        scanPageTask(ngp, true);
        for(GoalRecord tr : allTask)
        {
            if(!isRequested(tr.getId(), idList))
            {
                continue;
            }
            Element actEle = DOMUtils.createChildElement(doc, element_activities, "activity");
            String processurl = lserverURL + "p/" + ngp.getKey() + "/process.xml";
            tr.fillInWfxmlActivity(doc, actEle, processurl);
        }
    }

    private  boolean isRequested(String id, String[] idList) throws Exception
    {
        if(idList == null){
            return true;
        }
        for(String test : idList){
            if(id.equals(test))
            {
                return true;
            }
        }
        return false;
    }


    public Vector<GoalRecord> getAllTasks() {
        if (!isFilled) {
            throw new ProgramLogicError("Attempt to get a task list, but the tasks have not been collected yet.");
        }
        return allTask;
    }
    public Vector<GoalRecord> getActiveTasks() {
        if (!isFilled) {
            throw new ProgramLogicError("Attempt to get a task list, but the tasks have not been collected yet.");
        }
        return activeTask;
    }
    public Vector<GoalRecord> getCompletedTasks() {
        if (!isFilled) {
            throw new ProgramLogicError("Attempt to get a task list, but the tasks have not been collected yet.");
        }
        return completedTask;
    }
    public Vector<GoalRecord> getFutureTasks() {
        if (!isFilled) {
            throw new ProgramLogicError("Attempt to get a task list, but the tasks have not been collected yet.");
        }
        return futureTask;
    }
    public NGContainer getPageForTask(GoalRecord tr) {
        if (!isFilled) {
            throw new ProgramLogicError("Attempt to get a task list, but the tasks have not been collected yet.");
        }
        return pageMap.get(tr);
    }


    public void syncTasksToProfile(UserPage uPage) throws Exception {
        if (!isFilled) {
            scanAllTask();
        }

        uPage.clearTaskRefFlags();
        for (GoalRecord existingTask : allTask) {
            int state = existingTask.getState();
            if (state == BaseRecord.STATE_STARTED ||
                state == BaseRecord.STATE_ACCEPTED)  {
                NGPage proj = pageMap.get(existingTask);
                RemoteGoal ref = uPage.findOrCreateTask( proj.getKey(), existingTask.getId() );
                ref.touchFlag = true;
                ref.syncFromTask(existingTask);
            }
        }

        Vector<RemoteGoal> untouched = new Vector<RemoteGoal>();
        for (RemoteGoal ref : uPage.getRemoteGoals()) {

            if (!ref.touchFlag) {
                untouched.add(ref);
            }
        }

        for (RemoteGoal dangler : untouched) {
            uPage.deleteTask(dangler.getProjectKey(), dangler.getId());
        }

        //renumber, rerank the tasks
        uPage.cleanUpTaskRanks();

    }


}
