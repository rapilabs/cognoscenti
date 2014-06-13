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
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.socialbiz.cog.util.CVSUtil;
import org.w3c.dom.Document;

/**
 * An site is a collection of pages. This allows a collection of pages to share
 * a single set of members, and a particular look and feel. For archaic reasons
 * called NGBook, should be NGSite
 */
public class NGBook extends ContainerCommon implements NGContainer {
    public String key;
    public ReminderMgr reminderMgr;
    // The following are the indices which are used by book finding and
    // reading. Initialized by scanAllBooks() method.
    private static Hashtable<String, NGBook> keyToSite = null;
    private static Vector<NGBook> allSites = null;

    private Vector<String> existingIds = null;
    private String[] displayNames;
    private BookInfoRecord siteInfoRec;
    private NGRole executiveRole;
    private NGRole ownerRole;

    public NGBook(File theFile, Document newDoc) throws Exception {
        super(theFile, newDoc);
        siteInfoRec = requireChild("bookInfo", BookInfoRecord.class);
        displayNames = siteInfoRec.getPageNames();

        // migration code, make sure there is a stored value for key
        key = siteInfoRec.getScalar("key");
        if (key == null || key.length() == 0) {
            String fileName = theFile.getName();
            if (fileName.equalsIgnoreCase("SiteInfo.xml")) {
                // use the name of the containing folder to set the key
                File cogFolder = theFile.getParentFile();
                File containingFolder = cogFolder.getParentFile();
                key = SectionUtil.sanitize(containingFolder.getName());
                siteInfoRec.setScalar("key", key);
            }
            else if (fileName.endsWith(".book") || fileName.endsWith(".site")) {
                key = fileName.substring(0, fileName.length() - 5);
                siteInfoRec.setScalar("key", key);
            }
            else {
                throw new Exception("Site is missing key, and unable to generate one: " + theFile);
            }
        }
        System.out.println("Cached site (" + key + ") from : " + theFile);

        requireChild("notes", DOMFace.class);
        requireChild("attachments", DOMFace.class);
        requireChild("process", DOMFace.class);
        requireChild("history", DOMFace.class);

        executiveRole = getRequiredRole("Executives");
        ownerRole = getRequiredRole("Owners");

        // just in case this is an old site object, we need to look for and
        // copy members from the members tag into the role itself
        moveOldMembersToRole();

        // upgrade all the note records
        cleanUpNoteAndDocUniversalId();
    }

    /**
     * SCHEMA MIGRATION CODE - old schema required members to be children of a
     * tag 'members' and also prospective memebers in a tag 'pmembers' This code
     * migrates these to the standard Role object storage format, to a role
     * called 'Executives' The tag 'members' and 'pmembers' are removed from the
     * file.
     *
     * the old format did not distinguish between executives and owners so these
     * members are migrated to both executives and owners, presumably the real
     * owner will remove the others.
     *
     * But this code, like other migration code, must be left in in case there
     * are olld book files around with the old format. until 2 years after April
     * 2011 and there are no books older than this.
     */
    private void moveOldMembersToRole() throws Exception {
        // in case there is a pmembers tag around, get rid of that.
        // these are just discarded, and they have to request again
        DOMFace pmembers = getChild("pmembers", DOMFace.class);
        if (pmembers != null) {
            removeChild(pmembers);
        }

        DOMFace members = getChild("members", DOMFace.class);
        if (members == null) {
            return;
        }
        for (String id : members.getVector("member")) {
            AddressListEntry user = AddressListEntry.newEntryFromStorage(id);
            executiveRole.addPlayer(user);
            ownerRole.addPlayer(user);
        }
        // now get rid of it so it never is heard from again.
        removeChild(members);

    }

    public static NGBook readSiteByKey(String key) throws Exception {
        if (keyToSite == null) {
            // this should never happen, but if it does....
            throw new ProgramLogicError("in readSiteByKey called before the site index initialzed.");
        }
        if (key == null) {
            throw new Exception("Program Logic Error: Site key of null is no longer allowed.");
        }

        NGBook retVal = keyToSite.get(key);
        if (retVal == null) {
            throw new NGException("nugen.exception.book.not.found", new Object[] { key });
        }
        return retVal;
    }

