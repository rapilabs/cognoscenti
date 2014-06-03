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

import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Vector;

import org.json.JSONObject;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

/**
* A NoteRecord represents a Note in a Container.
* Notes exist on project and sites as quick ways for people to
* write and exchange information about the project.
* Leaflet is the old term for this, we prefer the term Note now everywhere.
* (Used to be called LeafletRecord, but name changed March 2013)
*/
public class NoteRecord extends DOMFace
{

    public NoteRecord(Document definingDoc, Element definingElement, DOMFace new_ngs)
    {
        super(definingDoc, definingElement, new_ngs);

        //assure that visibility is set, default to the visibility to member
        int viz = getVisibility();
        if (viz<1 || viz>4)
        {
            setVisibility(2);
        }
    }

    public void copyFrom(NoteRecord other) {
        setOwner(other.getOwner());
        setLastEdited(other.getLastEdited());
        setLastEditedBy(other.getLastEditedBy());
        setSubject(other.getSubject());
        setData(other.getData());
        setVisibility(other.getVisibility());
        setEditable(other.getEditable());
        setEffectiveDate(other.getEffectiveDate());
        setTags(other.getTags());
        setChoices(other.getChoices());
    }

    public String getId()
    {
        return getAttribute("id");
    }
    public void setId(String newId)
    {
        setAttribute("id", newId);
    }

    public String getOwner()
    {
        return getScalar("owner");
    }
    public void setOwner(String newOwner)
    {
        setScalar("owner", newOwner);
    }

    public long getLastEdited()
    {
        return safeConvertLong(getScalar("created"));
    }
    public void setLastEdited(long newCreated)
    {
        setScalar("created", Long.toString(newCreated));
    }

    public String getLastEditedBy()
    {
         return getScalar("modifiedby");
    }
    public void setLastEditedBy(String newModifier)
    {
        setScalar("modifiedby", newModifier);
    }

    public String getSubject()
    {
        return getScalar("subject");
    }
    public void setSubject(String newSubj)
    {
        setScalar("subject", newSubj);
    }

    public String getData()
    {
        return getScalar("data");
    }
    public void setData(String newData)
    {
        setScalar("data", newData);
    }


    /**
    * Each note can be controlled as being public, member, or private,
    * so that it can be moved over the course of lifespan.  When it is
    * private, it can be seen only by the owner.
    *
    * The default setting inherits view from the container.  This is really
    * a migration mode which should be purposefully used.  Data from
    * before this setting will have 0, and thus will be public if in a
    * public comments section, and membero only if in a member only section.
    * New comments should be created specifically with a visibility that
    * is non-zero, and when edited the visibility should be set appropriately.
    * Ideally, the concept of a "public comments" section will disappear,
    * there will be one pool of comments with visibility set here.
    *
    * These constants declared in SectionDef
    * SectionDef.PUBLIC_ACCESS = 1;
    * SectionDef.MEMBER_ACCESS = 2;
    * SectionDef.AUTHOR_ACCESS = 3;
    * SectionDef.PRIVATE_ACCESS = 4;
    *
    */
    public int getVisibility()
    {
        return (int) safeConvertLong(getScalar("visibility"));
    }
    public void setVisibility(int newData)
    {
        //the "anonymous" case must be converted to public
        if (newData<1)
        {
            newData=1;
        }
        else if (newData>4)
        {
            newData=2;
        }
        setScalar("visibility", Integer.toString(newData));
    }
    /**
     * Visibility value of 1 means that this note is publicly viewable.
     * This convenience method makes the test for this easy.
     */
    public boolean isPublic() {
        return (getVisibility()==1);
    }

    /**
    * given a display level and a user (AuthRequest) tells whether
    * this note is to be displayed at that level.  Note this is
    * an "exact" match to a level, not a "greater than" match.
    */
    public boolean isVisible(AuthRequest ar, int displayLevel)
        throws Exception
    {
        int visibility = getVisibility();
        if (visibility != displayLevel)
        {
            return false;
        }
        if (visibility != 4)
        {
            return true;
        }
        // must test ownership
        return (ar.getUserProfile().hasAnyId(getOwner()));
    }




    public static final int EDIT_OWNER   = 1;
    public static final int EDIT_MEMBER  = 2;

