/*
 * This software is published under the Apchae 2.0 licenses.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Author: Erik Scholtz
 * Web: http://blog.elitecoderz.net
 */

package com.fujitsu.gwt.bewebapp.client.content.text;

import java.util.HashMap;

import com.fujitsu.gwt.bewebapp.client.BeWebApp;
import com.google.gwt.core.client.JsArrayString;
import com.google.gwt.dom.client.Element;
import com.google.gwt.event.dom.client.ChangeEvent;
import com.google.gwt.event.dom.client.ChangeHandler;
import com.google.gwt.event.dom.client.ClickEvent;
import com.google.gwt.event.dom.client.ClickHandler;
import com.google.gwt.event.dom.client.KeyUpEvent;
import com.google.gwt.event.dom.client.KeyUpHandler;
import com.google.gwt.user.client.Window;
import com.google.gwt.user.client.ui.Composite;
import com.google.gwt.user.client.ui.HTML;
import com.google.gwt.user.client.ui.HorizontalPanel;
import com.google.gwt.user.client.ui.Image;
import com.google.gwt.user.client.ui.ListBox;
import com.google.gwt.user.client.ui.PushButton;
import com.google.gwt.user.client.ui.RichTextArea;
import com.google.gwt.user.client.ui.ToggleButton;
import com.google.gwt.user.client.ui.VerticalPanel;
import com.google.gwt.user.client.ui.RichTextArea.Formatter;

public class RichTextToolbar extends Composite {
	/** Local CONSTANTS **/
	//ImageMap and CSS related
	//private static final String HTTP_STATIC_ICONS_GIF = "http://blog.elitecoderz.net/wp-includes/js/tinymce/themes/advanced/img/icons.gif";
	private static  String HTTP_STATIC_ICONS_GIF;
	private static final String CSS_ROOT_NAME = "RichTextToolbar";

	
	public final static HashMap<String,String> GUI_HEADERLIST = new HashMap<String,String>();
	static {
		GUI_HEADERLIST.put("Header1", "Header1");
		GUI_HEADERLIST.put("Header2", "Header2");
		GUI_HEADERLIST.put("Header3", "Header3");
	}
	
	public final static HashMap<String,String> GUI_FONTSIZELIST = new HashMap<String,String>();
    static {
        GUI_FONTSIZELIST.put("X_LARGE", "X_LARGE");
        GUI_FONTSIZELIST.put("LARGE", "LARGE");
        GUI_FONTSIZELIST.put("MEDIUAM", "MEDIUAM");
    }
	

	//HTML Related (styles made by SPAN and DIV)
	private static final String HTML_STYLE_CLOSE_SPAN = "</span>";
	private static final String HTML_STYLE_CLOSE_DIV = "</div>";
	private static final String HTML_STYLE_OPEN_BOLD = "<span style=\"font-weight: bold;\">";
	private static final String HTML_STYLE_OPEN_ITALIC = "<span style=\"font-weight: italic;\">";
	private static final String HTML_STYLE_OPEN_UNDERLINE = "<span style=\"font-weight: underline;\">";
	private static final String HTML_STYLE_OPEN_LINETHROUGH = "<span style=\"font-weight: line-through;\">";
	private static final String HTML_STYLE_OPEN_ALIGNLEFT = "<div style=\"text-align: left;\">";
	private static final String HTML_STYLE_OPEN_ALIGNCENTER = "<div style=\"text-align: center;\">";
	private static final String HTML_STYLE_OPEN_ALIGNRIGHT = "<div style=\"text-align: right;\">";
	private static final String HTML_STYLE_OPEN_INDENTRIGHT = "<div style=\"margin-left: 40px;\">";
	/*
	private static final String HTML_STYLE_OPEN_HEADER1 = "<p><span style=\"font-weight: bold; font-size: 35px;\">";
	private static final String HTML_STYLE_OPEN_HEADER2 = "<p><span style=\"font-weight: bold; font-size: 25px;\">";
	private static final String HTML_STYLE_OPEN_HEADER3 = "<p><span style=\"font-weight: bold; font-size: 20px;\">";
    */
	
