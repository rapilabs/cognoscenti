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

import org.socialbiz.cog.AddressListEntry;

/**
* This is for email messages which are sent to the Super Admin
* and you really can't opt out of that responsibility.
* So this makes a message that says that.
*/
public class OptOutRolePlayer extends OptOutAddr {

    String containerID;
    String roleName;

    public OptOutRolePlayer(AddressListEntry _assignee, String containerKey, String _roleName) {
        super(_assignee);
        if (assignee.getEmail()==null || assignee.getEmail().length()==0) {
            throw new RuntimeException("Somehow got an opt out addressee with a missing email address.  Should not happen");
        }
        containerID = containerKey;
        roleName = _roleName;
    }

    public void writeUnsubscribeLink(AuthRequest clone) throws Exception {
        String emailId = assignee.getEmail();
        if (emailId==null || emailId.length()==0) {
            throw new Exception("There is a problem with this addressee, the email field is blank????");
        }
        NGContainer ngc = NGPageIndex.getContainerByKey(containerID);

        //if the project no longer exists, then just use the generic response.
        if (ngc==null) {
            super.writeUnsubscribeLink(clone);
            return;
        }

        writeSentToMsg(clone);
        clone.write("\n You have received this message because you are a player of the <b>'");
        clone.writeHtml(roleName);
        clone.write("'</b> role in the '");
        ngc.writeContainerLink(clone, 100);
        clone.write("' project.  ");
        clone.write("You can ");
        clone.write("<a href=\"");
        clone.writeHtml(clone.baseURL);
        clone.write("t/EmailAdjustment.htm?st=role&p=");
        clone.writeURLData(containerID);
        clone.write("&role=");
        clone.writeURLData(roleName);
        clone.write("&email=");
        clone.writeURLData(emailId);
        clone.write("&mn=");
        clone.writeURLData(ngc.emailDependentMagicNumber(emailId));
        clone.write("\">withdraw from that role</a> if you no longer want to be involved and receive email for the role. ");
        writeConcludingPart(clone);
        NGPageIndex.releaseLock(ngc);
    }

}
