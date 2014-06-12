package com.fujitsu.gwt.bewebapp.client;

import java.util.Vector;

import com.fujitsu.gwt.bewebapp.client.widgets.TreeTableModel;
import com.fujitsu.gwt.bewebapp.client.widgets.TreeTableModelListener;
import com.google.gwt.user.client.rpc.IsSerializable;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.xml.client.Document;
import com.google.gwt.xml.client.Element;
import com.google.gwt.xml.client.NamedNodeMap;
import com.google.gwt.xml.client.Node;
import com.google.gwt.xml.client.NodeList;
import com.google.gwt.xml.client.XMLParser;

public class BUsinessEntityView implements TreeTableModel {

    public static final int TYPE_CONTAINER = 1;
    public static final int TYPE_ATTRIBUTE = 2;
    public static final int TYPE_DATA = 3;
    
    public static final String TEXT_STRING = "String";
    public static final String TEXT_BOOLEAN = "Boolean";
    public static final String TEXT_INTEGER = "Integer";
    public static final String TEXT_DECIMAL= "Decimal";
    public static final String TEXT_DATE = "Date";
    public static final String TEXT_EMAIL = "Email";
    public static final String TEXT_TYPE_ATT = "_system_text_type";
    
    public static String  emailExp  =
        "^[a-zA-Z][\\w\\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\\w\\.-]*[a-zA-Z0-9]\\.[a-zA-Z][a-zA-Z\\.]*[a-zA-Z]$";


    private Vector listeners ;
    private Document doc;
    private TextArea xmlTextArea;


    public BUsinessEntityView(String data){
        listeners = new Vector();
        doc = XMLParser.parse(data);
    }
    
    

    public void addTreeTableModelListener(TreeTableModelListener listener) {
        listeners.add(listener);

    }

    public Object getChild(Object parent, int index) {
        NodeKey nKey = (NodeKey)parent;
        Node n = nKey.getNode();
        Vector<NodeKey> childVector = new Vector<NodeKey>();
        try {
        if(Node.ELEMENT_NODE == n.getNodeType() ){
            NamedNodeMap  attMap = n.getAttributes();
            if(attMap != null){
                for(int i=0; i<attMap.getLength(); i++){
                    Node attNode = attMap.item(i);
                    NodeKey cKey = new NodeKey(attNode, nKey, TYPE_ATTRIBUTE);
                    childVector.add(cKey);
                    
                }
            }
            
            //Get Child Node
            NodeList ndList = n.getChildNodes();
            if(ndList != null){
                for(int i=0; i<ndList.getLength(); i++){
                    Node cnd  = ndList.item(i);
                    if(Node.ELEMENT_NODE == cnd.getNodeType() ){
                        NodeKey cKey;
                        if(isTextNode(cnd))
                            cKey = new NodeKey(cnd, nKey, TYPE_DATA);
                        else
                            cKey = new NodeKey(cnd, nKey, TYPE_CONTAINER);
                        
                        childVector.add(cKey);
                    }
                 }
            }
        }
        
        return childVector.get(index);
        }catch(Exception e){
            System.out.println("EXCEPTION NODE NAME:" + n.getNodeName() 
                    + " INDX:" + index + " VSIZE:" + childVector.size());
            return null;
        }
    }

    public int getChildCount(Object parent) {
        int cCount = 0;
        //Window.alert("parent:" + parent);
        NodeKey nKey = (NodeKey)parent;
        Node n = nKey.getNode();
        if(Node.ELEMENT_NODE == n.getNodeType() ){
            NamedNodeMap  attMap = n.getAttributes();
            if(attMap != null){
                cCount = cCount + attMap.getLength();
            }
            NodeList ndList = n.getChildNodes();
            if(ndList != null){
                for(int i=0; i<ndList.getLength(); i++){
                    Node nd  = ndList.item(i);
                    if(Node.ELEMENT_NODE == nd.getNodeType())
                        cCount = cCount + 1;
                }
            }
        }
        return cCount;
        
    }

    public int getColumnCount() {
        // TODO Auto-generated method stub
        return 4;
    }

    public String getColumnName(int columnIndex) {
        // TODO Auto-generated method stub
        switch (columnIndex) {
        case 0: return "Node Name";
        case 1: return "Node Data";
        case 2: return "Data Type";
        case 3: return "";
        default: return "Unknown";
      }
    }

    public Object getRoot() {
        Node root = doc.getDocumentElement();
        NodeKey pKey = new NodeKey(root, null, TYPE_CONTAINER);
        NodeKey nKey = new NodeKey(root, pKey, TYPE_CONTAINER);
        nKey.setRoot(true);
        return nKey;
        
    }

    public Object getValueAt(Object node, int columnIndex) {
        
        String value = "";
        NodeKey nKey = (NodeKey)node;
        Node n = nKey.getNode();
        if(Node.ELEMENT_NODE == n.getNodeType() ){
            Node tNode = n.getFirstChild();
            if(tNode != null && tNode.getNodeValue() != null)
                value = tNode.getNodeValue();
        }else if(Node.ATTRIBUTE_NODE == n.getNodeType()){
            if(n.getNodeValue() != null)
                value = n.getNodeValue();
        }
        switch (columnIndex) {
            case 0: return n.getNodeName();
            case 1: return value;
            case 2: return n.getNodeType();
            case 3: return "false";
            default: return value;
        }
    }
    
    

