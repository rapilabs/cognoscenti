<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AddressListEntry"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.AuthDummy"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.NoteRecord"
%><%@page import="org.socialbiz.cog.LeafletResponseRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.SectionComments"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.StringWriter"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.List"
%><%AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't send email.");
    ar.setTomcatKludge();

    String go = ar.reqParam("go");
    String action = ar.reqParam("action");
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

    NoteRecord leaflet = null;
    if (!oid.equals("x"))
    {
        //Note: an oid of 'x' means that there is NO note attached, but instead
        //we are sending only documents.
        leaflet = ngp.getNoteOrFail(oid);
    }


    StringBuffer outParams = new StringBuffer();
    outParams.append("?p=");
    outParams.append(URLEncoder.encode(p, "UTF-8"));
    outParams.append("&oid=");
    outParams.append(URLEncoder.encode(oid, "UTF-8"));
    outParams.append("&note=");
    outParams.append(URLEncoder.encode(note, "UTF-8"));
    outParams.append("&go=");
    outParams.append(URLEncoder.encode(go, "UTF-8"));
    outParams.append("&encodingGuard=");
    outParams.append(URLEncoder.encode("\u6771\u4eac", "UTF-8"));
    if (pagemem)
    {
        outParams.append("&pagemem=true");
    }
    if (bookmem)
    {
        outParams.append("&bookmem=true");
    }
    if (exclude)
    {
        outParams.append("&exclude=true");
    }
    if (tempmem)
    {
        outParams.append("&tempmem=true");
    }
    if (includeBody)
    {
        outParams.append("&includeBody=true");
    }
    if (emailto!=null)
    {
        outParams.append("&emailto=");
        outParams.append(URLEncoder.encode(emailto, "UTF-8"));
    }
    for (AttachmentRecord att : ngp.getAllAttachments())
    {
        String paramId = "attach"+att.getId();
        String attParam = ar.defParam(paramId, null);
        if (attParam!=null)
        {
            outParams.append("&");
            outParams.append(paramId);
            outParams.append("=true");
        }
    }

    if (action.equals("Edit Mail"))
    {
        response.sendRedirect(ar.retPath+"CommentEmail.jsp"+outParams.toString());
        return;
    }
    if (action.equals("Preview Mail"))
    {
        response.sendRedirect(ar.retPath+"CommentEmailPreview.jsp"+outParams.toString());
        return;
    }
    if (action.equals("Send Mail"))
    {
        throw new Exception("Send Mail in old UI not supported");
    }

    response.sendRedirect(go);%><%@ include file="functions.jsp"%>
