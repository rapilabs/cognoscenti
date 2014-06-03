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

package org.socialbiz.cog.api;

import java.net.URL;
import java.util.Hashtable;
import java.io.InputStream;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.socialbiz.cog.RemoteGoal;
import org.socialbiz.cog.UserPage;

/**
* A remote profile represents a user on a remote site and is accessed
* purely through URLs and REST oriented web services
*/
public class RemoteProfile {
    URL        url;

    public RemoteProfile(String urlStr) throws Exception {
        url = new URL(urlStr);
    }


    /**
     * Send a JSONObject to this server as a POST and
     * get a JSONObject back with the response.
     */
    public void syncRemoteGoals(UserPage uPage) throws Exception {
        try {
            InputStream is = url.openStream();
            JSONTokener jt = new JSONTokener(is);
            JSONObject root = new JSONObject(jt);
            Hashtable<String, RemoteGoal> usedTable = new Hashtable<String, RemoteGoal>();

            JSONArray goals = root.getJSONArray("goals");

            uPage.clearTaskRefFlags();
            int numGoals = goals.length();
            for (int i=0; i<numGoals; i++) {
                JSONObject oneGoal = goals.getJSONObject(i);
                String accessURL = oneGoal.getString("goalinfo");
                RemoteGoal remGoal = uPage.findOrCreateRemoteGoal(accessURL);
                usedTable.put(remGoal.getAccessURL(), remGoal);
                remGoal.setFromJSONObject(oneGoal);
            }

            //now, update the ones that did not come in the task list
            //for some reason (maybe they are closed, cancelled, or reassigned)
            for (RemoteGoal remGoal : uPage.getRemoteGoals()) {
                if (!usedTable.containsKey(remGoal.getId())) {
                    remGoal.refreshFromRemote();
                }
            }
        }
        catch (Exception e) {
            throw new Exception("Unable to sync goals from remote profile url="+url, e);
        }
    }

    Hashtable<String,RemoteProject> projIndex = new Hashtable<String,RemoteProject>();

    private RemoteProject getProject(String urlStr) throws Exception {
        RemoteProject rp = projIndex.get(urlStr);
        if (rp==null) {
            rp = new RemoteProject(urlStr);
            projIndex.put(urlStr, rp);
        }
        return rp;
    }

}
