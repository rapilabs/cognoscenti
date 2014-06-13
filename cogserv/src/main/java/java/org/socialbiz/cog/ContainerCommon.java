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
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.Vector;

import org.socialbiz.cog.dms.ConnectionSettings;
import org.socialbiz.cog.dms.ConnectionType;
import org.socialbiz.cog.dms.ResourceEntity;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.w3c.dom.Document;

/**
* The three classes: NGPage, NGBook, and UserPage are all DOMFile classes, and there
* are some methods that they can easily share.  This class is an abstract base class
* so that these classes can easily share a few methods.
*/
public abstract class ContainerCommon extends DOMFile implements NGContainer
{
    DOMFace attachParent;
    DOMFace noteParent;
    DOMFace roleParent;
    DOMFace historyParent;
    DOMFace infoParent;

    public ContainerCommon(File path, Document doc) throws Exception
    {
        super(path, doc);
        attachParent = getAttachmentParent();
        noteParent   = getNoteParent();
        roleParent   = getRoleParent();
        historyParent = getHistoryParent();
        infoParent    = getInfoParent();
    }

    /**
    * schema migration ...
    * make sure that all notes and documents have universal ids.
    * do this here because the NoteRecord & AttachmentRecord constructor
    * does not easily know what the container is.
    */
    protected void cleanUpNoteAndDocUniversalId() throws Exception {
        //schema migration ...
        //make sure that all notes have universal ids.
        for (NoteRecord lr : getAllNotes()) {
            String uid = lr.getUniversalId();
            if (uid==null || uid.length()==0) {
                uid = getContainerUniversalId() + "@" + lr.getId();
                lr.setUniversalId(uid);
            }
        }

        //and the same for documents
        for (AttachmentRecord att : getAllAttachments()) {
            String uid = att.getUniversalId();
            if (uid==null || uid.length()==0) {
                uid = getContainerUniversalId() + "@" + att.getId();
                att.setUniversalId(uid);
            }
        }
    }

    //these are methods that the extending classes need to implement so that this class will work
    public abstract String getUniqueOnPage() throws Exception;
    protected abstract DOMFace getAttachmentParent() throws Exception;
    protected abstract DOMFace getNoteParent() throws Exception;
    protected abstract DOMFace getRoleParent() throws Exception;
    protected abstract DOMFace getHistoryParent() throws Exception;
    protected abstract DOMFace getInfoParent() throws Exception;
    public abstract NGRole getPrimaryRole() throws Exception;
    public abstract NGRole getSecondaryRole() throws Exception;




    public List<AttachmentRecord> getAllAttachments() throws Exception {
        List<AttachmentRecord> list = attachParent.getChildren("attachment", AttachmentRecord.class);
        for (AttachmentRecord att : list) {
            att.setContainer(this);
        }
        return list;
    }

    public AttachmentRecord findAttachmentByID(String id) throws Exception {
        for (AttachmentRecord att : getAllAttachments())
        {
            if (id.equals(att.getId()))
            {
                return att;
            }
        }
        return null;
    }

    public AttachmentRecord findAttachmentByIDOrFail(String id) throws Exception {

        AttachmentRecord ret =  findAttachmentByID( id );

        if (ret==null)
        {
            throw new NGException("nugen.exception.unable.to.locate.att.with.id", new Object[]{id, getFullName()});
        }
        return ret;
    }

    public AttachmentRecord findAttachmentByName(String name) throws Exception {
        for (AttachmentRecord att : getAllAttachments()) {
            if (att.equivalentName( name )) {
                return att;
            }
        }
        return null;
    }
    public AttachmentRecord findAttachmentByUidOrNull(String universalId) throws Exception {
        for (AttachmentRecord att : getAllAttachments()) {
            if (universalId.equals(att.getUniversalId())) {
                return att;
            }
        }
        return null;
    }
    public AttachmentRecord findAttachmentByNameOrFail(String name) throws Exception {

        AttachmentRecord ret =  findAttachmentByName( name );

        if (ret==null)
        {
            throw new NGException("nugen.exception.unable.to.locate.att.with.name", new Object[]{name, getFullName()});
        }
        return ret;
    }

