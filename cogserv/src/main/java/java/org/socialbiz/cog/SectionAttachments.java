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

import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import java.io.File;
import java.io.FileInputStream;
import java.io.Writer;
import java.util.Collections;
import java.util.Comparator;
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

public class SectionAttachments extends SectionUtil implements SectionFormat
{

    public SectionAttachments()
    {
    }



    /**
    * READ CERFULLY:  This method is placed here to perform any schema migration
    * or any clean up tasks that need to be done on a document as it is read.
    * This method is called when the page is read into memory.
    * The migration will always update the document in memory, so that IF the
    * document is written out, it will always be written in the latest form.
    *
    * Each piece of schema migration code must be dated as of the date it was
    * introduced, so that when all documents have finally been updated,
    * that code can be removed as it is no longer needed.  Generally we will
    * leave such code in place for a period of two years.
    *
    * Care must be take so that new additions of the schema are not confused
    * with older versions of the schema.
    *
    */
    public static void assureSchemaMigration(NGSection sec, NGPage ngp) throws Exception
    {
        //assure that all attachments have an ID
        //added Dec 2009
        //Now, clean up the ids in case there are any missing ids, this will
        //migrate any existing documents without id values in the record
        //remove this code when the oldest document is younger than Dec 2009
        DOMFace allAttachments = sec.requireChild("attachments", DOMFace.class);
        Vector<AttachmentRecord> attVect = allAttachments.getChildren("attachment", AttachmentRecord.class);
        for(AttachmentRecord att : attVect)
        {
            String thisId = att.getId();
            if (thisId.length()==0)
            {
                thisId = ngp.getUniqueOnPage();
                att.setId(thisId);
            }
        }

        //added Nov 2010
        //clean up mistake where versions of attachments were being created at new
        //top level attachment records with the same ID.  This will remove any records
        //that exist that have the same ID as a previous record.  The assumption is that
        //the actual file in the directory, has the same ID, and will be detected by
        //the attachment version object.  So, nothing will be lost by eliminating the
        //duplicate attachment records.  After this, an ID will be an ID again.
        sortByVersion(attVect);
        Hashtable<String,String> idset = new Hashtable<String,String>();

        for(AttachmentRecord att : attVect)
        {
            String thisId = att.getId();
            if (idset.get(thisId)!=null)
            {
                allAttachments.getElement().removeChild(att.getElement());
            }
            idset.put(thisId, thisId);
        }

    }



    /**
    * get the name of the format
    */
    public String getName()
    {
        return "Attachments Format";
    }


    public static void moveAttachmentsFromDeprecatedSection(NGSection oldSec) throws Exception
    {
        if (oldSec==null)
        {
            throw new Exception("Null parameter passed to moveAttachmentsFromDeprecatedSection");
        }
        List<AttachmentRecord> wrongPlaceAtts = oldSec.getChildren("attachment", AttachmentRecord.class);
        for (AttachmentRecord oldRec: wrongPlaceAtts)
        {
            AttachmentRecord newRec = oldSec.parent.createAttachment();
            newRec.copyFrom(oldRec);
            newRec.setId(oldRec.getId());

            //now remove from the source.
            DOMFace allSourceAttachments = oldSec.getChild("attachments", DOMFace.class);
            allSourceAttachments.removeChild(oldRec);
        }
    }

    /**
    * pass ar=null if you do not want any history records created
    * recording that the document was removed.
    */
    public static void removeAttachments( AuthRequest ar, NGSection ngs, String[] fileIdsToBeRemoved)
        throws Exception
    {
        if (fileIdsToBeRemoved == null || fileIdsToBeRemoved.length == 0)
        {
            //nothing to do
            return;
        }

        // remove the files that were marked for delete.
        for (String fileid : fileIdsToBeRemoved)
        {
            AttachmentRecord att = ngs.parent.findAttachmentByID(fileid);
            if (att!=null)
            {
                ngs.parent.deleteAttachment(fileid,ar);
                att.createHistory(ar, ngs.parent, HistoryRecord.EVENT_DOC_REMOVED, "");
            }
        }
    }


