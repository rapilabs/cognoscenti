package com.fujitsu.gwt.bewebapp.client;

import java.util.Date;

import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Label;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.RadioButton;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.datepicker.client.DateBox;
import java.util.Iterator;
import java.util.Vector;

public class NoteEditor implements ClickHandler{

    LeafData lfdata = null;

    private Label subjLabel;
    private Label bodyLabel;
    private Label visibleLabel;
    private Label editedByLabel;
    private Label effectiveDateLabel;
    private Label pinPositionLabel;
    private Label choiceLable;

    private TextBox subjText;
    private TextBox pinPos;
    private TextBox choices;
    private DateBox effectiveDate;

    private Button editCancelBtn;
    private Button editSaveAsDraftBtn;
    private Button editSaveBtn;

    private CheckBox optionPublic;
    private CheckBox optionMember;
    private CheckBox optionUpstream;
    private RadioButton optionEditedByYou;
    private RadioButton optionEditedByMember;

    private HorizontalPanel editBarPanel;
    private HorizontalPanel editSubjPanel;
    private HorizontalPanel editVisibility;
    private HorizontalPanel editBody;
    private HorizontalPanel editByPanel;
    private HorizontalPanel rolePanel;
    private HorizontalPanel effectiveDatePanel;
    private HorizontalPanel pinPositionPanel;
    private HorizontalPanel choicePanel;

    private TinyMCE tinyMCE;
    VerticalPanel dialogEPanel;

    private boolean isNew = false;

    public NoteEditor(LeafData lfdata, VerticalPanel mainPanel) {
        this.dialogEPanel = mainPanel;
        this.lfdata = lfdata;
    }

