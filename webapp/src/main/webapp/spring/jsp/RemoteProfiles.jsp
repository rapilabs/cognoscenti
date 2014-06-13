<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%

    String go = ar.getCompleteURL();
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
    UserPage uPage = uProf.getUserPage();
    List<ProfileRef> remoteRefs = uPage.getProfileRefs();

%>
<body class="yui-skin-sam">

<script type="text/javascript">
    function openModalDialogue(popupId,headerContent,panelWidth){
        var   header = headerContent;
        var bodyText= document.getElementById(popupId).innerHTML;
        createPanel(header, bodyText, panelWidth);
        myPanel.beforeHideEvent.subscribe(function() {
            if(!isConfirmPopup){
                window.location = "<%=ar.getCompleteURL()%>";
            }
        });
    }
</script>

<div class="content tab03" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div id="NewConnection" style="border:1px solid red;display: none;">
            <div class="generalSettings">
                <form name="newProfile" id="newProfile" action="RemoteProfileAction.form" method="post">
                    <input type="hidden" name="go" id="updateGo" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                    <input type="hidden" name="act" value="Create">
                    <table>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">URL:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="address" id="address" class="inputGeneral" size="69" /></td>
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

        <div class="rightDivContent"><img src="<%= ar.retPath%>assets/iconBluePlus.gif" width="13" height="15" alt="" />
        <a href="#" onclick="openModalDialogue('NewConnection','Add Remote Profile','640px');">Add New Remote Profile</a></div>
        <div class="generalHeading">Remote Profiles (for accessing Goals)</div>
        <br />
        <table class="gridTable2" width="100%">
            <tr class="gridTableHeader">
                <td width="300px">Address</td>
                <td>Last Used</td>
                <td>Delete</td>
            </tr>
            <%

            for (ProfileRef oneRef : remoteRefs) {
                %>
                <tr>
                <td class="repositoryName"><a href="<%ar.writeHtml(oneRef.getAddress());%>"><%
                ar.writeHtml(oneRef.getAddress());
                %></a></td>
                <td><%SectionUtil.nicePrintTime(ar.w, oneRef.getLastAccess(), ar.nowTime);%></td>
                <form method="post" action="RemoteProfileAction.form">
                <input type="hidden" name="act" value="Delete">
                <input type="hidden" name="go" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                <input type="hidden" name="address" value="<%ar.writeHtml(oneRef.getAddress());%>">
                <td>
                <button type="submit"><img src="<%=ar.retPath%>assets/iconDelete.gif"/></button>
                </td>
                </form>
                </tr>
                <%
            }

            %>
        </table>
    </div>
</div>
    <script type="text/javascript">

        function confirmDeletion(){
            if(confirm("Do you want to delete this remote profile?")){
                return true;
            }else {
                return false;
            }
        }
    </script>
