<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@page import="org.socialbiz.cog.spring.XHTMLError"
%><%
/*
Required parameter:

    1. errors : This parameter is used to retrieve list of XHTMLError from request attribute.
    
*/
 
    List<XHTMLError> errors = (List<XHTMLError>)request.getAttribute("errors");
    
    writeHtmlErros(errors,ar);

%><%!

    public void writeHtmlErros(List<XHTMLError> errors,AuthRequest out )throws Exception{
         for (XHTMLError error : errors) {
             out.writeHtml("Line : ");
             out.writeHtml(String.valueOf(error.getLine()));
             out.writeHtml(" Column : ");
             out.writeHtml(String.valueOf(error.getColumn()));
             out.writeHtml(" - ");
             out.writeHtml(error.getErrorMessage());
             out.write("<br/>");
            }
         out.write("\n\n\t Total Error on this Page = " + errors.size());
    }

%>