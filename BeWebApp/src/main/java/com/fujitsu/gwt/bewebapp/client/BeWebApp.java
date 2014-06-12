package com.fujitsu.gwt.bewebapp.client;

import java.util.Vector;
import com.fujitsu.gwt.bewebapp.client.gantt.ChartHandler;
import com.google.gwt.core.client.EntryPoint;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.SelectionEvent;
import com.google.gwt.event.logical.shared.SelectionHandler;
import com.google.gwt.http.client.URL;
import com.google.gwt.user.client.Random;
import com.google.gwt.user.client.Timer;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Anchor;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.DecoratedTabPanel;
import com.google.gwt.user.client.ui.DialogBox;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FlowPanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.Hidden;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Hyperlink;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.RadioButton;
import com.google.gwt.user.client.ui.RootPanel;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.xml.client.Document;
import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.NamedNodeMap;
import com.google.gwt.xml.client.Node;
import com.google.gwt.xml.client.NodeList;
import com.google.gwt.xml.client.XMLParser;

import gwtupload.client.IUploader;
import gwtupload.client.ModalUploadStatus;
import gwtupload.client.MultiUploader;
import gwtupload.client.PreloadedImage;
import gwtupload.client.SingleUploader;
import gwtupload.client.IFileInput.FileInputType;
import gwtupload.client.IUploadStatus.Status;
import gwtupload.client.IUploader.OnChangeUploaderHandler;
import gwtupload.client.IUploader.OnFinishUploaderHandler;
import gwtupload.client.PreloadedImage.OnLoadPreloadedImageHandler;

import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.Widget;
import java.util.HashMap;

/**
 * Entry point classes define <code>onModuleLoad()</code>.
 */
public class BeWebApp implements EntryPoint {
    /**
     * The message displayed to the user when the server cannot be reached or
     * returns an error.
     */
    private static final String SERVER_ERROR = "An error occurred while "
            + "attempting to contact the server. Please check your network "
            + "connection and try again.";

    private static final String MEMBER_NOTLOGGED = "In order to see the member "
            + "section of the leaf, you need to be logged in, and you need to be an "
            + "member of the leaf. Because you are not logged in, the system is unable "
            + "to tell whether you are a member or not.";

    private static final String PRIVATE_NOTLOGGED = "In order to see the member "
            + "section of the leaf, you need to be logged in, and you need to be an "
            + "member of the leaf. Because you are not logged in, the system is unable "
            + "to tell whether you are a member or not.";

    private static final String PUBLIC_NOTDATA = "THERE IS NO PUBLIC NOTES TO DISPLAY";
    private static final String MEMBER_NOTDATA = "THERE IS NO PUBLIC NOTES TO DISPLAY";
    private static final String PRIVATE_NOTDATA = "THERE IS NO PUBLIC NOTES TO DISPLAY";

    private static final String CREATE_NO = "ONLY MEMBER OF THIS PROJECT CAN "
            + "CREATE A NOTE.";

    public static Image loadImage;
    public static Image addImg;
    public static Image saveImg;
    public static Image deleteImg;
    public static Image refreshImg;
    public static Image openImg;

    /**
     * This is the entry point method.
     */

    DecoratedTabPanel tabPanel = new DecoratedTabPanel();
    VerticalPanel mPanel = new VerticalPanel();
    VerticalPanel pPanel = new VerticalPanel();
    VerticalPanel prPanel = new VerticalPanel();
    VerticalPanel crPanel = new VerticalPanel();
    VerticalPanel uploadPanel = new VerticalPanel();
    Button uploadSubmitBtn = new Button("Upload File");
    DisclosurePanel createPanel = new DisclosurePanel();
    AsyncCallback<String> ucallBack = null;

    HorizontalPanel statusPanel = new HorizontalPanel();
    HTML status = new HTML("");
    Button statusButton = new Button("AutoUpdate");

    // A panel where the thumbnails of uploaded images will be shown
    private FlowPanel panelImages = new FlowPanel();
    private final FormPanel form2 = new FormPanel();

