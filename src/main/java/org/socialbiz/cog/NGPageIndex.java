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
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.List;
import java.util.Vector;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.TimeUnit;

import javax.servlet.ServletContext;

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;

/**
 * NGPageIndex is an index entry in an index of pages
 *
 * There exists a collection of NGPage objects (process leaves). This class
 * helps to form an index to those objects and to provide basic metadata about
 * those pages without having to have all pages (all leaves) in memory at the
 * same time. The index holds the page name, page key, references from that
 * page, pages that refer to that page, which book, last change, whether a
 * request for membership is pending, and who the admins (authors) of the page
 * are. These values are selected in order to allow for quick searching and
 * listing of exisitng pages according to certain common criteria. Most
 * importantly, this allows for back-links to be detected readily: since we have
 * a list of forward links, we can scan through there and build a list of back
 * links.
 *
 * Forward links are found by using a method on NGPage to find all the outbound
 * links. In this case, a link is string using wiki-link rules (can be a name
 * and link together separated by vertical bar). This can also include external
 * links, which are ignored by this index. Internal links are simply the name of
 * leaf being addressed. This name is case-insensitive and
 * punctuation-insensitive. This is accomplished by converting the name to a
 * lowercase and stripping all non alpha-num characters out. This simplified
 * version of the name is compared between what the page is linking to and the
 * simplified names of the other pages.
 *
 * Leaves (pages) can have multiple names, so that the name can be changed
 * without breaking links -- old reference will continue to work.
 *
 * Names are not necessarily unique: there can be multiple leaves with the same
 * name, because users are not prevented from entering a particular name. This
 * means that there needs to be a "disambiguation" step in the case that there
 * are other pages with the same name.
 *
 * The approach is to have two objects: one object NGPageIndex represents the
 * leaf (page) and the other represents a particular name value (NGTerm). The
 * term object represents a many-to-many association between all the pages that
 * link to a term, and all the pages that can be targets of that term. Thus the
 * NGPageIndex object has a "name" collection of terms, and a "links" collection
 * of terms. Each NGTerm has a "target pages" collection of index entries, and a
 * "source links" collection of index entries.
 *
 * For example, a page "p1" may have three names: "a", "b", and "c". The page
 * "p1" will be represented by an NGPageIndex object. There will be three NGTerm
 * objects, one for each name. Each of those NGTerm objects will have a single
 * target reference back to the page "p1". If a page "p2" links to "a", then in
 * the link collection for "p2" it will have a pointer to the term "a", and term
 * "a" will include "p2" in the "source link" collection.
 *
 * If you are on page "p1", and want to find all the pages that point to "p1",
 * then you find all the terms that represent the names of "p1", and find all
 * the pages that link to that term.
 *
 * This has the effect of over counting in the case of non-unique names. If
 * there are three pages that have a single link to "a", and there are three
 * pages that have the single name "a", then each of the three target pages will
 * show three pages linking to them. And each page will effectively link to all
 * three of the pages with the same name. Even though the page has only one
 * link. In practice, the user will have to choose the page when traversing the
 * link.
 */
public class NGPageIndex {

    public Vector<NGTerm> nameTerms;
    public Vector<NGTerm> refTerms;
    public Vector<NGTerm> hashTags;
    public long lastChange;
    public boolean requestWaiting;
    public boolean isDeleted;
    public String[] admins; // a.k.a. authors

    public File containerPath;
    public String containerName; // The nicest name to use for this container
    public String containerKey;

    private static Vector<NGPageIndex> allContainers;
    private static Hashtable<String, NGPageIndex> keyToContainer;
    private static Hashtable<String, NGPageIndex> upstreamToContainer;

    // there may be a number of pages that have unsent email, and so this is a
    // list of keys
    private static Vector<String> projectsWithEmailToSend = new Vector<String>();

    /**
     * containerType is the type of container whether it is Site, Project or
     * User See constants below
     */
    private int containerType = 0;

    // use these constants for containerType
    private static final int CONTAINER_TYPE_ACCOUNT = 1;
    // private static final int CONTAINER_TYPE_USER = 2;
    private static final int CONTAINER_TYPE_PAGE = 3;
    private static final int CONTAINER_TYPE_PROJECT = 4;

    public String pageBookName;
    public String pageBookKey;

    private long lockedBy = 0;

    public Exception lockedByAuditException = new Exception("Audit Lock Trail");
    private static int blqSize = 10;

    public static Hashtable<String, Vector<ArrayBlockingQueue<String>>> blqList = new Hashtable<String, Vector<ArrayBlockingQueue<String>>>();

    public static Hashtable<String, ArrayBlockingQueue<String>> bsnList = new Hashtable<String, ArrayBlockingQueue<String>>();

    public static final String PAGE_NTFX_WAIT = "pageNotificationWait";
    public static final String UPDATE_LOCK_WAIT = "updateLockWait";
    public static final String LOCK_ID = "lock";
    public static final String NO_LOCK_ID = "nolock";
    private static HashMap<String, List<NGPageIndex>> lockMap = new HashMap<String, List<NGPageIndex>>();

