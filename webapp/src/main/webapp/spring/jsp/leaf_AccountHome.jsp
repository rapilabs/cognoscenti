<%@ include file="/spring/jsp/include.jsp"
%><%@ include file="/spring/jsp/functions.jsp"
%><%
/*
Required parameters:

    1. accountId : This is the id of an site and here it is used to retrieve NGBook.

*/

    String accountId = ar.reqParam("accountId");

%><%!
    String pageTitle="";

%><%
    NGBook ngb = (NGBook)NGPageIndex.getContainerByKeyOrFail(accountId);

    int COUNT_OF_PUBLIC_NOTES = NGWebUtils.getNotesCount(ngb,ar,SectionDef.PUBLIC_ACCESS);
    int COUNT_OF_MEMBER_NOTES = NGWebUtils.getNotesCount(ngb,ar,SectionDef.MEMBER_ACCESS);

    String specialTab = "Site Home Content";

    if(ngb!=null){
        //TODO: should be translatable
        pageTitle= ngb.getFullName() + " - Public";
    }

    UserProfile uProf = ar.getUserProfile();

%>
<head>
    <title><% ar.writeHtml(pageTitle); %></title>

    <link href="<%=ar.baseURL%>css/tabs.css" rel="styleSheet" type="text/css" media="screen" />
    <link href="<%=ar.baseURL%>css/tables.css" rel="styleSheet" type="text/css" media="screen" />


    <style type="text/css">
        #mycontextmenu ul li {
            list-style:none;
        }

        .yuimenubaritemlabel,
        .yuimenuitemlabel {
            outline: none;
         }

    </style>


    <!--[if IE 7]>
        <link href="<%=ar.baseURL%>css/ie7styles.css" rel="styleSheet" type="text/css" media="screen" />
    <![endif]-->


    <script type="text/javascript" src="<%=ar.baseURL%>jscript/nugen_utils.js"></script>
    <script type="text/javascript" src="<%=ar.baseURL%>jscript/yahoo-dom-event.js"></script>
    <script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/jquery.js"></script>
    <script type="text/javascript" language="javascript" src="<%=ar.baseURL%>jscript/tabs.js"></script>
    <script>
        var specialSubTab = '<fmt:message key="${requestScope.subTabId}"/>';

        var tab0_home = '<fmt:message key="nugen.projecthome.subtab.public"/>';
        var tab1_home = '<fmt:message key="nugen.projecthome.subtab.private"/>';
        var tab2_home = '<fmt:message key="nugen.projecthome.subtab.member"/>';
        var tab3_home = '<fmt:message key="nugen.accounthome.subtab.accountbulletin"/>';
        var account_public_notes_count = '<%=COUNT_OF_PUBLIC_NOTES%>';
        var account_member_notes_count = '<%=COUNT_OF_MEMBER_NOTES%>';
        var retPath ='<%=ar.retPath%>';
    </script>
</head>
<body class="yui-skin-sam" oncontextmenu="return true;" onclick="if(oContextMenu!='')oContextMenu.hide();">
    <div>
        <!-- Content Area Starts Here -->
        <div class="generalArea">
            <div class="generalContent tabContainer">
                <!-- Tab Structure Starts Here -->
                <div id="container">
                    <div>
                        <ul id="subTabs" class="menu">

                        </ul>
                    </div>
                    <script>
                     createAccountSubTabs("_home");
                    </script>


    <script language="javascript">
        var oContextMenu="";
        var idForEditing="";
        var addedInContextMenu=false;
        function onNoteEditMenu(p_sType, p_aArgs, p_oValue) {

            openWin(document.getElementById("hreflink_"+idForEditing).href);
        }

        function sendNodeByEmail(p_sType, p_aArgs, p_oValue) {

            openWin(document.getElementById("emaillink_"+idForEditing).href);
        }

        function createLeafletMenuItem(p_sType, p_aArgs, p_oValue) {

            openWin(document.getElementById("create_leaflet").href);
        }

        function onMenuItemDelete(p_sType, p_aArgs, p_oValue) {
            YAHOO.util.Connect.asyncRequest('POST', document.getElementById(idForEditing+"_remove_link").value,deleteSubmitResponse);
        }

        function onMenuItemMakeMember(p_sType, p_aArgs, p_oValue) {
            YAHOO.util.Connect.asyncRequest('POST', document.getElementById(idForEditing+"_visibility_link").value+"&visibility=2",visibilitySubmitResponse);
        }

        function onMenuItemMakePublic(p_sType, p_aArgs, p_oValue) {
            YAHOO.util.Connect.asyncRequest('POST', document.getElementById(idForEditing+"_visibility_link").value+"&visibility=1",visibilitySubmitResponse);
        }


        function onMenuItemMakePrivate(p_sType, p_aArgs, p_oValue) {
            YAHOO.util.Connect.asyncRequest('POST', document.getElementById(idForEditing+"_visibility_link").value+"&visibility=4",visibilitySubmitResponse);
        }


        var deleteSubmitResponse ={
               success: function(o) {
                   var respText = o.responseText;

                   if(respText== "success"){
                       window.location.reload();
                   }
                   else{
                        var splittedText = respText.split(":");
                       if(splittedText != null && splittedText.length >= 1){
                            alert(splittedText[1]);
                        }
                   }
               },
               failure: function(o) {
                alert("deleteSubmitResponse Error:" +o.responseText);
               }
        }

        var visibilitySubmitResponse ={
            success: function(o) {
                var respText = o.responseText;
                if(respText.split(":")[0]== "success"){
                    window.location.reload();
                }
                else{
                    var splittedText = respText.split(":");
                    if(splittedText != null && splittedText.length >= 1){
                        alert(splittedText[1]);
                    }
                }
            },
            failure: function(o) {
                alert("visibilitySubmitResponse Error:" +o.responseText);
            }
        }

        function onRightClick(id){
            idForEditing =  id;

            oContextMenu = new YAHOO.widget.ContextMenu("mycontextmenu", {
                trigger: document.getElementById(idForEditing)
            });
            var member = false;
            var public_tab = false;
            var private_tab = false;
            if(specialSubTab==tab0_home){
                public_tab = true;
            }
            else if(specialSubTab==tab1_home){
                private_tab = true;
            }
            else if(specialSubTab==tab2_home){
                member = true;
            }


            if(!addedInContextMenu){
                oContextMenu.addItems([
                                   [{ text: "Create Note", onclick: { fn: createLeafletMenuItem }}],
                                   [{ text: "Edit Note", onclick: { fn: onNoteEditMenu }}],
                                   [{ text: "Delete Note", onclick: { fn: onMenuItemDelete }}],
                                   [{ text: "Send Note By Email", onclick: { fn: sendNodeByEmail }}],
                                   [{ text: "Make Public", onclick: { fn: onMenuItemMakePublic },disabled: public_tab}],
                                   [{ text: "Make Member Only", onclick: { fn: onMenuItemMakeMember }, disabled: member}]
                ]);

            }

            //  Subscribe to the "render" event and set the "hideFocus" attribute
            //  of each <a> element to "true."

            oContextMenu.subscribe("render", function () {

                var aItems = this.getItems(),
                nItems = aItems.length,
                i;

                if (nItems > 0) {
                    i = nItems - 1;
                    do {
                        aItems[i].element.firstChild.hideFocus = true;
                    }
                    while(i--);
                }
            });
            oContextMenu.render(document.getElementById(idForEditing));
            addedInContextMenu=true;
        }
    </script>
</body>
