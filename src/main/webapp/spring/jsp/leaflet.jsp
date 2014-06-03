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
%><%@ include file="/spring/jsp/functions.jsp"
%><%@page import="org.socialbiz.cog.AccessControl"
%><%/*
Required parameter:

    1. pageId : This is the id of a Project and used to retrieve NGPage.
    2. lid    : This is id which is used here to get detail of note (NoteRecord).

*/

    String p   = ar.reqParam("pageId");
    String lid = ar.reqParam("lid");%><%!String pageTitle="";%><%ngp = NGPageIndex.getContainerByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    UserProfile uProf = ar.getUserProfile();

    ngb = ((NGPage)ngp).getSite();

    NoteRecord note = ngp.getNoteOrFail(lid);

    boolean canAccessNote  = AccessControl.canAccessNote(ar, ngp, note);

    String choices = note.getChoices();
    String[] choiceArray = splitOnDelimiter(choices, ',');

    pageTitle = ngp.getFullName()+": "+note.getSubject();

    int allowedLevel = note.getVisibility();
    String mnnote = ar.defParam("emailId", null);%>
<body class="yui-skin-sam">
<%
    if(canAccessNote){

        writeOneLeaflet(ngp, ar, allowedLevel,note);
        if( !note.isDeleted()){
            if (choiceArray.length>0 && (ar.isLoggedIn() || mnnote != null))
            {
                UserProfile up = ar.getUserProfile();
        String userId = "";
        LeafletResponseRecord llr = null;
        if(up == null){
            userId = ar.reqParam("emailId");
            up = UserManager.findUserByAnyId(userId);
        }else{
            userId = up.getUniversalId();
        }
                if (up!=null) {
                    llr = note.getOrCreateUserResponse(up);
                }
                else {
                    //this is for the case that an invite was sent to someone who has
                    //never made a profile.
                    llr = note.accessResponse(userId);
                }

        String data = llr.getData();

%>

        <form method="post" action="leafletResponse.htm">
            <input type="hidden" name="lid" value="<% ar.writeHtml(lid); %>">
            <input type="hidden" name="uid" value="<% ar.writeHtml(userId); %>">
            <input type="hidden" name="mnnote" value="<% ar.writeHtml(mnnote); %>">
            <input type="hidden" name="go" value="<% ar.writeHtml(ar.getCompleteURL()); %>">

            <br><br>
            <div class="generalContent">

                <div class="generalHeading">Your Response</div>

                <table cellpadding="0" cellspacing="0" width="100%">
                    <tr><td style="height:5px" colspan="3"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2">Choice:</td>
                        <td style="width:20px;"></td>
                        <td>
                            <%
                            for (String ach : choiceArray)
                                {
                                    String isChecked = "";
                                    if (ach.equals(llr.getChoice())) {
                                        isChecked = " checked=\"checked\"";
                                    }
                                    %>
                                    <input type="radio" name="choice"<%ar.writeHtml(isChecked);%> value="<%
                                    ar.writeHtml(ach);
                                    %>"> <%
                                    ar.writeHtml(ach);
                                    %> &nbsp; <%
                                }
                            %>
                        </td>
                    </tr>
                    <tr><td style="height:8px" colspan="3"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2" valign="top">Response:</td>
                        <td style="width:20px;"></td>
                        <td>
                              <textarea name="data" class="textAreaGeneral" rows="4"><% ar.writeHtml(data); %></textarea>
                          </td>
                    </tr>
                    <tr><td style="height:8px" colspan="3"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2"></td>
                        <td style="width:20px;"></td>
                        <td>
                          <input class="inputBtn" type="submit" name="action" value="Update">
                        </td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2"></td>
                        <td style="width:20px;"></td>
                        <td>
                          <i>You can change your response at any time by visiting this page again.</i>
                        </td>
                    </tr>
                </table>
            <%
            }
            %>
            </form>
            <br><br>

            <div class="generalHeading">Responses</div>
            <table cellpadding="0" cellspacing="0" width="100%">
                <tr><td style="height:5px" colspan="3"></td></tr>
            <%
            Vector<LeafletResponseRecord> recs = note.getResponses();
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
                %><tr><td  width="180px" valign="top">
                <%
                }else{
                %>

                 <tr><td valign="top">
                <%}
                ale.writeLink(ar);
                %></td><td><b><%
                ar.writeHtml(choice);
                %></b> - <%
                SectionUtil.nicePrintTime(out, llr.getLastEdited(), ar.nowTime);
                %><br/><%
                WikiConverter.writeWikiAsHtml(ar,llr.getData());
                %></td></tr>
                <%
            }

            %>
            </table>
            <br><br>

            <div class="generalHeading">Totals</div>
            <table cellpadding="0" cellspacing="0" width="100%">
                <tr><td style="height:5px" colspan="3"></td></tr>
                <%
                for (String ach : choiceArray)
                {
                    int val = 0;
                    Integer tot = (Integer) choiceTotals.get(ach);
                    if (tot!=null)
                    {
                        val=tot.intValue();
                    }
                    %>
                    <tr><td width="180px"><b><%
                    ar.writeHtml(ach);
                    %>:</b></td>
                    <td> <%ar.writeHtml(String.valueOf(val));%></td>
                    </tr>
                <%
                }
                %>
            </table>
            <br><br>

            <div class="generalHeading">History</div>
            <table >
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td>
                    <%
                        List<HistoryRecord> histRecs = ngp.getAllHistory();
                        for (HistoryRecord hist : histRecs)
                        {
                            if (hist.getContextType()==HistoryRecord.CONTEXT_TYPE_LEAFLET
                                && lid.equals(hist.getContext()))
                            {
                                AddressListEntry ale = new AddressListEntry(hist.getResponsible());
                                UserProfile responsible = ale.getUserProfile();
                                String photoSrc = ar.retPath+"assets/photoThumbnail.gif";
                                if(responsible!=null && responsible.getImage().length() > 0){
                                    photoSrc = ar.retPath+"users/"+responsible.getImage();
                                }
                                %>
                                <tr>
                                     <td class="projectStreamIcons"><a href="#"><img src="<%=photoSrc%>" alt="" width="50" height="50" /></a></td>
                                     <td colspan="2"  class="projectStreamText">
                                         <%

                                         NGWebUtils.writeLocalizedHistoryMessage(hist, ngp, ar);
                                         ar.write("<br/>");
                                         SectionUtil.nicePrintTime(out, hist.getTimeStamp(), ar.nowTime);
                                         %>
                                     </td>
                                </tr>
                                <tr><td style="height:10px"></td></tr>
                                <%
                            }
                        }
                    %>
                    </td>
                </tr>
            </table>
        </div>
    <%
        }
    }else if (allowedLevel==SectionDef.MEMBER_ACCESS){
            %>
            <div class="generalArea">
                <div class="generalContent">
                  <br/>
                  In order to see a member note of the project, you need to be
                  logged in, and you need to be a member of the project.
                  <br/>
                  <br/>
                  <br/>
                  <br/>
                </div>
            </div>
            <%
    }else if (allowedLevel!=SectionDef.PUBLIC_ACCESS && !ngp.primaryOrSecondaryPermission(ar.getUserProfile()))
    {
        %>
            <div class="generalContent">
                In order to see a member note of the project,
                you need to be a member of the project.
                User '<% ar.getUserProfile().writeLink(ar); %>' is not a member.
                You can request membership, and if approved, you will then
                be able to access this information.<br/>
            </div>
        <%
    }

    out.flush();
%>
</body>
</div>