    public static NGBook readSiteAbsolutePath(File theFile) throws Exception {
        try {
            if (!theFile.exists()) {
                throw new NGException("nugen.exception.file.not.exist", new Object[] { theFile });
            }
            Document newDoc = readOrCreateFile(theFile, "book");
            return new NGBook(theFile, newDoc);
        }
        catch (Exception e) {
            throw new NGException("nugen.exception.unable.to.read.file",
                    new Object[] { theFile.toString() }, e);
        }
    }

    public static Vector<NGBook> getAllSites() {
        // might do a copy here if we fear that the receiver will corrupt this
        // vector
        return allSites;
    }

    /**
     * Creates a book with the specified name. Generates the key automatically.
     */
    public static NGBook createNewSite(String name) throws Exception {
        String key = IdGenerator.generateKey();
        NGBook ngb = createSiteByKey(key, name);
        registerSite(ngb);
        return ngb;
    }

    public static void registerSite(NGBook foundSite) throws Exception {
        allSites.add(foundSite);
        keyToSite.put(foundSite.getKey(), foundSite);
    }

    /**
     * Creates the special default book This should be kept in sync with above
     * routine.
     */
    private static NGBook createSiteByKey(String key, String name) throws Exception {

        // TODO: this only creates in the main folder. Archaic
        File theFile = NGPage.getPathInDataFolder(key + ".book");
        if (theFile.exists()) {
            throw new NGException("nugen.exception.cant.crete.new.book", new Object[] { key });
        }
        Document newDoc = readOrCreateFile(theFile, "book");

        NGBook newBook = new NGBook(theFile, newDoc);

        // set default values
        newBook.setName(name);
        newBook.setStyleSheet("PageViewer.css");
        newBook.setLogo("logo.gif");
        newBook.setDescription("");

        return newBook;
    }

    public void saveSiteAs(String newKey, UserProfile user, String comment) throws Exception {
        try {
            reformatXML();

            File theFile = NGPage.getPathInDataFolder(newKey + ".book");
            if (!theFile.exists()) {
                File theParent = theFile.getParentFile();
                theParent.mkdirs();
            }
            saveAs(theFile);
            key = newKey;

            // Add & commit the new file the CVS.
            CVSUtil.add(associatedFile, user.getName(), comment);
        }
        catch (Exception e) {
            throw new NGException("nugen.exception.unable.to.write.file.for.key",
                    new Object[] { newKey }, e);
        }
    }

    public String getKey() {
        return key;
    }

    public String getName() {
        String fullName = getFullName();
        if (fullName != null) {
            return fullName;
        }

        return getScalar("name");
    }

    public void setName(String newName) {
        setScalar("name", newName.trim());
    }

    public String[] getSiteNames() {
        if (displayNames == null || displayNames.length < 0) {
            String name = getFullName();
            return new String[] { name };
        }
        return displayNames;
    }

    public void setSiteNames(String[] newNames) {
        siteInfoRec.setPageNames(newNames);
        displayNames = siteInfoRec.getPageNames();
    }

    public String getStyleSheet() {
        String ss = getScalar("styleSheet");
        if (ss == null) {
            return "PageViewer.css";
        }
        return ss;
    }

    public void setStyleSheet(String newName) {
        setScalar("styleSheet", newName.trim());
    }

    public String getLogo() {
        String ss = getScalar("logo");
        if (ss == null) {
            return "logo.gif";
        }
        return ss;
    }

    public void setLogo(String newName) {
        setScalar("logo", newName.trim());
    }

    public String getDescription() {
        String ss = getScalar("description");
        if (ss == null) {
            return "";
        }
        return ss;
    }

    public void setDescription(String newDescr) {
        setScalar("description", newDescr.trim());
    }

    /**
     * Set all static values back to their initial states, so that garbage
     * collection can be done, and subsequently, the class will be
     * reinitialized.
     */
    public synchronized static void clearAllStaticVars() {
        keyToSite = null;
        allSites = null;
    }