    // Error Panel
    private static DialogBox errDialogBox;
    private static Button bErrClose;
    private static VerticalPanel errorVp;
    private static HTML serverError;

    private static DialogBox loadingDialogBox;

    // Bes Panel
    VerticalPanel beVPanel;
    MultiUploader mUploader;
    String apageid;
    Hidden hPageId;

    public static final LeafServiceAsync leafService = GWT
            .create(LeafService.class);
    public static final String UPLOAD_ACTION_URL = GWT.getModuleBaseURL()
            + "upload";
    public static final String GWT_UPLOAD_ACTION_URL = GWT.getModuleBaseURL()
            + "gwtupload";
    public static final BesServiceAsync besService = GWT
            .create(BesService.class);

    public static String imgroot = "/bewebapp/gwt/standard/images/icons.gif";

    public void onModuleLoad() {

        RootPanel lrp = RootPanel.get("gwt_notes");
        if (lrp != null) {
            init();
            String pageId = getPageId();
            loadLeflets(pageId);
            lrp.add(tabPanel);
        }

        RootPanel noteEditorPanel = RootPanel.get("gwt_editor");
        if (noteEditorPanel != null) {
            init();
            LeafData note = null;

            String nid = Window.Location.getParameter("nid");
            String pid = Window.Location.getParameter("pid");
            String visibility =Window.Location.getParameter("visibility_value");

            noteEditorPanel.add(mPanel);

            if (nid == null || nid.length() == 0) {
                note = new LeafData();
                note.setPageId(pid);
                note.setSubject("");
                note.setData("");
                if("1".equals(visibility)){
                    note.setVisibility(1);
                }else{
                    note.setVisibility(2);
                }
                note.setId("-1");
                note.setPinPosition("0");
                note.setEffectiveDate(System.currentTimeMillis());
                note.setEditedBy(2);
            }

            if (note == null) {
                mPanel.add(loadImage);
                leafService.getNote(nid, pid, new AsyncCallback<LeafData>() {
                    public void onFailure(Throwable caught) {
                        mPanel.remove(loadImage);
                    }

                    public void onSuccess(LeafData note) {
                        mPanel.remove(loadImage);
                        updateNoteEditor(note);
                    }
                });
            } else {
                updateNoteEditor(note);
            }
        }

        RootPanel berp = RootPanel.get("gwt_bentity");
        if (berp != null) {
            String prjId = getFullProjectId();
            this.loadBes(prjId);
            berp.add(beVPanel);
        }

        RootPanel gwtWait = RootPanel.get("gwt_wait");
        if (gwtWait != null) {
            statusButton
                    .setTitle("Refresh automatically if page content changed.");
            statusPanel.add(statusButton);
            statusPanel.add(status);
            gwtWait.add(statusPanel);
            String pageId = getPageId();
            callForNtfx(pageId);
        }

        RootPanel gwtUpload = RootPanel.get("gwt_single_upload");
        if (gwtUpload != null) {
            initSingleUpLoaderPanel(gwtUpload);
        }

        String aid = Window.Location.getParameter("aid");
        RootPanel gwtUploadRevised = RootPanel
                .get("gwt_upload_revised_document");
        if (gwtUploadRevised != null) {
            initUploadRevisedDocPanel(gwtUploadRevised, aid);
        }

        RootPanel gwtMultipleUpload = RootPanel.get("gwt_multiple_upload");
        if (gwtMultipleUpload != null) {
            initMultipleUpLoaderPanel(gwtMultipleUpload);
        }

        RootPanel ganttPanel = RootPanel.get("gwt_gantt");
        if(ganttPanel != null){
            ChartHandler chartHandler = new ChartHandler(ganttPanel);
            String dataType = Window.Location.getParameter("data");
            String pid = getPageId();
            if(dataType.equals("sample")){
                pid = "-1";
            }
            chartHandler.loadGanttChart(pid);
        }

    }

