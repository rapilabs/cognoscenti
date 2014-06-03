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
import java.util.Vector;
import java.util.List;
import java.util.Collections;
import java.util.Comparator;

/**
* An entry in the address list.  Holds the email address
* and optionally a UserProfile so that duplicate or alternate
* email addresses can be identified easily.
*
* Address lists can also hold a reference to a role.
* The method isRoleRef() returns true if this is the case.
* Create a role ref version with newRoleRef.
*
* ALE provides a number of functions around parsing and handling
* email addresses and openids.  Whenever you get an email address
* the code should immediately create an ALE and manipulate that.
*
* Upon construction, the ALE will parse the email address, and say
* whether it is a valid email address or not.
*
* The constructor will also detect if the ID is an openid.
*
* Then, it will look into the list of profiles, and see if there is
* a user profile that matches this address.  If it finds one, it will
* make use of of that user's PREFERRED address, instead of the one
* given.
*
* getUniversalId() - returns the "best" id for the user matched with
*     this address.  If no user was found, then the original address returned.
*
* getOriginalId() - returns the (cleaned up) address that was passed in.
*
* getEmail() - returns either the best email address for the user, or
*     the original address if that looks like email, otherwise null string.
*
* There is no way to "set" the id since you only use the constructor
* and pass an email address in.
*
* Generally, the ALE is passed to other objects to either add them to
* a list of addresses (like a NGRole) or to other methods that need a
* target address.
*
* When you have a list of ALE you can find which ones match a particular
* address using hasAnyId() which will test all of a user's addresses
* as well as their name for a match.  If no matching profile was found,
* the obviously it only matches against the address passed in.
*
* Then, when outputting UI you have:
*
* writeLink() to write a well formatted link into a web page
*
* writeURLEncodedID() for composing web URLS
*
*
*/
public class AddressListEntry implements UserRef
{
    String       rawAddress;
    boolean      isRole       = false;
    UserProfile  user;
    String       namePart;

    public AddressListEntry(String addr)
    {
        if (addr==null)
        {
            throw new ProgramLogicError("attempt to construct an AddressListEntry with a null value");
        }
        user = UserManager.findUserByAnyId(addr);
        rawAddress = addr;
    }

    public AddressListEntry(UserProfile knownUser)
    {
        if (knownUser==null)
        {
            throw new RuntimeException("Unable to construct AddressListEntry on a null user profile object");
        }
        user = knownUser;
        rawAddress = user.getUniversalId();
    }

    /**
    * Pass the name of a role in, and get an AddressListEntry
    * that represents a reference to a role in return.
    */
    public static AddressListEntry newRoleRef(String roleName)
    {
        AddressListEntry retval = new AddressListEntry(roleName);
        retval.setRoleRef(true);
        return retval;
    }

    /**
    * Return the email address for this entry if one is known.
    * If not, return a null string.
    */
    public String getEmail()
    {
        if (user!=null)
        {
            return user.getPreferredEmail();
        }
        else if (rawAddress.indexOf("@")>0
              && !startsWithIgnoreCase(rawAddress, "https://")
              && !startsWithIgnoreCase(rawAddress, "http://"))
        {
            return rawAddress;
        }

        //if it does not look like an email address, return a null string.
        return "";
    }


    private boolean startsWithIgnoreCase(String dataVal, String testVal) {
        if (dataVal.length()<testVal.length()) {
            return false;
        }
        return dataVal.substring(0, testVal.length()).equalsIgnoreCase(testVal);
    }

    /**
    * Return the best global unique ID for this address list entry.
    * Usually an email address, but not always.  Could be an openid if there is no user
    * profile associated with the initial address.  Or it could be the name of a role.
    */
    public String getUniversalId()
    {
        if (user!=null)
        {
            return user.getUniversalId();
        }
        else
        {
            return rawAddress;
        }
    }

    /**
    * return the ID that was used in this role or address list
    * the one that was used to find the associated user.
    */
    public String getInitialId()
    {
        return rawAddress;
    }

    /**
    * return the best email address for this entry
    */
    public boolean hasAnyId(String testAddr)
    {
        if (user!=null)
        {
            return user.hasAnyId(testAddr);
        }
        else
        {
            return testAddr.equalsIgnoreCase(rawAddress);
        }
    }

    public boolean equals(UserRef other)
    {
        //first test one way
        if (hasAnyId(other.getUniversalId()))
        {
            return true;
        }

        //then test the other way
        return other.hasAnyId(getUniversalId());
    }

    /**
    * Say whether this address list entry is for the specified profile
    */
    public boolean isSameAs(UserProfile another)
    {
        if (user!=null)
        {
            return user.getKey().equals(another.getKey());
        }
        return false;
    }

    /**
    * return the best name, either the user name, or the address
    * in the case that no user was found.
    */
    public String getName()
    {
        if (user!=null)
        {
            return user.getName();
        }
        MicroProfileRecord record = MicroProfileMgr.findMicroProfileById(rawAddress);
        if (record != null)
        {
            return record.getDisplayName();
        }
        if (namePart!=null)
        {
            return namePart;
        }

        return rawAddress;
    }



    public void writeURLEncodedID(AuthRequest ar) throws Exception
    {
        if (user!=null)
        {
            ar.write(user.getKey());
        }
        else
        {
            ar.writeURLData(rawAddress);
        }
    }


