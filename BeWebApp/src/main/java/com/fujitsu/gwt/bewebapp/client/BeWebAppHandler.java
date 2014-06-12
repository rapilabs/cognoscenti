package com.fujitsu.gwt.bewebapp.client;

import java.util.Iterator;
import java.util.Map;

import com.fujitsu.gwt.bewebapp.client.BUsinessEntityView.NodeKey;
import com.fujitsu.gwt.bewebapp.client.common.Utils;
import com.fujitsu.gwt.bewebapp.client.widgets.TreeTable;
import com.fujitsu.gwt.bewebapp.client.widgets.TreeTable.TreeTableItem;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.OpenEvent;
import com.google.gwt.event.logical.shared.OpenHandler;
import com.google.gwt.http.client.URL;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.rpc.AsyncCallback;
import com.google.gwt.user.client.ui.Button;
import com.google.gwt.user.client.ui.DialogBox;
import com.google.gwt.user.client.ui.DisclosurePanel;
import com.google.gwt.user.client.ui.FileUpload;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.FormPanel;
import com.google.gwt.user.client.ui.HasHorizontalAlignment;
import com.google.gwt.user.client.ui.Hidden;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.PushButton;
import com.google.gwt.user.client.ui.RadioButton;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.client.ui.FlexTable.FlexCellFormatter;
import com.google.gwt.user.client.ui.FormPanel.SubmitCompleteEvent;
import com.google.gwt.user.client.ui.FormPanel.SubmitEvent;

public class BeWebAppHandler implements ClickHandler{


	VerticalPanel dialogVPanel;

	//Create Panel

	private DialogBox beDialogBox;

	private Button beCreateBtn;
	private Button prjBtn;

	//Create Business Entity Form
	private FormPanel form;
	private TextBox fname;
	private TextBox fdesc;
	private FileUpload upload;
	private Button fsub;
	private Button fcncl;
	private Hidden besLoc;

	private DialogBox addDialogBox;
	private Button addCancelBtn;
	private Button addSubmitBtn;
	private TextBox addNameTextBox;
	private TextBox addValueTextBox;
	private RadioButton optionContainer;
	private RadioButton optionData;
	private RadioButton optionChild;
	private RadioButton optionSibling;

	//Edit Panel
	private DisclosurePanel editPanel;
	private VerticalPanel editVpanel;
	private HorizontalPanel viewBarPanel;

	private PushButton addPb;
	private PushButton savePb;
	private PushButton deletePb;
	private PushButton refreshPb;
	private PushButton openPb;

	private BUsinessEntityView bev;
	private TreeTable treeTable;
	private BusinessEntity be;
	private static final String UPLOAD_ACTION_URL = GWT.getModuleBaseURL() + "upload";


	private TextArea xmltextArea;

	public BeWebAppHandler(VerticalPanel dialogVPanel, BusinessEntity be){
		this.dialogVPanel = dialogVPanel;
		this.be = be;
	}
	public void initCreatePanel(){
		beCreateBtn = new Button("Create New Business Entity");
		beCreateBtn.addClickHandler(this);

		prjBtn =  new Button("Go to Project Page");
		prjBtn.addClickHandler(this);
		//dialogVPanel.add(prjBtn);

		HorizontalPanel hppp = new HorizontalPanel();
		hppp.add(beCreateBtn);
		//hppp.add(prjBtn);

		dialogVPanel.setHorizontalAlignment(VerticalPanel.ALIGN_LEFT);
		dialogVPanel.add(hppp);
		initCreateFormPanel();

		beDialogBox = new DialogBox();
		beDialogBox.setText("Create Business Entity");
		beDialogBox.setGlassEnabled(true);
		beDialogBox.setAnimationEnabled(true);
		beDialogBox.setWidget(form);

	}


