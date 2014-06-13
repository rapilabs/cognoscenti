<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/attachment_forms.jsp" %>
<div>
    <div class="pageHeading">
       <fmt:message key="nugen.attachment.uploadattachment.LinkURL" />
    </div>

   <%if(ngp.isFrozen()){ %>
           <div id="loginArea">
               <span class="black">
                    <fmt:message key="nugen.project.freezed.msg" />
               </span>
           </div>
   <%}else{ %>

   <div class="pageSubHeading">
       <%ar.writeHtmlMessage("nugen.attachment.uploadattachment.LinkURLtoProject",new Object[]{ngp.getFullName()}); %>
   </div>
    <div class="generalSettings">
        <form action="createLinkURL.form" method="post" onsubmit="return checkVal('link');">
            <table border="0px solid red" class="popups" width="100%">
                <tr>
                    <td class="gridTableColummHeader_2">
                        <input type="hidden" name="encodingGuard" value="%E6%9D%B1%E4%BA%AC"/>
                        <fmt:message key="nugen.attachment.uploadattachment.DescriptionOf" />
                        <fmt:message key="nugen.attachment.uploadattachment.WebPage" />
                    </td>
                    <td  style="width:20px;"></td>
                    <td>
                        <textarea name="comment" id="link_comment" rows="4" class="textAreaGeneral"></textarea>
                    </td>
                </tr>
                <tr><td style="height:10px"></td></tr>
                <tr>
                    <td class="gridTableColummHeader_2"><fmt:message key="nugen.attachment.uploadattachment.Accessibility" /></td>
                    <td  style="width:20px;"></td>
                    <!--<td>
                        <input type="radio" name="visibility" value="*PUB*"/> <fmt:message key="nugen.attachment.uploadattachment.Public" />
                        <input type="radio" name="visibility" value="*MEM*" checked="checked"/> <fmt:message key="nugen.attachment.uploadattachment.Member" />
                    </td>-->
                    <%
                    if (ar.isMember())
                    {
                    %>
                    <td>
                        <%
                            String publicMsg = "";
                            if("yes".equals(ngp.getAllowPublic())){
                        %>
                                <input type="radio" name="visibility" id="pubchoice" value="*PUB*"/> <fmt:message key="nugen.attachment.uploadattachment.Public" />
                        <%

                            }else{
                                publicMsg = ar.getMessageFromPropertyFile("public.attachments.not.allowed", null);
                            }
                        %>

                        <input type="radio" name="visibility" id="memchoice"  checked="checked"/>
                        <fmt:message key="nugen.attachment.uploadattachment.Member" />
                        <div style="color: gray;padding-top: 5px;" ><%ar.writeHtml(publicMsg); %></div>
                    </td>
                    <%
                    }else{
                    %>
                    <td>
                        <fmt:message key="nugen.attachment.uploadattachment.Public" />
                        <input type="hidden" id="visibility" name="visibility" value="*PUB*"/>
                    </td>
                    <%
                    }
                    %>
                </tr>
                <tr><td style="height:10px"></td></tr>
                <input type="hidden" id="ftype" name="ftype" value="URL"/>
                <tr>
                    <td class="gridTableColummHeader_2">
                        <fmt:message key="nugen.attachment.uploadattachment.URL"/>
                    </td>
                    <td  style="width:20px;"></td>
                    <td>
                        <input type="text" id="taskUrl" name="taskUrl" class="inputGeneral" />
                    </td>
                </tr>
                <tr><td style="height:20px"></td></tr>
                <tr>
                    <td></td>
                    <td  style="width:20px;"></td>
                    <td>
                        <input type="submit" name="action" class="inputBtn" value="<fmt:message key='nugen.attachment.uploadattachment.button.AttachWebURL'/>">
                        <input type="button"  class="inputBtn"  name="action" value="<fmt:message key='nugen.button.general.cancel'/>" onclick="cancel();"/>
                    </td>
                </tr>
            </table>
        </form>
        <%} %>
    </div>
</div>
</div>
</div>
</div>
