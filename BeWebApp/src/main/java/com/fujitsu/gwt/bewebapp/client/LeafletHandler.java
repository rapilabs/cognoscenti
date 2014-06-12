package com.fujitsu.gwt.bewebapp.client;


import com.fujitsu.gwt.bewebapp.client.content.text.MultiTextBox;
import com.fujitsu.gwt.bewebapp.client.content.text.RichTextToolbar;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.http.client.URL;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.MultiWordSuggestOracle;
import com.google.gwt.user.client.ui.RadioButton;
import com.google.gwt.user.client.ui.RichTextArea;
import com.google.gwt.user.client.ui.SuggestBox;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;

public class LeafletHandler implements ClickHandler {

    // Server Data
    LeafData lfdata;

    // Container
    private DisclosurePanel mainPanel;


    // View Panel
    private Button editBtn;
    private Button emailBtn;
    private Button removeBtn;
    private Button zoomBtn;
    private HTML viewContent;
    private HorizontalPanel viewBarPanel;
    private VerticalPanel dialogVPanel;

    // Email Panel
    private Button emailCancelBtn;
    private Button emailSendButton;
    private SuggestBox emailSuggestBox;
    private MultiTextBox emailMTextBbox;

    // Edit Panel
    private Label subjLabel;
    private TextBox subjText;

    private Button editCancelBtn;
    private Button editSubmitBtn;
    private Button editSaveBtn;

    private RadioButton optionPublic;
    private RadioButton optionMember;
    private RadioButton optionPrivate;
    private HorizontalPanel editBarPanel;
    private HorizontalPanel editSubjPanel;


    private RichTextArea eidtTextArea;
    private RichTextToolbar editToolBar;
    VerticalPanel dialogEPanel = new VerticalPanel();

    private boolean isNew = false;

    private VerticalPanel pPanel;
    private VerticalPanel mPanel;
    private VerticalPanel prPanel;

    private int currentAccessLevel;
    private LeafletHandler newlh;

    public LeafletHandler(DisclosurePanel mainPanel, LeafData lfdata) {
        this.lfdata = lfdata;
        this.mainPanel = mainPanel;
        this.currentAccessLevel = lfdata.getVisibility();
    }

    public void initViewPanel(){
        editBtn = new Button("Edit");
        editBtn.addClickHandler(this);
        emailBtn = new Button("Send");
        emailBtn.addClickHandler(this);
        removeBtn = new Button("Delete");
        removeBtn.addClickHandler(this);
        zoomBtn = new Button("Zoom");
        zoomBtn.setTitle("Open in new Window");
        zoomBtn.addClickHandler(this);

        viewBarPanel = new HorizontalPanel();
        if(!lfdata.isMember()){
            viewBarPanel.setVisible(false);
        }
        dialogVPanel = new VerticalPanel();
        dialogVPanel.setSpacing(5);

        viewContent = new HTML();
        viewBarPanel.add(editBtn);
        viewBarPanel.add(emailBtn);
        viewBarPanel.add(removeBtn);
        viewBarPanel.add(zoomBtn);

        dialogVPanel.addStyleName("dialogVPanel");
        dialogVPanel.setHorizontalAlignment(VerticalPanel.ALIGN_RIGHT);
        dialogVPanel.add(viewBarPanel);
        dialogVPanel.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
        dialogVPanel.add(viewContent);

    }
    public void initEditPanel(){
        subjLabel = new Label("Subject");
        subjText = new TextBox();
        subjText.setWidth("100%");

        editSubjPanel = new HorizontalPanel();
        editSubjPanel.setWidth("100%");
        editSubjPanel.add(subjLabel);
        editSubjPanel.add(new HTML("&nbsp"));
        editSubjPanel.add(subjText);
        editSubjPanel.setCellWidth(subjText, "60%");
        editSubjPanel.add(new HTML("&nbsp&nbsp"));

        editCancelBtn = new Button("Close");
        editCancelBtn.addClickHandler(this);
        editSubmitBtn = new Button("Submit");
        editSubmitBtn.addClickHandler(this);
        editSaveBtn = new Button("Save");
        editSaveBtn.addClickHandler(this);
        editBarPanel = new HorizontalPanel();
        editBarPanel.add(editSaveBtn);
        editBarPanel.add(editCancelBtn);
        editBarPanel.add(editSubmitBtn);

        optionPublic = new RadioButton("LfAccess", "Public");
        optionMember = new RadioButton("LfAccess", "Member");
        //optionPrivate = new RadioButton("LfAccess", "Private");

        editSubjPanel.add(optionPublic);
        editSubjPanel.add(optionMember);
        editSubjPanel.add(optionPrivate);


        if(currentAccessLevel == 1){
            optionPublic.setValue(true);
        }else if(currentAccessLevel == 2){
            optionMember.setValue(true);
        }else {
            optionPrivate.setValue(true);
        }

        eidtTextArea = new RichTextArea();
        editToolBar = new RichTextToolbar(eidtTextArea);
        eidtTextArea.setWidth("100%");
        eidtTextArea.setHeight("14em");

        dialogEPanel = new VerticalPanel();
        dialogEPanel.setSpacing(5);
        dialogEPanel.addStyleName("dialogVPanel");
        dialogEPanel.setHorizontalAlignment(VerticalPanel.ALIGN_RIGHT);
        dialogEPanel.add(editBarPanel);
        dialogEPanel.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
        dialogEPanel.add(editSubjPanel);
        dialogEPanel.add(editSubjPanel);
        dialogEPanel.add(editToolBar);
        dialogEPanel.add(eidtTextArea);
    }

