<%@page errorPage="/spring/jsp/error.jsp"
%><%@ include file="administration.jsp"
%><%

    String searchDate = ar.defParam("searchDate", null);
    if (searchDate==null) {
        //put today in if no date given
        searchDate = new SimpleDateFormat("MM/dd/yyyy").format(new Date());
    }
%>

<div class="content tab03" style="display:block;">
    <div class="section_body">
        <div style="height:10px;"></div>
        <div class="pageSubHeading">
            <table width="100%">
                <tr>
                    <td rowspan="2" width="42px"><img src="<%=ar.retPath %>assets/iconError_BIG.png" width="32" height="32" /></td>
                    <td>
                        <div class="pageHeading">Error Log for <%=searchDate%></div>
                    </td>
                </tr>
            </table>
        </div>
        <div style="height:10px;"></div>
        <table border="0px solid red">
            <form method="get" action="errorLog.htm">
            <tr>
                <td class="gridTableColummHeader">Search By Date:</td>
                <td style="width:12px;"></td>
                <td><input type="text" class="inputGeneralSmall" size="10" name="searchDate" id="searchDate"  value="<%=searchDate%>" readonly="1"/>
                    <img src="<%=ar.retPath %>/jscalendar/img.gif" id="btn_searchDate" style="cursor: pointer;" title="Date selector"/>
                </td>
                <td> &nbsp; </td>
                <td><input type="submit" value="View Errors for Date"/></td>
            </tr>
            </form>
        </table>
        <div id="container" class="yui-skin-sam" >
            <div id="paging1"></div>
            <div id="xml"></div>
        </div>
        <%
        SectionTask.plugInCalenderScript(out, "searchDate", "btn_searchDate");
        %>
    </div>
