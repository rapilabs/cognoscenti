<%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameter:

    1. accountId : This is the id of a site and used to retrieve NGBook.

*/

    String accountKey = ar.reqParam("accountId");

%><%!
    String pageTitle="";
%><%

    UserProfile  uProf =ar.getUserProfile();
    Vector<NGPageIndex> templates = new Vector<NGPageIndex>();
    if(uProf != null){
        for(TemplateRecord tr : uProf.getTemplateList()){
            String pageKey = tr.getPageKey();
            NGPageIndex ngpi = NGPageIndex.getContainerIndexByKey(pageKey);
            if (ngpi!=null) {
                //silently ignore templates that no longer exist
                templates.add(ngpi);
            }
        }
        NGPageIndex.sortInverseChronological(templates);
    }

%>

<script language="javascript">
    var flag=false;
    var projectNameRequiredAlert = '<fmt:message key="nugen.project.name.required.error.text"/>';
    var projectNameTitle = '<fmt:message key="nugen.project.projectname.textbox.text"/>';

     function isProjectExist(){
         var projectName = document.getElementById('projectname').value;
         var url="../isProjectExist.ajax?projectname="+projectName+"&siteId=<% ar.writeURLData(accountKey); %>";
         var transaction = YAHOO.util.Connect.asyncRequest('POST',url, projectValidationResponse);
         return false;
     }

     var projectValidationResponse ={
                success: function(o) {
                    var respText = o.responseText;
                    var json = eval('(' + respText+')');
                    if(json.msgType == "no"){
                        document.forms["projectform"].submit();
                    }
                    else{
                        showErrorMessage("Result", json.msg, json.comments);
                    }
                },
                failure: function(o) {
                    alert("projectValidationResponse Error:" +o.responseText);
                }
        }
</script>
<% if(!ar.isLoggedIn()){%>

<%@page import="org.socialbiz.cog.TemplateRecord"%>
<body>
<div class="generalArea">
    <div class="generalContent">In order to see the process section of
    the project, you need to be logged in, and you need to be an member of
    the project.
    </div>
</div>
<%
    } else{
%>
<body class="yui-skin-sam">


<div class="pageHeading">Create Project in this Site</div>
<div class="pageSubHeading"></div>

<div class="generalContent">
   <form name="projectform" action="createprojectFromTemplate.form" method="post" autocomplete="off">
        <table class="popups">
           <tr><td style="height:30px"></td></tr>
           <tr>
                <td class="gridTableColummHeader_2 bigHeading">New Project Name:</td>
                <td style="width:20px;"></td>
                <td>
                    <table cellpadding="0" cellspacing="0">
                       <tr>
                           <td class="createInput" style="padding:0px;">
                               <input type="text" class="inputCreateButton" name="projectname" id="projectname" value='<fmt:message key="nugen.project.projectname.textbox.text"/>' onKeyup="updateVal();" onfocus="ClearForm();" onblur="addvalue();" onclick="" />
                           </td>
                           <td class="createButton" onclick="submitForm();">&nbsp;</td>
                       </tr>
                   </table>
               </td>
            </tr>
            <tr>
                <td colspan="3">
                <table id="assignTask">
                    <tr><td width="148" class="gridTableColummHeader_2" style="height:20px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader_2">Select Template:</td>
                        <td style="width:20px;"></td>
                        <td><Select class="selectGeneral" id="templateName" name="templateName">
                                <option value="" selected>Select</option>
                                <%
                                for (NGPageIndex ngpi : templates)
                                {
                                    %>
                                    <option value="<%ar.writeHtml(ngpi.containerKey);%>" ><%ar.writeHtml(ngpi.containerName);%></option>
                                    <%
                                }
                                %>
                            </Select>
                        </td>
                    </tr>
                    <tr><td style="height:10px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader_2"><fmt:message key="nugen.project.duedate.text"/></td>
                        <td style="width:20px;"></td>
                        <td><input type="text" class="inputGeneral" style="width:368px" size="50" name="dueDate" id="dueDate"  value="" readonly="1"/>
                            <img src="<%=ar.retPath %>/jscalendar/img.gif" id="btn_dueDate" style="cursor: pointer;" title="Date selector"/>
                        </td>
                    </tr>
                    <tr><td style="height:15px"></td></tr>
                    <tr>
                        <td class="gridTableColummHeader_2" style="vertical-align:top"><fmt:message key="nugen.project.desc.text"/></td>
                        <td style="width:20px;"></td>
                        <td><textarea name="description" id="description" class="textAreaGeneral" rows="4" tabindex=7></textarea></td>
                    </tr>
                    <tr><td style="height:20px"></td></tr>
                    <tr>
                        <td width="148" class="gridTableColummHeader_2">Upstream Link:</td>
                        <td style="width:20px;"></td>
                        <td><input type="text" class="inputGeneral" style="width:368px" size="50" name="upstream" value=""/>
                        </td>
                    </tr>
                    <tr><td style="height:20px"></td></tr>
                </table>
               </td>
            </tr>
            <tr>
               <td width="148" class="gridTableColummHeader_2"></td>
               <td width="39" style="width:20px;"></td>
               <td style="cursor:pointer">
                <span id="showDiv" style="display:inline" onclick="">
                    <img src="<%=ar.retPath %>/assets/createSeperatorDown.gif" width="398" height="13"
                    title="Expand" alt="" /></span>
                <span id="hideDiv" style="display:none" onclick="">
                    <img src="<%=ar.retPath %>/assets/createSeperatorUp.gif" width="398" height="13"
                    title="Collapse" alt="" /></span>
               </td>
            </tr>
       </table>
   </form>

<script language="javascript">
      initCal();
</script>
<script type="text/javascript">
    function trim(s) {
        var temp = s;
        return temp.replace(/^s+/,'').replace(/s+$/,'');
    }
        YAHOO.util.Event.addListener(window, "load", function()
        {
            YAHOO.example.EnhanceFromMarkup = function()
            {
                var myColumnDefs = [
                    {key:"no",label:"No",formatter:YAHOO.widget.DataTable.formatNumber,sortable:true,resizeable:true},
                    {key:"projectname",label:"Project Name", sortable:true,resizeable:true},
                    {key:"lastmodified",label:"Last Modified", sortable:true,sortOptions:{sortFunction:sortDates}, resizeable:true},
                    {key:"comments",label:"comments",sortable:true, resizeable:true},
                    {key:"timePeriod",label:"timePeriod",sortable:true, resizeable:true,hidden:true}
                ];

                var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
                myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
                myDataSource.responseSchema = {
                    fields: [{key:"no", parser:"number"},
                            {key:"projectname"},
                            {key:"lastmodified"},
                            {key:"comments"},
                            {key:"timePeriod" , parser:YAHOO.util.DataSource.parseNumber}]
                };

                var oConfigs = {
                    paginator: new YAHOO.widget.Paginator({
                        rowsPerPage: 200,
                        containers   : 'paging'
                    }),
                    initialRequest: "results=999999"
                };


                var myDataTable = new YAHOO.widget.DataTable("container", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"no",dir:"desc"}});


                return {
                    oDS: myDataSource,
                    oDT: myDataTable
                };
            }();
        });

    </script>

    <%}%>
    </body>
