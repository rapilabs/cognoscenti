<%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page isErrorPage="true"
%><%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"
%><%@include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.exception.NGException"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.HTMLWriter"
%><%@page import="org.socialbiz.cog.ErrorLog"
%><%@page import="org.socialbiz.cog.ErrorLogDetails"
%><%@page import="java.io.PrintWriter"
%><%@page import="java.util.Locale"
%><%String pageTitle = (String) request.getAttribute("pageTitle");
    String userName = "User not logged in";
    if (ar.isLoggedIn()) {
        userName = ar.getUserProfile().getName();
    }

    if (pageTitle == null) {
        pageTitle = "Error Page";
    }

    String exceptionNO = ar.defParam("exceptionNO", null);

    //this code was allowing a display to be made of an unlogged exception, logging
    //it here is a little sloppy.  Should assure that all errors are logged before this page.
    if (exceptionNO == null) {
        exceptionNO=String.valueOf(ar.logException("", exception));
    }


    ErrorLog eLog = ErrorLog.getLogForDate(ar.nowTime);
    ErrorLogDetails eDetails = eLog.getDetails(exceptionNO);

    String msg = eDetails.getErrorDetails();

    //get rid of pointless name of exception class that appears in 99% of cases
    if (msg.startsWith("java.lang.Exception: ")) {
        msg = msg.substring(21);
    }
    pageTitle = "-- Problem Resolution Message --";
    long searchDate=new Date().getTime();

    if (msg.indexOf("TilesJspException")>0) {
        //in this case, we have an error within the Tiles, which means this was
        //thrown from within a page, nested who knows how many levels deep.
        //This attempts to close all the containing structures if possible.
        ar.write("</li></ul></div></td></tr></table></li></ul></div></td></tr></table></div></td></tr></table></li></ul></div></td></tr></table>");
    }%>
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


<body class="yui-skin-sam">
    <div class="generalArea">
        <div class="generalHeading"><fmt:message key="nugen.common.errorHeader" /></div>
        <ul>

        <li><fmt:message key="nugen.common.error" /></li>

        </ul>
        <%
            Throwable runner = exception;
            int counter=0;
            while (runner!=null)
            {
                String msg1 = runner.toString();
                if (msg.startsWith("java.lang.Exception: "))
                {
                    msg1 = msg.substring(21);
                }
                ar.write("\n<br/>");
                ar.write("\n<li><span style=\"color:#5377ac\"><b>");
                ar.write(Integer.toString(++counter));
                ar.write(".  ");
                ar.writeHtmlWithLines(msg1);
                ar.write("</b></span></li>");
                runner = runner.getCause();
            }
        %>

        <br/>
        <li><b>Reference No:</b> <% ar.writeHtml(exceptionNO);%></li>
        <br/>
        <li><b>User:</b> <% ar.writeHtml(userName);%></li>
        <br/>
        <li><b>Date & Time: </b><% ar.writeHtml(ar.nowTimeString);%></li>
        </ul>
        <br/>
        <input type="button" name="sendError" class="inputBtn" value="Send a comment to the Administrator" onclick="displayPanel();"/>
        <br/>
        <br/>
        <img src="<%= ar.retPath %>but_process_view.gif" title="Show Error details" onclick="showHideCommnets('stackTrace')">
        <div id="stackTrace" class="errorStyle" style="display:none">
            <span style="overflow:auto;width:900px;"><%ar.writeHtmlWithLines(eDetails.getErrorDetails()); %></span>
        </div>
    </div>

<script language="javascript">

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
    function displayPanel(){
        var body=
                '<div class="bd">'+
                '<form id="errorform" action="<%=ar.retPath%>t/sendErrortoAdmin.ajax" method="post">'+
                '<textarea id="errorData" name="errorData" rows="50" cols="70" style="display:none"></textarea>'+
                '<textarea name="user_comments" id="user_comments" value="" style="width: 500px;height: 200px" rows="4"></textarea>'+
                '<input type="hidden" name="errorId" id="errorId" value="<%=exceptionNO%>">'+
                '<input type="hidden" name="dateTime" id="dateTime" value="<%=searchDate%>">'+
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
