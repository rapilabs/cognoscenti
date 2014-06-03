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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.StringTokenizer;
import java.util.Vector;

import org.w3c.dom.Document;

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.socialbiz.cog.util.PasswordEncrypter;

public class UserManager
{
    private static Hashtable<String, UserProfile> userHashByUID = new Hashtable<String, UserProfile>();
    private static Hashtable<String, UserProfile> userHashByKey = new Hashtable<String, UserProfile>();
    private static Vector<UserProfile> allUsers = new Vector<UserProfile>();

    private static boolean initialized = false;

    private static DOMFile  profileFile;

    /**
    * Set all static values back to their initial states, so that
    * garbage collection can be done, and subsequently, the
    * class will be reinitialized.
    */
    public synchronized static void clearAllStaticVars()
    {
        userHashByUID = new Hashtable<String, UserProfile>();
        userHashByKey = new Hashtable<String, UserProfile>();
        allUsers      = new Vector<UserProfile>();
        initialized   = false;
        profileFile   = null;
    }


    public synchronized static void loadUpUserProfilesInMemory()
        throws Exception
    {
        //check to see if this has already been loaded, if so, there is nothing to do
        if (initialized)
        {
            return;
        }

        String userFolder = ConfigFile.getProperty("userFolder");
        File newPlace = new File(userFolder, "UserProfiles.xml");

        //check to see if the file is there
        if (!newPlace.exists())  {
            //it might be in the old position.
            File oldPlace = ConfigFile.getFile("UserProfiles.xml");
            if (oldPlace.exists()) {
                DOMFile.moveFile(oldPlace, newPlace);
            }
        }

        //clear out any left over evidence of an earlier initialization
        allUsers = new Vector<UserProfile>();

        Document userDoc = null;
        if(!newPlace.exists())
        {
            // create the user profile file.
            userDoc = DOMUtils.createDocument("userprofiles");
            profileFile = new DOMFile(newPlace, userDoc);
            writeUserProfilesToFile();
        }
        else
        {
            InputStream is = new FileInputStream(newPlace);
            userDoc = DOMUtils.convertInputStreamToDocument(is, false, false);
        }
        profileFile = new DOMFile(newPlace, userDoc);

        //there was some kind of but that allowed multiple entries to be created
        //with the same unique key, and that causes all sorts of problems.
        //This code will check and make sure that every Key value is unique.
        //if a duplicate is found (which might happen when someone edits this
        //file externally, then a new unique key is substituted.  This is OK
        //because the openid is ID that is stored in pages.  It does change the
        //URL for that user, but we have no choice ... some other user has that URL.
        Hashtable<String, String> guaranteeUnique = new Hashtable<String, String>();
        Vector<UserProfile> profiles = profileFile.getChildren("userprofile", UserProfile.class);
        for (UserProfile up : profiles) {
            String upKey = up.getKey();
            if (guaranteeUnique.containsKey(upKey)) {
                upKey = IdGenerator.generateKey();
                up.setKey(upKey);
            }

            guaranteeUnique.put(upKey, upKey);
            allUsers.add(up);
        }
        refreshHashtables();
        if (profileFile == null) {
            throw new ProgramLogicError("ended up with profileFile null.!?!?!");
        }

        initialized = true;
    }


    public static void reloadUserProfiles() throws Exception
    {
        clearAllStaticVars();
        loadUpUserProfilesInMemory();
    }

    public static void refreshHashtables()
    {
        userHashByUID = new Hashtable<String, UserProfile>();
        userHashByKey = new Hashtable<String, UserProfile>();

        for (UserProfile up : allUsers)
        {
            for (IDRecord idrec : up.getIdList())
            {
                String idval = idrec.getLoginId();
                if (idval!=null)
                {
                    userHashByUID.put(idval, up);
                }
            }
            userHashByKey.put(up.getKey(), up);
        }
    }


    /**
    * The user "key" is the 9 character unique hash value given them by system
    */
    public static UserProfile getUserProfileByKey(String key)
    {
        if (key == null)
        {
            throw new RuntimeException("getUserProfileByKey requires a non-null key as a parameter");
        }
        return userHashByKey.get(key);
    }
    public static UserProfile getUserProfileOrFail(String key)
        throws Exception
    {
        UserProfile up = getUserProfileByKey(key);
        if (up == null)
        {
            throw new NGException("nugen.exception.user.profile.not.exist", new Object[]{key});
        }
        return up;
    }