	private static final String HTML_STYLE_OPEN_HEADER1 = "<P><STRONG><FONT SIZE=6>";
	private static final String HTML_STYLE_OPEN_HEADER2 = "<P><STRONG><FONT SIZE=5>";
	private static final String HTML_STYLE_OPEN_HEADER3 = "<P><STRONG><FONT SIZE=4>";
	
	
	private static final String HTML_STYLE_OPEN_H1 = "<h1>";
	private static final String HTML_STYLE_OPEN_H2 = "<h2>";
	private static final String HTML_STYLE_OPEN_H3 = "<h3>";
	private static final String HTML_STYLE_OPEN_P = "<p>";
	
	private static final String HTML_STYLE_CLOSE_H1 = "</h1>";
    private static final String HTML_STYLE_CLOSE_H2 = "</h2>";
    private static final String HTML_STYLE_CLOSE_H3 = "</h3>";
    private static final String HTML_STYLE_CLOSE_P = "</p>";
	
		
	//HTML Related (styles made by custom HTML-Tags)
	private static final String HTML_STYLE_OPEN_SUBSCRIPT = "<sub>";
	private static final String HTML_STYLE_CLOSE_SUBSCRIPT = "</sub>";
	private static final String HTML_STYLE_OPEN_SUPERSCRIPT = "<sup>";
	private static final String HTML_STYLE_CLOSE_SUPERSCRIPT = "</sup>";
	private static final String HTML_STYLE_OPEN_ORDERLIST = "<ol><li>";
	private static final String HTML_STYLE_CLOSE_ORDERLIST = "</ol></li>";
	private static final String HTML_STYLE_OPEN_UNORDERLIST = "<ul><li>";
	private static final String HTML_STYLE_CLOSE_UNORDERLIST = "</ul></li>";
	
	//private static final String HTML_STYLE_CLOSE_HEADER = "</span></p>";
	
	private static final String HTML_STYLE_CLOSE_HEADER = "</FONT></STRONG></p>";

	//HTML Related (styles without closing Tag)
	private static final String HTML_STYLE_HLINE = "<hr style=\"width: 100%; height: 2px;\">";

	//GUI Related stuff
	private static final String GUI_DIALOG_INSERTURL = "Enter a link URL:";
	private static final String GUI_DIALOG_IMAGEURL = "Enter an image URL:";

	private static final String GUI_LISTNAME_HEADER = "Header";
	private static final String GUI_LISTNAME_FONTSIZE = "FontSize";

	private static final String GUI_HOVERTEXT_SWITCHVIEW = "Switch View HTML/Source";
	private static final String GUI_HOVERTEXT_REMOVEFORMAT = "Remove Formatting";
	private static final String GUI_HOVERTEXT_IMAGE = "Insert Image";
	private static final String GUI_HOVERTEXT_HLINE = "Insert Horizontal Line";
	private static final String GUI_HOVERTEXT_BREAKLINK = "Break Link";
	private static final String GUI_HOVERTEXT_LINK = "Generate Link";
	private static final String GUI_HOVERTEXT_IDENTLEFT = "Ident Left";
	private static final String GUI_HOVERTEXT_IDENTRIGHT = "Ident Right";
	private static final String GUI_HOVERTEXT_UNORDERLIST = "Unordered List";
	private static final String GUI_HOVERTEXT_ORDERLIST = "Ordered List";
	private static final String GUI_HOVERTEXT_ALIGNRIGHT = "Align Right";
	private static final String GUI_HOVERTEXT_ALIGNCENTER = "Align Center";
	private static final String GUI_HOVERTEXT_ALIGNLEFT = "Align Left";
	private static final String GUI_HOVERTEXT_SUPERSCRIPT = "Superscript";
	private static final String GUI_HOVERTEXT_SUBSCRIPT = "Subscript";
	private static final String GUI_HOVERTEXT_STROKE = "Stroke";
	private static final String GUI_HOVERTEXT_UNDERLINE = "Underline";
	private static final String GUI_HOVERTEXT_ITALIC = "Italic";
	private static final String GUI_HOVERTEXT_BOLD = "Bold";
	
