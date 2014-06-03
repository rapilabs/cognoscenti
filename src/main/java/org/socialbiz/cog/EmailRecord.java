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

import java.util.Vector;

import org.socialbiz.cog.exception.NGException;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class EmailRecord extends DOMFace
{

    public static final String READY_TO_GO = "Ready";
    public static final String SENT = "Sent";
    public static final String FAILED = "Failed";

    public EmailRecord(Document doc, Element upEle, DOMFace p)
    {
        super(doc,upEle, p);
    }

    public String getId()
    {
        String val = getAttribute("id");
        if (val==null)
        {
            return "";
        }
        return val;
    }
    public void setId(String id)
    {
        setAttribute("id", id);
    }

    public String getFromAddress() {
        return getAttribute("fromAddress");
    }
    public void setFromAddress(String fromAddress) {
        setAttribute("fromAddress",fromAddress);
    }

    public Vector<OptOutAddr> getAddressees() throws Exception {
        Vector<DOMFace> children = getChildren("to", DOMFace.class);

        Vector<OptOutAddr> res = new Vector<OptOutAddr>();
        for (DOMFace assignee : children) {

            String ootype = assignee.getAttribute("ootype");
            String email = assignee.getAttribute("email");
            AddressListEntry ale = new AddressListEntry(email);
            if ("Role".equals(ootype)) {
                String containerID = assignee.getAttribute("containerID");
                String roleName = assignee.getAttribute("roleName");
                res.add(new OptOutRolePlayer(ale, containerID, roleName));
            }
            else if ("Super".equals(ootype)) {
                res.add(new OptOutSuperAdmin(ale));
            }
            else if ("Indiv".equals(ootype)) {
                res.add(new OptOutIndividualRequest(ale));
            }
            else if ("Direct".equals(ootype)) {
                res.add(new OptOutDirectAddress(ale));
            }
            else {
                res.add(new OptOutAddr(ale));
            }
        }
        return res;
    }


    public void setAddressees(Vector<OptOutAddr> inad) throws Exception {
        removeAllNamedChild("to");
        for (OptOutAddr ooa : inad) {

            DOMFace assignee = createChild("to", DOMFace.class);
            assignee.setAttribute("email", ooa.getEmail());
            if (ooa instanceof OptOutRolePlayer) {
                OptOutRolePlayer oorm = (OptOutRolePlayer) ooa;
                assignee.setAttribute("ootype", "Role");
                assignee.setAttribute("containerID", oorm.containerID);
                assignee.setAttribute("roleName", oorm.roleName);
            }
            else if (ooa instanceof OptOutSuperAdmin) {
                assignee.setAttribute("ootype", "Super");
            }
            else if (ooa instanceof OptOutIndividualRequest) {
                assignee.setAttribute("ootype", "Indiv");
            }
            else if (ooa instanceof OptOutDirectAddress) {
                assignee.setAttribute("ootype", "Direct");
            }
            else {
                assignee.setAttribute("ootype", "Gen");
            }
        }
    }

    public String getCcAddress() {
        return getScalar("ccAddress");
    }
    public void setCcAddress(String ccAddress) {
        setScalar("ccAddress",ccAddress);
    }

    /**
    * The body is the message without the unsubscribe part
    */
    public String getBodyText() {
        return getScalar("bodyText");
    }
    public void setBodyText(String bodyText) {
        setScalar("bodyText",bodyText);
    }

    public String getStatus() {
        return getAttribute("status");
    }
    public void setStatus(String status) {
        setAttribute("status",status);
    }
    public boolean statusReadyToSend() {
        return READY_TO_GO.equals(getAttribute("status"));
    }

    public long getLastSentDate() {
        return safeConvertLong(getAttribute("lastSentDate"));
    }
    public void setLastSentDate(long sentDate) {
        setAttribute("lastSentDate",String.valueOf(sentDate));
    }

    public String getSubject() {
        return getAttribute("subject");
    }
    public void setSubject(String subject) {
        setAttribute("subject",subject);
    }

    public String getProjectId() {
        return getAttribute("projectId");
    }
    public void setProjectId(String projectId) {
        setAttribute("projectId",projectId);
    }

    public long getCreateDate() {
        return safeConvertLong(getAttribute("createDate"));
    }
    public void setCreateDate(long createDate) {
        setAttribute("createDate",String.valueOf(createDate));
    }

    public String getExceptionMessage() {
        return getScalar("exception");
    }
    public void setExceptionMessage(Exception e) {
        setScalar("exception", NGException.getFullMessage(e));
    }

    public Vector<String> getAttachmentIds() {
        return getVector("attachid");
    }
    public void setAttachmentIds(Vector<String> ids) {
        setVector("attachid", ids);
    }

}
