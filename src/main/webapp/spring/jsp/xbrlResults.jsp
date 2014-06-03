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
<!-- begin xbrlResults.jsp -->
<script type="text/javascript" language="javascript" src="<%=ud_ar.retPath%>bewebapp/bewebapp.nocache.js"></script>
<style>
    button {width:190px;}
</style>

<iframe src="javascript:''" id="__gwt_historyFrame" tabIndex='-1' style="position:absolute;width:0;height:0;border:0"></iframe>
<div>
    <div class="pageHeading">XBRL Validation Results</div>
    <div class="pageSubHeading">
        MOCKUP DEMONSTRATION: Displays hypothetical results of validation
    </div>
    <br/>
    <table>
    <tr>
        <td colspan="3" class="linkWizardHeading">Here are the (hypothetical) results:</td>
    </tr>
    <tr style="height:50px;padding:15px">
    <td style="padding:15px">1. line 12</td>
    <td style="padding:15px"><p>Missing identifier.</p></td>
    </tr>
    <tr style="height:50px;padding:15px">
    <td style="padding:15px">2. line 392</td>
    <td style="padding:15px"><p>Too many untyped qualifiers.</p></td>
    </tr>
    <tr style="height:50px;padding:15px">
    <td style="padding:15px">3. line 414</td>
    <td style="padding:15px"><p>Not enough donations to charity.</p></td>
    </tr>
    </table>

</div>
<!-- end addDocument.jsp -->
