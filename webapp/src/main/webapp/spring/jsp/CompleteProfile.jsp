<%@ include file="/spring/jsp/include.jsp"
%><%@ page import="org.socialbiz.cog.ProfileRequest"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%>
<%
    /*
     Required parameter:

     1. go       : This is used to pass as hidden parameter so that when form is submitted controller
                   can redirect to the url (go value).
     2. redirectPageURL: This is the redirect url used when click on logout link (another go value).
     3. up       : This is UserProfile of logged in user.
     4. popupMsg : This contain the messgae(if any) to show in the pop up created on body load.
     */


    String redirectPageURL = ar.retPath+"t/EmailLoginForm.htm?go="+ar.retPath+"t/index.htm";
    UserProfile up = ar.getUserProfile();
    String go  =  ar.defParam("go",ar.retPath+"t/"+up.getKey()+"/watchedProjects.htm");
    String popupMsg = request.getParameter("popupMsg");
%>

<body class="yui-skin-sam" onload="createPopUp()">
    <div class="generalArea">
        <div class="pageHeading">Complete Your Profile</div>
        <div class="pageSubHeading">All your future project related
            correspondence will be done through your registered email id, therefore
            please complete your profile</div>
        <div class="alertMessageArea">
            <span class="alertMessageYellow">You
            have been logged in with <b><%ar.writeHtml(up.getLastLoginId()); %></b> but you don't
            have any profile.</span><br />
            Please complete your profile in order to receive project related email
            notifications.<br />
            <br />
            <b>Note:</b> By opting any of the two below mentioned options, your
            logged in "openid" will be saved automatically in your profile. If you
            do not wish to save your logged in openid, you can immediately <a
            href="<%=ar.retPath%>t/LogoutAction.htm?go=<%ar.writeURLData(redirectPageURL);%>"><b>Log Out</b></a> to skip this action.
        </div>
        <div class="generalSettings">
            <div class="generalHeading">
                <span style="color: #808080">Option 1:</span> Associate with your existing profile
            </div>
            <div class="generalContent">You can link with your existing
                profile by just confirming your email address and password.
            </div>
            <form name="completeProfile" id="completeProfile" action="completeProfile.form" method="post">
                <input type="hidden" name="go" value="<% ar.writeHtml(go);%>" />
                <table border="0px solid red" width="100%">
                    <tr>
                        <td style="height: 30px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3">Email Address:</td>
                        <td style="width: 20px;"></td>
                        <td><input type="text" class="inputGeneral" name="email" /></td>
                    </tr>
                    <tr>
                        <td style="height: 10px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3">Password:</td>
                        <td style="width: 20px;"></td>
                        <td>
                            <input type="password" class="inputGeneral" name="password" />
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 10px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3"></td>
                        <td style="width: 20px;"></td>
                        <td>
                            <input type="submit" class="inputBtn" name="action" value="Link with Existing Profile" />
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 50px"></td>
                    </tr>
                </table>
            </form>
            <div class="generalHeading">
                <span style="color: #808080">Option 2:</span> Create a new profile
            </div>
            <div class="generalContent">If you do not have any existing
                profile or do not want to associate with your existing profile, you can
                directly create a new profile.
            </div>
            <form name="createProfile" id="createProfile" action="createProfile.form" method="post">
                <input type="hidden" name="u" value="<% ar.writeHtml(up.getKey());%>" />
                <table border="0px solid red" width="100%">
                    <tr>
                        <td style="height: 30px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3">Full Name:</td>
                        <td style="width: 20px;"></td>
                        <td><input type="text" id="txtBoxName" class="inputGeneral" name="name" /></td>
                    </tr>
                    <tr>
                        <td style="height: 10px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3">Email Address:</td>
                        <td style="width: 20px;"></td>
                        <td><input type="text" id="txtBoxEmailId" class="inputGeneral" name="email" /></td>
                    </tr>
                    <tr>
                        <td style="height:10px"></td>
                    </tr>
                    <tr>
                        <td class="gridTableColummHeader_3"></td>
                        <td style="width: 20px;"></td>
                        <td>
                            <input type="button" class="inputBtn" name="action" value="Save New Profile" onclick="addEmailId()"/>
                        </td>
                    </tr>
                    <tr>
                        <td style="height: 30px"></td>
                    </tr>
                </table>
            </form>
        </div>
        <div class="generalSettings" id="popupDiv" style="display: none;">
        <table>
            <tr><td style="height:10px"></td></tr>
            <tr>
                <td style="padding-left:50px; padding-right:50px"><img src="<%=ar.retPath %>assets/iconAlertSmall.gif" alt="" /><br /><br /><br />
                    <div style="font-size:14px; font-weight:bold" class="red">Your input details does not match with any of the existing profile.</div><br />
                    Please enter correct email address and password.
                </td>
            </tr>
            <tr><td style="height:30px"></td></tr>
        </table>
    </div>
    <div class="generalSettings" id="successDiv" style="display: none;">
        <table>
            <tr><td style="height:10px"></td></tr>
            <tr>
                <td style="padding-left:50px; padding-right:50px"><div style="font-size:14px; font-weight:bold">Welcome! <span class="red"><%=up.getName() %></span>,</div><br />
                Your openid <b><%ar.writeHtml(popupMsg); %></b> is now successfully associated with your existing profile.
                </td>
            </tr>
            <tr><td style="height:30px"></td></tr>
        </table>
    </div>
    </div>
