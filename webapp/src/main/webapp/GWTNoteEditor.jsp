<!doctype html>
<!-- The DOCTYPE declaration above will set the    -->
<!-- browser's rendering engine into               -->
<!-- "Standards Mode". Replacing this declaration  -->
<!-- with a "Quirks Mode" doctype may lead to some -->
<!-- differences in layout.                        -->
<%@page import="org.socialbiz.cog.AuthRequest"%>
<%@page import="org.socialbiz.cog.NGPageIndex"%>

<%
    String pageTitle  = "Note Editor";
    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);
    ar.assertLoggedIn("Can't open the Editor.");
    String nid      = ar.defParam("nid", "");
    String p = ar.reqParam("pid");
    ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);
    if(nid.length() == 0){
        ar.assertMember("Need Member Access to Create a Note.");
    }
%>

<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <script type="text/javascript" language="javascript" src="<%=ar.retPath%>bewebapp/bewebapp.nocache.js"></script>

    <script src="<%=ar.retPath%>tiny_mce/tiny_mce.js" type='text/javascript'></script>
  <script language="javascript" type="text/javascript">
      tinyMCE.init({
            mode : "textareas",
            theme : "advanced",
            plugins : "pagebreak,style,layer,table,save,advhr,advimage,advlink,emotions,iespell,insertdatetime,preview,media,searchreplace,print,contextmenu,paste,directionality,fullscreen,noneditable,visualchars,nonbreaking,xhtmlxtras,template",
            theme_advanced_buttons1 : "paste,formatselect,bold,italic,underline,|,"+
                    "justifyleft,justifycenter,justifyright,justifyfull,|," +
                     "bullist,numlist,outdent,indent,hr,|," +
                     "|,link,unlink,anchor,image,cleanup,|,print,|,fullscreen",
            theme_advanced_buttons2 : '',
            theme_advanced_buttons3 : '',
            theme_advanced_toolbar_location : "top",
            theme_advanced_toolbar_align : "left",
            theme_advanced_statusbar_location : "bottom",
            theme_advanced_resizing : true
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
    <br/><br/>
    <table width="100%" align="left">
      <tr>
        <td id="gwt_editor"></td>
      </tr>
    </table>
  </body>
</html>

<%@ include file="functions.jsp"%>