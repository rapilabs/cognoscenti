<%@ include file="/spring/jsp/include.jsp"
%><%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameter:

    1. go : This is used to pass as hidden parameter so that when form is submitted controller
        can redirect to the url (go value) in case of 'Cancel'.
*/
    ar.assertLoggedIn("Must be logged in to set your password");
    String go    = ar.reqParam("go");


    //find the user profile for this.  Must look up by key because
    //there may be more than one user profile claiming that email
    //address.  The key will be the one that requested this confirmation
    //of the email address.
    UserProfile up2 = ar.getUserProfile();

    String password = up2.getPassword();
    boolean hasPassword = (password!=null && password.length()>0);

%>
<script type="text/javascript" language = "JavaScript">

function changePassword(op){
        document.getElementById('option').value=op;
    }

</script>
<div class="pageHeading">Change Your Password</div>
<div class="pageSubHeading">From here you can change your password.</div>
<div class="generalSettings">
    <table>
        <form id="ChangePassword" action="<%=ar.retPath%>t/changePasswordAction.form" method="post" onsubmit="return validate();">
        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
        <input type="hidden" name="go" value="<% ar.writeHtml(go); %>"/>
        <input type="hidden" name="option" id="option" value='' />
        <tr>
            <td width="148" class="gridTableColummHeader">Unique Id:</td>
            <td  style="width:20px;"></td>
            <td colspan="2"><input type="hidden" name="key"
            value="<% ar.writeHtml(up2.getKey()); %>" size="50"/><% ar.writeHtml(up2.getKey()); %></td>
        </tr>
        <tr><td style="height:5px"></td></tr>
        <tr>
            <td width="148" class="gridTableColummHeader">Full Name (for display):</td>
            <td  style="width:20px;"></td>
            <td colspan="2"><input type="text" name="userName" class="inputGeneral" size="69"
                value="<% ar.writeHtml(up2.getName()); %>" /></td>
        </tr>
        <tr><td style="height:5px"></td></tr>
        <tr>
            <td class="gridTableColummHeader">Email Address:</td>
            <td style="width:20px;"></td>
            <td colspan="2"><% ar.writeHtml(up2.getPreferredEmail()); %></td>
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
                    value="<%ar.writeHtmlMessage("nugen.button.general.save",null); %>"
                    onclick="changePassword('Save Profile')">
                <input type="submit" class="inputBtn"
                    value="<%ar.writeHtmlMessage("nugen.button.general.cancel",null); %>"
                    onclick="changePassword('Return')">
        </tr>
        </form>
    </table>
</div>

<script>

function validate(){
    if (document.getElementById('option').value == "Return"){
        return true;
    }else if (document.getElementById('option').value == "Save Profile"){
        return isNullOrBlank('p1','Password') && isNullOrBlank('p2','Password') && matchPasswords();
    }else {
        return false;
    }
}

function matchPasswords(){
     var check = (document.getElementById("p1").value == document.getElementById("p2").value);
     if(!check)
         alert("Both passwords must be same.");
     return check;
}


</script>

