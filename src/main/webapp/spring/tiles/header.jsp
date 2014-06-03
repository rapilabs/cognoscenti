<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.ConfigFile"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*

Parameter used :

    1. pageTitle    : Used to retrieve the page title from request.
    2. userKey      : This is Key of user who is logged in.
    3. pageId       : Id of a Project, used to fetch details of Project (NGPage).
    4. book         : This is key of a site, used here to get details of an Site (NGBook).
    5. viewingSelf  : This parameter is used to check if user is viewing himself/herself or other profile.
    6. headerType   : Used to check the header type whether it is from site, project or user on the basis of
                      it corrosponding tabs are displayed
    7. tabId        : This is tabId when the page ie rendered Tab with this id will be selected.
    8. accountId    : This is key of a site, used here to get details of an Site (NGBook).

*/%><%!String pageTitle = null;
    String go="";
    String trncatePageTitle=null;%><%String pageTitle = (String)request.getAttribute("pageTitle");
    String userKey = (String)request.getAttribute("userKey");

    String pageId = (String)request.getAttribute("pageId");
    String bookId = (String)request.getAttribute("book");
    String viewingSelfStr = (String)request.getAttribute("viewingSelf");

    String headerTypeStr = (String)request.getAttribute("headerType");
    String tabId = (String)request.getAttribute("tabId");
    String accountId = (String)request.getAttribute("accountId");

    String headerType = "";
    String serverMode = ConfigFile.getProperty("serverMode");
    if(serverMode == null){
        serverMode = "Production";
    }

    ar.assertNotPost();
    String deletedWarning = "";


    String navImage = ar.retPath+"navigation.jpg";

    NGContainer ngp =null;
    NGBook ngb=null;
    UserProfile userRecord = null;
    if(pageTitle == null && pageId != null){
        ngp  = NGPageIndex.getContainerByKey(pageId);
    }
    if(userKey != null){
        userKey = URLEncoder.encode(userKey);
        headerType = "user";
        userRecord = UserManager.getUserProfileByKey(userKey);
    }


    if (ngp!=null)
    {
        ar.setPageAccessLevels(ngp);
        pageTitle = ngp.getFullName();
        if(ngp instanceof NGPage) {
            ngb = ((NGPage)ngp).getSite();
        }
        else if(ngp instanceof NGBook) {
            ngb = ((NGBook)ngp);
        }
        if (ngp.isDeleted())
        {
            deletedWarning = "<img src=\""+ar.retPath+"deletedLink.gif\"> (DELETED)";
        }
        else if (ngp.isFrozen())
        {
            deletedWarning = " ~ (Frozen)";
        }
    }
    UserProfile uProf = ar.getUserProfile();
    if(viewingSelfStr != null && viewingSelfStr.length() > 0){
        boolean viewingSelf = Boolean.parseBoolean(viewingSelfStr);
        if(!viewingSelf){
            headerType="other";
        }
    }
    if(headerTypeStr != null){
        headerType = headerTypeStr;
    }

    String currentPageURL = ar.getCompleteURL();
    String encodedLoginMsg = URLEncoder.encode("Can't open form","UTF-8");%>
   <script type="text/javascript">
      var retPath ='<%=ar.retPath%>';
      var headerType = '';
      var serverMode = '';
      var book='';
      var pageId = '';
   </script>

    <script type="text/javascript" src="<%=ar.baseURL%>jscript/wiky.js"></script>
    <script type="text/javascript" src="<%=ar.baseURL%>jscript/wiky.lang.js"></script>

    <link rel="stylesheet" href="<%=ar.retPath%>css/autocomplete.css" media="screen" type="text/css">
    <script language="javascript" type="text/javascript" src="<%=ar.retPath%>jscript/autocomplete.js"></script>

    <link href="<%=ar.retPath%>css/lightWindow.css" rel="styleSheet" type="text/css" media="screen" />

    <%if(headerType!=null){ %>
        <script type="text/javascript" language="javascript" src="<%=ar.retPath%>jscript/ddlevelsmenu.js"></script>
    <%} %>


    <%if(headerType.equalsIgnoreCase("index")){ %>
        <script type="text/javascript" src="<%=ar.retPath%>jscript/prototype.js"></script>
        <script type="text/javascript" src="<%=ar.retPath%>jscript/effects.js"></script>
        <script type="text/javascript" src="<%=ar.retPath%>jscript/lightWindow.js"></script>
    <%} %>

    <script type="text/javascript">
    var msg_separator = '<:>';
    var myPanel;
    var subPanel;
    function createPanel(header, bodyText, panelWidth){
        myPanel = new YAHOO.widget.Panel("panel", {
                                                width: panelWidth ,
                                                fixedcenter: true,
                                                constraintoviewport: true,
                                                underlay: "shadow",
                                                close: true,
                                                visible: false,
                                                draggable: true,
                                                modal:true
                                            });
        myPanel.setHeader(header);
        myPanel.setBody(bodyText);
        myPanel.render(document.body);
        myPanel.show();
    }
    function cancelPanel(){
         if(myPanel){
             myPanel.hide();
         }
    }
    var count = 0;
    function autoComplete(e,obj){
        autoAssignTextBox= obj.id;
        actionVal = "<%=ar.retPath%>t/getUsers.ajax";
        if(count == 0){
            doCompletion(e);
            count++;
        }
    }

    function markastemplate(pageId,action,URL,isfreezed){
        if(isfreezed == 'false'){
            var transaction = YAHOO.util.Connect.asyncRequest('POST', URL+"t/markAsTemplate.ajax?pageId="+pageId+"&action="+action, callbackresult);
        }else{
           openFreezeMessagePopup();
        }
    }

    var callbackresult = {
            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    if(typeof(flag)=='undefined'){
                        var action = json.action;
                        var markastemplateObj = document.getElementById("markastemplate");
                        var stopusingtemplateObj = document.getElementById("stopusingtemplate");
                        if(markastemplateObj && stopusingtemplateObj){
                            if(action == "MarkAsTemplate"){
                                markastemplateObj.style.display="";
                                stopusingtemplateObj.style.display="none";
                            }else{
                                markastemplateObj.style.display="none";
                                stopusingtemplateObj.style.display="";
                            }
                        }
                    }
                    else{
                        deleteRow();
                    }
                }
                else{
                    showErrorMessage("Result", json.msg , json.comments );
                }
            },
            failure: function(o) {
                    alert("markAsTemplate.ajax Error:" +o.responseText);
            }
        }

        //  This function is user to sort column which shows "Nice Print Time" (like Lat modfied, visited etc.) in Data Table
        //  In all data table , there should be column name "timePeriod" of type Number
        //  which is the visited/modified time in long/int.
        var sortDates = function(a, b, desc) {
            if(!YAHOO.lang.isValue(a)) {
                return (!YAHOO.lang.isValue(b)) ? 0 : 1;
            }
            else if(!YAHOO.lang.isValue(b)) {
                return -1;
            }
            var comp = YAHOO.util.Sort.compare;
            var compState = comp(a.getData("timePeriod"), b.getData("timePeriod"), desc);
            return compState;
        };

        function onSearch(){
            var  searchtext = trimme(document.getElementById("searchText").value);
            if(searchtext == ""){
                alert("Please enter search text.");
                document.getElementById("searchText").value = "";
                document.getElementById("searchText").focus();
                return false;
            }
            document.getElementById('searchForm').submit();
            return true;
        }




        function showHideReasonDiv(divId)
        {
            var reason_div = document.getElementById(divId);
            if(reason_div != null){
                if(reason_div.style.display=="block"){
                    reason_div.style.display="none";
                }else{
                    reason_div.style.display="block";
                }
            }
            return false;
        }

        function showErrorMessage(title, errorMsg, detailedMsg){
                if(myPanel != null){
                    cancelPanel();
                }

                var body = '<div class="generalArea">'+
                            '<div class="generalContent" align="center">'+
                                '<font size="3px">'+
                                    errorMsg+
                                '</font>'+
                                '<br/><br/>';

                if(typeof(detailedMsg) != 'undefined' && detailedMsg != "" ){
                    body += '<div align="left">'+
                                '<a href="#" onclick="showDetail()">Show Full Detail</a><br/>'+
                                    '<div id="detailErrDiv" style="display:none">'+
                                        '<textarea class="mywidth" rows="12" readonly>'+detailedMsg+'</textarea>'+
                                    '</div>'+
                                    '</div>'+
                                '<br/><br/>';
                }
                 body += '<input type="button" class="inputBtn" value="<fmt:message key="nugen.button.general.ok" />" name="option_btn" onclick="javascript:cancelPanel()"/>'+
                          '</div>'+
                          '</div>';
                createPanel(title,body,(title.length+errorMsg.length+350)+'px');
                myPanel.cfg.setProperty('modal', false);
            }
            function showDetail(){
                if(document.getElementById('detailErrDiv').style.display == 'block'){
                    document.getElementById('detailErrDiv').style.display = 'none';
                }else{
                    document.getElementById('detailErrDiv').style.display = 'block';
                }
            }

        function openFreezeMessagePopup(){
            var popup_title = "Project Frozen";
            var popup_body = '<div class="generalArea">'+
                '<div class="generalContent" align="center">'+
                    'You can not perform any operation in this project because this project has been frozen by administrator/owner.'+
                    '<br>'+
                    '<br>'+
                    '<input type="button" class="inputBtn"  value="Ok" onclick="cancelPanel()" >'+
                '</div>'+
            '</div>';
            createPanel(popup_title,popup_body, (popup_title.length+popup_body.length+350)+'px');
            return false;
        }

    </script>

    <!--[if IE 7]>
        <link href="<%=ar.retPath%>css/ie7styles.css" rel="styleSheet" type="text/css" media="screen" />
    <![endif]-->