    public void initEditPanel(){
        subjLabel = buildLabel("Subject:");
        subjText = new TextBox();
        subjText.setStyleName("inputGeneralBig");

        editSubjPanel = new HorizontalPanel();
        editSubjPanel.add(subjLabel);
        editSubjPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        editSubjPanel.add(subjText);
        editSubjPanel.add(new HTML("&nbsp;&nbsp;"));

        editCancelBtn = new Button("Close");
        editCancelBtn.addClickHandler(this);
        editCancelBtn.setStyleName("inputBtn");
        editSaveAsDraftBtn = new Button();
        if(lfdata.isDraft()){
            editSaveAsDraftBtn.setText("Save and Publish");
            editSaveAsDraftBtn.setVisible(true);
        }else{
            editSaveAsDraftBtn.setVisible(false);
        }
        editSaveAsDraftBtn.addClickHandler(this);
        editSaveAsDraftBtn.setStyleName("inputBtn");
        editSaveBtn = new Button("Save");
        editSaveBtn.setStyleName("inputBtn");
        editSaveBtn.addClickHandler(this);
        editBarPanel = new HorizontalPanel();
        editBarPanel.add(editSaveBtn);
        editBarPanel.add(new HTML("&nbsp"));
        editBarPanel.add(editCancelBtn);
        editBarPanel.add(new HTML("&nbsp"));
        editBarPanel.add(editSaveAsDraftBtn);

        visibleLabel = buildLabel("Visible To:");
        optionPublic = new CheckBox("Public");
        optionPublic.setValue(lfdata.getVisibility() == 1);
        optionMember = new CheckBox("Member");
        optionMember.setValue(true);
        optionMember.setEnabled(false);
        optionUpstream = new CheckBox("Upstream");
        optionUpstream.setValue(lfdata.isUpstream());


        editVisibility = new HorizontalPanel();
        editVisibility.add(visibleLabel);
        editVisibility.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        editVisibility.add(optionPublic);
        editVisibility.add(new HTML(" &nbsp; &nbsp; "));
        editVisibility.add(optionMember);
        editVisibility.add(new HTML(" &nbsp; &nbsp; "));
        editVisibility.add(optionUpstream);


        editedByLabel = buildLabel("Edited By:");
        optionEditedByYou = new RadioButton("LeditedBy", "Only You");
        optionEditedByMember =  new RadioButton("LeditedBy", "Any Project Member ");
        int editByValue = lfdata.getEditedBy();
        if(editByValue == 2){
            optionEditedByMember.setValue(true);
        }
        else if(editByValue == 1){
            optionEditedByYou.setValue(true);
        }
        else{
            throw new RuntimeException("Internal Logic Error: The editedby value HAS NOT BEEN SET!");
        }

        editByPanel = new HorizontalPanel();
        editByPanel.add(editedByLabel);
        editByPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        editByPanel.add(optionEditedByYou);
        editByPanel.add(new HTML(" &nbsp &nbsp "));
        editByPanel.add(optionEditedByMember);

        rolePanel = new HorizontalPanel();
        rolePanel.add(buildLabel("Role Access:"));
        rolePanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        for (String roleName : lfdata.allRoles) {
            CheckBox cb = new CheckBox(roleName);
            cb.setName(roleName);
            for (String checkedName : lfdata.checkedRoles) {
                if (checkedName.equals(roleName)) {
                    cb.setValue(true);
                }
            }
            rolePanel.add(cb);
            rolePanel.add(new HTML(" &nbsp &nbsp "));
        }

        effectiveDateLabel = buildLabel("Effective Date:");

        DateTimeFormat dateFormat = DateTimeFormat.getLongDateFormat();
        effectiveDate = new DateBox();
        effectiveDate.setValue(new Date(lfdata.getEffectiveDate()));
        effectiveDate.setFormat(new DateBox.DefaultFormat(dateFormat));
        effectiveDate.addValueChangeHandler(new ValueChangeHandler<Date>() {
            public void onValueChange(ValueChangeEvent<Date> event) {
                lfdata.setEffectiveDate(effectiveDate.getValue().getTime());
            }
        });

        effectiveDatePanel = new HorizontalPanel();
        effectiveDatePanel.add(effectiveDateLabel);
        effectiveDatePanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        effectiveDatePanel.add(effectiveDate);


        pinPositionLabel = buildLabel("Pin Position:");
        pinPos = new TextBox();
        pinPos.setText(lfdata.getPinPosition());
        pinPos.setStyleName("inputGeneralSmall");

        pinPositionPanel = new HorizontalPanel();
        pinPositionPanel.add(pinPositionLabel);
        pinPositionPanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        pinPositionPanel.add(pinPos);

        choiceLable = buildLabel("Choices:");
        choices = new TextBox();
        choices.setText(lfdata.getChoice());
        choices.setStyleName("inputGeneralUrl");

        choicePanel = new HorizontalPanel();
        choicePanel.add(choiceLable);
        choicePanel.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        choicePanel.add(choices);

        dialogEPanel.setSpacing(5);
        dialogEPanel.addStyleName("dialogVPanel");
        dialogEPanel.setTitle("Note Editor");
        dialogEPanel.setHorizontalAlignment(VerticalPanel.ALIGN_RIGHT);
        dialogEPanel.add(editBarPanel);
        dialogEPanel.add(new HTML("<br><br>"));
        dialogEPanel.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
        dialogEPanel.add(editSubjPanel);

        bodyLabel = buildLabel("Body:");

        subjText.setText(lfdata.getSubject());
        tinyMCE  = new TinyMCE(30,30,lfdata.getData());
        dialogEPanel.add(new HTML("<br>"));
        editBody = new HorizontalPanel();
        editBody.add(bodyLabel);
        editBody.add(new HTML("&nbsp;&nbsp;&nbsp;"));
        editBody.add(tinyMCE);

        dialogEPanel.add(editBody);
        dialogEPanel.add(new HTML("<br>"));
        dialogEPanel.add(editVisibility);
        dialogEPanel.add(rolePanel);
        dialogEPanel.add(new HTML("<br>"));
        dialogEPanel.add(editByPanel);
        dialogEPanel.add(new HTML("<br>"));
        dialogEPanel.add(effectiveDatePanel);
        dialogEPanel.add(new HTML("<br>"));
        dialogEPanel.add(pinPositionPanel);
        dialogEPanel.add(new HTML("<br>"));
        dialogEPanel.add(choicePanel);

    }

    private Label buildLabel(String labelText) {
        Label x = new Label(labelText);
        x.setStyleName("gridTableColummHeader_3");
        return x;
    }

    public void initCreatePanel(){
        isNew = true;
        editSaveAsDraftBtn.setText("Save as Draft");
        editSaveAsDraftBtn.setVisible(true);
    }


