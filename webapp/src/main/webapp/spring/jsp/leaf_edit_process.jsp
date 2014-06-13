<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="java.util.Date"
%><%@page import="java.text.SimpleDateFormat"
%><%@page import="org.socialbiz.cog.TemplateRecord"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*
Required parameters:

    1. pageId   : This is the id of an Project and here it is used to retrieve NGPage.
    2. bookList : This is the list of sites which is set in request attribute, used here to show
                  dropdown list of sites.
    3. taskId   : This parameter is id of a task and here it is used to get current task detail (GoalRecord)
                  and to pass current task id value when submitted.
    4. book     : This request attribute provide the key of account which is used to select account from the
                  list of all sites by-default when the page is rendered.

*/

    String pageId = ar.reqParam("pageId");
    String taskId = ar.reqParam("taskId");

    List<NGBook> bookList = (List<NGBook>)request.getAttribute("bookList");
    String book = (String)request.getAttribute("book");%><%!String pageTitle = "";
    SimpleDateFormat formatter  = new SimpleDateFormat ("MM/dd/yyyy");

    String parentProcess=null;
    String bookKey=null;%><%UserProfile uProf = ar.getUserProfile();

    NGPage ngp =(NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);

    ar.setPageAccessLevels(ngp);
    NGBook ngb = ngp.getSite();
    pageTitle = ngp.getFullName();

    GoalRecord currentTaskRecord=ngp.getGoalOrFail(taskId);

    List<HistoryRecord> histRecs = currentTaskRecord.getTaskHistory(ngp);

    Vector<NGPageIndex> templates = new Vector<NGPageIndex>();
    for(TemplateRecord tr : uProf.getTemplateList()){
        String pageKey = tr.getPageKey();
        NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(pageKey);
        if (ngpi!=null){
            templates.add(ngpi);
        }
    }
    NGPageIndex.sortInverseChronological(templates);%>
    <script src="<%=ar.baseURL%>jscript/jquery.dd.js" type="text/javascript"></script>
    <link rel="stylesheet" type="text/css" href="<%=ar.retPath%>css/dd.css" />

    <script type="text/javascript" language = "JavaScript">

        var isfreezed = '<%=ngp.isFrozen()%>';
        var flag=false;
        var emailflag=false;
        var taskNameRequired = '<fmt:message key="nugen.process.taskname.required.error.text"/>';
        var taskName = '<fmt:message key="nugen.process.taskname.textbox.text"/>';
        var emailadd='<fmt:message key="nugen.process.emailaddress.textbox.text"/>'
        var goToUrl  ='<%=ar.getRequestURL()%>'+'?taskId='+<%=taskId%>;

         function submitUpdatedTask(){
            <%if (!ngp.isFrozen()) {%>
                var taskname =  document.getElementById("taskname_update");
                if(!(!taskname.value=='' || !taskname.value==null)){
                    alert(taskNameRequired);
                        return false;
                }
                document.forms["updateTaskForm"].submit();
            <%}else{%>
               return openFreezeMessagePopup();
            <%}%>
        }

        function createProject(){
        <%if (!ngp.isFrozen()) {%>
            document.forms["projectform"].submit();
        <%}else{%>
            return openFreezeMessagePopup();
        <%}%>
        }
        function updateTaskStatus(){
        <%if (!ngp.isFrozen()) {%>
            document.forms["updateTaskStatusForm"].submit();
        <%}else{%>
            return openFreezeMessagePopup();
        <%}%>
        }

        function inviteUser(bookId,pageId,emailId)
        {
            var uri='<%=ar.retPath%>'+"t/"+bookId+"/"+pageId+"/inviteUser.htm?emailId="+emailId;
            window.open(uri,TARGET="_parent");
        }

        function AddNewAssigne(){
        <%if (!ngp.isFrozen()) {%>
            document.forms["assignTask"].submit();
        <%}else{%>
            return openFreezeMessagePopup();
        <%}%>
        }

        var callbackprocess = {
           success: function(o) {
               var respText = o.responseText;
               var json = eval('(' + respText+')');
               if(json.msgType != "success"){
                   showErrorMessage("Result", json.msg , json.comments );
              }
           },
           failure: function(o) {
                   alert("callbackprocess Error:" +o.responseText);
           }
        }

    function removeAssigne(assigneeId){
        if(isfreezed == 'false'){
            document.getElementById("remove").value="true";
            document.getElementById("removeAssignee").value=assigneeId;
            document.forms["assignTask"].submit();
        }else{
            return openFreezeMessagePopup();
        }
    }

    function updateAssigneeVal(){
        emailflag=true;
    }


    function createSubTask(){
        if(isfreezed == 'false'){
            var taskname =  document.getElementById("taskname");
            var assignto =  document.getElementById("assignto_SubTask");

            if(taskname.value=='' || taskname.value==null){
                alert(taskNameRequired);
                    return false;
            }

            if(assignto.value==emailadd){
                document.getElementById("assignto_SubTask").value="";
            }
            document.forms["createSubTaskForm"].elements["assignto"].value = assignto.value;
            document.forms["createSubTaskForm"].submit();
        }else{
            return openFreezeMessagePopup();
        }
    }

    function updateTaskVal(){
        flagSubTask=true;
    }

    function clearField(elementName) {
        var task=document.getElementById(elementName).value;
        if(task==taskName){
            document.getElementById(elementName).value="";
            document.getElementById(elementName).style.color="black";
        }
    }

    function defaultTaskValue(elementName) {
        var task=document.getElementById(elementName).value;
        if(task==""){
            flag=false;
            document.getElementById(elementName).value=taskName;
            document.getElementById(elementName).style.color = "gray";
        }
    }

    function validatePercentage(){
        var percentage = document.getElementById("percentage").value;
        if(percentage==""){
            document.getElementById("percentage").value = 0;
        }else{
            var x = parseInt(percentage);
            var numericExpression = /^[0-9]+$/;
            if(percentage.match(numericExpression)) {
                if (isNaN(x) || x < 0 || x > 100) {
                    alert("Please enter correct percentage, a numeric value between 0 to 100");
                }
            } else {
                alert("Please enter correct percentage, a numeric value between 0 to 100");
            }
        }
    }
