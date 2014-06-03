<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/attachment_forms.jsp"
%><%!int countRows = 0;%>
<script type="text/javascript">

    function onClickAction(flag){

           if(flag == "Synchronize"){
               <% if (!ngp.isFrozen()) { %>
                   document.getElementById("attachmentForm").submit();
               <% }else{ %>
                   openFreezeMessagePopup();
               <% } %>
           }else if(flag == "Cancel"){
               location.href = "attachment.htm";
           }

    }

    function changeIcon(id1,id2,id3){

        var position = id2.indexOf("-");
        var value = id2.substring(0,position);
        var row = id2.substring(position+1,id2.length);
        var rowId = "aid-"+row;
        var  readonlyId = "readonly-"+row;

        if(document.getElementById(readonlyId).value!='on'){
            document.getElementById(id1).style.display = "none";
            document.getElementById(id2).style.display = "block";
            document.getElementById(id3).style.display = "none";
            document.getElementById(rowId).value=value;
        }else{
            var checkinId = "checkin-"+row;
            var checkoutId = "checkout-"+row;
            var syncId = "sync-"+row;
            document.getElementById(checkinId).style.display = "none";
            if(document.getElementById(rowId).value == "checkout")
            {
                document.getElementById(rowId).value = "sync";
                document.getElementById(checkoutId).style.display = "none";
                document.getElementById(syncId).style.display = "block";
            }
            else
            {
                document.getElementById(rowId).value = "checkout";
                document.getElementById(syncId).style.display = "none";
                document.getElementById(checkoutId).style.display = "block";
            }
        }




    }

</script>
    <div class="pageHeading">Synchronize Documents</div>
    <div class="pageSubHeading">
        Check to see if there are newer or older documents linked to these documents.
    </div>
    <form name="attachmentForm" id="attachmentForm" action="Synchronize.form" method="post">
        <table width="100%">
            <tr>
                <td align="right">
                    <img src="<%=ar.retPath %>assets/iconSync.gif" />
                    <a href="javascript:onClickAction('Synchronize')"  title="Synchronize Now">
                        Synchronize Now
                    </a>&nbsp;&nbsp;
                    <img src="<%=ar.retPath %>assets/iconDelete.gif" />
                    <a href="javascript:onClickAction('Cancel')"  title="Cancel">
                         <fmt:message key='nugen.button.general.cancel'/>
                    </a>
                </td>
            </tr>
        </table>
        <div id="paging"></div>
       <div id="listofpagesdiv<%=SectionDef.PUBLIC_ACCESS %>">
           <table id="pagelist">
               <tbody>
               <%
               attachmentDisplay(ar, (NGPage) ngp);
               %>
               </tbody>
           </table>
       </div>
       <input type="hidden" name="countRows" id="countRows" value="<%ar.writeHtml(String.valueOf(countRows)); %>">
       <input type="hidden" name="p" id="p" value="<%ar.writeHtml(ngp.getKey()); %>">
    </form>
</div>
</div>
</div>


<script type="text/javascript">

    var attachmentsName= "";
    var description = "";
    var version = "";
    var aid= "";
    var go ="";

    // Custom function to sort  Column  by another Column

    YAHOO.util.Event.addListener(window, "load", function()
    {
        YAHOO.example.EnhanceFromMarkup = function()
        {
            var myColumnDefs = [
                {key:"attachmentsName",label:"<fmt:message key='nugen.attachment.pagelist.AttachmentName'/>",sortable:true,resizeable:true},
                {key:"date",label:"Local Modified Date",sortable:true,sortOptions:{sortFunction:sortDates},resizeable:true},
                {key:"sync",label:"<fmt:message key='nugen.attachment.Sync'/>",sortable:false,resizeable:true},
                {key:"remoteDate",label:"Remote Modified Date",sortable:false,resizeable:true},
                {key:"state",label:"<fmt:message key='nugen.attachment.State'/>",sortable:false,resizeable:true,hidden:true},
                {key:"aid",label:"AID",sortable:false,resizeable:true,hidden:true},
                {key:"timePeriod",label:"timePeriod",sortable:true,resizeable:false,hidden:true}
                ];

            var myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("pagelist"));
            myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            myDataSource.responseSchema = {
                fields: [{key:"attachmentsName", parser:YAHOO.util.DataSourceBase.parseString},
                        {key:"date"},
                        {key:"sync"},
                        {key:"remoteDate"},
                        {key:"state"},
                        {key:"aid"},
                        {key:"timePeriod", parser:YAHOO.util.DataSource.parseNumber}]
            };

            var oConfigs = {
                paginator: new YAHOO.widget.Paginator({
                    rowsPerPage: 200,
                    containers: 'paging'
                }),
                initialRequest: "sort=date&results=999999"
             };

            var myDataTable = new YAHOO.widget.DataTable("listofpagesdiv1", myColumnDefs, myDataSource, oConfigs,
                {caption:"",sortedBy:{key:"date",dir: "attachmentsName"}});
            }();
        });
