package com.fujitsu.gwt.bewebapp.server;

import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Vector;

import org.socialbiz.cog.exception.NGException;
import com.fujitsu.gwt.bewebapp.client.AttachmentData;
import com.fujitsu.gwt.bewebapp.client.LeafData;
import com.fujitsu.gwt.bewebapp.client.LeafService;
import com.fujitsu.gwt.bewebapp.client.TaskData;
import org.socialbiz.cog.AttachmentRecord;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.HtmlToWikiConverter;
import org.socialbiz.cog.NoteRecord;
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGRole;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGPageIndex;
import org.socialbiz.cog.SectionDef;
import org.socialbiz.cog.SectionUtil;
import org.socialbiz.cog.GoalRecord;
import org.socialbiz.cog.WikiConverterForWYSIWYG;
import com.google.gwt.user.server.rpc.RemoteServiceServlet;

public class LeafServiceImpl extends RemoteServiceServlet implements LeafService{

    private String space = " ";
    private int headerSize = 90;

    public static Hashtable ntfxList = new Hashtable();
    public LeafData[] getNotes(String pageId)throws IllegalArgumentException{
        return getServerNotes(pageId);
    }

    public LeafData[] getServerNotes(String pageId)throws IllegalArgumentException{
        AuthRequest ar = null;
        try{
            Vector comments = new Vector();

            ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngc);


            boolean isMember = false;
            String userId = null;
            long cTime  = System.currentTimeMillis();

            isMember = ngc.primaryOrSecondaryPermission(ar.getUserProfile());

            if(ar.getUserProfile() != null){
                userId = ar.getUserProfile().getUniversalId();
            }

            //Create a dummy LeafData for create operation
            LeafData cldata = new LeafData();
            cldata.setIsMember(isMember);
            cldata.setUserId(userId);
            cldata.setId("-1");
            cldata.setPageId(pageId);
            comments.add(cldata);

            List<NoteRecord> notes = ngc.getVisibleNotes(ar, SectionDef.PUBLIC_ACCESS);
            boolean details = true;
            for (NoteRecord note : notes){
                LeafData ldata = getLeafData(note, isMember, userId, ngc, cTime, details);
                details = false;
                comments.add(ldata);
            }

            if(ar.isLoggedIn()){
                notes = ngc.getVisibleNotes(ar, SectionDef.MEMBER_ACCESS);
                details = true;
                for (NoteRecord note : notes){
                    LeafData ldata = getLeafData(note, isMember, userId, ngc, cTime, details);
                    details = false;
                    comments.add(ldata);
                }
                notes = ngc.getVisibleNotes(ar, SectionDef.PRIVATE_ACCESS);
                details = true;
                for (NoteRecord note : notes){
                    LeafData ldata = getLeafData(note, isMember, userId, ngc, cTime, details);
                    details = false;
                    comments.add(ldata);
                }

                notes = ngc.getVisibleNotes(ar, SectionDef.ADMIN_ACCESS);
                details = true;
                for (NoteRecord note : notes){
                    LeafData ldata = getLeafData(note, isMember, userId, ngc, cTime, details);
                    details = false;
                    comments.add(ldata);
                }
            }

            LeafData[] leafs = new LeafData[comments.size()];
            comments.copyInto(leafs);
            return leafs;

        }catch(Exception e){
            if(ar != null){
                ar.logException("Failed to get Notes for Container Id: " + pageId, e);
            }
            throw new IllegalArgumentException("Failed to get Notes for Container Id: " + pageId, e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }

    }
    public LeafData saveNote(String pageId, LeafData leafData) throws IllegalArgumentException{
        AuthRequest ar = null;
        try{
            ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngc);
            boolean isMember = false;
            String userId = null;
            long cTime  = System.currentTimeMillis();

            isMember = ngc.primaryOrSecondaryPermission(ar.getUserProfile());

            if(ar.getUserProfile() != null){
                userId = ar.getUserProfile().getUniversalId();
            }

            boolean maccess = ar.isMember();
            if(!maccess){
                throw new NGException("nugen.exception.member.access.required",null);
            }

            HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
            String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL,leafData.getData());