	public void initEditPanel(){
		int lname = 50;
		int ldesc = 100;

		String bname = be.getName();
		String bdesc = be.getDesc();
		if(bname.length() > 50){
			bname = bname.substring(0, 48) + "..";
		}else if(bname.length() < 50){
			int diff = 50 - bname.length();
			for(int i=0; i<diff; i++){
				bname = bname + " ";
			}
		}
		//Window.alert("bname length:" + bname.length());

		if(bdesc.length() > 100){
			bdesc = bdesc.substring(0, 98) + "..";
		}else if(bdesc.length() < 100){
			int diff = 100 - bdesc.length();
			for(int i=0; i<diff; i++){
				bdesc = bdesc + " ";
			}
		}

		String htext = bname + "   -" + bdesc;

		editPanel  = new DisclosurePanel(htext);
		editPanel.setWidth("100%");
		editPanel.setAnimationEnabled(true);
		dialogVPanel.add(editPanel);
		editVpanel = new VerticalPanel();
		editVpanel.addStyleName("dialogVPanel");
		viewBarPanel = new HorizontalPanel();

		addPb = new PushButton(BeWebApp.addImg);
		addPb.setTitle("Add new");
		addPb.addClickHandler(this);

		savePb = new PushButton(BeWebApp.saveImg);
		savePb.setTitle("Save");
		savePb.addClickHandler(this);

		deletePb = new PushButton(BeWebApp.deleteImg);
		deletePb.setTitle("Delete");
		deletePb.addClickHandler(this);

		refreshPb = new PushButton(BeWebApp.refreshImg);
		refreshPb.setTitle("reload");
		refreshPb.addClickHandler(this);

		openPb = new PushButton(BeWebApp.openImg);
		openPb.setTitle("view xml");
		openPb.addClickHandler(this);


		viewBarPanel.add(addPb);
		viewBarPanel.add(savePb);
		viewBarPanel.add(deletePb);
		viewBarPanel.add(refreshPb);
		viewBarPanel.add(openPb);

		editVpanel.add(viewBarPanel);

		xmltextArea = new TextArea();
		xmltextArea.setWidth("498px");
		xmltextArea.ensureDebugId("debug-panel-xml");
		xmltextArea.setStyleName(Utils.style() + "-xml");
		xmltextArea.setReadOnly(true);

		editPanel.addOpenHandler(new OpenHandler<DisclosurePanel>() {
			public void onOpen(OpenEvent<DisclosurePanel> event) {
				if(bev == null){
					getBusinessEntity();
				}
			}

		});

		addDialogBox = new DialogBox();
		addDialogBox.setText("Add New Node");
		addDialogBox.setGlassEnabled(true);
		addDialogBox.setAnimationEnabled(true);

		FlexTable layout = new FlexTable();
		addNameTextBox = new TextBox();
		addNameTextBox.setWidth("300px");
		addValueTextBox = new TextBox();
		addValueTextBox.setWidth("300px");
		optionContainer = new RadioButton("addNode", "Container Node");
		optionData = new RadioButton("addNode", "Data Node");
		optionData.setValue(true);

		optionChild = new RadioButton("nodePos", "Child");
		optionSibling = new RadioButton("nodePos", "Sibling");
		optionChild.setValue(true);

		addCancelBtn = new Button("Cancel");
		addCancelBtn.addClickHandler(this);
		addSubmitBtn = new Button("Submit");
		addSubmitBtn.addClickHandler(this);

		layout.setCellSpacing(6);
		FlexCellFormatter cellFormatter = layout.getFlexCellFormatter();

	    // Add a title to the form
	    layout.setHTML(0, 0, "Enter Data");
	    cellFormatter.setColSpan(0, 0, 2);
	    cellFormatter.setHorizontalAlignment(0, 0,
	    HasHorizontalAlignment.ALIGN_CENTER);

		// Add some standard form options
	    layout.setHTML(1, 0, "Name");
	    layout.setWidget(1, 1, addNameTextBox);

	    HorizontalPanel pohp = new HorizontalPanel();
	    pohp.add(optionChild);
	    pohp.add(optionSibling);
	    layout.setHTML(2, 0, "Position");
		layout.setWidget(2, 1, pohp);

	    HorizontalPanel ohp = new HorizontalPanel();
	    ohp.add(optionData);
	    ohp.add(optionContainer);
	    layout.setHTML(3, 0, "Type");
		layout.setWidget(3, 1, ohp);

		HorizontalPanel hp = new HorizontalPanel();
		hp.add(addSubmitBtn);
		hp.add(addCancelBtn);
		layout.setWidget(4, 1, hp);
	    cellFormatter.setColSpan(4, 1, 2);
	    cellFormatter.setHorizontalAlignment(4, 1,
	    HasHorizontalAlignment.ALIGN_CENTER);


		addDialogBox.add(layout);

	}

	private void getBusinessEntity(){
		BeWebApp.showLodingDialogue();
		String name = getFullProjectId() + "/" + be.getName();
		BeWebApp.besService.getBusinessEntity(name, new AsyncCallback<String>() {
			public void onFailure(Throwable caught) {
				BeWebApp.hideLodingDialogue();
				BeWebApp.showError(caught);
			 }
			 public void onSuccess(String result) {
				 BeWebApp.hideLodingDialogue();
				 bev = new BUsinessEntityView(result);
				 bev.setXMLTextArea(xmltextArea);
				 setTreeWidget();
			 }
		  });
	}

