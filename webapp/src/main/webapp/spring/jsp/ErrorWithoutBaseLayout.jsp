<%@page isErrorPage="true"%><%@page import="java.io.PrintWriter"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.HTMLWriter"
%>

<!-- -->
<link href="<%=ar.baseURL%>css/body.css" rel="styleSheet" type="text/css" media="screen" />
<script type="text/javascript" src="<%=ar.baseURL%>jscript/nugen_utils.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>jscript/yahoo-dom-event.js"></script>

<link href="<%=ar.retPath%>css/tabs.css" rel="styleSheet" type="text/css" media="screen" />


<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/fonts/fonts-min.css" />
<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/button/assets/skins/sam/button.css" />
<link rel="stylesheet" type="text/css" href="<%=ar.baseURL%>yui/build/container/assets/skins/sam/container.css" />

<script type="text/javascript" src="<%=ar.baseURL%>yui/build/yahoo-dom-event/yahoo-dom-event.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/connection/connection-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/json/json-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/element/element-beta-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/paginator/paginator-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/datasource/datasource-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/dragdrop/dragdrop-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/datatable/datatable-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/button/button-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/animation/animation-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/autocomplete/autocomplete-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/utilities/utilities.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/tabview/tabview-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/container/container-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/container/container_core-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/menu/menu-min.js"></script>
<script type="text/javascript" src="<%=ar.baseURL%>yui/build/cookie/cookie-min.js"></script>
<link href="<%=ar.retPath%>css/reset.css" rel="styleSheet" type="text/css" media="screen" />
<link href="<%=ar.retPath%>css/global.css" rel="styleSheet" type="text/css" media="screen" />
<%
    String pageTitle = (String) request.getAttribute("pageTitle");

    if (pageTitle == null)
        pageTitle = "Unknown";

    if (exception == null) {
        exception = new Exception(
                "<<Unknown exception arrived at the error page ... this should never happen. The exception variable was null.>>");
    }
    String msg = exception.toString();

    //get rid of pointless name of exception class that appears in 99% of cases
    if (msg.startsWith("java.lang.Exception: ")) {
        msg = msg.substring(21);
    }
    pageTitle = "-- Problem Resolution Message --";
%>
<%@page import="org.socialbiz.cog.AuthRequest"%>
<script>
    function showHideCommnets(divid)
    {
        var id = document.getElementById(divid);
        if(id.style.display == "block")
        {
            id.style.display = "none";
        }
        else
        {
            id.style.display = "block";
        }
    }