    /**
     * The method scanAllBooks is used to initialize the indices which are used
     * to quickly find and manipulate books. Book records are read and held in
     * memory since they are used so frequently, and there are relatively few of
     * them.
     *
     * This method need to consider carefully the "reinitialize" situation.
     * There is an Admin page which allows for clearing memory, garbage
     * collecting, and then reinitializing all the static variables. This is a
     * "soft restart" of the nugen system, reinitializing all internal data
     * structures. How can this be accomplished when we are not sure that all
     * other requests have been stopped? Simply clearing the data structures has
     * the problem that some code tests and automatically regenerates certain
     * structures, and you might have the problem that multiple threads might be
     * rebuilding the index at the same time, and this would be bad.
     *
     * This method was once written to create all the structures in temporary
     * variables, and then update the globals all at once, but this is not
     * entirely satisfactory because one of the methods used during the
     * initialization might use the older existing indices, which might have the
     * effect of causing a link reference from the new tables to the old tables,
     * and cause garbage collection to fail to reclaim that memory.
     *
     * The cleanest method would be to clear all global variables, garbage
     * collect with nothing in memory, and then rebuild completely from scratch.
     * That requires a special mode of the server, which prevents any access
     * during the time that the internal memory is being rebuilt. At this point
     * in time such an admin mode is not present, so there is no way to prevent
     * access during the time that the memory is being constructed.
     *
     * Currently, the globals are cleaned out (nulled), and then reconstructed.
     * If there are accesses during the time of rebuilding, there are two
     * possibilities. First, there could be an exception terminating the
     * processing of the request. This is annoying to users, but a necessary
     * side effect of doing maintenance while the server is online. Second,
     * there might be an operation that causes the regeneration of such data.
     * This is more problematic since that constructed data might have a mixture
     * of old and new links. So this method checks to see if anything has
     * created cached values in the mean time, and throws it's own self-destruct
     * exception.
     */
    public synchronized static void scanAllSites(File root) throws Exception {
        // clear the statics first of all to make sure they are not
        // holding any old values that need to be cleared, also to make
        // sure that they are not set as a side effect of this code,
        // or code on another thread that may be running.
        keyToSite = null;
        allSites = null;
        System.out.println("Scanning for book files: " + root);

        Hashtable<String, NGBook> tKeyToSite = new Hashtable<String, NGBook>();
        Vector<NGBook> tAllSites = new Vector<NGBook>();

        for (File child : root.listFiles()) {
            String fileName = child.getName();
            if (!fileName.endsWith(".book")) {
                // ignore all files except those that end in .book
                continue;
            }

            NGBook ngb = readSiteAbsolutePath(child);

            tAllSites.add(ngb);
            String key = ngb.getKey();

            // check for uniqueness just to be sure
            if (tKeyToSite.containsKey(key)) {
                throw new Exception("found a new book with a key (" + key
                        + ") that duplicates another book: " + child);
            }
            tKeyToSite.put(key, ngb);
        }

        if (keyToSite != null || allSites != null) {
            // this is the 'self-destruct' message. Either something in
            // the logic above, or something on a different thread
            // has manipulated the static variables during execution.
            // A self-destruct does not solve the problem, but it does
            // alert the programmer / admin that the code logic is
            // somehow incorrect.
            throw new ProgramLogicError("somewhere inside "
                    + "the logic to initialize the key data structures of the "
                    + "server, something incorrectly created some values in "
                    + "'keyToBook' or 'allAccounts'.  This should not happen, and "
                    + "the fact that it happened means that the internal memory "
                    + "structures are in an unknown state.  Restarting the server "
                    + "is recommended in this case.");
        }

        // now make them live
        keyToSite = tKeyToSite;
        allSites = tAllSites;
    }