	private static final String GUI_HOVERTEXT_H1 = "Header1";
	private static final String GUI_HOVERTEXT_H2 = "Header2";
	private static final String GUI_HOVERTEXT_H3 = "Header3";
	private static final String GUI_HOVERTEXT_P = "Paragraph";

	/** Private Variables **/
	//The main (Vertical)-Panel and the two inner (Horizontal)-Panels
	private VerticalPanel outer;
	private HorizontalPanel topPanel;
	private HorizontalPanel bottomPanel;

	//The RichTextArea this Toolbar referes to and the Interfaces to access the RichTextArea
	private RichTextArea styleText;
	private Formatter styleTextFormatter;

	//We use an internal class of the ClickHandler and the KeyUpHandler to be private to others with these events
	private EventHandler evHandler;

	//The Buttons of the Menubar
	private ToggleButton bold;
	private ToggleButton italic;
	private ToggleButton underline;
	private ToggleButton stroke;
	private ToggleButton subscript;
	private ToggleButton superscript;
	private PushButton alignleft;
	private PushButton alignmiddle;
	private PushButton alignright;
	private PushButton orderlist;
	private PushButton unorderlist;
	private PushButton indentleft;
	private PushButton indentright;
	private PushButton generatelink;
	private PushButton breaklink;
	private PushButton insertline;
	private PushButton insertimage;
	private PushButton removeformatting;
	private ToggleButton texthtml;
	private PushButton inserth1;
	private PushButton inserth2;
	private PushButton inserth3;
	private PushButton insertp;

	private ListBox headerlist;
	private ListBox fontsizelist;

	/** Constructor of the Toolbar **/
	public RichTextToolbar(RichTextArea richtext) {
		if(HTTP_STATIC_ICONS_GIF == null){
			HTTP_STATIC_ICONS_GIF = BeWebApp.imgroot + "icons.gif";
		}
		//Initialize the main-panel
		outer = new VerticalPanel();

		//Initialize the two inner panels
		topPanel = new HorizontalPanel();
		bottomPanel = new HorizontalPanel();
		topPanel.setStyleName(CSS_ROOT_NAME);
		bottomPanel.setStyleName(CSS_ROOT_NAME);

		//Save the reference to the RichText area we refer to and get the interfaces to the stylings

		styleText = richtext;
		styleTextFormatter = styleText.getFormatter();

		//Set some graphical options, so this toolbar looks how we like it.
		topPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);
		bottomPanel.setHorizontalAlignment(HorizontalPanel.ALIGN_LEFT);

		//Add the two inner panels to the main panel
		outer.add(topPanel);
		outer.add(bottomPanel);

		//Some graphical stuff to the main panel and the initialisation of the new widget
		outer.setWidth("100%");
		outer.setStyleName(CSS_ROOT_NAME);
		initWidget(outer);

		//
		evHandler = new EventHandler();

		//Add KeyUp and Click-Handler to the RichText, so that we can actualize the toolbar if neccessary
		styleText.addKeyUpHandler(evHandler);
		styleText.addClickHandler(evHandler);

