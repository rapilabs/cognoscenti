package com.fujitsu.gwt.bewebapp.client;

import com.google.gwt.core.client.Scheduler;
import com.google.gwt.user.client.Command;
import com.google.gwt.user.client.DOM;
import com.google.gwt.user.client.DeferredCommand;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTMLPanel;
import com.google.gwt.user.client.ui.HasText;
import com.google.gwt.user.client.ui.TextArea;
import com.google.gwt.user.client.ui.VerticalPanel;

/**
 * TinyMCE -
 *
 * A wrapper widget for using TinyMCE. It contains a number of JSNI methods that
 * I have found useful during development

 */
public class TinyMCE extends Composite implements HasText {
    private TextArea ta;
    private String id;
    public TinyMCE(int width, int height, String data) {
        super();
        VerticalPanel panel = new VerticalPanel();
        initWidget(panel);
        panel.setWidth("732px");
        panel.setHeight("250px");
        id = HTMLPanel.createUniqueId();
        ta = new TextArea();
        if(data != null){
            ta.setText(data);
        }
        ta.setCharacterWidth(width);
        ta.setVisibleLines(height);
        DOM.setElementAttribute(ta.getElement(), "id", id);
        DOM.setStyleAttribute(ta.getElement(), "width", "732px");
        DOM.setStyleAttribute(ta.getElement(), "height", "250px");
        panel.add(ta);
    }

    /**      * getID() -      *
     * * @return the MCE element's ID      */
    public String getID() {
        return id;
    }

    protected static native String getEditorContents(
            String elementId) /*-{
            return $wnd.tinyMCE.get(elementId).getContent();
    }-*/;

    protected static native void setEditorContents(
            String elementId, String html) /*-{
            $wnd.tinyMCE.execInstanceCommand(
            elementId, 'mceSetContent', false, html, false);
    }-*/;

    public void setText(String text) {
        setEditorContents(id, text);
    }

    public String getText() {
        return getEditorContents(id);
    }

    public void setEnabled(boolean enabled) {
        ta.setEnabled(enabled);
    }      /**      * @see com.google.gwt.user.client.ui.Widget#onLoad()      */
    protected void onLoad() {
        super.onLoad();
        DeferredCommand.addCommand(new Command() {
            public void execute() {
                setWidth("100%");
                setTextAreaToTinyMCE(id);
                //focusMCE(id);
                }
            });
        }
    /**
     * focusMCE() -
     *
     *  Use this to set the focus to the MCE area
     *   @param id - the element's ID
     * */
    protected native void focusMCE(String id) /*-{
        $wnd.tinyMCE.execCommand('mceFocus', true, id);
    }-*/;
    /**
     * resetMCE() -
     * Use this if reusing the same MCE element, but losing focus
    */

    public native void resetMCE() /*-{
        $wnd.tinyMCE.execCommand('mceResetDesignMode', true);
    }-*/;
    /**
     * unload() -
     * Unload this MCE editor instance from active memory.
     * I use this in the onHide function of the containing widget. This helps
     * * to avoid problems, especially when using tabs.
     */

    public void unload() {
        unloadMCE(id);
    }
    /**
     * unloadMCE() -
     * @param id - The element's ID
     * JSNI method to implement unloading the MCE editor instance from memory
     */

    protected native void unloadMCE(String id) /*-{
        $wnd.tinyMCE.execCommand('mceFocus', false, id);
        $wnd.tinyMCE.execCommand('mceRemoveControl', false, id);
    }-*/;

    /**
     * updateContent() -
     * Update the internal referenced content. Use this if you programatically change
     * the original text area's content (eg. do a clear)
     * @param id - the ID of the text area that contains the content you wish to copy
    */

    protected native void updateContent(String id) /*-{
        $wnd.tinyMCE.activeEditor = $wnd.tinyMCE.get(id);
        $wnd.tinyMCE.activeEditor.setContent($wnd.document.getElementById(id).value);
    }-*/;

    /**
     * getTextArea() -
     */

    protected native void getTextData(String id) /*-{
        $wnd.tinyMCE.activeEditor = $wnd.tinyMCE.get(id);
        $wnd.tinyMCE.activeEditor.save();
        $wnd.tinyMCE.triggerSave();
    }-*/;

    /**
     * encodeURIComponent() -
     * Wrapper for the native URL encoding methods
     * @param text - the text to encode
     * @return the encoded text      */

    protected native String encodeURIComponent(String text) /*-{
        return encodeURIComponent(text);
    }-*/;

    /**
     * setTextAreaToTinyMCE() -
     * Change a text area to a tiny MCE editing field
     * * @param id - the text area's ID      */

    protected native void setTextAreaToTinyMCE(String id) /*-{
          $wnd.tinyMCE.execCommand('mceAddControl', true, id);
    }-*/;

    /**
     * removeMCE() -
    * Remove a tiny MCE editing field from a text area
    * @param id - the text area's ID
    */

    public native void removeMCE(String id) /*-{
        $wnd.tinyMCE.execCommand('mceRemoveControl', true, id);
     }-*/;



   }