</script>

<script language="javascript">
    $(document).ready(function(e) {
    try {
        //This have been commented out because it is failing for some reason
        //to allow the select boxes to actually submit values
        //$("select.special").msDropDown();
    } catch(e) {
        alert(e.message);
    }
    });
</script>
<body class="yui-skin-sam">

    <!-- Content Area Starts Here -->
    <div class="generalArea">
        <div class="pageHeading">
            <img src="<%=ar.retPath%>/assets/images/tb_<%=BaseRecord.stateImg(currentTaskRecord.getState())%>" />
            <span style="color:#5377ac"> <%=BaseRecord.stateName(currentTaskRecord.getState())%> Goal:</span>
            <%
                ar.writeHtml(currentTaskRecord.getSynopsis());
            %>
        </div>

        <div class="pageSubHeading">
            <table>
                <tr>
                    <td valign="top">assigned to:&nbsp;&nbsp;
                        <div id="assignDivContent" class="assignDivContent" style="display:none">
                            <form name="assignTask" action="reassignTaskSubmit.form" method="post">
                                <input type="hidden" name="taskid" id="taskid" value="<%ar.writeHtml(taskId);%>"/>
                                <input type="hidden" name="remove" id="remove" value=""/>
                                <input type="hidden" name="removeAssignee" id="removeAssignee" value=""/>
                                <input type="hidden" name="go" id="go" value="<%=ar.getCompleteURL()%>"/>
                                <table width="100%" class="tableArea">
                        <%
                            List<AddressListEntry> allUsers = currentTaskRecord.getAssigneeRole().getDirectPlayers();
                                            for (AddressListEntry ale : allUsers)
                                            {
                                                if(ale.getUserProfile() == null){
                                                    ar.write("<tr><td>");
                                                    ar.write("<img src=\"");
                                                    ar.write(ar.retPath+"/assets/photoThumbnailSmall.gif\" alt=\"img\" border=\"0\" />&nbsp;");
                                                    ar.write("\n    <a href=\"");
                                                    ar.write(ar.retPath);
                                                    ar.write("t/");
                                                    ar.write(ngp.getSite().getKey());
                                                    ar.write("/");
                                                    ar.write(ngp.getKey());
                                                    ar.writeHtml("/inviteUser.htm?");
                                                    ar.writeHtml("emailId=");
                                                    ar.write(ale.getEmail());
                                                    ar.write("\">");
                                                    ar.write("\n    <span style=\"color:red\">");
                                                    ar.writeHtml(ale.getStorageRepresentation());
                                                    ar.write("</span></a>");
                                                    ar.write("&nbsp;&nbsp;<a href=\"#\" title=\"Remove\" onclick=\"removeAssigne('"+ale.getStorageRepresentation()+"')\">");
                                                    ar.write("<img src=\"");
                                                    ar.write(ar.retPath+"/assets/iconBlackDelete.gif\" alt=\"Remove\" border=\"0\" /></a>");
                                                    ar.write("</td></tr>");
                                                    ar.write("<tr><td style=\"border-top:0px solid #ccc; height:5px\"></td></tr>");
                                                }else{
                        %>
                                    <tr>
                                        <td>
                                            <img src="<%=ar.retPath%>/assets/photoThumbnailSmall.gif" alt="img" border="0" />&nbsp;
                                            <a href=""><span style="color:red"><%
                                                ale.writeLink(ar);
                                            %></span></a>&nbsp;&nbsp;
                                            <a href="#" title="Remove" onclick="removeAssigne('<%=ale.getUniversalId()%>')"><img src="<%=ar.retPath%>/assets/iconBlackDelete.gif" alt="Remove" border="0" /></a>
                                        </td>
                                    </tr>
                                    <tr><td style="border-top:0px solid #ccc; height:5px"></td></tr>
                        <%
                            }
                                            }
                        %>
                                    <tr><td style="border-top:1px solid #ccc; height:5px"></td></tr>
                                    <tr>
                                        <td id="reassignDiv" style="display:none">
                                            <input type="text" class="wickEnabled" name="assignto" id="assignto" size="69"
                                                value="<fmt:message key='nugen.process.emailaddress.textbox.text'/>" autocomplete="off"
                                                onkeyup="autoComplete(event,this);"
                                                onfocus="clearFieldAssignee('assignto');initsmartInputWindowVlaue('smartInputFloater','smartInputFloaterContent');"
                                                onblur="defaultAssigneeValue('assignto');"/>
                                            <div style="position:relative;text-align:left">
                                                <table  class="floater" style="position:absolute;top:0;left:0;background-color:#cecece;display:none;visibility:hidden"  id="smartInputFloater"  rules="none" cellpadding="0" cellspacing="0">
                                                    <tr><td id="smartInputFloaterContent"  nowrap="nowrap" width="100%"></td></tr>
                                                </table>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                    <%
                                        if (allUsers.size() == 0) {
                                    %>
                                            <div id="showDiv1" style="display:inline" onclick="setVisibility_2('reassignDiv')"><a href="#" title="Add More">Add New</a></div>
                                    <%
                                        }else{
                                    %>
                                            <div id="showDiv1" style="display:inline" onclick="setVisibility_2('reassignDiv')"><a href="#" title="Add More">Add More</a></div>
                                    <%
                                        }
                                    %>
                                            <div id="hideDiv1" style="display:none;" onclick="setVisibility_2('reassignDiv')"><a href="#" onclick="AddNewAssigne()" title="Save">Save</a></div>
                                                &nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;<a href="#" title="Close" onclick="collapseDiv1('assignDivContent','reassignDiv','showDiv1','hideDiv1','assignto');defaultAssigneeValue('assignto');">Close</a>
                                        </td>
                                    </tr>
                                </table>
                            </form>
                        </div>
                        <%
                            if (allUsers.size() != 0) {
                        %>
                         <a href=""><span style="color:red"><%
                             allUsers.get(0).writeLink(ar);
                         %></span></a>
                        <%
                            }
                        %>
                    </td>
                    <td valign="top">&nbsp;&nbsp;&nbsp;<a href="#" title="More" onclick="expandDiv('assignDivContent')"><img src="<%=ar.retPath%>/assets/iconMore.gif" border="0" alt="More" /></a></td>
                    <td valign="top">&nbsp;&nbsp;&nbsp;&nbsp;
                        due date:
                        <span  id="top_btn_dueDate" style="color: red">
                            <%
                                writeDate(ar,currentTaskRecord.getDueDate());
                            %>
                        </span>
                        start date:
                        <span id="top_btn_dueDate" style="color: red">
                            <%
                                writeDate(ar,currentTaskRecord.getStartDate());
                            %>
                        </span>

                        end date:
                        <span  id="top_btn_dueDate" style="color: red">
                            <%
                                writeDate(ar,currentTaskRecord.getEndDate());
                            %>
                        </span>
                    </td>
                </tr>
            </table>
        </div>

        <p style="padding-top:10px"><%
            ar.writeHtmlWithLines(currentTaskRecord.getDescription());
        %></p>

        <div id="TabbedPanels1" class="TabbedPanels">
            <ul class="TabbedPanelsTabGroup">
                <li class="TabbedPanelsTab" tabindex="0">Status &amp; Accomplishments</li>
                <li class="TabbedPanelsTab" tabindex="1"><img src="<%=ar.retPath%>/assets/iconCreateSubProject.gif" />&nbsp;&nbsp;Create Sub Project</li>
                <li class="TabbedPanelsTab" tabindex="2"><img src="<%=ar.retPath%>/assets/iconAddSubtask.gif" />&nbsp;&nbsp;Create Sub Goal</li>
            </ul>
            <div class="TabbedPanelsContentGroup">
                <div class="TabbedPanelsContent">
                    <!-- ========================================================================= -->
                    <form name="updateTaskStatusForm" action="statusUpdateForTask.form" method="post">
                        <input type="hidden" name="go" id="go" value="<%=ar.getCompleteURL()%>"/>
                        <input type="hidden" name="taskId" value="<%ar.writeHtml(taskId);%>">
                        <table width="100%">
                            <tr>
                                <td colspan="3" class="generalHeading">Status &amp; Accomplishments</td>
                            </tr>
                            <tr><td height="25px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.status.text"/></td>
                                <td style="width:20px;"></td>
                                <td><textarea id="status" name="status" class="textAreaGeneral" rows="4"><%
                                    ar.writeHtml(currentTaskRecord.getStatus());
                                %></textarea></td>
                            </tr>
                            <tr><td height="20px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader" valign="top">Accomplishments:</td>
                                <td style="width:20px;"></td>
                                <td><textarea name="accomp" id="accomp" name="accomp" class="textAreaGeneral" rows="4"></textarea></td>
                            </tr>
                            <tr><td height="20px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"><fmt:message key="nugen.process.state.text"/></td>
                                <td style="width:20px;"></td>
                                <td><table><tr>
                                    <td>
                                        <select name="states" id="states" class="specialx" tabindex=5 >
                                        <%
                                            for(int i=1;i<=9;i++){
                                                                                String selected = "";
                                                                                if (i==currentTaskRecord.getState()) {
                                                                                    selected = "selected=\"selected\"";
                                                                                }
                                                                                String img3=ar.retPath+"assets/images/"+BaseRecord.stateImg(i);
                                                                                out.write("     <option " + selected + " value=\"" + i + "\"  title=\""+img3+"\" >" + BaseRecord.stateName(i) + "</option>");
                                                                            }
                                                                            String errorselected="";
                                                                            if(currentTaskRecord.getState()==0){
                                                                                errorselected = "selected=\"selected\"";
                                                                            }
                                                                            String image=ar.retPath+"assets/images/"+BaseRecord.stateImg(0);
                                                                            out.write("     <option " + errorselected + " value=\"" + 0 + "\"  title=\""+image+"\" >" + BaseRecord.stateName(0) + "</option>");
                                        %>
                                        </select>
                                    </td>
                                    <td style="width:20px;"></td>
                                    <td style="color:#000000"><b>Completed:</b></td>
                                    <td style="width:10px;"></td>
                                    <td>
                                        <input type="text" name="percentage" id="percentage" value="<%=currentTaskRecord.getPercentComplete()%>"
                                            style="font-size:12px;color:#333333;width: 25px;" onchange="validatePercentage()"/>%
                                    </td>
                                </tr></table></td>
                            </tr>
                            <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader" valign="top"></td>
                                <td style="width:20px;"></td>
                                <td><input type="button" value="Update Status &amp; Accomplishments" class="inputBtn" onclick="updateTaskStatus();" /></td>
                            </tr>
                            <tr><td height="30px"></td></tr>
                        </form>

                        <!-- ========================================================================= -->
                        <form name="updateTaskFormB" action="updateTask.form" method="post">
                            <input type="hidden" name="go" id="go" value="<%=ar.getCompleteURL()%>"/>
                            <input type="hidden" name="taskId" value="<%ar.writeHtml(taskId);%>">
                            <tr>
                                <td colspan="3" class="generalHeading">Goal Details</td>
                            </tr>
                            <tr><td height="23px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"><fmt:message key="nugen.process.taskname.display.text"/>:</td>
                                <td style="width:20px;"></td>
                                <td><input type="text" name="taskname_update" id="taskname_update" class="inputGeneral" size="50" tabindex=1  value='<%ar.writeHtml(currentTaskRecord.getSynopsis());%>'/>
                                </td>
                            </tr>
                            <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"><fmt:message key="nugen.process.priority.text"/></td>
                                <td style="width:20px;"></td>
                                <td>
                                    <table>
                                        <tr>
                                            <td><select name="priority" id="priority" tabindex="4">
                                                <%
                                                    int taskPrior = currentTaskRecord.getPriority();
                                                                                        for (int i=0; i<3; i++)
                                                                                        {
                                                                                            ar.write("\n     <option ");
                                                                                            if (i==taskPrior) {
                                                                                                out.write("selected=\"selected\" ");
                                                                                            }
                                                                                            ar.write("value=\"");
                                                                                            ar.write(Integer.toString(i));
                                                                                            ar.write("\">");
                                                                                            ar.writeHtml(BaseRecord.getPriorityStr(i));
                                                                                            ar.write("</option>");
                                                                                        }
                                                %>
                                                </select>
                                             </td>
                                             <td style="width:45px;"></td>
                                             <td style="color:#000000"><b><fmt:message key="nugen.process.state.text"/></b></td>
                                            <td style="width:10px;"></td>
                                            <td>
                                                <select name="state" id="state" class="specialNo" tabindex="5">
                                                <%
                                                    int taskState = currentTaskRecord.getState();
                                                                                        for(int i=1;i<=8;i++){
                                                                                            String img4=ar.retPath+"assets/images/"+BaseRecord.stateImg(i);
                                                                                            ar.write("\n     <option ");
                                                                                            if (i==taskState) {
                                                                                                ar.write("selected=\"selected\"");
                                                                                            }
                                                                                            ar.write(" value=\"");
                                                                                            ar.write(Integer.toString(i));
                                                                                            ar.write("\"  title=\"");
                                                                                            ar.writeHtml(img4);
                                                                                            ar.write("\" >");
                                                                                            ar.writeHtml(BaseRecord.stateName(i));
                                                                                            ar.write("</option>");
                                                                                        }
                                                                                        String img5=ar.retPath+"assets/images/"+BaseRecord.stateImg(0);
                                                                                        ar.write("\n     <option ");
                                                                                        if(taskState==0){
                                                                                             ar.write("selected=\"selected\"");
                                                                                        }
                                                                                        ar.write(" value=\"0\"  title=\"");
                                                                                        ar.writeHtml(img5);
                                                                                        ar.write("\" >");
                                                                                        ar.writeHtml(BaseRecord.stateName(0));
                                                                                        ar.write("</option>");
                                                %>
                                                </select>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"><fmt:message key="nugen.project.duedate.text"/></td>
                                <td style="width:20px;"></td>
                                <td>
                                    <table>
                                        <tr>
                                            <td><input type="text" size="16" name="dueDate_update" id="dueDate_update"
                                                value='<%=(currentTaskRecord.getDueDate()==0)?"":formatter.format(new Date(currentTaskRecord.getDueDate()))%>' readonly="1"/>
                                            <img src="<%=ar.retPath%>/jscalendar/img.gif" id="btn_update" style="cursor: pointer;" title="Date selector"/>
                                            </td>
                                            <td style="width:17px;"></td>
                                            <td style="color:#000000"><b><fmt:message key="nugen.project.startdate.text"/></b></td>
                                            <td style="width:10px;"></td>
                                            <td><input type="text" size="16" name="startDate_update" id="startDate_update" value='<%=(currentTaskRecord.getStartDate()==0)?"":formatter.format(new Date(currentTaskRecord.getStartDate()))%>' readonly="1"/>
                                            <img src="<%=ar.retPath%>/jscalendar/img.gif" id="top_btn_startDate" style="cursor: pointer;" title="Date selector"/>
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"><fmt:message key="nugen.project.enddate.text"/></td>
                                <td style="width:20px;"></td>
                                <td><input type="text" size="16" name="endDate_update" id="endDate_update"  value='<%=(currentTaskRecord.getEndDate()==0)?"":formatter.format(new Date(currentTaskRecord.getEndDate()))%>' readonly="1"/>
                                <img src="<%=ar.retPath%>/jscalendar/img.gif" id="top_btn_endDate" style="cursor: pointer;" title="Date selector"/>
                                </td>
                            </tr>
                             <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.desc.text"/></td>
                                <td style="width:20px;"></td>
                                <td><textarea name="description" id="description" class="textAreaGeneral" rows="4" tabindex=7><%
                                    ar.writeHtml(currentTaskRecord.getDescription());
                                %></textarea></td>
                            </tr>
                            <tr><td height="10px"></td></tr>
                            <tr>
                                <td class="gridTableColummHeader"></td>
                                <td style="width:20px;"></td>
                                <td>
                                    <input type="submit" value="Update Goal" class="inputBtn" tabindex=3/>
                                </td>
                            </tr>
                        </form>

                        <!-- ========================================================================= -->
                        <tr><td height="40px"></td></tr>
                        <tr>
                            <td colspan="3">
                                <div class="generalHeading">List of Sub Goals</div>
                                  <table class="gridTable2" width="100%">
                                    <tr>
                                        <td align="right" style="padding:0px;height:10px;"> </td>
                                    </tr>
                            <%
                                for (GoalRecord child : currentTaskRecord.getSubGoals()) {
                                                        String subTaskName = child.getSynopsis();
                                                        String img7=ar.retPath+"assets/images/"+BaseRecord.stateImg(child.getState());
                            %>
                                      <tr>
                                          <td><a href="task<%=child.getId()%>.htm"><img src="<%=img7%>"/></a>&nbsp; &nbsp; &nbsp;<%
     ar.writeHtml(subTaskName);
 %> </td>
                                      <tr>
                            <%
                                }
                            %>
                                   </table>
                             </td>
                          </tr>

                        <!-- ========================================================================= -->
                        <tr><td height="30px"></td></tr>
                        <tr>
                            <td colspan="3" class="generalHeading">Previous Accomplishments</td>
                        </tr>
                        <tr>
                            <td colspan="3" id="prevAccomplishments">
                                <table >
                                    <tr><td style="height:10px"></td>
                                    </tr>
                        <%
                            for (HistoryRecord history : histRecs)
                                            {
                                                AddressListEntry ale = new AddressListEntry(history.getResponsible());
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
                                                NGWebUtils.writeLocalizedHistoryMessage(history, ngp, ar);
                                            %>
                                            <br/>
                                            <%
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
                    </table>
                </div>
                <div class="TabbedPanelsContent">
                    <div class="generalArea">
                        <!--  Start here -->
                        <div class="generalContent">
                    <%
                        if(bookList!=null && bookList.size()<1){
                    %>
                            <div id="loginArea">
                                <span class="black">
                                    <fmt:message key="nugen.userhome.PermissionToCreateProject.text"/>
                                </span>
                            </div>
                    <%
                        }
                                    else
                                    {
                                        String actionPath=ar.retPath+"t/"+ngp.getSite().getKey()+"/"+ngp.getKey()+"/createProjectFromTask.form";
                                        String goToUrl =ar.getRequestURL()+"?taskId="+taskId;
                    %>
                            <form name="projectform" action='<%=actionPath%>' method="post" autocomplete="off" >
                                <table>
                                    <tr><td style="height:20px"></td></tr>
                                    <tr>
                                        <td class="gridTableColummHeader">Sub Project Name:</td>
                                        <td style="width:20px;"></td>
                                        <td>
                                            <input type="text" onblur="validateProjectField()" class="inputGeneral"
                                            name="projectname" id="projectname" value="<%ar.writeHtml(currentTaskRecord.getSynopsis());%>"
                                            onKeyup="updateVal();" onblur="addvalue();" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="gridTableColummHeader"></td>
                                        <td style="width:20px;"></td>
                                        <td width="396px">
                                            <b>Note:</b> From here you can create a new subproject.The subproject will be connected to this activity, and will be completed when the subproject process is completed.
                                        </td>
                                    </tr>
                                    <tr><td style="height:10px"></td></tr>
                                    <tr>
                                        <td class="gridTableColummHeader">Select Template:</td>
                                        <td style="width:20px;"></td>
                                        <td><Select class="selectGeneral" id="templateName" name="templateName">
                                            <option value="" selected>Select</option>
                                            <%
                                                for (NGPageIndex ngpi : templates){
                                                    %><option value="<%=ngpi.containerKey%>" ><%
                                                    ar.writeHtml(ngpi.containerName);
                                                    %></option><%
                                                }
                                            %>
                                                    </Select></td>
                                      </tr>
                                      <tr><td style="height:15px"></td></tr>
                                      <tr>
                                          <td class="gridTableColummHeader"><fmt:message key="nugen.userhome.Account"/></td>
                                          <td style="width:20px;"></td>
                                          <td><select class="selectGeneral" name="accountId" id="accountId">
                                            <%
                                                for (NGBook nGBook : bookList) {
                                                    String id =nGBook.getKey();
                                                    String bookName= nGBook.getName();
                                                    if((book!=null && id.equalsIgnoreCase(book))
                                                        || (bookKey!=null && id.equalsIgnoreCase(bookKey))) {
                                                        %><option value="<%=id%>" selected><%
                                                    }
                                                    else {
                                                        %><option value="<%=id%>"><%
                                                    }
                                                    ar.writeHtml(bookName);
                                                    %></option><%
                                                }
                                            %>
                                          </select></td>
                                     </tr>
                                     <tr><td style="height:15px"></td></tr>
                                     <tr>
                                         <td class="gridTableColummHeader" style="vertical-align:top"><fmt:message key="nugen.project.desc.text"/></td>
                                         <td style="width:20px;"></td>
                                         <td><textarea name="description" id="description" class="textAreaGeneral" rows="4" tabindex=7></textarea></td>
                                     </tr>
                                     <tr><td style="height:10px"></td></tr>
                                     <tr>
                                         <td class="gridTableColummHeader"></td>
                                         <td style="width:20px;"></td>
                                         <td>
                                             <input type="button" value="Create Sub Project" class="inputBtn" onclick="createProject();" />
                                             <input type="hidden" name="goUrl" value="<%ar.writeHtml(goToUrl);%>" />
                                             <input type="hidden" id="parentProcessUrl" name="parentProcessUrl"
                                                value="<%ar.writeHtml(currentTaskRecord.getWfxmlLink(ar).getCombinedRepresentation());%>" />
                                         </td>

                                     </tr>
                                </table>
                            </form>
                  <%
                    }
                  %>
                        </div>
                        <!-- End here -->
                      </div>
                </div>
                <div class="TabbedPanelsContent">
                    <div class="generalContent">
                    <!-- Tab Structure Starts Here -->
                        <div id="container">
                            <form name="createSubTaskForm" action="createSubTask.form" method="post">
                                <input type="hidden" name="go" id="go" value="<%ar.writeHtml(ar.getCompleteURL());%>"/>
                                <input type="hidden" name="assignto" value=""/>
                                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                        <tr>
                                            <td colspan="3">
                                                <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                    <tr><td height="22px"></td></tr>
                                                    <tr>
                                                        <td class="gridTableColummHeader"><fmt:message key="nugen.process.taskname.display.text"/>:</td>
                                                        <td style="width:20px;"></td>
                                                        <td>
                                                            <input type="text" class="inputGeneral" name="taskname" id="taskname" tabindex=1 value ='<fmt:message key="nugen.process.taskname.textbox.text"/>'  onKeyup="updateTaskVal();" onfocus="clearField('taskname');" onblur="defaultTaskValue('taskname');"/>&nbsp;
                                                            <input type="hidden" name="taskId" value="<%=taskId%>" />
                                                        </td>
                                                    </tr>
                                                    <tr><td height="15px"></td></tr>
                                                    <tr>
                                                        <td class="gridTableColummHeader"><fmt:message key="nugen.process.assignto.text"/></td>
                                                        <td style="width:20px;"></td>
                                                        <td><input type="text" class="wickEnabled" name="assignto_SubTask" id="assignto_SubTask" style="height:20px" tabindex=2 value='<fmt:message key="nugen.process.emailaddress.textbox.text"/>' onkeydown="updateAssigneeVal();" autocomplete="off" onkeyup="autoComplete(event,this);"  onfocus="clearFieldAssignee('assignto_SubTask');initsmartInputWindowVlaue('smartInputFloater1','smartInputFloaterContent1');" onblur="defaultAssigneeValue('assignto_SubTask');"/>
                                                            <div style="position:relative;text-align:left">
                                                                <table class="floater" style="position:absolute;top:0;left:0;background-color:#cecece;display:none;visibility:hidden;width:397px"
                                                                    id="smartInputFloater1" rules="none" cellpadding="0" cellspacing="0" width="100%">
                                                                    <tr><td id="smartInputFloaterContent1" nowrap="nowrap"></td></tr>
                                                                </table>
                                                            </div>
                                                        </td>
                                                    </tr>
                                                    <tr><td height="15px"></td></tr>
                                                </table>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td colspan="3">
                                                <div id="assignTask" style="display: inline">
                                                    <table width="100%" border="0" cellpadding="0" cellspacing="0">
                                                        <tr>
                                                            <td class="gridTableColummHeader"><fmt:message key="nugen.process.priority.text"/></td>
                                                            <td style="width:20px;"></td>
                                                            <td>
                                                                <table>
                                                                    <tr>
                                                                        <td>
                                                                            <select name="priority" tabindex="4">
                                                                                <option selected="selected" value ="0"><fmt:message key="nugen.process.priority.High"/></option>
                                                                                <option value="1"><fmt:message key="nugen.process.priority.Medium"/></option>
                                                                                <option value="2"><fmt:message key="nugen.process.priority.Low"/></option>
                                                                            </select>
                                                                        </td>
                                                                        <td style="width:20px;"></td>
                                                                        <td style="color:#000000"><b><fmt:message key="nugen.project.duedate.text"/></b></td>
                                                                        <td style="width:10px;"></td>
                                                                        <td>
                                                                            <input class="inputGeneral" type="text" style="width:100px" name="dueDate" id="dueDate" value="" readonly="1" tabindex="6"/>
                                                                        </td>
                                                                        <td style="width:5px;"></td>
                                                                        <td>
                                                                            <img src="<%=ar.retPath%>/jscalendar/img.gif" id="btn_dueDate" style="cursor: pointer;" title="Date selector"/>
                                                                        </td>
                                                                    </tr>
                                                                </table>
                                                            </td>
                                                        </tr>
                                                        <tr><td height="15px"></td></tr>
                                                        <tr>
                                                            <td class="gridTableColummHeader" valign="top"><fmt:message key="nugen.project.desc.text"/></td>
                                                            <td style="width:20px;"></td>
                                                            <td><textarea name="description" id="description" class="textAreaGeneral" rows="4" tabindex=7></textarea></td>
                                                        </tr>
                                                        <tr><td height="10px"></td></tr>
                                                        <tr>
                                                            <td class="gridTableColummHeader"></td>
                                                            <td style="width:20px;"></td>
                                                            <td><input type="button" value="Create Sub Goal" class="inputBtn" tabindex=3 onclick="createSubTask();"/></td>
                                                        </tr>
                                                    </table>
                                                </div>
                                            </td>
                                        </tr>
                                        <tr><td height="40px"></td></tr>
                                        <tr>
                                            <td colspan="3">
                                                <div class="generalHeadingBorderLess">List of Sub Goals</div>
                                                  <table class="gridTable2" width="100%">
                                                    <tr>
                                                        <td align="right" style="padding:0px;height:10px;"> </td>
                                                    </tr>
                                            <%
                                                for (GoalRecord child : currentTaskRecord.getSubGoals()) {
                                                    String subTaskName = child.getSynopsis();
                                                    String img7=ar.retPath+"assets/images/"+BaseRecord.stateImg(child.getState());
                                            %>
                                                      <tr>
                                                          <td><a href="task<%=child.getId()%>.htm"><img src="<%=img7 %>"/></a>&nbsp; &nbsp; &nbsp;<%ar.writeHtml(subTaskName);%> </td>
                                                      <tr>
                                            <%
                                                }
                                            %>
                                                   </table>
                                             </td>
                                          </tr>
                                        <!--  end sub goal-->
                                    </table>
                                </form>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
            <script type="text/javascript">
                var TabbedPanels1 = new Spry.Widget.TabbedPanels("TabbedPanels1");
            </script>
        </div>
    </div>
</body>

<%
    if (ar.isMember()){
        SectionTask.plugInCalenderScript(out, "dueDate_update", "btn_update");
        SectionTask.plugInCalenderScript(out, "dueDate", "btn_dueDate");
        SectionTask.plugInCalenderScript(out, "startDate_update", "top_btn_startDate");
        SectionTask.plugInCalenderScript(out, "endDate_update", "top_btn_endDate");
    }
%><%!public void writeDate(AuthRequest ar, long date) throws Exception {
        if(date!=0){
            ar.write(new SimpleDateFormat("MM/dd/yyyy").format(new Date(date)));
        }else{
            ar.write(" -- ");
        }
    }%>