    /**
    * Given an id, may be openid or email address, this will attempt
    * to find the existing user profile that has that id.  If it can not
    * find one that is existing, it will return null.
    *
    * Should ONLY fid by confirmed IDs, not by any proposed IDs.
    */
    public static UserProfile findUserByAnyId(String anyId)
    {
        //return null if a bogus value passed.
        //fixed bug 12/20/2010 hat was finging people with nullstring names
        if (anyId==null || anyId.length()==0)
        {
            return null;
        }

        //first, try hashtable since that might be fast
        UserProfile up = userHashByUID.get(anyId);
        if (up!=null)
        {
            //this should always be true at this point
            if (up.hasAnyId(anyId))
            {
                return up;
            }

            //if it gets here, then the hash table is messed up.
            //rather than throw exception ... just regenerate
            //the hash table, then drop into slow search.
            refreshHashtables();
        }

        //second, walk through users the slow way
        for (UserProfile up2 : allUsers)
        {
            if (up2.hasAnyId(anyId))
            {
                return up2;
            }
        }

        //did not find one, return null
        return null;
    }

    public static UserProfile findUserByAnyIdOrFail(String anyId){
        UserProfile up = findUserByAnyId(anyId);
        if (up == null)
        {
            throw new RuntimeException("Can not find a user profile for the id: "+anyId);
        }
        return up;
    }

    public static UserProfile createUserWithId(String newId)
        throws Exception
    {
        //lets make sure that no other profile has that id first,
        //to avoid any complicated situations.
        UserProfile up = UserManager.findUserByAnyId(newId);
        if (up!=null)
        {
            throw new ProgramLogicError("Can not create a new user profile using an address that some other profile already has: "+newId);
        }

        up = createUserProfile();
        up.addId(newId);
        return up;
    }

    public static UserProfile createUserProfile()
        throws Exception
    {
        if (profileFile==null)
        {
            throw new ProgramLogicError("profileFile is null when it shoudl not be.  May not have been initialized correctly.");
        }
        UserProfile nu = profileFile.createChild("userprofile", UserProfile.class);
        allUsers.add(nu);
        refreshHashtables();
        return nu;
    }


    static public String getUserFullNameList() {
        if (userHashByUID == null) {
            return "";
        }
        StringBuffer sb = new StringBuffer();
        boolean addComma = false;
        for (String oid : userHashByUID.keySet()) {
            UserProfile up = userHashByUID.get(oid);
            if (addComma) {
                sb.append(",");
            }
            sb.append("\"");
            sb.append(up.getName());
            sb.append("<");
            sb.append(oid);
            sb.append(">");
            sb.append("\"");
            addComma = true;
        }
        String str = sb.toString();
        return str;
    }

    public static UserProfile[] getAllUserProfiles() throws Exception
    {
        UserProfile[] ups = new UserProfile[allUsers.size()];
        allUsers.copyInto(ups);
        return ups;
    }

    public synchronized static void writeUserProfilesToFile() throws Exception
    {
        if (profileFile==null)
        {
            throw new NGException("nugen.exception.write.user.profile.info.fail",null);
        }
        profileFile.save();
        generateSSOFIUserFile();
    }