<% if (!headerType.equals("site")) { %>
    <script>
        var specialTab='<%=tabId%>';
        headerType = "<%=headerType%>";
        serverMode = "<%=serverMode%>";
        var userKey = "<%=userKey%>";
        var isSuperAdmin = "<%=ar.isSuperAdmin()%>";
        <% if (pageId != null && bookId != null) { %>
          pageId='<%=pageId%>';
          book='<%=bookId%>';
        <% } %>
    </script>
    <style type="text/css">
        th.yui-dt-hidden,
        tr.yui-dt-odd .yui-dt-hidden,
        tr.yui-dt-even .yui-dt-hidden {
        display:none;
        }
    </style>

<% } else if(headerType.equals("site")){ %>
     <script>
        var specialTab='<%=tabId%>';
        headerType = "<%=headerType%>";
        serverMode = "<%=serverMode%>";
        var userKey = "<%=userKey%>";

        <% if(accountId != null){ %>
        var accountId='<%=accountId %>';
        <% } else if(pageId!=null){ %>
        var accountId='<%=pageId%>';
        <% } %>
     </script>
<% } %>

<body onload="createTabs();">


    <!-- Begin siteMasthead -->
    <div id="siteMasthead">
        <img id="logoInterstage" src="<%=ar.retPath%>assets/logo_interstage.gif" alt="Interstage" width="145" height="38" />
        <div id="consoleName">
           <% if(ngb!=null){ %>
           Site: <a href="<%=ar.retPath%>v/<%ar.writeURLData(ngb.getKey());%>/$/public.htm"
                     title="View the Site for this page"><%ar.writeHtml(ngb.getName());%></a>

           <% } %>
           <br />
           <%
            if(headerType.equals("user")) {
                if(userRecord!=null){
                    String userName = userRecord.getName();
                    if(userName.length()>60){
                        userName=userName.substring(0,60)+"...";
                    }
                    ar.write("User: <span title=\"");
                    ar.write(userName);
                    ar.write("\">");
                    ar.writeHtml(userName);
                    ar.write("</span>");
                }
            }
            else if(headerType.equals("site")) {
                if(pageTitle!=null){
                    if(pageTitle.length()>60){
                        trncatePageTitle=pageTitle.substring(0,60)+"...";
                    }else{
                        trncatePageTitle=pageTitle;
                    }
                    ar.write("Site: <span title=\"");
                    ar.write(pageTitle);
                    ar.write("\">");
                    ar.writeHtml(trncatePageTitle);
                    ar.write(deletedWarning);
                    ar.write("</span>");
                }
            }
            else {
                if(pageTitle!=null){
                    if(pageTitle.length()>60){
                        trncatePageTitle=pageTitle.substring(0,60)+"...";
                    }else{
                        trncatePageTitle=pageTitle;
                    }
                    ar.write("Project: <span title=\"");
                    ar.write(pageTitle);
                    ar.write("\">");
                    ar.writeHtml(trncatePageTitle);
                    ar.write(deletedWarning);
                    ar.write("</span>");
                }
            }
            %>
        </div>
        <div id="globalLinkArea">
          <ul id="globalLinks">
                <%
                    if(ar.isLoggedIn())
                    {
                        uProf = ar.getUserProfile();
                %>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/watchedProjects.htm"
                                title="Projects for the logged in user">Projects</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userAlerts.htm"
                                title="Updates for the logged in user">Updates</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userActiveTasks.htm"
                                title="Goals for the logged in user">Goals</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userProfile.htm?active=1"
                                title="Profile for the logged in user">Settings</a></li>
                        <%if(ar.isSuperAdmin()){ %>
                            <li>|</li>
                            <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/emailListnerSettings.htm" title="Administration">Administration</a></li>
                        <%} %>
                        <li>|</li>
                        <li class="text last"><a href="<%=ar.retPath%>t/LogoutAction.htm?go=<%ar.writeURLData(currentPageURL);%>">Log Out</a></li>
               <%
                  }
                  else
                  {
               %>
                        <li><a href="<%=ar.retPath%>"
                                title="Initial Introduction Page">Welcome Page</a></li>
                        <li>|</li>
                        <li class="text last"><a href="<%=ar.retPath%>t/EmailLoginForm.htm?go=<%ar.writeURLData(currentPageURL);%>">Log in</a></li>
               <%
                  }
               %>
            </ul>
            </div>
        <%
        if (ar.isLoggedIn())
        {
            UserProfile uProf1 = ar.getUserProfile();
            %>
            <div id="welcomeMessage">
                Welcome, <%uProf1.writeLink(ar); %>
                <img id="logoFujitsu" src="<%=ar.retPath%>assets/logo_fujitsu.gif" alt="Fujitsu" width="86" height="38" />
            </div>
            <%
        }
        else
        {
            %>
            <div id="welcomeMessage">
                Not logged in
                <img id="logoFujitsu" src="<%=ar.retPath%>assets/logo_fujitsu.gif" alt="Fujitsu" width="86" height="38" />
            </div>
            <%
        }
        %>
    </div>
    <!-- End siteMasthead -->

    <!-- Begin mainNavigation -->
    <div id="mainNavigationLeft">
        <div id="mainNavigationCenter">
            <div id="mainNavigationRight">
            </div>
        </div>
        <div id="mainNavigation">

            <ul id="tabs">

                <div id="zoomOutButton" style="display: none;vertical-align:baseline;" align="right"  >
                    <input type="button" class="inputBtn" onclick="zoomOut()" value="<< Back in Project">
                </div>
            </ul>
        </div>
          <!--Top Drop Down Menu for User section HTML Starts Here -->
                <ul id="userSubMenu1" class="ddsubmenustyle"/></ul>
                <ul id="userSubMenu2" class="ddsubmenustyle"/></ul>
                <ul id="userSubMenu3" class="ddsubmenustyle"/></ul>
                <%if(ar.isSuperAdmin()){
                %>
                <ul id="userSubMenu4" class="ddsubmenustyle"/></ul>
                <%}%>

          <!--Top Drop Down Menu for project section HTML Starts Here -->
                <ul id="ddsubmenu1" class="ddsubmenustyle"/></ul>
                <ul id="ddsubmenu2" class="ddsubmenustyle"></ul>
                <ul id="ddsubmenu3" class="ddsubmenustyle"> </ul>
                <ul id="ddsubmenu4" class="ddsubmenustyle"></ul>

           <!--Top Drop Down Menu for Site section HTML Starts Here -->
                <ul id="accountSubMenu1" class="ddsubmenustyle"/></ul>
                <ul id="accountSubMenu2" class="ddsubmenustyle"></ul>
                <ul id="accountSubMenu4" class="ddsubmenustyle"> </ul>

    </div>