    /**
    * Each note can be be edited either by just the author only
    * or by any member of the page.  Clearly it has to be visible
    * to the members or public, in order for members to edit it;
    * when the comment is private it can only be edited by the
    * owner.
    *
    * By default, a comment is editable only by the all members.
    * This is preferred to edit only by owner because generally
    * collaboration is preferred over exclusive access.
    */
    public int getEditable() {
        if (1 == safeConvertLong(getScalar("editable"))) {
            return EDIT_OWNER;
        }
        else {
            return EDIT_MEMBER;
        }
    }
    public void setEditable(int newData) {
        if (newData == EDIT_OWNER || newData == EDIT_MEMBER) {
            setScalar("editable", Integer.toString(newData));
        }
    }

    /**
    * This date used to sort the comments.  Set to the date that
    * the comment was first made or published.  That date remains
    * fixed even if the comment continues to be edited.
    *
    * When effective date is not set, use last saved date instead.
    * These will be the same a lot of the time.
    */
    public long getEffectiveDate()
    {
        long effDate = safeConvertLong(getScalar("effective"));
        if (effDate==0)
        {
            return getLastEdited();
        }
        return effDate;
    }
    public void setEffectiveDate(long newEffective)
    {
        setScalar("effective", Long.toString(newEffective));
    }

    /**
    * If the comment is "pinned" to the top of the page, then
    * this pin order will be set with a positive integer value
    * so that comments are in the order 1, 2, 3, etc.
    * A value of zero (or negative) means that the comment is
    * not pinned to the top, and should instead be sorted by
    * effective date.
    * Default: 0
    */
    public long getPinOrder()
    {
        long pin = safeConvertLong(getScalar("pin"));
        if (pin < 0)
        {
            pin = 0;
        }
        return pin;
    }
    public void setPinOrder(long newPinOrder)
    {
        if (newPinOrder < 0)
        {
            newPinOrder = 0;
        }
        setScalar("pin", Long.toString(newPinOrder));
    }

    /**
    * Given a vector, this will fill the vector with tag terms
    */
    public void fillTags(Vector<String> result)
    {
        fillVectorValues(result, "tag");
    }


    /**
    * Returns a vector of string tag values
    */
    public Vector<String> getTags()
    {
        return getVector("tag");
    }
    /**
    * Given a vector of string, this tag terms for this comment
    */
    public void setTags(Vector<String> newVal)
    {
        setVector("tag", newVal);
    }

    /**
    * Returns a vector of string choice values
    */
    public String getChoices()
    {
        return getScalar("choices");
    }

    /**
    * Given a vector of string, this choices for this note
    */
    public void setChoices(String choices)
    {
        setScalar("choices", choices);
    }



    /**
    * gets all the response that exist on the note.
    */
    public Vector<LeafletResponseRecord> getResponses()
        throws Exception
    {
        //there was a bug ...  that puts response records in for uses BY KEY, but later accesses by
        //global ID (which is the right way).  This code strips out the records that are created with a
        //nine-letter ID, and not an email address ....
        Vector<LeafletResponseRecord> temp = getChildren("response", LeafletResponseRecord.class);
        Vector<LeafletResponseRecord> res = new Vector<LeafletResponseRecord>();
        for (LeafletResponseRecord llr : temp) {
            String userId = llr.getUser();
            if (userId.length()==9 && userId.indexOf("@")<0 && userId.indexOf("/")<0) {
                //ignore all records that have a user id which is exactly 9 characters long
                //and have no @ sign and no slashes.  Can only be a key!
                continue;
            }
            res.add(llr);
        }
        return res;
    }

    /**
    * returns the response for a particular user, creating one if it does
    * not already exist.
    */
    public LeafletResponseRecord getOrCreateUserResponse(UserProfile up)
        throws Exception
    {
        Vector<LeafletResponseRecord> temp = getChildren("response", LeafletResponseRecord.class);
        for (LeafletResponseRecord child : temp)
        {
            String childUser = child.getUser();
            if (up.hasAnyId(childUser))
            {
                //update record with user's current universal ID
                child.setUser(up.getUniversalId());
                return child;
            }
        }
        //did not find it, so we need to create it
        LeafletResponseRecord newChild = createChildWithID(
                "response", LeafletResponseRecord.class, "user", up.getUniversalId());
        return newChild;
    }

    /**
    * This is needed for finding responses from people with email addresses
    * who have been asked to respond to a note, but who do not have any profile.
    * In this case ID must match exactly.
    */
    public LeafletResponseRecord accessResponse(String userId)
        throws Exception
    {
        Vector<LeafletResponseRecord> nl = getChildren("response", LeafletResponseRecord.class);
        for (LeafletResponseRecord child : nl) {
            String childUser = child.getUser();
            if (userId.equals(childUser)) {
                return child;
            }
        }
        //did not find it, so we need to create it
        LeafletResponseRecord newChild = createChildWithID(
                "response", LeafletResponseRecord.class, "user", userId);
        return newChild;
    }