    /**
    * in order to transition from Cognoscenti managing passowrds
    * to SSOFI managing passords, we need to write the passwords
    * out in a form that SSOFI can read, and this does that.
    */
    private static void generateSSOFIUserFile() throws Exception
    {
        try
        {
            String userFolder = ConfigFile.getProperty("userFolder");
            File tempSUsers = new File(userFolder, "SSOFIUsers.xml.tmp");
            File finalSUsers = new File(userFolder, "SSOFIUsers.xml");

            if (tempSUsers.exists())
            {
                tempSUsers.delete();
            }

            FileOutputStream fos = new FileOutputStream(tempSUsers);
            OutputStreamWriter osw = new OutputStreamWriter(fos, "UTF-8");

            osw.write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?><users>\n");

            for (UserProfile userx : getAllUserProfiles())
            {
                String pwd= userx.getPassword();
                if (pwd==null || pwd.length()==0)
                {
                    //ignore users who have never set up a password
                    continue;
                }
                List<String> eList = userx.getEmailList();
                if (eList.size()==0)
                {
                    //ignore users who have no email address
                    continue;
                }

                String hashedPwd = PasswordEncrypter.getSaltedHash(pwd);

                osw.write("  <user>\n");
                for (String oneEmail : eList)
                {
                    osw.write("    <address>");
                    UtilityMethods.writeHtml(osw,oneEmail);
                    osw.write("</address>\n");
                }
                osw.write("    <password>");
                UtilityMethods.writeHtml(osw,hashedPwd);
                osw.write("</password>\n");

                osw.write("    <fullname>");
                UtilityMethods.writeHtml(osw,userx.getName());
                osw.write("</fullname>\n");
                osw.write("  </user>\n");
            }
            osw.write("</users>");
            osw.flush();
            osw.close();

            //now swap the new file with the old one
            if (finalSUsers.exists()) {
                finalSUsers.delete();
            }
            tempSUsers.renameTo(finalSUsers);
        }
        catch (Exception e)
        {
            throw new Exception("Failure while attempting to create the SSOFI users file.", e);
        }
    }

    public static String getShortNameByUserId(String userId)
    {
        if(userHashByUID != null)
        {
            UserProfile up = findUserByAnyId(userId);
            if(up != null)
            {
                return up.getName();
            }
        }
        return userId;
    }


    public static String getUserNamesFromUserId(String userIdList) throws Exception {
        if (userIdList == null || userIdList.length() == 0) {
            return "";
        }

        StringBuffer sb = new StringBuffer();
        StringTokenizer st = new StringTokenizer(userIdList, ",");
        for (int i=0; st.hasMoreTokens(); i++)
        {
            if (i!=0)
            {
                sb.append(", ");
            }
            sb.append(getShortNameByUserId(st.nextToken()));
        }
        return sb.toString();
    }

    /**
    * Read through the user profile file, find all the users that are
    * disabled, and remove them from the user profile list.
    */
    public static synchronized void removeDisabledUsers()
        throws Exception
    {
        Vector<UserProfile> toBeRemoved = new Vector<UserProfile>();
        for (UserProfile up : allUsers)
        {
            if (up.getDisabled())
            {
                toBeRemoved.add(up);
            }
        }
        for (UserProfile up : toBeRemoved)
        {
            profileFile.removeChild(up);
            allUsers.remove(up);
        }
        writeUserProfilesToFile();
    }

    static public String getUserFullNameList(String matchKey) throws Exception
    {
        StringBuffer sb = new StringBuffer();
        boolean addComma = false;
        for (UserProfile up : allUsers)
        {
             if (addComma)
             {
                 sb.append(",");
             }
             if(up.getName().toLowerCase().contains(matchKey.toLowerCase())){
                sb.append(up.getName());
                sb.append("<");
                sb.append(up.getUniversalId());
                sb.append(">");
                addComma = true;
            }else{
                addComma = false;
            }
        }
        return sb.toString();
    }

    public static String getKeyByUserId(String userId)
    {
        if(userHashByUID != null)
        {
            UserProfile up = findUserByAnyId(userId);
            if(up != null)
            {
                return up.getKey();
            }
        }
        return userId;
    }



    public static List<UserProfile> getAllSuperAdmins(AuthRequest ar) throws Exception{

     UserProfile[] allProfiles=  getAllUserProfiles();
     List<UserProfile> allAdmins = new ArrayList<UserProfile>();
     for(int i=0; i<allProfiles.length; i++){
         if(ar.isSuperAdmin( allProfiles[i].getKey() )){
             allAdmins.add( allProfiles[i] );
         }
     }
     return allAdmins;

    }

    public static  UserProfile getSuperAdmin(AuthRequest ar) throws Exception{
        UserProfile superAdmin = null;
        String superAdminKey = ar.getSystemProperty("superAdmin");
        if (superAdminKey == null)
        {
            //if the superAdmin not defined, then NOBODY is super admin
            return null;
        }
        superAdmin = findUserByAnyId(superAdminKey);

        return superAdmin;
    }

}
