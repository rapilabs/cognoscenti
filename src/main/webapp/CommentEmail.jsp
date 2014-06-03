<%@page errorPage="error.jsp"
%><%@page contentType="text/html;charset=UTF-8" pageEncoding="ISO-8859-1"
%><%@page import="org.socialbiz.cog.AuthRequest"
%><%@page import="org.socialbiz.cog.NGBook"
%><%@page import="org.socialbiz.cog.NGPage"
%><%@page import="org.socialbiz.cog.NGPageIndex"
%><%@page import="org.socialbiz.cog.UtilityMethods"
%><%@page import="java.net.URLEncoder"
%><%@page import="org.w3c.dom.Element"
%><%
    //This is a legacy forwarding page
    //the old pattern is
    //   /CommentEmail.jsp?p={projectid}&oid={noteid}


    AuthRequest ar = AuthRequest.getOrCreate(request, response, out);

    /* if the parameter is not found in the parameters list, then find it out in the attributes list */
    String p = ar.reqParam("p");
    //note that oid could be anything passed in, including malicious scripting, so must URLEncode
    String oid = ar.reqParam("oid");

    NGPage ngp = NGPageIndex.getProjectByKeyOrFail(p);
    ar.setPageAccessLevels(ngp);

    //redirect to the new UI to email a leaf
    String redirectURL = ar.retPath + "t/sendNoteByEmail.htm?p=" + ngp.getKey()
            + "&oid=" + URLEncoder.encode(oid, "UTF-8")
            + "&encodingGuard=\u6771\u4eac&project=true";
    response.sendRedirect(redirectURL);
%>
<p>This resource has a new location, update the source link if possible.</p>
<p>Access the <a href="<%=redirectURL%>">resource with this link</a></p>



