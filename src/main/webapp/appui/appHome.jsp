<%@page import="com.fujitsu.appui.common.CommonConstants"%>
<%@page import="com.fujitsu.appui.util.Utility"%>
<%@page import="com.fujitsu.appui.valueobject.AppUIConfig"%>
<%@page import="com.fujitsu.appui.valueobject.AppUIGroup"%>
<%@page import="com.fujitsu.appui.valueobject.AppUIProcDef"%>
<%@page import="com.fujitsu.appui.valueobject.AppUISearch"%>
<%@page import="com.fujitsu.appui.valueobject.AppUILink"%>

<%@page import="java.net.URLEncoder"%>
<%@page import="java.util.Date"%>

<%

    AppUIConfig uiConfig = (AppUIConfig) request.getAttribute(CommonConstants.REQUEST_ATTR_UICONFIG);

    String name = uiConfig.getName();
    String id = uiConfig.getId();
    String desc = uiConfig.getDesc();
    AppUIGroup[] groups = uiConfig.getGroups();
    AppUILink[] alinks = uiConfig.getLinks();
    String lastUpdatedBy = uiConfig.getLastUpdatedBy();
    long lastUpdatedOn = uiConfig.getLastUpdatedOn();

%>


    Application Name : <%Utility.writeHtmlWithNBSPs(out,  name, true);%><br/>

    <!--Application Desc : <%Utility.writeHtmlWithNBSPs(out,  desc, true);%><br/>
        Last Modified By : <%Utility.writeHtmlWithNBSPs(out,  lastUpdatedBy, true);%><br/>
        Last Modified On : <%=new Date(lastUpdatedOn)%><br/>
    -->

<%
    for(int i=0; groups!=null && i<groups.length; i++)
    {
        AppUIGroup group = groups[i];
        String groupName = group.getName();
        String groupDesc = group.getDesc();
        AppUIProcDef[] processDefinitions = group.getProcessDefinitions();
        AppUISearch[] searches = group.getSearches();
        AppUILink[] glinks = group.getLinks();
%>

        <br/>
        <b><%Utility.writeHtmlWithNBSPs(out,groupName);%></b>
        <br/>
        <br/>
<%

        for(int j=0; processDefinitions!=null && j<processDefinitions.length; j++)
        {
            AppUIProcDef procDef = processDefinitions[j];
            String pname = procDef.getName();
            String pdisplayName = procDef.getDisplayName();
            String pdesc = procDef.getDesc();
            //String pstate = procDef.getState();;
            //String pstatusForm = procDef.getStatusForm();
            //String pinstanceMessage = procDef.getInstanceMessage();
            //String pstatusUDA = procDef.getStatusUDA();
            //String url = procDef.getUrl();

%>
           <a href="StartProcessForm.htm?planName=<%Utility.writeHtmlWithNBSPs(out,pname);%>"><%Utility.writeHtmlWithNBSPs(out,pdisplayName);%></a> <br/>
           <%Utility.writeHtmlWithNBSPs(out,pdesc);%><br/>

<%
        } // processdefinition


        for(int j=0; searches!=null && j<searches.length; j++)
        {
            AppUISearch search = searches[j];
            //String sid = search.getId();
            String sname = search.getName();
            String sdesc = search.getDesc();
            String stype = search.getType();
            //SearchStruct search = search.getSearch();
            String sowner = search.getOwner();
            String surl = search.getUrl();
        } // searches
                
        for(int j=0; glinks!=null && j<glinks.length; j++)
        {
            AppUILink glink = glinks[j];
            String glinkName = glink.getName();
            String glinkUrl = glink.getUrl();
        } // group links
        
        
    } // groups.

    
    // display the links.
    for(int i=0; alinks!=null && i<alinks.length; i++)
    {
        AppUILink alink = alinks[i];
        String alinkName = alink.getName();
        String alinkUrl = alink.getUrl();
    } // application links.
%>