            NoteRecord cr = ngc.getNote(leafData.getId());
            cr.setData(wikiText);
            cr.setSubject(leafData.getSubject());
            cr.setVisibility(leafData.getVisibility());
            cr.setUpstream(leafData.isUpstream());
            cr.setLastEdited(ar.nowTime);
            cr.setLastEditedBy(ar.getBestUserId());
            if(leafData.getEffectiveDate()> ar.nowTime){
                cr.setEffectiveDate(leafData.getEffectiveDate());
            }else{
                cr.setEffectiveDate(ar.nowTime);
            }
            if(leafData.getChoice() != null){
                cr.setChoices(leafData.getChoice());
            }
            int pinPos = 0;
            try{
                Integer.parseInt(leafData.getPinPosition().trim());
            }catch(Exception e){
                pinPos = 0;
            }
            cr.setPinOrder(pinPos);
            if(leafData.isDraft()){
                cr.setSaveAsDraft("yes");
            }else{
                cr.setSaveAsDraft("no");
            }

            Vector<NGRole> checkedRoles = new Vector<NGRole>();
            for (String roleName : leafData.checkedRoles) {
                NGRole role = ngc.getRole(roleName);
                if (role!=null) {
                    //roles can be removed from a project, so ignore any unexpected names
                    checkedRoles.add(role);
                }
            }
            cr.setAccessRoles(checkedRoles);

