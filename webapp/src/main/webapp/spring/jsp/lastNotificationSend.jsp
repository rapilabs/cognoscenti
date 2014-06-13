<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="administration.jsp"
%>
<div class="content tab02" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div class="generalHeading">Last Notification Sent Time: <span id="elapsed_time"></span></div>
        <%
            long nextScheduleTime = EmailSender.getNextTime(lastSentTime);
                boolean overDue = (ar.nowTime > nextScheduleTime);
        %>
        <ul>
            <li>Last Notification Sent Time: <%
                SectionUtil.nicePrintDateAndTime(out, lastSentTime);
            %></li>
            <li>Next Schedule Time: <%
                SectionUtil.nicePrintDateAndTime(out, nextScheduleTime);
            %></li>
            <li>Last Check Time: <%
                SectionUtil.nicePrintDateAndTime(out, EmailSender.threadLastCheckTime);
            %></li>
            <%
                if (overDue) {
            %>
            <li><b>Email sending is OverDue!</b></li>
            <%
                }
            %>
            <%
                if (EmailSender.threadLastCheckException!=null) {
                       ar.writeHtml( EmailSender.threadLastCheckException.toString() );
                       ar.write("</ul>\n<pre>\n");
                       EmailSender.threadLastCheckException.printStackTrace(new PrintWriter(new HTMLWriter(out)));
                       ar.write("\n</pre>\n<ul>\n");
                   }
            %>
            <%
                if (EmailSender.threadLastMsgException!=null) {
                       ar.writeHtml( EmailSender.threadLastMsgException.toString() );
                       ar.write("</ul>\n<pre>\n");
                       EmailSender.threadLastMsgException.printStackTrace(new PrintWriter(new HTMLWriter(out)));
                       ar.write("\n</pre>\n<ul>\n");
                   }
            %>
            <li><hr/></li>
            <%
                ar.write(SuperAdminLogFile.getInstance().getSendLog());
            %>
        </ul>
    </div>
</div>