    public void writePlainText(NGSection section, Writer out) throws Exception
    {
        assertRightAttachmentsSection(section);
        for (AttachmentRecord attachment : section.parent.getAllAttachments())
        {
            SectionUtil.writeTextWithLB(attachment.getId() , out);
            SectionUtil.writeTextWithLB(attachment.getNiceName() , out);
            SectionUtil.writeTextWithLB(attachment.getStorageFileName() , out);
            SectionUtil.writeTextWithLB(attachment.getType() , out);
            SectionUtil.writeTextWithLB(attachment.getModifiedBy() , out);
            SectionUtil.writeTextWithLB(Long.toString(attachment.getModifiedDate()) , out);
            SectionUtil.writeTextWithLB(attachment.getComment() , out);
        }
    }


    private void assertRightAttachmentsSection(NGSection sec) throws Exception
    {
        //there should only be on section of type attachments, and it should
        //be named "Attachments" so check this quickly to make sure that the
        //right section, and only the right section is being passed here.
        if (!"Attachments".equals(sec.getName())) {
            throw new Exception("Internal error, SectionAttachments was passed a section that is not named 'Attachments' but is named '"+sec.getName()+"' instead");
        }
    }



    /**
    * Walk through whatever elements this owns and put all the four digit
    * IDs into the vector so that we can generate another ID and assure it
    * does not duplication any id found here.
    */
    public void findIDs(Vector<String> v, NGSection sec)
        throws Exception
    {
        //legacy upgrade...there are some old attachments sections that are to be automatically
        //deleted or migrated during scema migration.  Unfortunately, there are some calls to
        //get unique ids during schema migration, and possibly before this section has had a
        //chance to be migrated.  So rather than bomb out, the search of IDs should search even
        //outdated or legacy sections. The idea begin findIds is that finding more IDs is better
        //than skipping IDs and possibly causing a clash.

        List<AttachmentRecord> attChildren = sec.getChildren("attachment", AttachmentRecord.class);
        for (AttachmentRecord att : attChildren) {
            v.add(att.getId());
        }
    }

    /**
    * Some sections have a number of smaller pieces, where each piece can appear
    * at different levels.  This flag returns true is this is the case, and false
    * it is a normal section that appears only at one level.
    */
    public boolean appearsAtMultipleLevels()
    {
        return true;
    }


    /**
    * This is a method to find a file, and output the file as a
    * stream of bytes to the request output stream.
    */
    public static void serveUpFile(AuthRequest ar, NGPage ngp, String fileName)
        throws Exception
    {
        serveUpFileNewUI(ar, ngp, fileName, -1);
    }


