<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.NGRole"
%><%@ include file="leaf_account_ProjectSettings.jsp"
%><%@page import="org.socialbiz.cog.BookInfoRecord"
%>
<script type="text/javascript" language = "JavaScript">
    function submitRole(){
    var rolename =  document.getElementById("rolename");

    if(!(!rolename.value=='' || !rolename.value==null)){
        alert("Role Name Required");
            return false;
        }
        document.forms["createAccountRoleForm"].submit();
    }
</script>
<script language="javascript">
    $(document).ready(function(e) {
        try {
            $("body select").msDropDown();
        } catch(e) {
            alert(e.message);
        }
    });
</script>
<script src="<%=ar.baseURL%>jscript/jquery.dd.js" type="text/javascript"></script>
<link rel="stylesheet" type="text/css" href="<%=ar.retPath%>css/dd.css" />
<div class="content tab01">
<%
    if (ar.isLoggedIn())
    {
        NGRole role = ngb.getRoleOrFail("Executives");
%>
<!-- Content Area Starts Here -->
    <c:set var="adminSect"> <fmt:message key="nugen.adminSection.title"/> </c:set>
    <div style="height:20px">&nbsp;</div>
    <div class="generalHeading"><fmt:message key="nugen.generatInfo.AccountNameCaption"/></div>
    <div class="generalContent">
        <form action="changeAccountName.form" method="post">
            <table>
                <tr>
                    <td class="gridTableColummHeader_2">Site Name:</td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="hidden" name="p" value="<%ar.writeHtml(accountId);%>">
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                        <input type="hidden" name="go" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                        <input type="text" class="inputGeneral" name="newName"
                            value="<%writeHtml(out, pageFullName);%>">
                    </td>
                </tr>
                <tr><td height="5px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2"></td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="submit" value='<fmt:message key="nugen.generatInfo.Button.Caption.Admin.ChangePage"/>' name="action" class="inputBtn">

                    </td>
                </tr>
                <tr><td height="10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2" valign="top"><fmt:message key="nugen.generatInfo.Admin.Page.PreviousDelete"/></td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="hidden" name="p" value="<%writeHtml(out,pageFullName);%>">
                        <input type="hidden" name="go" value="<%writeHtml(out,pageAddress);%>">
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC" />
                        <%
                        for (int i = 1; i < names.length; i++) {
                            String delLink = ar.retPath+"t/"+ngb.getKey()
                            + "/$/deletePreviousAccountName.htm?action=delName&p="
                            + URLEncoder.encode(pageFullName, "UTF-8")
                            + "&oldName="
                            + URLEncoder.encode(names[i], "UTF-8");
                            //out.write("<td>");
                            writeHtml(out, names[i]);
                            out.write(" &nbsp; <a href=\"");
                            writeHtml(out, delLink);
                            out.write("\" title=\"delete this name from project\"><img src=\"");
                            out.write(ar.retPath);
                            out.write("assets/iconDelete.gif\"></a><br />\n");
                            //out.write("delicon.gif\"></a><br />\n");
                            //out.write("</td></tr>\n");
                        }
                        %>
                    </td>
                </tr>
            </table>
        </form>
    </div>
    <div class="generalHeading">Site Settings</div>
    <div class="generalContent">
        <form action="changeAccountDescription.form" method="post">
            <input type="hidden" name="p" value="<%writeHtml(out,pageFullName);%>">
            <input type="hidden" name="go" value="<%writeHtml(out,pageAddress);%>">
            <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC" />
            <table>
                <tr><td height="5px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2" valign="top">Site Description:</td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="hidden" name="p" value="<%ar.writeHtml(accountId);%>">
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                        <textarea  name="desc" id="desc" class="textAreaGeneral" rows="4"><%writeHtml(out, ngb.getDescription());%></textarea>
                    </td>
                </tr>
                <tr><td height="5px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2"></td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="submit" value="Change Description" name="action" class="inputBtn" />
                    </td>
                </tr>
                <tr><td height="10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2">Current Theme:</td>
                    <td style="width:20px;"></td>
                    <td>
                        <select name="theme" id="theme">
                        <%
                        for(int i=0;i<=6;i++){
                            String selected = "";
                            if (BookInfoRecord.themePath(i).equals(ngb.getThemePath())) {
                                 selected = "selected=\"selected\"";
                             }
                            String img=ar.retPath+"assets/images/"+BookInfoRecord.themeImg(i);
                            out.write("     <option " + selected + " value=\"" + i + "\"  title=\""+img+"\" >" + BookInfoRecord.themeName(i) + "</option>");
                        }
                        %>
                        </select>
                    </td>
                </tr>
                <tr><td height="5px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2"></td>
                    <td style="width:20px;"></td>
                    <td>
                        <input type="submit" value="Change Theme" name="action" class="inputBtn" />
                    </td>
                </tr>
                <tr><td height="10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2">Site Key:</td>
                    <td style="width:20px;"></td>
                    <td>
                        <% ar.writeHtml(ngb.getKey()); %>
                    </td>
                </tr>
                <tr><td height="10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2">Storage Path:</td>
                    <td style="width:20px;"></td>
                    <td>
                        <% ar.writeHtml(ngb.getPreferredProjectLocation()); %>
                    </td>
                </tr>
                <tr>
                    <td class="gridTableColummHeader_2">Streaming Link:</td>
                    <td style="width:20px;"></td>
                    <td><%
                        License lic = null;
                        for (License test : ngb.getLicenses()) {
                            //just find any one license that is still valid
                            if (ar.nowTime < test.getTimeout()) {
                                lic = test;
                            }
                        }
                        //ok ... since at this time there is no UI for creating licenses
                        //in order to test, we just create a license on the fly here, and
                        //also save the project, which is not exactly proper.
                        //TODO: clean this up
                        if (lic==null) {
                            lic = ngb.createLicense(ar.getBestUserId(), "Owners", ar.nowTime+(1000*60*60*24*365), false);
                            ngb.saveFile(ar, "Created license on the fly for testing purposes");
                        }
                        String link = ar.baseURL + "api/" + ngb.getKey() + "/$/summary.json?lic="+lic.getId();
                        ar.writeHtml(link);
                        %>
                    </td>
                </tr>
            </table>
        </form>
    </div>
    <%
    } else{
    %>
        <p>You must be logged in, in order to see information about users.</p>
    <%} %>
</div>

