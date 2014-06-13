<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_process2.jsp"
%>
<div class="content tab05" style="display:block;" onmousedown="buttononIndex('5')">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="paging2"></div>
        <div id="searchresultdiv4">
            <div class="taskListArea">
                <!-- Need to take content from here  -->
                <div class="reportSelection">
                    <form name="statusReport" id="statusReport" action="statusReport.form" method="post">
                        <table>
                            <tr>
                               <td class="gridTableColummHeader_2 bigHeading">Status Report:</td>
                               <td style="width:20px"></td>
                               <td><b>Start Date:</b>&nbsp;</td>
                               <td><input type="text" name="startDate" id="startDate" class="inputGeneralSmall" style="width:80px" value="<%=formatter.format(new Date(startTime)) %>" />&nbsp;</td>
                               <td>
                                    <img src="<%=ar.retPath %>/jscalendar/img.gif" id="startDateImg" style="cursor: pointer;" title="Date selector"/>
                               </td>
                               <td style="width:20px"></td>
                               <td><b>End Date:</b>&nbsp;</td>
                               <td><input type="text" name="endDate" id="endDate" class="inputGeneralSmall" style="width:80px" value="<%=formatter.format(new Date(endTime)) %>"/>&nbsp;</td>
                               <td>
                                  <img src="<%=ar.retPath %>/jscalendar/img.gif" id="endDateImg" style="cursor: pointer;" title="Date selector"/>
                               </td>
                               <td style="width:20px"></td>
                               <td><input type="button" class="inputBtn" value="Generate" onclick="generateReoprt()" /></td>
                            </tr>
                        </table>
                    </form>
                </div>
                <div class="paginationBar"><< <a href="">first</a> < <a href="">prev</a>&nbsp;&nbsp;&nbsp;<b>1</b>&nbsp;&nbsp;&nbsp;<a href="">next</a> > <a href="">last</a> >></div>
                   <table width="100%" class="statusReport" border="0">
                       <tr>
                           <th style="width:240px">Goal</th>
                           <th style="width:100px">Assigned To</th>
                           <th style="width:70px">% Done</th>
                           <th style="width:80px">Due Date</th>
                           <th style="width:80px">Est/Actual Date</th>
                       </tr>

                        <% outputStatusReport(ar, taskList, ngp, 1, thisPageAddress, max, startTime, endTime);%>


                   </table>
                   <br /><br /><br />
                   <div class="generalHeadingBorderLess" style="padding-bottom:5px;">Goals in Sub Projects:</div>
                   <div class="paginationBar"><< <a href="">first</a> < <a href="">prev</a>&nbsp;&nbsp;&nbsp;<b>1</b>&nbsp;&nbsp;&nbsp;<a href="">next</a> > <a href="">last</a> >></div>
                   <table width="100%" class="statusReport">
                       <tr>
                           <th style="width:240px">Goal in Sub Projects</th>
                           <th style="width:100px">Assigned To</th>
                           <th style="width:70px">% Done</th>
                           <th style="width:80px">Due Date</th>
                           <th style="width:80px">Est/Actual Date</th>
                       </tr>

                         <% subOutputStatusReport(ar, taskList, ngp, 1, thisPageAddress, max, startTime, endTime);%>

                   </table>
                   <div class="generalHeadingBorderLess" style="padding-bottom:5px;">Super Project:</div>
                   <div class="paginationBar"></div>
                   <table width="100%" class="statusReport">
                       <tr>
                           <th style="width:240px">Goal in Sub Projects</th>
                           <th style="width:100px">Assigned To</th>
                           <th style="width:70px">% Done</th>
                           <th style="width:80px">Due Date</th>
                           <th style="width:80px">Est/Actual Date</th>
                       </tr>

                        <% superStatusReport(ar, taskList, ngp, 1, thisPageAddress, max, startTime, endTime);%>

                   </table>
            </div>
        </div>
    </div>