    public static NGBook createNewSite(String key, String name) throws Exception {
        // where is the site going to go?
        String[] libFolders = ConfigFile.getArrayProperty("libFolder");
        if (libFolders.length == 0) {
            throw new Exception(
                    "You must have a setting for 'libFolder' in order to create a new site.");
        }

        File domFolder = new File(libFolders[0]);
        if (!domFolder.exists()) {
            throw new Exception(
                    "Config setting 'libFolder' is not correct, first value must be an existing folder: ("
                            + domFolder + ")");
        }
        File newSiteFolder = new File(domFolder, key);
        if (newSiteFolder.exists()) {
            throw new Exception("Can't create site because folder already exists: ("
                    + newSiteFolder + ")");
        }
        newSiteFolder.mkdirs();

        File theFile = new File(newSiteFolder, key + ".site");
        if (theFile.exists()) {
            throw new Exception("Unable to create new site, a site with that ID already exists.");
        }

        Document newDoc = readOrCreateFile(theFile, "book");
        NGBook newBook = new NGBook(theFile, newDoc);

        // set default values
        // TODO: change this to pass a file here
        newBook.setPreferredProjectLocation(newSiteFolder.toString());
        newBook.setName(name);
        newBook.setStyleSheet("PageViewer.css");
        newBook.setLogo("logo.gif");

        registerSite(newBook);
        return newBook;
    }

    public void setKey(String key) {
        setScalar("key", key.trim());
    }

    /**
     * Walk through whatever elements this owns and put all the four digit IDs
     * into the vector so that we can generate another ID and assure it does not
     * duplication any id found here.
     */
    public void findIDs(Vector<String> v) throws Exception {
        // shouldn't be any attachments. But count them if there are any
        List<AttachmentRecord> attachments = getAllAttachments();
        for (AttachmentRecord att : attachments) {
            v.add(att.getId());
        }
    }

    public String getUniqueOnPage() throws Exception {
        if (existingIds == null) {
            existingIds = new Vector<String>();
            findIDs(existingIds);
        }
        return IdGenerator.generateFourDigit(existingIds);
    }

    public String getFullName() {
        if (displayNames == null) {
            return getScalar("name");
        }
        if (displayNames.length == 0) {
            return getScalar("name");
        }
        return displayNames[0];
    }

    // /////////////// Role Requests/////////////////////

    public RoleRequestRecord createRoleRequest(String roleName, String requestedBy,
            long modifiedDate, String modifiedBy, String requestDescription) throws Exception {
        DOMFace rolelist = siteInfoRec.requireChild("Role-Requests", DOMFace.class);
        RoleRequestRecord newRoleRequest = rolelist
                .createChild("requests", RoleRequestRecord.class);
        newRoleRequest.setRequestId(IdGenerator.generateKey());
        newRoleRequest.setModifiedDate(modifiedDate);
        newRoleRequest.setModifiedBy(modifiedBy);
        newRoleRequest.setState("Requested");
        newRoleRequest.setCompleted(false);
        newRoleRequest.setRoleName(roleName);
        newRoleRequest.setRequestedBy(requestedBy);
        newRoleRequest.setRequestDescription(requestDescription);
        newRoleRequest.setResponseDescription("");

        return newRoleRequest;
    }

    public List<RoleRequestRecord> getAllRoleRequest() throws Exception {

        List<RoleRequestRecord> requestList = new ArrayList<RoleRequestRecord>();
        DOMFace rolelist = siteInfoRec.requireChild("Role-Requests", DOMFace.class);
        Vector<RoleRequestRecord> children = rolelist.getChildren("requests",
                RoleRequestRecord.class);
        for (RoleRequestRecord rrr : children) {
            requestList.add(rrr);
        }
        return requestList;
    }

    // ////////////////// ROLES /////////////////////////

    public NGRole getPrimaryRole() {
        return executiveRole;
    }

    public NGRole getSecondaryRole() {
        return ownerRole;
    }

    protected DOMFace getAttachmentParent() throws Exception {
        return requireChild("attachments", DOMFace.class);
    }

    protected DOMFace getNoteParent() throws Exception {
        return requireChild("notes", DOMFace.class);
    }

    protected DOMFace getRoleParent() throws Exception {
        return requireChild("roleList", DOMFace.class);
    }

    protected DOMFace getHistoryParent() throws Exception {
        return requireChild("history", DOMFace.class);
    }

    protected DOMFace getInfoParent() throws Exception {
        return siteInfoRec;
    }

    // ////////////////// NOTES /////////////////////////

