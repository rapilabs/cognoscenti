<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%
    AuthRequest ud_ar = AuthRequest.getOrCreate(request, response, out);
    ud_ar.assertLoggedIn("You need to Login to Upload a file.");
    String pageId = ud_ar.reqParam("pageId");
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);

%>
<html>
    <head>
        <meta http-equiv="content-type" content="text/html; charset=UTF-8">
        <title>Upload Document</title>
        <script type="text/javascript" language="javascript" src="<%=ud_ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
        <link href="<%=ud_ar.baseURL%>css/body.css" rel="styleSheet" type="text/css" media="screen" />
    </head>
    <body class="yui-skin-sam">
        <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
        <div>
            <div class="pageHeading">Upload Document</div>
            <div class="pageSubHeading">
                Use this form to upload a file to the Project "<%=ngp.getFullName() %>"
            </div>
            <%if(ngp.isFrozen()){ %>
            <div id="loginArea">
                <span class="black">
                    <fmt:message key="nugen.project.freezed.msg" />
                </span>
            </div>
            <%}else{ %>

            <div id="gwt_single_upload"></div>
            <%}
         %>
        </div>
    </body>
</html>
<noscript>
      <div style="width: 22em; position: absolute; left: 50%; margin-left: -11em; color: red; background-color: white; border: 1px solid red; padding: 4px; font-family: sans-serif">
        Your web browser must have JavaScript enabled
        in order for this application to display correctly.
      </div>
</noscript>