    private void initSingleUpLoaderPanel(RootPanel cpanel) {
        apageid = getPageId();
        final FlexTable grid = new FlexTable();
        grid.setText(1, 0, "Select File:");
        grid.getCellFormatter().setStyleName(1, 0, "gridTableColummHeader_3");
        grid.setText(2, 0, "");
        grid.setStyleName("linkWizard");
        hPageId = new Hidden("pageid", apageid);
        grid.setWidget(2, 1, hPageId);

        final Hidden perm = new Hidden("atype", "Member");
        grid.setWidget(2, 2, perm);

        grid.setText(4, 0, "AccessName:");
        grid.getCellFormatter().setStyleName(4, 0, "gridTableColummHeader_3");

        final TextBox antb = new TextBox();
        antb.setName("aname");
        grid.setWidget(4, 1, antb);
        antb.setStyleName("inputGeneral");

        grid.setText(5, 0, "Description:");
        grid.getCellFormatter().setStyleName(5, 0, "gridTableColummHeader_3");

        final TextArea adta = new TextArea();
        adta.setName("desc");
        adta.setStyleName("textAreaGeneral");
        grid.setWidget(5, 1, adta);

        final RadioButton op = new RadioButton("visibility", "Public");
        final RadioButton om = new RadioButton("visibility", "Member");
        op.setStyleName("generalSettings");
        om.setStyleName("generalSettings");
        op.addClickHandler(new ClickHandler() {
            public void onClick(ClickEvent event) {
                perm.setValue("Public");
            }
        });
        om.addClickHandler(new ClickHandler() {
            public void onClick(ClickEvent event) {
                perm.setValue("Member");
            }
        });
        om.setValue(true);
        HorizontalPanel ohp = new HorizontalPanel();
        ohp.setSpacing(5);
        ohp.add(op);
        ohp.add(om);
        grid.setText(6, 0, "Permission:");
        grid.getCellFormatter().setStyleName(6, 0, "gridTableColummHeader_3");
        grid.setWidget(6, 1, ohp);

        final ListBox lb = new ListBox();
        lb.setName("existingaid");
        lb.addItem("select", "0");
        lb.setStyleName("selectGeneralSmall");

        final HashMap<String, AttachmentData> aDataMap = new HashMap<String, AttachmentData>();

        leafService.getAttachments(apageid,
                new AsyncCallback<AttachmentData[]>() {
                    public void onFailure(Throwable caught) {
                        Window.alert("Exception:" + caught);
                    }

                    public void onSuccess(AttachmentData[] aDataArray) {
                        for (int i = 0; i < aDataArray.length; i++) {
                            AttachmentData aData = aDataArray[i];
                            if (!aData.getReadOnly().equals("on")) {
                                lb.addItem(aData.getName(), aData.getId());
                                aDataMap.put(aData.getId(), aData);
                            }
                        }
                    }
                });

        lb.addChangeHandler(new ChangeHandler() {
            public void onChange(ChangeEvent event) {
                int selectedIndex = lb.getSelectedIndex();
                if (selectedIndex > 0) {
                    String cid = lb.getValue(selectedIndex);
                    AttachmentData cdata = aDataMap.get(cid);
                    if (cdata != null) {
                        antb.setText(cdata.getName());
                        adta.setText(cdata.getDescription());
                        if (cdata.getVisibility() == 1) {
                            op.setValue(true);
                            perm.setValue("Public");
                        } else {
                            om.setValue(true);
                            perm.setValue("Member");
                        }
                    }
                }
            }
        });

        final CheckBox cb = new CheckBox(
                " Create New Version of Existing Document");
        cb.setStyleName("generalSettings");
        cb.setName("newversion");
        // Hook up a listener to find out when it's clicked.
        cb.addClickHandler(new ClickHandler() {
            public void onClick(ClickEvent event) {
                boolean checked = ((CheckBox) event.getSource()).getValue();
                if (checked) {
                    lb.setEnabled(true);
                } else {
                    lb.setEnabled(false);
                }
            }
        });
        cb.setValue(false);
        lb.setEnabled(false);

        HorizontalPanel nvp = new HorizontalPanel();
        nvp.setSpacing(5);
        nvp.add(cb);
        nvp.add(lb);

        grid.setWidget(3, 1, nvp);
        FormPanel form = new FormPanel() {
            public void add(Widget w) {
                if (w == uploadSubmitBtn) {
                    grid.setWidget(grid.getRowCount(), 1, w);
                } else {
                    grid.setWidget(1, 1, w);
                }
            }

            {
                super.add(grid);
            }
        };

        SingleUploader uploader = new SingleUploader(
                FileInputType.BROWSER_INPUT, new ModalUploadStatus(),
                uploadSubmitBtn, form);
        uploader.setServletPath(GWT_UPLOAD_ACTION_URL);
        uploadPanel.setSpacing(5);
        uploadPanel.add(uploader);

        cpanel.add(uploadPanel);

        uploader.addOnChangeUploadHandler(new OnChangeUploaderHandler() {
            public void onChange(IUploader uploader) {
                String cfpath = uploader.getFileName();
                if (cfpath != null) {
                    int indx2 = cfpath.lastIndexOf('\\');
                    if (indx2 > 0) {
                        String cfname = cfpath.substring(indx2 + 1);
                        antb.setText(cfname);
                    } else {
                        antb.setText(cfpath);
                    }
                }

            }
        });

        uploader.addOnFinishUploadHandler(new OnFinishUploaderHandler() {
            public void onFinish(IUploader uploader) {
                if (uploader.getStatus() == Status.SUCCESS) {
                    uploadPanel.insert(new HTML("<b>"
                            + uploader.getServerResponse() + "</b>"), 0);
                    uploader.reset();
                    hPageId.setValue(apageid);
                }
            }
        });

    }

