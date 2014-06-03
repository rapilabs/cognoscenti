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
 */

package org.socialbiz.cog.api;

import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.socialbiz.cog.AttachmentRecord;
import org.socialbiz.cog.AttachmentVersion;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.GoalRecord;
import org.socialbiz.cog.License;
import org.socialbiz.cog.MimeTypes;
import org.socialbiz.cog.NGBook;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.NoteRecord;
import org.socialbiz.cog.SectionUtil;
import org.socialbiz.cog.SectionWiki;
import org.socialbiz.cog.ServerInitializer;
import org.socialbiz.cog.UtilityMethods;
import org.socialbiz.cog.WikiConverter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.URLEncoder;
import javax.servlet.ServletConfig;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * This servlet serves up pages using the following URL format:
 *
 * http://{machine:port}/{application}/api/{site}/{project}/{resource}
 *
 * http://{machine:port}/{application} is whatever you install the application to on
 * Tomcat could be multiple levels deep.
 *
 * "api" is fixed. This is the indicator within the system that says
 * this servlet will be invoked.
 *
 * {site} unique identifier for the site.
 *
 * {project} unique identifier for the project.
 *
 * All of the stuff above can be abbreviated {site-proj}
 * so the general pattern is:
 * {site-proj}/{resource}
 *
 * {resource} specifies the resource you are trying to access.
 * See below for the details.  NOTE: you only receive resources
 * that you have access to.  Resources you do not have access
 * to will not be included in the list, and will not be accessible
 * in any way.
 *
 * {site-proj}/summary.json
 * This will list all the goals, notes, and attachments to this project.
 * and include some info like modified date, owner, and file size.
 *
 * {site-proj}/doc{docid}/docname.ext
 * documents can be accessed directly with this, the docname and extension
 * is the name of the document and the proper extension, but can actually
 * be anything.  The only thing that matters is the docid.
 * A PUT to this address will create a new version of the document.
 *
 * {site-proj}/doc{docid}-{version}/docname.ext
 * Gets a version of the document directly if that version exists.
 * Again, the name is just so the browser works acceptably, the
 * document is found using docid and version alone.
 * You can not PUT to this, versions are immutable.
 *
 * {site-proj}/note{noteid}/note1.html
 * This will retrieve the contents of a note in HTML format
 * A PUT to this address will update the note
 *
 * {site-proj}/note{noteid}/note1.sp
 * This will retrieve the contents of a note in SmartPage Wiki format
 * A PUT to this address will update the note
 *
 * {site-proj}/goal{goalid}/goal.json
 * Will retrieve a goal in JSON format
 * A POST to this address will update the goal in JSON format
 */
@SuppressWarnings("serial")
public class APIServlet extends javax.servlet.http.HttpServlet {

    public void doGet(HttpServletRequest req, HttpServletResponse resp) {
        AuthRequest ar = AuthRequest.getOrCreate(req, resp);
        try {
            System.out.println("API_GET: "+ar.getCompleteURL());
            if (!ServerInitializer.isRunning()) {
                throw new Exception("Server is not ready to handle requests.");
            }

            doAuthenticatedGet(ar);
        }
        catch (Exception e) {
            streamException(e, ar);
        }
        finally {
            NGPageIndex.clearLocksHeldByThisThread();
        }
        ar.logCompletedRequest();
    }

    private void doAuthenticatedGet(AuthRequest ar)  throws Exception {

        try {
            ResourceDecoder resDec = new ResourceDecoder(ar);

            if (resDec.isSite){
                genSiteListing(ar, resDec);
            }
            else if (resDec.isListing){
                genProjectListing(ar, resDec);
            }
            else if (resDec.isDoc) {
                streamDocument(ar, resDec);
            }
            else if (resDec.isGoal) {
                genGoalInfo(ar, resDec);
            }
            else if (resDec.isNote) {
                streamNote(ar, resDec);
            }
            else {
                throw new Exception("don't understand that resource URL: "+ar.getCompleteURL());
            }
            ar.flush();

        } catch (Exception e) {
            streamException(e, ar);
        }
    }

