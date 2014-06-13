<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="UserProfile.jsp"
%><%

    ar.assertLoggedIn("Must be logged in to see anything about a user");

    UserProfile uProf = (UserProfile)request.getAttribute("userProfile");
    if (uProf == null) {
        throw new NGException("nugen.exception.cant.find.user",null);
    }

    UserProfile  operatingUser =ar.getUserProfile();
    if (operatingUser==null) {
        //this should never happen, and if it does it is not the users fault
        throw new ProgramLogicError("user profile setting is null.  No one appears to be logged in.");
    }

    boolean viewingSelf = uProf.getKey().equals(operatingUser.getKey());

%>
<script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/jquery.ui.js"></script>
<div class="content tab05" style="display:block;">
    <div class="section_body">
        <div class="pageHeading">
            Notifications Settings for <%
            ar.writeHtml(uProf.getName());
        %>
        </div>

        <div class="pageSubHeading">
            Below is a list of things you are subscribed to that might cause you to receive email.
            If you wish to avoid email in the future, you can unsubscribe to any of them below.
            <%
            if (!ar.isLoggedIn() && ar.hasSpecialSessionAccess("Notifications:"+uProf.getKey())) {
                ar.write("  Note, you are able to access this page because you used a special link from an email message that gives you acces to this page only.");
            }
        %>
        </div>
        <div style="height:10px;"></div>
        <div class="leafLetArea">
        <%
            String formId= "";
            int counter = 0;
            Vector<NGPageIndex> v = NGPageIndex.getProjectsUserIsPartOf(uProf);
            for(NGPageIndex ngpi : v){
                NGPage ngp = ngpi.getPage();

                if (ngp != null)
                {
        %>
                <div class="leafHeading" id="leafHeading<%ar.write(String.valueOf(counter));%>"
                    onMouseOver="this.style.backgroundColor='#fdf9e1'"
                    onMouseOut="this.style.backgroundColor='#f7f7f7'"
                    onclick="expandCollapseLeaflets('leafContent<%ar.write(String.valueOf(counter));%>','<%=ar.baseURL%>','leafHeading<%ar.write(String.valueOf(counter));%>')">
                    <table width="100%" cellpadding="0" cellspacing="0">
                        <tr>
                            <td id="leafHeading<%=counter%>_leafContent<%=counter%>">
                                <img src="<%=ar.baseURL%>assets/images/expandIcon.gif"
                                     name="img_leafContent<%=counter%>"
                                     id="img_leafContent<%=counter%>"
                                     border="0" />
                                &nbsp;&nbsp;<b>
                                <%
                                    String projectName = ngp.getFullName();
                                    if(ngp.getFullName().length() >= 100){
                                        projectName = projectName.substring(0,100)+"...";
                                    }
                                    ar.write(projectName);
                                %>
                                </b>
                                <a href="<%=ar.baseURL%>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey()%>/history.htm">
                                    <img height="15" width="15" alt="go to project" src="<%=ar.baseURL%>assets/images/iconGoInside.gif" />
                                </a>
                            </td>
                            <td></td>
                            <td class="leafNote"></td>
                        </tr>
                    </table>
                </div>
            <%
                formId = "notificationSettingsForm"+counter;
            %>
                <form id="<%=formId%>"
                    action="<%=ar.baseURL%>v/<%=uProf.getKey()%>/saveNotificationSettings.form" method="post">

                    <input type="hidden" id="pageId" name="pageId" value="<%ar.write(ngp.getKey());%>">
                    <%
                        boolean isNotified = uProf.isNotifiedForProject(ngp.getKey());
                    %>
                    <div class="leafContentArea" id="leafContent<%ar.write(String.valueOf(counter));%>" style="display:none">
                        <div class="notificationContent">
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <%
                                    if(isNotified){
                                %>
                                <tr>
                                    <td class="notificationSubHeading">Send me a digest of message activity:

                                        <select name="sendDigest" id="sendDigest" class="selectGeneralSmall">
                                            <option value="daily" <%if(isNotified){%>selected="selected" <%}%> >Daily</option>
                                            <option value="never" <%if(!isNotified){%>selected="selected" <%}%> >Never</option>
                                        </select>
                                    </td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>Digest is the email notification sent to the player only when any change
                                        occurs in the project. But this will not effect the email notification sent
                                        from the goals you are assigned with.
                                    </td>
                                </tr>
                                <tr><td style="height:30px;"></td></tr>
                                <%
                                    }
                                                            Vector<GoalRecord> activeTask = new Vector<GoalRecord>();
                                                            for(GoalRecord task : ngp.getAllGoals())
                                                            {
                                                                if ((!task.isAssignee(uProf)) && (!task.isReviewer(uProf)))
                                                                {
                                                                    continue;
                                                                }
                                                                int state = task.getState();
                                                                if(state == BaseRecord.STATE_ERROR)
                                                                {
                                                                    if (task.isAssignee(uProf)) {
                                                                        activeTask.add(task);
                                                                    }
                                                                }
                                                                else if(state == BaseRecord.STATE_ACCEPTED ||
                                                                          state == BaseRecord.STATE_STARTED ||
                                                                          state == BaseRecord.STATE_WAITING)
                                                                {
                                                                    if (task.isAssignee(uProf)) {
                                                                        activeTask.add(task);
                                                                    }

                                                                }
                                                                else if(state == BaseRecord.STATE_REVIEW)
                                                                {
                                                                    if (task.isNextReviewer(uProf))
                                                                    {
                                                                        activeTask.add(task);
                                                                    }
                                                                }
                                                            }
                                                            if(activeTask.size() > 0){
                                %>
                                <tr>
                                    <td class="notificationSubHeading">Email notifications related to goals & sub goals</td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>You are assigned to this goal, therefore, you are receiving related email notification.
                                        In order to stop these notifications, you can either "Mark As Completed" or "UnAssign"
                                        yourself. Further, if you wish to see the full details or want to edit the goal, you can
                                        directly go to the respective goal by clicking on the goal name.
                                    </td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>
                                        <table class="gridTable4" width="100%">
                                            <tr>
                                                <td><b>All Goals & Sub Goals</b></td>
                                                <td width="150px"><input type="checkbox" id="markascompletedAll" name="markascompletedAll" onclick="selectAll(this,'markascompleted','<%=formId%>');" />&nbsp;&nbsp;Mark As Completed</td>
                                                <td width="150px"><input type="checkbox" id="unassignAll" name="unassignAll" onclick="selectAll(this,'unassign','<%=formId%>');" />&nbsp;&nbsp;UnAssign</td>
                                            </tr>


                                            <%
                                                String imageName = null;
                                                                                    for(GoalRecord task : activeTask){
                                                                                        imageName = GoalRecord.stateImg(task.getState());
                                            %>

                                            <tr>
                                                <td>
                                                    <a href="<%=ar.baseURL%>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey()%>/task<%=task.getId()%>.htm"><img src="<%=ar.baseURL%>assets/images/<%ar.write(imageName);%>" title="Edit Task" /></a>
                                                    &nbsp;&nbsp;<a href="<%=ar.baseURL%>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey()%>/task<%=task.getId()%>.htm"><b><%
                                                        ar.write(task.getSynopsis());
                                                    %></b>
                                                    </a> <%
     if(task.getDescription() != null && task.getDescription().length()> 0){ar.write("-"); ar.write(task.getDescription()); }
 %>
                                                </td>
                                                <td width="150px"><input type="checkbox" id="markascompleted" name="markascompleted" value="<%ar.write(task.getId());%>" onclick="unSelect('markascompletedAll','<%=formId%>')" />&nbsp;&nbsp;Mark As Completed</td>
                                                <td width="150px"><input type="checkbox" id="unassign" name="unassign" value="<%ar.write(task.getId());%>" onclick="unSelect('unassignAll','<%=formId%>')" />&nbsp;&nbsp;UnAssign</td>
                                            </tr>
                                            <%
                                                }
                                            %>
                                        </table>
                                    </td>
                                </tr>
                                <tr><td style="height:30px;"></td></tr>
                                <%
                                    }
                                %>
                                <tr>
                                    <td class="notificationSubHeading">Stop being a player of roles</td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>
                                    <%
                                        List<NGRole> roles = ngp.getAllRoles();
                                    %>
                                        <input type="checkbox" id="stoproleplayerAll" name="stoproleplayerAll" onclick="selectAll(this,'stoproleplayer','<%=formId%>');"/>&nbsp;&nbsp;<b>All Roles</b><br />

                                        <%
                                            for(NGRole role : roles){
                                                                                if(role.isExpandedPlayer(uProf, ngp)){
                                        %>

                                                    <input type="checkbox" id="stoproleplayer" name="stoproleplayer" value="<%ar.write(role.getName());%>" onclick="unSelect('stoproleplayerAll','<%=formId%>')"/>
                                                    &nbsp;&nbsp;<a href="<%=ar.baseURL%>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey()%>/EditRole.htm?roleName=<%ar.write(role.getName());%>"><b><%
                                                        ar.write(role.getName());
                                                    %></b></a><br />

                                                    <%
                                                        }
                                                                                        }
                                                    %>
                                    </td>
                                </tr>
                                <%
                                    ReminderMgr rMgr = ngp.getReminderMgr();
                                                        Vector<ReminderRecord> rVec = rMgr.getUserReminders(uProf);
                                                        if(rVec != null && rVec.size() > 0){
                                %>
                                <tr><td style="height:30px;"></td></tr>
                                <tr>
                                    <td class="notificationSubHeading">Stop sending notification related to document sharing reminders</td>
                                </tr>
                                <tr><td style="height:5px;"></td></tr>
                                <tr>
                                    <td>
                                    <input type="checkbox" id="stopRemindingAll" name="stopRemindingAll" onclick="selectAll(this,'stopReminding','<%=formId%>');" />&nbsp;&nbsp;<b>All Document Reminders</b><br />
                                    <%
                                        AddressListEntry ale = null;
                                                                    for(ReminderRecord reminder : rVec)
                                                                    {
                                                                        ale = new AddressListEntry(reminder.getModifiedBy());
                                    %>
                                            <input type="checkbox" id="stopReminding" name="stopReminding" onclick="unSelect('stoproleplayerAll','<%=formId%>')" value="<%ar.write(reminder.getId());%>"
                                            <%if("no".equals(reminder.getSendNotification())){%> selected="true" <%}%> />
                                                &nbsp;&nbsp;<a href="<%=ar.baseURL%>t/<%=ngp.getSiteKey()%>/<%=ngp.getKey() %>/reminders.htm">
                                                <b><%ar.write(reminder.getSubject()); %></b>
                                                </a> &nbsp;&nbsp;by <% ale.writeLink(ar); %>
                                                &nbsp;&nbsp; dated &nbsp;&nbsp;<b><%SectionUtil.nicePrintTime(ar, reminder.getModifiedDate(), ar.nowTime); %></b>
                                                <br />
                                    <%
                                        }
                                    %>

                                    </td>
                                </tr>
                                <tr><td class="notificationSubHeading" style="height:30px;"></td></tr>
                                <%} %>
                                <tr><td style="height:10px;"></td></tr>
                                <tr>
                                    <td><input type="submit" id="savebutton" name="savebutton" class="inputBtn" value="Save"  /> <input type="button" class="inputBtn" value="Cancel" onclick="cancel();" /></td>
                                </tr>
                            </table>
                        </div>
                    </div>
                </form>
            <%
                }
                counter++;
            }
            %>
        </div>
    </div>
</div>