    public AttachmentRecord createAttachment() throws Exception {
        AttachmentRecord attach = attachParent.createChild("attachment", AttachmentRecord.class);
        String newId = getUniqueOnPage();
        attach.setId(newId);
        attach.setContainer(this);

        //this is the default, but it might be overridden in case of sync from another project
        attach.setUniversalId( getContainerUniversalId() + "@" + newId );
        return attach;
    }

    public void deleteAttachment(String id,AuthRequest ar) throws Exception {
        AttachmentRecord att = findAttachmentByIDOrFail( id );
        att.setDeleted( ar );
    }


    public void unDeleteAttachment(String id) throws Exception {
        AttachmentRecord att = findAttachmentByIDOrFail( id );
        att.clearDeleted();
    }

    public void eraseAttachmentRecord(String id) throws Exception {
        AttachmentRecord att = findAttachmentByIDOrFail( id );
        attachParent.removeChild(att);
    }

    /**
    * Returns the ResourceEntity that represents the remote folder that files
    * can be stored in.  Returns null if not set.
    */
    public ResourceEntity getDefRemoteFolder() throws Exception {
        String userKey = getDefUserKey();
        String connId = getDefFolderId();
        String fullPath = getDefLocation();
        if (userKey==null || userKey.length()==0 || connId==null || connId.length()==0 ||
            fullPath==null || fullPath.length()==0 ) {
            return null;
        }
        UserPage uPage = UserPage.findOrCreateUserPage(userKey);
        ConnectionSettings defCSet = uPage.getConnectionSettingsOrNull(connId);
        if (defCSet==null) {
            //if ID is invalid, treat it like it does not exist
            return null;
        }
        ConnectionType cType = defCSet.getConnectionOrFail();
        return cType.getResource(fullPath);
    }
    /**
    * Pass a null to clear the setting
    */
    public void setDefRemoteFolder(ResourceEntity loc) throws Exception {
        if (loc==null) {
            setDefUserKey(null);
            setDefFolderId(null);
            setDefLocation(null);
            return;
        }

        ConnectionType cType = loc.getConnection();
        setDefUserKey(cType.getOwnerKey());
        setDefFolderId(loc.getFolderId());
        setDefLocation(loc.getFullPath());
    }


