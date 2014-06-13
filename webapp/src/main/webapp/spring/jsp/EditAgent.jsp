<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%@page import="org.socialbiz.cog.AgentRule"
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
    String id = ar.reqParam("id");
    AgentRule theAgent = uPage.findAgentRule(id);
    if (theAgent==null) {
        throw new Exception("Unagle to find an agent with id="+id);
    }

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
        <div class="generalHeading">Edit Agent</div>
        <div style="height:10px;"></div>
        <div id="NewAgent" style="border:1px solid red;">
            <div class="generalSettings">
                <form name="newProfile" id="newProfile" action="AgentAction.form" method="post">
                    <input type="hidden" name="go" id="updateGo" value="<%ar.writeHtml(ar.getCompleteURL());%>">
                    <input type="hidden" name="act" value="Create">
                    <table>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">Name:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="name" class="inputGeneral" size="69"
                                value="<%ar.writeHtml(theAgent.getTitle());%>"/></td>
                        </tr>
                        <tr><td style="height:10px"></td></tr>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">Expression:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="text" name="expression" class="inputGeneral" size="69"
                                value="<%ar.writeHtml(theAgent.getExpression());%>"/></td>
                        </tr>
                        <tr><td style="height:10px"></td></tr>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">Option:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><input type="checkbox" name="accept"/> Auto-Accept
                                <input type="checkbox" name="transform"/> Schema Transform
                                <input type="checkbox" name="normalize"/> Normalize</td>
                        </tr>
                        <tr><td style="height:10px"></td></tr>
                        <tr id="trspath">
                            <td class="gridTableColummHeader">Template:</td>
                            <td style="width:20px;"></td>
                            <td colspan="2"><select name="refresh"/>
                                <option>Regular Plan</option>
                                <option>Long Plan</option>
                                <option>Short Plan</option></select>
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


    </div>
</div>
<script type="text/javascript">

    function confirmDeletion(id, name){
        form = document.getElementById(id);
        if(confirm("Do you want to delete the agent with following expression? \n-- '"+name+"'")) {
            form.submit();
            return true;
        }
        else {
            return false;
        }
    }

</script>