    public void setLastModify(AuthRequest ar) throws Exception {
        ar.assertLoggedIn("Must be logged in in order to modify site.");
        siteInfoRec.setModTime(ar.nowTime);
        siteInfoRec.setModUser(ar.getBestUserId());
    }

    public void saveFile(AuthRequest ar, String comment) throws Exception {
        try {
            setLastModify(ar);
            save();
            // commit the modified files to the CVS.
            CVSUtil.commit(getFilePath(), ar.getBestUserId(), comment);
        }
        catch (Exception e) {
            throw new NGException("nugen.exception.unable.to.write.account.file",
                    new Object[] { getFilePath().toString() }, e);
        }
    }

    public void saveContent(AuthRequest ar, String comment) throws Exception {
        saveFile(ar, comment);
    }

    public String[] getContainerNames() {
        return getSiteNames();
    }

    public void setContainerNames(String[] nameSet) {
        setSiteNames(nameSet);
    }

    public long getLastModifyTime() throws Exception {
        return siteInfoRec.getModTime();
    }

    public boolean isDeleted() {
        return false;
    }

    public ReminderMgr getReminderMgr() throws Exception {
        if (reminderMgr == null) {
            reminderMgr = requireChild("reminders", ReminderMgr.class);
        }
        return reminderMgr;
    }

    public void changeVisibility(String oid, AuthRequest ar) throws Exception {
        int visibility = safeConvertInt(ar.reqParam("visibility"));
        NoteRecord note = getNoteOrFail(oid);
        note.setVisibility(visibility);
        note.setEffectiveDate(SectionUtil.niceParseDate(ar.defParam("effDate", "")));
    }

    public List<HistoryRecord> getAllHistory() throws Exception {
        DOMFace historyContainer = requireChild("history", DOMFace.class);
        Vector<HistoryRecord> vect = historyContainer.getChildren("event", HistoryRecord.class);
        HistoryRecord.sortByTimeStamp(vect);
        return vect;
    }

    public HistoryRecord createNewHistory() throws Exception {
        DOMFace historyContainer = requireChild("history", DOMFace.class);
        HistoryRecord newHist = historyContainer.createChild("event", HistoryRecord.class);
        newHist.setId(getUniqueOnPage());
        return newHist;
    }

    public void writeContainerLink(AuthRequest ar, String documentId, int len) throws Exception {
        writeSiteUrl(ar);
        ar.write("/public.htm\">");
        ar.writeHtml(getFullName());
        ar.write("</a>");
    }

    public void writeDocumentLink(AuthRequest ar, String documentId, int len) throws Exception {
        throw new Exception("writeDocumentLink should no longer be used on an Site");
    }

    public void writeReminderLink(AuthRequest ar, String reminderId, int len) throws Exception {
        throw new Exception("writeReminderLink should no longer be used on an Site");
    }

    /**
     * overridden in Site to make sure this is never needed
     */
    public AttachmentRecord findAttachmentByID(String id) throws Exception {
        throw new Exception("findAttachmentByID should never be needed on Site");
    }

    public AttachmentRecord findAttachmentByIDOrFail(String id) throws Exception {
        throw new Exception("findAttachmentByIDOrFail should never be needed on Site");
    }

    public AttachmentRecord findAttachmentByName(String name) throws Exception {
        throw new Exception("findAttachmentByName should never be needed on Site");
    }

    public AttachmentRecord findAttachmentByNameOrFail(String name) throws Exception {
        throw new Exception("findAttachmentByNameOrFail should never be needed on Site");
    }

    public AttachmentRecord createAttachment() throws Exception {
        throw new Exception("createAttachment should never be needed on Site");
    }

    public void deleteAttachment(String id, AuthRequest ar) throws Exception {
        throw new Exception("deleteAttachment should never be needed on Site");
    }

    public void unDeleteAttachment(String id) throws Exception {
        throw new Exception("unDeleteAttachment should never be needed on Site");
    }

    public void eraseAttachmentRecord(String id) throws Exception {
        throw new Exception("eraseAttachmentRecord should never be needed on Site");
    }

