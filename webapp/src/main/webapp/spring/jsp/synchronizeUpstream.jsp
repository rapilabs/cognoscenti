<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="leaf_ProjectSettings.jsp"
%>
<%
    ar.assertLoggedIn("This VIEW only for logged in use cases");
    ar.assertMember("This VIEW only for members in use cases");
    UserProfile up = ar.getUserProfile();

    String userKey = "";
    if(up!=null){
        userKey = up.getKey();
    }

    Vector<NGPageIndex> templates = new Vector<NGPageIndex>();
    if(uProf != null){
        for(TemplateRecord tr : up.getTemplateList()){
            NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(tr.getPageKey());
            if (ngpi!=null) {
                //silently ignore templates that no longer exist
                templates.add(ngpi);
            }
        }
        NGPageIndex.sortInverseChronological(templates);
    }
    String thisPage = ar.getResourceURL(ngp,"synchronizeUpstream.htm");
    String allTasksPage = ar.getResourceURL(ngp,"projectAllTasks.htm");

    String upstreamLink = ngp.getUpstreamLink();
    Exception upstreamError = null;
    RemoteProject rp = null;
    ProjectSync ps = null;
    try {
        rp = new RemoteProject(upstreamLink);
        ps = new ProjectSync(ngp, rp, ar, ngp.getLicenses().get(0).getId());
    }
    catch (Exception uu) {
        upstreamError = uu;
        PrintWriter pw = new PrintWriter(System.out);
        uu.printStackTrace(pw);
        pw.flush();
    }

%>
    <div class="generalArea">
        <div class="content tab01">

            <div class="generalContent">
                <div class="generalHeading paddingTop">Synchronize with Upstream Project</div>
                <%
                if (upstreamLink==null || upstreamLink.length()==0) {
                    %><i>Set an Upstream link (above) in order to synchronize with an upstream project,<br/>
                    <br/>or..... enter a link to a remote site to create a new clone of this project.</i>


                  <form action="<%=ar.retPath%>Beam1Create.jsp" method="post">
                      <input type="hidden" name="go" value="<%ar.writeHtml(thisPage);%>">
                      <input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
                      <input type="text" name="siteLink" value="" size="50" class="inputGeneral">
                      <input type="submit" name="op" value="Create Remote Upstream Project"  class="inputBtn">
                  </form>

                    <%
                }
                else if (upstreamError!=null)  {
                    %><i>Encountered an error accessing the upstream project: <%ar.writeHtml(upstreamError.toString());%></i>
                    <%
                }
                else {

                    License lic = rp.getLicense();
                    long timeout = lic.getTimeout();
                    int days = (int) ( (timeout-ar.nowTime)/1000/60/60/24 );

                    int docsNeedingDown  = ps.getToDownload(SyncStatus.TYPE_DOCUMENT).size();
                    int docsNeedingUp    = ps.getToUpload(SyncStatus.TYPE_DOCUMENT).size();
                    int docsEqual        = ps.getEqual(SyncStatus.TYPE_DOCUMENT).size();
                    int notesNeedingDown = ps.getToDownload(SyncStatus.TYPE_NOTE).size();
                    int notesNeedingUp   = ps.getToUpload(SyncStatus.TYPE_NOTE).size();
                    int notesEqual       = ps.getEqual(SyncStatus.TYPE_NOTE).size();
                    int goalsNeedingDown = ps.getToDownload(SyncStatus.TYPE_TASK).size();
                    int goalsNeedingUp   = ps.getToUpload(SyncStatus.TYPE_TASK).size();
                    int goalsEqual       = ps.getEqual(SyncStatus.TYPE_TASK).size();
                %>
                <p>Link to project is valid for <%=days%> more day as long as
                    <% ar.writeHtml(lic.getCreator()); %> remains in the
                    <% ar.writeHtml(lic.getRole()); %> role in that project</p>

                <table width="720px">
                  <form action="<%=ar.retPath%>Beam1SyncAll.jsp" method="post">
                  <input type="hidden" name="go" value="<%ar.writeHtml(thisPage);%>">
                  <input type="hidden" name="p" value="<%ar.writeHtml(p);%>">
                    <tr>
                        <td class="gridTableColummHeader_2"></td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">Upload</td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">Download</td>
                        <td style="width:20px;"></td>
                        <td >In Synch</td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2">Documents:</td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(docsNeedingUp>0){%>checked="checked"<%}%>>
                            <%=docsNeedingUp%></td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(docsNeedingDown>0){%>checked="checked"<%}%>>
                            <%=docsNeedingDown%></td>
                        <td style="width:20px;"></td>
                        <td ><%=docsEqual%></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2">Notes:</td>
                        <td style="width:20px"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(notesNeedingUp>0){%>checked="checked"<%}%>>
                            <%=notesNeedingUp%> </td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(notesNeedingDown>0){%>checked="checked"<%}%>>
                            <%=notesNeedingDown%> </td>
                        <td style="width:20px;"></td>
                        <td ><%=notesEqual%></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2">Goals:</td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(goalsNeedingUp>0){%>checked="checked"<%}%>>
                            <%=goalsNeedingUp%> </td>
                        <td style="width:20px;"></td>
                        <td style="width:40px;">
                            <input type="checkbox" name="docsUp" value="yes" <%if(goalsNeedingDown>0){%>checked="checked"<%}%>>
                            <%=goalsNeedingDown%> </td>
                        <td style="width:20px;"></td>
                        <td ><%=goalsEqual%></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_2"></td>
                        <td style="width:20px;"></td>
                        <td> <input type="submit" value="Upload All" name="op" class="inputBtn"> </td>
                        <td style="width:20px;"></td>
                        <td> <input type="submit" value="Download All" name="op" class="inputBtn"> </td>
                        <td style="width:20px;"></td>
                        <td> <input type="submit" value="Ping" name="op" class="inputBtn"> </td>
                    </tr>
                  </form>
                </table>
                <% } %>
            </div>
        </div>
    </div>
</div>
