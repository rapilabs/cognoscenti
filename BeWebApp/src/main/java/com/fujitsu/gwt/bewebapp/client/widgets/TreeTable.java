/*
 * Copyright 2009 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy
 * of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations
 * under the License.
 */
package com.fujitsu.gwt.bewebapp.client.widgets;

import java.util.ArrayList;
import java.util.Date;
import java.util.IdentityHashMap;
import java.util.List;
import java.util.Map;

import com.fujitsu.gwt.bewebapp.client.BUsinessEntityView;
import com.fujitsu.gwt.bewebapp.client.BUsinessEntityView.NodeKey;
import com.google.gwt.core.client.GWT;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.logical.shared.ValueChangeEvent;
import com.google.gwt.event.logical.shared.ValueChangeHandler;
import com.google.gwt.i18n.client.DateTimeFormat;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.Element;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.AbstractImagePrototype;
import com.google.gwt.user.client.ui.CheckBox;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.FlexTable;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.RadioButton;
import com.google.gwt.user.client.ui.TextBox;
import com.google.gwt.user.client.ui.TreeImages;
import com.google.gwt.user.client.ui.Widget;
import com.google.gwt.user.datepicker.client.DateBox;
import com.google.gwt.xml.client.Node;

/**
 * A widget displaying a {@link TreeTableModel}. This will display a table,
 * where the first column is a tree and each node in the tree is a table row.
 */
public class TreeTable extends Composite {

  /** This simple {@link CellFormatter} does not provide any additional style. **/
  public static final CellFormatter DEFAULT_CELL_FORMATTER = new CellFormatter() {
    public String getCellStyleName(Object node, int columnIndex) {
      return null;
    }
  };

  private TreeTableModel model;
  private TreeImages images;
  private CellFormatter formatter;
  private Map<Object, TreeTableItem> items;
  private RowAccountingTable table;
  private TreeTableItem root;

  /**
   * Constructs a new TreeTable that will display the given model, using the
   * given images and formatter.
   *
   * @param model the model to be displayed
   * @param images the images to use for the tree handles. If {@code null},
   *     will use GWT.create to get the default tree images
   * @param formatter the formatter to use for the table cells. If
   *     {@code null}, will use {@link #DEFAULT_CELL_FORMATTER}
   * @param showRoot whether to display the root node. Since a TreeModel only
   *     have a single root, set this to {@code false} to simulate a tree with
   *     multiple roots (i.e. the first generation children appear to be the
   *     roots)
   */
  public TreeTable(
      final TreeTableModel model, TreeImages images, CellFormatter formatter, boolean showRoot) {
    this.model = model;
    this.images = (images == null) ? GWT.<TreeImages>create(TreeImages.class) : images;
    this.formatter = (formatter == null) ? DEFAULT_CELL_FORMATTER : formatter;
    this.items = new IdentityHashMap<Object, TreeTableItem>();

    initWidget(table = new RowAccountingTable());
    createHeader();
    Object rootNode = model.getRoot();
    root = new TreeTableItem(rootNode, table.newRow(), showRoot ? 0 : -1);
    //Window.alert("rootNode:" + rootNode);
    createTree(root, rootNode);
    items.put(rootNode, root);

    model.addTreeTableModelListener(new TreeTableModelListener() {
      //@Override
      public void nodeAdded(Object parent, Object node, int index) {
        TreeTableItem item = items.get(parent);
        //Window.alert("parent:" + item);
        if (item != null) {
          items.put(node, item.addChild(index, node));
        }
      }

      //@Override
      public void nodeRemoved(Object parent, Object node, int index) {
    	  //Window.alert("remove indx:" + index);
        TreeTableItem item = items.get(parent);
        if (item != null) {
          item.removeChild(index);
          items.remove(node);
        }
      }

      //@Override
      public void valueChanged(Object node, int columnIndex) {
        TreeTableItem item = items.get(node);
        if (item != null && item.isShown()) {
          item.setValue(columnIndex, String.valueOf(model.getValueAt(node, columnIndex)));
        }
      }
    });
  }

  private void createHeader() {
	 
    RowAccountingTable.Row row = table.newRow();
    for (int i = 0; i < model.getColumnCount(); i++) {
       row.setText(i, model.getColumnName(i));
    }  
    row.setRowStyleName("DebugPanel-TreeTable-header");
  }

  private void createTree(TreeTableItem parent, Object parentNode) {
    for (int i = 0; i <  model.getChildCount(parentNode); i++) {
      Object node = model.getChild(parentNode, i);
      TreeTableItem item = parent.addChild(i, node);
      items.put(node, item);
      createTree(item, node);
    }
  }