    public void doPut(HttpServletRequest req, HttpServletResponse resp) {
        AuthRequest ar = AuthRequest.getOrCreate(req, resp);
        ar.resp.setContentType("application/json");
        try {
            System.out.println("API_PUT: "+ar.getCompleteURL());
            ResourceDecoder resDec = new ResourceDecoder(ar);

            if (resDec.isTempDoc) {
                receiveTemp(ar, resDec);
                System.out.println("    PUT: file written: "+resDec.tempName);
                JSONObject result = new JSONObject();
                result.put("responseCode", 200);
                result.write(ar.resp.getWriter(), 2, 0);
            }
            else {
                throw new Exception("Can not do a PUT to that resource URL: "+ar.getCompleteURL());
            }
            ar.flush();
        }
        catch (Exception e) {
            streamException(e, ar);
        }
    }

    public void doPost(HttpServletRequest req, HttpServletResponse resp) {
        AuthRequest ar = AuthRequest.getOrCreate(req, resp);
        ar.resp.setContentType("application/json");
        try {
            System.out.println("API_POST: "+ar.getCompleteURL());
            ResourceDecoder resDec = new ResourceDecoder(ar);

            InputStream is = ar.req.getInputStream();
            JSONTokener jt = new JSONTokener(is);
            JSONObject objIn = new JSONObject(jt);
            is.close();

            String op = objIn.getString("operation");
            System.out.println("API_POST: operation="+op);
            if (op==null || op.length()==0) {
                throw new Exception("Request object needs to have a specified 'operation'."
                        +" None found.");
            }

            JSONObject responseObj = null;
            if (resDec.isSite) {
                responseObj = getSitePostResponse(ar, resDec, op, objIn);
            }
            else {
                responseObj = getProjectPostResponse(ar, resDec, op, objIn);
            }
            responseObj.write(ar.resp.getWriter(), 2, 0);
            ar.flush();
        }
        catch (Exception e) {
            streamException(e, ar);
        }
    }

    private JSONObject getSitePostResponse(AuthRequest ar, ResourceDecoder resDec,
            String op, JSONObject objIn) throws Exception {
        JSONObject responseOK = new JSONObject();
        responseOK.put("responseCode", 200);

        if ("ping".equals(op)) {
            objIn.put("responseCode", 200);
            return objIn;
        }

        if (resDec.site==null) {
            throw new Exception("Unable to fine a site with the id: "+resDec.siteId);
        }
        if (!resDec.site.isSiteFolderStructure()) {
            throw new Exception("This operation requires a site that is structured with site-folder structure");
        }
        if (!resDec.site.isValidLicense(resDec.lic, ar.nowTime)) {
            throw new Exception("The license ("+resDec.licenseId+") has expired.  "
                    +"To exchange information, you will need to get an updated license");
        }
        if (resDec.lic.isReadOnly()) {
            throw new Exception("The license ("+resDec.licenseId+") is a read-only license and "
                    +"can not be used to update information on this server.");
        }

        responseOK.put("license", getLicenseInfo(resDec.lic));
        if ("createProject".equals(op)) {
            if (!"$".equals(resDec.projId)) {
                throw new Exception("create project can only be called on a site URL, not project: "+resDec.projId);
            }
            NGBook site = resDec.site;
            String projectName = objIn.getString("projectName");
            String projectKey = SectionWiki.sanitize(projectName);
            projectKey = site.findUniqueKeyInSite(projectKey);
            NGPage ngp = site.createProjectByKey(ar, projectKey);

            License lr = ngp.createLicense(ar.getBestUserId(), "Admin",
                    ar.nowTime + 1000*60*60*24*365, false);
            ngp.saveFile(ar, "project created through API by "+ar.getBestUserId());

            String newLink = ar.baseURL + "api/" + resDec.siteId + "/" + ngp.getKey()
                    + "/summary.json?lic=" + lr.getId();

            responseOK.put("key", ngp.getKey());
            responseOK.put("site", site.getKey());
            responseOK.put("name", ngp.getFullName());
            responseOK.put("link", newLink);
            return responseOK;
        }

        throw new Exception("API does not understand operation: "+op);
    }


