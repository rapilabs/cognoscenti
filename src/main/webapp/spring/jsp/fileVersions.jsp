<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/EditAttachment.jsp"
%><%@page import="org.socialbiz.cog.AttachmentVersion"
%><%
    List<AttachmentVersion>  versionList = attachment.getVersions(ngp);
%>
<div class="content tab01">
    <br>
    <B>Attachment Name : <%ar.writeHtml(attachment.getDisplayName());%> &nbsp;</B> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('uploadRevisedDocument.htm?aid=<%ar.writeHtml(attachment.getId());%>');"
                        value="Upload New Version" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('editDetails<%ar.writeHtml(attachment.getId());%>.htm');"
                        value="Edit Details" /> &nbsp;
                    <input type="button" class="inputBtn"
                        onclick="window.location.assign('docinfo<%ar.writeHtml(attachment.getId());%>.htm');"
                        value="Access Document" />

    <br/>
    <div class="scrollableOverflow">
        <div id="attachVersionList" width="100%">
            <table id="attachVersionTable" width="100%">
                <thead>
                    <tr>
                        <th>Version</th>
                        <th>Modified Date</th>
                        <th>File Size</th>
                        <th>Time Period</th>
                    </tr>
                </thead>
                <tbody>
                <%
                String rowStyleClass = "";
                for(AttachmentVersion aVer : versionList){
                    String contentLink = "";
                    String ftype = attachment.getType();
                    if (ftype.equals("URL"))
                    {
                        contentLink = fname; // URL.
                    }
                    else
                    {
                        contentLink = "a/" + SectionUtil.encodeURLData(attachment.getNiceName())+"?version="+aVer.getNumber();
                    }
                    %>
                <tr >
                    <td>
                        <a href="<%ar.writeHtml(contentLink); %>" title="Access the content of this attachment">
                        <%= aVer.getNumber() %>: <% writeHtml(out,attachment.getNiceName());  %>
                        <% if (aVer.isModified()) { %>(Modified)<% } %>
                        </a>
                    </td>
                    <td><% SectionUtil.nicePrintTime(out, aVer.getCreatedDate(), ar.nowTime); %></td>
                    <td><%= aVer.getLocalFile().length() %></td>
                    <td style='display:none'><%= (ar.nowTime - aVer.getCreatedDate())/1000%></td>
                </tr>
                <%
                }
                %>
                </tbody>
            </table>
        </div>
    </div>
</div>
</div></div></div></div></div>