    private void initUploadRevisedDocPanel(RootPanel cpanel, String aid) {

        apageid = getPageId();

        final FlexTable grid = new FlexTable();
        grid.setText(1, 0, "Select File:");
        grid.getCellFormatter().setStyleName(1, 0, "gridTableColummHeader_3");
        grid.setText(2, 0, "");
        hPageId = new Hidden("pageid", apageid);
        grid.setWidget(2, 1, hPageId);

        final Hidden perm = new Hidden("atype", "Member");
        grid.setWidget(2, 2, perm);

        final Hidden existingAid = new Hidden("existingaid", aid);
        grid.setWidget(2, 3, existingAid);

        grid.setText(3, 0, "AccessName:");
        grid.getCellFormatter().setStyleName(4, 0, "gridTableColummHeader_3");

        final TextBox antb = new TextBox();
        antb.setName("aname");
        grid.setWidget(3, 1, antb);
        antb.setStyleName("inputGeneral");

        grid.setText(4, 0, "Description:");
        grid.getCellFormatter().setStyleName(4, 0, "gridTableColummHeader_3");

        final TextArea adta = new TextArea();
        adta.setName("desc");
        adta.setStyleName("textAreaGeneral");
        grid.setWidget(4, 1, adta);

        final RadioButton op = new RadioButton("visibility", "Public");
        final RadioButton om = new RadioButton("visibility", "Member");
        op.setStyleName("generalSettings");
        om.setStyleName("generalSettings");

        op.addClickHandler(new ClickHandler() {
            public void onClick(ClickEvent event) {
                perm.setValue("Public");
            }
        });
        om.addClickHandler(new ClickHandler() {
            public void onClick(ClickEvent event) {
                perm.setValue("Member");
            }
        });

        HorizontalPanel ohp = new HorizontalPanel();
        ohp.setSpacing(5);
        ohp.add(op);
        ohp.add(om);
        grid.setText(5, 0, "Permission:");
        grid.getCellFormatter().setStyleName(5, 0, "gridTableColummHeader_3");
        grid.setWidget(5, 1, ohp);

        leafService.getAttachment(apageid, aid,
                new AsyncCallback<AttachmentData>() {
                    public void onFailure(Throwable caught) {
                        Window.alert("Exception:" + caught);
                    }

                    public void onSuccess(AttachmentData aData) {
                        antb.setText(aData.getName());
                        adta.setText(aData.getDescription());
                        if (aData.getVisibility() == 1) {
                            op.setValue(true);
                            perm.setValue("Public");
                        } else {
                            om.setValue(true);
                            perm.setValue("Member");
                        }
                    }
                });

        FormPanel form = new FormPanel() {
            public void add(Widget w) {
                if (w == uploadSubmitBtn) {
                    grid.setWidget(grid.getRowCount(), 1, w);
                } else {
                    grid.setWidget(1, 1, w);
                }
            }

            {
                super.add(grid);
            }
        };

        SingleUploader uploader = new SingleUploader(
                FileInputType.BROWSER_INPUT, new ModalUploadStatus(),
                uploadSubmitBtn, form);
        uploader.setServletPath(GWT_UPLOAD_ACTION_URL);
        uploadPanel.setSpacing(5);
        uploadPanel.add(uploader);

        cpanel.add(uploadPanel);

        uploader.addOnChangeUploadHandler(new OnChangeUploaderHandler() {
            public void onChange(IUploader uploader) {
                String cfpath = uploader.getFileName();
                if (cfpath != null) {
                    int indx2 = cfpath.lastIndexOf('\\');
                    if (indx2 > 0) {
                        String cfname = cfpath.substring(indx2 + 1);
                        antb.setText(cfname);
                    } else {
                        antb.setText(cfpath);
                    }
                }

            }
        });

        uploader.addOnFinishUploadHandler(new OnFinishUploaderHandler() {
            public void onFinish(IUploader uploader) {
                if (uploader.getStatus() == Status.SUCCESS) {
                    uploadPanel.insert(new HTML("<b>"
                            + uploader.getServerResponse() + "</b>"), 0);
                    hPageId.setValue(apageid);
                }
            }
        });

    }

