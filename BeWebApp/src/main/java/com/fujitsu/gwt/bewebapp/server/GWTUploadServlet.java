/*
 * Copyright 2009 Manuel Carrasco Moñino. (manuel_carrasco at users.sourceforge.net)
 * http://code.google.com/p/gwtupload
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package com.fujitsu.gwt.bewebapp.server;

import gwtupload.server.UploadAction;
import gwtupload.server.exceptions.UploadActionException;

import org.apache.commons.fileupload.FileItem;

import org.socialbiz.cog.AttachmentRecord;
import org.socialbiz.cog.AttachmentVersion;
import org.socialbiz.cog.AttachmentVersionSimple;
import org.socialbiz.cog.AuthDummy;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.UserManager;
import org.socialbiz.cog.UserProfile;
import org.socialbiz.cog.exception.NGException;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.util.Hashtable;
import java.util.List;
import java.util.Random;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class GWTUploadServlet extends UploadAction {

    private static final long serialVersionUID = 1L;
    private static final Random rd = new Random(System.currentTimeMillis());

    Hashtable<String, String> receivedContentTypes = new Hashtable<String, String>();
    /**
     * Maintain a list with received files and their content types.
     */
    Hashtable<String, File> receivedFiles = new Hashtable<String, File>();

    /**
     * Override executeAction to save the received files in a custom place and
     * delete this items from session.
     */
    @Override
    public String executeAction(HttpServletRequest request,
            List<FileItem> sessionFiles) throws UploadActionException {

        String response = "";
        int cont = 0;

        String displayName = "";
        String originalName = "";
        String fileExtension = "bin";
        String comments = "";
        String pageId = "";
        String atype = "";
        String newversion = "";
        String existingaid = "";
        String visibility = "";
        File tempFile = null;
        for (FileItem item : sessionFiles) {

            if (false == item.isFormField()) {
                cont++;
                try {

                    String fName = item.getName();
                    fName = fName.replace('\\', '/');
                    int indx = fName.lastIndexOf("/");
                    if (indx > 0) {
                        originalName = fName.substring(indx + 1);
                    } else {
                        originalName = fName;
                    }

                    int dotPos = originalName.lastIndexOf(".");
                    if (dotPos > 0) {
                        fileExtension = originalName.substring(dotPos + 1);
                    }

                    String tmpFileName = "upload-" + rd.nextInt();
                    // Create a temporary file placed in the default system temp
                    // folder
                    tempFile = File.createTempFile(tmpFileName, ".bin");
                    item.write(tempFile);

                    // / Save a list with the received files
                    receivedFiles.put(item.getFieldName(), tempFile);
                    receivedContentTypes.put(item.getFieldName(), item
                            .getContentType());

                    // / Send a customized message to the client.
                    response += "Successfully attached the file "
                            + item.getName();

                } catch (Exception e) {
                    throw new UploadActionException(e.getMessage());
                }
            } else {
                if ("aname".equals(item.getFieldName())) {
                    displayName = item.getString();
                } else if ("desc".equals(item.getFieldName())) {
                    comments = item.getString();
                } else if ("pageid".equals(item.getFieldName())) {
                    pageId = item.getString();
                } else if ("atype".equals(item.getFieldName())) {
                    atype = item.getString();
                } else if ("newversion".equals(item.getFieldName())) {
                    newversion = item.getString();
                } else if ("existingaid".equals(item.getFieldName())) {
                    existingaid = item.getString();
                } else if ("visibility".equals(item.getFieldName())) {
                    visibility = item.getString();
                } else {
                    System.out.println("Unknows FiledName:"
                            + item.getFieldName() + "=" + item.getString());
                }
            }

            if (displayName.length() == 0) {
                displayName = originalName;
            } else if (!displayName.endsWith("." + fileExtension)) {
                displayName = displayName + "." + fileExtension;
            }
        }
        try {

            String userKey = (String) request.getSession().getAttribute(
                    "userKey");
            UserProfile user = null;
            if (userKey != null) {
                user = UserManager.getUserProfileByKey(userKey);

            } else {
                throw new NGException("nugen.exception.user.must.be.login",null);
            }
            AuthDummy ar = new AuthDummy(user, new StringWriter());
            ar.req = request;
            NGPage ngp = (NGPage) NGPageIndex.getContainerByKeyOrFail(pageId);
            AttachmentRecord attachment = null;

            if (existingaid != null) {
                if ((!existingaid.equals("0") && (existingaid.length() > 0))) {
                    attachment = ngp.findAttachmentByIDOrFail(existingaid);
                } else {
                    attachment = ngp.createAttachment();
                }
            } else {
                attachment = ngp.createAttachment();
            }

            attachment.setDisplayName(displayName);
            attachment.setComment(comments);
            attachment.setModifiedBy(ar.getBestUserId());
            attachment.setModifiedDate(ar.nowTime);
            attachment.setType("FILE");
            attachment.setVersion(1);
            if (atype.equals("Public")) {
                attachment.setVisibility(1);
            } else {
                attachment.setVisibility(2);
            }

            FileInputStream contentStream = new FileInputStream(tempFile);
            AttachmentVersion av = attachment.streamNewVersion(ar, ngp, contentStream);

            HistoryRecord.createHistoryRecord(ngp, attachment.getId(),
                    HistoryRecord.CONTEXT_TYPE_DOCUMENT, ar.nowTime,
                    HistoryRecord.EVENT_DOC_ADDED, ar, "");

            ngp.saveContent(ar, "Modified attachments");
        } catch (Exception e) {
            e.printStackTrace();
            throw new UploadActionException(e.getMessage());
        } finally {
            NGPageIndex.clearLocksHeldByThisThread();
        }

        // / Remove files from session because we have a copy of them
        removeSessionFileItems(request);

        // / Send your customized message to the client.
        return response;
    }

    /**
     * Get the content of an uploaded file.
     */
    @Override
    public void getUploadedFile(HttpServletRequest request,
            HttpServletResponse response) throws IOException {
        String fieldName = request.getParameter(PARAM_SHOW);
        File f = receivedFiles.get(fieldName);
        if (f != null) {
            response.setContentType(receivedContentTypes.get(fieldName));
            FileInputStream is = new FileInputStream(f);
            copyFromInputStreamToOutputStream(is, response.getOutputStream());
        } else {
            renderXmlResponse(request, response, ERROR_ITEM_NOT_FOUND);
        }
    }

    /**
     * Remove a file when the user sends a delete request.
     */
    @Override
    public void removeItem(HttpServletRequest request, String fieldName)
            throws UploadActionException {
        File file = receivedFiles.get(fieldName);
        receivedFiles.remove(fieldName);
        receivedContentTypes.remove(fieldName);
        if (file != null) {
            file.delete();
        }
    }
}
