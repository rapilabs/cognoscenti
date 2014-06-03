<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.Iterator"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.HistoryRecord"
%><%@page import="org.socialbiz.cog.NoteRecord"
%><%@page import="org.socialbiz.cog.LeafletResponseRecord"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.SectionComments"
%><%@page import="org.socialbiz.cog.SectionDef"
%><%@page import="org.socialbiz.cog.SectionFormat"
%><%@page import="org.socialbiz.cog.SectionUtil"
%><%@page import="org.socialbiz.cog.UserProfile"
%><%@page import="org.socialbiz.cog.WikiConverter"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.io.Writer"
%><%@page import="java.net.URLEncoder"
%><%@page import="java.util.Enumeration"
%><%@page import="java.util.Hashtable"
%><%@page import="java.util.Vector"
%><%@page import="org.w3c.dom.Element"
%><%@ include file="/spring/jsp/include.jsp"
%><%/*
Required parameter:

    1. p    : This is the id of a Project and used to retrieve NGPage.
    2. lid  : This is id which is used here to get detail of note (NoteRecord).

*/

    String p = ar.reqParam("p");
    String lid = ar.reqParam("lid");%><%!String pageTitle="";%>
<%
    ngp = NGPageIndex.getContainerByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    NoteRecord note = ngp.getNoteOrFail(lid);
    pageTitle = ngp.getFullName()+": "+note.getSubject();
    int allowedLevel = note.getVisibility();
%>
    <!-- Content Area Starts Here -->

<%
    if (!ar.isLoggedIn())
    {
        if (allowedLevel==SectionDef.PUBLIC_ACCESS)
        {
            writeOneLeaflet(ngp, ar, SectionDef.PUBLIC_ACCESS,note);
            String choices = note.getChoices();
            if (choices!=null && choices.length()>0)
            {
                ar.write("<h2>Please log in to enter a response, and to see other responses</h2>");
            }
        }
        else
        {
        %>
    <div class="generalArea">
        <div class="generalContent">
            <br/>
            In order to see the a member note of the site, you need to be
            logged in, and you need to be a executive of the site.
            <br/>
            <br/>
            <br/>
            <br/>
        </div>
    </div>
    <%
        }
    }
    else if (allowedLevel!=SectionDef.PUBLIC_ACCESS &&
             !ar.isMember())
    {
    %>
    <div class="generalContent">
    In order to see a member note for an site,
    you need to be an executive for the site.
    User '<% ar.getUserProfile().writeLink(ar); %>' is not a member.
    <br/>
    </div>
    <%
    }
    else
    {
        writeOneLeaflet(ngp, ar, allowedLevel,note);
        if (ar.isLoggedIn())
        {
            UserProfile up = ar.getUserProfile();
            LeafletResponseRecord llr = note.getOrCreateUserResponse(up);
            String choices = note.getChoices();
            String[] choiceArray = splitOnDelimiter(choices, ',');
            String data = llr.getData();
    %>

    <form method="post" action="leafletResponse.htm">
        <input type="hidden" name="lid" value="<% ar.writeHtml(lid); %>">
        <input type="hidden" name="uid" value="<% ar.writeHtml(up.getKey()); %>">
        <input type="hidden" name="go" value="<% ar.writeHtml(ar.getResourceURL(ngp,note)); %>">
        <table cellpadding="0" cellspacing="0" width="100%" class="gridTable">
            <tr class="gridTableHeader">
                <td colspan="2"><b>Your Response</b></td>
            </tr>
            <tr>
                <td class="gridTableColummHeader">Choice:</td>
                <td>
    <%
            for (String ach : choiceArray) {
                String isChecked = "";
                if (ach.equals(llr.getChoice())) {
                    isChecked = " checked=\"checked\"";
                }
    %>
                    <input type="radio" name="choice"<%ar.writeHtml(isChecked);%> value="<% ar.writeHtml(ach);%>"> <% ar.writeHtml(ach);%> &nbsp;
        <%
            }
        %>
                </td>
            </tr>
            <tr>
                <td class="gridTableColummHeader" valign="top">Response</td>
                <td>
                    <textarea name="data" cols="70" rows="2"><% ar.writeHtml(data); %></textarea>
                    <input class="inputBtn" type="submit" name="action" value="Update">
                </td>
            </tr>
        </table>
        <%
        }
        %>
    </form>
    <table cellpadding="0" cellspacing="0" width="100%" class="gridTable">
        <tr class="gridTableHeader">
            <td colspan="2"><b>Responses</b></td>
       </tr>
       <%
        Vector<AddressListEntry> recs = note.getResponses();
        Hashtable choiceTotals= new Hashtable();
        int count =0;

        for (LeafletResponseRecord llr : recs)
        {
            AddressListEntry ale = new AddressListEntry(llr.getUser());
            String choice = llr.getChoice();
            Integer tot = (Integer) choiceTotals.get(choice);
            if (tot==null)
            {
                tot = new Integer(1);
            }
            else
            {
                tot = new Integer( tot.intValue()+1 );
            }
            choiceTotals.put(choice, tot);
            if(count==0){
            %>
        <tr>
            <td  width="120px" valign="top">
            <%
            }else{
            %>
        <tr>
            <td valign="top">
            <%}
            ale.writeLink(ar);
            %>
            </td>
            <td><b><%
            ar.writeHtml(choice);
            %></b> - <%
            SectionUtil.nicePrintTime(out, llr.getLastEdited(), ar.nowTime);
            %><br/><%
            WikiConverter.writeWikiAsHtml(ar,llr.getData());
            %>
            </td>
        </tr>
        <%
        }
        %>
    </table>
    <table cellpadding="0" cellspacing="0" width="100%" class="gridTable">
        <tr class="gridTableHeader">
            <td colspan="2"><b>Totals</b></td>
        </tr>

        <%
        e = choiceTotals.keys();
        while (e.hasMoreElements())
        {
            String  choice = (String)e.nextElement();
            Integer tot = (Integer) choiceTotals.get(choice);
        %>
        <tr>
            <td width="120px"><b><%ar.writeHtml(choice);%>:</b></td>
            <td> <%ar.writeHtml(String.valueOf(tot.intValue()));%></td>
        </tr>
        <%
        }
        %>
    </table>
    <table cellpadding="0" cellspacing="0" width="100%" class="gridTable">
        <tr class="gridTableHeader">
            <td><b>History</b></td>
        </tr>
        <tr>
            <td>
                <ul class="bulletLinks"></ul>
            </td>
        </tr>
    </table>
    <%
    }
    out.flush();
    %>
    <div class="seperator">&nbsp;</div>
    <div id="loginArea">
        <span class="black"><%writeMembershipStatus(ngp, ar);%></span>
    </div>
<%@ include file="logininfoblock.jsp"%>
<%@ include file="/spring/jsp/functions.jsp"%>
