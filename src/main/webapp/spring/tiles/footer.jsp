<!doctype html>
<!-- The DOCTYPE declaration above will set the    -->
<!-- browser's rendering engine into               -->
<!-- "Standards Mode". Replacing this declaration  -->
<!-- with a "Quirks Mode" doctype may lead to some -->
<!-- differences in layout.                        -->
<%@page import="org.socialbiz.cog.AuthRequest"%>
<%@page import="org.socialbiz.cog.NGPageIndex"%>
<%
/*

Optional Parameter:

    1. autoupdate       :
    2. pageNotification :
    3. pageId           : This is used to go to Old-UI page.
*/

    AuthRequest far = AuthRequest.getOrCreate(request, response, out);
    String autoupdate = request.getParameter("autoupdate");
    String testwait = far.getSystemProperty("pageNotification");
    String pageId = (String)request.getAttribute("pageId");
%>

<script type="text/javascript" language="javascript" src="<%=far.retPath%>bewebapp/bewebapp.nocache.js"></script>

    <div id="footer">
        <table width="100%">
            <tr>
<%
            if("true".equals(testwait) && "true".equals(autoupdate) && far.isLoggedIn()) {
%>
                <td id="gwt_wait" align="left"></td>

<%
            }
%>
                <td>
                    <a href="#" onclick="getSourceCode();">Validate HTML</a> |
                    <a href="<%
                    far.write(far.retPath);
                    if(pageId!=null&&pageId.length()>0){
                        far.write("p/");
                        far.writeURLData(pageId);
                        far.write("/");
                    }else{
                        far.write("UserHome.jsp");
                    }
                    %>" title="View the old UI for this page">Old UI</a>
                </td>
                <td align="right">
                    Copyright 2014 Fujitsu North America, Advanced Software Design Lab
                </td>
            </tr>
        </table>
    </div>
<% out.flush(); %>