    public String getDefLocation() throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        return attachElement.getAttribute("defaultRepository");
    }

    public void setDefLocation(String loc) throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        attachElement.setAttribute("defaultRepository", loc);
    }

    public String getDefFolderId() throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        return attachElement.getAttribute("defaultFolderId");
    }

    public void setDefFolderId(String folderId) throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        attachElement.setAttribute("defaultFolderId", folderId);
    }

    public String getDefUserKey() throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        return attachElement.getAttribute("defaultUserKey");
    }

    public void setDefUserKey(String userKey) throws Exception {
        DOMFace attachElement  = getAttachmentParent();
        attachElement.setAttribute("defaultUserKey", userKey);
    }


    //////////////////// NOTES ///////////////////////

    public List<NoteRecord> getAllNotes() throws Exception {
        return noteParent.getChildren("note", NoteRecord.class);
    }

    public List<NoteRecord> getVisibleNotes(AuthRequest ar, int displayLevel)
            throws Exception {
        List<NoteRecord> list=new ArrayList<NoteRecord>();
        List<NoteRecord> fullList = getAllNotes();

        for (NoteRecord note : fullList) {
            if (note.isVisible(ar, displayLevel) && !note.isDeleted() && !note.isDraftNote()) {
                list.add(note);
            }
        }
        return list;
    }


    public NoteRecord getNote(String cmtId) throws Exception {
        for (NoteRecord lr : getAllNotes()) {
            if (cmtId.equals(lr.getId())) {
                return lr;
            }
        }
        return null;
    }


    public NoteRecord getNoteOrFail(String noteId) throws Exception {
        NoteRecord ret =  getNote(noteId);
        if (ret==null) {
            throw new NGException("nugen.exception.unable.to.locate.note.with.id", new Object[]{noteId, getFullName()});
        }
        return ret;
    }

    public NoteRecord getNoteByUidOrNull(String universalId) throws Exception {
        for (NoteRecord lr : getAllNotes()) {
            if (universalId.equals(lr.getUniversalId())) {
                return lr;
            }
        }
        return null;
    }


    /** mark deleted, don't actually deleting the Note. */
    public void deleteNote(String id,AuthRequest ar) throws Exception {
        NoteRecord ei = getNote( id );

        ei.setDeleted( ar );
    }

    public void unDeleteNote(String id,AuthRequest ar) throws Exception {
        NoteRecord ei = getNote( id );
        ei.clearDeleted();
    }



    public List<NoteRecord> getDeletedNotes(AuthRequest ar)
    throws Exception {
        List<NoteRecord> list=new ArrayList<NoteRecord>();
        List<NoteRecord> fullList = getAllNotes();

        for (NoteRecord note : fullList) {
            if (note.isDeleted()) {
                list.add(note);
            }
        }
        return list;
    }


    public NoteRecord createNote() throws Exception {
        NoteRecord note = noteParent.createChild("note", NoteRecord.class);
        String localId = getUniqueOnPage();
        note.setId( localId );
        note.setUniversalId(getContainerUniversalId() + "@" + localId);
        return note;
    }

    //////////////////// ROLES ///////////////////////


    public boolean primaryPermission(UserRef user) throws Exception {
        if (user==null) {
            throw new ProgramLogicError("primaryPermission called with null user object.");
        }
        return getPrimaryRole().isExpandedPlayer(user, this);
    }
    public boolean primaryOrSecondaryPermission(UserRef user) throws Exception {
        if (primaryPermission(user))
        {
            return true;
        }
        if (secondaryPermission(user))
        {
            return true;
        }
        if (this instanceof NGPage)
        {
            throw new ProgramLogicError("NGPage overrides this, so this should never happen");
        }
        return false;
    }

    public boolean secondaryPermission(UserRef user) throws Exception {
        if (user==null) {
            throw new ProgramLogicError("secondaryPermission called with null user object.");
        }
        return getSecondaryRole().isExpandedPlayer(user, this);
    }



    @SuppressWarnings("unchecked")
    public List<NGRole> getAllRoles() throws Exception {
        return (List<NGRole>)(List<?>) roleParent.getChildren("role", CustomRole.class);
    }

    public NGRole getRole(String roleName) throws Exception {
        for (NGRole role : getAllRoles()) {
            if (roleName.equals(role.getName())) {
                return role;
            }
        }
        return null;
    }

    public NGRole getRoleOrFail(String roleName) throws Exception {
        NGRole ret = getRole(roleName);
        if (ret==null)
        {
            throw new NGException("nugen.exception.unable.to.locate.role.with.name", new Object[]{roleName, getFullName()});
        }
        return ret;
    }

    public NGRole createRole(String roleName, String description)
            throws Exception {
        if (roleName==null || roleName.length()==0) {
            throw new NGException("nugen.exception.role.cant.be.empty",null);
        }

        NGRole existing = getRole(roleName);
        if (existing!=null) {
            throw new NGException("nugen.exception.cant.create.new.role", new Object[]{roleName});
        }
        CustomRole newRole = roleParent.createChild("role", CustomRole.class);
        newRole.setName(roleName);
        newRole.setDescription(description);
        return newRole;
    }

    public void deleteRole(String name) throws Exception {
        NGRole role = getRole(name);
        if (role!=null) {
            roleParent.removeChild((DOMFace)role);
        }
    }


    /**
    * just a shortcut for getRole(roleName).addPlayer(newMember)
    */
    public void addPlayerToRole(String roleName,String newMember)throws Exception
    {
        NGRole role= getRoleOrFail(roleName);
        role.addPlayer(new AddressListEntry(newMember));
    }

    public List<NGRole> findRolesOfPlayer(UserRef user) throws Exception {
        Vector<NGRole> res = new Vector<NGRole>();
        if (user==null) {
            return res;
        }
        for (NGRole role : getAllRoles()) {
            if (role.isExpandedPlayer(user, this)) {
                res.add(role);
            }
        }
        return res;
    }

    //////////////////// HISTORY ///////////////////////

    public List<HistoryRecord> getAllHistory()
            throws Exception
    {
        Vector<HistoryRecord> vect = historyParent.getChildren("event", HistoryRecord.class);
        HistoryRecord.sortByTimeStamp(vect);
        return vect;
    }

    public List<HistoryRecord> getHistoryRange(long startTime, long endTime)
            throws Exception
    {
        Vector<HistoryRecord> allHist = historyParent.getChildren("event", HistoryRecord.class);
        Vector<HistoryRecord> newHist = new Vector<HistoryRecord>();
        for (HistoryRecord hr : allHist)
        {
            long eventTime = hr.getTimeStamp();
            if (eventTime > startTime && eventTime <= endTime)
            {
                newHist.add(hr);
            }
        }
        HistoryRecord.sortByTimeStamp(newHist);
        return newHist;
    }

    public void copyHistoryForResource(NGContainer ngc, int contextType, String oldID, String newID) throws Exception
    {
        for (HistoryRecord oldHist : ngc.getAllHistory())
        {
            int histContextType = oldHist.getContextType();
            if (histContextType!=contextType) {
                continue;
            }
            String contextId = oldHist.getContext();
            if (!oldID.equals(contextId)) {
                continue;
            }

            HistoryRecord newHist = createNewHistory();
            newHist.copyFrom(oldHist);
            newHist.setContext(newID);
        }
    }


    public HistoryRecord createNewHistory()
        throws Exception
    {
        HistoryRecord newHist = historyParent.createChild("event", HistoryRecord.class);
        newHist.setId(getUniqueOnPage());
        return newHist;
    }


    ////////////////////// WRITE LINKS //////////////////////////

    public void writeContainerLink(AuthRequest ar, int len) throws Exception{
        throw new ProgramLogicError("writeContainerLink not implemented");
    }

    public void writeDocumentLink(AuthRequest ar, String id, int len) throws Exception{
        throw new ProgramLogicError("not implemented");
    }

    public void writeReminderLink(AuthRequest ar, String id, int len) throws Exception{
        throw new ProgramLogicError("writeDocumentLink not implemented");
    }

    public void writeTaskLink(AuthRequest ar, String id, int len) throws Exception{
        throw new ProgramLogicError("writeTaskLink not implemented");
    }

    public void writeNoteLink(AuthRequest ar, String id, int len) throws Exception{
        throw new ProgramLogicError("writeNoteLink not implemented");
    }


    public String trimName(String nameOfLink, int len)
    {
        if (nameOfLink.length()>len)
        {
            return nameOfLink.substring(0,len-1)+"...";
        }
        return nameOfLink;
    }

    /**
    * get a role, and create it if not found.
    */
    protected NGRole getRequiredRole(String roleName) throws Exception
    {
        NGRole role = getRole(roleName);
        if (role==null)
        {
            String desc = roleName+" of the project "+getFullName();
            if ("Executives".equals(roleName))
            {
                desc = "The role 'Executives' contains a list of people who are assigned to the site "
                +"as a whole, and are automatically members of every project in that site.  ";
            }
            else if ("Members".equals(roleName))
            {
                desc = "Members of a project can see and edit any of the content in the project.  "
                       +"Members can create, edit, and delete notes, can upload, download, and delete documents."
                       +"Members can approve other people to become members or other roles.";
            }
            else if ("Administrators".equals(roleName))
            {
                desc = "Administrators have all the rights that Members have, but have additional ability "
                       +"to manage the structure of the project, to add/remove roles, and to exercise greater "
                       +"control over a project, such as renaming and deleting a project.";
            }
            else if ("Notify".equals(roleName))
            {
                desc = "People who are not members, but who receive email notifications anyway.";
            }
            else
            {
                //I don't know of any other required roles, if so, we should have a
                //better description than this.
                desc = roleName+" of the project "+getFullName();
            }
            role = createRole(roleName, desc);
        }
        return role;
    }

    /**
    * The purpose of this, is to generate a unique magic number
    * for any given email id for this page.  Links to this
    * page could include this magic number, and it will allow
    * a person with that email address access to this page.
    * It will prove that they have been sent the magic number,
    * and proof that they received it, and therefor proof that
    * they own the email address.
    *
    * Pass the email address that you are sending to, and this will
    * return the magic number.   When the user clicks on the link
    * match the magic number in the link, with the magic number
    * generated here, to make sure they are not hacking their way in.
    *
    * The URL that the user clisk on must have BOTH the email address
    * and the magic number in it, because they are precisely paired.
    * Don't expect to get the email address from other part of
    * environment, because remember that email addresses are sometimes
    * transformed through the sending of the document.
    *
    * The magic number is ephemeral.  They need to last long enough
    * for someone to receive the email and click on the link,
    * so they have to last for days at least, probably weeks.
    * This algorithm generates a magic number that will last
    * permanently as long as the project lasts.  This is good because
    * there is no real way to migrate to a new algorithm for generating
    * the magic numbers.  But in practice
    * this algorithm might be changed at any time, causing discomfort
    * to those users that just received links, but presumably they
    * would soon receive new links with the new numbers in them.
    * There is no real requirement that the number last *forever*.
    */
    public String emailDependentMagicNumber(String emailId)
        throws Exception
    {
        String encryptionPad = getScalar("encryptionPad");
        if (encryptionPad==null || encryptionPad.length()!=30)
        {
            StringBuffer tmp = new StringBuffer();
            Random r = new Random();
            for (int i=0; i<30; i++)
            {
                //generate a random character >32 and <10000
                char ch = (char) (r.nextInt(9967) + 33);
                tmp.append(ch);
            }
            encryptionPad = tmp.toString();
            setScalar("encryptionPad", encryptionPad);
        }

        long chksum = 0;

        for (int i=0; i<30; i++)
        {
            char ch1 = encryptionPad.charAt(i);
            char ch2 = 'x';
            if (i < emailId.length())
            {
                ch2 = emailId.charAt(i);
            }
            int partial = ch1 ^ ch2;
            chksum = chksum + (partial*partial);
        }

        StringBuffer gen = new StringBuffer();

        while (chksum>0)
        {
            char gch = (char)('A' +  (chksum % 26));
            chksum = chksum / 26;
            gen.append(gch);
            gch = (char) ('0' + (chksum % 10));
            chksum = chksum / 10;
            gen.append(gch);
        }

        return gen.toString();
    }

    public List<NoteRecord> getDraftNotes(AuthRequest ar)
    throws Exception {
        List<NoteRecord> list=new ArrayList<NoteRecord>();
        if (ar.isLoggedIn()) {
            List<NoteRecord> fullList = getAllNotes();
            String thisUserId = ar.getUserProfile().getUniversalId();
            for (NoteRecord note : fullList) {
                if (!note.isDeleted() && note.isDraftNote() && note.getLastEditedBy().equals(thisUserId)) {
                    list.add(note);
                }
            }
        }
        return list;
    }

    public RoleRequestRecord getRoleRequestRecordById(String requestId) throws Exception{
        RoleRequestRecord requestRecord = null;
        for (RoleRequestRecord roleRequestRecord : getAllRoleRequest()) {
            if(roleRequestRecord.getAttribute("id").equalsIgnoreCase(requestId)){
                requestRecord = roleRequestRecord;
                break;
            }
        }
        return requestRecord;
    }

    public List<RoleRequestRecord> getAllRoleRequestByState(String state, boolean completedReq) throws Exception{
        List<RoleRequestRecord> resultList = new ArrayList<RoleRequestRecord>();
        for (RoleRequestRecord roleRequestRecord : getAllRoleRequest()) {
            if(roleRequestRecord.getState().equalsIgnoreCase(state)
                    && completedReq == roleRequestRecord.isCompleted()){
                resultList.add(roleRequestRecord);
            }
        }
        return resultList;
    }

    public boolean isAlreadyRequested(String roleName, String requestedBy) throws Exception{
        for (RoleRequestRecord roleRequestRecord : getAllRoleRequestByState("Requested", false)) {
            if(requestedBy.equals(roleRequestRecord.getRequestedBy())
                    && roleName.equals(roleRequestRecord.getRoleName())){
                return true;
            }
        }
        return false;
    }

    public RoleRequestRecord getRoleRequestRecord(String roleName, String requestedBy) throws Exception {
        RoleRequestRecord requestRecord = null;
        long modifiedDate = 0;
        for (RoleRequestRecord roleRequestRecord : getAllRoleRequest()) {
            if(requestedBy.equals(roleRequestRecord.getRequestedBy())
                    && roleName.equals(roleRequestRecord.getRoleName())
                    && modifiedDate < roleRequestRecord.getModifiedDate()){

                    requestRecord = roleRequestRecord;
                    modifiedDate = roleRequestRecord.getModifiedDate();
            }
        }
        return requestRecord;
    }

    public String getThemePath()
    {
        //this is the default theme when nothing else overrides it
        return "theme/blue/";
    }

    public String getContainerUniversalId() {

        return ConfigFile.getServerGlobalId() + "@" + getKey();

    }

    @Override
    public List<EmailRecord> getAllEmail() throws Exception {
        DOMFace mail = requireChild("mail", DOMFace.class);
        return mail.getChildren("email", EmailRecord.class);
    }

    @Override
    public EmailRecord createEmail() throws Exception {
        DOMFace mail = requireChild("mail", DOMFace.class);
        EmailRecord email = mail.createChild("email", EmailRecord.class);
        email.setId(getUniqueOnPage());
        return email;
    }

    @Override
    public EmailRecord getEmailReadyToSend() throws Exception {
        for (EmailRecord er : getAllEmail()) {
            if (er.statusReadyToSend()) {
                return er;
            }
        }
        return null;
    }

    @Override
    public int countEmailToSend() throws Exception {
        int count = 0;
        for (EmailRecord er : getAllEmail()) {
            if (er.statusReadyToSend()) {
                count++;
            }
        }
        return count;
    }

    /**
    * Pages have a set of licenses
    */
    public Vector<License> getLicenses() throws Exception {
        Vector<LicenseRecord> vc = infoParent.getChildren("license", LicenseRecord.class);
        Vector<License> v = new Vector<License>();
        for (License child : vc) {
            v.add(child);
        }
        return v;
    }

    public License getLicense(String id) throws Exception {
        if (id==null || id.length()==0) {
            //silently ignore the null by returning null
            return null;
        }
        for (License child : getLicenses()) {
            if (id.equals(child.getId())) {
                return child;
            }
        }
        return null;
    }

    public boolean removeLicense(String id) throws Exception {
        Vector<LicenseRecord> vc = infoParent.getChildren("license", LicenseRecord.class);
        for (LicenseRecord child : vc) {
            if (id.equals(child.getId())) {
                infoParent.removeChild(child);
                return true;
            }
        }
        //maybe this should throw an exception?
        return false;
    }

    public License addLicense(String id) throws Exception {
        LicenseRecord newLement = infoParent.createChildWithID("license",
                LicenseRecord.class, "id", id);
        return newLement;
    }

    public boolean isValidLicense(License lr, long time) throws Exception {
        if (lr==null) {
            //no license passed, then not valid, handle this quietly so that
            //this can be used with getLicense operations.
            return false;
        }
        if (time>lr.getTimeout()) {
            return false;
        }

        NGRole ngr = getRole(lr.getRole());
        if (ngr==null) {
            //can not be valid if the role no longer exists
            return false;
        }

        //check to see if the user who created it, is still in the
        //role or in the member's role
        AddressListEntry ale = new AddressListEntry(lr.getCreator());
        if (!ngr.isExpandedPlayer(ale,  this) && !primaryOrSecondaryPermission(ale)) {
            return false;
        }

        return true;
    }
}