    private JSONObject getProjectPostResponse(AuthRequest ar, ResourceDecoder resDec,
            String op, JSONObject objIn) throws Exception {
        JSONObject responseOK = new JSONObject();
        responseOK.put("responseCode", 200);
        String urlRoot = ar.baseURL + "api/" + resDec.siteId + "/" + resDec.projId + "/";

        if ("ping".equals(op)) {
            objIn.put("responseCode", 200);
            return objIn;
        }


        NGPage ngp = resDec.project;
        if (ngp == null) {
            throw new Exception("Unable to find a project with the id "+resDec.projId);
        }
        if (resDec.lic == null) {
            throw new Exception("Unable to find a license with the id "+resDec.licenseId);
        }
        if (!ngp.isValidLicense(resDec.lic, ar.nowTime)) {
            throw new Exception("The license ("+resDec.licenseId+") has expired.  "
                    +"To exchange information, you will need to get an updated license");
        }
        if (resDec.lic.isReadOnly()) {
            throw new Exception("The license ("+resDec.licenseId+") is a read-only license and "
                    +"can not be used to update information on this server.");
        }
        if (!resDec.site.isSiteFolderStructure()) {
            throw new Exception("This operation requires a site that is structured with site-folder structure");
        }

        responseOK.put("license", getLicenseInfo(resDec.lic));

        if ("tempFile".equals(op)) {
            String fileName = "~tmp~"+SectionUtil.getNewKey()+"~tmp~";
            responseOK.put("tempFileName", fileName);
            responseOK.put("tempFileURL", urlRoot + "temp/" + fileName);
            return responseOK;
        }
        if ("newGoal".equals(op)) {
            JSONObject newGoalObj = objIn.getJSONObject("goal");
            GoalRecord newGoal = resDec.project.createGoal();
            newGoal.setUniversalId(newGoalObj.getString("universalid"));
            newGoal.updateGoalFromJSON(newGoalObj);
            resDec.project.save(ar.getBestUserId(), ar.nowTime, "New goal synchronized from downstream linked project.");
            return responseOK;
        }
        if ("updateGoal".equals(op)) {
            JSONObject newGoalObj = objIn.getJSONObject("goal");
            GoalRecord goal = resDec.project.findGoalByUIDorNull(
                    newGoalObj.getString("universalid"));
            if (goal==null) {
                throw new Exception("Unable to find an existing goal with UID ("
                        +newGoalObj.getString("universalid")+")");
            }
            goal.updateGoalFromJSON(newGoalObj);
            resDec.project.save(ar.getBestUserId(), ar.nowTime, "Goal synchronized from downstream linked project.");
            return responseOK;
        }
        if ("newNote".equals(op)) {
            JSONObject newNoteObj = objIn.getJSONObject("note");
            NoteRecord newNote = resDec.project.createNote();
            newNote.setUniversalId(newNoteObj.getString("universalid"));
            newNote.updateNoteFromJSON(newNoteObj);
            resDec.project.save(ar.getBestUserId(), ar.nowTime, "New note synchronized from downstream linked project.");
            return responseOK;
        }
        if ("updateNote".equals(op)) {
            JSONObject newNoteObj = objIn.getJSONObject("note");
            NoteRecord note = resDec.project.getNoteByUidOrNull(
                    newNoteObj.getString("universalid"));
            if (note==null) {
                throw new Exception("Unable to find an existing note with UID ("
                        +newNoteObj.getString("universalid")+")");
            }
            note.updateNoteFromJSON(newNoteObj);
            resDec.project.save(ar.getBestUserId(), ar.nowTime, "Note synchronized from downstream linked project.");
            return responseOK;
        }
        if ("updateDoc".equals(op) || "newDoc".equals(op)) {
            JSONObject newDocObj = objIn.getJSONObject("doc");
            String tempFileName = objIn.getString("tempFileName");

            File folder = resDec.project.getContainingFolder();
            File tempFile = new File(folder, tempFileName);
            if (!tempFile.exists()) {
                throw new Exception("Attemped operation failed because the temporary file "
                        +"does not exist: "+tempFile);
            }
            AttachmentRecord att;
            if ("updateDoc".equals(op)) {
                att = resDec.project.findAttachmentByUidOrNull(newDocObj.getString("universalid"));
            }
            else {
                att = resDec.project.createAttachment();
                att.setUniversalId(newDocObj.getString("universalid"));
            }
            att.updateDocFromJSON(newDocObj);
            String userUpdate = newDocObj.getString("modifieduser");
            long timeUpdate = newDocObj.getLong("modifiedtime");

            FileInputStream fis = new FileInputStream(tempFile);
            att.streamNewVersion(resDec.project, fis, userUpdate, timeUpdate);
            fis.close();
            tempFile.delete();

            //send all the info back for a reasonable response
            responseOK.put("doc",  att.getJSON4Doc(resDec.project, urlRoot));
            resDec.project.save(ar.getBestUserId(), ar.nowTime, "Document synchronized from downstream linked project.");
            return responseOK;
        }

        throw new Exception("API does not understand operation: "+op);
    }