    private void initMultipleUpLoaderPanel(RootPanel cpanel) {
        // A panel where the thumbnails of uploaded images will be shown
        I18nConstants c = GWT.create(I18nConstants.class);
        RootPanel.get("gwt_thumbnails").add(panelImages);

        // Create a new multiuploader and attach it to the document
        mUploader = new MultiUploader(FileInputType.LABEL);
        cpanel.add(mUploader);

        // You could change the internationalization creating your own Constants
        // file
        mUploader.setI18Constants(c);
        // Enable/disable the component
        // mUploader.setEnabled(true);

        final FlexTable grid = new FlexTable();
        grid.setText(1, 0, "AccessName:");
        grid.setWidget(1, 1, new TextBox() {
            {
                setName("aname");
            }
        });
        grid.setText(2, 0, "Description:");
        grid.setWidget(2, 1, new TextArea() {
            {
                setName("desc");
            }
        });

        String bpageid = getPageId();
        // String bpageid = "npageid";
        Hidden h = new Hidden("pageid", bpageid);
        grid.setWidget(3, 1, h);

        Anchor anchor = new Anchor("Done With Upload", getAttachmentLink());
        grid.setWidget(3, 2, anchor);

        mUploader.setServletPath(GWT_UPLOAD_ACTION_URL);

        form2.add(grid);

        mUploader.add(form2);

        // Add a finish handler which will load the image once the upload
        // finishes
        mUploader.addOnFinishUploadHandler(onFinishUploaderHandler);
    }

    // Load the image in the document and in the case of success attach it to
    // the viewer
    private IUploader.OnFinishUploaderHandler onFinishUploaderHandler = new IUploader.OnFinishUploaderHandler() {
        public void onFinish(IUploader uploader) {
            if (uploader.getStatus() == Status.SUCCESS) {
                new PreloadedImage(uploader.fileUrl(), showImage);

                mUploader.add(form2);

            }
        }
    };

    // Attach an image to the pictures viewer
    private OnLoadPreloadedImageHandler showImage = new OnLoadPreloadedImageHandler() {
        public void onLoad(PreloadedImage image) {
            image.setWidth("75px");
            panelImages.add(image);
        }
    };

