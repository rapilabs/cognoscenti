<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AddressListEntry"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.BaseRecord"
%><%@page import="org.socialbiz.cog.EmailSender"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.LeafletResponseRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.NGSection"
%><%@page import="org.socialbiz.cog.ProcessRecord"
%><%@page import="org.socialbiz.cog.SectionComments"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.GoalRecord"
%><%@page import="org.socialbiz.cog.UserManager"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.StringWriter"
%><%@page import="java.util.ArrayList"
%><%@page import="java.util.List"
%><%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't send email.");

    String go = ar.reqParam("go");
    String action = ar.reqParam("action");
    String p = ar.reqParam("p");
    String msg = ar.reqParam("msg");
    String emailto = ar.defParam("emailto", null);
    boolean pagemem = (ar.defParam("pagemem", null)!=null);
    boolean assignees = (ar.defParam("assignees", null)!=null);
    boolean tempmem = (ar.defParam("tempmem", null)!=null);

    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    Vector<AddressListEntry> sendTo = new Vector<AddressListEntry>();
    String thisPageAddress = ar.getResourceURL(ngp,"process.htm");
    String subject = "Goals for: "+ngp.getFullName();

    if (action.equals("Send Mail"))
    {
        StringWriter bodyWriter = new StringWriter();
        AuthRequest clone = ar.getNestedRequest("", bodyWriter);
        clone.retPath = ar.baseURL;

        if (pagemem)
        {
            appendUsersF(clone, ngp.getPrimaryRole().getExpandedPlayers(ngp), sendTo);
            appendUsersF(clone, ngp.getSecondaryRole().getExpandedPlayers(ngp), sendTo);
        }

        if (emailto!=null && emailto.length()>0)
        {
            clone.write("<br/>\nAdditionally: ");
            Vector<AddressListEntry> v2 = EmailSender.parseAddressList(emailto);
            appendUsersF(clone, v2, sendTo);
        }

        clone.write("<html><head>");
        clone.write("\n<link rel=\"stylesheet\" type=\"text/css\" media=\"screen\" href=\"");
        clone.write(clone.retPath);
        clone.write("plain.css\"  />");
        clone.write("\n</head><body><p>");
        clone.writeHtml(msg);
        clone.write("\n</p>");


        ProjectTasksEmailBody(clone, ngp, 1, thisPageAddress, 1);
        Vector addressOnly = new Vector();
        clone.write("\n<p></p>");
        writeUsers(clone, sendTo, addressOnly);
        clone.write("</body></html>");

        EmailSender.quickEmail(addressOnly, null, subject, bodyWriter.toString());

        Enumeration e3 = addressOnly.elements();
        StringBuffer nameList = new StringBuffer();
        while (e3.hasMoreElements())
        {
            String addr = (String) e3.nextElement();
            nameList.append(addr);
            if (e3.hasMoreElements())
            {
                nameList.append(", ");
            }
        }

        //OK, done, so write history about it
        HistoryRecord.createHistoryRecord(ngp,
                ngp.getKey(), HistoryRecord.CONTEXT_TYPE_PROCESS,
                HistoryRecord.EVENT_EMAIL_SENT, ar, nameList.toString());
    }

    response.sendRedirect(go);

%>
<%@ include file="functions.jsp"%>
<%@ include file="ProjectTasksEmailFormatter.jsp"%>
<%!



public void appendUsersF(AuthRequest clone, List<AddressListEntry> members, Vector collector)
    throws Exception
{
    for (AddressListEntry ale : members)
    {
        Enumeration e2 = collector.elements();
        boolean found = false;
        while (e2.hasMoreElements())
        {
            AddressListEntry coll = (AddressListEntry)e2.nextElement();
            if (coll.hasAnyId(ale.getUniversalId()))
            {
                found = true;
                break;
            }
        }
        if (!found)
        {
            collector.add(ale);
        }
    }
}


public void writeUsers(AuthRequest clone, Vector collector, Vector addressOnly)
    throws Exception
{
    clone.write("\n<p>This message sent to:");
    Enumeration e = collector.elements();
    while (e.hasMoreElements())
    {
        AddressListEntry ale = (AddressListEntry)e.nextElement();
        String email = ale.getEmail();
        ale.writeLink(clone);
        if (email!=null && email.length()>0)
        {
            addressOnly.add(email);
        }
        else
        {
            clone.write("(no email) ");
        }
    }
    clone.write("</p>");
}

%>