    public void onClick(ClickEvent event) {
        Widget sender = (Widget) event.getSource();
        if (sender == editCancelBtn) {
            closeBrowser();
        } else if (sender == editSaveAsDraftBtn) {
            LeafData tld = getEditorLd();
            if("Save as Draft".equals(editSaveAsDraftBtn.getText())){
                tld.setIsDraft(true);
            }else{
                tld.setIsDraft(false);
            }
            if(isNew){
                this.createLeafData(tld);
            }else{
                this.saveLeafData(tld);
            }
        } else if (sender == editSaveBtn) {
            LeafData tld = getEditorLd();
            if(isNew){
                this.createLeafData(tld);
            }else{
                this.saveLeafData(tld);
            }
        }

    }

    private void createLeafData(LeafData tld){
        BeWebApp.leafService.createNote(tld.getPageId(), tld, new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
            }
            public void onSuccess(LeafData rld) {
                lfdata = rld;
                isNew = false;
                if(lfdata.isDraft()){
                    editSaveAsDraftBtn.setText("Save and Publish");
                    editSaveAsDraftBtn.setVisible(true);
                }else{
                    editSaveAsDraftBtn.setVisible(false);
                }
                tinyMCE.setText(rld.getData());

            }
         });
    }


    private LeafData getEditorLd(){
        LeafData tmpLeaf = new LeafData();
        tmpLeaf.setSubject(subjText.getText());
        String txt = tinyMCE.getText();
        tmpLeaf.setData(txt);
        if(optionPublic.getValue()){
            tmpLeaf.setVisibility(1);
        }else {
            tmpLeaf.setVisibility(2);
        }
        tmpLeaf.setUpstream(optionUpstream.getValue());

        if(optionEditedByYou.getValue()){
            tmpLeaf.setEditedBy(1);
        }else if(this.optionEditedByMember.getValue()){
            tmpLeaf.setEditedBy(2);
        }
        tmpLeaf.setPinPosition(pinPos.getText());
        tmpLeaf.setChoice(choices.getText());


        tmpLeaf.setId(lfdata.getId());
        tmpLeaf.setPageId(lfdata.getPageId());

        tmpLeaf.setIsDraft(lfdata.isDraft());

        //Role Access
        //walk through the panel, get all the check boxes for role access
        //see which ones are checked, and put that in the data going back.
        Iterator<Widget> iter = rolePanel.iterator();
        Vector<String> allRoles = new Vector<String>();
        Vector<String> checkedRoles = new Vector<String>();
        while (iter.hasNext()) {
            Widget ww = iter.next();
            if (ww instanceof CheckBox) {
                CheckBox cb = (CheckBox) ww;
                String name = cb.getName();
                if (cb.getValue()) {
                    checkedRoles.add(name);
                }
            }
        }
        tmpLeaf.checkedRoles = new String[checkedRoles.size()];
        checkedRoles.copyInto(tmpLeaf.checkedRoles);


        return tmpLeaf;

    }

    public void submitLeafData(LeafData tld){
        BeWebApp.leafService.saveNote(tld.getPageId(), tld , new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(LeafData rld) {
                  lfdata = rld;
                  if(lfdata.isDraft()){
                      editSaveAsDraftBtn.setText("Save and Publish");
                      editSaveAsDraftBtn.setVisible(true);
                  }else{
                      editSaveAsDraftBtn.setVisible(false);
                  }
                  tinyMCE.setText(lfdata.getData());
            }
          });
    }
    private void saveLeafData(LeafData tld){
        BeWebApp.leafService.saveNote(tld.getPageId(), tld , new AsyncCallback<LeafData>() {
            public void onFailure(Throwable caught) {
                Window.alert("Exception:" + caught);
              }
              public void onSuccess(LeafData rld) {
                  lfdata = rld;
                  if(lfdata.isDraft()){
                      editSaveAsDraftBtn.setText("Save and Publish");
                      editSaveAsDraftBtn.setVisible(true);
                  }else{
                      editSaveAsDraftBtn.setVisible(false);
                  }
                  tinyMCE.setText(lfdata.getData());
            }
          });
    }

     public static native void closeBrowser()
        /*-{
            $wnd.close();
        }-*/;

     /**
         * encodeURIComponent() -
         * Wrapper for the native URL encoding methods
         * @param text - the text to encode
         * @return the encoded text      */

        protected native String jsEscape(String text) /*-{
            return escape(text);
        }-*/;


}
