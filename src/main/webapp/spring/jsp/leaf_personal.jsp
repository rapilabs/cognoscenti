<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.CustomRole"
%><%@page import="org.socialbiz.cog.RoleRequestRecord"
%><%@page import="org.socialbiz.cog.SuperAdminLogFile"
%><%@page import="org.socialbiz.cog.EmailListener"
%><%@page import="java.util.Date"
%>
<%
    Date date=new Date(SuperAdminLogFile.getLastNotificationSentTime());
    String thisPage = ar.getResourceURL(ngp,"projectSettings.htm");
%>

<div class="content tab01">
    <div style="height:20px">&nbsp;</div>
    <div class="generalHeading">Watch project</div>
    <div class="generalContent">
    <%
        long pageChangeTime = ngp.getLastModifyTime();

            long subTime = 0;
            if (uProf!=null)
            {
        subTime = uProf.watchTime(pageKey);
            }
            boolean found = subTime!=0;
            ar.write("\n<input type=\"hidden\" id=\"pageChangeTime\" value=\"");
            ar.write(String.valueOf(pageChangeTime));
            ar.write("\"/>");
            ar.write("\n<input type=\"hidden\" id=\"subTime\" value=\"");
            ar.write(String.valueOf(subTime));
            ar.write("\"/>");
    %>
        <table width="100%">
            <tr>
                <td>
                    <fmt:message key="nugen.projecthome.private.watchproject.part1"/>
                    <fmt:message key="nugen.projecthome.private.watchproject.part2"/>
                    <div id="01" style="display: none;">
                        <table>
                            <tr>
                                <td width="500px">
                                    <b><fmt:message key="nugen.projecthome.private.stopwatching.notchanged"/></b>
                                    <b><%
                                        SectionUtil.nicePrintTime(out, subTime, ar.nowTime);
                                    %></b>
                                    <b><fmt:message key="nugen.projecthome.private.stopwatching"/></b>
                                </td>
                                <td width="10px"></td>
                                <td>
                                    <input type="hidden" name="p" value="<%ar.writeHtml(pageKey);%>">
                                    <input type="hidden" name="go" value="<%ar.writeHtml(thisPage);%>">
                                    <input type="button" name="action"  class="inputBtn"
                                        value="<fmt:message key='nugen.button.StopWatching'/>"
                                        onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Stop Watching','<%=ar.retPath%>');">
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="02" style="display: none;">
                        <table>
                            <tr>
                                <td width="500px">
                                    <b><fmt:message key="nugen.projecthome.private.stopwatching.changed"/></b>
                                    <b><%
                                        SectionUtil.nicePrintTime(out, subTime, ar.nowTime);
                                    %></b>
                                    <b><fmt:message key="nugen.projecthome.private.stopwatching"/></b>
                                </td>
                                <td width="10px"></td>
                                <td>
                                    <input type="hidden" name="p" value="<%ar.writeHtml(pageKey);%>">
                                    <input type="hidden" name="go" value="<%ar.writeHtml(thisPage);%>">
                                    <input type="button" name="action"  class="inputBtn"
                                        value="<fmt:message key='nugen.button.ResetWatchingTime'/>"
                                        onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Reset Watch Time','<%=ar.retPath%>');">
                                    <input type="button" name="action"  class="inputBtn"
                                        value="<fmt:message key='nugen.button.StopWatching'/>"
                                        onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Stop Watching','<%=ar.retPath%>');">
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div id="03"  style="display: none;">
                        <table>
                            <tr>
                                <td width="500px">
                                    <b><fmt:message key="nugen.projecthome.private.startwatching"></fmt:message></b>
                                </td>
                                <td width="10px"></td>
                                <td>
                                    <input type="hidden" name="p" value="<%ar.writeHtml(pageKey);%>">
                                    <input type="hidden" name="go" value="<%ar.writeHtml(thisPage);%>">
                                    <input type="button" name="action"  class="inputBtn"
                                        value="<fmt:message key='nugen.button.StartWatching'/>"
                                        onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Start Watching','<%=ar.retPath%>',<%ar.writeQuote4JS(String.valueOf(ngp.isFrozen()));%>);">
                                </td>
                            </tr>
                        </table>
                        <script type="text/javascript">
                            var time = null;
                            var pageChangeTime = null;
                            if(document.getElementById('subTime')!=null){
                            time = document.getElementById('subTime').value;
                            }
                            if(document.getElementById('pageChangeTime')!=null){
                            pageChangeTime = document.getElementById('pageChangeTime').value;
                            }
                            if (time>pageChangeTime){
                                document.getElementById("01").style.display="";
                            }
                            else if(time>0){
                                document.getElementById("02").style.display="";
                            }
                            else{
                                if(document.getElementById("03")!=null)
                                    document.getElementById("03").style.display="";
                            }
                        </script>
                    </div>
                </td>
            </tr>
            <tr><td style="height:30px"></td></tr>
            <tr><td><div class="generalHeading">Create project as template</div></td></tr>
            <tr>
                <td>
                    You can use this project as template for your future reference.
                    If you mark this project as template then it will appear in the <b>"<a href="#">List of Templates</a>"</b> in your profile's project page.
                    At any time you can even stop using this project as template.<br /><br />
                    <%
                        out.flush();

                                      if(p!=null && p.length()>0){
                    %>
                    <div id="markastemplate">
                          <table>
                              <tr>
                                  <td width="500px"><b>Presently, this project is one of your templates, would you like to</b></td>
                                  <td width="10px"></td>
                                  <td><input type="button" name="action"  class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.stoptemplate'/>"  onclick="return markastemplate(<%ar.writeQuote4JS(p);%>,'removeTemplate','<%=ar.retPath%>',<%ar.writeQuote4JS(String.valueOf(ngp.isFrozen()));%> );"></td>
                              </tr>
                          </table>
                      </div>
                      <div id="stopusingtemplate">
                          <table>
                              <tr>
                                  <td width="500px"><b>Presently, this project is not one of your templates, would you like to</b></td>
                                  <td width="10px"></td>
                                  <td valign="top"><input type="button" name="action"  class="inputBtn" value="<fmt:message key='nugen.button.projectsetting.markastemplate'/>"  onclick="return markastemplate(<%ar.writeQuote4JS(p);%>,'MarkAsTemplate','<%=ar.retPath%>',<%ar.writeQuote4JS(String.valueOf(ngp.isFrozen()));%>);"></td>
                              </tr>
                          </table>
                      </div>
                </td>
            </tr>
            <tr><td style="height:30px"></td></tr>
            <tr><td><div class="generalHeading">Email notification</div></td></tr>
            <tr>
                <td>
                    You can receive email notifications related to any change occurs in the project,
                    on your registered email address by clicking on <b>"Start Receiving Notification"</b> button.
                    At any time you can even stop receiving email notifications.<br /><br />
                    <%
                        NGRole notifyRole = ngp.getRole("Notify");
                                      if (notifyRole==null)
                                      {
                                          notifyRole = ngp.createRole("Notify", "List of people to be notified of changes to the project.");
                                      }
                    %>
                      <%
                          UserProfile up = ar.getUserProfile();
                                        boolean isNotified = up.isNotifiedForProject(ngp.getKey());
                      %>
                          <div id="stopNotifications" >
                                  <table>
                                      <tr>
                                          <td width="500px">
                                            <I>Last email Sent:&nbsp;<b><%
                                                ar.writeHtml(date.toString());
                                            %></b></I><br />
                                            <b>You are not receiving change notifications for this project.</b>
                                          </td>
                                          <td width="10px"></td>
                                          <td valign="top">
                                              <input type="button" name="action"  class="inputBtn"
                                                value="<fmt:message key='nugen.button.projectsetting.stopnotify'/>"
                                                onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Stop Notifications','<%=ar.retPath%>',<%ar.writeQuote4JS(String.valueOf(ngp.isFrozen()));%>);">

                                          </td>
                                      </tr>
                                  </table>
                              </div>
                            <div id="startNotifications" >
                                    <table>
                                        <tr>
                                            <td width="500px">
                                                <b>Currently, you are not receiving any email notifications related to this project, <br />
                                                would you like to</b>
                                            </td>
                                            <td width="10px"></td>
                                            <td valign="top">
                                                <input type="button" name="action"  class="inputBtn"
                                                    value="<fmt:message key='nugen.button.projectsetting.startnotify'/>"
                                                    onclick="ajaxChangeWatching(<%ar.writeQuote4JS(pageKey);%>,'Start Notifications','<%=ar.retPath%>',<%ar.writeQuote4JS(String.valueOf(ngp.isFrozen()));%>);">
                                            </td>
                                        </tr>
                                    </table>
                                </div>

                                 <script>
                                     if ("<%=isNotified%>" == "true"){
                                  document.getElementById("stopNotifications").style.display="";
                                  document.getElementById("startNotifications").style.display="none";
                              }else{
                                  document.getElementById("stopNotifications").style.display="none";
                                  document.getElementById("startNotifications").style.display="";
                              }
                                 </script>
                </td>
            </tr>
        </table>
        <%
            }
        %>

    </div>

      <div style="height:30px">&nbsp;</div>
      <div class="generalHeading">Join or leave project roles</div>
      <div class="generalContent">
          <table width="100%" border="0">
          <%
              boolean isPersonalTab = true;
                    UserProfile up = ar.getUserProfile();
                    String roleMember = up.getUniversalId();
                    if(roles!=null){
                RoleRequestRecord roleRequestRecord = null;
                Iterator  iterator = roles.iterator();
                while(iterator.hasNext()){
                    NGRole role = (NGRole)iterator.next();
          %>
              <%@include file="join_leave_role_block.jsp"%>
          <%
              }
                    }
          %>
          </table>
      </div>


<script>
var isExecutives = "no";
<%NGRole accountExecutive = ngp.getSite().getRoleOrFail("Executives");
    if(accountExecutive.isPlayer(new AddressListEntry(roleMember))){%>
    isExecutives ="yes";

<%}%>

    if ("<%=ar.isLoggedIn()%>" == "true"){


        if ("<%=isTemplate%>" == "true"){
            document.getElementById("markastemplate").style.display="";
            document.getElementById("stopusingtemplate").style.display="none";
        }else{
            document.getElementById("markastemplate").style.display="none";
            document.getElementById("stopusingtemplate").style.display="";
        }
    }

    function leaveRole(pageId, option, relpath, roleName,isfreezed){
        if(isfreezed == 'false'){
            if(roleName == 'Members'){
                if(isExecutives == 'yes'){
                    alert("User can not leave this role because this user is a 'Site Executive'.");
                    return false;
                }
            }
            var confirmResult = confirm("Are you sure you want to leave '"+roleName+"' Role.");
            if(confirmResult){
                return joinOrLeaveRole(pageId,option,relpath,roleName,'');
            }else{
                return false;
            }
        }else{
           openFreezeMessagePopup();
        }
    }
</script>