	private void setTreeWidget(){
	    treeTable =  new TreeTable(bev, null, new TreeTable.CellFormatter() {
	        //@Override
	        public String getCellStyleName(Object node, int columnIndex) {
	          if (columnIndex == 0) {
	            return Utils.style() + "-tree";
	          } else {
	            return null;
	          }
	        }
	      }, true);
	    editVpanel.add(treeTable);
	    xmltextArea.setText(bev.getXML());
	    editVpanel.add(xmltextArea);
		editPanel.setContent(editVpanel);
	}

	public void onClick(ClickEvent event) {
		// TODO Auto-generated method stub
		Widget sender = (Widget) event.getSource();
		if (sender == beCreateBtn) {
			beDialogBox.center();
			beDialogBox.show();
			fname.setFocus(true);
		}else if (sender == prjBtn) {
			//Window.open(getPrjLink(),"_top", "" );
			Window.open(getPrjLink(),"_blank", "" );
		}else if (sender == addPb) {
			addNameTextBox.setText("");
			addDialogBox.center();
			addDialogBox.show();
			addNameTextBox.setFocus(true);
		}else if (sender == deletePb) {
			NodeKey nodeKey = getSelectedNode();
			if(nodeKey == null){
				Exception exp = new Exception("No node is selected. Please select a node.");
				addDialogBox.hide();
				BeWebApp.showError(exp);
			}else{
				int indx = getSelectedIndex(nodeKey);
				boolean isOk =
					Window.confirm("Do you want to delete Node: " + nodeKey.getNode().getNodeName() + "?");
				if(!isOk) {
					return;
				}
				try{
					bev.removeNode(nodeKey,indx);
					updatexmltextArea();
				}catch(Exception e){
					BeWebApp.showError(e);
				}
			}
		}else if (sender == savePb) {
			saveBes();
		}else if (sender == refreshPb) {
			getBusinessEntity();
		}else if (sender == openPb) {
			String xLink = getXMLLink();
			Window.open(xLink,"_blank", "" );
		}else if (sender == addCancelBtn) {
			addDialogBox.hide();
		}else if (sender == addSubmitBtn) {
			String tname = addNameTextBox.getValue();
			String pos = "child";
			if(optionSibling.getValue()){
				pos = "sibling";
			}

			int ttype = 1;
			if(optionData.getValue()){
				ttype = 3;
			}
			addDialogBox.hide();
			NodeKey nodeKey = getSelectedNode();
			if(nodeKey == null){
				Exception exp = new Exception("No node is selected. Please select a node.");
				BeWebApp.showError(exp);
			}else{
				try{
					int indx = getSelectedIndex(nodeKey);
					bev.addNode(nodeKey, tname, pos, ttype, indx);
					updatexmltextArea();
				}catch(Exception e){
					BeWebApp.showError(e);
				}
			}
		}

	}