    /**
    * Write out a HTML link to fetch the informatin about this user
    * if possible.
    */
    public void writeLink(AuthRequest ar) throws Exception
    {
        if (user != null)
        {
            user.writeLink(ar);
            if (!ar.isStaticSite())
            {
                String email = getEmail();
                if (email==null || email.length()==0)
                {
                    ar.write(" <img src=\"");
                    ar.write(ar.retPath);
                    ar.write("warning.gif\">");
                }
            }
            return;
        }


        MicroProfileRecord record = MicroProfileMgr.findMicroProfileById(rawAddress);
        if (record != null)
        {
            record.writeLink(ar);
            return;
        }

        //no profile, and no micro profile, so just work with what ALE has
        String cleanName = SectionUtil.cleanName(getName());
        if (cleanName.length()> 28)
        {
            cleanName = cleanName.substring(0,28);
        }

        if (!ar.isLoggedIn() || ar.isStaticSite())
        {
            ar.writeHtml(cleanName);
            return;
        }

        MicroProfileRecord.writeSpecificLink(ar, cleanName, rawAddress);
    }


    public boolean isRoleRef()
    {
        return isRole;
    }

    public void setRoleRef(boolean newVal)
    {
        isRole = newVal;
    }


    public String getStorageRepresentation()
    {
        String memberID = getUniversalId();
        if (isRoleRef())
        {
            memberID = "%"+memberID;
        }
        return memberID;
    }
    public static AddressListEntry newEntryFromStorage(String roleName)
    {
        String actualName = roleName;
        boolean isRole = false;
        if (roleName.startsWith("%"))
        {
            actualName = roleName.substring(1);
            isRole = true;
        }
        AddressListEntry retval = new AddressListEntry(actualName);
        retval.setRoleRef(isRole);
        return retval;
    }

    public UserProfile getUserProfile()
    {
        return user;
    }


    public static void sortByName(List<UserRef> list)
    {
        Collections.sort(list, new UserRefComparator());
    }


    static class UserRefComparator implements Comparator<UserRef>
    {
        public UserRefComparator() {}

        public int compare(UserRef o1, UserRef o2)
        {
            String name1 = o1.getName();
            String name2 = o2.getName();
            return name1.compareToIgnoreCase(name2);
        }
    }

    public boolean hasAddressMatchingFrag(String frag) {
        if(user != null){
            return user.hasAddressMatchingFrag(frag);
        }else{
            if(getName().toLowerCase().contains(frag) || getUniversalId().toLowerCase().contains(frag)){
                return true;
            }
        }
        return false;
    }

    /**
    * If the address was supplied with a name AND and address,
    * then this method will return the name part.
    * If not, returns null.
    *
    * For example, some email addresses look like:
    *      "Tom Jones"  <tom.jones@example.com>
    *
    * This will be properly parsed, and the email address /
    * universal ID will be just the email address, but to get
    * the name that comes before that, use this method.
    */
    public String getNamePart() {
        return namePart;
    }

    /**
    * See #getNamePart().  This method allows you to force a
    * name part into the address list entry.
    */
    public void setNamePart(String newName) {
        this.namePart = newName;
    }


    /**
    * Give this method a 'combined' address, that contains both a
    * user name and email address.  This will correctly parse the
    * two out, and return an AddressListEntry object that contains
    * both.
    */
    public static AddressListEntry parseCombinedAddress(String nameAddress)
    {
        //note: this needs to be checked against the standard to make
        //sure that handling of quotes and special cases is correct.
        int braketStart = nameAddress.indexOf('<');
        int braketEnd   = nameAddress.indexOf('>');

        //if there is no angle bracked, then just return normal ALE
        if (braketStart<0 || braketEnd<braketStart) {
            return new AddressListEntry(nameAddress);
        }

        String beforePart = nameAddress.substring(0, braketStart).trim();
        String emailPart  = nameAddress.substring(braketStart+1, braketEnd).trim();

        AddressListEntry ale = new AddressListEntry(emailPart);
        ale.setNamePart(beforePart);
        return ale;
    }


    /**
    * returns a 'combined' address that has both the user name, and
    * the email address in a single string value.
    * Note: it uses values from the user profile if one has been associated.
    */
    public String generateCombinedAddress()
    {
        String theName = namePart;
        if (user!=null) {
            theName = user.getName();
        }
        return theName + " <" + getEmail() + ">";
    }


    /**
    * Given a string that contains a comma delimited list of email addresses
    * this will parse the addresses out, and write links for every address.
    */
    public static void writeParsedLinks(AuthRequest ar, String addressList)
        throws Exception
    {
        Vector<AddressListEntry> list = parseEmailList(addressList);
        boolean needsComma = false;
        for (AddressListEntry ale : list)
        {
            if (needsComma)
            {
                ar.write(", ");
            }
            ale.writeLink(ar);
            needsComma = true;
        }
    }


    /**
    * Given a string with email addresses (or openids) separated by either commas
    * semicolons, or carriage returns, this will parse the list, and return a
    * vector of AddressListEntry objects.
    */
    public static Vector<AddressListEntry> parseEmailList(String addressList)
        throws Exception
    {
        Vector<AddressListEntry> res = new Vector<AddressListEntry>();

        int start = 0;
        while (start < addressList.length())
        {
            int commaPos = addressList.indexOf(',', start);
            int semiPos = addressList.indexOf(';', start);
            int nlPos = addressList.indexOf('\n', start);
            int min = addressList.length();
            if (commaPos>start && commaPos<min)
            {
                min = commaPos;
            }
            if (semiPos>start && semiPos<min)
            {
                min = semiPos;
            }
            if (nlPos>start && nlPos<min)
            {
                min = nlPos;
            }

            String frag = addressList.substring(start, min).trim();
            if (frag.length()>0)
            {
                res.add( parseCombinedAddress(frag) );
            }
            start = min+1;
        }

        return res;
    }

}