    private ArrayBlockingQueue<String> lockBlq;

    /**
     * Returns the collection of all target pages that are linked FROM this
     * page. Vector contains NGPageIndex objects. Remember, this may contain
     * multiple pages for a single link if there are multiple pages with the
     * same name.
     */
    public Vector<NGPageIndex> getOutLinkPages() {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        for (NGTerm term : refTerms) {
            for (NGPageIndex target : term.targetLeaves) {
                if (!ret.contains(target)) {
                    ret.add(target);
                }
            }
        }
        sortByName(ret);
        return ret;
    }

    /**
     * Returns the collection of all source pages that link TO this page. Vector
     * contains NGPageIndex objects. Remember, this may contain multiple pages
     * for a single link if there are multiple pages with the same name.
     */
    public Vector<NGPageIndex> getInLinkPages() {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        for (NGTerm term : nameTerms) {
            for (NGPageIndex target : term.sourceLeaves) {
                if (!ret.contains(target)) {
                    ret.add(target);
                }
            }
        }
        sortByName(ret);
        return ret;
    }

    /**
     * Determine whether there are any inbound links, and if so it is not an
     * orphan, but if there are none, then it is an orphan.
     */
    public boolean isOrphan() {
        for (NGTerm term : nameTerms) {
            // if there are any pages pointing to this term, then
            // this page is not an orphan.
            if (term.sourceLeaves.size() > 0) {
                // found one project that points to this term that points
                // to this project. That is enough to not be an orphan.
                return false;
            }
        }
        // if we found none, then it is an orphan
        return true;
    }

    /**
     * This should be called everytime the page contents are changed in a way
     * that might effect the links on the page.
     */
    public static void refreshOutboundLinks(NGPage aPage) throws Exception {
        String key = aPage.getKey();
        NGPageIndex ngpi = getContainerIndexByKey(key);
        if (ngpi == null) {
            throw new NGException("nugen.exception.refresh.links", new Object[] { aPage.getKey() });
        }
        ngpi.unlinkAll();
        ngpi.buildLinks(aPage);

        // check if there is new email, and put this in the index as well
        if (aPage.countEmailToSend() > 0) {
            projectsWithEmailToSend.add(key);
        }
    }

    public static Vector<NGPageIndex> getAllContainer() {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();

        for (NGPageIndex ngpi : allContainers) {
            if (!ngpi.isDeleted) {
                ret.add(ngpi);
            }
        }
        sortByName(ret);
        return ret;
    }

    public static Vector<NGPageIndex> getDeletedContainers() {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        if (allContainers == null) {
            return ret;
        }
        // if system is not initialized then return an empty vector
        for (NGPageIndex ngpi : allContainers) {
            if (ngpi.isDeleted) {
                ret.add(ngpi);
            }
        }
        sortByName(ret);
        return ret;
    }

    /**
     * Returns a vector of NGPageIndex objects which represent projects which
     * are all part of a single site. Should be called get all projects in site
     */
    public static Vector<NGPageIndex> getAllProjectsInSite(String accountKey) throws Exception {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        for (NGPageIndex ngpi : allContainers) {
            if (ngpi.containerType == 0) {
                // just need to assure that the data is consistent and correct
                throw new Exception("uninitialized ngpi.containerType!!");
            }
            if (ngpi.containerType != CONTAINER_TYPE_PROJECT
                    && ngpi.containerType != CONTAINER_TYPE_PAGE) {
                // only consider book/project style containers
                continue;
            }
            if (!accountKey.equals(ngpi.pageBookKey)) {
                // only consider if the project is in the site we look for
                continue;
            }
            if (ngpi.isDeleted) {
                // ignore deleted projects
                continue;
            }
            ret.add(ngpi);
        }
        sortByName(ret);
        return ret;
    }

    public static Vector<NGPageIndex> getAllPagesForAdmin(UserProfile user) {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        if (allContainers == null) {
            throw new RuntimeException("Problem, server has not been initialied ... yet.");
        }
        for (NGPageIndex ngpi : allContainers) {
            if (ngpi.containerType != CONTAINER_TYPE_PROJECT
                    && ngpi.containerType != CONTAINER_TYPE_PAGE) {
                // only consider project style containers
                continue;
            }
            for (String admin : ngpi.admins) {
                if (user.hasAnyId(admin)) {
                    ret.add(ngpi);
                    break;
                }
            }
        }
        sortByName(ret);
        return ret;
    }

    public static Vector<NGPageIndex> getProjectsUserIsPartOf(UserRef ale) throws Exception {
        Vector<NGPageIndex> ret = new Vector<NGPageIndex>();
        if (allContainers == null) {
            throw new RuntimeException("Problem, server has not been initialied ... yet.");
        }
        for (NGPageIndex ngpi : allContainers) {
            if (ngpi.containerType != CONTAINER_TYPE_PROJECT
                    && ngpi.containerType != CONTAINER_TYPE_PAGE) {
                // only consider project style containers
                continue;
            }
            NGContainer container = ngpi.getContainer();
            List<NGRole> roles = container.getAllRoles();

            for (NGRole role : roles) {
                if (role.isPlayer(ale)) {
                    ret.add(ngpi);
                    break;
                }
            }
        }
        sortByName(ret);
        return ret;
    }