    public void removeTreeTableModelListener(TreeTableModelListener listener) {
        this.listeners.remove(listener);

    }
    
    public void addNode(NodeKey nKey, String name, String pos, int type, int indx) throws Exception{
        try{
            NodeKey parentKey = nKey.getParentKey();
            Node node = nKey.getNode();
            NodeKey nchildKey = null;
            NodeKey nparentKey = null;
            
            Node childNode = doc.createElement(name);
            if (type == TYPE_DATA){
                childNode.appendChild(doc.createTextNode(""));
            }
            
            if(node.equals(doc.getDocumentElement())){
                indx = 0;
                nparentKey = nKey;
                childNode = node.appendChild(childNode);
            }else if("child".equalsIgnoreCase(pos)){
                if(TYPE_CONTAINER == nKey.getNodeType()){
                    indx = 0;
                    nparentKey = nKey;
                    childNode = node.appendChild(childNode);
                }else{
                    nparentKey = nKey.getParentKey();
                    Node parent = nparentKey.getNode();
                    childNode = parent.insertBefore(childNode, node);
                }
            }else{
                    nparentKey = nKey.getParentKey();
                    Node parent = nparentKey.getNode();
                    childNode = parent.insertBefore(childNode, node);
            }
            
            nchildKey = new NodeKey(childNode, nparentKey, type);

            for(int i=0; i<listeners.size(); i++){
                TreeTableModelListener lt = (TreeTableModelListener)listeners.get(i);
                lt.nodeAdded(nparentKey, nchildKey, indx);
            }
        }catch(Exception e){
            BeWebApp.showError(e);
        }
    }
    
    public void removeNode(NodeKey nKey, int indx) throws Exception{
        try {
            Node node = nKey.getNode();
            NodeKey parentKey = nKey.getParentKey();
            if(node.equals(doc.getDocumentElement())){
                throw new Exception("can not remove root element");
            }else {
                for(int i=0; i<listeners.size(); i++){
                    TreeTableModelListener lt = (TreeTableModelListener)listeners.get(i);
                    lt.nodeRemoved(parentKey, nKey, indx);
                }
                Node parent = parentKey.getNode();
                parent.removeChild(node);
            }
        }catch(Exception e){
            BeWebApp.showError(e);
        }
    }
    
    public String getXML(){
        return doc.toString();
    }
    
    private boolean isTextNode(Node node){
        NodeList nd = node.getChildNodes();
        if(nd == null || nd.getLength() >1 )
            return false;
        Node tNode = node.getFirstChild();
        if(tNode != null 
            &&tNode.getNodeType() == Node.TEXT_NODE 
                && tNode.getNodeValue()!= null){
            return true;
        }
        return false;
    }
    
     public void setXMLTextArea(TextArea xmlTextArea){
       this.xmlTextArea = xmlTextArea;
     }
    
    public class NodeKey implements IsSerializable{
        private NodeKey parentKey;
        private Node node;
        private int posIndx;
        private int nType;
        private boolean isRoot = false;
        
        public NodeKey(Node node, NodeKey parentKey, int ntype){
            this.node = node;
            this.parentKey = parentKey;
            this.nType = ntype;
        }
        public Node getNode(){
            return node;
        }
        
        public NodeKey getParentKey(){
            return parentKey;
        }
        
        public int getNodeType(){
            return nType;
        }
        
        public int getPosition(){
            return posIndx;
        }
        
        public void setPosition(int posIndx){
            this.posIndx = posIndx;
        }
        
        public void setNodeType(int nType){
            
        }
        public void setNodeValue(String value){
            if(TYPE_DATA == nType){
                Node txtNode = node.getFirstChild();
                txtNode.setNodeValue(value);
            }if(TYPE_ATTRIBUTE == nType){
                node.setNodeValue(value);
            }
            xmlTextArea.setText(getXML());
        }
        
        public void setTextType(String textType){
            if(Node.ATTRIBUTE_NODE == node.getNodeType()){
                return;
            }
            Element e = (Element)node;
            String lcl = e.getAttribute(TEXT_TYPE_ATT);
            
            if(textType.equalsIgnoreCase(lcl)){
                return;
            }else{
                e.setAttribute(TEXT_TYPE_ATT, textType);
                xmlTextArea.setText(getXML());
            }
            
        }
        
        public String getTextType(){
            if(Node.ATTRIBUTE_NODE == node.getNodeType()){
                return null;
            }else{
                Element e = (Element)node;
                String val =  e.getAttribute(TEXT_TYPE_ATT);
                if(val != null && val.length() > 0){
                    return val;
                }else{
                    return TEXT_STRING;
                }
            }
        }
        
        public void setRoot(boolean isRoot){
            this.isRoot = isRoot;
        }
        public boolean isRoot(){
            return isRoot;
        }
        
    }

}


