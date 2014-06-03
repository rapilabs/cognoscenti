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
         var acct = '<%=accountKey%>';
         var url="../isProjectExist.ajax?projectname="+projectName+"&accountId="+acct;
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


<div class="pageHeading">Projects that belong to this site</div>
<div class="pageSubHeading">Manage projects that belong to this site.</div>

<div class="generalContent">

   <div id="paging"></div>
    <div id="container">
    <table id="pagelist">
    <thead>
        <tr>
            <th>No</th>
            <th>Project Name</th>
            <th>Last Modified</th>
            <th>Comment</th>
            <th>Time Period</th>
        </tr>
    </thead>
    <tbody>
    <%
        int sno=0;
        for (NGPageIndex ngpi : NGPageIndex.getAllProjectsInSite(accountKey))
        {
            sno++;
            String linkAddr = ar.retPath + "t/" +ngpi.pageBookKey+"/"+ngpi.containerKey + "/projectHome.htm";
    %>
        <tr>
            <td>
                <%=sno%>
            </td>
            <td>
                <a href="<%writeHtml(out, linkAddr);%>" title="navigate to the page"><%writeHtml(out, ngpi.containerName);%></a>
            </td>
            <td>
                <%SectionUtil.nicePrintTime(out, ngpi.lastChange, ar.nowTime);%>
            </td>
            <td></td>
            <td style='display:none'><%= (ar.nowTime - ngpi.lastChange)/1000%></td>
        </tr>
<%
    }

%>
        </tbody>
   </table>
   </div>

</div>
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
