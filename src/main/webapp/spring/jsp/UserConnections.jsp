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

    Vector<CVSConfig> cvsConnections =  FolderAccessHelper.getCVSConnections();
    Vector<LocalFolderConfig> lclConnections =  FolderAccessHelper.getLoclConnections();
%>
<div class="content tab03" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="NewConnection" style="border:1px solid red;display: none;">
            <div class="generalSettings">
                <form name="newConnection" id="newConnection" action="connectionAction.form" method="post">
                    <input type="hidden" name="go" id="updateGo" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                    <input type="hidden" name="folderId" id="fid" value="CREATE">
                    <input type="hidden" name="action" value="Create Connection">
                    <table>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Protocol:</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2">
                                <input type="radio" name="ptc" id="ptc" value="CVS" onClick="changeForm(this)" /> CVS
                                <input type="radio" name="ptc" id="ptc" value="WEBDAV" checked="checked" onClick="changeForm(this)"/> SharePoint
                                <input type="radio" name="ptc" id="ptc" value="SMB" onClick="changeForm(this)"/> NetWorkShare
                                <input type="radio" name="ptc" id="ptc" value="LOCAL" onClick="changeForm(this)"/> Local
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Connection Name:</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="displayname" id="fname" class="inputGeneral" size="69" /></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">URL:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="serverpath" id="path" class="inputGeneral" size="69" /></td>
                        </tr>

                        <tr  id="trlclroots" style="display:none">

                            <td class="gridTableColummHeader">Local Root:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="lclrootdiv">
                                    <select name="lclroot" id="lclroot" onchange="lclRootChange(this)" style="WIDTH:95%;"/>
                                    <%
                                    String localKey = "";
                                    String initlclfldr = "";
                                    for(int i=0; i<lclConnections.size(); i++){
                                        localKey = lclConnections.get(i).getDisplayName();
                                        String val = lclConnections.get(i).getPath();
                                        if(initlclfldr.length() == 0){
                                            initlclfldr = val;
                                        }
                                    %>
                                        <option value="<%ar.writeHtml(val); %>" /><%ar.writeHtml(localKey); %></option>
                                    <%}%>
                                    </select>
                                    <input type="hidden" name="localRoot" id="localRoot" value="<%ar.writeHtml(localKey); %>" />
                                </div>
                            </td>
                        </tr>
                        <tr  id="trlclfolder" style="display:none">
                            <td class="gridTableColummHeader">Local Folder:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="lclfolderdiv">
                                    <input type="text" name="lclfldr" id="lclfldr" value="<%ar.writeHtml(initlclfldr); %>" style="WIDTH:95%" />
                                </div>
                            </td>
                        </tr>

                        <tr id="trcvsroots" style="display:none">
                            <td class="gridTableColummHeader">CVS Root:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="cvsrootdiv">
                                    <select name="cvsroot" id="cvsroot" onchange="cvsRootChange(this)" style="WIDTH:95%;"/>
                                    <%
                                    String initroot = "";
                                    String initmodule = "";
                                    for(int i=0; i<cvsConnections.size(); i++){
                                        String cvsKey = cvsConnections.get(i).getRoot();
                                        String val = cvsConnections.get(i).getRepository();
                                        if(initroot.length() == 0){
                                            initroot = cvsKey;
                                            initmodule = val;
                                        }
                                    %>
                                    <option value="<%ar.writeHtml(val); %>" /><%ar.writeHtml(cvsKey); %></option>
                                    <%}%>
                                    </select>
                                    <input type="hidden" name="cvsserver" id="cvsserver" value="<%ar.writeHtml(initroot);%>" />
                                </div>
                            </td>
                        </tr>

                        <tr id="trcvsmodule" style="display:none">
                            <td class="gridTableColummHeader">CVS Module:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="cvsmodulediv">
                                    <input type="text" name="cvsmodule" id="cvsmodule" value="<%ar.writeHtml(initmodule);%>" style="WIDTH:95%;" />
                                </div>
                            </td>
                        </tr>

                        <tr><td style="height:5px"></td></tr>
                        <tr id="truid">
                            <td class="gridTableColummHeader">User Id:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="uid" id="uid" class="inputGeneral" size="69" /></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr id="trpwd">
                            <td class="gridTableColummHeader">Password:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="password" id="pwd" name="pwd" value="" size="30" class="inputGeneral" /></td>
                        </tr>
                        <tr><td style="height:30px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"></td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <input type="submit" class="inputBtn"
                                    value="<fmt:message key="nugen.button.general.save" />">
                                <input type="button" class="inputBtn"
                                    value="<fmt:message key="nugen.button.general.cancel" />"
                                    onclick="return cancelPanel();">
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        </div>
        <div id="UpdateConnection" style="border:1px solid red;display: none;">
            <div class="generalSettings">
                <form name="updateConnection" id="updateConnection" action="connectionAction.form" method="post">
                    <input type="hidden" name="folderId" id="fid" value="XXX">
                    <input type="hidden" name="go" id="updateGo" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                    <input type="hidden" name="action" value="Update">

                    <table>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Protocol:</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2">
                                <input type="radio" name="ptc" id="CVS" value="CVS" onchange="changeFormUpdt(this)"/> CVS
                                <input type="radio" name="ptc" id="WEBDAV" value="WEBDAV" onchange="changeFormUpdt(this)"/> Sharepoint
                                <input type="radio" name="ptc" id="SMB" value="SMB"/ onchange="changeFormUpdt(this)"> NetWorkShare
                                <input type="radio" name="ptc" id="LOCAL" value="LOCAL"/ onchange="changeFormUpdt(this)"> Local
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Connection Name:</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="displayname" id="updateName" class="inputGeneral" size="69" /></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr id="trspath_updt">
                            <td class="gridTableColummHeader">URL:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="serverpath" id="updatePath" class="inputGeneral" size="69" /></td>
                        </tr>

                        <tr  id="trlclroots_updt" style="display:none">

                            <td class="gridTableColummHeader">Local Root:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="lclrootdiv">
                                    <select name="lclroot" id="lclroot" onchange="lclRootChange(this)" style="WIDTH:95%;"/>
                                    <%
                                    initlclfldr = "";
                                    for(int i=0; i<lclConnections.size(); i++){
                                        localKey = lclConnections.get(i).getDisplayName();
                                        String val = lclConnections.get(i).getPath();
                                        if(initlclfldr.length() == 0){
                                            initlclfldr = val;
                                        }
                                    %>
                                        <option value="<%ar.writeHtml(val); %>" /><%ar.writeHtml(localKey); %></option>
                                    <%}%>
                                    </select>
                                    <input type="hidden" name="localRoot" id="localRoot"  />
                                </div>
                            </td>
                        </tr>
                        <tr  id="trlclfolder_updt" style="display:none">
                            <td class="gridTableColummHeader">Local Folder:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="lclfolderdiv">
                                    <input type="text" name="lclfldr" id="lclfldr" value="<%ar.writeHtml(initlclfldr); %>" style="WIDTH:95%" />
                                </div>
                            </td>
                        </tr>

                        <tr id="trcvsroots_updt" style="display:none">
                            <td class="gridTableColummHeader">CVS Root:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="cvsrootdiv_updt">
                                    <select name="cvsroot" id="cvsroot" onchange="cvsRootChange(this)" style="WIDTH:95%;"/>
                                    <%
                                    initroot = "";
                                    initmodule = "";
                                    for(int i=0; i<cvsConnections.size(); i++){
                                        String cvsKey = cvsConnections.get(i).getRoot();
                                        String val = cvsConnections.get(i).getRepository();
                                        if(initroot.length() == 0){
                                            initroot = cvsKey;
                                            initmodule = val;
                                        }
                                    %>
                                    <option value="<%ar.writeHtml(val); %>" /><%ar.writeHtml(cvsKey); %></option>
                                    <%}%>
                                    </select>
                                    <input type="hidden" name="cvsserver" id="cvsserver" value="<%ar.writeHtml(initroot);%>" />
                                </div>
                            </td>
                        </tr>

                        <tr id="trcvsmodule_updt" style="display:none">
                            <td class="gridTableColummHeader">CVS Module:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <div id="cvsmodulediv_updt">
                                    <input type="text" name="cvsmodule" id="cvsmodule" value="<%ar.writeHtml(initmodule);%>" style="WIDTH:95%;" />
                                </div>
                            </td>
                        </tr>

                        <tr><td style="height:5px"></td></tr>
                        <tr id="truid_updt">
                            <td class="gridTableColummHeader">User Id:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="uid" id="updateUId" class="inputGeneral" size="69" /></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr id="trpwd_updt">
                            <td class="gridTableColummHeader">Password:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="password" id="updatePwd" name="pwd" value="" size="30" class="inputGeneral" /></td>
                        </tr>
                        <tr><td style="height:30px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"></td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                                <input type="submit" class="inputBtn"
                                    value="<fmt:message key="nugen.button.general.update" />">
                                <input type="button" class="inputBtn"
                                    value="<fmt:message key="nugen.button.general.cancel" />"
                                    onclick="return cancelPanel();">
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        </div>
        <div class="rightDivContent"><img src="<%= ar.retPath%>assets/iconBluePlus.gif" width="13" height="15" alt="" />
        <a href="#" onclick="openModalDialogue('NewConnection','Add New Connection','640px');">Add New Connection</a></div>
        <div class="generalHeading">Document Repository Connections</div>
        <br />
        <table class="gridTable2" width="100%">
            <tr class="gridTableHeader">
                <td width="300px">Connection Name</td>
                <td>Modified</td>
                <td>Update Connection</td>
                <td>Delete Connection</td>
            </tr>
            <% displayUserFolders(ar, uProf); %>
        </table>
    </div>