    /**
    * output a HTML link to this note, truncating the name (subject)
    * to maxlength if it is longer than that.
    */
    public void writeLink(AuthRequest ar, int maxLength)
        throws Exception
    {
        ar.write("<a href=\"");
        ar.write(ar.retPath);
        ar.write("\">");
        String name = getSubject();
        if (name.length()>maxLength)
        {
            name = name.substring(0,maxLength);
        }
        ar.writeHtml(name);
        ar.write("</a>");
    }


    public void findTags(Vector<String> v)
        throws Exception
    {
        String tv = getData();
        LineIterator li = new LineIterator(tv);
        while (li.moreLines())
        {
            String thisLine = li.nextLine();
            scanLineForTags(thisLine, v);
        }
    }

    protected void scanLineForTags(String thisLine, Vector<String> v)
    {
        int hashPos = thisLine.indexOf('#');
        int startPos = 0;
        int last = thisLine.length();
        while (hashPos >= startPos)
        {
            hashPos++;
            int endPos = WikiConverter.findIdentifierEnd(thisLine, hashPos);
            if (endPos > hashPos+2)
            {
                if (endPos >= last)
                {
                    //this includes everything to the end of the string, and we are done
                    v.add(thisLine.substring(hashPos));
                    return;
                }

                v.add(thisLine.substring(hashPos, endPos));
            }
            else if (endPos >= last)
            {
                return;
            }
            startPos = endPos;
            hashPos = thisLine.indexOf('#', startPos);
        }
    }



    public static void sortCommentsByPinOrder(Vector<NoteRecord> v) {
        Collections.sort(v, new CommentsInPinOrder());
    }

    /**
    * Compares its two arguments for order.
    * First compares their pin order value which the user has placed
    * on them to pin them in a particular position.  The order
    * is 1, 2, 3, ... and then 0 at the end denoting that there is
    * no pin order set.
    * If no pin order is set (or if pin order is equal) then
    * compared by effective date order, which is usually the date
    * that the comment was first created.
    */
    private static class CommentsInPinOrder implements Comparator<NoteRecord> {
        CommentsInPinOrder() {
        }

        public int compare(NoteRecord o1, NoteRecord o2) {
            long p1 = o1.getPinOrder();
            long p2 = o2.getPinOrder();
            if (p1 != p2) {
                if (p1 == 0) {
                    return 1;
                }
                if (p2 == 0) {
                    return -1;
                }
                if (p2 < p1) {
                    return 1;
                }
                if (p2 > p1) {
                    return -1;
                }
            }

            // pin number is equal, so sort by effective date
            long t1 = o1.getEffectiveDate();
            long t2 = o2.getEffectiveDate();
            if (t2 < t1) {
                return -1;
            }
            if (t2 == t1) {
                return 0;
            }
            return 1;
        }

    }

    /**
    * Marking a Note as deleted means that we SET the deleted time.
    * If there is no deleted time, then it is not deleted.
    * A Note that is deleted remains in the archive until a later
    * date, when garbage has been collected.
    */
    public boolean isDeleted()
    {
        String delAttr = getAttribute("deleteUser");
        return (delAttr!=null&&delAttr.length()>0);
    }

    /**
    * Set deleted date to the date that it is effectively deleted,
    * which is the current time in most cases.
    * Set the date to zero in order to clear the deleted flag
    * and make the note to be not-deleted
    */
    public void setDeleted(AuthRequest ar)
    {
        setAttribute("deleteDate", Long.toString(ar.nowTime));
        setAttribute("deleteUser", ar.getBestUserId());
    }
    public void clearDeleted()
    {
        setAttribute("deleteDate", null);
        setAttribute("deleteUser", null);
    }
    public long getDeleteDate()
    {
        return getAttributeLong("deleteDate");
    }
    public String getDeleteUser()
    {
        return getAttribute("deleteUser");
    }

    public void setSaveAsDraft(String saveAsDraft){
        setAttribute("saveAsDraft", saveAsDraft);
    }

    public boolean isDraftNote(){
        String saveAsDraft = getAttribute("saveAsDraft");
        if(saveAsDraft != null && saveAsDraft.equals("yes")){
            return true;
        }else{
            return false;
        }
    }

    /**
     * when a note is moved to another project, use this to record where
     * it was moved to, so that we can link there.
     */
     public void setMovedTo(String project, String otherId)
         throws Exception
     {
         setScalar("MovedToProject", project);
         setScalar("MovedToId", otherId);
     }


