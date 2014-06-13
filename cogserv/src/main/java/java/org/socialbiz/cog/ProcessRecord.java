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

import org.socialbiz.cog.exception.ProgramLogicError;
import java.util.Enumeration;
import java.util.List;
import java.util.Vector;
import org.w3c.dom.Document;
import org.w3c.dom.Element;


public class ProcessRecord extends BaseRecord
{
    //NGSection section;
    public ProcessRecord(Document definingDoc, Element definingElement, DOMFace p)
        throws Exception
    {
        super(definingDoc, definingElement, p);

        // the process has a license token for RECEIVING interaction requests
        // someday parent links will have such licenses as well, but for now
        // we can use this.
        // force generation of license, & force cleanup of old XML
        accessLicense();
    }

   public int getState()
        throws Exception
    {
        String stateVal = getScalar("state");
        return (int) safeConvertLong(stateVal);
    }

    public void setState(int newVal) throws Exception {
        if (getState() != newVal) {
            setScalar("state", Integer.toString(newVal));

            //this code used to update contained goals from a state
            //change in the process overall, but this is broken
            //and has been broken for a while.
            //TODO: investigate whether this needs to be fixed
            /*
            NGPage ngp = null;
            if (ngp!=null) {
                handleProcessStateChangeEvent(ngp, newVal);
            }
            */
        }
    }

    public void updateStatusFromGoals(List<GoalRecord> allGoals)  throws Exception
    {
        //if any task is in the waiting state, then the process is also.
        for (GoalRecord tr : allGoals) {
            if (tr.getState() == BaseRecord.STATE_WAITING) {
                setState(BaseRecord.STATE_WAITING);
                return;
            }
        }

        //nothing is waiting, so check if anything preventing being done
        for (GoalRecord goal : allGoals)
        {
            int state = goal.getState();
            if (state == BaseRecord.STATE_UNSTARTED ||
                    state == BaseRecord.STATE_STARTED ||
                    state == BaseRecord.STATE_ACCEPTED ||
                    state == BaseRecord.STATE_ERROR) {
                //don't change anything
                return;
            }
        }

        //OK, we can mark this as complete now.
        setState(BaseRecord.STATE_COMPLETE);
    }

    //TODO: can this be eliminated?
    /*
    private void handleProcessStateChangeEvent(NGPage ngp, int newState) throws Exception
    {
        List<GoalRecord> goalList = ngp.getAllGoals();

        if (newState == BaseRecord.STATE_COMPLETE ||
                newState == BaseRecord.STATE_SKIPPED)
        {
            // change the state of the existing incomplete tasks based on process state.
            for (GoalRecord goal : goalList)
            {
                int tstate = goal.getState();

                if (tstate == BaseRecord.STATE_ACCEPTED ||
                    tstate == BaseRecord.STATE_ERROR ||
                    tstate == BaseRecord.STATE_WAITING)
                {
                    goal.setState(BaseRecord.STATE_COMPLETE);
                    goal.setPercentComplete(100);
                }
                else if (tstate == BaseRecord.STATE_UNSTARTED ||
                         tstate == BaseRecord.STATE_STARTED)
                {
                    goal.setState(BaseRecord.STATE_SKIPPED);
                }
            }
        }
        else if (newState == BaseRecord.STATE_STARTED ||
                newState == BaseRecord.STATE_ACCEPTED)
        {
            ProcessEnactor.startTheNextTask(goalList, null);
        }
    }
    */

    /**
    * Generates a fully qualified, licensed,  Wf-XML link for this process
    * This is the link someone else would use to get to this process.
    * AuthRequest is needed to know the current server context path
    */
    public LicensedURL getWfxmlLink(AuthRequest ar)
        throws Exception
    {
        NGContainer ngp = ar.ngp;
        if (ngp==null)
        {
            throw new ProgramLogicError("the NGPage must be loaded into the AuthRequest for getWfxmlLink to work");
        }
        return new LicensedURL(
            ar.baseURL + "p/" + ngp.getKey() + "/process.xml",
            ngp.getKey(),
            accessLicense().getId());
    }


    public LicensedURL[] getLicensedParents()
        throws Exception
    {
        DOMFace ppEle = getChild("parentProcesses", DOMFace.class);
        if (ppEle == null)
        {
            return new LicensedURL[0];
        }

        Vector<DOMFace> vect = ppEle.getChildren("parentProcess", DOMFace.class);
        LicensedURL[] parents = new LicensedURL[vect.size()];
        Enumeration<DOMFace> en = vect.elements();
        for (int i=0; en.hasMoreElements(); i++)
        {
            DOMFace ele = en.nextElement();

            //need to migrate old documents in some cases
            //used to put the URL in the attribute called name
            //so if that exists, convert it over.
            String nameAttr = ele.getAttribute("name");
            if (nameAttr.length()>0)
            {
                ele.setAttribute("name", null);
                ele.setTextContents(nameAttr);
            }

            parents[i] = LicensedURL.parseDOMElement(ele);
        }
        return parents;
    }

