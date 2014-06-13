<%@page import="org.socialbiz.cog.exception.NGException"
%><%@page import="org.socialbiz.cog.exception.ProgramLogicError"
%><%@page import="org.socialbiz.cog.AddressListEntry"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@page import="org.socialbiz.cog.DOMFace"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.NoteRecord"
%><%@page import="org.socialbiz.cog.LeafletResponseRecord"
%><%@page import="org.socialbiz.cog.License"
%><%@page import="org.socialbiz.cog.LicensedURL"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGContainer"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.SectionAttachments"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionTask"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.UserPage"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.WikiConverter"
%><%@page import="org.socialbiz.cog.WikiConverterForWYSIWYG"
%><%@page import="org.socialbiz.cog.dms.ConnectionSettings"
%><%@page import="org.socialbiz.cog.dms.ConnectionType"
%><%@page import="org.socialbiz.cog.dms.FolderAccessHelper"
%><%@page import="org.socialbiz.cog.dms.ResourceEntity"
%><%@page import="java.io.File"
%><%@page import="java.io.Writer"
%><%@page import="java.io.Writer"
%><%@page import="java.lang.StringBuffer"
%><%@page import="java.lang.StringBuffer"
%><%@page import="java.net.URLDecoder"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.text.SimpleDateFormat"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.Date"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.HashMap"
%><%@page import="java.util.Iterator"
%><%@page import="java.util.List"
%><%@page import="java.util.Map"
%><%@page import="java.util.Properties"
%><%@page import="java.util.StringTokenizer"
%><%@page import="java.util.Vector"
%><%

/*

functions.jsp provides useful java functions for the pages
It does NOT produce any output by itself.

Optional Parameters:

    // used in 'findSpecifiedUserOrDefault' method
    u : This is user key which is used to get details of specified User.

    // used in 'displayCreatLeaf' method
    visibility_value : This is used to get visibility whether its public or member.

*/