    public void writeTaskLink(AuthRequest ar, String taskId, int len) throws Exception {
        throw new ProgramLogicError("This site does not have a task '" + taskId
                + "' or any other task.  Sites don't have tasks.");
    }

    public void writeNoteLink(AuthRequest ar, String noteId, int len) throws Exception {
        NoteRecord note = getNote(noteId);
        if (note == null) {
            if ("x".equals(noteId)) {
                ar.write("(attached documents only)");
            }
            else {
                ar.write("(Note ");
                ar.write(noteId);
                ar.write(")");
            }
            return;
        }

        String nameOfLink = trimName(note.getSubject(), len);
        writeSiteUrl(ar);
        ar.write("/leaflet");
        ar.writeURLData(note.getId());
        ar.write(".htm\">");
        ar.writeHtml(nameOfLink);
        ar.write("</a>");
    }

    private void writeSiteUrl(AuthRequest ar) throws Exception {
        ar.write("<a href=\"");
        ar.writeHtml(ar.baseURL);
        ar.write("t/");
        ar.writeHtml(getKey());
    }

    /**
     * Different sites can have different style sheets (themes)
     */
    public String getThemePath() {
        String val = siteInfoRec.getThemePath();
        if (val == null || val.length() == 0) {
            return "theme/blue/";
        }
        return val;
    }

    public void setThemePath(String newName) {
        siteInfoRec.setThemePath(newName);
    }

    /**
     * This is the path to a folder (on disk) that new projects should be
     * created in for this site. Not all projects will actually be there because
     * older ones may have been created elsewhere, or moved, but new ones
     * created there. If this has a value, then a new folder is created inside
     * this one for the project.
     */
    public String getPreferredProjectLocation() {
        return siteInfoRec.getScalar("preferredLocation");
    }

    public void setPreferredProjectLocation(String newLoc) {
        siteInfoRec.setScalar("preferredLocation", newLoc);
    }

    /**
     * Modern sites have a folder on disk, and all the projects are inside that
     * folder. If this site has such a folder, return it, otherwise, return null
     */
    public File getSiteRootFolder() {
        String prefLocStr = getPreferredProjectLocation();
        if (prefLocStr == null || prefLocStr.length() == 0) {
            return null;
        }
        File prefLoc = new File(prefLocStr);
        if (prefLoc.exists()) {
            return prefLoc;
        }
        return null;
    }

    /**
     * Just a security measure, if given a path on the file system this check
     * quickly to see if the path is a valid folder within the file system.
     */
    public boolean isPathInSite(File testPath) throws Exception {
        File siteRoot = getSiteRootFolder();
        if (siteRoot == null) {
            // if no preferred location, then site has no root, and always false
            return false;
        }
        String rootPath = siteRoot.getCanonicalPath();
        String testStr = testPath.getCanonicalPath();
        return (testStr.startsWith(rootPath));
    }

    /**
     * Returns true if this is a site with a folder structure that the projects
     * should be put into.
     *
     * Returns false if this is a site & project in the datafolder
     */
    public boolean isSiteFolderStructure() {
        return (getSiteRootFolder() != null);
    }

    /**
     * Given a new project with a key 'p', this will return the File for the new
     * project file (which does not exist yet). There are two methods:
     *
     * 1) if a preferred location has been set, then a new folder in that will
     * be created, and the project NGProj placed within that. 2) if no preferred
     * location, then a regular NGPage will be created in datapath folder.
     *
     * Note: p is NOT the name of the file, but the sanitized key. The returned
     * name should have the .sp suffix on it.
     */
    private File getNewProjectPath(String p) throws Exception {
        File rootFolder = getSiteRootFolder();
        if (rootFolder != null) {
            return newProjFolderByKey(rootFolder, p);
        }

        // No site root, this is an OLDSTYLE site in the data path

        if (NGPage.dataPath == null) {
            throw new NGException("nugen.exception.datapath.not.initialized", null);
        }
        if (p.indexOf('/') >= 0) {
            throw new NGException("nugen.exception.path.have.slash", new Object[] { p });
        }
        File theFile = new File(NGPage.dataPath, p + ".sp");

        // this is a security check:
        // The result of combining the path in this way, must result in a path
        // that is still within the data folder, so check that the cannonical
        // path starts with the data folder path.
        if (!fileIsInDataPath(theFile)) {
            throw new ProgramLogicError(
                    "Somehow the NGPage file is supposed to be in the datapath, but did not turn out to be: "
                            + theFile);
        }

        return theFile;
    }