</div>
    <script type="text/javascript">

        function confirmDeletion(){
            if(confirm("Do you want to delete this connection?")){
                return true;
            }else {
                return false;
            }
        }
        function cvsRootChange(obj){
            document.getElementById("cvsmodule").value = obj.value;
            document.getElementById("cvsserver").value = obj.name;
        }

        function changeForm(obj)
        {
            var checkboxVal = obj.value
            if(checkboxVal == 'WEBDAV' || checkboxVal == 'SMB'){
                document.getElementById("newConnection").serverpath.value='';
                document.getElementById("trspath").style.display='';
                document.getElementById("truid").style.display='';
                document.getElementById("trpwd").style.display='';
                document.getElementById("trlclroots").style.display='none';
                document.getElementById("trlclfolder").style.display='none';
                document.getElementById("trcvsroots").style.display='none';
                document.getElementById("trcvsmodule").style.display='none';
            }else if(checkboxVal == 'CVS'){
                document.getElementById("trcvsroots").style.display='';
                document.getElementById("trcvsmodule").style.display='';
                document.getElementById("truid").style.display='';
                document.getElementById("trpwd").style.display='';
                document.getElementById("trspath").style.display='none';
                document.getElementById("trlclroots").style.display='none';
                document.getElementById("trlclfolder").style.display='none';
                document.getElementById("newConnection").serverpath.value='cvs';
            }
            else{
                document.getElementById("trlclroots").style.display='';
                document.getElementById("trlclfolder").style.display='';
                document.getElementById("trspath").style.display='none';
                document.getElementById("truid").style.display='none';
                document.getElementById("trpwd").style.display='none';
                document.getElementById("trcvsroots").style.display='none';
                document.getElementById("trcvsmodule").style.display='none';
                document.getElementById("newConnection").serverpath.value='local';
            }
        }
        function lclRootChange(obj){
            document.getElementById("lclfldr").value = obj.value;
            var lclrootObj = document.getElementById("lclroot");
            var index = document.getElementById("lclroot").selectedIndex;
            document.getElementById("localRoot").value =  lclrootObj.options[index].text;
        }

        function createUpdatePanel(popupId,headerContent,panelWidth,protocol,ptc,dName,path,cvsroot, cvsmodule, localRoot,uId,fid,go){
            var   header = headerContent;
            var bodyText= document.getElementById(popupId).innerHTML;
            createPanel(header, bodyText, panelWidth);
            if(protocol == 'CVS'){
                 document.getElementById("CVS").checked = true;
                 changeFormUpdt(document.getElementById("CVS"));
            }else if(protocol == 'WEBDAV' ){
                document.getElementById("WEBDAV").checked = true;
                changeFormUpdt(document.getElementById("WEBDAV"));
            }else if(protocol == 'SMB'){
                document.getElementById("SMB").checked = true;
                changeFormUpdt(document.getElementById("SMB"));
            }else if(protocol == 'LOCAL'){
                document.getElementById("LOCAL").checked = true;
                changeFormUpdt(document.getElementById("LOCAL"));
            }

            document.getElementById("updateName").value = dName;
            document.getElementById("updatePath").value = path;
            document.getElementById("updateUId").value = uId;
            document.getElementById("fid").value = fid;
            document.getElementById("updateGo").value = go;

            document.getElementById("cvsroot").value = cvsroot;
            document.getElementById("cvsmodule").value = cvsmodule;
            var lclrootObj = document.getElementById("lclroot");//.value = localRoot;
            for(i=0; i<lclrootObj.length; i++){
                if(lclrootObj[i].text == localRoot){
                    lclrootObj[i].selected = true;
                    break;
                }
            }
            document.getElementById("lclfldr").value = path;

            myPanel.beforeHideEvent.subscribe(function() {
                if(!isConfirmPopup){
                    window.location = "userProfile.htm?active=3";
                }
            });
        }

        function changeFormUpdt(obj)
        {
            var checkboxVal = obj.value

            if(checkboxVal == 'WEBDAV' || checkboxVal == 'SMB'){
                document.getElementById("updateConnection").serverpath.value='';
                document.getElementById("trspath_updt").style.display='';
                document.getElementById("truid_updt").style.display='';
                document.getElementById("trpwd_updt").style.display='';
                document.getElementById("trcvsroots_updt").style.display='none';
                document.getElementById("trcvsmodule_updt").style.display='none';
                document.getElementById("trlclroots_updt").style.display='none';
                document.getElementById("trlclfolder_updt").style.display='none';
            }else if(checkboxVal == 'CVS'){
                document.getElementById("trcvsroots_updt").style.display='';
                document.getElementById("trcvsmodule_updt").style.display='';
                document.getElementById("truid_updt").style.display='';
                document.getElementById("trpwd_updt").style.display='';
                document.getElementById("trspath_updt").style.display='none';
                document.getElementById("updateConnection").serverpath.value='cvs';
                document.getElementById("trlclroots_updt").style.display='none';
                document.getElementById("trlclfolder_updt").style.display='none';

            }else{
                document.getElementById("trlclroots_updt").style.display='';
                document.getElementById("trlclfolder_updt").style.display='';
                document.getElementById("trspath_updt").style.display='none';
                document.getElementById("truid_updt").style.display='none';
                document.getElementById("trpwd_updt").style.display='none';
                document.getElementById("trcvsroots_updt").style.display='none';
                document.getElementById("trcvsmodule_updt").style.display='none';
                document.getElementById("updateConnection").serverpath.value='local';
            }
        }
    </script>
