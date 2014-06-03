<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%
    AuthRequest ud_ar = AuthRequest.getOrCreate(request, response, out);
    ud_ar.assertLoggedIn("You need to Login to Upload a file.");
    String pageId = ud_ar.reqParam("pageId");
    NGPage ngp = (NGPage)NGPageIndex.getContainerByKeyOrFail(pageId);
    if (ngp.isFrozen()) {
        throw new Exception("Program Logic Error: addDocument.jsp should never be invoked when the project is frozen.  Please check the logic of the controller.");
    }

%>
<!-- begin xbrlValidate.jsp -->
<script type="text/javascript" language="javascript" src="<%=ud_ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
<style>
    button {width:190px;}
</style>

<iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
<div>
    <div class="pageHeading">XBRL Validation Setup</div>
    <div class="pageSubHeading">
        MOCKUP DEMONSTRATION: Use this form to initiate (hypothetical) validation of an XBRL document
    </div>
    <br/>
    <table>
    <tr>
        <td colspan="3" class="linkWizardHeading">Validation Settings:</td>
    </tr>
    <tr style="height:50px;padding:15px">
    <td style="padding:15px">Choose Document</td>
    <td style="padding:15px"><select>
        <option value="888">Instance Doc 142.xml</option>
        <option value="348">Q4 Late Returns.xml</option>
        <option value="668">Yet Another Instance.xml</option>
        </td>
    </tr>
    <tr style="height:50px;padding:15px">
    <td style="padding:15px"></td>
    <td style="padding:15px"><button class="inputBtn" onClick="location.href='xbrlResults.htm'">Validate</button></td>
    </tr>
    </table>
</div>
<!-- end addDocument.jsp -->
