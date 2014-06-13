<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.Date"
%><%@page import="java.text.SimpleDateFormat"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*
Required parameters:

    1. pageId   : This is the id of an Project and here it is used to retrieve NGPage.
    2. taskId   : This parameter is id of a task and here it is used to get current task detail (GoalRecord)
                  and to pass current task id value when submitted.

*/

    String pageId = ar.reqParam("pageId");
    String taskId = ar.reqParam("taskId");%><%!String pageTitle = "";%><%UserProfile uProf = ar.getUserProfile();

    NGPage ngp =(NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);

    ar.setPageAccessLevels(ngp);
    pageTitle = ngp.getFullName();

    GoalRecord currentTaskRecord = ngp.getGoalOrFail(taskId);

    List<HistoryRecord> histRecs = currentTaskRecord.getTaskHistory(ngp);%>
<script src="<%=ar.baseURL%>jscript/jquery.dd.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="<%=ar.retPath%>css/dd.css" />

<body class="yui-skin-sam">

    <!-- Content Area Starts Here -->
    <div class="generalArea">
        <div class="pageHeading">
            <img src="<%=ar.retPath %>/assets/images/tb_<%=BaseRecord.stateImg(currentTaskRecord.getState())%>" />
            <span style="color:#5377ac"> <%=BaseRecord.stateName(currentTaskRecord.getState())%> Activity:</span>
            <%ar.writeHtml(currentTaskRecord.getSynopsis());%>
        </div>

        <div class="pageSubHeading">
            <table>
                <tr>
                    <td valign="top">assigned to:&nbsp;&nbsp;
                    <%
                        List<AddressListEntry> allUsers = currentTaskRecord.getAssigneeRole().getDirectPlayers();
                        if (allUsers.size() != 0)
                        {
                    %>
                         <span style="color:red"><%allUsers.get(0).writeLink(ar);%></span>
                    <%  } %>
                    </td>
                    <td valign="top">&nbsp;&nbsp;&nbsp;&nbsp;
                        due date:
                        <span  id="top_btn_dueDate" style="color: red">
                        <%
                        if(currentTaskRecord.getDueDate()!=0){
                            ar.write(new SimpleDateFormat("MM/dd/yyyy").format(new Date(currentTaskRecord.getDueDate())));
                        }else{
                        %>
                        --
                        <%
                        }
                        %>
                        </span>
                        start date:
                         <span id="top_btn_dueDate" style="color: red">
                        <%
                        if(currentTaskRecord.getStartDate()!=0){
                            ar.write(new SimpleDateFormat("MM/dd/yyyy").format(new Date(currentTaskRecord.getStartDate())));
                        }else{ %>
                        --
                        <% }%>
                        </span>

                        end date:
                        <span  id="top_btn_dueDate" style="color: red">
                        <%
                        if(currentTaskRecord.getEndDate()!=0){
                            ar.write(new SimpleDateFormat("MM/dd/yyyy").format(new Date(currentTaskRecord.getEndDate())));
                        }else{
                        %>
                        --
                        <%
                        }
                        %>
                        </span>
                    </td>
                </tr>
            </table>
        </div>
        <div >
            <table width="100%">
                <tr><td height="25px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader" valign="top">
                        <fmt:message key="nugen.project.description.text"/>
                    </td>
                    <td style="width:20px;"></td>
                    <td valign="top">
                        <%ar.writeHtmlWithLines(currentTaskRecord.getDescription());%>
                    </td>
                </tr>

                <tr><td height="10px"></td></tr>

                <tr>
                    <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.status.text"/></td>
                    <td style="width:20px;"></td>
                    <td valign="top"><%=currentTaskRecord.getStatus() %></td>
                </tr>

                <tr><td height="10px"></td></tr>

                <tr>
                    <td class="gridTableColummHeader"><fmt:message key="nugen.process.state.text"/></td>
                    <td style="width:20px;"></td>
                    <td>
                        <%=BaseRecord.stateName(currentTaskRecord.getState())%>
                    </td>
                </tr>
                <tr><td height="20px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.Completed.text"/></td>
                    <td style="width:20px;"></td>
                    <td valign="top"><%=currentTaskRecord.getPercentComplete() %> %</td>
                </tr>
                <tr><td height="20px"></td></tr>
                <%
                if (histRecs.size()>0)
                {
                %>
                <tr>
                    <td colspan="3" class="generalHeading">Previous Accomplishments</td>
                </tr>
                <tr>
                    <td colspan="3" id="prevAccomplishments">
                        <table >
                            <tr><td style="height:10px"></td></tr>
                <%
                    int i=0;
                    for (HistoryRecord history : histRecs)
                    {
                        i++;
                        AddressListEntry ale = new AddressListEntry(history.getResponsible());
                        UserProfile responsible = ale.getUserProfile();
                        String photoSrc = ar.retPath+"assets/photoThumbnail.gif";
                        if(responsible!=null && responsible.getImage().length() > 0){
                            photoSrc = ar.retPath+"users/"+responsible.getImage();
                        }
                %>
                            <tr valign="top">
                                <td class="projectStreamIcons"><a href="#"><img src="<%=photoSrc%>" alt="" width="50" height="50" /></a></td>
                                <td colspan="2" class="projectStreamText">
                                    <%

                                    NGWebUtils.writeLocalizedHistoryMessage(history, ngp, ar);
                                    ar.write("<br/>");
                                    SectionUtil.nicePrintTime(out, history.getTimeStamp(), ar.nowTime);
                                    %>
                                </td>
                           </tr>
                           <tr><td style="height:10px"></td></tr>
                 <%
                    }
                 %>
                        </table>
                    </td>
                </tr>
            <%  } %>
            </table>
        </div>
    </div>
    </div>
</body>
