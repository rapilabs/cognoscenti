<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NoteRecord"
%><%@page import="org.socialbiz.cog.SectionComments"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can not send email.");
    ar.setTomcatKludge();

    String go = ar.defParam("go", "closeWindow.htm");
    String p = ar.reqParam("p");
    String oid = ar.reqParam("oid");
    String emailto = ar.defParam("emailto", null);
    String note = ar.defParam("note", "");

    boolean pagemem = (ar.defParam("pagemem", null)!=null);
    boolean bookmem = (ar.defParam("bookmem", null)!=null);
    boolean exclude = (ar.defParam("exclude", null)!=null);
    boolean tempmem = (ar.defParam("tempmem", null)!=null);
    boolean includeBody = (ar.defParam("includeBody", null)!=null);

    assureNoParameter(ar, "s");

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    ar.assertMember("Can not send email.");

    pageTitle = "Preview Email: "+ngp.getFullName();

    NoteRecord cr = null;
    String subject = "Documents from Project "+ngp.getFullName();
    if (!oid.equals("x"))
    {
        cr = ngp.getNoteOrFail(oid);
        subject = cr.getSubject();
    }

    UserProfile upx = ar.getUserProfile();
    AddressListEntry sampleUser = new AddressListEntry(upx);


    Vector<AddressListEntry> sendTo = new Vector<AddressListEntry>();

    if (pagemem)
    {
        appendUsersF(ngp.getPrimaryRole().getExpandedPlayers(ngp), sendTo);
        appendUsersF(ngp.getSecondaryRole().getExpandedPlayers(ngp), sendTo);
    }

    if (bookmem)
    {
        NGBook ngb = ngp.getSite();
        appendUsersF(ngb.getPrimaryRole().getExpandedPlayers(ngb), sendTo);
    }

    if (emailto!=null && emailto.length()>0)
    {
        List<AddressListEntry> v2 = new ArrayList<AddressListEntry>();
        String[] values = UtilityMethods.splitOnDelimiter(emailto, ',');
        for (int i=0; i<values.length; i++)
        {
            //in the case where you get a single space character, split will return
            //one value (just space) and trim will remove white space.  Avoid that
            //leftover string.  Similar problem if comma is last thing on line.
            String oneAddre = values[i].trim();
            if (oneAddre.length()>0)
            {
                v2.add(new AddressListEntry(oneAddre));
            }
        }
        appendUsersF(v2, sendTo);
    }%>

<%@ include file="Header.jsp"%>

<!--  here is where the content goes -->


<table width="600">
<col width="130">
<col width="470">

<form action="CommentEmailAction.jsp" method="post">
<tr>
  <td>
  </td>
  <td>
    <input type="hidden" name="encodingGuard" value="<%ar.writeHtml("\u6771\u4eac");%>"/>
    <input type="hidden" name="p"       value="<%ar.writeHtml(p);%>"/>
    <input type="hidden" name="oid"     value="<%ar.writeHtml(oid);%>"/>
    <input type="hidden" name="go"      value="closeWindow.htm"/>
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
    if (tempmem)
    {
        ar.write("\n<input type=\"hidden\" name=\"tempmem\" value=\"true\">");
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
    <input type="submit" name="action"  value="Edit Mail"/> &nbsp;
    <input type="submit" name="action"  value="Send Mail"/> &nbsp;
  </td>
</tr>
</form>
<tr>
  <td>
    From:
  </td>
  <td>
    <b><%ar.writeHtml(composeFromAddress(ngp));%></b>
  </td>
</tr>
<tr>
  <td>
    To:
  </td>
  <td>
<%
    for (AddressListEntry ale : (Vector<AddressListEntry>) sendTo)
    {
        ale.writeLink(ar);
        ar.write(" &nbsp; ");
    }
%>
  </td>
</tr>
<tr>
  <td>
    Subject:
  </td>
  <td>
    <b><%ar.writeHtml(subject);%></b>
  </td>
</tr>
<tr>
  <td colspan="2">
    <hr/>
  </td>
</tr>
</form>
<tr>
  <td></td>
  <td>
    <%writeLeafletEmailBody(ar, ngp, cr, true, sampleUser, note, includeBody);%>
  </td>
</tr>
</table>

<br/>
<%@ include file="FooterNoLeft.jsp"%>
<%@ include file="functions.jsp"%>