<%!

    public void displayUserFolders(AuthRequest ar, UserProfile uProf)
    throws Exception {
        try {
            String go = ar.getCompleteURL();

            UserPage uPage = uProf.getUserPage();
            Vector allFolders = uPage.getAllConnectionSettings();

            for (int i = 0; i < allFolders.size(); i++) {
                ConnectionSettings cSet = (ConnectionSettings)allFolders.get(i);
                String dname = cSet.getDisplayName();
                String uid = cSet.getFolderUserId();
                int backSlashIndex = uid.indexOf("\\");
                if(backSlashIndex!= -1){
                    StringBuffer sbUID = new StringBuffer(uid);
                    uid = sbUID.insert(backSlashIndex,"\\").toString();
                }
                String url = cSet.getBaseAddress();
                String ptc = cSet.getProtocol();
                String folderId = cSet.getId();
                long lmodified = cSet.getLastModified();
                String path = ar.retPath + "v/"+ ar.getUserProfile().getKey() +"/userConnections.htm";
                String fdLink = ar.retPath + "v/"+ ar.getUserProfile().getKey() + "/folder"+cSet.getId()+".htm?path="
                        + URLEncoder.encode("/", "UTF-8") + "&encodingGuard=%E6%9D%B1%E4%BA%AC";

                String deleteLink = ar.retPath + "v/"+ ar.getUserProfile().getKey() +"/deleteConnection.form?folderId="
                        + URLEncoder.encode(cSet.getId(), "UTF-8");
                String protocol = cSet.getProtocol();
                String cvsRoot = cSet.getCVSRoot();
                String cvsModule = cSet.getCVSModule();
                String localRoot = cSet.getLocalRoot();
                if(!cSet.isDeleted()){
                    ar.write("\n<tr>");
                    ar.write("\n<td class=\"repositoryName\"><a href=\"");
                    ar.writeHtml(fdLink);
                    ar.write("\">");
                    ar.writeHtml(dname);
                    ar.write("</a></td>");
                    ar.write("\n<td>");
                    SectionUtil.nicePrintTime(ar.w, lmodified, ar.nowTime);
                    ar.write("</td>");
                    ar.write("\n<td><a href=\"#\" onclick=\"createUpdatePanel('UpdateConnection','Update Connection','600px','");
                    ar.writeHtml(protocol);
                    ar.write("','");
                    ar.writeHtml(ptc);
                    ar.write("','");
                    ar.writeHtml(dname);
                    ar.write("','");
                    ar.writeHtml(url);
                    ar.write("','");
                    ar.writeHtml(cvsRoot);
                    ar.write("','");
                    ar.writeHtml(cvsModule);
                    ar.write("','");
                    ar.writeHtml(localRoot);
                    ar.write("','");
                    ar.writeHtml(uid);
                    ar.write("','");
                    ar.writeHtml(folderId);
                    ar.write("','");
                    ar.writeHtml(path);
                    ar.write("')\"><img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconUpdate.gif\" alt=\"\" /></a></td>");
                    ar.write("\n<td><a href=\"");
                    ar.writeHtml(deleteLink);
                    ar.write(" \" onclick=\"return confirmDeletion()\"><img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconDelete.gif\" alt=\"\" /></a></td>");
                    ar.write("\n</tr>");
                }
            }
        } catch (Exception e) {
            throw e;
        }
    }

%>