	  private void initCreateFormPanel () {

		  form = new FormPanel();
		  form.setAction(BeWebApp.UPLOAD_ACTION_URL);
		  form.setEncoding(FormPanel.ENCODING_MULTIPART);
		  form.setMethod(FormPanel.METHOD_POST);

		  FlexTable layout = new FlexTable();
		  form.setWidget(layout);


		  fname = new TextBox();
		  fname.setName("besname");
		  fname.setWidth("300px");
		  fdesc = new TextBox();
		  fdesc.setName("besdesc");
		  fdesc.setWidth("300px");

		  // Create a FileUpload widget.
		  upload = new FileUpload();
		  upload.setName("File");
		  upload.setWidth("300px");


		  // Add a 'submit' button.
		  fsub = new Button("Submit", new ClickHandler() {
			  public void onClick(ClickEvent event) {
				  form.submit();
		      }
		   });
		  // Add a 'Cancel' button.
		  fcncl = new Button("Cancel", new ClickHandler() {
			  public void onClick(ClickEvent event) {
				  beDialogBox.hide();
		      }
		  });

		  // Add an event handler to the form.
		  form.addSubmitHandler(new FormPanel.SubmitHandler() {
			  public void onSubmit(SubmitEvent event) {
				String ufname = upload.getFilename();
				String inTxt = fname.getText();
				if( (ufname == null || ufname.length() == 0)
					&& (inTxt == null || inTxt.length() == 0) ){
					Window.alert("The 'Name' and 'File' both can not be empty");
					event.cancel();
				}
	            if(inTxt != null){
					String vTxt = inTxt.toLowerCase().replaceAll("[^A-Za-z0-9]", "_");
					if(!inTxt.equalsIgnoreCase(vTxt)){
						Window.alert("Not a valid name, possible name:" + vTxt);
						event.cancel();
					}
	            }
			  }
			});

		 form.addSubmitCompleteHandler(new FormPanel.SubmitCompleteHandler() {
		     public void onSubmitComplete(SubmitCompleteEvent event) {
		         // When the form submission is successfully completed, this
		     // event is fired. Assuming the service returned a response of type
		     // text/html, we can get the result text here (see the FormPanel
		     // documentation for further explanation).

		    	 BusinessEntity nbe = new BusinessEntity();
        		 nbe.setName(fname.getText());
        		 nbe.setDesc(fdesc.getText());
        		 BeWebAppHandler tbeh = new BeWebAppHandler(dialogVPanel,nbe);
  	       	     tbeh.initEditPanel();
        		 beDialogBox.hide();
		     }
		 });

	    layout.setCellSpacing(6);
	    FlexCellFormatter cellFormatter = layout.getFlexCellFormatter();

	    // Add a title to the form
	    layout.setHTML(0, 0, "Enter Data");
	    cellFormatter.setColSpan(0, 0, 2);
	    cellFormatter.setHorizontalAlignment(0, 0,
	        HasHorizontalAlignment.ALIGN_CENTER);

	    // Add some standard form options
	    layout.setHTML(1, 0, "Name");
	    layout.setWidget(1, 1, fname);
	    layout.setHTML(2, 0, "Description");
	    layout.setWidget(2, 1, fdesc);
	    layout.setHTML(3, 0, "File");
	    layout.setWidget(3, 1, upload);

	    besLoc = new Hidden("besloc", getFullProjectId());
	    besLoc.setName("besloc");
	    HorizontalPanel hp = new HorizontalPanel();
	    hp.add(fsub);
	    hp.add(fcncl);
	    hp.add(besLoc);
	    layout.setWidget(4, 1, hp);
	    cellFormatter.setColSpan(4, 1, 2);
	    cellFormatter.setHorizontalAlignment(4, 1,
	    HasHorizontalAlignment.ALIGN_CENTER);
	  }

	  private String getXMLLink(){
		  String name = getFullProjectId() + "/" + be.getName();
		  String belink =  UPLOAD_ACTION_URL
				+ "?action=open&basename=" + name;
		  return belink;
	  }

	  private String getFullProjectId(){
    	String purl = Window.Location.getHref();
    	purl = URL.decode(purl);
    	int eindx  = purl.lastIndexOf('/');
    	int tindx = purl.indexOf("/t/");
    	int bindx = tindx + 3;
    	String fprjid = purl.substring(bindx,eindx);
    	return fprjid;
	  }

	  private NodeKey getSelectedNode(){
		  Map<Object, TreeTableItem> map = this.treeTable.getNodeMap();
		  Iterator<Object> it = map.keySet().iterator();
		  while (it.hasNext()) {
			  NodeKey key = (NodeKey) it.next();
		      TreeTableItem value = (TreeTableItem) map.get(key);
		      if(value.isSelected()){
		    	  //this.addDialogBox.hide();
		    	  //Window.alert("Selected Node:" + key.getNode().getNodeName());
		    	  return key;
		      }
		      //do stuff here
		  }
		  return null;

	  }

	  private int getSelectedIndex(NodeKey child){
		  int indx = 0;
		  Object parent = child.getParentKey();
		  if(parent == null)
			  return indx;

		  Map map = this.treeTable.getNodeMap();
		  TreeTableItem ptree = (TreeTableItem)map.get(parent);
		  if(ptree != null){
			  //Window.alert("ptree is not null");
			  TreeTableItem ctree = (TreeTableItem)map.get(child);
			  indx = ptree.getChildIndex(ctree);
		  }
		  if(indx < 0)
			 indx = 0;

		  return indx;
	  }

	  private void updatexmltextArea(){
		  xmltextArea.setText(bev.getXML());
	  }

	  private void saveBes(){
		  String name = getFullProjectId() + "/" + be.getName();
		  BeWebApp.besService.saveBusinessEntity(name, bev.getXML(), new AsyncCallback<String>() {
				public void onFailure(Throwable caught) {
					BeWebApp.showError(caught);
				 }
				 public void onSuccess(String result) {
					 //Data is already with client
				}
			});
		}

	  private String getPrjLink(){
		  String purl = Window.Location.getHref();
		  purl = URL.decode(purl);
		  int inndx  = purl.lastIndexOf('/');
	      purl = purl.substring(0, inndx) + "/project.htm";
	      return purl;
	  }

}