  public TreeTableItem getRoot() {
    return root;
  }
  
  public Map<Object, TreeTableItem> getNodeMap(){
	  return items;
  }

  /**
   * A {@link FlexTable} with row pointers that update themselves when rows are
   * added or removed.
   */
  public static class RowAccountingTable extends FlexTable {
    private List<Row> rows;

    public RowAccountingTable() {
      rows = new ArrayList<Row>();
      setStyleName("DebugPanel-TreeTable");
    }

    /**
     * Inserts a new row at the bottom of the table.
     */
    public Row newRow() {
      return newRow(null);
    }

    /**
     * Inserts a new row before the given row.
     *
     * @param before the row where the new row should be added. If
     *     {@code null}, the new row will be appended to the end
     */
    public Row newRow(Row before) {
      Row r;
      if (before == null) {
        rows.add(r = new Row(rows.size()));
      } else {
        r = new Row(before.getRow());
        rows.add(r.getRow(), r);
        for (int i = r.getRow() + 1; i < rows.size(); i++) {
          rows.get(i).setRow(i);
        }
      }
      insertRow(r.getRow());
      return r;
    }

    public void removeRow(Row row) {
      rows.remove(row.getRow());
      removeRow(row.getRow());
      for (int i = row.getRow(); i < rows.size(); i++) {
        rows.get(i).setRow(i);
      }
    }

    /**
     * Pointer to a row in the {@link RowAccountingTable}.
     */
    public class Row {
      private int row;

      Row(int row) {
        this.row = row;
      }

      public int getRow() {
        return row;
      }

      void setRow(int row) {
        this.row = row;
      }

      public void remove() {
        RowAccountingTable.this.removeRow(this);
      }

      public void setWidget(int column, Widget widget) {
        RowAccountingTable.this.setWidget(row, column, widget);
      }

      public void setText(int column, String text) {
        RowAccountingTable.this.setText(row, column, text);
      }

      public void setVisible(boolean visible) {
        getRowFormatter().setVisible(row, visible);
      }

      public void setRowStyleName(String name) {
        getRowFormatter().setStyleName(row, name);
      }

      public void setColumnStyleName(int column, String name) {
        getCellFormatter().setStyleName(row, column, name);
      }

      public Row next() {
        if (row + 1 >= rows.size()) {
          return null;
        }
        return rows.get(row + 1);
      }

      public Row previous() {
        return (row == 0) ? null : rows.get(row - 1);
      }
    }
  }

  /**
   * Item representing a node in the tree and a row in the table.
   */
  public class TreeTableItem {
    private final Object node;
    private final List<TreeTableItem> children;
    private final RowAccountingTable.Row row;
    private final int level;
    private boolean open, shown;
    
    private final ItemWidget widget;
    private final TextBox valueBox;
    private final DateBox dateBox;
    private final ListBox typeBox;
    private final RadioButton rb;
    private int typeIndex = 0;