    private void callForNtfx(String pageId) {

        String ntfxevnt = pageId + "/" + getUserAgent();
        AsyncCallback<String> cbk = new AsyncCallback<String>() {
            public void onFailure(Throwable caught) {
                // Window.alert("Server Communication is Lost. Exception:" +
                // caught);

            }

            public void onSuccess(String result) {
                showNtfxResult(result);
            }
        };

        leafService.isPageUpdated(ntfxevnt, cbk);
    }

    private void showNtfxResult(String result) {
        if ("reconnect".equals(result)) {
            String pageId = getPageId();
            callForNtfx(pageId);
            return;
        } else if ("cancel".equals(result)) {
            statusButton.setVisible(false);
            return;
        } else {
            int i = Random.nextInt(10) + 1;
            String msg = "<p><font size=\"3\" color=\"red\">&nbsp&nbsp Project will be Reloaded in "
                    + i + " sec.</font></p>";
            status.setHTML(msg);
            // statusButton.setFocus(true);

            Timer t = new Timer() {
                int i = Random.nextInt(3) + 1;

                public void run() {
                    if (i == 0) {
                        cancel();
                        Window.Location.reload();
                    }

                    String msg = "<p><font size=\"3\" color=\"red\">&nbsp&nbsp Project will be Reloaded in "
                            + i + " sec.</font></p>";
                    status.setHTML(msg);
                    // statusButton.setFocus(true);

                    i--;
                }
            };

            t.scheduleRepeating(1000);
        }

    }

    public static native String getUserAgent() /*-{
         var ua = navigator.userAgent.toLowerCase();


         if (ua.indexOf("opera") != -1) {
                 return "opera";
         }
         if (ua.indexOf("webkit") != -1) {
                 return "safari";
         }
         if (ua.indexOf("msie") != -1) {
            return "ie6";
         }
         if (ua.indexOf("gecko") != -1) {
                 var result = /rv:([0-9]+)\.([0-9]+)/.exec(ua);
                 if (result && result.length == 3) {
                         var version = (parseInt(result[1]) * 10) +
       parseInt(result[2]);
                         if (version >= 18)
                                 return "gecko1_8";
                 }
                 return "gecko";
         }
         return "unknown";
    }-*/;

    private void init() {
        // init Bes Panel
        beVPanel = new VerticalPanel();
        beVPanel.setWidth("100%");
        beVPanel.setSpacing(5);

        loadingDialogBox = new DialogBox();
        loadingDialogBox.setText("Loading Data");
        loadingDialogBox.setSize("200px", "200px");
        loadingDialogBox.add(loadImage);
        loadingDialogBox.setGlassEnabled(true);
        loadingDialogBox.setAnimationEnabled(true);

        imgroot = Window.Location.getHref();
        int tindx = imgroot.indexOf("/t/");

        if (tindx == -1) {
            tindx = imgroot.indexOf("/GWTNoteEditor.jsp");
        }

        imgroot = imgroot.substring(0, tindx)
                + "/bewebapp/gwt/standard/images/";


        loadImage = new Image(imgroot + "progress.gif");
        addImg = new Image(imgroot + "new.gif");
        ;
        saveImg = new Image(imgroot + "save.gif");
        ;
        deleteImg = new Image(imgroot + "delete.gif");
        ;
        refreshImg = new Image(imgroot + "refresh.gif");
        ;
        openImg = new Image(imgroot + "open.gif");
    }