</script>
<body class="yui-skin-sam">
    <!-- Start body wrapper -->
    <div class="bodyWrapper" style="border:0px solid red">
        <!-- Start Header Section -->
        <div class="topNav">
            <!-- Start siteMasthead -->
            <div id="siteMasthead">
                <img id="logoInterstage" src="<%=ar.retPath%>assets/logo_interstage.gif" alt="Interstage" width="137" height="30" />
                <div id="consoleName">Cognoscenti Console</div>
                <div id="globalLinkArea" style="right:30px;">
                    <ul id="globalLinks">
                    <%
                        if(ar.isLoggedIn())
                        {
                            UserProfile uProf = ar.getUserProfile();
                            String currentPageURL = ar.getCompleteURL();
                    %>
                        <li><a href="#" onClick="getSourceCode();">Validate HTML</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/watchedProjects.htm"
                                title="home for the logged in user">Projects</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userAlerts.htm"
                                title="">Updates</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userActiveTasks.htm"
                                title="Goals for the logged in user">Goals</a></li>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/userProfile.htm?active=1"
                                title="Profile for the logged in user">Settings</a></li>
                    <%
                            if(ar.isSuperAdmin()){
                    %>
                        <li>|</li>
                        <li><a href="<%=ar.retPath%>v/<%ar.writeHtml(uProf.getKey());%>/emailListnerSettings.htm" title="Administration">Administration</a></li>
                    <%      } %>
                        <li>|</li>
                        <li class="text last"><a href="<%=ar.retPath%>t/LogoutAction.htm?go=<%ar.writeURLData(currentPageURL);%>">Log Out</a></li>

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
                <div id="welcomeMessage" style="right:30px;">
                    Welcome, <%uProf1.writeLink(ar); %><img id="logoFujitsu" src="<%=ar.retPath%>assets/logo_fujitsu.gif" alt="Fujitsu" width="86" height="38" />
                </div>
                  <%
                }
                else
                { %>
                <div id="welcomeMessage" style="right:30px;">
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
                    <div id="mainNavigationRight"></div>
                </div>
                <div id="mainNavigation"></div>
            </div>
            <!-- End mainNavigation -->
        </div>
        <!-- Start Header Section -->
        <!-- Begin mainSiteContainer -->
        <div id="mainSiteContainerDetails">
            <div id="mainSiteContainerDetailsRight">
                <table width="100%">
                    <tr>
                        <td valign="top">
                            <!-- Begin mainContent (Body area) -->
                            <div id="mainContent" style="text-align:center">
                                <div style="margin:0px auto; width:850px;text-align:left">
                                    <div class="generalSettings">
                                        <div class="generalHeadingBorderLess">Oops ... difficulty handling that request</div>
                                        <div style="height:20px"></div>
                                        <input type="button" name="sendError" class="inputBtn" value="Send this error to Admin" onClick="displayPanel();"/>
                                        <div style="height:20px"></div>
                                        Something went wrong trying to handle that request.It might be something simple on the last page that you can go
                                        back and fix.  Or it might be a problem with the server configuration that needs to be addressed by the
                                        administrator.The following message might contain useful information about the problem

                                        <ul>
                                        <%
                                        Throwable runner = exception;
                                        while (runner!=null)
                                        {
                                            msg = runner.toString();
                                            if (msg.startsWith("java.lang.Exception: "))
                                            {
                                                msg = msg.substring(21);
                                            }
                                            %><li><%
                                            ar.writeHtmlWithLines(msg);
                                            runner = runner.getCause();
                                            %></li><%
                                        }
                                        %>
                                        </ul>
                                        <br/>

                                        <img src="<%= ar.retPath %>but_process_view.gif" onClick="showHideCommnets('stackTrace')">
                                        <div id="stackTrace" class="errorStyle" style="display:none">
                                            <pre>
                                            <%
                                                out.flush();
                                            %>
                                            <%
                                                ar.logException("Exception captured by error.jsp", exception);
                                                exception.printStackTrace(new PrintWriter(new HTMLWriter(out)));
                                            %>
                                            </pre>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <!-- End mainContent (Body area) -->
                        </td>
                    </tr>
                </table>
            </div>
        </div>
        <!-- End mainSiteContainer -->

        <!-- Begin siteFooter -->
        <div id="siteFooter">
            <div id="siteFooterRight">
                <div id="siteFooterCenter">
                    <div id="footer">
                        <table>
                            <tr>
                                <td align="right">
                                    Copyright 2012 Fujitsu America Incorporated. All rights reserved.
                                </td>
                            </tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        <!-- End siteFooter -->
    </div>
    <!-- End body wrapper -->

<script language="javascript">

    function displayPanel(){


        var body=
                '<div class="bd">'+
                '<form id="errorform" action="<%=ar.retPath%>t/sendErrortoAdmin.ajax" method="post">'+
                '<textarea id="errorData" name="errorData" rows="50" cols="70" style="display:none"></textarea>'+
                '<textarea name="user_comments" id="user_comments" value="" style="width: 500px;height: 200px" rows="4"></textarea>'+
                '<br/>'+
                '<br/>'+
                '<table  align="right">'+
                '<tr>'+
                '<td><input type="button" class="inputBtn"  value="Report Error" onclick="setErrorAndSendEmail();"></td>'+
                '<td>&nbsp;</td>'+
                '<td><input type="button" class="inputBtn"  value="Cancel" onclick="cancel();"></td>'+
                '</tr>'+
                '</table>'+
                '</form>'+
                '</div>';

        createPanel2("Please enter your comments",body,"600px");
    }
    var panel;
    function cancel(){
        if(panel != null)
        panel.hide();
    }

    function setErrorAndSendEmail(){
        cancel();
        var id = document.getElementById('stackTrace');
        var flag = false;
        if(id.style.display != "block")
        {
            flag=true;
        }
        if(flag){
            showHideCommnets('stackTrace')
        }
        var html = document.getElementsByTagName('html')[0].innerHTML;
        if(flag){
            showHideCommnets('stackTrace')
        }
        document.getElementById("errorData").value = "<html>"+html+"</html>";
        YAHOO.util.Connect.setForm(document.forms["errorform"]);
        YAHOO.util.Connect.asyncRequest('POST', '<%=ar.retPath%>t/sendErrortoAdmin.ajax',errorResponse);
        YAHOO.util.Connect.resetFormState();

    }
    function createPanel2(header, bodyText, panelWidth){
        panel = new YAHOO.widget.Panel("panel", {
                                                height: "300px",
                                                width: panelWidth ,
                                                fixedcenter: true,
                                                constraintoviewport: true,
                                                underlay: "shadow",
                                                close: true,
                                                visible: false,
                                                draggable: true,
                                                modal:true
                                            });
        panel.setHeader(header);
        panel.setBody(bodyText);
        panel.render(document.body);
        panel.show();
    }

    var errorResponse ={
            success: function(o) {
                var respText = o.responseText;
                var json = eval('(' + respText+')');
                if(json.msgType == "success"){
                    alert("Mail has been sent succesfully");
                }else if(json.msgType == "failure"){
                    showErrorMessage("Unable to Perform Action", json.msg , json.comments);
                }
            },
            failure: function(o) {
                alert("Error in createLeafletSubmit.ajax: "+o.responseText);
            }
    }
    // Added all the below functions as of now, will move all this at center location
    function showErrorMessage(title, errorMsg, detailedMsg){
        if(panel != null){
            cancel();
        }
        var body = '<div class="generalArea">'+
                    '<div class="generalContent" align="center">'+
                    '<font color="red" size="4px"><I>'+
                    errorMsg+
                    '</I></font>'+
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
        body += '<input type="button" class="inputBtn"  value="Ok" onclick="cancel()" >'+
                '</div>'+
                '</div>';

        panel = new YAHOO.widget.Panel("panel", {
                    width: "550px" ,
                    fixedcenter: true,
                    constraintoviewport: true,
                    close: true,
                    visible: false,
                    draggable: true,
                    modal:true
                });
                panel.setBody(body);
                panel.render(document.body);
                panel.show();

            }
        function showDetail(){
            if(document.getElementById('detailErrDiv').style.display == 'block'){
                document.getElementById('detailErrDiv').style.display = 'none';
            }else{
                document.getElementById('detailErrDiv').style.display = 'block';
            }
        }
</script>
</body>
