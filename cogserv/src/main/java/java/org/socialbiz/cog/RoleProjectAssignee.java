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

import java.util.ArrayList;
import java.util.List;

import org.socialbiz.cog.exception.NGException;

/**
 * Each page can have a role that represents the members of the page, and this
 * object represents that as a NGRole object.
 */
public class RoleProjectAssignee extends RoleSpecialBase implements NGRole {
    NGPage ngp;

    RoleProjectAssignee(NGPage newPage) {
        ngp = newPage;
    }

    public String getName() {
        return "Assignees";
    }

    /**
     * A description of the purpose of the role, suitable for display to user.
     */
    public String getDescription() {
        return "Assignees of tasks in the project " + ngp.getFullName();
    }

    public List<AddressListEntry> getDirectPlayers() throws Exception {
        List<AddressListEntry> list = new ArrayList<AddressListEntry>();
        for (GoalRecord task : ngp.getAllGoals()) {
            if (task.getState() == BaseRecord.STATE_ACCEPTED) {
                NGRole assignees = task.getAssigneeRole();
                list.addAll(assignees.getDirectPlayers());
            }
        }
        return list;
    }

    public void addPlayer(AddressListEntry newMember) throws Exception {
        throw new NGException(
                "nugen.exception.cant.add.or.remove.role.directly", null);
    }

    public void removePlayer(AddressListEntry oldMember) throws Exception {
        throw new NGException(
                "nugen.exception.cant.add.or.remove.role.directly", null);
    }

}