    /**
     * Will create a new folder to put the project into based on the key
     */
    private File newProjFolderByKey(File prefLoc, String key) throws Exception {

        File newFolder = new File(prefLoc, key);

        int count = 0;
        while (newFolder.exists()) {
            count++;
            newFolder = new File(prefLoc, key + "-" + count);
        }

        File cogFolder = new File(newFolder, ".cog");
        cogFolder.mkdirs();
        File newProjFile = new File(cogFolder, "ProjInfo.xml");
        return newProjFile;
    }

    /**
     * Confirm that this is a good unique key, or extend the passed value until
     * is is good by adding hyphen and a number on the end.
     */
    public String findUniqueKeyInSite(String key) throws Exception {

        // if it is already unique, use that. This tests ALL sites currently
        // loaded, but might consider a site-specific test when there is a
        // site specific search for a project.
        NGContainer ngc = NGPageIndex.getContainerByKey(key);
        if (ngc == null) {
            return key;
        }

        // NOPE, there is a container already with that key, so we have to find
        // another one. If there is already a numeral on the end, strip it off
        // so that the new numeral will most likely be one more that that, but
        // only
        // for single digit numerals after a hyphen. Not worth dealling with
        // more elaborate
        // than that
        if (key.length() > 6) {
            if (key.charAt(key.length() - 2) == '-') {
                char lastChar = key.charAt(key.length() - 1);
                if (lastChar >= '0' && lastChar <= '9') {
                    key = key.substring(0, key.length() - 2);
                }
            }
        }

        int testNum = 1;
        while (true) {
            String testKey = key + "-" + Integer.toString(testNum);
            ngc = NGPageIndex.getContainerByKey(testKey);
            if (ngc == null) {
                return testKey;
            }
            testNum++;
        }
    }

    public boolean isFrozen() throws Exception {
        return false;
    }

    // //////////////////// DEPRECATED METHODS//////////////////

    public String getAllowPublic() throws Exception {
        return siteInfoRec.getAllowPublic();
    }

    public void setAllowPublic(String allowPublic) throws Exception {
        siteInfoRec.setAllowPublic(allowPublic);
    }

    public void save(String modUser, long modTime, String comment) throws Exception {
        try {
            siteInfoRec.setModTime(modTime);
            siteInfoRec.setModUser(modUser);
            save();
            // commit the modified files to the CVS.
            CVSUtil.commit(getFilePath(), modUser, comment);
        }
        catch (Exception e) {
            throw new NGException("nugen.exception.unable.to.write.account.file",
                    new Object[] { getFilePath().toString() }, e);
        }

    }

    /**
     * Tells you if this file is within the dataPath folder
     */
    public static boolean fileIsInDataPath(File testFile) {
        String fullPath = testFile.getPath();
        String cleanUp1 = fullPath.toLowerCase().replace('\\', '/');
        String cleanUp2 = NGPage.dataPath.toLowerCase().replace('\\', '/');
        return cleanUp1.startsWith(cleanUp2);
    }

    public NGPage convertFolderToProj(AuthRequest ar, File expectedLoc) throws Exception {
        String projectName = expectedLoc.getName();
        String projectKey = SectionWiki.sanitize(projectName);
        projectKey = findUniqueKeyInSite(projectKey);
        File projectFile = new File(expectedLoc, projectKey + ".sp");
        NGPage ngp = createProjectAtPath(ar, projectFile, projectKey);
        String[] nameSet = new String[] { projectName };
        ngp.setPageNames(nameSet);
        return ngp;
    }