    /**
     * Given a string tag value, looks for and returns all the pages that are
     * tagged with that tag.
     *
     * Must NOT manipulate resulting vector in any way!
     */
    public static Vector<NGPageIndex> getContainersForTag(String tag) throws Exception {
        if (tag == null) {
            throw new ProgramLogicError("null value tag given to getPagesForTag");
        }
        NGTerm tagTerm = NGTerm.findTagIfExists(tag);
        if (tagTerm == null) {
            return new Vector<NGPageIndex>();
        }
        return tagTerm.targetLeaves;
    }

    public NGPage getPage() throws Exception {
        return (NGPage) getContainer();
    }

    /**
     * Get the container object associated with this index entry, or return a
     * null if one can not be found.
     */
    public NGContainer getContainer() throws Exception {
        setLock();
        if (containerType == CONTAINER_TYPE_PROJECT) {
            return NGProj.readProjAbsolutePath(containerPath);
        }
        else if (containerType == CONTAINER_TYPE_PAGE) {
            return NGPage.readPageAbsolutePath(containerPath);
        }
        else if (containerType == CONTAINER_TYPE_ACCOUNT) {
            return NGBook.readSiteByKey(containerKey);
        }
        return null;
    }

    /**
     * Get the container object associated with this index entry, or throw an
     * exception if that container can not be found. This method never returns a
     * null;
     */
    public NGContainer getContainerOrFail() throws Exception {
        NGContainer val = getContainer();
        if (val != null) {
            return val;
        }
        throw new NGException("nugen.exception.fail.to.locate.container.obj", new Object[] {
                containerName, containerKey });
    }

    public void writeTruncatedLink(AuthRequest ar, int len) throws Exception {
        String linkName = containerName;

        ar.write("\n    <a href=\"");
        ar.writeHtml(ar.retPath);
        ar.writeHtml(ar.getResourceURL(this, "public.htm"));
        ar.write("\"  title=\"Navigate to leaf: ");
        ar.writeHtml(linkName);
        ar.write("\">");
        if (linkName.length() > len) {
            linkName = linkName.substring(0, len);
        }
        ar.writeHtml(linkName);
        if (isDeleted) {
            ar.write("<img src=\"");
            ar.writeHtml(ar.retPath);
            ar.write("deletedLink.gif\">");
        }
        ar.write("</a>");
    }

    /**
     * Set all static values back to their initial states, so that garbage
     * collection can be done, and subsequently, the class will be
     * reinitialized.
     *
     * NGPageIndex is the master, which calls NGBook and NGPage.
     */
    public synchronized static void clearAllStaticVars() {
        allContainers = null;
        keyToContainer = null;
        upstreamToContainer = null;
        NGBook.clearAllStaticVars();
        NGPage.clearAllStaticVars();
        NGTerm.clearAllStaticVars();
        SectionDef.clearAllStaticVars();
        UserManager.clearAllStaticVars();
        SiteReqFile.clearAllStaticVars();
    }

    /**
     * This method must not be called by any method that is used during the
     * actual initialization itself. This method will wait for up to 20 seconds
     * for initialization to complete with either a failure or a successful
     * initialization.
     */
    public static boolean isInitialized() {
        // if the server is currently actively being initialized, then it if
        // probably worth
        // waiting a few seconds instead of failing
        int countDown = 40;
        while (ServerInitializer.isActivelyStarting() && --countDown > 0) {
            // test every 1/5 second, and wait up to 8 seconds for the
            // server to finish initializing, otherwise give up
            try {
                Thread.sleep(200);
            }
            catch (Exception e) {
                countDown = 0;
                // don't care what the exception is
                // just exit loop if sleep throws exception
            }
        }

        return (ServerInitializer.isRunning());
    }

    public static Exception initFailureException() {
        return ServerInitializer.lastFailureMsg;
    }

    /**
     * provides compatibility with earlier version that would attempt to
     * initialize on any given page refresh, and throw an exception if it
     * failed. Newer approach is to initialize once, but this will throw the
     * exception anyway if one was found attempting to initialize.
     */
    public static void assertInitialized() throws Exception {
        if (!isInitialized()) {
            Exception ex = initFailureException();
            if (ex != null) {
                throw new NGException("nugen.exception.sys.not.initialize.correctly", null, ex);
            }
            throw new ProgramLogicError("NGPageIndex has never been initialized");
        }
    }

    public static synchronized void initializeInternal(ServletContext sc) throws Exception {
        ConfigFile.initialize(sc);
        ConfigFile.assertConfigureCorrectInternal();

        UserManager.loadUpUserProfilesInMemory();

        String attachFolder = ConfigFile.getProperty("attachFolder");
        File attachFolderFile = new File(attachFolder);
        AttachmentVersionSimple.attachmentFolder = attachFolderFile;

        // reinitialize ... should be as good as new.
        initIndex();
        SSOFIUserManager.initSSOFI(ConfigFile.getProperty("baseURL"));
    }