</script>

<%!public void attachmentDisplay(AuthRequest ar, NGPage _ngp) throws Exception
    {
        this.ngp = _ngp;
        _ngp.scanForNewFiles();
        FolderAccessHelper fdah = new FolderAccessHelper(ar);
        for(AttachmentRecord attachment : ngp.getAllAttachments())
        {
            if (attachment.isDeleted())
            {
                continue;
            }

            String rLink = attachment.getRemoteLink();
            if(!attachment.hasRemoteLink()) {
                continue;
            }

            String id = attachment.getId();
            String displayName = attachment.getNiceNameTruncated(48);
            NGPage page =(NGPage) NGPageIndex.getContainerByKey(ngp.getKey());
            AttachmentRecord attch = page.findAttachmentByID(id);

            ar.write("\n<tr>");
            ar.write("\n<td width=\"250px\">");
            ar.writeHtml(displayName);
            ar.write("</td>");

            long mTime = attch.getModifiedDate();       // modified time of local attachment
            long rCTime = attch.getAttachTime();        // creation time of attachment saved in *.sp file
            long rlmTime = attch.getFormerRemoteTime(); // recently modified remote time saved in *.sp file
            String readonly = "off";
            if((attch.getReadOnlyType()!=null) && (attch.getReadOnlyType().length()>0))
            {
                readonly = attch.getReadOnlyType();
            }

            try
            {
                long rslmTime = fdah.getLastModified(rLink);// recently modified remote fetched from sharepoint
                RemoteLinkCombo rlc = attachment.getRemoteCombo();
                String folderId = rlc.folderId;
                UserPage up = rlc.getUserPage();
                ConnectionType cType = up.getConnectionOrNull(folderId);
                if(cType == null){
                    throw new ProgramLogicError("Can not find a connection with id '"+folderId+"' for user '"+rlc.userKey+"'.");
                }
                ConnectionSettings cSet = up.getConnectionSettingsOrNull(folderId);
                if(cSet == null){
                    throw new ProgramLogicError("Public Web Access can not be synchronized.");
                }
                if(cSet.isDeleted()){
                    throw new ProgramLogicError("Connection have been deleted.");
                }
                boolean lModifed = false;
                boolean rModifed = false;

                //note that times are not always accurate to millisecond, and there may be error
                //should compare if these are within a few seconds of each other, that is close enough
                if(mTime != rCTime){
                    lModifed = true;
                }
                if(rlmTime != rslmTime){
                    rModifed = true;
                }

                ar.write("\n<td>");
                SectionUtil.nicePrintTime(ar.w,attachment.getModifiedDate(), ar.nowTime);
                if(lModifed && !rModifed){
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconChanged.png\" title=\"Modified\">");
                }
                ar.write("</td>");
                ar.write("\n<td>");
                ar.write("<input type=\"hidden\" name=\"readonly-"+id+"\" id=\"readonly-"+id+"\" value="+readonly+">");
                if(lModifed && rModifed){
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconWarning.png\" id=\"warning-"+id+"\" title=\"Conflict\" style=\"display:block\" onclick=\"changeIcon('warning-"+id+"','checkin-"+id+"','checkout-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowUpRight.png\" id=\"checkin-"+id+"\" title=\"Update Repository\" style=\"display:none\" value=\"1\" onclick=\"changeIcon('checkin-"+id+"','checkout-"+id+"','warning-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowDownLeft.png\" id=\"checkout-"+id+"\" title=\"Update Local\" style=\"display:none\" value=\"2\" onclick=\"changeIcon('checkout-"+id+"','warning-"+id+"','checkin-"+id+"');\">");
                    ar.write("<input type=\"hidden\" name=\"aid-"+id+"\" id=\"aid-"+id+"\" value=\"warning\">");
                }
                else if(lModifed && !rModifed){
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconEqualTo.gif\" id=\"sync-"+id+"\" title=\"Synchronized Document\" style=\"display:none\" onclick=\"changeIcon('sync-"+id+"','checkin-"+id+"','checkout-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowUpRight.png\" id=\"checkin-"+id+"\" title=\"Update Repository\" style=\"display:block\" onclick=\"changeIcon('checkin-"+id+"','checkout-"+id+"','sync-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowDownLeft.png\" id=\"checkout-"+id+"\" title=\"Update Local\" style=\"display:none\" onclick=\"changeIcon('checkout-"+id+"','sync-"+id+"','checkin-"+id+"');\">");
                    ar.write("<input type=\"hidden\" name=\"aid-"+id+"\" id=\"aid-"+id+"\" value=\"checkin\">");
                }
                else if(!lModifed && rModifed){
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconEqualTo.gif\" id=\"sync-"+id+"\" title=\"Synchronized Document\" style=\"display:none\" onclick=\"changeIcon('sync-"+id+"','checkin-"+id+"','checkout-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowUpRight.png\" id=\"checkin-"+id+"\" title=\"Update Repository\" style=\"display:none\" onclick=\"changeIcon('checkin-"+id+"','checkout-"+id+"','sync-"+id+"');\">");
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconArrowDownLeft.png\" id=\"checkout-"+id+"\" title=\"Update Local\" style=\"display:block\" onclick=\"changeIcon('checkout-"+id+"','sync-"+id+"','checkin-"+id+"');\">");
                    ar.write("<input type=\"hidden\" name=\"aid-"+id+"\" id=\"aid-"+id+"\" value=\"checkout\">");
                }
                else {
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconEqualTo.gif\" id=\"sync-"+id+"\" title=\"Synchronized Document\">");
                    ar.write("<input type=\"hidden\" name=\"aid-"+id+"\" id=\"aid-"+id+"\" value=\"sync\">");
                }
                ar.write("</td>");
                ar.write("\n<td>");
                SectionUtil.nicePrintTime(ar.w, rslmTime, ar.nowTime);
                if(!lModifed && rModifed){
                    ar.write("<img src=\"");
                    ar.write(ar.retPath);
                    ar.write("assets/iconChanged.png\" title=\"Modified\">");
                }
                ar.write("</td>");

            }
            catch(Exception e){
                ar.write("\n<td>");
                SectionUtil.nicePrintTime(ar.w,attachment.getModifiedDate(), ar.nowTime);
                ar.write("</td>");
                ar.write("\n<td>");
                String pageLink = ar.baseURL+"t/"+page.getSite().getKey()+"/"+page.getKey()+"/problemDiagnosePage.htm?id="+id;
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write("assets/iconError.png\" title=\"Error in connection\">");
                ar.write("</td>");
                ar.write("\n<td><a title=\"");
                ar.writeHtml(e.toString());
                ar.write("\" href=\"");
                if(ngp.isFrozen()){
                    ar.write("#\" onclick=\"javascript:return openFreezeMessagePopup();\">");
                }else{
                    ar.writeHtml(pageLink);
                    ar.write("\">");
                }
                ar.write("Problem with Link</a>");
                ar.write("</td>");

            }

            ar.write("<td>");
            ar.writeHtml(id);
            ar.write("</td>");
            ar.write("\n<td>");
            long diff = (ar.nowTime - attachment.getModifiedDate())/1000;
            ar.writeHtml(String.valueOf(diff));
            ar.write("</td>");

            ar.write("<td>");
            ar.writeHtml(String.valueOf(attachment.getVisibility()));
            ar.write("</td>");

            ar.write("</tr>");
            countRows++;
        }
    }%>