    TreeTableItem(Object node1, RowAccountingTable.Row row1, int level) {
      this.node = node1;
      this.children = new ArrayList<TreeTableItem>();
      this.row = row1;
      this.level = level;
      this.shown = false;

      
      rb = new RadioButton("myRadioGroup", "");

      
      valueBox = new TextBox();
      valueBox.setStyleName("treeTextBox");
      
      // Hook up a handler to find out when it's clicked.
      valueBox.addChangeHandler(new ChangeHandler() {
        public void onChange(ChangeEvent event) {
        	String val = valueBox.getText();
        	isValid();
        	((NodeKey)node).setNodeValue(val);
        	
        }
      });
      
  	DateTimeFormat dateFormat = DateTimeFormat.getLongDateFormat();
  	dateBox = new DateBox();
    dateBox.setFormat(new DateBox.DefaultFormat(dateFormat));
    dateBox.addValueChangeHandler(new ValueChangeHandler<Date>() {
		public void onValueChange(ValueChangeEvent<Date> event) {
			String value = String.valueOf(dateBox.getValue().getTime());
			((NodeKey)node).setNodeValue(value);
		}
	});
      
      
      
      typeBox = new ListBox();
      typeBox.addItem(BUsinessEntityView.TEXT_STRING);
      typeBox.addItem(BUsinessEntityView.TEXT_BOOLEAN);
      typeBox.addItem(BUsinessEntityView.TEXT_INTEGER);
      typeBox.addItem(BUsinessEntityView.TEXT_DECIMAL);
      typeBox.addItem(BUsinessEntityView.TEXT_DATE);
      typeBox.addItem(BUsinessEntityView.TEXT_EMAIL);
      
  
      // Hook up a handler to find out when it's clicked.
      typeBox.addChangeHandler(new ChangeHandler() {
        public void onChange(ChangeEvent event) {
        	boolean isOk =
				Window.confirm("You may loose data by changing data type. Do you want to continue?");
			if(!isOk) {
				typeBox.setSelectedIndex(typeIndex);
				return;
			}else{
				int sIndex = ((ListBox) event.getSource()).getSelectedIndex();
				if(sIndex== typeIndex){
					return;
				}else if(typeIndex == 4){
					try{
						long l = dateBox.getValue().getTime();
						valueBox.setValue(String.valueOf(l));
					}catch(Exception e){
						//Set empty
						valueBox.setValue("");
					}
					isValid();
					row.setWidget(1, valueBox);
				}else if(sIndex == 4){
					try{
						String x = valueBox.getValue();
						long l = Long.parseLong(x);
						dateBox.setValue(new Date(l));
					}catch(Exception e){
						dateBox.setValue(new Date());
					}
					row.setWidget(1, dateBox);
				}else{
					isValid();
				}
				typeIndex = sIndex;
				((NodeKey)node).setTextType(typeBox.getItemText(sIndex));
				
				
			}
			
        }
      });
     
      
      if (level < 0) {
        widget = null;
        row.setVisible(false);
        open = true;
      } else {
        open = false;
        widget = new ItemWidget(level);
        widget.setImage(images.treeLeaf());
        widget.setClickHandler(new ClickHandler() {
          //@Override
          public void onClick(ClickEvent event) {
            toggle();
          }
        });
        if (level == 0) {
          show();
        } else {
          row.setVisible(false);
        }
      }
      
    }
    
    void show() {
      if (!shown) {
        shown = true;
        
        row.setWidget(0, widget);
        setValue(0, String.valueOf(model.getValueAt(node, 0)));
        
        typeIndex = this.getSelectedIndex(String.valueOf(model.getValueAt(node, 2)));
        
        String dataValue = String.valueOf(model.getValueAt(node, 1));
        if(typeIndex == 4){
        	try{
        		Date d = new Date(Long.parseLong(dataValue));
        		dateBox.setValue(d);
        	}catch(Exception e){
        		//Keep Empty
        	}
        }else{
        	valueBox.setText(dataValue);
        }
       
        typeBox.setSelectedIndex(typeIndex);
        
        if(((NodeKey)node).getNodeType() == 1){
        	row.setText(1, "--Container--");
        	row.setText(2, "--Container--");
        }else {
        	if(typeIndex == -1){
        		row.setText(2, BUsinessEntityView.TEXT_STRING);
        	}
        	if(typeIndex == 4){
        		row.setWidget(1, dateBox);
        	}else{
        		row.setWidget(1, valueBox);
        	}
        	row.setWidget(2, typeBox);
        }
        
        row.setWidget(3, rb);
        if(((NodeKey)node).isRoot())
        	rb.setValue(true);
        
      }
      row.setVisible(true);
    }

    TreeTableItem addChild(int index, Object node) {
      RowAccountingTable.Row before;
      if (children.size() == 0) {

        // Insert child at top and update image.
        before = row.next();
        if (widget != null) {
          widget.setImage(open ? images.treeOpen() : images.treeClosed());
        }
        index = 0;
      } else if (index == 0) {

        // Insert child at top.
        before = row.next();
      } else if (index < children.size()) {

        // Insert child in the middle.
        before = children.get(index).row;
      } else {

        // Insert child at the bottom.
        before = getLastRow().next();
        index = children.size();
      }
      TreeTableItem item = new TreeTableItem(node, table.newRow(before), level + 1);
      children.add(index, item);
      if (open) {
        item.show();
      }
      return item;
    }
    
    private int getSelectedIndex(String name){
    	if(BUsinessEntityView.TEXT_STRING.equals(name)){
    		return 0;
    	}else if(BUsinessEntityView.TEXT_BOOLEAN.equals(name)){
    		return 1;
    	}else if(BUsinessEntityView.TEXT_INTEGER.equals(name)){
    		return 2;
    	}else if(BUsinessEntityView.TEXT_DECIMAL.equals(name)){
    		return 3;
    	}else if(BUsinessEntityView.TEXT_DATE.equals(name)){
    		return 4;
    	}else if(BUsinessEntityView.TEXT_EMAIL.equals(name)){
    		return 5;
    	}else{
    		return -1;
    	}
    }
    