    public void doDelete(HttpServletRequest req, HttpServletResponse resp) {
        AuthRequest ar = AuthRequest.getOrCreate(req, resp);
        streamException(new Exception("not implemented yet"), ar);
    }

    public void init(ServletConfig config) throws ServletException {
        //don't initialize here.  Instead, initialize in SpringServlet!
    }

    private void streamException(Exception e, AuthRequest ar) {
        try {
            //all exceptions are delayed by 3 seconds to avoid attempts to
            //mine for valid license numbers
            Thread.sleep(3000);

            System.out.println("API_ERROR: "+ar.getCompleteURL());

            ar.logException("API Servlet", e);

            JSONObject errorResponse = new JSONObject();
            errorResponse.put("responseCode", 500);
            JSONObject exception = new JSONObject();
            errorResponse.put("exception", exception);

            JSONArray msgs = new JSONArray();
            Throwable runner = e;
            while (runner!=null) {
                System.out.println("    ERROR: "+runner.toString());
                msgs.put(runner.toString());
                runner = runner.getCause();
            }
            exception.put("msgs", msgs);

            StringWriter sw = new StringWriter();
            e.printStackTrace(new PrintWriter(sw));
            exception.put("stack", sw.toString());

            ar.resp.setContentType("application/json");
            errorResponse.write(ar.resp.writer, 2, 0);
            ar.flush();
        } catch (Exception eeeee) {
            // nothing we can do here...
            ar.logException("API Servlet Error Within Error", eeeee);
        }
    }



    @SuppressWarnings("unused")
    private void genSiteListing(AuthRequest ar, ResourceDecoder resDec) throws Exception {

        NGBook site = resDec.site;
        if (site==null) {
            //this is probably unnecessary, having hit an exception earlier, but just begin sure
            throw new Exception("Something is wrong, can not find a site object.");
        }
        if (false==true) {
            if (resDec.licenseId == null || resDec.licenseId.length()==0 || resDec.lic==null) {
                throw new Exception("All operations on the site need to be licensed, but did not get a license id in that URL.");
            }
            if (!site.isValidLicense(resDec.lic, ar.nowTime)) {
                throw new Exception("The license ("+resDec.licenseId+") has expired.  "
                        +"To exchange information, you will need to get an updated license");
            }
        }
        JSONObject root = new JSONObject();

        String urlRoot = ar.baseURL + "api/" + resDec.siteId + "/$/";
        root.put("siteinfo", urlRoot);
//        root.put("hostinfo", ar.baseURL + "api/$/$/");
        root.put("name", resDec.site.getName());
        root.put("id", resDec.site.getKey());
        root.put("deleted", resDec.site.isDeleted());
        root.put("frozen", resDec.site.isFrozen());
        root.put("license", getLicenseInfo(resDec.lic));

        ar.resp.setContentType("application/json");
        root.write(ar.resp.getWriter(), 2, 0);
        ar.flush();
    }