    public static synchronized void initIndex() throws Exception {
        if (allContainers == null) {
            String path = ConfigFile.getProperty("dataFolder");
            NGPage.initDataPath(path);
            scanAllPages();
        }
    }

    public static synchronized void scanAllPages() throws Exception {
        System.out.println("Beginning SCAN for all pages in system.");
        Vector<File> allPageFiles = new Vector<File>();
        Vector<File> allProjectFiles = new Vector<File>();
        NGTerm.initialize();
        keyToContainer = new Hashtable<String, NGPageIndex>();
        upstreamToContainer = new Hashtable<String, NGPageIndex>();
        allContainers = new Vector<NGPageIndex>();

        String rootDirectory = ConfigFile.getProperty("dataFolder");
        if (rootDirectory != null && rootDirectory.length() > 0) {
            File root = ConfigFile.getDataFolderOrFail();

            NGBook.scanAllSites(root);
            for (NGBook acct : NGBook.getAllSites()) {
                makeIndex(acct);
            }

            for (File child : root.listFiles()) {
                if (child.getName().endsWith(".sp")) {
                    allPageFiles.add(child);
                }
            }
        }
        else {
            System.out
                    .println("Skipped scanning the data folder because no setting for 'datafolder'");
        }

        String[] libFolders = ConfigFile.getArrayProperty("libFolder");
        Vector<File> allSiteFiles = new Vector<File>();

        for (String libFolder : libFolders) {
            File libDirectory = new File(libFolder);
            if (!libDirectory.exists()) {
                throw new Exception("Configuration error: LibFolder does not exist: " + libFolder);
            }
            seekProjectsAndSites(libDirectory, allProjectFiles, allSiteFiles);
        }

        // now process the site files if any
        for (File aSitePath : allSiteFiles) {
            try {
                NGBook ngb = NGBook.readSiteAbsolutePath(aSitePath);
                NGBook.registerSite(ngb);
                makeIndex(ngb);
            }
            catch (Exception eig) {
                reportUnparseableFile(aSitePath, eig);
            }
        }
        // page files for data folder
        for (File aProjPath : allPageFiles) {
            try {
                NGPage aPage = NGPage.readPageAbsolutePath(aProjPath);
                makeIndex(aPage);
            }
            catch (Exception eig) {
                reportUnparseableFile(aProjPath, eig);
            }
        }
        // now process the project files if any
        for (File aProjPath : allProjectFiles) {
            try {
                NGProj aProj = NGProj.readProjAbsolutePath(aProjPath);
                makeIndex(aProj);
            }
            catch (Exception eig) {
                reportUnparseableFile(aProjPath, eig);
            }
        }
        System.out.println("Concluded SCAN for all pages in system.");

    }

    private static void reportUnparseableFile(File badFile, Exception eig) {
        AuthRequest dummy = AuthDummy.serverBackgroundRequest();
        Exception wrapper = new Exception("Failure reading file during Initialization: "
                + badFile.toString(), eig);
        dummy.logException("Initialization Loop Continuing After Failure", wrapper);
    }

    private static void seekProjectsAndSites(File folder, Vector<File> pjs, Vector<File> acts)
            throws Exception {

        // only use the first ".sp" file or ".site" file in a given folder
        boolean foundOne = false;

        File cogFolder = new File(folder, ".cog");
        if (cogFolder.exists()) {
            File projectFile = new File(cogFolder, "ProjInfo.xml");
            if (projectFile.exists()) {
                pjs.add(projectFile);
                foundOne = true;
            }
            File siteFile = new File(cogFolder, "SiteInfo.xml");
            if (siteFile.exists()) {
                acts.add(siteFile);
                foundOne = true;
            }
        }

        for (File child : folder.listFiles()) {
            String name = child.getName();
            if (child.isDirectory()) {
                // only drill down if not the cog folder
                if (!name.equalsIgnoreCase(".cog")) {
                    seekProjectsAndSites(child, pjs, acts);
                }
                continue;
            }
            if (foundOne) {
                // ignore all files after one is found
                continue;
            }
            if (name.endsWith(".sp")) {
                // this is the migration case, a .sp file exists, but the
                // .cog/ProjInfo.xml
                // does not exist, so move the file there immediately.
                if (!cogFolder.exists()) {
                    cogFolder.mkdirs();
                }
                String key = name.substring(0, name.length() - 3);
                File keyFile = new File(cogFolder, "key_" + key);
                keyFile.createNewFile();
                File projInfoFile = new File(cogFolder, "ProjInfo.xml");
                UtilityMethods.copyFileContents(child, projInfoFile);
                child.delete();
                pjs.add(projInfoFile);
                foundOne = true;
            }
            else if (name.endsWith(".site")) {
                acts.add(child);
                foundOne = true;
            }
        }
    }