    public void updateViewPanel(){
        viewContent.setHTML(lfdata.getData());
        mainPanel.getHeaderTextAccessor().setText(lfdata.getHeaderText());
        mainPanel.setContent(dialogVPanel);
        mainPanel.setWidth("100%");
    }

    public void updateEditPanel(){
        subjText.setText(lfdata.getSubject());
        if(currentAccessLevel == 1){
            optionPublic.setValue(true);
        }else if(currentAccessLevel == 2){
            optionMember.setValue(true);
        }else {
            optionPrivate.setValue(true);
        }
        eidtTextArea.setHTML(lfdata.getData());
        mainPanel.setContent(dialogEPanel);
        mainPanel.setWidth("100%");
    }

    public void updateCreatePanel(){
        isNew = true;
        optionPublic.setValue(true);
        mainPanel.setContent(dialogEPanel);
        mainPanel.setWidth("100%");
    }

    public void setNote(LeafData tld){
        lfdata = tld;
    }

    public void initMainPanel(){
        this.mainPanel = new DisclosurePanel("No Subject");
        mainPanel.setAnimationEnabled(true);
        mainPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() {
            public void onOpen(OpenEvent<DisclosurePanel> event) {
                if(!lfdata.isDataLoaded()){
                    getLeafData();
                }
            }

        });