</div>
<%
SectionTask.plugInCalenderScript(out, "startDate", "startDateImg");
SectionTask.plugInCalenderScript(out, "endDate", "endDateImg");
SectionTask.plugInDurationCalcScript(out);
%>
<%!public void outputStatusReport(AuthRequest ar, List<GoalRecord> taskList, NGPage ngp, int level, String thisPageAddress,
        int max, long startTime, long endTime) throws Exception
    {
        if (taskList.size()>0)
        {
            for (GoalRecord task : taskList)
            {
                //tasks with parents will be handled recursively
                //as long as parent setting is valid
                if (!task.hasParentGoal() )
                {
                    outputStatusReportItem(ar, taskList, ngp, task, level, thisPageAddress, max, startTime, endTime);
                }
            }
        }
        else
        {
            ar.write("\n<tr><td><i>no tasks in this process</i></td></tr>");
        }
    }


    public void subOutputStatusReport(AuthRequest ar, List<GoalRecord> taskList, NGPage ngp, int level, String thisPageAddress,
            int max, long startTime, long endTime)
            throws Exception
    {
        if (taskList.size()==0)
        {
            ar.write("\n<tr><td><i>no tasks in this process</i></td></tr>");
            return;
        }
        for (GoalRecord task : taskList)
        {
            String sub = task.getSub();
            if (sub==null ||sub.length()==0) {
                continue;
            }
            String pageid = getKeyFromURL(sub);
            if (pageid==null) {
                throw new ProgramLogicError("pageid is null for sub="+sub);
            }

            NGPageIndex subpage = NGPageIndex.getContainerIndexByKey(pageid);
            if (subpage==null) {
                subpage = NGPageIndex.getContainerIndexByKey(pageid.toLowerCase());
                if (subpage==null) {
                    continue;  //ignore it, bad URL
                }
            }
            String projectUrl = ar.getResourceURL(subpage, "statusReport.htm");

            ar.write("\n<tr>");
            ar.write("\n<td class=\"linkedProject\" colspan=\"5\"><img src=\"");
            ar.write(ar.retPath+"/assets/images/leaf.gif\" ");
            ar.write(" \" alt=\"\" />");
            ar.write(" &nbsp;<a href=\"");
            ar.writeHtml(ar.retPath);
            ar.writeHtml(projectUrl);
            ar.write("\">");
            ar.writeHtml(subpage.containerName);

            ar.write("</a></td></tr>");

            NGPage subProject = subpage.getPage();
            outputStatusReport(ar, subProject.getAllGoals(), subProject, level+1, thisPageAddress, max, startTime, endTime);
        }
    }

    public void outputStatusReportItem(AuthRequest ar, List<GoalRecord> taskList, NGPage ngp,
                  GoalRecord task, int level, String thisPageAddress, int max,
                  long startTime, long endTime)
        throws Exception
    {
        List<HistoryRecord> histRecs = task.getTaskHistoryRange(ngp, startTime, endTime);
        if (task.getState() == BaseRecord.STATE_ACCEPTED || histRecs.size()>0){
            ar.write("\n<tr class=\"taskReportArea\">");
            ar.write(" <td class=\"reportTitle\">");
            writeTaskStateIcon(ar, task);
            ar.write(" <span>");
            ar.writeHtml(task.getSynopsis());
            ar.write("</span>");

            ar.write("</td><td>");
            writeAssignees(ar, task, ngp);

            ar.write("</td><td>");
            ar.write(String.valueOf(task.getPercentComplete()));

            ar.write("</td><td>");
            ar.write(((task.getDueDate()==0)?"":new SimpleDateFormat("MM/dd/yyyy").format(new Date(task.getDueDate()))));

            ar.write("</td><td>");
            ar.write(((task.getEndDate()==0)?"":new SimpleDateFormat("MM/dd/yyyy").format(new Date(task.getEndDate()))));
            ar.write("</td></tr>\n");

            //now write out the history/status/accomplishments
            ar.write("<tr><td colspan=\"5\">\n");
            ar.write("\n<div class=\"reportDescription\">");
            if(task.getSub().length()!= 0){
                String pageidValue = getKeyFromURL(task.getSub());
                if (pageidValue==null) {
                    throw new ProgramLogicError("pageid is null for sub="+task.getSub());
                }

                NGPageIndex isSubpage = NGPageIndex.getContainerIndexByKey(pageidValue);
                if (isSubpage!=null){
                    NGPageIndex ngpIndex = NGPageIndex.getContainerIndexByKey(isSubpage.getPage().getKey());
                    String projectUrl = ar.getResourceURL(ngpIndex, "history.htm");

                    ar.write("\n<b>Subproject:</b>\n<p>");
                    ar.write("\n &nbsp;&nbsp;<img src=\"");
                    ar.writeHtml(ar.retPath);
                    ar.write("assets/images/leaf.gif\">");

                    ar.write("\n &nbsp;<a href=\"");
                    ar.writeHtml(ar.retPath);
                    ar.writeHtml(projectUrl);
                    ar.write("\">");
                    ar.writeHtml(ngpIndex.containerName);
                    ar.write("</a></p>");
                }
            }
            String status = task.getStatus();
            if (status!=null && status.length()>0) {
                ar.write("\n<b>Status:</b>\n<p>");
                ar.writeHtmlWithLines(task.getStatus());
                ar.write("</p>");
            }
            if (histRecs.size()>0) {
                ar.write("\n<b>Accomplishments:</b>\n<p>");
                for (HistoryRecord history : histRecs) {
                    String msg = history.getComments();
                    if(msg==null || msg.length()==0) {
                        msg=HistoryRecord.convertEventTypeToString(history.getEventType());
                    }
                    SectionUtil.nicePrintDateAndTime(ar.w, history.getTimeStamp());
                    ar.write("&nbsp;");
                    ar.writeHtmlWithLines(msg);
                    ar.write("<br />");
                }
                ar.write("</p>");
            }
            ar.write("\n</div>");
            ar.write("\n</td></tr>\n");

        }


        //check for subtasks
        for (GoalRecord child : task.getSubGoals())
        {
            outputStatusReportItem(ar, taskList, ngp, child, level+1, thisPageAddress, max, startTime, endTime);
        }
    }

    public void superStatusReport(AuthRequest ar, List<GoalRecord> taskList, NGPage ngp, int level, String thisPageAddress,
            int max, long startTime, long endTime)
            throws Exception
    {

    }%>