    /**
    * This is a method to find a file, and output the file as a
    * stream of bytes to the request output stream.
    */
    public static void serveUpFileNewUI(AuthRequest ar, NGContainer ngp, String fileName, int version)
        throws Exception
    {
        if (ngp==null) {
            throw new ProgramLogicError("SectionAttachments can serve upthe attachment only when the Project is known.");
        }

        try {
            ConfigFile.assertConfigureCorrect();
            AttachmentRecord att = null;
            //we find the attachment BY NAME in the requested url,
            //but the actual file is specified in getStorageFileName from that attachment record
            //first, look to see if there is a public attachments section
            //if so, these attachments can be accessed without logging in
            att = ngp.findAttachmentByName(fileName);
            if (att==null) {
                throw new NGException("nugen.exception.unattached.file.to.page",new Object[]{fileName,ngp.getFullName()});
            }

            if (!att.hasContents()) {
                throw new NGException("nugen.exception.unable.to.serve.attachment", new Object[]{att.getType()});
            }

            AttachmentVersion attachmentVersion = att.getSpecificVersion(ngp, version);
            if (attachmentVersion==null) {
                //not sure if this is the best course of action, to serve up the latest
                //maybe we should throw an exception, because after all they are not
                //getting the version requested.  Why are they asking for a version that
                //does not exist?
                attachmentVersion = att.getLatestVersion(ngp);
                if (attachmentVersion==null) {
                    throw new NGException("nugen.exception.unable.to.serve.attachment", new Object[]{att.getType()});
                }
            }

            File attachmentFile =  attachmentVersion.getLocalFile();
            if (!attachmentFile.exists()) {
                throw new NGException("nugen.exception.attachment.not.exist", new Object[]{attachmentFile.getAbsolutePath()});
            }

            //get the mime type from the file extension
            String mimeType=MimeTypes.getMimeType(attachmentFile.getName());
            ar.resp.setContentType(mimeType);
            //set expiration to about 1 year from now
            ar.resp.setDateHeader("Expires", ar.nowTime+3000000);

            // Temporary fix: To force the browser to show 'SaveAs' dialogbox with right format.
            // (Suppose attachment has many versions and latest version of attachment contains .xls file
            // and earlier version had .doc, now if we try to download earlier version than we have to pass
            // filename with correct extension in setHeader method. For this we have calculated the
            // downloadFileName using current display name without extn plus extension of actual file name.
            String downloadExtn = "";
            if(attachmentFile.getName().contains(".")){
                downloadExtn = (attachmentFile.getName()).substring(attachmentFile.getName().lastIndexOf("."));
            }

            int extinx = fileName.length();
            if(fileName.contains(".")){
                extinx = fileName.lastIndexOf(".");
            }
            String downloadFileName = fileName.substring(0,extinx)+downloadExtn;
            ar.resp.setHeader( "Content-Disposition", "attachment; filename=\"" + downloadFileName + "\"" );
            //end here

            FileInputStream fis = new FileInputStream(attachmentFile);
            ar.streamBytesOut(fis);
            fis.close();
        }
        catch (Exception e) {
            //why sleep?  Here, this is VERY IMPORTANT
            //Someone might be trying all the possible file names just to
            //see what is here.  A three second sleep makes that more difficult.
            Thread.sleep(3000);
            throw new Exception("Unable to serve up a file named '"+fileName+"' from project '"+ngp.getFullName()+"'", e);
        }
    }

    public static void sortByVersion(List<AttachmentRecord> listToSort)
    {
        Collections.sort(listToSort, new AttachmentRecordComparator());
    }
    public static void sortByName(List<AttachmentRecord> listToSort)
    {
        Collections.sort(listToSort, new AttachmentNameComparator());
    }
    public static void sortByDate(List<AttachmentRecord> listToSort)
    {
        Collections.sort(listToSort, new AttachmentDateComparator());
    }


    static class AttachmentRecordComparator implements Comparator<AttachmentRecord>{

        public int compare(AttachmentRecord paramT1, AttachmentRecord paramT2) {

            int version1 = paramT1.getVersion();
            int version2 = paramT2.getVersion();

            if( version1 < version2 ) {
                return 1;
            }
            else if( version1 > version2 ) {
                return -1;
            }
            else {
                return 0;
            }
        }
    }
    static class AttachmentNameComparator implements Comparator<AttachmentRecord>{

        public int compare(AttachmentRecord paramT1, AttachmentRecord paramT2) {

            String name1 = paramT1.getNiceName();
            String name2 = paramT2.getNiceName();

            int comp = name1.compareTo(name2);
            if (comp!=0)
            {
                return comp;
            }

            int version1 = paramT1.getVersion();
            int version2 = paramT2.getVersion();

            if( version1 < version2 ) {
                return 1;
            }
            else if( version1 > version2 ) {
                return -1;
            }
            else {
                return 0;
            }
        }
    }
    static class AttachmentDateComparator implements Comparator<AttachmentRecord>{

        public int compare(AttachmentRecord paramT1, AttachmentRecord paramT2) {

            long date1 = paramT1.getModifiedDate();
            long date2 = paramT2.getModifiedDate();

            //note, this is REVERSE chrono order
            if( date2 < date1 )
            {
                return 1;
            }
            else if( date2 > date1 )
            {
                return -1;
            }


            String name1 = paramT1.getNiceName();
            String name2 = paramT2.getNiceName();

            int comp = name1.compareTo(name2);
            if (comp!=0)
            {
                return comp;
            }

            int version1 = paramT1.getVersion();
            int version2 = paramT2.getVersion();

            if( version1 < version2 ) {
                return 1;
            }
            else if( version1 > version2 ) {
                return -1;
            }
            else {
                return 0;
            }
        }
    }

}