%><%!int count=100;
    private NGContainer ngp = null;
    private NGBook ngb = null;
    private boolean firstLeafLet = true;

    static public String[] splitOnDelimiter (String str, char delim)
        throws Exception
    {
        return UtilityMethods.splitOnDelimiter(str, delim);

    }
    public static void writeHtml(Writer out, String t)
    throws Exception
    {
        if (t==null) {
            return;  //treat it like an empty string
        }
        for (int i=0; i<t.length(); i++) {

            char c = t.charAt(i);
            switch (c) {
                case '&':
                    out.write("&amp;");
                    continue;
                case '<':
                    out.write("&lt;");
                    continue;
                case '>':
                    out.write("&gt;");
                    continue;
                case '"':
                    out.write("&quot;");
                    continue;
                default:
                    out.write(c);
                    continue;
            }
        }
    }

    boolean needTomcatKludge = false;
    public String
    defParam(HttpServletRequest request,
        String paramName,
        String defaultValue)
        throws Exception
    {
        String val = request.getParameter(paramName);
        if (val!=null)
        {
            // this next line should not be needed, but I have seen this hack recommended
            // in many forums.  See setTomcatKludge() above.
            if (needTomcatKludge)
            {
                val = new String(val.getBytes("iso-8859-1"), "UTF-8");
            }
            return val;
        }

        //try and see if it a request attribute
        val = (String)request.getAttribute(paramName);
        if (val != null)
        {
            return val;
        }

        return defaultValue;
    }


    public String getSiteRootURL(AuthRequest ar, NGBook site) {
        String pageRootURL = ar.retPath + "t/"+site.getKey()+"/$/";
        return pageRootURL;
    }
    public String getProjectRootURL(AuthRequest ar, NGPage ngp) {
        NGBook site = ngp.getSite();
        String pageRootURL = ar.retPath + "t/"+site.getKey()+"/"+ngp.getKey()+"/";
        return pageRootURL;
    }
    public String getNoteEditorURL(AuthRequest ar, NGContainer ngc, String noteId) {
        return ar.retPath + "t/texteditor.htm?pid=" + ngc.getKey() + "&nid=" + noteId;
        /*
        if (ngc instanceof NGBook) {
            return getSiteRootURL(ar, (NGPage)ngc) + "note" + noteId + "/noteEditor.htm";
        }
        else {
            return getProjectRootURL(ar, (NGPage)ngc) + "note" + noteId + "/noteEditor.htm";
        }
        */
    }
    public String getNoteCreatorURL(AuthRequest ar, NGContainer ngc) {
        return ar.retPath + "t/texteditor.htm?pid=" + ngc.getKey() + "&nid=";
    }


    /**
     * Returns only valid alphanumeric characters of the input String.
     * Any characters outside the ASCII character set (greater than 127)
     * used to be returned unchanged (version 7.2 and earlier) but now
     * characters > 127 are excluded.  This is because JavaScript variable
     * rules (sanitized names are used for JS variables as well as form
     * variable names) require only alphanumeric and underscore.
     *
     * @param s The input String to be translated to pure alphanumeric String.
     * @return The String after removing all non-alphanumeric characters.
     */
    public static String getSanitizedString(String s) {
        StringBuffer sOut = null;
        if (s == null) {
            return null;
        }
        if (s.length() == 0) {
            return "";
        }

        int ilen = s.length();
        sOut = new StringBuffer(ilen);
        char c;
        for (int i = 0; i<ilen; i++)
        {
            c = s.charAt(i);
            if (c == '_'                ||  // underscore
                (c >= 'A' && c <= 'Z')  ||  // uppercase letters
                (c >= 'a' && c <= 'z')  ||  // lowercase letters
                (c >= '0' && c <= '9'))     // numerals
            {
                sOut.append(c);
            }
        }
        return sOut.toString();
    }


    public UserProfile findSpecifiedUserOrDefault(AuthRequest ar)
        throws Exception
    {
        String u = ar.defParam("u", null);
        UserProfile up = null;
        if (u!=null)
        {
            up = UserManager.getUserProfileByKey(u);
            if (up==null)
            {
                Thread.sleep(3000);
                throw new NGException("nugen.exception.user.not.found.invalid.key",new Object[]{u});
            }
        }
        else
        {
            if (!ar.isLoggedIn())
            {
                return null;
            }
            up = ar.getUserProfile();

            //every logged in user should have a profile, so should never hit this
            if (up == null)
            {
                throw new ProgramLogicError("every logged in user should have a profile, why is it missing in this case?");
            }
        }
        return up;
    }



    public void headlinePath(AuthRequest ar, String localName,NGBook ngb,NGPage ngp)
    throws Exception
    {
        String trncatePageTitle=null;

        if (ngb!=null)
        {
            ar.writeHtml(ngb.getName());
        }
        ar.write(" &raquo; ");
        if (ngp!=null)
        {
            if(ngp.getFullName().length()>40){
                trncatePageTitle=ngp.getFullName().substring(0,40)+"...";
            }else{
                trncatePageTitle=ngp.getFullName();
            }
            ar.write("<span title=\"");
            ar.writeHtml(ngp.getFullName());
            ar.write("\">");
            ar.writeHtml(trncatePageTitle);
            ar.write("</span>");
        }
        ar.write(" &raquo; ");
        ar.writeHtml( localName);
    }


    public String redirectToViewLevel(AuthRequest ar, NGPage ngp, int viewLevel)
        throws Exception
    {
        if (viewLevel==SectionDef.MEMBER_ACCESS)
        {
            return ar.getResourceURL(ngp,"member.htm");
        }
        if (viewLevel==SectionDef.ADMIN_ACCESS)
        {
            return  ar.getResourceURL(ngp,"projectSettings.htm");
        }
        if (viewLevel==SectionDef.PRIVATE_ACCESS)
        {
            return ar.getResourceURL(ngp,"private.htm");
        }
        return ar.getResourceURL(ngp,"projectHome.htm");
    }

    public void displayCreatLeaf(AuthRequest ar, NGPage ngc) throws Exception{
        String pageRootURL = getProjectRootURL(ar, ngc);
        if(ar.isLoggedIn()){
            NGBook site  = ngc.getSite();

            ar.write("\n<div class=\"createLeaf\">");

            String createNoteUrl = getNoteCreatorURL(ar, ngc) + "&visibility_value="
                +ar.defParam("visibility_value","0");

            ar.write("\n<a id=\"create_leaflet\" href=\"");
            ar.writeHtml(createNoteUrl);
            ar.write("\" title=\"tiny_mce_editor\"  target=\"_blank\">");
            ar.write("Create Note</a>&nbsp;");

            ar.write("\n<a name=\"expand_collapse");
            ar.write("\" id=\"expand_collapse\" title=\"Expand All\" href=\"#");
            ar.write("\" onclick=\"return expandCollapseAll('");
            ar.writeHtml(ar.retPath);
            ar.write("');\">");


            ar.write("[+] Expand All");
            ar.write("</a>");

            if(ngc instanceof NGPage){
                //Adding Export to PDF for NGPage only, will add in Site as well if required
                String pdflink =pageRootURL + "exportPDF.htm";
                ar.write("&nbsp;&nbsp;&nbsp;<a id=\"exportToPdf\" href=\"");
                ar.writeHtml(pdflink);
                ar.write("\" title=\"Generate a PDF of this note for printing.\"><img src=\"");
                ar.writeHtml(ar.retPath);
                ar.write("assets/iconPrint.gif\">&nbsp;Generate PDF");
                ar.write("</a>&nbsp;&nbsp;&nbsp;");
            }
            ar.write("</div>");
        }
    }

    public void displayCreatLeafOnSite(AuthRequest ar, NGBook site) throws Exception{
        String pageRootURL = ar.retPath + "t/"+site.getKey()+"/$/";
        if(ar.isLoggedIn()){

            ar.write("\n<div class=\"createLeaf\">");

            String createNoteUrl = getNoteCreatorURL(ar, site) + "&visibility_value="
                +ar.defParam("visibility_value","0");

            ar.write("\n<a id=\"create_leaflet\" href=\"");
            ar.writeHtml(createNoteUrl);
            ar.write("\" title=\"tiny_mce_editor\"  target=\"_blank\">");
            ar.write("Create Note</a>&nbsp;");

            ar.write("\n<a name=\"expand_collapse");
            ar.write("\" id=\"expand_collapse\" title=\"Expand All\" href=\"#");
            ar.write("\" onclick=\"return expandCollapseAll('");
            ar.writeHtml(ar.retPath);
            ar.write("');\">");


            ar.write("[+] Expand All");
            ar.write("</a>");

            ar.write("</div>");
        }
    }

    public int displayAllLeaflets(AuthRequest ar, NGContainer ngp, int displayLevel)
            throws Exception {
        return displayListOfNotes(ar, ngp, ngp.getVisibleNotes(ar,displayLevel));
    }


    public int displayDeletedNotes(AuthRequest ar, NGContainer ngp)
            throws Exception {
        return displayListOfNotes(ar, ngp, ngp.getDeletedNotes(ar));
    }


    public int displayDraftNotes(AuthRequest ar, NGContainer ngp)
            throws Exception {
        return displayListOfNotes(ar, ngp, ngp.getDraftNotes(ar));
    }

    private int displayListOfNotes(AuthRequest ar, NGContainer ngp, List <NoteRecord> notes)
            throws Exception {

        Vector<NoteRecord> nl = new Vector<NoteRecord>();
        ar.write("\n<div class=\"leafLetArea\"> ");
        nl.addAll(notes);
        NoteRecord.sortCommentsByPinOrder(nl);
        for (NoteRecord noteRec : nl)
        {
            displayNewLeafletUI(ar,noteRec, count++,ngp);
            ar.flush();
        }
        ar.write("</div>");
        return nl.size();
    }

    private void writeOneLeaflet(NGContainer ngp, AuthRequest ar, int accessLevel, NoteRecord cr)
        throws Exception
    {
        Writer w = ar.w;

        ar.write("<div class=\"leafContent\">");
        displayNewLeafletUIZoomView(ar, cr, -1,ngp);

        ar.w.flush();
    }



    /**
    * displayNewLeafletUIZoomView will display a single comment record.
    * index "i" denotes the index on the page, when there are multiple entries
    * on the page.   This is important for being able to open and close the
    * sections.  Pass a -1 for the index to disable this, and leave it only open
    * and without controls for opening or zooming.
    */
    private void displayNewLeafletUIZoomView(AuthRequest ar, NoteRecord cr, int i, NGContainer ngp)
        throws Exception
    {

        UserProfile uProf = ar.getUserProfile();
        boolean canEdit = false;
        String owner = cr.getOwner();
        String lastModifiedBy = cr.getLastEditedBy();
        if(lastModifiedBy==null || lastModifiedBy.trim().equals("")){
            lastModifiedBy=owner;
        }
        else{
            owner=lastModifiedBy;
        }

        long cTime = cr.getLastEdited();
        long effDime = cr.getEffectiveDate();
        if (!ar.isLoggedIn())
        {
            canEdit = false;
        }
        else if(ar.isAdmin())
        {
            canEdit = true;
        }
        else if(uProf!=null && uProf.hasAnyId(owner))
        {
            canEdit = true;
        }
        else if (cr.getEditable()==NoteRecord.EDIT_MEMBER && ar.isMember())
        {
            canEdit = true;
        }

        String subject = cr.getSubject();
        String trncateSubject = "";

        String emailUrl = ar.retPath + "t/sendNoteByEmail.htm?p="
        + SectionUtil.encodeURLData(ngp.getKey())
        + "&oid=" + SectionUtil.encodeURLData(cr.getId())
        + "&encodingGuard=" + SectionUtil.encodeURLData("\u6771\u4eac");

        if(subject == null || subject.length() == 0)
        {
            subject = "No Subject";
        }

        String divid = "comment-" + i;
        String divheadingid = "leafHeading" + i;
        String imgId = "image"+ i;

        ar.write("<div class=\"leafHeadingZoom\">");
        ar.writeHtml(subject);
        if(cr.isDeleted()){
            ar.write("&nbsp;&nbsp;<img src=\""+ar.retPath+"deletedLink.gif\"> <font color=\"red\">(DELETED)</font>");
        }
        ar.write("</div>");
        ar.write("<div class=\"leafNoteZoom\">");
        ar.write("Last edited by <b>");
        UserProfile.writeLink(ar,owner);
        ar.write("</b>&nbsp;on ");
        SectionUtil.nicePrintTime(ar.w, cTime, ar.nowTime);
        if(ar.isLoggedIn() && !cr.isDeleted())
        {
            ar.write("<div class=\"leafNoteZoomRight\">");

            ar.write("\n <img src=\"");
            ar.writeHtml(ar.retPath);
            ar.write("assets/images/iconEditNote.gif\" width=\"17\" height=\"15\" alt=\"\" />");

            String editorUrl = getNoteEditorURL(ar, ngp, cr.getId());
            ar.write("\n<a href=\"");
            ar.writeHtml(editorUrl);
            ar.write("\" title=\"tiny_mce_editor\" target=\"_blank\">");
            ar.write("Edit This Note");
            ar.write("</a>");
            ar.write("&nbsp;&nbsp;&nbsp;");

            String pdfUrl = "pdf/note"+cr.getId()+".pdf?publicNotes="+cr.getId();
            ar.write(" <a href=\"");
            ar.writeHtml(pdfUrl);
            ar.write("\" title=\"Generate a PDF of this note for printing.\" target=\"_blank\"><img src=\"");
            ar.writeHtml(ar.retPath);
            ar.write("assets/iconPrint.gif\">&nbsp;");
            ar.write("Generate PDF</a>");
            ar.write("&nbsp;&nbsp;&nbsp;");

            ar.write(" <a");
            ar.write(" id=\"emaillink_");
            ar.writeHtml(divid);
            ar.write("\" href=\"");
            ar.writeHtml(emailUrl);
            ar.write("\" title=\"Send this note as an email message\" target=\"_blank\"><img src=\"");
            ar.writeHtml(ar.retPath);
            ar.write("assets/images/iconEmailNote.gif\">&nbsp;");
            ar.write("Send Note By Email</a>");
            ar.write("</div>");
        }
        ar.write("</div>");
        ar.write("<br/>");
        ar.write("<div class=\"leafContent\">");
        ar.write("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
        ar.write("<tr><td>");
        WikiConverter.writeWikiAsHtml(ar, cr.getData().trim());
        ar.write("\n</td>\n</tr>\n</table>");
        boolean ownerEditOnly = !(cr.getEditable() == 2);
        //start leaf note
        if(canEdit)
        {


            String removeUrl = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Remove"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&visibility="+cr.getVisibility()
            +"&editable="+cr.getEditable();


            String undeleteLink = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Undelete"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&visibility="+cr.getVisibility()
            +"&editable="+cr.getEditable();

            String changeVisibilityUrl = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Change Visibility"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&editable="+cr.getEditable();

            if(ngp instanceof NGPage){
                removeUrl = removeUrl+"&project=true";
            }else{
                removeUrl = removeUrl+"&project=false";
            }

            if(ngp instanceof NGPage){
                changeVisibilityUrl = changeVisibilityUrl+"&project=true";
            }else{
                changeVisibilityUrl = changeVisibilityUrl+"&project=false";
            }

            ar.write("<input type=\"hidden\" name=\"p\" id=\"");
            ar.writeHtml(divid);
            ar.write("_remove_link\" value=\"");
            ar.writeHtml(removeUrl);
            ar.write("\"/>");


            ar.write("<input type=\"hidden\" name=\"undelete\" id=\"");
            ar.writeHtml(divid);
            ar.write("_undelete_link\" value=\"");
            ar.writeHtml(undeleteLink);
            ar.write("\"/>");

            ar.write("<input type=\"hidden\" name=\"visibility_url\" id=\"");
            ar.writeHtml(divid);
            ar.write("_visibility_link\" value=\"");
            ar.writeHtml(changeVisibilityUrl);
            ar.write("\"/>");
         }
    }




    /**
     * displayNewLeafletUI will display a single comment record.
     * index "i" denotes the index on the page, when there are multiple entries
     * on the page.   This is important for being able to open and close the
     * sections.  Pass a -1 for the index to disable this, and leave it only open
     * and without controls for opening or zooming.
     */
    private void displayNewLeafletUI(AuthRequest ar, NoteRecord cr, int i, NGContainer ngp)
         throws Exception
    {

        UserProfile uProf = ar.getUserProfile();
        boolean canEdit = false;
        String owner = cr.getOwner();
        String lastModifiedBy = cr.getLastEditedBy();
        if(lastModifiedBy==null || lastModifiedBy.trim().equals("")){
            lastModifiedBy=owner;
        }
        else{
            owner=lastModifiedBy;
        }

        long cTime = cr.getLastEdited();
        long effDime = cr.getEffectiveDate();

        if (!ar.isLoggedIn())
        {
            canEdit = false;
        }
        else if(ar.isAdmin())
        {
            canEdit = true;
        }
        else if(uProf!=null && uProf.hasAnyId(owner))
        {
            canEdit = true;
        }
        else if (cr.getEditable()==NoteRecord.EDIT_MEMBER && ar.isMember())
        {
            canEdit = true;
        }

        String subject = cr.getSubject();
        String trncateSubject = "";

        if(subject == null || subject.length() == 0)
        {
            subject = "No Subject";
        }

        String divid = "comment-" + i;
        String divheadingid = "leafHeading" + i;
        String imgId = "image"+ i;
        if (i>=0)
        {


            String javascript1 = canEdit?"showHideCommnets('" + divid + "','"+ar.retPath+"');onRightClick('"+divheadingid+"','"+divid+"','"+cr.getId()+"');":"showHideCommnets('" + divid + "','"+ar.retPath+"');";
            String javascript_leaflet = canEdit?"expandCollapseLeaflets('" + divid + "','"+ar.retPath+"','"+divheadingid+"');onRightClick('"+divheadingid+"','"+divid+"','"+cr.getId()+"');":"expandCollapseLeaflets('" + divid + "','"+ar.retPath+"','"+divheadingid+"');";
            ar.write("\n<div class=\"leafHeading\" id=\"");
            ar.write(divheadingid);
            if(canEdit){
                ar.write("\" oncontextmenu=\"onRightClick('");
                ar.writeHtml(divheadingid);
                ar.write("','");
                ar.writeHtml(divid);
                ar.write("','");
                ar.writeHtml(cr.getId());
                ar.write("');return false;\" >");
            }
            else {
                ar.write("\">");
            }
            ar.write("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
            ar.write("<tr>");
            ar.write("<td class=\"zoomHeadingArea\" id=\"");
            ar.writeHtml(divheadingid);
            ar.write("_");
            ar.writeHtml(divid);
            ar.write("\" onMouseOver=\"this.style.backgroundColor='#fdf9e1'\" onMouseOut=\"this.style.backgroundColor='#f7f7f7'\" onclick=\"javascript:");
            ar.writeHtml(javascript_leaflet);
            ar.write("\">");
            ar.write("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">\n<tr>");
            ar.write("<td><img src=\"");
            ar.write(ar.retPath);
            ar.write("assets/images/expandIcon.gif\" id=\"img_");
            ar.writeHtml(divid);
            ar.write("\" name=\"img1\" alt=\"\" border=\"0\" id=\"");
            ar.write(imgId);
            ar.write("\" />&nbsp;");
            if(subject!=null){
                if(subject.length()>45){
                    trncateSubject=subject.substring(0,45)+"...";
                }else{
                    trncateSubject=subject;
                }
                ar.write("<span title=\"");
                ar.write(subject);
                ar.write("\">");
                ar.writeHtml(trncateSubject);
                ar.write("</span>");
            }
            ar.write("</td>");
            ar.write("<td></td>");
            ar.write("<td class=\"leafNote\">- Last edited by ");
            UserProfile.writeLink(ar,owner);
            ar.write(" ");
            SectionUtil.nicePrintTime(ar.w, cTime, ar.nowTime);
            ar.write("</td>");
            ar.write("</tr></table></td>");
            if (i >= 0) {
                ar.write("<td class=\"zoomIcon\" title=\"Zoom this Note to full page\"");
                if(ngp.isFrozen()){
                    ar.write("onclick=\"javascript:return openFreezeMessagePopup();\">");
                }else{
                    ar.write("<td class=\"zoomIcon\" title=\"Zoom this Note to full page\" onclick=\"window.location='");
                    ar.write(ar.retPath);
                    ar.writeHtml(ar.getResourceURL(ngp, cr));
                    ar.write("'\">");
                }
                ar.write("</td>");
            }

            ar.write("\n</tr>\n</table>\n</div>");
        }
        else
        {
            ar.writeHtml(subject);
        }


        if (i>=0)
        {
         //zoom logic goes here
        }
        //end of heading div

        //start leaf content
        ar.write("\n<div");
        if(canEdit){
            ar.write(" oncontextmenu=\"return true;\"");
        }
        ar.write(" class=\"leafContentArea\" id=\"");
        ar.write(divid);    //this does not need encoding
        ar.write("\" style=\"display:none\">");
        ar.write("\n<div class=\"leafContent\" oncontextmenu=\"return true;\">");
        ar.write("<table width=\"100%\" cellpadding=\"0\" cellspacing=\"0\">");
        ar.write("<tr><td>");
        WikiConverter.writeWikiAsHtml(ar, cr.getData().trim());
        ar.write("\n</td>");

        ar.write("\n</tr>\n</table>");
        ar.write("\n</div>");

        boolean  ownerEditOnly = !(cr.getEditable() == 2);
     //start leaf note
        ar.write("\n<div  class=\"leafFooter\">&nbsp;");
        if(canEdit)
        {
            String removeUrl = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Remove"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&visibility="+cr.getVisibility()
            +"&editable="+cr.getEditable();


            String undeleteLink = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Undelete"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&visibility="+cr.getVisibility()
            +"&editable="+cr.getEditable();

            if(ngp instanceof NGPage){
                removeUrl = removeUrl+"&project=true";
            }else{
                removeUrl = removeUrl+"&project=false";
            }

            String changeVisibilityUrl = ar.retPath+"t/createLeafletSubmit.ajax?p="+SectionUtil.encodeURLData(ngp.getKey())
            +"&action=Change Visibility"
            +"&oid="+ SectionUtil.encodeURLData(cr.getId())
            +"&go="+SectionUtil.encodeURLData(ar.getCompleteURL())
            +"&editable="+cr.getEditable();

            if(ngp instanceof NGPage){
                changeVisibilityUrl = changeVisibilityUrl+"&project=true";
            }else{
                changeVisibilityUrl = changeVisibilityUrl+"&project=false";
            }
            String emailUrl = ar.retPath + "t/sendNoteByEmail.htm?p="
            + SectionUtil.encodeURLData(ngp.getKey())+ "&oid="
            + SectionUtil.encodeURLData(cr.getId()) + "&encodingGuard=%E6%9D%B1%E4%BA%AC";
            if(ngp instanceof NGPage){
                emailUrl = emailUrl+"&project=true";
            }

            ar.write("<input type=\"hidden\" name=\"p\" id=\"");
            ar.writeHtml(divid);
            ar.write("_remove_link\" value=\"");
            ar.writeHtml(removeUrl);
            ar.write("\"/>");

            ar.write("<input type=\"hidden\" name=\"undelete\" id=\"");
            ar.writeHtml(divid);
            ar.write("_undelete_link\" value=\"");
            ar.writeHtml(undeleteLink);
            ar.write("\"/>");


            ar.write("<input type=\"hidden\" name=\"visibility_url\" id=\"");
            ar.writeHtml(divid);
            ar.write("_visibility_link\" value=\"");
            ar.writeHtml(changeVisibilityUrl);
            ar.write("\"/>");

            if(!cr.isDeleted()){
                ar.write("\n <img src=\"");
                ar.writeHtml(ar.retPath);
                ar.write("assets/images/iconEditNote.gif\" width=\"17\" height=\"15\" alt=\"\" />");

                if(!ngp.isFrozen()){
                    String editorUrl = getNoteEditorURL(ar,ngp,cr.getId());
                    ar.write("\n<a id=\"hreflink_");
                    ar.writeHtml(divid);
                    ar.write("\" href=\"");
                    ar.writeHtml(editorUrl);
                    ar.write("\" title=\"tiny_mce_editor\" target=\"_blank\">");
                    ar.write("Edit Note");
                    ar.write("</a>");
                    ar.write("&nbsp;&nbsp;&nbsp");

                }
                else {
                    ar.write("<a name=\"comments");
                    ar.write("\" id=\"hreflink_");
                    ar.writeHtml(divid);
                    ar.write("\" href=\"#\" onclick=\"javascript:return openFreezeMessagePopup();\">");
                    ar.write("Edit this Note</a>&nbsp;");
                }

                if(!cr.isDraftNote()){
                    ar.write(" <a id=\"emaillink_");
                    ar.writeHtml(divid);
                    ar.write("\" href=\"");

                    if(ngp.isFrozen()){
                        ar.write("#\" onclick=\"javascript:return openFreezeMessagePopup();\"");
                    }else{
                        ar.writeHtml(emailUrl);
                        ar.write("\" onclick=\"return checkDeletedAndSubmit('");
                        ar.write(cr.getId());
                        ar.write("','");
                        ar.writeHtml(emailUrl);
                        ar.write("');\"");
                    }

                    ar.write(" title=\"Send this note as an email message\" target=\"_blank\"><img src=\"");
                    ar.writeHtml(ar.retPath);
                    ar.write("assets/images/iconEmailNote.gif\">&nbsp;");

                    ar.write("Send Note By Email</a>&nbsp;");
                }else{
                    ar.write(" <a id=\"publishNote");
                    ar.writeHtml(divid);
                    ar.write("\" href=\"#\"");
                    if(ngp.isFrozen()){
                        ar.write("#\" onclick=\"javascript:return openFreezeMessagePopup();\"");
                    }else{
                        ar.write(" onclick=\"return publishNote('");
                        ar.write(ar.baseURL);
                        ar.write("','");
                        ar.write(ngp.getKey());
                        ar.write("','");
                        ar.write(cr.getId());
                        ar.write("', false);\"");
                    }
                    ar.write(" title=\"Publish this Note\"><img src=\"");
                    ar.writeHtml(ar.retPath);
                    ar.write("assets/images/iconPublishNotes.gif\">&nbsp;");
                    ar.write("Publish this Note</a>&nbsp;");
                }
            }
            if (i >= 0) {
                ar.write("  <a href=\"");
                if(ngp.isFrozen()){
                    ar.write("#\" onclick=\"javascript:return openFreezeMessagePopup();\"");
                }else{
                    ar.write(ar.retPath);
                    ar.writeHtml(ar.getResourceURL(ngp, cr));
                }
                ar.write("\" title=\"Zoom this note to full page\"><img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/images/zoom6.gif\">");
                ar.write(" Zoom </a>");
            }
        }
        if(firstLeafLet){
            ar.write("\n<script>expandCollapseLeaflets('");
            ar.writeHtml(divid);
            ar.write("','");
            ar.writeHtml(ar.retPath);
            ar.write("','");
            ar.writeHtml(divheadingid);
            ar.write("');</script>");
        }
        ar.write("\n</div></div>");
    }


    public static String getUserFullNameList()
    {
        return UserManager.getUserFullNameList();
    }

    public void attachmentSectionDisplay(AuthRequest ar, NGContainer ngp, int displayLevel) throws Exception
    {
        UserProfile up = ar.getUserProfile();
        this.ngp = ngp;
        List<HistoryRecord> histRecs = ngp.getAllHistory();
        int count = 0;
        for(AttachmentRecord attachment : ngp.getAllAttachments())
        {
            if (attachment.getVisibility()!=displayLevel || attachment.isDeleted())
            {
                continue;
            }
            writeAttachment(attachment,ar,histRecs,count);
            count++;
        }
    }


    public void deletedAttachmentSectionDisplay(AuthRequest ar, NGContainer ngp) throws Exception
    {
        UserProfile up = ar.getUserProfile();
        this.ngp = ngp;
        List<HistoryRecord> histRecs = ngp.getAllHistory();
        int count = 0;
        for(AttachmentRecord attachment : ngp.getAllAttachments())
        {
            if (!attachment.isDeleted())
            {
                continue;
            }
            writeAttachment(attachment,ar,histRecs,count);
            count++;
        }
    }


    public void writeAttachment(AttachmentRecord attachment,AuthRequest ar,List<HistoryRecord> histRecs,int count) throws Exception{

        String rowStyleClass = "tableBodyRow even";
        String id = attachment.getId();

        int readStatus = 0;
        boolean matchesVersion = true;
        for (HistoryRecord hist : histRecs)
        {
            if (hist.getContextType() == HistoryRecord.CONTEXT_TYPE_DOCUMENT)
            {
                if(id.equals(hist.getContext()))
                {
                    readStatus = hist.getEventType();
                    matchesVersion = (attachment.getModifiedDate()==hist.getContextVersion());
                    break;
                }
            }
        }
        // for FILE the file & displayName attribute will be the same.
        // for the URL the file & the displayName will be different.
        String fname = attachment.getStorageFileName();

        String accessName = attachment.getNiceName();
        String displayName = attachment.getNiceNameTruncated(48);
        String ftype = attachment.getType();

        String modifiedBy = attachment.getModifiedBy();
        if (modifiedBy.length() == 0)
        {
            modifiedBy = "unknown";
        }

         String editLink = "editDetails"+URLEncoder.encode(id, "UTF-8")+".htm"
                + "?p=" + URLEncoder.encode(ngp.getKey(), "UTF-8");

        String contentLink = "";
        boolean putCreateIcon = false;
        if (ftype.equals("URL"))
        {
            contentLink = fname; // URL.
        }
        else
        {
            contentLink = "a/" + SectionUtil.encodeURLData(accessName)+"?version="+attachment.getVersion();
        }

        if(count%2 == 0){
         rowStyleClass = "tableBodyRow odd";
        }else{
         rowStyleClass = "tableBodyRow even";
        }

        ar.write("\n<tr class='");
        ar.writeHtml(rowStyleClass);
        ar.write("'>");

        ar.write("\n<td width=\"250px\">");
        ar.writeHtml(displayName);
        ar.write("</td>");

        ar.write("\n<td>");
        SectionUtil.nicePrintTime(ar.w,attachment.getModifiedDate(), ar.nowTime);
        ar.write("</td>");
        if(!attachment.isDeleted())
        {
            ar.write("\n<td align=\"center\">");

            if (attachment.getVisibility()<=1)
            {
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/images/iconPublic.png\" name=\"PUB\" alt=\"Public\" title=\"Public\" />");
            }
            else
            {
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/images/iconMember.png\" name=\"MEM\" alt=\"Member\" title=\"Member\" />");
            }
            ar.write("</td>");

            if(attachment.getType().equals("URL")){
                ar.write("\n<td align=\"center\">");
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/images/iconUrl.png\" name=\"URL\" alt=\"URL\" title=\"URL\" />");
                ar.write("</td>");
                ar.write("<td>");
                ar.write("false");
                ar.write("</td>");
            }
            else if ((attachment.hasRemoteLink()) && (!attachment.getType().equals("URL")))
            {
                ar.write("\n<td align=\"center\">");
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/images/iconLinkedFile.png\" name=\"Linked To Repository\" alt=\"Linked To Repository\" title=\"Linked To Repository\" />");
                ar.write("</td>");
                ar.write("<td>");
                ar.write("true");
                ar.write("</td>");
            }
            else
            {
                String tip = "Regular File";
                String imagePath = "assets/images/iconFile.png";
                if (attachment.getType().equals("EXTRA"))
                {
                    tip = "File Discovered in Project Folder";
                    imagePath = "assets/images/iconFileExtra.png";
                }
                else if (attachment.getType().equals("GONE"))
                {
                    tip = "File (but appears to be missing)";
                    imagePath = "assets/images/iconFileGone.png";
                }
                ar.write("\n<td align=\"center\">");
                ar.write("<a href=\"editDetails");
                ar.write(id);
                ar.write(".htm\"><img src=\"");
                ar.write(ar.retPath);
                ar.write(imagePath);
                ar.write("\" name=\"");
                ar.write(tip);
                ar.write("\" alt=\"");
                ar.write(tip);
                ar.write("\" title=\"");
                ar.write(tip);
                ar.write("\" /></a>");
                ar.write("</td>");
                ar.write("<td>");
                ar.write("false");
                ar.write("</td>");
            }

        }
        ar.write("<td>");
        ar.writeHtml(attachment.getComment());
        ar.write("</td>");

        if(attachment.isDeleted()){
            ar.write("<td>");
            SectionUtil.nicePrintTime(ar.w,attachment.getDeleteDate(), ar.nowTime);
            ar.write("</td>");
            ar.write("<td>");
            UserProfile.writeLink(ar,attachment.getDeleteUser());
            //ar.writeHtml(attachment.getDeleteUser());
            ar.write("</td>");
        }

        ar.write("<td align='center'>");
        ar.write("\n<a href=\"");
        ar.writeHtml(editLink);
        ar.write("\" title=\"Modify your settings for this attachment\"><img src=\"");
        ar.write(ar.retPath);
        if (readStatus==HistoryRecord.EVENT_DOC_APPROVED)
        {
            ar.write("assets/images/ts_completed.gif");
        }
        else if (readStatus==HistoryRecord.EVENT_DOC_REJECTED)
        {
            ar.write("assets/images/ts_waiting.gif");
        }
        else if (readStatus==HistoryRecord.EVENT_DOC_SKIPPED)
        {
            ar.write("assets/images/ts_skipped.gif");
        }
        else
        {
            ar.write("assets/images/ts_initial.gif");
        }
        ar.write("\">");

        ar.write("</a>");
        ar.write("</td>");

        ar.write("<td>");
        ar.writeHtml(attachment.getId());
        ar.write("</td>");
        ar.write("<td>");
        ar.writeHtml(attachment.getDisplayName());
        ar.write("</td>");

        ar.write("<td>");
        ar.writeHtml(attachment.getId());
        ar.write("</td>");

        ar.write("<td>");
        ar.writeHtml(String.valueOf(attachment.getVersion()));
        ar.write("</td>");

        ar.write("<td>");
        if("URL".equals(attachment.getType())){
            ar.writeHtml(attachment.getStorageFileName());
        }else{
            ar.writeHtml(SectionUtil.encodeURLData(accessName));
        }
        ar.write("</td>");

        ar.write("\n<td>");
        long diff = (ar.nowTime - attachment.getModifiedDate())/1000;
        ar.writeHtml(String.valueOf(diff));
        ar.write("</td>");

        ar.write("<td>");
        int val = 3;
        if (attachment.getVisibility()==2) {
            val=4;
        }
        if (!attachment.isUpstream()) {
            val = val - 2;
        }
        ar.write(Integer.toString(val));
        ar.write("</td>");

        ar.write("<td>");
        ar.writeHtml(ftype);
        ar.write("</td>");
        if(!attachment.isDeleted())
        {
            ar.write("<td>");
            ar.writeHtml(attachment.getReadOnlyType());
            ar.write("</td>");
        }

        ar.write("<td>");
        ar.write("<img src=\"");
        ar.write(ar.baseURL);
        ar.write("assets/iconDownload.png\" name=\"DOWMLOAD\" alt=\"Public\" title=\"download\" />");
        ar.write("</td>");

        ar.write("</tr>");
    }


    /**
     * Strange function.  If you have an openid, this will return an email address for
     * that user if one is known.  If you have an email, it will return the openid
     * for that user if one is known.  In all other cases a zero length string is returned.
     */
    public String getPossibleOtherId(String possibleId)
    {
        if (possibleId==null)
        {
            return "";
        }
        UserProfile up = UserManager.findUserByAnyId(possibleId);
        if (up==null)
        {
            return "";
        }

        boolean isEmail = (possibleId.indexOf('@')>0);
        if (isEmail)
        {
            String testOpenId = up.getOpenId();
            if (testOpenId!=null)
            {
                return testOpenId;
            }
        }
        else
        {
            String testEmail = up.getPreferredEmail();
            if (testEmail!=null)
            {
                return testEmail;
            }
        }
        return "";
    }

    public String getAllQueryParams(HttpServletRequest req)
    throws Exception
    {
        String qs = "";
        Enumeration<String> en = req.getParameterNames();
        if(en.hasMoreElements()){
            qs = "?";
        }
        for (int i=0; en.hasMoreElements(); i++)
        {
            String key = (String)en.nextElement();
            String value = req.getParameter(key);
            if (value == null) value = "";
            qs = qs + ((i>0)? "&" : "") + key + "=" + SectionUtil.encodeURLData(value);
        }
        return qs;
    }

    public static String pasreFullname(String fullNames) throws Exception {
        String assigness = "";
        String[] fullnames = UtilityMethods.splitOnDelimiter(fullNames, ',');
        for(int i=0; i<fullnames.length; i++){
            String fname = fullnames[i];
            int bindx = fname.indexOf('<');
            int length = fname.length();
            if(bindx > 0){
                fname = fname.substring(bindx+1,length-1);
            }
            assigness = assigness + "," + fname;

        }
        if(assigness.startsWith(",")){
            assigness = assigness.substring(1);
        }
        return assigness;
    }


    private String getShortName(String name, int maxsize) {
        if (name.endsWith("/")) {
            name = name.substring(0, name.length() - 1);
        }
        if (name.length() > maxsize) {
            name = name.substring(0, maxsize - 3) + "...";
        }

        return name;

    }

    /**
    * Creates a title attribute of a HTML element only if the name is longer than
    * a specified amount.
    */
    private void writeTitleAttribute(AuthRequest ar, String name, int maxsize) throws Exception {
        if (name.endsWith("/")) {
            name = name.substring(0, name.length() - 1);
        }
        if (name.length() > maxsize) {
            ar.write(" title=\"");
            ar.writeHtml(name);
            ar.write("\"");
        }
    }


    private void displayHeader(AuthRequest ar, ResourceEntity ent, NGPage page)throws Exception {

        ConnectionType cType = ent.getConnection();
        String  cSetID = cType.getConnectionId();

        //first link is to the 'home' where you get a list of all your connections
        ar.write("\n<div class=\"pageSubHeading\">");
        if(page==null){
            ar.write("<a href=\"");
            String userHomePath = ar.retPath+"v/"+ar.getUserProfile().getKey()+"/userProfile.htm?active=3";
            ar.writeHtml(userHomePath);
            ar.write("\">Connections</a>&nbsp;&nbsp;&gt;&nbsp;&nbsp;");
        }

        //second link is to the connection you are looking at currently
        String dlink = ar.retPath + "v/"+ ar.getUserProfile().getKey() + "/folder"+cSetID
                +".htm?path=%2F&encodingGuard=%E6%9D%B1%E4%BA%AC";
        ar.write("  <a href=\"");
        ar.writeHtml(dlink);
        ar.write("\">");
        ar.writeHtml(cType.getDisplayName());
        ar.write("</a>");

        //Now make a chain of links to all folders containing this one
        createFolderLinks(ar, ent);
        ar.write("</div>");
    }


    //Recursive routine to handle variable number of parent folders
    private void createFolderLinks(AuthRequest ar, ResourceEntity ent) throws Exception
    {
        ResourceEntity parent = ent.getParent();
        if (parent!=null) {
            createFolderLinks(ar, parent);
            String dlink = ar.retPath + "v/"+ ar.getUserProfile().getKey() + "/folder"+ent.getFolderId()
                +".htm?path=" + URLEncoder.encode(ent.getPath()+"/", "UTF-8")
                +"&encodingGuard=%E6%9D%B1%E4%BA%AC";
            ar.write("&nbsp;&nbsp;&gt;&nbsp;&nbsp;<a href=\"");
            ar.writeHtml(dlink);
            ar.write("\">");
            ar.writeHtml(ent.getDecodedName());
            ar.write("</a>");
        }
    }%>