    private boolean isValid(){
    	boolean result = true;
    	String value = valueBox.getValue().trim();
    	int type  = typeBox.getSelectedIndex();
    	try{
	    	if(type == 1){
	    		if(value.equalsIgnoreCase("true")
	    				|| value.equalsIgnoreCase("false")){
	    			result = true;
	    		}else{
	    			result = false;
	    		}
	    	}else if(type == 2){
	    		Integer.parseInt(value);
	    	}else if(type == 3){
	    		Double.parseDouble(value);
	    	}else if(type == 5){
	    		if(value.matches(BUsinessEntityView.emailExp)){
	    			result = true;
	    		}else{
	    			result = false;
	    		}
	    			
	    	}
    	}catch(Exception e){
    		result = false;
    	}
    	
    	//Window.alert("Changing Style result:" + result);
    	if(!result){
    		valueBox.setStyleName("dateBoxFormatError");
    		valueBox.setFocus(true);
    	}else{
    		valueBox.setStyleName("treeTextBox");
    	}
    	return result;
    }

    private RowAccountingTable.Row getLastRow() {
      return (children.size() == 0) ? row : children.get(children.size() - 1).getLastRow();
    }

    public int getChildCount() {
      return children.size();
    }

    public TreeTableItem getChild(int index) {
      return children.get(index);
    }

    public void removeChild(int index) {
      TreeTableItem child = children.remove(index);
      child.row.remove();
      child.removeAllChildren();
      if (children.size() == 0) {
        if (widget != null) {
          widget.setImage(images.treeLeaf());
        }
      }
    }

    public void removeAllChildren() {
      for (TreeTableItem child : children) {
        child.row.remove();
        child.removeAllChildren();
      }
      children.clear();
      if (widget != null) {
        widget.setImage(images.treeLeaf());
      }
    }

    public void setValue(int col, String text) {
      if (col == 0) {
        if (widget != null) {
          widget.setLabel(text);
        }
      } else {
        row.setText(col, text);
      }
    }

    /**
     * Opens or closes the current tree item.
     */
    public void toggle() {
      if (children.size() > 0) {
        open = !open;
        if (widget != null) {
          widget.setImage(open ? images.treeOpen() : images.treeClosed());
        }
        for (TreeTableItem child : children) {
          if (!open) {
            child.close();
            child.row.setVisible(false);
          } else {
            child.show();
          }
        }
      }
    }

    public void close() {
      if (open) {
        toggle();
      }
    }

    public boolean isOpen() {
      return open;
    }

    public boolean isShown() {
      return shown;
    }

    public ItemWidget getWidget() {
      return widget;
    }
    
    public boolean isSelected(){
    	
    	return rb.getValue();
    }
    
    public int getType(){
    	return typeBox.getSelectedIndex();
    }
    
    public String getValue(){
    	return valueBox.getText();
    }
    
    public int getChildIndex(TreeTableItem ctree){
    	return children.indexOf(ctree);
    }
    
  }

  /**
   * The widget displayed in the first column containing the label and tree image.
   */
  public static class ItemWidget extends Widget {
    protected final Element image;
    protected final Element label;

    public ItemWidget(int level) {
      this.image = DOM.createSpan();
      this.label = DOM.createSpan();

      Element div = DOM.createDiv();
      div.appendChild(this.image);
      div.appendChild(this.label);

      div.setAttribute("style", "padding-left: " + level * 16 + "px");
      image.setAttribute("style", "vertical-align: bottom");

      setElement(div);
    }

    public void setClickHandler(final ClickHandler handler) {
      addDomHandler(handler, ClickEvent.getType());
    }

    public void setImage(AbstractImagePrototype image) {
      Element child = DOM.getFirstChild(this.image);
      if (child == null) {
        DOM.appendChild(this.image, image.createElement().<Element> cast());
      } else {
        image.applyTo(child.<AbstractImagePrototype.ImagePrototypeElement> cast());
      }
    }

    public void setLabel(String label) {
      this.label.setInnerHTML(label);
    }

    public String getLabel() {
      return label.getInnerHTML();
    }
  }

  /**
   * Allows the formatting of individual cells by setting a style.
   */
  public static interface CellFormatter {

    /**
     * Return {@code null} if you do not wish to set a style.
     */
    public String getCellStyleName(Object node, int columnIndex);
  }
}