     /**
     * get the project that this note was moved to.
     */
     public String getMovedToProjectKey()
         throws Exception
     {
         return getScalar("MovedToProject");
     }

     /**
     * get the id of the note (leaflet) in the other project that this note was moved to.
     */
     public String getMovedToNoteId()
         throws Exception
     {
         return getScalar("MovedToId");
     }

     /**
     * the universal id is a globally unique ID for this note, composed of the id for the
     * server, the project, and the note.  This is set at the point where the note is created
     * and remains with the note as it is carried around the system as long as it is moved
     * as a clone from a project to a clone of a project.   If it is copied or moved to another
     * project for any other reason, then the universal ID should be reset.
     */
     public String getUniversalId() throws Exception {
         return getScalar("universalid");
     }
     public void setUniversalId(String newID) throws Exception {
         setScalar("universalid", newID);
     }


     /**
      * getAccessRoles retuns a list of NGRoles which have access to this document.
      * Admin role and Member role are assumed automatically, and are not in this list.
      * This list contains only the extra roles that have access for non-members.
      */
     public List<NGRole> getAccessRoles(NGContainer ngp) throws Exception {
         Vector<NGRole> res = new Vector<NGRole>();
         Vector<String> roleNames = getVector("accessRole");
         for (String name : roleNames) {
             NGRole aRole = ngp.getRole(name);
             if (aRole!=null) {
                 if (!res.contains(aRole)) {
                     res.add(aRole);
                 }
             }
         }
         return res;
     }

     /**
      * setAccessRoles sets the list of NGRoles which have access for non-members.
      * You should not specify Admin or Members in this list.
      */
     public void setAccessRoles(List<NGRole> values) throws Exception {
         Vector<String> roleNames = new Vector<String>();
         for (NGRole aRole : values) {
             roleNames.add(aRole.getName());
         }
         //Since this is a 'set' type vector, always sort them so that they are
         //stored in a consistent way ... so files are more easily compared
         Collections.sort(roleNames);
         setVector("accessRole", roleNames);
     }

     /**
      * check if a particular role has access to the particular file.
      * Just handles the 'special' roles, and does not take into consideration
      * the Members or Admin roles, nor whether the attachment is public.
      */
      public boolean roleCanAccess(String roleName) {
          Vector<String> roleNames = getVector("accessRole");
          for (String name : roleNames) {
              if (roleName.equals(name)) {
                  return true;
              }
          }
          return false;
      }

      public boolean isUpstream() {
          String delAttr = getAttribute("upstreamAccess");
          return (delAttr!=null && delAttr.length()>0);
      }
      public void setUpstream(boolean val) {
          if (val) {
              setAttribute("upstreamAccess", "yes");
          }
          else {
              setAttribute("upstreamAccess", null);
          }
      }


     public JSONObject getJSON4Note(String urlRoot, boolean withData) throws Exception {
         JSONObject thisNote = new JSONObject();
         String contentUrl = urlRoot + "note" + getId() + "/"
                     + SectionWiki.sanitize(getSubject()) + ".txt";
         thisNote.put("subject", getSubject());
         thisNote.put("modifiedtime", getLastEdited());
         thisNote.put("modifieduser", getLastEditedBy());
         thisNote.put("universalid", getUniversalId());
         thisNote.put("public", getVisibility()==1);
         thisNote.put("content", contentUrl);
         thisNote.put("id", getId());
         if (withData) {
             thisNote.put("data", getData());
         }
         return thisNote;
     }
     public void updateNoteFromJSON(JSONObject noteObj) throws Exception {
         String universalid = noteObj.getString("universalid");
         if (!universalid.equals(getUniversalId())) {
             //just checking, this should never happen
             throw new Exception("Error trying to update the record for a goal with UID ("
                     +getUniversalId()+") with post from goal with UID ("+universalid+")");
         }
         String subj = noteObj.optString("subject");
         if (subj!=null && subj.length()>0) {
             setSubject(subj);
         }
         setLastEdited(noteObj.getLong("modifiedtime"));
         setLastEditedBy(noteObj.getString("modifieduser"));
         if (noteObj.getBoolean("public")) {
             //public
             setVisibility(1);
         }
         else {
             //only non-public option is member only.  Other visibility
             //options should not be considered by sync mechanism at all.
             setVisibility(2);
         }
         String data = noteObj.optString("data");
         if (data!=null && data.length()>0) {
             setData(data);
         }
     }


}