</body>
<!-- Content Area Ends Here -->
<script>

    var message = '<%= popupMsg %>';
    var path  = '<%= go %>';
    function createPopUp(){
        if(message!= 'null'){
            if(message=='err')
            {
                var bodyText= document.getElementById("popupDiv").innerHTML;
                createPanel("Error Message", bodyText, "500px");
            }else{
                var bodyText= document.getElementById("successDiv").innerHTML;
                createPanel("OpenId Added Successfully", bodyText, "500px");
                myPanel.beforeHideEvent.subscribe(function() {
                    window.location = path;
                });
            }
        }
    }

    function addEmailId(){
        var newid = document.getElementById("txtBoxEmailId").value;
        var name = document.getElementById("txtBoxName").value;

        var go = "<%=ar.baseURL %>v/<%=up.getKey()%>/confirmedAddIdView.htm?addedEmailId="+newid;
        var postURL = "<%=ar.baseURL %>t/createProfile.ajax?newid="+newid+"&isEmail=true&go="+encodeURI(go)+"&name="+encodeURI(name);
        var transaction = YAHOO.util.Connect.asyncRequest('POST', postURL, addEmailIdResult);
    }
    var  addEmailIdResult = {
           success: function(o) {
           var respText = o.responseText;
           var json = eval('(' + respText+')');
           if(json.msgType == "success"){
               var gotoPage  = "<%=ar.getRequestURL()%><%=getAllQueryParams(ar.req)%>";
               var option = '<%=ProfileRequest.getPromptString(ProfileRequest.ADD_EMAIL)%>';
               openSubPanel('Confirmation',json.newId , option ,'550px');
           }else{
               showErrorMessage("Result", json.msg , json.comments );
           }

       },
       failure: function(o) {
               alert("createProfile.ajax Error:" +o.responseText);
       }
    }

    function openSubPanel(header,email,option,panelWidth){
        var onclick = "goForConfirmation('"+option+"','"+email+"')";
        var bodyText =  '<div id="errorDiv" style="color:red; font-style:italic; font-size:11px;">'+
            '</div>'+
            '<div class="generalPopupSettings">'+
                '<form action="<%=ar.baseURL%>t/waitForEmailAction.form" method="post">'+
                '<table> '+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td colspan="3">An email message has been sent to <b>'+email+'</b> <br/>'+
                        'with a confirmation key in it. Check your mail box and click on the link provided or copy the confirmation key into the following box.'+
                        '</td>'+
                    '</tr>'+
                    '<tr><td style="height:20px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader_2">Email:</td>'+
                        '<td style="width:20px;"></td>'+
                        '<td><b>'+email+'</b></td>'+
                    '</tr>'+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader_2">Confirmation Key:</td>'+
                        '<td style="width:20px;"></td>'+
                        '<td><input type="text" id="mn" name="mn" value="" size="50"></td>'+
                    '</tr>'+
                    '<tr><td style="height:10px"></td></tr>'+
                    '<tr>'+
                        '<td class="gridTableColummHeader_2"></td>'+
                        '<td style="width:20px;"></td>'+
                        '<td>'+
                        '<input type="submit" class="inputBtn" value="Add Email">'+
                        '</td>'+
                    '</tr>'+
                    '<tr><td style="height:20px"></td></tr>'+
                    '<tr>'+
                        '<td colspan="3">After putting the correct confirmation key & pressing the "Add Email" button will allow you to reset'+
                        ' the password of the specified email address.'+
                        '<hr/>'+
                        'If you are done waiting, use this link to <a href="#" onclick="subPanel.hide();">return</a>.'+
                        '</td>'+
                    '</tr>'+
                '</table>'+
                '<input type="hidden" id="go" name="go" value="<%ar.write(go);%>">'+
                '<input type="hidden" id="email" name="email" value="'+email+'">'+
                '<input type="hidden" id="option" name="option" value="'+option+'">'+
                '</form>'+
            '</div>';
        subPanel = new YAHOO.widget.Panel("win", {
                                                width: panelWidth ,
                                                fixedcenter: true,
                                                constraintoviewport: true,
                                                underlay: "shadow",
                                                close: true,
                                                visible: false,
                                                draggable: true,
                                                modal: true
                                            });
        subPanel.setHeader(header);
        subPanel.setBody(bodyText);
        subPanel.render(document.body);
        subPanel.show();
    }

    function goForConfirmation(option, email,confkeyObj){
        if(confkeyObj != null && trimme(confkeyObj.value) != ""){
            var postURL = "<%=ar.retPath %>t/confirmEmail.ajax?email="+email+"&go=<%ar.writeURLData(go);%>&option="+option+"&mn="+confkeyObj.value;
            var transaction = YAHOO.util.Connect.asyncRequest('POST', postURL,confirmationResult);
        }else{
            alert("Please enter confirmation key.");
            return false;
        }

    }

    var confirmationResult = {
        success: function(o) {
                        var respText = o.responseText;
                        var json = eval('(' + respText+')');
                        if(json.msgType == "success"){
                            alert("Email id has been added successfully.");
                            subPanel.hide();
                        }else{
                             document.getElementById("errorDiv").innerHTML = responseTxt[1];
                             return false;
                        }
         },
         failure: function(o) {
                    alert("confirmEmail.ajax Error:" +o.responseText);
         }
     }


</script>