    public static void makeIndex(NGContainer ngc) throws Exception {
        String key = ngc.getKey();

        // clean up old index entries using old name
        NGPageIndex foundPage = keyToContainer.get(key);
        if (foundPage != null) {
            foundPage.unlinkAll();
            allContainers.remove(foundPage);
            keyToContainer.remove(foundPage.containerKey);
        }

        NGPageIndex bIndex = new NGPageIndex(ngc);
        if (bIndex.containerType == 0) {
            throw new Exception("uninitialized ngpi.containerType in makeIndex");
        }
        allContainers.add(bIndex);
        keyToContainer.put(key, bIndex);

        if (ngc instanceof NGPage) {
            String upstream = ((NGPage)ngc).getUpstreamLink();
            if (upstream!=null && upstream.length()>0) {
                int lastSlash = upstream.indexOf("/");
                upstreamToContainer.put(upstream.substring(0,lastSlash+1), bIndex);
            }
        }



        // look for email and remember if there is some
        if (ngc instanceof NGPage) {
            if (((NGPage) ngc).countEmailToSend() > 0) {
                projectsWithEmailToSend.add(key);
            }
        }
    }

    public static NGPageIndex getContainerIndexByKey(String key) throws Exception {
        assertInitialized();
        if (key == null) {
            // this programming mistake should never happen
            throw new ProgramLogicError("null value passed as key to getContainerIndexByKey");
        }
        return keyToContainer.get(key);
    }

    public static NGPageIndex getContainerIndexByKeyOrFail(String key) throws Exception {
        NGPageIndex ngpi = getContainerIndexByKey(key);
        if (ngpi == null) {
            throw new NGException("nugen.exception.container.not.found", new Object[] { key });
        }
        return ngpi;
    }

    public static NGContainer getContainerByKey(String key) throws Exception {
        NGPageIndex foundPI = getContainerIndexByKey(key);
        if (foundPI == null) {
            return null;
        }

        return foundPI.getContainer();
    }

    public static NGContainer getContainerByKeyOrFail(String key) throws Exception {
        NGContainer ngc = getContainerByKey(key);
        if (ngc == null) {
            throw new NGException("nugen.exception.container.not.found", new Object[] { key });
        }
        return ngc;
    }

    public static NGPage getProjectByKeyOrFail(String key) throws Exception {
        NGContainer ngc = getContainerByKeyOrFail(key);
        if (!(ngc instanceof NGPage)) {
            throw new NGException("nugen.exception.container.not.project", new Object[] { key });
        }

        return (NGPage) ngc;
    }

    public static NGBook getSiteByIdOrFail(String key) throws Exception {
        NGContainer ngc = getContainerByKeyOrFail(key);
        if (!(ngc instanceof NGBook)) {
            throw new NGException("nugen.exception.container.not.account", new Object[] { key });
        }

        return (NGBook) ngc;
    }

    public static NGPage getProjectByUpstreamLink(String upstream) throws Exception {
        int lastSlash = upstream.indexOf("/");
        NGPageIndex ngpi = upstreamToContainer.get(upstream.substring(0,lastSlash+1));
        if (ngpi != null) {
            return ngpi.getPage();
        }
        return null;
    }

    /**
     * Finding pages by name means that you might find more than one so you get
     * a vector back, which might be empty, it might have one or it might have
     * more pages.
     */
    public static Vector<NGPageIndex> getPageIndexByName(String pageName) throws Exception {
        assertInitialized();

        NGTerm term = NGTerm.findTerm(pageName);
        if (term == null) {
            throw new NGException("nugen.exception.key.dont.have.alphanum", null);
        }
        return term.targetLeaves;
    }

    public static Vector<NGPageIndex> getContainerIndexByName(String name) throws Exception {
        assertInitialized();

        NGTerm term = NGTerm.findTerm(name);
        if (term == null) {
            throw new NGException("nugen.exception.key.dont.have.alphanum", null);
        }
        return term.targetLeaves;
    }

    public static boolean pageExists(String pageName) throws Exception {
        NGTerm term = NGTerm.findTermIfExists(pageName);
        if (term == null) {
            return false;
        }
        return (term.targetLeaves.size() > 0);
    }

    public static NGPageIndex[] getAllPageIndex() throws Exception {
        NGPageIndex[] indxlist = null;
        if (allContainers != null) {
            indxlist = new NGPageIndex[allContainers.size()];
            allContainers.copyInto(indxlist);
        }
        return indxlist;
    }

