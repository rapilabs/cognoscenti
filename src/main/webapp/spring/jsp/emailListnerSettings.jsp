<%@page errorPage="/spring/jsp/error.jsp"
%><%@page import="org.socialbiz.cog.EmailListener"
%><%@page import="java.io.PrintWriter"
%><%@ include file="administration.jsp"
%>
<div class="content tab01" style="display:block;" >
    <div class="section_body">
        <div style="height:10px;"></div>
        <div class="generalHeading">Email Listener Settings</div>
        <%
             Properties emailProperties = EmailListener.getEmailProperties();
             if(SuperAdminLogFile.getEmailListenerPropertiesFlag()){
                 %><img src="<%=ar.retPath%>assets/images/greencircle.jpg" border="green" width="10px" height="10px" />
                  &nbsp;&nbsp; Settings for Email Listener are fine.<br/><%
            }
            else {
                 %><img src="<%=ar.retPath%>assets/images/redcircle.jpg" border="green" width="10px" height="10px" />
                  &nbsp;&nbsp; Email Listener is not working.<br/><%
            }
        %>
        <br/>
        <table border="0px solid gray" class="gridTable" width="500">
            <tr>
                <td>POP3 Host</td>
                <td><%=emailProperties.getProperty("mail.pop3.host")%></td>
            </tr>
            <tr>
                <td>POP3 Port</td>
                <td><%=emailProperties.getProperty("mail.pop3.port")%></td>
            </tr>
            <tr>
                <td>User Name</td>
                <td><%=emailProperties.getProperty("mail.pop3.user")%></td>
            </tr>
            <tr>
                <td>Password</td>
                <td>****************</td>
            </tr>
        </table>
        <p>
            Last Inbox Read: <% SectionUtil.nicePrintDateAndTime(out, EmailListener.lastFolderRead);%>
        </p>

    </div>
</div>