		//Now lets fill the new toolbar with life
		buildTools();
	}

	/** Click Handler of the Toolbar **/
	private class EventHandler implements ClickHandler,KeyUpHandler, ChangeHandler {
		public void onClick(ClickEvent event) {
			if (event.getSource().equals(bold)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_BOLD,HTML_STYLE_CLOSE_SPAN);
				} else {
					styleTextFormatter.toggleBold();
				}
			} else if (event.getSource().equals(italic)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_ITALIC,HTML_STYLE_CLOSE_SPAN);
				} else {
					styleTextFormatter.toggleItalic();
				}
			} else if (event.getSource().equals(underline)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_UNDERLINE,HTML_STYLE_CLOSE_SPAN);
				} else {
					styleTextFormatter.toggleUnderline();
				}
			} else if (event.getSource().equals(stroke)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_LINETHROUGH,HTML_STYLE_CLOSE_SPAN);
				} else {
					styleTextFormatter.toggleStrikethrough();
				}
			} else if (event.getSource().equals(subscript)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_SUBSCRIPT,HTML_STYLE_CLOSE_SUBSCRIPT);
				} else {
					styleTextFormatter.toggleSubscript();
				}
			} else if (event.getSource().equals(superscript)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_SUPERSCRIPT,HTML_STYLE_CLOSE_SUPERSCRIPT);
				} else {
					styleTextFormatter.toggleSuperscript();
				}
			} else if (event.getSource().equals(alignleft)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_ALIGNLEFT,HTML_STYLE_CLOSE_DIV);
				} else {
					styleTextFormatter.setJustification(RichTextArea.Justification.LEFT);
				}
			} else if (event.getSource().equals(alignmiddle)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_ALIGNCENTER,HTML_STYLE_CLOSE_DIV);
				} else {
					styleTextFormatter.setJustification(RichTextArea.Justification.CENTER);
				}
			} else if (event.getSource().equals(alignright)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_ALIGNRIGHT,HTML_STYLE_CLOSE_DIV);
				} else {
					styleTextFormatter.setJustification(RichTextArea.Justification.RIGHT);
				}
			} else if (event.getSource().equals(orderlist)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_ORDERLIST,HTML_STYLE_CLOSE_ORDERLIST);
				} else {
					//styleTextFormatter.removeFormat();
					styleTextFormatter.insertOrderedList();
				}
			} else if (event.getSource().equals(unorderlist)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_UNORDERLIST,HTML_STYLE_CLOSE_UNORDERLIST);
				} else {
					//styleTextFormatter.removeFormat();
					styleTextFormatter.insertUnorderedList();
				}
			} else if (event.getSource().equals(indentright)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_OPEN_INDENTRIGHT,HTML_STYLE_CLOSE_DIV);
				} else {
					styleTextFormatter.rightIndent();
				}
			} else if (event.getSource().equals(indentleft)) {
				if (isHTMLMode()) {
					//TODO nothing can be done here at the moment
				} else {
					styleTextFormatter.leftIndent();
				}
			} else if (event.getSource().equals(generatelink)) {
				String url = Window.prompt(GUI_DIALOG_INSERTURL, "http://");
				if (url != null) {
					if (isHTMLMode()) {
						changeHtmlStyle("<a href=\""+url+"\">","</a>");
					} else {
						styleTextFormatter.createLink(url);
					}
				}
			} else if (event.getSource().equals(breaklink)) {
				if (isHTMLMode()) {
					//TODO nothing can be done here at the moment
				} else {
					styleTextFormatter.removeLink();
				}
			} else if (event.getSource().equals(insertimage)) {
				String url = Window.prompt(GUI_DIALOG_IMAGEURL, "http://");
				if (url != null) {
					if (isHTMLMode()) {
						changeHtmlStyle("<img src=\""+url+"\">","");
					} else {
						styleTextFormatter.insertImage(url);
					}
				}
			}  else if (event.getSource().equals(insertline)) {
				if (isHTMLMode()) {
					changeHtmlStyle(HTML_STYLE_HLINE,"");
				} else {
					styleTextFormatter.insertHorizontalRule();
				}
			} else if (event.getSource().equals(removeformatting)) {
				if (isHTMLMode()) {
					//TODO nothing can be done here at the moment
				} else {
					styleTextFormatter.removeFormat();
				}
			} else if (event.getSource().equals(texthtml)) {
				if (texthtml.isDown()) {
					styleText.setText(styleText.getHTML());
					styleText.setEnabled(false);
				} else {
					styleText.setHTML(styleText.getText());
					styleText.setEnabled(true);
				}
			} else if (event.getSource().equals(styleText)) {
				//Change invoked by the richtextArea
			}else if (event.getSource().equals(inserth1)) {
                //Change invoked by the richtextArea
			    //changeHtmlElement(HTML_STYLE_OPEN_H1,HTML_STYLE_CLOSE_H1);
			    styleTextFormatter.setFontSize(RichTextArea.FontSize.LARGE);
            }else if (event.getSource().equals(inserth2)) {
                //Change invoked by the richtextArea
                //changeHtmlElement(HTML_STYLE_OPEN_H2,HTML_STYLE_CLOSE_H2);
                styleTextFormatter.setFontSize(RichTextArea.FontSize.MEDIUM);
            }else if (event.getSource().equals(inserth3)) {
                //Change invoked by the richtextArea
                //changeHtmlElement(HTML_STYLE_OPEN_H3,HTML_STYLE_CLOSE_H3);
                styleTextFormatter.setFontSize(RichTextArea.FontSize.SMALL);
            }else if (event.getSource().equals(insertp)) {
                //Change invoked by the richtextArea
                changeHtmlElement(HTML_STYLE_OPEN_P,HTML_STYLE_CLOSE_P);
            }
			
			updateStatus();
		}

		public void onKeyUp(KeyUpEvent event) {
			updateStatus();
		}

		public void onChange(ChangeEvent event) {
		    if (event.getSource().equals(fontsizelist)) {
		        if (isHTMLMode()) {
		            
		        }else {
                    int indx = fontsizelist.getSelectedIndex();
                    String val = GUI_FONTSIZELIST.get(fontsizelist.getValue(fontsizelist.getSelectedIndex()));
                    if("X_LARGE".equals(val)){
                        styleTextFormatter.setFontSize(RichTextArea.FontSize.X_LARGE);
                    }else if("LARGE".equals(val)){
                        styleTextFormatter.setFontSize(RichTextArea.FontSize.LARGE);
                    }else if("MEDIUM".equals(val)){
                        styleTextFormatter.setFontSize(RichTextArea.FontSize.MEDIUM);
                    }else{
                        styleTextFormatter.setFontSize(RichTextArea.FontSize.MEDIUM);
                    }
		        }
		    }
			if (event.getSource().equals(headerlist)) {
				if (isHTMLMode()) {
					changeHtmlStyle("<span style=\"font-family: "+headerlist.getValue(headerlist.getSelectedIndex())+";\">",HTML_STYLE_CLOSE_SPAN);
				} else {
					int indx = headerlist.getSelectedIndex();
					
					String val = GUI_HEADERLIST.get(headerlist.getValue(headerlist.getSelectedIndex()));
					/*
					if("Header1".equals(val)){
						changeHtml("<H1>", "</H1>");
					}else if("Header2".equals(val)){
						changeHtml("<H2>", "</H2>");
					}else if("Header3".equals(val)){
						changeHtml("<H3>", "</H3>");
					}
					*/
					if("Header1".equals(val)){
						changeHtml(HTML_STYLE_OPEN_HEADER1, HTML_STYLE_CLOSE_HEADER);
					}else if("Header2".equals(val)){
						changeHtml(HTML_STYLE_OPEN_HEADER2, HTML_STYLE_CLOSE_HEADER);
					}else if("Header3".equals(val)){
						changeHtml(HTML_STYLE_OPEN_HEADER3, HTML_STYLE_CLOSE_HEADER);
					}
					
					
				}
			} 
		}
	}

	/** Native JavaScript that returns the selected text and position of the start **/
	public static native JsArrayString getSelection(Element elem) /*-{
		var txt = "";
		var pos = 0;
		var range;
    	var parentElement;
    	var container;

        if (elem.contentWindow.getSelection) {
        	txt = elem.contentWindow.getSelection();
        	pos = elem.contentWindow.getSelection().getRangeAt(0).startOffset;
        } else if (elem.contentWindow.document.getSelection) {
        	txt = elem.contentWindow.document.getSelection();
        	pos = elem.contentWindow.document.getSelection().getRangeAt(0).startOffset;
  		} else if (elem.contentWindow.document.selection) {
  			range = elem.contentWindow.document.selection.createRange();
        	txt = range.text;
        	parentElement = range.parentElement();
        	container = range.duplicate();
        	container.moveToElementText(parentElement);
        	container.setEndPoint('EndToEnd', range);
        	pos = container.text.length - range.text.length;
        }
  		return [""+txt,""+pos];
	}-*/;

	/** Method called to toggle the style in HTML-Mode **/
