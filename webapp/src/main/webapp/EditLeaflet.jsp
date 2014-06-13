<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AttachmentRecord"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.DOMFace"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.SectionComments"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionTask"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Must be logged in to make any changes to a project.");

    String p = ar.reqParam("p");
    String oid = ar.defParam("oid", "Create");
    int visibility = DOMFace.safeConvertInt(ar.defParam("viz", "2"));
    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    if (ngp.isDeleted())
    {
        throw new Exception("This page has been deleted, and can not be edited.  If you want to change this page contents, first 'un-delete' the page (Admin) and then you can edit the sections");
    }
    ar.setPageAccessLevels(ngp);
    ar.assertMember("You must be a member of the project in order to create or edit notes.");

    ngb = ngp.getSite();
    pageTitle = ngp.getFullName();%>

<%@ include file="Header.jsp"%>

<%
    ar.write("\n <div class=\"pagenavigation\"> ");
    ar.write("\n     <div class=\"pagenav\"> ");
    ar.write("\n         <h3 class=\"left\">");
    ar.write("<b>Edit &raquo; Note</b>");
    ar.write("</h3> ");

    ar.write("\n         <div class=\"section_date right\"></div> ");
    ar.write("\n         <div class=\"clearer\">&nbsp;</div> ");
    ar.write("\n     </div> ");

    ar.write("\n     <div class=\"pagenavigation\"> ");

    String sectionValue = "";
    String subject = "";
    String action = ar.defParam("action", "Create");
    boolean ownerEditOnly = false;
    Long effDate = ar.nowTime;
    String choices = "";
    long pinOrder = 0;
    if("Edit".equals(action) && !"Create".equals(oid))
    {
        NoteRecord cr = ngp.getNoteOrFail(oid);
        sectionValue = cr.getData();
        subject = cr.getSubject();
        visibility = cr.getVisibility();
        ownerEditOnly = !(cr.getEditable()==2);
        effDate = cr.getEffectiveDate();
        choices = cr.getChoices();
        pinOrder = cr.getPinOrder();
    }

    String secName = "Comments";
    ar.write("<form action=\"");
    ar.write(ar.retPath);
    ar.write("EditLeafletAction.jsp\" method=\"POST\">");

    //encoding guard puts a known value into the page, so that when it returns
    //we can be sure that the hosting TomCat container is decoded correctly.
    ar.write("<input type=\"hidden\" name=\"encodingGuard\" value=\"");
    ar.writeHtml("\u6771\u4eac");  //equals Tokyo in Kanji
    ar.write("\"/>\n");

    ar.write("<input type=\"hidden\" name=\"p\" value=\"");
    ar.writeHtml(ngp.getKey());
    ar.write("\"/>");
    ar.write("<input type=\"hidden\" name=\"s\" value=\"");
    ar.writeHtml("Comments");
    ar.write("\"/>");
    ar.write("<input type=\"hidden\" name=\"oid\" value=\"");
    ar.writeHtml(oid);
    ar.write("\"/>");

    ar.write("<input type=\"submit\" name=\"action\" value=\"Save and Continue Editing\"/>");

    ar.write("\n<input type=\"submit\" name=\"action\" value=\"Close (without saving)\"/>");
    ar.write(" or to delete note: ");
    ar.write("\n<input type=\"submit\" name=\"action\" value=\"Remove\"/>");
    ar.write("\n<input type=\"hidden\" name=\"section\" value=\"");
    ar.writeHtml(secName);
    ar.write("\"/>");
    ar.write("\n<br/>");
    ar.write("\nSubject:<br/>");
    ar.write("\n<input type=\"text\" name=\"subj\" size=\"67\" value=\"");
    ar.writeHtml(subject);
    ar.write("\"/>");
    ar.write("\n<br/>");
    ar.write("\nBody:<br/>");
    ar.write("\n<textarea name=\"val\" cols=\"60\" rows=\"15\">");
    ar.writeHtml(sectionValue);
    ar.write("</textarea>");
    ar.write("\n<br/>\nNote can be seen by: ");
    ar.write("\n<input type=\"radio\" name=\"visibility\" value=\"1\"");
    if (visibility==1)
    {
        ar.write(" checked=\"checked\"");
    }
    ar.write("/> Public ");
    ar.write("\n<input type=\"radio\" name=\"visibility\" value=\"2\"");
    if (visibility!=1 && visibility!=3 && visibility!=4)
    {
        ar.write(" checked=\"checked\"");
    }
    ar.write("/> Member ");
    ar.write("\n<input type=\"radio\" name=\"visibility\" value=\"4\"");
    if (visibility==4)
    {
        ar.write(" checked=\"checked\"");
    }
    ar.write("/> Private ");
    if (ngp.secondaryPermission(ar.getUserProfile()))    //if you are administrator
    {
        ar.write("\n<input type=\"radio\" name=\"visibility\" value=\"3\"");
        if (visibility==3)
        {
    ar.write(" checked=\"checked\"");
        }
        ar.write("/> Admin ");
    }
    ar.write("\n<br/>\nNote can be edited by: ");
    ar.write("\n<input type=\"radio\" name=\"editable\" value=\"1\"");
    if (ownerEditOnly)
    {
        ar.write(" checked=\"checked\"");
    }
    ar.write("/> Only You ");
    ar.write("\n<input type=\"radio\" name=\"editable\" value=\"2\"");
    if (!ownerEditOnly)
    {
        ar.write(" checked=\"checked\"");
    }
    ar.write("/> Any Project Member ");
    ar.write("\n<br/>\nEffective Date: ");
    ar.write("<input type=\"text\" name=\"effDate\" id=\"effDate\" ");
    ar.write("size=\"20\" value=\"");
    SectionUtil.nicePrintDate(ar.w, effDate);
    ar.write("\" readonly=\"1\" /><img src=\"jscalendar/img.gif\" ");
    ar.write("id=\"btn_effDate\" style=\"cursor: pointer;\" ");
    ar.write("title=\"Date selector\"/>");
    ar.write("  Pin Position: ");
    ar.write("<input type=\"text\" name=\"pin\" value=\"");
    ar.write(Long.toString(pinOrder));
    ar.write("\">");
    SectionTask.plugInCalenderScript(ar.w, "effDate", "btn_effDate");
%>
    <br/>
    Choices:<br/>
    <input type="text" name="choices" size="67" value="<%ar.writeHtml(choices);%>"/>
    <br/>
    <h3>Attachments</h3>

    <%
    int i=0;
    for (AttachmentRecord att : ngp.getAllAttachments())
    {
        String niceName = att.getNiceName();
        %><input type="checkbox" name="attach<%=++i%>" value="<% ar.writeHtml(niceName); %>"><%
        if (niceName.length()>30)
        {
            niceName = niceName.substring(0,30)+"...";
        }
        ar.writeHtml(niceName);
        %><br/><%
    }


    %>

    </form>
    <%
    ar.write("\n         <div class=\"pagenav\"> ");
    ar.write("\n             <div class=\"content\"> ");
    ar.write("\n                 <div class=\"left\"> ");
    ar.write("\n                 </div> ");
    ar.write("\n                 <div class=\"right\"> ");
    ar.write("\n                 </div> ");
    ar.write("\n                 <div class=\"clearer\">&nbsp;</div> ");
    ar.write("\n             </div> ");
    ar.write("\n         </div> ");
    ar.write("\n     </div> ");
    ar.write("\n </div> ");

    ar.flush();

%>

<%@ include file="FooterNoLeft.jsp"%>
<%@ include file="functions.jsp"%>
