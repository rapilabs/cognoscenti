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

import org.json.JSONObject;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.socialbiz.cog.dms.RemoteLinkCombo;
import java.io.File;
import java.io.InputStream;
import java.net.URLEncoder;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Vector;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class AttachmentRecord extends DOMFace {
    private static String ATTACHMENT_ATTB_RLINK = "rlink";
    private static String ATTACHMENT_ATTB_RCTIME = "rctime";
    public static String ATTACHMENT_ATTB_RLMTIME = "rlmtime";

    private String niceName = null;
    protected NGContainer container = null;

    public AttachmentRecord(Document doc, Element definingElement, DOMFace attachmentContainer) {
        super(doc, definingElement, attachmentContainer);

        // MIGRATION CODE, remove when oldest document is older than Dec 2009
        // if not otherwise specified, all documents will be member only
        if (getVisibility() == 0) {
            setVisibility(2);
        }
    }

    public void setContainer(NGContainer newCon) throws Exception {
        if (newCon instanceof NGProj) {
            throw new Exception(
                    "Problem: AttachmentRecord should NOT belong to NGProject, but somehow got one.");
        }
        container = newCon;
    }

    /**
     * Copy all the members from another attachment into this attachment
     * Remember to maintain this as new members are added.
     */
    public void copyFrom(AttachmentRecord other) throws Exception {
        setDisplayName(other.getDisplayName());
        setModifiedBy(other.getModifiedBy());
        setModifiedDate(other.getModifiedDate());
        setComment(other.getComment());
        setVisibility(other.getVisibility());
        setType(other.getType());
        setStorageFileName(other.getStorageFileName());
    }

    public String getId() {
        return checkAndReturnAttributeValue("id");
    }

    public void setId(String id) {
        setAttribute("id", id);
    }

    public String getUniversalId() {
        return getScalar("universalid");
    }

    public void setUniversalId(String id) {
        setScalar("universalid", id);
    }

    /* the 'comment' is a description of the document that is displayed
    * when you access the document.  Technically, it is a description of
    * why this document is relevant to this case.  It is not a comment
    * about an action, but really a description of the document.
    * TODO: change this name to getDescription and setDescription
    */
    public String getComment() {
        return checkAndReturnAttributeValue("comment");
    }

    public void setComment(String comment) {
        setAttribute("comment", comment);
    }

    /**
     * The display name default to the file name, if one has not been set. If
     * file name is empty, then set to AttachmentXXXX where XXXX is the id of
     * the attachment.
     */
    public String getNiceName() {
        if (niceName != null) {
            return niceName;
        }
        String val = getAttribute("displayName");
        if (val != null && val.length() > 0) {
            niceName = val;
            return niceName;
        }
        val = getAttribute("file");
        if (val != null && val.length() > 0) {
            niceName = val;
            return niceName;
        }
        niceName = "Attachment" + getId();
        return niceName;
    }

    public String getNiceNameTruncated(int maxLen) {
        String displayName = getNiceName();
        if (displayName.length() > maxLen) {
            int dotPos = displayName.lastIndexOf(".");
            if (dotPos == displayName.length() - 1 || dotPos < displayName.length() - 7) {
                // three situations to truncate without worrying about
                // extension:
                // 1 there is no dot, no extension, so just truncate
                // 2 there is a dot at the end, still no extension, so just
                // truncate
                // 3 the dot is more than six from the end, so this is a dot in
                // the middle
                // somewhere, and probably not an extension at all. This can
                // happen when
                // the display name is a URL or something like that.
                displayName = displayName.substring(0, maxLen - 3) + "...";
            }
            else {
                String ext = displayName.substring(dotPos + 1);
                int parsePos = maxLen - 3 - ext.length();
                displayName = displayName.substring(0, parsePos) + "..." + ext;
            }
        }
        return displayName;
    }

    public String getDisplayName() {
        return getAttribute("displayName");
    }

    public void setDisplayName(String newDisplayName) throws Exception {
        String oldName = getDisplayName();

        if (newDisplayName.equals(oldName)) {
            return; // nothing to do
        }

        if (equivalentName(newDisplayName)) {
            // only difference is in upper/lower case, or some other change
            // that remains equivalent, so set to the new form.
            setAttribute("displayName", newDisplayName);
            niceName = newDisplayName;
            return;
        }

        // consistency check, the display name and file name (in case of file)
        // must not
        // have any slash characters in them
        if (newDisplayName.indexOf("/") > 0 || newDisplayName.indexOf("\\") > 0) {
            throw new NGException("nugen.exception.display.name.have.slash",
                    new Object[] { newDisplayName });
        }
        // also, display name needs to be unique within the page

        setAttribute("displayName", newDisplayName);
        niceName = newDisplayName;

        updateActualFile(oldName, newDisplayName);
    }

    /**
     * returns true if the name supplied is considered equivalent to the name of
     * this attachment. This comparison will take into account any limitations
     * on what names are allowed to be.
     */
    public boolean equivalentName(String name) throws Exception {
        if (name == null) {
            return false;
        }
        String dName = getNiceName();
        return name.equalsIgnoreCase(dName);
    }

    public void updateActualFile(String oldName, String newName) throws Exception {
        // for AttachmentRecord and Simple versioning system, there is nothing
        // to do
        // but ProjectAttachment needs to do something here...
    }

    public String getLicensedAccessURL(AuthRequest ar, NGPage ngp, String licenseId)
            throws Exception {
        String relativeLink = "a/" + SectionUtil.encodeURLData(getNiceName());
        LicensedURL attPath = new LicensedURL(ar.baseURL + ar.getResourceURL(ngp, relativeLink),
                null, licenseId);
        return attPath.getCombinedRepresentation();
    }

    public String getStorageFileName() {
        return checkAndReturnAttributeValue("file");
    }

    public void setStorageFileName(String newURI) {
        setAttribute("file", newURI);
    }

    /**
     * There are three types of attachment: FILE: this is a local path into the
     * attachments repository URL: this is a URL to an external web addressible
     * content store EXTRA: this file appeared in the project folder (all by
     * itself) but not yet tracked GONE: this file is missing from the folder,
     * might have been deleted by user DEFER: deprecated, not supported any more
     * except legacy
     */
    public String getType() {
        String val = getAttribute("type");
        if (val == null || val.length() == 0) {
            return "FILE";
        }
        // some data file created with lower case terms ... need to migrate
        // them.
        if (val.equals("file")) {
            setAttribute("type", "FILE");
            return "FILE";
        }
        return val;
    }

    public void setType(String type) {
        // check that a valid string id being passed
        // this is a program logic exception since the user never enters
        // the type of attachment
        if (!type.equals("FILE") && !type.equals("URL") && !type.equals("EXTRA")
                && !type.equals("GONE")) {
            throw new RuntimeException("Attachment type has to be either FILE, EXTRA, GONE, or URL");
        }
        setAttribute("type", type);
    }

    /**
     * Returns true if this document has appeared in the folder, and the project
     * does not have any former knowledge of it ==> EXTRA or GONE Returns false
     * if this is an otherwise expected document where the type is URL or FILE
     */
    public boolean isUnknown() {
        String ftype = getType();
        return ("EXTRA".equals(ftype) || "GONE".equals(ftype));
    }

    public String getModifiedBy() {
        return checkAndReturnAttributeValue("modifiedBy");
    }

    public void setModifiedBy(String modifiedBy) {
        setAttribute("modifiedBy", modifiedBy);
    }

    public long getModifiedDate() {
        return safeConvertLong(checkAndReturnAttributeValue("modifiedDate"));
    }

    public void setModifiedDate(long modifiedDate) {
        setAttribute("modifiedDate", Long.toString(modifiedDate));
    }

    private String checkAndReturnAttributeValue(String attrName) {
        String val = getAttribute(attrName);
        if (val == null) {
            return "";
        }
        return val;
    }

    public void createHistory(AuthRequest ar, NGPage ngp, int event, String comment)
            throws Exception {
        HistoryRecord.createHistoryRecord(ngp, getId(), HistoryRecord.CONTEXT_TYPE_DOCUMENT,
                getModifiedDate(), event, ar, comment);
    }

    /**
     * tells whether this attachment is a public attachment, or a member only
     * attachment. Value are:
     *
     * SectionDef.PUBLIC_ACCESS = 1; SectionDef.MEMBER_ACCESS = 2;
     * SectionDef.ADMIN_ACCESS = 3; -- future expansion possibility
     * SectionDef.PRIVATE_ACCESS = 4; -- future expansion possibility
     */
    public int getVisibility() {
        return (int) safeConvertLong(getScalar("visibility"));
    }

    public void setVisibility(int viz) {
        if (viz < SectionDef.PUBLIC_ACCESS) {
            throw new RuntimeException("Visibility of an attachment can not be set to a value "
                    + "less than one.  Attempt to set visibility to " + viz);
        }
        if (viz > SectionDef.MEMBER_ACCESS) {
            throw new RuntimeException("Visibility of an attachment can not be set to a value "
                    + "greater than two.  Attempt to set visibility to " + viz);
        }
        setScalar("visibility", Integer.toString(viz));
    }
    public boolean isPublic() {
        return (getVisibility()==1);
    }

    public int getVersion() {
        return safeConvertInt(getAttribute("version"));
    }

    public void setVersion(int version) {
        setAttribute("version", Integer.toString(version));
    }

    public String getOriginalFilename() {
        return getAttribute("originalFilename");
    }

    public void setOriginalFilename(String actualFileName) {
        setAttribute("originalFilename", actualFileName);
    }

    // ////////////////////// VERSIONING STUFF ////////////

    /**
     * Get a list of all the versions of this attachment that exist. The
     * container is needed so that each attachment can caluculate its own name
     * properly.
     */
    public List<AttachmentVersion> getVersions(NGContainer ngc) throws Exception {

        // debug code
        if (ngc instanceof NGProj) {
            throw new Exception( "Program Logic Error: Attachment Record found on a NGProj object."
                    + "  Should be ProjectAttachment instead!");
        }

        // code must determine HERE what kind of versioning system is being used
        // currently we only have the simple versioning system.
        // When another system is provided, the switch to choose between them
        // will be here.

        List<AttachmentVersion> list = AttachmentVersionSimple.getSimpleVersions(ngc.getKey(),
                getStorageFileName());

        if (list.size() > 0) {
            // file system order is not always in order of version number...
            Collections.sort(list, new AttachmentVersionComparator());
            return list;
        }

        // there is a special case that must be considered, and that is for
        // documents that have been around since before the versioning system
        // was put in place. in those cases the storage name is stored
        // in the getURI place

        File source = new File(AttachmentVersionSimple.attachmentFolder, getStorageFileName());
        if (source.exists()) {
            // if the file is there, add it to the empty list
            list.add(new AttachmentVersionSimple(source, 1, true));
        }

        return list;
    }

    /**
     * Just get the last version. This is the one the user is most often
     * interested in. Can also get this by passing negative version number into
     * getSpecificVersion.
     *
     * Can return null if the file has been found missing, and there are no
     * committed versions.
     */
    public AttachmentVersion getLatestVersion(NGContainer ngc) throws Exception {

        // code must determine HERE what kind of versioning system is being used
        // currently we only have the simple versioning system.
        // When another system is provided, the switch to choose between them
        // will be here.

        // NOTE: this code is fine for the simple versioning system, but with
        // CVS or the others
        // you do not want to get all versions just to get the latest. This code
        // should be a
        // a little smarter in order to run better.

        List<AttachmentVersion> list = getVersions(ngc);

        if (list.size() == 0) {
            //this can happen if a folder had files, a refresh allowed the attachment
            //record to get created, and then the user deletes the file before
            //it gets checked in.  Technically this makes the attachment a "GHOST"
            return null;
        }

        return list.get(list.size() - 1);
    }

    /**
     * Just get the specified version, or null if that version can not be found
     * Pass a negative version number to get the latest version
     */
    public AttachmentVersion getSpecificVersion(NGContainer ngc, int version) throws Exception {

        // code must determine HERE what kind of versioning system is being used
        // currently we only have the simple versioning system.
        // When another system is provided, the switch to choose between them
        // will be here.

        // negative means get the latest version
        if (version < 0) {
            return getLatestVersion(ngc);
        }

        // NOTE: this code is fine for the simple versioning system, but with
        // CVS or the others
        // you do not want to get all versions just to get the latest. This code
        // should be a
        // a little smarter in order to run better.

        List<AttachmentVersion> list = getVersions(ngc);

        for (AttachmentVersion att : list) {
            if (att.getNumber() == version) {
                return att;
            }
        }

        return null;
    }

    /**
     * In some versioning schemes, there is a 'checked-out' copy of the file that
     * is the working version -- the user can modify that directly.  This gets
     * a version object pointing to it.
     *
     * Returns null if versioning system does not have working copy.
     */
    public AttachmentVersion getWorkingCopy(NGContainer ngc) throws Exception {
        //the simple version system does not have any working copy, and therefor
        //can not return anything for this.
        return null;
    }

    public AttachmentVersion getHighestCommittedVersion(NGContainer ngc) throws Exception {
        List<AttachmentVersion> list = getVersions(ngc);
        AttachmentVersion highest = null;
        int ver = 0;
        for (AttachmentVersion av : list) {
            if (av.getNumber()>ver) {
                ver = av.getNumber();
                highest = av;
            }
        }
        return highest;
    }

    /**
     * Takes the working copy, and make a new internal, backed up copy.
     */
    public void commitWorkingCopy(NGContainer ngc) throws Exception {
        //the simple version system does not have any working copy, and therefor
        //can not return anything for this.
        return;
    }

    /**
     * Pass the version list in to find out whether this attachment is
     * has uncommitted changes.
     */
    public boolean hasUncommittedChanges( List<AttachmentVersion> list) {
        AttachmentVersion externalCopy = null;
        AttachmentVersion latestInternal = null;
        int ver = -1;
        for (AttachmentVersion av : list) {
            if (av.isWorkingCopy()) {
                externalCopy = av;
            }
            else if (av.getNumber()>ver) {
                ver = av.getNumber();
                latestInternal = av;
            }
        }
        if (externalCopy==null) {
            //no external, nothing to commit
            return false;
        }
        if (latestInternal == null) {
            //external, but no internal, then you need commit
            return true;
        }
        long externalLen = externalCopy.getFileSize();
        long internalLen = latestInternal.getFileSize();
        return (externalLen != internalLen);
    }

    /**
     * Provide an input stream to the contents of the new version, and this
     * method will copy the contents into here, and then create a new version
     * for that file, and return the AttachmentVersion object that represents
     * that new version.
     */
    public AttachmentVersion streamNewVersion(AuthRequest ar, NGContainer ngc, InputStream contents)
            throws Exception {
        return streamNewVersion(ngc, contents, ar.getBestUserId(), ar.nowTime);
    }

    public AttachmentVersion streamNewVersion(NGContainer ngc, InputStream contents,
            String userId, long timeStamp) throws Exception {

        // debug code
        if (ngc instanceof NGProj) {
            throw new Exception( "Program Logic Error: Attachment Record found on a NGProj object."
                    + "  Should be ProjectAttachment instead!");
        }

        String fileExtension = "";
        String displayName = getNiceName();
        int dotPos = displayName.lastIndexOf(".");
        if (dotPos > 0) {
            fileExtension = displayName.substring(dotPos + 1);
        }

        AttachmentVersion av = AttachmentVersionSimple.getNewSimpleVersion(ngc.getKey(), getId(),
                fileExtension, contents);

        // update the record
        setVersion(av.getNumber());
        setStorageFileName(av.getLocalFile().getName());
        setModifiedDate(timeStamp);
        setModifiedBy(userId);

        return av;
    }

    public static void sortVersions(List<AttachmentVersion> list) {
        Collections.sort(list, new AttachmentVersionComparator());
    }

    static class AttachmentVersionComparator implements Comparator<AttachmentVersion> {
        public AttachmentVersionComparator() {
        }

        public int compare(AttachmentVersion o1, AttachmentVersion o2) {
            try {
                int rank1 = o1.getNumber();
                int rank2 = o2.getNumber();
                if (rank1 == rank2) {
                    return 0;
                }
                if (rank1 < rank2) {
                    return -1;
                }
                return 1;
            }
            catch (Exception e) {
                return 0;
            }
        }
    }

    /**
     * Marking an Attachment as deleted means that we SET the deleted time. If
     * there is no deleted time, then it is not deleted. A Attachment that is
     * deleted remains in the archive until a later date, when garbage has been
     * collected.
     */
    public boolean isDeleted() {
        String delAttr = getAttribute("deleteUser");
        return (delAttr != null && delAttr.length() > 0);
    }

    /**
     * Set deleted date to the date that it is effectively deleted, which is the
     * current time in most cases. Set the date to zero in order to clear the
     * deleted flag and make the Attachment to be not-deleted
     */
    public void setDeleted(AuthRequest ar) {
        setAttribute("deleteDate", Long.toString(ar.nowTime));
        setAttribute("deleteUser", ar.getBestUserId());
    }

    public void clearDeleted() {
        setAttribute("deleteDate", null);
        setAttribute("deleteUser", null);
    }

    public long getDeleteDate() {
        return getAttributeLong("deleteDate");
    }

    public String getDeleteUser() {
        return getAttribute("deleteUser");
    }

    /**
     * Specifies whether this document should be synchronized with the upstream
     * project or not.  If 'true' then this document should be shared and
     * synchronized upstream.  If 'false' then this project is NOT sharing this
     * document with the upstream project.
     */
    public boolean isUpstream() {
        return "true".equals(getAttribute("upstream"));
    }
    public void setUpstream(boolean bVal) {
        if (bVal) {
            setAttribute("upstream", "true");
            if (!isUpstream()) {
                throw new RuntimeException("tried to set upstream and it didn't work");
            }
        }
        else {
            setAttribute("upstream", null);
            if (isUpstream()) {
                throw new RuntimeException("Can't figure out why setting the attribute is not working");
            }
        }
    }


    /**
     * when a doc is moved to another project, use this to record where it was
     * moved to, so that we can link there.
     */
    public void setMovedTo(String project, String otherId) throws Exception {
        setScalar("MovedToProject", project);
        setScalar("MovedToId", otherId);
    }

    /**
     * get the project that this doc was moved to.
     */
    public String getMovedToProjectKey() throws Exception {
        return getScalar("MovedToProject");
    }

    /**
     * get the id of the doc in the other project that this doc was moved to.
     */
    public String getMovedToAttachId() throws Exception {
        return getScalar("MovedToId");
    }

    /**
     * If an attachment has a remote link, then it came originally from a
     * repository and can be synchronized with that remote copy as well.
     */
    public RemoteLinkCombo getRemoteCombo() throws Exception {
        return RemoteLinkCombo.parseLink(getAttribute(ATTACHMENT_ATTB_RLINK));
    }

    public void setRemoteCombo(RemoteLinkCombo combo) {
        if (combo == null) {
            setAttribute(ATTACHMENT_ATTB_RLINK, null);
        }
        else {
            setAttribute(ATTACHMENT_ATTB_RLINK, combo.getComboString());
        }
    }
    public boolean hasRemoteLink() {
        String rl = getAttribute(ATTACHMENT_ATTB_RLINK);
        return (rl!=null && rl.length()>0);
    }


    /**
     * This is the time that the user actually made the attachment, regardless
     * of the time that the document was edited, or any other time that the doc
     * might have.
     */
    public long getAttachTime() {
        return safeConvertLong(getAttribute(ATTACHMENT_ATTB_RCTIME));
    }

    public void setAttachTime(long attachTime) {
        setAttribute(ATTACHMENT_ATTB_RCTIME, Long.toString(attachTime));
    }

    /**
     * This is the timestamp of the document on the remote server at the time
     * that it was last synchronized. Thus if the remote file was modified on
     * Monday, and someone synchronized that version to the project on Tuesday,
     * this date will hold the Monday date. The purpose is to compare with the
     * current remote time to see if it has been modified since the last
     * synchronization.
     */
    public long getFormerRemoteTime() {
        return safeConvertLong(getAttribute(ATTACHMENT_ATTB_RLMTIME));
    }

    public void setFormerRemoteTime(long attachTime) {
        setAttribute(ATTACHMENT_ATTB_RLMTIME, Long.toString(attachTime));
    }

    public String getRemoteFullPath() {
        return getAttribute("remotePath");
    }

    public void setRemoteFullPath(String path) {
        setAttribute("remotePath", path);
    }

    /***
     * This is the flag which tells that file download in the project is read
     * only type or not. And if it is read only type then it prohibits user to
     * upload newer version of that file and synchronization of that file should
     * be one directional only
     */
    public String getReadOnlyType() {
        return getAttribute("readonly");
    }

    public void setReadOnlyType(String readonly) {
        setAttribute("readonly", readonly);
    }

    /**
     * If isInEditMode() returns false, then the document is not in editing
     * mode, or nobody is maintaining the document. We do not restrict other
     * users to edit the document but we warn the user that "this document is
     * editing/maintaining by other user and if you still upload document over
     * it then your data may be lost".
     */
    public boolean isInEditMode() {
        String isInEditMode = getAttribute("editMode");
        if (isInEditMode == null) {
            return false;
        }
        else {
            return "true".equals(isInEditMode);
        }
    }

    /**
     * Set editModeDate to the date when user opts to become editor/ maintainer
     * of the document Set editModeUser to the editor's (logged in) user key.
     */
    public void setEditMode(AuthRequest ar) {
        setAttribute("editModeDate", Long.toString(ar.nowTime));
        setAttribute("editModeUser", ar.getUserProfile().getKey());
        setAttribute("editMode", "true");
    }

    public void clearEditMode() {
        setAttribute("editModeDate", null);
        setAttribute("editModeUser", null);
        setAttribute("editMode", null);

    }

    /***
     * We get the getEditModeDate to check from when the user is maintaining the
     * attachment.
     */
    public long getEditModeDate() {
        return getAttributeLong("editModeDate");
    }

    public String getEditModeUser() {
        return getAttribute("editModeUser");
    }

    /**
     * Tells whether there is a file behind this that can be served up
     */
    public boolean hasContents() {
        // url is the oly type without contents
        return !("URL".equals(getType()));
    }

    /**
     * return the size of the file in bytes
     */
    public long getFileSize(NGContainer ngc) throws Exception {
        if (!"FILE".equals(getType()) || isDeleted()) {
            return -1;
        }
        AttachmentVersion av = getLatestVersion(ngc);
        if (av==null) {
            return -1;
        }
        File f = av.getLocalFile();
        return f.length();
    }

    /**
     * getAccessRoles retuns a list of NGRoles which have access to this document.
     * Admin role and Member role are assumed automatically, and are not in this list.
     * This list contains only the extra roles that have access for non-members.
     */
    public List<NGRole> getAccessRoles() throws Exception {
        if (container==null) {
            throw new ProgramLogicError("call to rolesWithAccess must be made AFTER the container is set.");
        }
        Vector<NGRole> res = new Vector<NGRole>();
        Vector<String> roleNames = getVector("accessRole");
        for (String name : roleNames) {
            NGRole aRole = container.getRole(name);
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

    /**
     * Given the current name of this attachment, figure out what the
     * file extension is.  The last dot and the stuff that is after the dot.
     */
    public String getFileExtension() {
        String attachName = getNiceName();
        int dotPos = attachName.lastIndexOf(".");
        if (dotPos>0) {
            return attachName.substring(dotPos);
        }
        return "";
    }


    public JSONObject getJSON4Doc(NGPage ngp, String urlRoot) throws Exception {
        JSONObject thisDoc = new JSONObject();
        String contentUrl = urlRoot + "doc" + getId() + "/"
                    + URLEncoder.encode(getNiceName(), "UTF-8");
        thisDoc.put("universalid",  getUniversalId());
        thisDoc.put("id",           getId());
        thisDoc.put("name",         getNiceName());
        thisDoc.put("description",  getComment());
        thisDoc.put("size",         getFileSize(ngp));
        thisDoc.put("modifiedtime", getModifiedDate());
        thisDoc.put("modifieduser", getModifiedBy());
        thisDoc.put("content", contentUrl);
        return thisDoc;
    }
    public void updateDocFromJSON(JSONObject thisDoc) throws Exception {
        String universalid = thisDoc.getString("universalid");
        if (!universalid.equals(getUniversalId())) {
            //just checking, this should never happen
            throw new Exception("Error trying to update the record for a goal with UID ("
                    +getUniversalId()+") with post from goal with UID ("+universalid+")");
        }
        setDisplayName(thisDoc.getString("name"));
        setComment(thisDoc.optString("description"));
        //Note the following field updates
        //  modifiedtime is set only when a new version is actually created
        //  modifieduser is set only when a new version is actually created
        //  size is the physical size of the file, and never set
        //  local id is an internal local value
        //  universal id has to match before we do anything here
        //  content url is the logical location of the contents, not settable
    }


    /**
     * @deprecated use getRemoteCombo().getComboString() instead
     */
    public String getRemoteLink() {
        return getAttribute(ATTACHMENT_ATTB_RLINK);
    }

}