/*
	private void changeHtmlStyle(String startTag, String stopTag) {
		JsArrayString tx = getSelection(styleText.getElement());
		String txbuffer = styleText.getText();
		Integer startpos = Integer.parseInt(tx.get(1));
		String selectedText = tx.get(0);
		styleText.setText(txbuffer.substring(0, startpos)+startTag+selectedText+stopTag+txbuffer.substring(startpos+selectedText.length()));
	}
*/
	private void changeHtmlStyle(String startTag, String stopTag) {
	}
	
	private void changeHtml(String startTag, String stopTag){
		styleTextFormatter.removeFormat();
		JsArrayString tx = getSelection(styleText.getElement());
		Integer startpos = Integer.parseInt(tx.get(1));
		String selectedText = startTag + tx.get(0)+ stopTag;
		
		styleTextFormatter.insertHTML(selectedText);
	}
	/*
	private void changeHtmlElement(String startTag, String stopTag){
	    styleText.setText(styleText.getHTML());
	    JsArrayString tx = getSelection(styleText.getElement());
        String txbuffer = styleText.getText();
        Integer startpos = Integer.parseInt(tx.get(1));
        String selectedText = tx.get(0);
        //styleText.setText(styleText.getHTML());
        styleText.setText(txbuffer.substring(0, startpos)+startTag+selectedText+stopTag+txbuffer.substring(startpos+selectedText.length()));
        styleText.setHTML(styleText.getText());
        //styleTextFormatter.insertHTML(txbuffer.substring(0, startpos)+startTag+selectedText+stopTag+txbuffer.substring(startpos+selectedText.length()));
	}
	*/
	

	private void changeHtmlElement(String startTag, String stopTag){
	    JsArrayString tx = getSelection(styleText.getElement());
	    if(tx.get(0).length() == 0){
	        Window.alert("Please select a text to change style before using this button.");
	        return;
	    }
        Integer startpos = Integer.parseInt(tx.get(1));
        String selectedText = startTag + tx.get(0)+ stopTag;
        
        styleTextFormatter.insertHTML(selectedText);
    }

	
	private void changeHtm(String startTag, String stopTag){
		styleTextFormatter.removeFormat();
		JsArrayString tx = getSelection(styleText.getElement());
		String txbuffer = styleText.getHTML();
		Window.alert("txbuffer:" + txbuffer);
		Integer startpos = Integer.parseInt(tx.get(1));
		String selectedText = tx.get(0);
		styleText.setHTML(txbuffer.substring(0, startpos)+startTag+selectedText+stopTag+txbuffer.substring(startpos+selectedText.length()));
	}
	
	private void removeHeader(){
		JsArrayString tx = getSelection(styleText.getElement());
		String txbuffer = styleText.getText();
		
	}
	/** Private method with a more understandable name to get if HTML mode is on or not **/
	public Boolean isHTMLMode() {
		return  texthtml.isDown();
	}

	/** Private method to set the toggle buttons and disable/enable buttons which do not work in html-mode **/
	private void updateStatus() {
		if (styleTextFormatter != null) {
			bold.setDown(styleTextFormatter.isBold());
			italic.setDown(styleTextFormatter.isItalic());
			underline.setDown(styleTextFormatter.isUnderlined());
			subscript.setDown(styleTextFormatter.isSubscript());
			superscript.setDown(styleTextFormatter.isSuperscript());
			stroke.setDown(styleTextFormatter.isStrikethrough());
		}

		if (isHTMLMode()) {
			bold.setEnabled(false);
			italic.setEnabled(false);
			underline.setEnabled(false);
			stroke.setEnabled(false);
			subscript.setEnabled(false);
			superscript.setEnabled(false);
			alignleft.setEnabled(false);
			alignmiddle.setEnabled(false);
			alignright.setEnabled(false);
			orderlist.setEnabled(false);
			unorderlist.setEnabled(false);
			indentleft.setEnabled(false);
			indentright.setEnabled(false);
			generatelink.setEnabled(false);
			breaklink.setEnabled(false);
			insertline.setEnabled(false);
			insertimage.setEnabled(false);
			removeformatting.setEnabled(false);
			headerlist.setEnabled(false);
			inserth1.setEnabled(false);
			inserth2.setEnabled(false);
			inserth3.setEnabled(false);
			insertp.setEnabled(false);
			fontsizelist.setEnabled(false);
			
		} else {
			bold.setEnabled(true);
			italic.setEnabled(true);
			underline.setEnabled(true);
			stroke.setEnabled(true);
			subscript.setEnabled(true);
			superscript.setEnabled(true);
			alignleft.setEnabled(true);
			alignmiddle.setEnabled(true);
			alignright.setEnabled(true);
			orderlist.setEnabled(true);
			unorderlist.setEnabled(true);
			indentleft.setEnabled(true);
			indentright.setEnabled(true);
			generatelink.setEnabled(true);
			breaklink.setEnabled(true);
			insertline.setEnabled(true);
			insertimage.setEnabled(true);
			removeformatting.setEnabled(true);
			headerlist.setEnabled(true);
			fontsizelist.setEnabled(true);
		}
	}

	/** Initialize the options on the toolbar **/
	private void buildTools() {
		//Init the TOP Panel forst
		topPanel.add(bold = createToggleButton(HTTP_STATIC_ICONS_GIF,0,0,20,20,GUI_HOVERTEXT_BOLD));
		topPanel.add(italic = createToggleButton(HTTP_STATIC_ICONS_GIF,0,60,20,20,GUI_HOVERTEXT_ITALIC));
		//topPanel.add(underline = createToggleButton(HTTP_STATIC_ICONS_GIF,0,140,20,20,GUI_HOVERTEXT_UNDERLINE));
		//topPanel.add(stroke = createToggleButton(HTTP_STATIC_ICONS_GIF,0,120,20,20,GUI_HOVERTEXT_STROKE));
		topPanel.add(new HTML("&nbsp;"));
		//topPanel.add(subscript = createToggleButton(HTTP_STATIC_ICONS_GIF,0,600,20,20,GUI_HOVERTEXT_SUBSCRIPT));
		//topPanel.add(superscript = createToggleButton(HTTP_STATIC_ICONS_GIF,0,620,20,20,GUI_HOVERTEXT_SUPERSCRIPT));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(alignleft = createPushButton(HTTP_STATIC_ICONS_GIF,0,460,20,20,GUI_HOVERTEXT_ALIGNLEFT));
		topPanel.add(alignmiddle = createPushButton(HTTP_STATIC_ICONS_GIF,0,420,20,20,GUI_HOVERTEXT_ALIGNCENTER));
		topPanel.add(alignright = createPushButton(HTTP_STATIC_ICONS_GIF,0,480,20,20,GUI_HOVERTEXT_ALIGNRIGHT));
		//topPanel.add(headerlist = createHeaderList());
		topPanel.add(fontsizelist = createFontSizeList());
		//topPanel.add(new HTML("&nbsp;"));
		//topPanel.add(inserth1 = createTextPushButton("HI",20,20, GUI_HOVERTEXT_H1));
		//topPanel.add(inserth2 = createTextPushButton("H2",20,20, GUI_HOVERTEXT_H2));
		//topPanel.add(inserth3 = createTextPushButton("H3",20,20, GUI_HOVERTEXT_H3));
		//topPanel.add(insertp = createTextPushButton("P",20,20, GUI_HOVERTEXT_P));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(orderlist = createPushButton(HTTP_STATIC_ICONS_GIF,0,80,20,20,GUI_HOVERTEXT_ORDERLIST));
		topPanel.add(unorderlist = createPushButton(HTTP_STATIC_ICONS_GIF,0,20,20,20,GUI_HOVERTEXT_UNORDERLIST));
		topPanel.add(indentright = createPushButton(HTTP_STATIC_ICONS_GIF,0,400,20,20,GUI_HOVERTEXT_IDENTRIGHT));
		topPanel.add(indentleft = createPushButton(HTTP_STATIC_ICONS_GIF,0,540,20,20,GUI_HOVERTEXT_IDENTLEFT));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(generatelink = createPushButton(HTTP_STATIC_ICONS_GIF,0,500,20,20,GUI_HOVERTEXT_LINK));
		topPanel.add(breaklink = createPushButton(HTTP_STATIC_ICONS_GIF,0,640,20,20,GUI_HOVERTEXT_BREAKLINK));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(insertline = createPushButton(HTTP_STATIC_ICONS_GIF,0,360,20,20,GUI_HOVERTEXT_HLINE));
		topPanel.add(insertimage = createPushButton(HTTP_STATIC_ICONS_GIF,0,380,20,20,GUI_HOVERTEXT_IMAGE));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(removeformatting = createPushButton(HTTP_STATIC_ICONS_GIF,20,460,20,20,GUI_HOVERTEXT_REMOVEFORMAT));
		topPanel.add(new HTML("&nbsp;"));
		topPanel.add(texthtml = createToggleButton(HTTP_STATIC_ICONS_GIF,0,260,20,20,GUI_HOVERTEXT_SWITCHVIEW));

		//Init the BOTTOM Panel
		//bottomPanel.add(fontlist = createFontList());
		//bottomPanel.add(headerlist = createHeaderList());
		//bottomPanel.add(headerlist = createHeaderList());
		//bottomPanel.add(fontsizelist = createFontSizeList());
	}

	/** Method to create a Toggle button for the toolbar **/
	private ToggleButton createToggleButton(String url, Integer top, Integer left, Integer width, Integer height, String tip) {
		Image extract = new Image(url, left, top, width, height);
		ToggleButton tb = new ToggleButton(extract);
		tb.setHeight(height+"px");
		tb.setWidth(width+"px");
		tb.addClickHandler(evHandler);
		if (tip != null) {
			tb.setTitle(tip);
		}
		return tb;
	}

	/** Method to create a Push button for the toolbar **/
	private PushButton createPushButton(String url, Integer top, Integer left, Integer width, Integer height, String tip) {
		Image extract = new Image(url, left, top, width, height);
		PushButton tb = new PushButton(extract);
		tb.setHeight(height+"px");
		tb.setWidth(width+"px");
		tb.addClickHandler(evHandler);
		if (tip != null) {
			tb.setTitle(tip);
		}
		return tb;
	}
	
	private PushButton createTextPushButton(String btext, Integer width, Integer height, String tip) {
        PushButton tb = new PushButton(btext);
        tb.setHeight(height+"px");
        tb.setWidth(width+"px");
        tb.addClickHandler(evHandler);
        if (tip != null) {
            tb.setTitle(tip);
        }
        return tb;
    }

	/** Method to create the HeaderList for the toolbar **/
	private ListBox createHeaderList() {
	    ListBox mylistBox = new ListBox();
	    mylistBox.addChangeHandler(evHandler);
	    mylistBox.setVisibleItemCount(1);
	    mylistBox.setStyleName("text-ListBox");

	    mylistBox.addItem(GUI_LISTNAME_HEADER);
	    for (String name: GUI_HEADERLIST.keySet()) {
	    	mylistBox.addItem(name, GUI_HEADERLIST.get(name));
	    }

	    return mylistBox;
	}
	
	/** Method to create the HeaderList for the toolbar **/
    private ListBox createFontSizeList() {
        ListBox mylistBox = new ListBox();
        mylistBox.addChangeHandler(evHandler);
        mylistBox.setVisibleItemCount(1);
        mylistBox.setStyleName("text-ListBox");

        mylistBox.addItem(GUI_LISTNAME_FONTSIZE);
        for (String name: GUI_FONTSIZELIST.keySet()) {
            mylistBox.addItem(name, GUI_FONTSIZELIST.get(name));
        }

        return mylistBox;
    }
}