    private void genProjectListing(AuthRequest ar, ResourceDecoder resDec) throws Exception {
        JSONObject root = new JSONObject();

        NGPage ngp = resDec.project;
        if (ngp==null) {
            //this is probably unnecessary, having hit an exception earlier, but just begin sure
            throw new Exception("Something is wrong, can not find a site object.");
        }
        if (resDec.licenseId == null || resDec.licenseId.length()==0 || resDec.lic==null) {
            throw new Exception("All operations on the site need to be licensed, but did not get a license id in that URL.");
        }
        if (!ngp.isValidLicense(resDec.lic, ar.nowTime)) {
            throw new Exception("The license ("+resDec.licenseId+") has expired.  "
                    +"To exchange information, you will need to get an updated license");
        }
        root.put("license", getLicenseInfo(resDec.lic));
        NGBook site = ngp.getSite();
        String urlRoot = ar.baseURL + "api/" + resDec.siteId + "/" + resDec.projId + "/";
        String siteRoot = ar.baseURL + "api/" + resDec.siteId + "/$/";
        root.put("projectname", ngp.getFullName());
        root.put("projectinfo", urlRoot+"?lic="+resDec.licenseId);
        root.put("sitename", site.getName());
        root.put("siteinfo", siteRoot);
        String uiUrl = ar.baseURL + "t/" + ngp.getSiteKey() + "/" + ngp.getKey() + "/";
        root.put("ui", uiUrl);

        String role = resDec.lic.getRole();

        //Primary (and secondary) roles should have access to everything.
        //don't need to check by role name in that case
        boolean isPrimeRole =  (role.equals(ngp.getPrimaryRole().getName())
                    || role.equals(ngp.getSecondaryRole().getName()));
        JSONArray goals = new JSONArray();
        if (isPrimeRole) {
            for (GoalRecord goal : resDec.project.getAllGoals()) {
                goals.put(goal.getJSON4Goal(resDec.project, ar.baseURL, resDec.licenseId));
            }
        }
        root.put("goals", goals);

        JSONArray docs = new JSONArray();
        for (AttachmentRecord att : resDec.project.getAllAttachments()) {
            if (att.isDeleted()) {
                continue;
            }
            if (att.isUnknown()) {
                continue;
            }
            if (!"FILE".equals(att.getType())) {
                continue;
            }
            if (!isPrimeRole && !att.roleCanAccess(role) && !att.isPublic()) {
                continue;
            }
            JSONObject thisDoc = new JSONObject();
            String contentUrl = urlRoot + "doc" + att.getId() + "/"
                    + URLEncoder.encode(att.getNiceName(), "UTF-8");
            thisDoc.put("universalid", att.getUniversalId());
            thisDoc.put("id", att.getId());
            thisDoc.put("name", att.getNiceName());
            thisDoc.put("size", att.getFileSize(resDec.project));
            thisDoc.put("modifiedtime", att.getModifiedDate());
            thisDoc.put("modifieduser", att.getModifiedBy());
            thisDoc.put("content", contentUrl);
            docs.put(thisDoc);
        }
        root.put("docs", docs);

        JSONArray notes = new JSONArray();
        for (NoteRecord note : resDec.project.getAllNotes()) {
            if (isPrimeRole || note.isPublic() || note.roleCanAccess(role)) {
                notes.put(note.getJSON4Note(urlRoot, false));
            }
        }
        root.put("notes", notes);

        ar.resp.setContentType("application/json");
        root.write(ar.resp.getWriter(), 2, 0);
        ar.flush();
    }

    private void streamDocument(AuthRequest ar, ResourceDecoder resDec) throws Exception {
        AttachmentRecord att = resDec.project.findAttachmentByIDOrFail(resDec.docId);
        ar.resp.setContentType(MimeTypes.getMimeType(att.getNiceName()));
        AttachmentVersion aVer = att.getLatestVersion(resDec.project);
        File realPath = aVer.getLocalFile();
        UtilityMethods.streamFileContents(realPath, ar.resp.out);
    }

    private void genGoalInfo(AuthRequest ar, ResourceDecoder resDec) throws Exception {
        GoalRecord goal = resDec.project.getGoalOrFail(resDec.goalId);
        JSONObject goalObj = goal.getJSON4Goal(resDec.project, ar.baseURL, resDec.licenseId);
        ar.resp.setContentType("application/json");
        goalObj.write(ar.resp.getWriter(), 2, 0);
        ar.flush();
    }

    private void streamNote(AuthRequest ar, ResourceDecoder resDec) throws Exception {
        NoteRecord note = resDec.project.getNoteOrFail(resDec.noteId);
        String contents = note.getData();
        if (contents.length()==0) {
            contents = "-no contents-";
        }
        if (resDec.isHtmlFormat) {
            ar.resp.setContentType("text/html;charset=UTF-8");
            WikiConverter.writeWikiAsHtml(ar, contents);
        }
        else {
            ar.resp.setContentType("text");
            ar.write(contents);
        }
        ar.flush();
    }

    private void receiveTemp(AuthRequest ar, ResourceDecoder resDec) throws Exception {
        File folder = resDec.project.getContainingFolder();
        File tempFile = new File(folder, resDec.tempName);
        InputStream is = ar.req.getInputStream();
        FileOutputStream fos = new FileOutputStream(tempFile);
        UtilityMethods.streamToStream(is,fos);
        fos.flush();
        fos.close();
    }

    private JSONObject getLicenseInfo(License lic) throws Exception {
        JSONObject licenseInfo = new JSONObject();
        if (lic == null) {
            throw new Exception("Program Logic Error: null license passed to getLicenseInfo");
        }
        licenseInfo.put("id", lic.getId());
        licenseInfo.put("timeout", lic.getTimeout());
        licenseInfo.put("creator", lic.getCreator());
        licenseInfo.put("role", lic.getRole());
        return licenseInfo;
    }
}