</div>
<script type="text/javascript">

    function populateErrorLogs(date){

        // for the loading Panel
        YAHOO.namespace("example.container");
        if (!YAHOO.example.container.wait)
        {
            // Initialize the temporary Panel to display while waiting for external content to load
            YAHOO.example.container.wait =
                new YAHOO.widget.Panel("wait",
                                        { width: "240px",
                                          fixedcenter: true,
                                          close: false,
                                          draggable: false,
                                          zindex:4,
                                          modal: true,
                                          visible: false
                                        }
                                    );

            YAHOO.example.container.wait.setHeader("Loading, please wait...");
            YAHOO.example.container.wait.setBody("<img src=\"<%=ar.retPath%>loading.gif\"/>");
            YAHOO.example.container.wait.render(document.body);
        }
        // Show the loading Panel
        YAHOO.example.container.wait.show();

        // for data table.
        YAHOO.example.Local_XML = function()
        {
            var errorLogDS, errorLogDT, oConfigs;

            var connectionCallback = {
                success: function(o) {

                    // hide the loading panel.
                    YAHOO.example.container.wait.hide();
                    var xmlDoc = o.responseXML;

                    var errorUrl = function(elCell, oRecord, oColumn, sData) {
               elCell.innerHTML = "<a href='errorDetails" + oRecord.getData("errorNo") + ".htm?searchByDate="+oRecord.getData("modTime")+ "'target='_blank'>" + "ENo-"+sData + "</a>";
             };

             var formatDate = function(elCell, oRecord, oColumn, sData)  {
                 var date=oRecord.getData("modTime");
                 var now = new Date(parseInt(date));
                 var d  = now.getDate();
                 var day = (d < 10) ? '0' + d : d;
                 var m = now.getMonth() + 1;
                 var month = (m < 10) ? '0' + m : m;
                 var yy = now.getYear();
                 var year = (yy < 1000) ? yy + 1900 : yy;
                 var hh  = now.getHours();
                 var HH = (hh < 10) ? '0' + hh : hh;
                 var mm  = now.getMinutes();
                 var MM = (mm < 10) ? '0' + mm : mm;
                 var ss  = now.getSeconds();
                 var SS = (ss < 10) ? '0' + ss : ss;
                 var formatDate=year+":" +month +":" + day+":" +HH+ ":"+MM+":"+SS;
                 elCell.innerHTML=formatDate;
             };
             var formatErrMsg = function(elCell, oRecord, oColumn, sData)  {
                  elCell.textContent= oRecord.getData("errorMessage");
             }
             var errorLogCD = [
                 {key:"modTime",label:"Date & Time",formatter:formatDate},
                 {key:"errorNo",label:" Error Ref No",formatter:errorUrl},
                 {key:"modUser",label:" User"},
                 {key:"errorMessage",label:"Error Message",formatter:formatErrMsg}
             ];

                    errorLogDS = new YAHOO.util.DataSource(xmlDoc);

                    errorLogDS.responseType = YAHOO.util.DataSource.TYPE_XML;
                    errorLogDS.responseSchema = {
                        resultNode: "error",
                        fields: [{key:"modTime"},
                                {key:"errorNo"},
                                {key:"modUser"},
                                {key:"errorMessage", parser:YAHOO.util.DataSource.parseString}
                        ]};

                    oConfigs = { paginator: new YAHOO.widget.Paginator({rowsPerPage:100,containers:'paging1'}), initialRequest:"results=99",MSG_EMPTY:"No records found on this "+date};

                    errorLogDT = new YAHOO.widget.DataTable(
                                      "xml",
                                      errorLogCD,
                                      errorLogDS,
                                      oConfigs
                                  );


                },
                failure: function(o)
                {
                    // hide the loading panel.
                    YAHOO.example.container.wait.hide();
                }
            };

            var servletURL = "<%=ar.retPath%>v/<%ar.writeURLData(userKey);%>/getErrorLogXML.ajax?searchByDate=<%=searchDate%>";

            var getXML = YAHOO.util.Connect.asyncRequest("GET",servletURL, connectionCallback);

            return {
                oDS: errorLogDS,
                oDT: errorLogDT
            };
        }();
    }

    (function(){
        var default_options = {
            prefix: '',     // prefix added to counter display
            suffix: '',     // suffix added to counter display
            dynamic_labels: true,   // if true, labels (hours, minutes) are output as needed
            show_seconds: true, // if true, seconds is also displayed
            frequency: 1000    // 1 second in milliseconds
        };

        var timer = function(display,options){
            if (typeof display == 'function') { this.display = display; }
            else { this.el = (typeof display == 'string') ? document.getElementById(display) : display; }

            this.options = {};
            if (!options) options = {};
            for (var p in default_options) { this.options[p] = (p in options) ? options[p] : default_options[p]; }

            if (!this.options.show_seconds && !options.frequency) this.options.frequency = 60000;   // change to 1 min. intervals
        }
        timer.prototype = {
            start: function() {
                this.resume( (new Date).getTime() );
            },
            resume: function(startTime) {
                if (startTime) this.startTime = startTime;
                var obj = this;
                var ticktock = function() {
                    var s = Math.floor(((new Date).getTime() - obj.startTime)/1000);
                    var m = Math.floor(s/60); s %= 60;
                    var h = Math.floor(m/60); m %= 60;
                    var d = Math.floor(h/24); h %= 24;

                    if (obj.display) obj.display(d,h,m,s);
                    if (obj.el) {
                        var html = '';
                        if (obj.options.dynamic_labels) {
                            if (d) { html += d + ' day' + (d > 1 ? 's' : ''); }
                            if (d && h) { html += ', '; }
                            if (h) { html += h + ' hour' + (h > 1 ? 's' : ''); }
                            if (h && m) { html += ', '; }
                            if (m) { html += m + ' minute' + (m > 1 ? 's' : ''); }
                            if (obj.options.show_seconds) {
                                if (m && s) { html += ', '; }
                                if (s) { html += s + ' second' + (s > 1 ? 's' : ''); }
                            }
                        }
                        else {
                            html += d + ' days ' + h + ' hours ' + m + ' minutes';
                            html += obj.options.show_seconds ? ' ' + s + ' seconds' : '';
                        }
                        if (html.length) {
                            obj.el.innerHTML =
                                    (obj.options.prefix != null ? obj.options.prefix : '') +
                                    html +
                                    (obj.options.suffix != null ? obj.options.suffix : '');
                        }
                    }
                    obj.timerID = setTimeout(arguments.callee,obj.options.frequency);
                };
                ticktock(); // start timer
            },
            stop: function() { clearInterval(this.timerID); }
        };

        // Expose
        window.ElapsedTimer = timer;
    })();

    (function(){
        var fn = window.onload;
        window.onload = function(){
            if (typeof fn == 'function') { fn(); }

            (new ElapsedTimer('elapsed_time')).resume('<%=lastSentTime%>');
        }
    })();

    populateErrorLogs(searchDate);
</script>

<%
    SectionTask.plugInCalenderScript(out, "searchDate", "btn_searchDate");
%>