<script type="text/javascript">
   createSubLinks();
</script>

<!-- End mainNavigation -->

<form id="validate" action="<%=ar.retPath%>t/validateHtml.validate" method="post">
<textarea id="output" name="output" rows="50" cols="70" style="display:none"></textarea>
</form>
    </body>
<script>
   function getSourceCode(){
            var url = '<%=ar.getCompleteURL()%>';
            YAHOO.util.Connect.asyncRequest('GET',url ,visibilitySubmitResponse);
   }




       var visibilitySubmitResponse ={
               success: function(o) {
                   var respText = o.responseText;
                   document.getElementById("output").value = respText;
                   document.getElementById("validate").submit();
               },
               failure: function(o) {
                    alert("validateSubmitResponse Error:" +o.responseText);
               }
       }

        function editDetail(id,username, obj,go){
            ele = obj;
            getEditForm(id,username,go);
        }

        function getEditForm(id,username, go){
            //alert("in edit form>>"+go)
            var body = '<div class="generalArea">'+
                       'This email-id ('+id+') is not linked to any user profile.  You can specify a display name to go with this email address until the user logs in and creates a profile.'+
                       '<div class="generalSettings">'+
                       '<form id="editForm" action="<%=ar.retPath%>t/editMicroProfileDetail.form" method="post">'+
                           '<table class="popups" width="100%">'+
                               '<tr>'+
                                   '<td class="gridTableColummHeader">'+
                                       '<label id="nameLbl"><B>Email Id: </B></label>'+
                                   '</td>'+
                                   '<td style="width:20px;"></td>'+
                                   '<td class="Odd">'+id+
                                   '</td>'+
                               '</tr>'+
                               '<tr>'+
                                   '<td class="gridTableColummHeader">'+
                                       '<label id="nameLbl"><B>Display Name: </B></label>'+
                                   '</td>'+
                                   '<td style="width:20px;"></td>'+
                                   '<td class="Odd"><input type="text" class="inputGeneral" name="userName" id="userName" value="'+username+'" />'+
                                   '</td>'+
                               '</tr>'+
                               '<tr><td style="height:10px"></td></tr>'+
                               '<tr>'+
                                   '<td class="gridTableColummHeader"></td>'+
                                   '<td style="width:20px;"></td>'+
                                   '<td>'+
                                       '<input type="button" class="inputBtn"  value="Update" onclick="validateAndSaveName();">&nbsp;'+
                                       '<input type="button" class="inputBtn"  value="Cancel" onclick="cancelPanel()" >'+
                                   '</td>'+
                               '</tr>'+
                           '</table>'+
                           '<input type="hidden" name="emailId" id="emailId" value="'+id+'">'+
                           '<input type="hidden" name="go" id="go" value="'+go+'">'+
                       '</form>'+
                       '</div>'+
                       '</div>';

           createPanel("Edit Details",body,"530px");
        }
        function validateAndSaveName(){
            var userName = document.getElementById("userName").value;
            var myRegxp = new RegExp("^\s*([0-9a-zA-Z _]+)\s*$");
            if(myRegxp.test(userName) == false){
                alert("Please enter a name using ASCII letters, numbers, spaces, and underscores.  Don't use punctuation or other characters.");
                document.getElementById("userName").focus();
            }else{
                document.forms["editForm"].submit();
            }
        }
        var emailErrors = '';
        function validateDelimEmails(field) {
            var count = 1;
            var result = "";
            var spiltedEmails;
            var value = trimme(field.value);
            if(value != ""){
                if(value.indexOf(";") != -1){
                    spiltedEmails = value.split(";");
                }else if(value.indexOf(",") != -1){
                    spiltedEmails = value.split(",");
                }else if(value.indexOf("\n") != -1){
                    spiltedEmails = value.split("\n");
                }else{
                    value = value+";";
                    spiltedEmails = value.split(";");
                }
                for(var i = 0;i < spiltedEmails.length;i++){
                    var email_id = trimme(spiltedEmails[i]);
                    if(email_id != ""){
                        if(!validateEmail(email_id)){
                            result += "  "+count+".    "+email_id+" \n";
                            count++;
                        }
                    }
                }
            }
            if(result != ""){
                alert("Below is the list of id(s) which does not look like an email. Please enter an email id(s).\n\n"+result);
                field.focus();
                return false;
            }

            return true;
        }
</script>
<!-- this is the end of header.jsp -->
<% out.flush(); %>
