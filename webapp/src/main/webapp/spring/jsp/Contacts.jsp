<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="/spring/jsp/include.jsp"
%><%@ include file="functions.jsp"
%><%@page import="org.socialbiz.cog.ProfileRequest"
%><%@page import="java.util.Set"
%><%@page import="org.socialbiz.cog.NGRole"
%><%!
    String pageTitle="";
%><%
    
    UserProfile uProf = ar.getUserProfile();
    if (uProf == null)
    {
        throw new NGException("nugen.exception.cant.find.user",null);
    }
    
    Map map = (Map)request.getAttribute("contactList");
    NGRole aRole  = ar.getUserPage().getRole("Contacts");
    List <AddressListEntry> allUsers = null;
    if(aRole != null){
        allUsers = aRole.getExpandedPlayers(ar.getUserPage());
    }
%>

<script>
   
    function back(){
        window.location = "userProfile.htm?active=2";
    }
    function unSelect(type){
        var obj = document.getElementById(type);
        obj.checked = false;
    }
    function selectAll(){
        var allContacts = document.getElementById("contactsAll");
        var obj = document.getElementsByName("contactList");
        
        for(i=0; i<obj.length ; i++){
            if(allContacts.checked == true){
                obj[i].checked = true;
            }else{
                obj[i].checked = false;
            }
        }
    }
</script>
<body class="yui-skin-sam">
    <div class="generalSettings">
        <div class="pageHeading">Select Contacts</div>
        <form action="addUserContacts.form" method="post">
        <div align="right">
            <input type="submit" class="inputBtn" value="Add"> &nbsp;&nbsp;
            <input type="button" class="inputBtn" value="Back" onclick="back();"/>
        </div><br/>
        <table border="0px solid gray" class="gridTable" width="100%">
                <thead>
                <tr>
                   <th width="30%">&nbsp;&nbsp;&nbsp;<b>Name</b></th>
                   <th width="50%">&nbsp;&nbsp;&nbsp;<b>Email-Id</b></th>
                    <th><b><input type="checkbox" name="contactsAll" id="contactsAll" onclick="return selectAll();" /> &nbsp; Select All &nbsp; </b>
                    </th>
                </tr>
                </thead>
                <tr>
                    <td colspan="2">&nbsp;</td>
                </tr>
                <%
                Iterator itr = map.keySet().iterator();
                while(itr.hasNext()){
                    String key = (String)itr.next();
                %>
                <tr>
                    <td>
                      &nbsp;&nbsp;&nbsp; <%=key %> 
                    </td>
                    <td>
                      &nbsp;&nbsp;&nbsp; <%=map.get(key) %>
                    </td>
                    
                    <td>
                    <%
                    String checked = "";
                    if(allUsers != null){
                        for (AddressListEntry ale : allUsers)
                        {
                            if(ale.getUniversalId().trim().equals(((String)map.get(key)).trim())){ 
                                checked = "checked=\"checked\"";
                            }
                        }
                    }
                     %>
                      &nbsp;&nbsp;&nbsp;<input type="checkbox" name="contactList" <%=checked %> 
                      onclick="return unSelect('contactsAll')" value="<%=key %>:<%=map.get(key) %>"  />
                    </td>
                </tr>
              <%} %>
            </table>     
            </form>     
    </div>
</body>