    private void assertPermissionToCreateProject(AuthRequest ar) throws Exception {
        if (ar.isLoggedIn()) {
            if (!primaryPermission(ar.getUserProfile())) {
                throw new Exception("Must be an owner of the site to create new projects");
            }
            return;
        }

        String licVal = ar.reqParam("lic");
        if (licVal == null || licVal.length() == 0) {
            throw new ProgramLogicError("Have to be logged in, or have a licensed link, "
                    + "to create a new project");
        }
        License lic = this.getLicense(licVal);
        if (lic == null) {
            throw new ProgramLogicError("Specified license (" + lic + ") not found");
        }
        if (ar.nowTime > lic.getTimeout()) {
            throw new ProgramLogicError("Specified license (" + lic + ") is no longer valid.  "
                    + "You will need an updated licensed link to create a new project.");
        }
        // TODO: check that the user for this license is still in the role

    }

    /**
     * NGPage object is created in memory, and can be manipulated in memory, but
     * be sure to call "savePage" before finished otherwise nothing is created
     * on disk.
     */
    public NGPage createProjectByKey(AuthRequest ar, String key) throws Exception {
        assertPermissionToCreateProject(ar);
        if (key.indexOf('/') >= 0) {
            throw new ProgramLogicError(
                    "Expecting a key value, but got something with a slash in it: " + key);
        }
        if (key.endsWith(".sp")) {
            throw new ProgramLogicError(
                    "this has changed, and the key should no longer end with .sp: " + key);
        }

        // get the sanitized form, just in case
        String sanitizedKey = SectionUtil.sanitize(key);
        File newFilePath = getNewProjectPath(sanitizedKey);
        return createProjectAtPath(ar, newFilePath, sanitizedKey);
    }

    public NGPage createProjectAtPath(AuthRequest ar, File newFilePath, String newKey)
            throws Exception {
        assertPermissionToCreateProject(ar);
        if (newFilePath.exists()) {
            throw new ProgramLogicError("Somehow the file given already exists: " + newFilePath);
        }

        Document newDoc = readOrCreateFile(newFilePath, "page");
        NGPage newPage = null;
        if (fileIsInDataPath(newFilePath)) {
            newPage = new NGPage(newFilePath, newDoc, this);
        }
        else {
            newPage = new NGProj(newFilePath, newDoc, this);
        }
        newPage.setKey(newKey);

        // make the current user the author, and member, of the new page
        newPage.addPlayerToRole("Administrators", ar.getBestUserId());
        newPage.addPlayerToRole("Members", ar.getBestUserId());

        // register this into the page index
        NGPageIndex.makeIndex(newPage);

        // add this new project into the user's watched projects list
        // so it is easy for them to find later.
        // Only do this if creating directly, and not through API
        UserProfile up = ar.getUserProfile();
        if (up != null) {
            up.setWatch(newPage.getKey(), ar.nowTime);
            UserManager.writeUserProfilesToFile();
        }

        return newPage;
    }

    /**
     * Sites have a set of licenses
     */
    public Vector<License> getLicenses() throws Exception {
        Vector<LicenseRecord> vc = siteInfoRec.getChildren("license", LicenseRecord.class);
        Vector<License> v = new Vector<License>();
        for (License child : vc) {
            v.add(child);
        }
        return v;
    }

    public License getLicense(String id) throws Exception {
        Vector<LicenseRecord> vc = siteInfoRec.getChildren("license", LicenseRecord.class);
        for (License child : vc) {
            if (id.equals(child.getId())) {
                return child;
            }
        }
        return null;
    }

    public boolean removeLicense(String id) throws Exception {
        Vector<LicenseRecord> vc = siteInfoRec.getChildren("license", LicenseRecord.class);
        for (LicenseRecord child : vc) {
            if (id.equals(child.getId())) {
                siteInfoRec.removeChild(child);
                return true;
            }
        }
        // maybe this should throw an exception?
        return false;
    }

    public License addLicense(String id) throws Exception {
        LicenseRecord lr = siteInfoRec.createChildWithID("license", LicenseRecord.class, "id", id);
        return lr;
    }

    public License createLicense(String userId, String role, long endDate, boolean readOnly)
            throws Exception {
        String id = IdGenerator.generateKey();
        License lr = addLicense(id);
        lr.setTimeout(endDate);
        lr.setCreator(userId);
        lr.setRole(role);
        lr.setReadOnly(false);
        return lr;
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