        if(lfdata.getVisibility() == 1){
            pPanel.add(mainPanel);
         }else if(lfdata.getVisibility() == 2){
            mPanel.add(mainPanel);
         }else {
            prPanel.add(mainPanel);
         }

    }

    public void setOpen(boolean open){
        if(open){
            mainPanel.setOpen(true);
            mainPanel.setVisible(true);
            
        }else{
            mainPanel.setOpen(false);
        }
    }
    public void onClick(ClickEvent event) {
        Widget sender = (Widget) event.getSource();
        if (sender == editBtn) {
            updateEditPanel();
        } else if (sender == removeBtn) {
            boolean isOk =
                Window.confirm("Do you want to delete Note: " + lfdata.getId() + "?");
            if(!isOk) {
                return;
            }
            removeLeafData(lfdata);
        } else if (sender == emailBtn) {
            setEmailPanel();
        } else if(sender == zoomBtn){
            String zoomLink = getZoomLink();
            Window.open(zoomLink,"_blank", "" );
        }
        else if (sender == editCancelBtn) {
            eidtTextArea.setHTML("");
            subjText.setText("");
            if(!isNew){
                updateNote();
            }else{
                mainPanel.setOpen(false);
            }
            this.newlh = null;
        } else if (sender == editSubmitBtn) {
            LeafData tld = getEditorLd();
            this.submitLeafData(tld);
            eidtTextArea.setHTML("");
            mainPanel.setOpen(false);
        } else if (sender == editSaveBtn) {
            if(editToolBar.isHTMLMode()){
                Window.alert("Please Exit from HTML source view before saving data.");
                return;
            }
            LeafData tld = getEditorLd();
            if(isNew){
                if(newlh != null)
                    newlh.submitLeafData(tld);
                else
                    this.createLeafData(tld);
            }else{
                this.saveLeafData(tld);
            }
        }else if (sender == emailCancelBtn) {
            updateNote();;
        } else if (sender == emailSendButton) {
            //Server call send email data
            updateNote();
        }else {
            System.out.println("Can not find the button");
        }

    }


    private void setEmailPanel() {

        String emailLink = getEmailLink();
        Window.open(emailLink,"_blank", "" );
    /*
        emailCancelBtn = new Button("Cancel");
        emailCancelBtn.addClickHandler(this);
        emailSendButton = new Button("Send");
        emailSendButton.addClickHandler(this);

        emailMTextBbox = new MultiTextBox();
        emailSuggestBox = new SuggestBox(getEmailOracle(), emailMTextBbox);

        VerticalPanel dialogMPanel = new VerticalPanel();
        dialogMPanel.setSpacing(5);
        dialogMPanel.addStyleName("dialogVPanel");
        HorizontalPanel esuggest = new HorizontalPanel();
        esuggest.add(new Label("Email To:"));
        esuggest.add(emailSuggestBox);
        dialogMPanel.add(esuggest);
        dialogMPanel.setHorizontalAlignment(VerticalPanel.ALIGN_RIGHT);

        HorizontalPanel ehp = new HorizontalPanel();
        ehp.add(emailSendButton);
        ehp.add(emailCancelBtn);
        dialogMPanel.add(ehp);
        mainPanel.setContent(dialogMPanel);
        emailMTextBbox.setFocus(true);
        */

    }

    private MultiWordSuggestOracle getEmailOracle() {
        MultiWordSuggestOracle oracle = new MultiWordSuggestOracle();

        oracle.add("kraja@us.fujitsu.com");
        oracle.add("squader@us.fujitsu.com");
        oracle.add("vabbi@us.fujitsu.com");
        oracle.add("ivar@us.fujitsu.com");
        oracle.add("syang@us.fujitsu.com");
        oracle.add("kswenson@us.fujitsu.com");
        oracle.add("cychen@us.fujitsu.com");
        oracle.add("spradhan@us.fujitsu.com");

        return oracle;

    }

    public void setPanels(VerticalPanel pPanel, VerticalPanel mPanel, VerticalPanel prPanel){
        this.pPanel = pPanel;
        this.mPanel = mPanel;
        this.prPanel = prPanel;
    }


    private void removeWizard(Widget w){
        if(currentAccessLevel == 1){
            pPanel.remove(w);
        }else if(currentAccessLevel == 2){
            mPanel.remove(w);
        }else {
            prPanel.remove(w);
        }
    }

    private void saveLeafData(LeafData tld){
        BeWebApp.leafService.saveNote(tld.getPageId(), tld , new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(LeafData rld) {
                  lfdata = rld;
            }
          });
    }

    public void submitLeafData(LeafData tld){

        BeWebApp.leafService.saveNote(tld.getPageId(), tld , new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(LeafData rld) {
                  lfdata = rld;
                  updateNote();
            }
          });
    }


   private void createLeafData(LeafData tld){
       BeWebApp.leafService.createNote(tld.getPageId(), tld, new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(LeafData rld) {
                  createNote(rld);
            }
          });
    }

    private void removeLeafData(LeafData tld){
        BeWebApp.leafService.removeNote(tld.getPageId(), tld.getId(),  new AsyncCallback<String>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(String result) {
                  if(result.equalsIgnoreCase("true")){
                      removeWizard(mainPanel);
                  }
            }
          });
    }

    private void getLeafData(){
        this.mainPanel.setContent(BeWebApp.loadImage);
        BeWebApp.leafService.getNote(lfdata.getId(),lfdata.getPageId(),  new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
                mainPanel.setContent(new HTML("Failed to Load Data:" ));
              }
              public void onSuccess(LeafData rld) {
                  lfdata = rld;
                  updateViewPanel();
            }
          });
    }

    private LeafData getEditorLd(){
        LeafData tmpLeaf = new LeafData();
        tmpLeaf.setSubject(subjText.getText());
        tmpLeaf.setData(eidtTextArea.getHTML());
        if(optionPublic.getValue()){
            tmpLeaf.setVisibility(1);
        }else if(this.optionMember.getValue()){
            tmpLeaf.setVisibility(2);
        }else if(this.optionPrivate.getValue()){
            tmpLeaf.setVisibility(4);
        }

        tmpLeaf.setId(lfdata.getId());
        tmpLeaf.setPageId(lfdata.getPageId());

        return tmpLeaf;

    }

    private void updateNote(){
        if(lfdata.getVisibility() == 1){
             if(currentAccessLevel != 1){
                 currentAccessLevel = 1;
                 removeWizard(mainPanel);
                 pPanel.insert(mainPanel, 0);
             }
         }else if(lfdata.getVisibility() == 2){
             if(currentAccessLevel != 2){
                 currentAccessLevel = 2;
                 removeWizard(mainPanel);
                 mPanel.insert(mainPanel, 0);
             }
            }else {
                 if(currentAccessLevel < 3 ){
                     currentAccessLevel = 4;
                     removeWizard(mainPanel);
                     prPanel.insert(mainPanel, 0);
                 }
            }
        updateViewPanel();
    }

    private void createNote(LeafData tld){
      DisclosurePanel leafletPane = new DisclosurePanel("No Subject");
      leafletPane.setAnimationEnabled(true);
      LeafletHandler lfh1 = new LeafletHandler(leafletPane, tld);
      lfh1.setPanels(pPanel, mPanel, prPanel);
      lfh1.initEditPanel();
      lfh1.initViewPanel();
      lfh1.updateViewPanel();
      
      if(tld.getVisibility() == 1){
           pPanel.insert(leafletPane,0);
      }else if(tld.getVisibility() == 2){
          mPanel.insert(leafletPane,0);
       }else {
            prPanel.insert(leafletPane,0);
       }
      newlh = lfh1;
    }

    private boolean isMember(){
        if(lfdata != null && lfdata.isMember()){
            return true;
        }else{
            return false;
        }
    }

    private String getEmailLink(){
        String purl = Window.Location.getHref();
        purl = URL.decode(purl);
        int inndx  = purl.lastIndexOf('/');
        purl = purl.substring(0, inndx);
        int indx2 = purl.lastIndexOf('/');
        String pageId = purl.substring(indx2+1);


        int cIndx = purl.indexOf("/t/");
        String baseUrl = purl.substring(0,cIndx) + "/";
        String emailUrl = baseUrl
            + "t/sendNoteByEmail.htm?p="
            + pageId + "&oid=" + lfdata.getId();
        return emailUrl;

    }
    
    private String getZoomLink(){
        String purl = Window.Location.getHref();
        purl = URL.decode(purl);
        int inndx  = purl.lastIndexOf('/');
        purl = purl.substring(0, inndx);
        String zoomUrl = purl + "/" + "leaflet" + lfdata.getId() + ".htm";
        return zoomUrl;

    }


}
