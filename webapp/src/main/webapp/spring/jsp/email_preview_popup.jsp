<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.NoteRecord"
%><%@page import="org.socialbiz.cog.NGContainer"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="org.socialbiz.cog.spring.MainTabsViewControler"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%@ include file="/spring/jsp/include.jsp"
%><%/*
Required parameter:

    1. p    : This is the id of a Project and used to retrieve NGPage.
    2. oid  : This is Leaflet id which is used to retieve Leaflet information which is being send
               by email (NoteRecord object).

Optional Parameter:

    1. note         :
    2. includeBody  : Option if we want to include note as body.
    3. emailto      :
    4. toRole       :


*/

    String p = ar.reqParam("p");
    String oid = ar.reqParam("oid");
    String note = ar.defParam("note", "Sending this note to let you know about a recent update to this web page has information that is relevant to you.  Follow the link to see the most recent version.");
    String includeBodyStr = ar.defParam("includeBody", null);
    String emailto = ar.defParam("emailto", null);
    String toRole = ar.defParam("toRole", null);
    String encodingGuard  = ar.reqParam("encodingGuard");
    if (!"\u6771\u4eac".equals(encodingGuard)) {
        throw new Exception("values are corrupted");
    }%><%!String pageTitle="";%>
<%
    boolean pagemem = (ar.defParam("pagemem", null)!=null);
    boolean bookmem = (ar.defParam("bookmem", null)!=null);
    boolean exclude = (ar.defParam("exclude", null)!=null);
    boolean includeBody=false;

    if(includeBodyStr!=null && includeBodyStr.equals("true")){
        includeBody=true;
    }

    pageTitle  ="Send Note By Mail";
    NGContainer ngp = NGPageIndex.getContainerByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ar.assertMember("Can not send email.");
    String subject = ar.defParam("subject", "Documents from Project "+ngp.getFullName());
    NoteRecord cr = null;
    if (!oid.equals("x"))
    {
        cr = ngp.getNoteOrFail(oid);
        if(subject==null || subject.trim().equals("")){
    subject = "Leaflet Note";
        }
        String body = cr.getData();
    }

    Vector sendTo = new Vector();

    if (pagemem)
    {
        NGWebUtils.appendUsersFromRole(ngp, "Members", sendTo);
        NGWebUtils.appendUsersFromRole(ngp, "Administrators", sendTo);
    }

    if (bookmem)
    {
        NGWebUtils.appendUsersFromRole(ngp, "Executives", sendTo);
    }
    if(toRole!=null && toRole.length()>0){
        String[] sentToRole = UtilityMethods.splitOnDelimiter(toRole, ',');
        for(int i=0; i<sentToRole.length; i++){
    String roleName = sentToRole[i];
    NGRole role = ngp.getRole(roleName);
    if (role!=null)
    {
        NGWebUtils.appendUsersFromRole(ngp, roleName, sendTo);
    }
        }
    }

    if (emailto!=null && emailto.length()>0)
    {
        List<AddressListEntry> v2 = AddressListEntry.parseEmailList(emailto);
        NGWebUtils.appendUsers(v2, sendTo);
    }

    UserProfile upx = ar.getUserProfile();
    AddressListEntry sampleUser = new AddressListEntry(upx);
    List roles = ngp.getAllRoles();
%>

    <link href="<%=ar.baseURL%>css/reset.css" rel="styleSheet" type="text/css" media="screen" />
    <link href="<%=ar.baseURL%>css/global.css" rel="styleSheet" type="text/css" media="screen" />
    <link href="<%=ar.baseURL%>css/body.css" rel="styleSheet" type="text/css" media="screen" />
    <link href="<%=ar.baseURL%>css/tables.css" rel="styleSheet" type="text/css" media="screen" />
    <link rel="stylesheet" type="text/css" media="all" href="<%=ar.baseURL%>datatable.css"/>
<head>
    <script type="text/javascript">
        function sendMail() {
            var formEmail = window.opener.document.getElementById('emailForm');
            formEmail.action.click();
            window.close();
        }
    </script>
</head>
<body>
    <!--  here is where the content goes -->
    <div class="generalArea">
        <%
        //ar.write(anyErrors);
        //ar.write("<br/>");
        %>
        <div class="generalContent">
            <table width="700"><tr><td>
            <form action="<%=ar.baseURL%>t/CommentEmailAction.form" method="post" enctype="application/x-www-form-urlencoded; charset=utf-8">
                <input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
                <input type="hidden" name="p"       value="<%ar.writeHtml(p);%>"/>
                <input type="hidden" name="oid"     value="<%ar.writeHtml(oid);%>"/>
                <input type="hidden" name="go"      value="<%ar.writeHtml(ar.retPath+"closeWindow.jsp");%>"/>
                <input type="hidden" name="emailto" value="<%ar.writeHtml(emailto);%>"/>
                <input type="hidden" name="note"    value="<%ar.writeHtml(note);%>"/>
                <%
                if (pagemem)
                {
                    ar.write("\n<input type=\"hidden\" name=\"pagemem\" value=\"true\">");
                }
                if (bookmem)
                {
                    ar.write("\n<input type=\"hidden\" name=\"bookmem\" value=\"true\">");
                }
                if (exclude)
                {
                    ar.write("\n<input type=\"hidden\" name=\"exclude\" value=\"true\">");
                }
                if (toRole!=null && toRole.length()>0)
                {
                    ar.write("\n<input type=\"hidden\" name=\"toRole\" value=\"");
                    ar.writeHtml(toRole);
                    ar.write("\">");
                }
                if (includeBody)
                {
                    ar.write("\n<input type=\"hidden\" name=\"includeBody\" value=\"true\">");
                }
                if (emailto!=null)
                {
                    ar.write("\n<input type=\"hidden\" name=\"emailto\" value=\"");
                    ar.writeHtml(emailto);
                    ar.write("\">");
                }
                if (subject!=null)
                {
                    ar.write("\n<input type=\"hidden\" name=\"subject\" id=\"subject\" value=\"");
                    ar.writeHtml(subject);
                    ar.write("\">");
                }
                for (AttachmentRecord att : ngp.getAllAttachments())
                {
                    String paramId = "attach"+att.getId();
                    String attParam = ar.defParam(paramId, null);
                    if (attParam!=null)
                    {
                        ar.write("\n<input type=\"hidden\" name=\"");
                        ar.write(paramId);
                        ar.write("\" value=\"true\">");
                    }
                }
               %>
                <div style="float:right">
                    <input type="submit" name="action" id="action"  value="Send Mail" class="inputBtn" />
                    <input type="submit" name="action" id="action" class="inputBtn" value="Edit Mail" />
                </div>
                <div>
                    <b>Subject:</b> <% ar.writeHtml(subject); %>
                </div>
                <div>
                    <br><br><br>
                <%MainTabsViewControler.writeNoteAttachmentEmailBody(ar, ngp, cr, true, sampleUser, note,
                    includeBody, NGWebUtils.getSelectedAttachments(ar, ngp));%>
                </div>
            </form>
            </td></tr></table>
        </div>
    </div>
</body>