    private void loadLeflets(String prjId) {

        tabPanel.setWidth("100%");
        tabPanel.setAnimationEnabled(true);

        pPanel.setSpacing(5);
        mPanel.setSpacing(5);
        prPanel.setSpacing(5);
        crPanel.setSpacing(5);

        tabPanel.add(pPanel, "Public Notes");
        pPanel.add(loadImage);
        tabPanel.add(mPanel, "Member Notes");
        tabPanel.add(prPanel, "Private Notes");
        tabPanel.add(crPanel, "Create Note");

        tabPanel.selectTab(0);

        tabPanel.addSelectionHandler(new SelectionHandler<Integer>() {
            public void onSelection(SelectionEvent<Integer> event) {
                if (event.getSelectedItem() == 3) {

                    createPanel.setOpen(true);
                }
            }
        });

        leafService.getNotes(prjId, new AsyncCallback<LeafData[]>() {
            public void onFailure(Throwable caught) {
                pPanel.remove(loadImage);
                Window.alert("Exception:" + caught);
            }

            public void onSuccess(LeafData[] lefalets) {
                pPanel.remove(loadImage);
                updateDisplay(lefalets);
            }
        });
    }

    private void updateDisplay(LeafData[] leaflets) {
        boolean loggedIn = false;
        if (leaflets[0].getUserId() != null && leaflets[0].isMember()) {
            createPanel.setHeader(new Button("Create New Note"));
            createPanel.setAnimationEnabled(true);
            LeafletHandler lfh = new LeafletHandler(createPanel, leaflets[0]);
            lfh.initEditPanel();
            lfh.updateCreatePanel();
            lfh.setPanels(pPanel, mPanel, prPanel);
            crPanel.add(createPanel);
        } else {
            HTML htmlw = new HTML(CREATE_NO);
            crPanel.add(htmlw);
        }

        if (leaflets[0].getUserId() != null) {
            loggedIn = true;
        }
        for (int i = 1; i < leaflets.length; i++) {
            LeafData leaflet = leaflets[i];
            LeafletHandler lfh1 = new LeafletHandler(null, leaflet);
            lfh1.setPanels(pPanel, mPanel, prPanel);
            lfh1.initMainPanel();
            if (i == 1) {
                lfh1.setOpen(true);
            }
            lfh1.initEditPanel();
            lfh1.initViewPanel();
            lfh1.updateViewPanel();
        }

        if (pPanel.getWidgetCount() == 0) {
            HTML html = new HTML(PUBLIC_NOTDATA);
            pPanel.add(html);
        }
        if (mPanel.getWidgetCount() == 0) {
            HTML html = new HTML();
            if (loggedIn) {
                html.setText(MEMBER_NOTDATA);
            } else {
                html.setText(MEMBER_NOTLOGGED);
            }
            mPanel.add(html);
        }
        if (prPanel.getWidgetCount() == 0) {
            HTML html = new HTML();
            if (loggedIn) {
                html.setText(PRIVATE_NOTDATA);
            } else {
                html.setText(PRIVATE_NOTLOGGED);
            }
            prPanel.add(html);
        }
    }

    private String getPageId() {
        String purl = Window.Location.getHref();
        purl = URL.decode(purl);
        int inndx = purl.lastIndexOf('/');
        purl = purl.substring(0, inndx);
        int indx2 = purl.lastIndexOf('/');
        String pageId = purl.substring(indx2 + 1);
        return pageId;

    }

    private String getAttachmentLink() {
        String purl = Window.Location.getHref();
        purl = URL.decode(purl);
        int inndx = purl.lastIndexOf('/');
        purl = purl.substring(0, inndx) + "/attachment.htm";
        return purl;
    }

    private String getFullProjectId() {
        String purl = Window.Location.getHref();
        purl = URL.decode(purl);
        int eindx = purl.lastIndexOf('/');
        int tindx = purl.indexOf("/t/");
        int bindx = tindx + 3;
        String fprjid = purl.substring(bindx, eindx);
        return fprjid;

    }

    private void loadBes(String prjId) {
        besService.getBusinessEntityList(prjId, new AsyncCallback<String>() {
            public void onFailure(Throwable caught) {
                showError(caught);
            }

            public void onSuccess(String result) {
                uploadBeList(result);
            }
        });
    }

    public static void showLodingDialogue() {
        if (loadingDialogBox == null) {
            loadingDialogBox = new DialogBox();
            loadingDialogBox.setText("Loading Data");
            loadingDialogBox.setSize("200px", "200px");
            loadingDialogBox.add(loadImage);
            loadingDialogBox.setGlassEnabled(true);
            loadingDialogBox.setAnimationEnabled(true);
        }
        loadingDialogBox.center();
        loadingDialogBox.show();
    }