    public void setLicensedParents(LicensedURL[] parentProcesses)
        throws Exception
    {
        if (parentProcesses == null)
        {
            throw new ProgramLogicError("null value passed to setLicensedParents, this should never happen");
        }

        DOMFace ppEle = requireChild("parentProcesses", DOMFace.class);

        ppEle.clearVector("parentProcess");

        for (int i=0; i<parentProcesses.length; i++)
        {
            LicensedURL parent = parentProcesses[i];
            DOMFace child = ppEle.createChild("parentProcess", DOMFace.class);
            parent.setDOMElement(child);
        }
    }


    public void addLicensedParent(LicensedURL newParent)
        throws Exception
    {
        if (newParent == null)
        {
            throw new ProgramLogicError("null value passed to addLicensedParent, this should never happen");
        }

        DOMFace ppEle = requireChild("parentProcesses", DOMFace.class);
        DOMFace child = ppEle.createChild("parentProcess", DOMFace.class);
        newParent.setDOMElement(child);
    }





    /**
    * @deprecated
    */
    public void setParentProcesses(String[] parentProcesses) throws Exception
    {
        LicensedURL[] lps = new LicensedURL[parentProcesses.length];
        for (int i=0; i<parentProcesses.length; i++)
        {
            lps[i] = new LicensedURL(parentProcesses[i]);
        }
        setLicensedParents(lps);
    }


    public void fillInWfxmlProcess(Document doc, Element processEle, NGPage ngp, String processurl)
        throws Exception
    {
        if (doc == null || processEle == null) {
            return;
        }

        processEle.setAttribute("id", getId());

        DOMUtils.createChildElement(doc, processEle, "key", processurl);
        DOMUtils.createChildElement(doc, processEle, "display", "public.htm");
        DOMUtils.createChildElement(doc, processEle, "synopsis", getSynopsis());
        DOMUtils.createChildElement(doc, processEle, "description", getDescription());
        DOMUtils.createChildElement(doc, processEle, "priority", String.valueOf(getPriority()));
        DOMUtils.createChildElement(doc, processEle, "duedate", UtilityMethods.getXMLDateFormat(getDueDate()));
        DOMUtils.createChildElement(doc, processEle, "startdate", UtilityMethods.getXMLDateFormat(getStartDate()));
        DOMUtils.createChildElement(doc, processEle, "enddate", UtilityMethods.getXMLDateFormat(getEndDate()));

        LicensedURL[] parentlist = getLicensedParents();
        Element element_parents = DOMUtils.createChildElement(doc, processEle, "parentprocesses");
        for(int i=0; i<parentlist.length; i++)
        {
            String parent = parentlist[i].url;
            //we DON'T include the user name and password here ... that is kept private
            DOMUtils.createChildElement(doc, element_parents, "url", parent);
        }

        DOMUtils.createChildElement(doc, processEle, "state", Integer.toString(getState()));

        List<HistoryRecord> histRecs = ngp.getAllHistory();
        if (histRecs.size()>0)
        {
            Element histEle = DOMUtils.createChildElement(doc, processEle, "history");
            DOMUtils.createChildElement(doc, histEle, "processurl", processurl);

            for (HistoryRecord history : histRecs) {
                history.fillInWfxmlHistory(doc, histEle);
            }
        }

        Element actsEle = DOMUtils.getOrCreateChild(doc, processEle, "activities");
        for (GoalRecord gr : ngp.getAllGoals())
        {
            Element actEle = DOMUtils.createChildElement(doc, actsEle, "activity");
            gr.fillInWfxmlActivity(doc, actEle, processurl);
        }

    }




    public List<HistoryRecord> getAllHistory()
            throws Exception
    {
        DOMFace historyContainer = requireChild("history", DOMFace.class);
        Vector<HistoryRecord> vect = historyContainer.getChildren("event", HistoryRecord.class);
        HistoryRecord.sortByTimeStamp(vect);
        return vect;
    }



    /**
    * the ID is missing
    */
    public HistoryRecord createPartialHistoryRecord()
        throws Exception
    {
        DOMFace historyContainer = requireChild("history", DOMFace.class);
        return historyContainer.createChild("event", HistoryRecord.class);
    }


}
