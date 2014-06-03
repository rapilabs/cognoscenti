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
import java.io.File;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;
import javax.servlet.http.HttpSession;
import javax.servlet.ServletContext;

/**
* Holds things that are persistent for a user across a session
*/
public class NGSession
{
    public Vector<RUElement> recentlyVisited = new Vector<RUElement>();

    /**
    * table of page ids that this session is an honorary member of
    * because of using a special license.  This persists for the
    * duration of the session.
    */
    private Hashtable<String,String> honorarium = new Hashtable<String,String>();

    /**
    * This is the wrapped session object
    */
    private HttpSession session;

    /**
    * Construct an NGSession object to hold information for this
    * browser session.
    *
    * Why not pass the http session to it and store a reference?
    * The reason is that the HttpSession object will be serialized out
    * and then serialized back in again.  Will the reference be preserved
    * through that?  I don't think so.
    */
    public NGSession(HttpSession n_session)
    {
        session = n_session;
    }

    public void addVisited(NGContainer ngp, long currentTime)
    {
        if (ngp==null)
        {
            throw new ProgramLogicError("addVisited was called with a null parameter.  That should not happen");
        }
        RUElement rue = new RUElement(ngp.getFullName(), ngp.getKey(), currentTime);
        RUElement.addToRUVector(recentlyVisited, rue, currentTime, 12);
    }


    /**
    * Configuration values are cached, but this method will clear the
    * cache and force the config to be read from disk again.
    * This can be called at any time, and only effect performance.
    */
    public void flushConfigCache()
    {
    }


    /**
    * pass in the simple file name of a file that exists in the server's
    * local config file, and this will return a File object with the
    * full path to that file (whether it exists or not).
    */
    public File getConfigDirFile(String fileName)
    {
        ServletContext sc = session.getServletContext();
        String configPath = sc.getRealPath("WEB-INF/"+fileName);
        return new File(configPath);
    }


    public void addHonoraryMember(String pageId)
    {
        honorarium.put(pageId, pageId);
    }

    public boolean isHonoraryMember(String pageId)
    {
        return (honorarium.get(pageId)!=null);
    }

    /**
    * Get rid of all marks in the session about this user or any
    * rights or capabilities that the usr might have, including:
    *    session.setAttribute("userKey", null);
    *    session.removeAttribute("specialAccessUser");
    *
    * This method gets rid of ALL attributes...
    */
    public void deleteAllSpecialSessionAccess(){
        @SuppressWarnings("unchecked")
        Enumeration<String> e = session.getAttributeNames();
        while (e.hasMoreElements()) {
            String attribute = e.nextElement();
            session.removeAttribute(attribute);
        }
    }

    /**
    * Get the user key of the currently logged in user (if there is any)
    * or return null if not.
    */
    public String findLoginUserKey() {
        return (String) session.getAttribute("userKey");
    }

    /**
    * Get the user profile of the currently logged in user (if there is any)
    * or return null if not.
    */
    public UserProfile findLoginUserProfile() {
        String key = findLoginUserKey();
        if (key==null) {
            return null;
        }
        return UserManager.getUserProfileByKey(key);
    }

    /**
    * make the proper markings in the session to remember who the logged
    * in user is.  This should only be called when the user is POSITIVELY
    * identified, such as after logging in.
    */
    public void setLoggedInUser(UserProfile user, String loginId) throws Exception {
        session.setAttribute("userKey", user.getKey());
        user.setLastLogin(System.currentTimeMillis(), loginId);
        UserManager.writeUserProfilesToFile();
    }

}