    public static void hideLodingDialogue() {
        loadingDialogBox.hide();
    }

    public static void showError(Throwable caught) {
        if (errDialogBox == null) {
            errDialogBox = new DialogBox();
            errDialogBox.setText("Exception");
            errDialogBox.setGlassEnabled(true);
            errDialogBox.setAnimationEnabled(true);

            bErrClose = new Button("Close");
            bErrClose.addClickHandler(new ClickHandler() {
                public void onClick(ClickEvent event) {
                    errDialogBox.clear();
                    errDialogBox.hide();
                }
            });

            errorVp = new VerticalPanel();
            errorVp.setSize("200px", "200px");
            errorVp.setHorizontalAlignment(VerticalPanel.ALIGN_RIGHT);
            errorVp.add(bErrClose);
            errorVp.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
            serverError = new HTML();
            serverError.setSize("200px", "200px");
            serverError.addStyleName("serverResponseLabelError");
            errorVp.add(serverError);
            errDialogBox.add(errorVp);
            errDialogBox.center();
        }
        String err = caught.toString();
        if (caught == null) {
            err = "Server has thrown an exception";
            serverError.setText(err);
        } else {
            serverError.setHTML("<pre>" + printStackTrace(caught) + "</pre>");
        }
        bErrClose.setFocus(true);
    }

    private static String printStackTrace(Throwable caught) {

        Object[] stackTrace = caught.getStackTrace();
        String output = caught.toString() + "<br/>";
        for (Object line : stackTrace) {
            output += line + "<br/>";
        }
        return output;
    }

    private void uploadBeList(String result) {
        BeWebAppHandler beh = new BeWebAppHandler(beVPanel, null);
        beh.initCreatePanel();

        Document doc = XMLParser.parse(result);
        Element root = doc.getDocumentElement();
        NodeList ndList = root.getChildNodes();
        for (int i = 0; i < ndList.getLength(); i++) {
            Node nd = ndList.item(i);
            if ("entity".equals(nd.getNodeName())) {
                NamedNodeMap attMap = nd.getAttributes();
                String name = attMap.getNamedItem("name").getNodeValue();
                String desc = attMap.getNamedItem("desc").getNodeValue();

                BusinessEntity be = new BusinessEntity();
                be.setName(name);
                be.setDesc(desc);
                BeWebAppHandler tbeh = new BeWebAppHandler(beVPanel, be);
                tbeh.initEditPanel();
            }
        }
    }

    private void updateNoteEditor(LeafData note) {
        NoteEditor nd = new NoteEditor(note, mPanel);
        nd.initEditPanel();
        if (note.getId().equals("-1")) {
            nd.initCreatePanel();
        }
    }

    private LeafData[] getDummyData(int cnt) {
        Vector comments = new Vector();
        LeafData tmp = new LeafData();
        tmp.setIsMember(true);
        tmp.setUserId("hello");
        tmp.setId("dummy");
        tmp.setPageId("hello");
        comments.add(tmp);
        int headerSize = 90;

        for (int i = 0; i < cnt; i++) {
            LeafData tmp1 = new LeafData();
            tmp1.setIsMember(true);
            tmp1.setUserId("hello");
            tmp1.setId("id" + i);
            tmp1.setPageId("hello");
            tmp1.setVisibility(2);
            tmp1.setData("This is test data for testing");

            String headerText = "Subject No " + i;
            int rspace = headerSize - headerText.length();
            if (rspace > 0) {
                for (int j = 0; j < rspace; j++) {
                    headerText = headerText + " ";
                }
            }

            headerText = headerText + "    -Last edited by "
                    + "Dummy 2 days ago";
            tmp1.setHeaderText(headerText);
            comments.add(tmp1);

        }

        LeafData[] notes = new LeafData[comments.size()];
        comments.copyInto(notes);
        return notes;
    }

}