    public boolean isInVector(Vector<NGPageIndex> v) {
        for (NGPageIndex y : v) {
            if (y.containerKey.equals(containerKey)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Implement sorting and comparator classes
     */
    public static void sortByName(Vector<NGPageIndex> v) {
        Collections.sort(v, new NGPIByName());
    }

    public static void sortInverseChronological(Vector<NGPageIndex> v) {
        Collections.sort(v, new NGPIByInverseChange());
    }

    private static class NGPIByName implements Comparator<NGPageIndex> {
        NGPIByName() {
        }

        public int compare(NGPageIndex o1, NGPageIndex o2) {
            String n1 = o1.containerName.toLowerCase();
            String n2 = o2.containerName.toLowerCase();
            return n1.compareTo(n2);
        }

    }

    /**
     * Used to sort NGPI entries from most recent change, to least recent change
     */
    private static class NGPIByInverseChange implements Comparator<NGPageIndex> {
        NGPIByInverseChange() {
        }

        public int compare(NGPageIndex o1, NGPageIndex o2) {
            long n1 = o1.lastChange;
            long n2 = o2.lastChange;
            if (n1 < n2) {
                return 1;
            }
            else if (n1 == n2) {
                return 0;
            }
            else {
                return -1;
            }
        }

    }

    static public String getAllProjectFullNameList(String matchKey) throws Exception {
        StringBuffer sb = new StringBuffer();
        boolean addComma = false;

        for (NGPageIndex page : allContainers) {
            if (page.containerName.toLowerCase().startsWith(matchKey.toLowerCase())) {
                if (addComma) {
                    sb.append(",");
                }
                sb.append(page.containerName);
                sb.append(":");
                sb.append(page.pageBookKey);
                sb.append("/");
                sb.append(page.containerKey);
                addComma = true;
            }
        }
        return sb.toString();
    }

    static public String getProjectFullNameList(String matchKey, String bookKey) throws Exception {
        StringBuffer sb = new StringBuffer();
        boolean addComma = false;

        for (NGPageIndex page : getAllProjectsInSite(bookKey)) {
            if (page.containerName.toLowerCase().startsWith(matchKey.toLowerCase())) {
                if (addComma) {
                    sb.append(",");
                }
                sb.append(page.containerName);
                addComma = true;
            }
        }
        String str = sb.toString();
        return str;
    }

    public static NGContainer findContainer(String key) throws Exception {

        NGPageIndex foundPI = getContainerIndexByKeyOrFail(key);
        return foundPI.getContainer();
    }

    public void deleteContainerFile() {
        File deadFile = containerPath;
        if (deadFile.exists()) {
            deadFile.delete();
        }
    }

    public boolean isProject() {
        return (containerType == CONTAINER_TYPE_PROJECT || containerType == CONTAINER_TYPE_PAGE);
    }

    public static void assertBook(String siteId) throws Exception {
        try {
            NGPageIndex ngpi = NGPageIndex.getContainerIndexByKeyOrFail(siteId);
            if (ngpi.containerType != CONTAINER_TYPE_ACCOUNT) {
                throw new NGException("nugen.exception.not.account.container", null);
            }
        }
        catch (Exception e) {
            throw new NGException("nugen.exception.site.with.key.not.found",
                    new Object[] { siteId }, e);
        }
    }

    public static void postEventMsg(String emsg) {
        String result = "evt_" + emsg;
        Vector<ArrayBlockingQueue<String>> v = blqList.get(emsg);
        if (v != null) {
            // copied out to an array because I had concurrent update problems
            // otherwise.
            Object[] olist = v.toArray();
            for (Object ooo : olist) {
                try {
                    @SuppressWarnings("unchecked")
                    ArrayBlockingQueue<String> queue = (ArrayBlockingQueue<String>) ooo;
                    queue.add(result);
                }
                catch (Exception e) {
                    // Queue may be full ignore
                }
            }
        }
    }

    public static String getEvtMsg(String id, String emsg) throws Exception {

        String wTime = ConfigFile.getProperty(PAGE_NTFX_WAIT);
        if (wTime == null) {
            wTime = "10";
        }

        long l = DOMFace.safeConvertLong(wTime);

        Vector<ArrayBlockingQueue<String>> v = blqList.get(emsg);
        if (v == null) {
            v = new Vector<ArrayBlockingQueue<String>>();
            blqList.put(emsg, v);
        }
        ArrayBlockingQueue<String> blq = new ArrayBlockingQueue<String>(blqSize);

        if (id.endsWith("ie6")) {
            try {
                ArrayBlockingQueue<String> oblq = bsnList.put(id, blq);
                if (oblq != null) {
                    oblq.add("cancel");
                }
            }
            catch (Exception e) {
                // Queue may be full ignore
            }
        }

        v.add(blq);
        String rmsg = blq.poll(l, TimeUnit.SECONDS);
        v.remove(blq);
        return rmsg;
    }

    public void setLock() throws Exception {
        long thisThread = Thread.currentThread().getId();
        try {
            if (lockedBy == thisThread) {
                // thread already has this lock, so ignore this. Everything is
                // unlocked at once at the end of the web request
                return;
            }

            String ctid = "tid:" + thisThread;
            String lockObj = lockBlq.poll(10, TimeUnit.SECONDS);
            if (lockObj == null) {
                throw new NGException("nugen.exception.fail.to.lock.container", new Object[] {
                        ctid, this.containerKey, lockedBy }, lockedByAuditException);
            }

            lockedBy = thisThread;
            lockedByAuditException = new Exception("Audit lock hold by " + ctid + " pageId: "
                    + containerKey);
            List<NGPageIndex> ngpiList = NGPageIndex.lockMap.get(ctid);
            if (ngpiList == null) {
                ngpiList = new ArrayList<NGPageIndex>();
                NGPageIndex.lockMap.put(ctid, ngpiList);
            }
            ngpiList.add(this);
        }
        catch (Exception e) {
            String msg = "Failed to set up the lock for Edit, Please check '" + UPDATE_LOCK_WAIT
                    + "' setting in Config file.";
            throw new NGException("nugen.exception.dynamic.data", new Object[] { msg }, e);
        }
    }

    public void clearLock() {
        long thisThread = Thread.currentThread().getId();
        String ctid = "tid:" + thisThread;
        try {
            if (lockedBy != thisThread) {
                // should probably throw an exception here ... but signature is
                // not right
                // and, not sure what we can do about it. Unlocking should
                // continue.
                System.out
                        .println("LOCK ERROR - clear lock called when thread does not have lock!");
                return;
            }
            this.lockedBy = 0;
            this.lockedByAuditException = null;
            lockBlq.add(LOCK_ID);
        }
        catch (IllegalStateException e) {
            // Lock is already available
            System.out.println(new Date().toString() + " " + ctid + ": clearLock cid: "
                    + this.containerKey + " lock is available nothing to clear");
        }
    }

    public static void clearLocksHeldByThisThread() {
        String ctid = "tid:" + Thread.currentThread().getId();
        List<NGPageIndex> indexList = lockMap.remove(ctid);
        if (indexList == null) {
            return;
        }
        for (NGPageIndex ngpindx : indexList) {
            ngpindx.clearLock();
        }
    }

    public static void releaseLock(NGContainer ngc) {
        String ckey = ngc.getKey();
        String ctid = "tid:" + Thread.currentThread().getId();
        List<NGPageIndex> indexList = lockMap.get(ctid);
        if (indexList == null) {
            return;
        }

        Iterator<NGPageIndex> iter = indexList.iterator();
        while (iter.hasNext()) {
            NGPageIndex ngpi = iter.next();
            if (ngpi.containerKey.equalsIgnoreCase(ckey)) {
                ngpi.clearLock();
                indexList.remove(ngpi);
                break;
            }
        }

    }

    // ///////////// INTERNAL PRIVATE METHODS ///////////////////

    /**
     * nobody should need to call the constructor, since these are created
     * purely by scanning files, or by adding containers. The index is built and
     * maintained internally.
     */
    private NGPageIndex(NGContainer container) throws Exception {
        lockBlq = new ArrayBlockingQueue<String>(1);
        lockBlq.add(LOCK_ID);
        buildLinks(container);
    }

    private void buildLinks(NGContainer container) throws Exception {

        containerName = "~Container Has No Name";
        isDeleted = container.isDeleted();
        lastChange = container.getLastModifyTime();

        // consistency check, either the nameTerms or refTerms vectors must
        // be missing or empty.
        if (nameTerms != null && nameTerms.size() > 0) {
            throw new RuntimeException(
                    "Program logic is asking for building nameTerms links when it already has some.");
        }
        if (refTerms != null && refTerms.size() > 0) {
            throw new RuntimeException(
                    "Program logic is asking for building refTerms links when it already has some.");
        }

        containerPath = container.getFilePath();
        containerKey = container.getKey();

        if (container instanceof NGPage) {
            if (container instanceof NGProj) {
                containerType = CONTAINER_TYPE_PROJECT;
            }
            else {
                containerType = CONTAINER_TYPE_PAGE;
            }
        }
        else if (container instanceof NGBook) {
            containerType = CONTAINER_TYPE_ACCOUNT;
        }
        else {
            throw new Exception("Program Logic Error: don't know what kind of container this is: "
                    + containerPath);
        }

        initNameTerms(container);

        initLinkTerms(container);

        // record the admins (authors) of the page
        NGRole adminRole = container.getSecondaryRole();
        List<AddressListEntry> v = adminRole.getExpandedPlayers(container);
        admins = new String[v.size()];
        int i = 0;
        for (AddressListEntry ale : v) {
            admins[i++] = ale.getUniversalId();
        }

        initIndexForHashTags(container);

        if (container instanceof NGPage) {
            NGPage ngp = (NGPage) container;
            NGBook ngb = ngp.getSite();
            if (ngb != null) {
                pageBookName = ngb.getName();
                pageBookKey = ngb.getKey();
            }
        }
    }

    /**
     * The container (project or site) can have any number of names. For each
     * name, an associated term is found, and that term is made to point to this
     * container.
     */
    private void initNameTerms(NGContainer container) throws Exception {
        Vector<NGTerm> nameTermsTmp = new Vector<NGTerm>();

        // make a link to the page key first
        NGTerm term = NGTerm.findTerm(containerKey);
        if (term == null) {
            throw new NGException("nugen.exception.key.dont.have.alphanum", null);
        }
        if (isInVector(term.targetLeaves)) {
            throw new NGException("nugen.exception.duplicacy.problem", null);
        }
        term.targetLeaves.add(this);
        nameTermsTmp.add(term);

        String[] containerNames = container.getContainerNames();
        if (containerNames.length > 0) {
            // picks the first name as the nicest, official, name
            containerName = containerNames[0];
        }
        for (int i = 0; i < containerNames.length; i++) {
            String name = containerNames[i];
            term = NGTerm.findTerm(name);
            if (term == null) {
                // this is not a good name, ignore it
                continue;
            }
            if (!nameTermsTmp.contains(term)) {
                if (isInVector(term.targetLeaves)) {
                    throw new NGException("nugen.exception.duplicacy.problem", null);
                }
                term.targetLeaves.add(this);
                sortByName(term.targetLeaves);
                nameTermsTmp.add(term);
            }
        }
        nameTerms = nameTermsTmp;
    }

    /**
     * Containers have outbound links. This method finds all the links, and then
     * finds the associated terms, then marks those terms as having source links
     * from this container.
     */
    private void initLinkTerms(NGContainer container) throws Exception {
        Vector<String> tmpRef = new Vector<String>();
        if (container instanceof NGPage) {
            // find the links in the page, right now only the Link type sections

            ((NGPage) container).findLinks(tmpRef);
            Collections.sort(tmpRef);
        }
        // remove duplicate entries in the map
        Vector<NGTerm> refTermTmp = new Vector<NGTerm>();
        for (String entry : tmpRef) {
            int barPos = entry.indexOf("|");
            if (barPos >= 0) {
                entry = entry.substring(barPos + 1).trim();
            }

            // detect external links, any link with a slash in it, is assumed
            // to be a URL. To address a page with a slash in the name, address
            // it without the slash (which is stripped in sanitize anyway).
            if (entry.indexOf("/") >= 0) {
                continue; // skip external links
            }
            NGTerm term = NGTerm.findTerm(entry);
            if (term == null) {
                // this is not a good link, ignore it
                continue;
            }
            if (!refTermTmp.contains(term)) {
                refTermTmp.add(term);
                if (isInVector(term.sourceLeaves)) {
                    throw new NGException("nugen.exception.duplicacy.problem.with.source.leaves",
                            null);
                }
                term.sourceLeaves.add(this);
                sortByName(term.sourceLeaves);
            }
        }
        // update this all at once at the end to avoid multi-threading problems
        // with half-built indices
        refTerms = refTermTmp;
    }

    /**
     * Page objects can have hash tags in the description. The hash tag starts
     * with a # character and continues to the first white space A NGTerm object
     * is created for each tag, and made to point to this page Each NGPageIndex
     * object contains a vector of such hash terms. If each page lists their
     * hash tags, and links to all the other pages that have that hash tag, then
     * it is an easy way to link similar pages together automatically in both
     * directions.
     */
    private void initIndexForHashTags(NGContainer container) throws Exception {
        Vector<String> tagVals = new Vector<String>();
        if (container instanceof NGPage) {
            NGPage ngp = (NGPage) container;
            ngp.findTags(tagVals);
        }
        Vector<NGTerm> hashTagsTmp = new Vector<NGTerm>();
        for (String hashVal : tagVals) {
            if (hashVal.length() < 3) {
                continue;
            }
            NGTerm term = NGTerm.findOrCreateTag(hashVal);

            // term can be null if the tag value was not a valid tag value
            // for example it was zero length, or consisted only of punctuation.
            // also, eliminate duplicates at this step
            if (term != null && !hashTagsTmp.contains(term)) {
                term.targetLeaves.add(this);
                sortByName(term.targetLeaves);
                hashTagsTmp.add(term);
            }
        }
        hashTags = hashTagsTmp;
    }

    /**
     * unlinkAll disconnects this NGPageIndex object from the terms so that it
     * can be discarded. This must be called when an index entry is removed from
     * the index.
     */
    private void unlinkAll() {
        for (NGTerm term : nameTerms) {
            term.removeTarget(this);
        }
        nameTerms.removeAllElements();

        for (NGTerm term : refTerms) {
            term.removeSource(this);
        }
        refTerms.removeAllElements();

        for (NGTerm term : hashTags) {
            term.removeTarget(this);
        }
        hashTags.removeAllElements();
    }

    /**
     * Get the first page that has email that still needs to be sent Returns
     * null if there are not any
     */
    public static NGPage getPageWithEmailToSend() throws Exception {
        if (projectsWithEmailToSend.size() == 0) {
            return null;
        }

        Vector<String> copyList = new Vector<String>();
        copyList.addAll(projectsWithEmailToSend);
        for (String key : copyList) {
            NGContainer ngc = getContainerByKey(key);
            if (ngc instanceof NGPage) {
                NGPage aPage = (NGPage) ngc;
                if (aPage.countEmailToSend() > 0) {
                    return aPage;
                }
            }
            // hmm, didn't have email after all, should be removed. This is how
            // the list gets cleaned up after the email is sent
            projectsWithEmailToSend.remove(key);
        }
        return null;
    }

    // /////////////// DEPRECATED ///////////////////////////

}
