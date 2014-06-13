<!doctype html>
<!-- The DOCTYPE declaration above will set the    -->
<!-- browser's rendering engine into               -->
<!-- "Standards Mode". Replacing this declaration  -->
<!-- with a "Quirks Mode" doctype may lead to some -->
<!-- differences in layout.                        -->
<%@page import="org.socialbiz.cog.AuthRequest"%>
<%@page import="org.socialbiz.cog.NGPageIndex"%>

<%
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    String pageTitle  = "Note Editor";
%>

<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <script type="text/javascript" language="javascript" src="<%=ar.retPath%>bewebapp/bewebapp.nocache.js"></script>

    <script src="<%=ar.retPath%>tiny_mce/tiny_mce.js" type='text/javascript'></script>

    <link href="<%=ar.retPath%>css/editorContent.css" rel="styleSheet" type="text/css" media="screen" />

    <script language="javascript" type="text/javascript">
         tinyMCE.init({
            content_css : "<%=ar.retPath%>/css/editorContent.css",
            mode : "textareas",
            elements : "nourlconvert",
            theme : "advanced",
            plugins : "pagebreak,style,layer,table,save,advhr,advimage,emotions,iespell,insertdatetime,preview,media,searchreplace,print,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
            convert_urls : false,
            theme_advanced_buttons1 : "formatselect,bold,italic,underline,|,"+
                                 "bullist,outdent,indent,hr," +
                                 "|,link,unlink,removeformat,code",
                  theme_advanced_buttons2 : '',
                  theme_advanced_buttons3 : '',
            theme_advanced_toolbar_location : "top",
            theme_advanced_toolbar_align : "left",
            theme_advanced_statusbar_location : "bottom",
            theme_advanced_resizing : true,
            theme_advanced_blockformats : "p,h1,h2,h3"
        });
    </script>
   

  </head>
  <body>

    <!-- OPTIONAL: include this if you want history support -->
    <iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>

    <!-- RECOMMENDED if your web app will not function without JavaScript enabled -->
    <noscript>
      <div style="width: 22em; position: absolute; left: 50%; margin-left: -11em; color: red; background-color: white; border: 1px solid red; padding: 4px; font-family: sans-serif">
        Your web browser must have JavaScript enabled
        in order for this application to display correctly.
      </div>
    </noscript>
    <table width="100%" align="left">
      <tr>
        <td id="gwt_editor"></td>
      </tr>
    </table>
  </body>
</html>

<%@ include file="functions.jsp"%>