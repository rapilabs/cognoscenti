<%@page errorPage="/spring/jsp/error.jsp"
%><%@include file="UserProfile.jsp"
%><%@page import="com.fujitsu.loginapplication.service.LoginServlet"
%><%@page import="org.socialbiz.cog.ConfigFile"
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

    String key = uProf.getKey();
    String name = uProf.getName();
    String desc = uProf.getDescription();

    String photoSrc = ar.retPath+"assets/photoThumbnail.gif";
    if(uProf.getImage().length() > 0){
        photoSrc = ar.retPath+"users/"+uProf.getImage();
    }

    String autoLoginCookie = ar.findCookieValue("autoLoginCookie");
    String openIdCookie = ar.findCookieValue("openIdCookie");

    String thisPage = ar.getCompleteURL();
    String ssofiLogin = "";
    if (viewingSelf) {
        ssofiLogin = LoginServlet.getAddIdURL(thisPage, thisPage, "only_tenant");
    }
    String emailOpenIDProvider = ConfigFile.getProperty("emailOpenIDProvider");
    String visitLoginPrompt = "";
    String prefEmail = uProf.getPreferredEmail();
    String remoteProfileURL = ar.baseURL+"apu/"+uProf.getKey()+"/user.json";

%>
<div class="content tab01" style="display:block;" >
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="Change" style="border:1px solid red;display: none;">
            <div class="generalSettings">
                <form name="ChangePasswordForm" id="ChangePasswordForm" action="<%=ar.baseURL%>t/changePasswordAction.form" method="post" >
                    <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                    <input type="hidden" name="go" id="go" value="<%=ar.getCompleteURL()%>"/>
                    <input type="hidden" name="option" id="option" value='Save Profile' />
                    <table border="0px solid red" class="popups">
                        <tr>
                            <td width="148" class="gridTableColummHeader">Unique Id:</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2"><input type="hidden" name="key"
                                value="<% ar.writeHtml(key);%>" size="50"/><% ar.writeHtml(key);%></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td width="148" class="gridTableColummHeader">Full Name (for display):</td>
                            <td  style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="userName" class="inputGeneral" size="69" value="<% ar.writeHtml(name);%>" /></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader">Email Address:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                            <%  if(prefEmail != null)
                                    ar.writeHtml(prefEmail);
                                else
                                    ar.writeHtml("No Email Address");
                            %>
                            </td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader">Password:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="password" id="p1" name="password" value="" size="30" class="inputGeneral"/></td>
                        </tr>
                        <tr><td style="height:5px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader">Re-enter Password:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="password" id="p2" name="password2" value="" size="30" class="inputGeneral" /></td>
                        </tr>
                        <tr><td style="height:30px"></td></tr>
                        <tr>
                            <td class="gridTableColummHeader"></td>
                            <td style="width:20px;"></td>
                            <td colspan="2">
                            <input type="submit" class="inputBtn"
                                value="<fmt:message key="nugen.button.general.save" />"
                                onclick="return validate();">
                            <input type="button" class="inputBtn"
                                value="<fmt:message key="nugen.button.general.cancel" />"
                                onclick="return cancelPanel();">
                            </td>
                        </tr>
                    </table>
                </form>
            </div>
        </div>
        <!-- Content Area Starts Here -->
        <div class="generalArea">
            <div class="pageSubHeading">
                <table width="100%">
                    <tr>
                        <td rowspan="2" width="57px"><img src="<%ar.writeHtml(photoSrc);%>" width="50" height="50"/></td>
                        <td colspan="3">
                            <div class="pageHeading">
                                <%
                                if(name.length() != 0){ %>
                                <fmt:message key="nugen.userprofile.UserDetails">
                                    <fmt:param value="<%=name%>"/>
                                </fmt:message>
                                <%
                                }else{
                                %>
                                <fmt:message key="nugen.userprofile.UserDetailsNoName"></fmt:message>
                                <%
                                }
                                %>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <%if (viewingSelf){ %>
                            <td>From here you can view your own profile settings. </td>
                        <%}else{ %>
                            <td>You are viewing <% ar.writeHtml(name);%>'s profile. </td>
                        <%} %>
                        <td></td>
                        <td align="right">
                            <% if (viewingSelf) {

                            %>
                               <div style="float:right">
                               <img src="<%=ar.retPath%>assets/iconChangePassword.gif" alt="" />
                               <a href="<%= ssofiLogin %>" >Add Another ID</a>&nbsp;&nbsp;&nbsp;
                               <img src="<%=ar.retPath%>assets/iconEditProfile.gif" alt="" />
                               <a href="editUserProfile.htm?u=<%ar.writeURLData(key);%>">Update Settings</a>
                               &nbsp;

                               </div>
                           <%} %>
                       </td>
                    </tr>
                  </table>
                  <%
                 if (uProf.getDisabled())
                 {
                     %><p><img src="<%=ar.baseURL%>warning.gif">&nbsp;<fmt:message key="nugen.userprofile.UserDisabled"/></p><%
                 }
                 if (uProf.getPreferredEmail()==null)
                 {
                     %><p><img src="<%=ar.baseURL%>warning.gif">&nbsp;<fmt:message key="nugen.userprofile.NoEmail"/></p><%
                 }
                 if (uProf.getName()==null || uProf.getName().length()==0)
                 {
                     %><p><img src="<%=ar.baseURL%>warning.gif">&nbsp;<fmt:message key="nugen.userprofile.NoDisplayName"/></p><%
                 }

                %>
            </div>
            <div class="generalSettings">
                <table border="0px solid red" class="popups">
                    <tr>
                        <td width="148" class="gridTableColummHeader"><fmt:message key="nugen.userprofile.Name"/>:</td>
                        <td width="39" style="width:20px;"></td>
                        <td><% ar.writeHtml(name);%></td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader"><fmt:message key="nugen.userprofile.Description"/>:</td>
                        <td style="width:20px;"></td>
                        <td><% ar.writeHtml(desc);%></td>
                    </tr>
                    <% //above this is public, below this only for people logged in
                    if (ar.isLoggedIn()) { %>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader"><fmt:message key="nugen.userprofile.PreferredEmail"/>:</td>
                        <td style="width:20px;"></td>
                        <td><%
                            ar.writeHtml(prefEmail);
                            if (emailOpenIDProvider!=null) {
                                %> [<a href="<%
                                ar.write(emailOpenIDProvider);
                                ar.write(prefEmail);
                                %>">Visit Login Site</a>] <%
                            }
                            %></td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader" valign="top">Alternate Email:</td>
                        <td style="width:20px;"></td>
                        <td valign="top">
                            <table>
                                <%
                                for (IDRecord anid : uProf.getIdList())
                                {
                                    if ((anid.isEmail()) && (!anid.getLoginId().equals(prefEmail)))
                                    {
                                    %>
                                        <tr><td><%
                                        ar.writeHtml(anid.getLoginId());
                                        if (emailOpenIDProvider!=null) {
                                            %> [<a href="<%
                                            ar.write(emailOpenIDProvider);
                                            ar.write(anid.getLoginId());
                                            %>">Visit Login Site</a>] <%
                                        }
                                        %></td></tr>
                                    <%
                                    }
                                }
                                %>
                            </table>
                        </td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader" valign="top">Open Id:</td>
                        <td style="width:20px;"></td>
                        <td valign="top">
                            <table>
                                <%
                                for (IDRecord anid : uProf.getIdList())
                                {
                                    if (!anid.isEmail())
                                    {
                                    %>
                                    <tr>
                                        <td>
                                            <a href="<%ar.writeHtml(anid.getLoginId());%>"><%ar.writeHtml(anid.getLoginId());%></a>
                                        </td>
                                    </tr>
                                    <%
                                    }
                                }
                                %>
                            </table>
                        </td>
                    </tr>
                    <tr><td style="height:15px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader">Last Login:</td>
                        <td style="width:20px;"></td>
                        <td><%SectionUtil.nicePrintTime(ar.w, uProf.getLastLogin(), ar.nowTime); %> as <% ar.writeHtml(uProf.getLastLoginId()); %> </td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader">Remote URL:</td>
                        <td style="width:20px;"></td>
                        <td><a href="<%=remoteProfileURL%>"><%=remoteProfileURL%></a></td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader"><fmt:message key="nugen.userprofile.Id"/>:</td>
                        <td style="width:20px;"></td>
                        <td><% ar.writeHtml(key);%></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader"></td>
                        <td></td><td><hr><i>Settings in cookies in this browser:</i><br/>&nbsp;</td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader"><fmt:message key="nugen.userprofile.AutoLogin"/>:</td>
                        <td style="width:20px;"></td>
                        <%
                        if((autoLoginCookie!=null)&&(autoLoginCookie.equals("true"))){ %>
                        <td>
                            <form id="clearCookie" action="clearCookie.form" method="post">
                                <table>
                                    <tr>
                                        <td>ON</td>
                                        <td width="5px">&nbsp;</td>
                                        <td><input type="submit" class="inputBtn" value="Turn Off"/></td>
                                        <td><% ar.writeHtml(openIdCookie); %></td>
                                    </tr>
                                </table>
                            </form>
                        </td>
                        <%}else{%>
                        <td>OFF</td>
                        <%} %>
                    </tr>
                    <%} %>
                </table>
            </div>
        </div>
    </div>
</div>
