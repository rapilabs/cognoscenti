<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%/*
Required parameter:

    1. pageId : This is the id of a Project and used to retrieve NGPage.

*/

    String pageId = ar.reqParam("pageId");%>
<%
    UserProfile uProf = ar.getUserProfile();
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);
    ar.setPageAccessLevels(ngp);
    String pageTitle = ngp.getFullName();
%>
<head>
    <style type="text/css">
        #bodyWrapper {
            margin:0px 30px 45px 30px;
            min-width:935px;
            position:relative;
        }
    </style>
</head>

<script>

    function back(){
        window.location = "public.htm";
    }
    function unSelect(type){
        var obj = document.getElementById(type);
        obj.checked = false;
    }
    function selectAll(type){
        if(type == 'public'){
            var obj = document.getElementsByName("publicNotes");
            for(i=0; i<obj.length ; i++){
                var allPublic = document.getElementById("publicNotesAll");
                if(allPublic.checked == true){
                    obj[i].checked = true;
                }else{
                    obj[i].checked = false;
                }
            }
        }else if(type == 'member'){
            var obj = document.getElementsByName("memberNotes");
            for(i=0; i<obj.length ; i++){
                var allMember = document.getElementById("memberNotesAll");
                if(allMember.checked == true){
                    obj[i].checked = true;
                }else{
                    obj[i].checked = false;
                }
            }
        }
    }
</script>
<div class="generalArea">
    <div class="generalContent">
        <div class="pageHeading">Export PDF</div>
        <div class="pageSubHeading">You can add contents to PDF and then generate it.</div>

        <form name="exportPdfFrom" id="exportPdfFrom"  action="pdf/page.pdf"  method="get">
            <input type="hidden" name="encodingGuard" value="<%writeHtml(out,"\u6771\u4eac");%>"/>
            <br/>
            <table width="800">
                <tr>
                    <td colspan="2" align="right">
                        <input type="submit" class="inputBtn" value="Export PDF" >
                        <input type="button" class="inputBtn" value="Back" onclick="back();"/>
                    </td>
                </tr>
            </table>
            <div class="generalHeading">Public Notes :</div>
            <br>
            <table border="0px solid gray" class="gridTable" width="800">
                <thead>
                <tr>
                   <th width="75%">&nbsp;&nbsp;&nbsp;<b>Subject</b></th>
                    <th><b><input type="checkbox" name="publicNotesAll" id="publicNotesAll" onclick="return selectAll('public')" checked="checked" /> &nbsp; Select All </b></th>
                </tr>
                </thead>
                <tr>
                    <td colspan="2">&nbsp;</td>
                </tr>
                <%
                    NGSection noteSection = ngp.getSection("Comments");
                        Vector<NoteRecord> publicComments = SectionComments.getVisibleComments(noteSection, SectionDef.PUBLIC_ACCESS, ar.getUserProfile());
                        for(int i=0;i<publicComments.size();i++){
                            NoteRecord noteRec = publicComments.get(i);
                %>
                <tr>
                    <td>
                      &nbsp;&nbsp;&nbsp; <%ar.writeHtml(noteRec.getSubject());%>
                    </td>
                    <td>
                      &nbsp;&nbsp;&nbsp;<input type="checkbox" name="publicNotes" checked="checked" value="<%ar.writeHtml(noteRec.getId());%>"  onclick="return unSelect('publicNotesAll')"/>
                    </td>
                </tr>
              <%
                  }
              %>
            </table>
            <br><br>
<% if (ar.isMember()) { %>
            <div class="generalHeading">Member Notes :</div>
            <br>
            <table border="0px solid gray" class="gridTable" width="800">
                <%
                    Vector<NoteRecord> memberComments = SectionComments.getVisibleComments(noteSection,
                                SectionDef.MEMBER_ACCESS, ar.getUserProfile());
                        if(memberComments.size() == 0){
                %>
                    No member notes found.
                <%
                        }
                        else{
                %>
                <thead>
                    <tr>
                        <th width="75%">&nbsp;&nbsp;&nbsp;<b>Subject</b></th>
                        <th><b><input type="checkbox" name="memberNotesAll" id="memberNotesAll" onclick="return selectAll('member')" /> &nbsp; Select All</b></th>
                    </tr>
                </thead>
                <tr>
                    <td colspan="2">&nbsp;</td>
                </tr>
             <%
                        for(int i=0;i<memberComments.size();i++) {
                            NoteRecord noteRec = memberComments.get(i);
             %>
                <tr>
                    <td>
                      &nbsp;&nbsp;&nbsp; <%ar.writeHtml(noteRec.getSubject()); %>
                    </td>
                    <td>
                      &nbsp;&nbsp;&nbsp;<input type="checkbox" name="memberNotes"  value="<%ar.writeHtml(noteRec.getId()); %>" onclick="return unSelect('memberNotesAll')"/>
                    </td>
                </tr>
              <%            }
                        }
              %>

            </table>
<% } %>

        </form>
    </div>
</div>