            ngc.saveContent(ar, "updating  note id:" + cr.getId());
            HistoryRecord.createHistoryRecord(ngc, cr.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_MODIFIED,
                    ar, "");
            LeafData ldata = getLeafData(cr, isMember, userId, ngc, cTime, true);
            return ldata;

        }catch(Exception e){
            IllegalArgumentException iae = new IllegalArgumentException("Failed to save note: " + leafData.getId(), e);
            if(ar != null){
                ar.logException("LeafServiceImpl caught exception: ", iae);
            }
            throw iae;
        }
        finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }
    }
    public LeafData createNote(String pageId, LeafData leafData) throws IllegalArgumentException{
        AuthRequest ar = null;
        try {
            ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngc);
            boolean isMember = false;
            String userId = null;
            long cTime  = System.currentTimeMillis();
            isMember = ngc.primaryOrSecondaryPermission(ar.getUserProfile());

            if(ar.getUserProfile() != null){
                userId = ar.getUserProfile().getUniversalId();
            }

            boolean maccess = ar.isMember();
            if(!maccess){
                throw new NGException("nugen.exception.member.access.required",null);
            }

            HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
            String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL,leafData.getData());
            NoteRecord cr = ngc.createNote();
            cr.setData(wikiText);
            cr.setSubject(leafData.getSubject());
            cr.setVisibility(leafData.getVisibility());
            if(leafData.getEffectiveDate()> ar.nowTime){
                cr.setEffectiveDate(leafData.getEffectiveDate());
            }else{
                cr.setEffectiveDate(ar.nowTime);
            }
            if(leafData.getChoice() != null){
                cr.setChoices(leafData.getChoice());
            }
            if(leafData.isDraft()){
                cr.setSaveAsDraft("yes");
            }else{
                cr.setSaveAsDraft("no");
            }
            int pinPos = 0;
            try{
                Integer.parseInt(leafData.getPinPosition().trim());
            }catch(Exception e){
                pinPos = 0;
            }
            cr.setPinOrder(pinPos);
            cr.setLastEdited(ar.nowTime);
            cr.setLastEditedBy(ar.getBestUserId());
            ngc.saveContent(ar, "creating note id:" + cr.getId());
            HistoryRecord.createHistoryRecord(ngc, cr.getId(),
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_CREATED,
                    ar, "");

            LeafData ldata = getLeafData(cr, isMember, userId, ngc, cTime, true);
            return ldata;

        }catch(Exception e){
            if(ar != null){
                ar.logException("Failed to create Note", e);
            }
            throw new IllegalArgumentException("Failed to create Note", e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }

    }


    public String removeNote(String pageId, String leadId) throws IllegalArgumentException{
        AuthRequest ar = null;
        try{
            ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngc);
            ngc.deleteNote(leadId,ar);
            HistoryRecord.createHistoryRecord(ngc, leadId,
                    HistoryRecord.CONTEXT_TYPE_LEAFLET,0, HistoryRecord.EVENT_TYPE_DELETED,
                    ar, "");
            ngc.saveContent(ar, "deleted note id:" + leadId);
            return "true";
        }catch(Exception e){
            if(ar != null){
                ar.logException("Failed to delete Note:" + leadId, e);
            }
            throw new IllegalArgumentException("Failed to delete Note:" + leadId, e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }
    }


    public LeafData getNote(String id, String pageId)throws IllegalArgumentException {
        AuthRequest ar = null;
        try {
            ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            NGContainer ngc = NGPageIndex.getContainerByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngc);
            boolean isMember = false;
            String userId = null;
            long cTime  = System.currentTimeMillis();

            isMember = ngc.primaryOrSecondaryPermission(ar.getUserProfile());

            if(ar.getUserProfile() != null){
                userId = ar.getUserProfile().getUniversalId();
            }

            NoteRecord lr = ngc.getNote(id);
            LeafData ldata = getLeafData(lr, isMember, userId, ngc, cTime, true);
            return ldata;

        }catch(Exception e){
            if(ar != null){
                ar.logException("Invalid Vontainer or Note Id, Container Id:" + pageId
                    + " Note Id:" + id, e);
            }
            throw new IllegalArgumentException("Invalid Vontainer or Note Id, Container Id:" + pageId
                + " Note Id:" + id, e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }
    }

    private LeafData getLeafData(
            NoteRecord lr,
            boolean isMember,
            String userId,
            NGContainer ngc,
            long cTime,
            boolean detail)throws Exception{

        LeafData ldata = new LeafData();
        ldata.setIsMember(isMember);
        ldata.setUserId(userId);
        ldata.setId(lr.getId());
        ldata.setPageId(ngc.getKey());
        ldata.setVisibility(lr.getVisibility());
        ldata.setUpstream(lr.isUpstream());
        ldata.setSubject(lr.getSubject());

        String headerText = lr.getSubject();
        if(headerText == null || headerText.length() == 0){
            headerText = "No Subject";
        }else if(headerText.length() > headerSize){
            headerText = headerText.substring(0, headerSize-2) + "..";
        }

        int rspace = headerSize - headerText.length();
        if(rspace > 0){
            for(int i=1; i<rspace; i++){
                headerText = headerText + space;
            }
        }
        String owner = lr.getOwner();
        String lastModifiedBy = lr.getLastEditedBy();
        if(lastModifiedBy==null || lastModifiedBy.trim().equals("")){
             lastModifiedBy=owner;
         }

        headerText = headerText + "    -Last edited by " + lastModifiedBy;
        String lastEdited = "";
        try{
            lastEdited = SectionUtil.getNicePrintTime(lr.getLastEdited(), cTime);
        }catch(Exception e){
            lastEdited = "unknown";
        }
        headerText = headerText + " " + lastEdited;
        ldata.setHeaderText(headerText);

        if(detail){
            AuthRequest tar = AuthRequest.getOrCreate(
                    this.getThreadLocalRequest(), this.getThreadLocalResponse(), new StringWriter());
            WikiConverterForWYSIWYG.writeWikiAsHtml(tar, lr.getData());
            String  htmlData = tar.w.toString();
            ldata.setData(htmlData);
        }

        ldata.setEditedBy(lr.getEditable());
        ldata.setChoice(lr.getChoices());
        ldata.setEffectiveDate(lr.getEffectiveDate());
        ldata.setPinPosition(String.valueOf(lr.getPinOrder()));

        ldata.setIsDraft(lr.isDraftNote());

        NGRole primaryRole = ngc.getPrimaryRole();
        String primaryRoleName = primaryRole.getName();
        NGRole secondaryRole = ngc.getSecondaryRole();
        String secondaryRoleName = secondaryRole.getName();

        List<NGRole> allRoles = ngc.getAllRoles();
        List<NGRole> checkedRoles = lr.getAccessRoles(ngc);
        ldata.allRoles = new String[allRoles.size()-2];
        ldata.checkedRoles = new String[checkedRoles.size()];
        int i=0;
        for (NGRole role : allRoles) {
            String roleName = role.getName();
            if (roleName.equals(primaryRoleName)) {
                continue;
            }
            if (roleName.equals(secondaryRoleName)) {
                continue;
            }
            ldata.allRoles[i] = roleName;
            i++;
        }
        i=0;
        for (NGRole role : checkedRoles) {
            ldata.checkedRoles[i] = role.getName();
            i++;
        }

        return ldata;
    }

    private LeafData[] getDummyData(){
        Vector comments = new Vector();
        LeafData tmp = new LeafData();
        tmp.setIsMember(true);
        tmp.setUserId("hello");
        tmp.setId("dummy");
        tmp.setPageId("hello");
        comments.add(tmp);

        for(int i=0; i<4; i++){
            LeafData tmp1 = new LeafData();
            tmp1.setIsMember(true);
            tmp1.setUserId("hello");
            tmp1.setId("id"+i);
            tmp1.setPageId("hello");
            tmp1.setVisibility(2);
            tmp1.setData("This is test data for testing" );

            String headerText = "Subject No " + i;
            int rspace = headerSize - headerText.length();
            if(rspace > 0){
                for(int j=0; j<rspace; j++){
                    headerText = headerText + space;
                }
            }

            headerText = headerText + "    -Last edited by " + "Dummy 2 days ago";
            tmp1.setHeaderText(headerText);
            comments.add(tmp1);

        }

        LeafData[] notes = new LeafData[comments.size()];
        comments.copyInto(notes);
        return notes;
    }

    public String isPageUpdated(String pageId) throws IllegalArgumentException {
        int indx = pageId.indexOf('/');
        String evt = pageId.substring(0, indx);
        String msg =  "";
        String tidtext =  new Date().toString() + " tid:" + Thread.currentThread().getId() ;
        try{
            String id = this.getThreadLocalRequest().getSession().getId()
                + pageId.substring(indx+1);
            System.out.println(tidtext + " Start Listening(" + id + ") for pageId '" + pageId + "'");
            String result = NGPageIndex.getEvtMsg(id, evt);
            if(result == null)
                result = "reconnect";
            System.out.println(tidtext + " End Listening(" + id + ") for pageId '" + pageId
                    + "' result '" + result + "'");
            return result;
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException(e);
        }

    }

    public AttachmentData[]getAttachments(String pageId)throws IllegalArgumentException{
        try {
            AuthRequest ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            ar.assertLoggedIn("Can not Retrieve Attachment List.");
            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);
            List<AttachmentRecord> arecords = ngp.getAllAttachments();
            ArrayList<AttachmentData> aDataList = new ArrayList<AttachmentData>();
            for (AttachmentRecord arecord : arecords){
                if(!arecord.isDeleted())
                {
                    AttachmentData aData = new AttachmentData(arecord.getId(),arecord.getDisplayName(),arecord.getComment());
                    aData.setVisibility(arecord.getVisibility());
                    aData.setReadOnly(arecord.getReadOnlyType());
                    aDataList.add(aData);
                }

            }

            AttachmentData[] aDataArray = new AttachmentData[aDataList.size()];
            aDataArray = aDataList.toArray(aDataArray);
            return aDataArray;
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException(e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }

    }

    public AttachmentData getAttachment(String pageId, String aid)throws IllegalArgumentException{
        try {
            AuthRequest ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());
            ar.assertLoggedIn("Can not Retrieve Attachment.");
            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);
            AttachmentRecord arecord = ngp.findAttachmentByID(aid);
            AttachmentData aData = new AttachmentData(arecord.getId(),arecord.getDisplayName(),arecord.getComment());
            aData.setVisibility(arecord.getVisibility());
            aData.setReadOnly(arecord.getReadOnlyType());
            return aData;
        }catch(Exception e){
            e.printStackTrace();
            throw new IllegalArgumentException(e);
        }finally{
            NGPageIndex.clearLocksHeldByThisThread();
        }
    }

     public TaskData[] getTasks(String pageId)throws IllegalArgumentException{
       try{
            AuthRequest ar = AuthRequest.getOrCreate(this.getThreadLocalRequest(), this.getThreadLocalResponse());

            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageId);
            ar.setPageAccessLevels(ngp);
            List<GoalRecord> tecords = ngp.getAllGoals();
            ArrayList<TaskData> tDataList = new ArrayList<TaskData>();
            for (GoalRecord trecord : tecords){
                TaskData tData = new TaskData();
                tData.processurl = trecord.getDisplayLink();
                tData.id = trecord.getId();
                tData.name = trecord.getSynopsis();
                tData.state = GoalRecord.stateName(trecord.getState());
                tData.assignee = trecord.getAssigneeCommaSeparatedList();
                tData.creator = trecord.getCreator();
                tData.status = trecord.getStatus();
                tData.priroty = trecord.getPriority();
                tData.duedate = trecord.getDueDate();
                tData.startdate = trecord.getStartDate();
                tData.enddate = trecord.getEndDate();

                if(trecord.hasSubGoals()){
                    tData.isGroup = true;
                }

                if(trecord.hasParentGoal()){
                    tData.parentId = trecord.getParentGoalId();
                }else{
                    tData.parentId = "0";
                }

                tDataList.add(tData);

            }

            TaskData[] tDataArray = new TaskData[tDataList.size()];
            tDataArray = tDataList.toArray(tDataArray);
            return tDataArray;


       }catch(Exception e){
           e.printStackTrace();
           throw new IllegalArgumentException(e);
       }

    }



}
