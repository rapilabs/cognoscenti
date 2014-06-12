package com.fujitsu.gwt.bewebapp.client.content.text;

import com.google.gwt.dom.client.Document;
import com.google.gwt.dom.client.Element;
import com.google.gwt.user.client.ui.TextBoxBase;

/* Usage: 
 * SuggestBox(oracle, new MultipleTextBox());
 */

public class MultiTextBox extends TextBoxBase {
	/**
	 * Creates an empty multiple text box.
	 */
	public MultiTextBox() {
		this(Document.get().createTextInputElement(), "gwt-TextBox");
	}

	protected MultiTextBox(Element element, String styleName) {
		super(element);
		if (styleName != null) {
			setStyleName(styleName);
		}
	}

	@Override
	public String getText() {
		String wholeString = super.getText();
		System.out.println("Super:" + wholeString);
		String lastString = wholeString;
		if (wholeString != null && !wholeString.trim().equals("")) {
			int lastComma = wholeString.trim().lastIndexOf(",");
			if (lastComma > 0) {
				lastString = wholeString.trim().substring(lastComma + 1);
			}
		}
		System.out.println("lastString:" + lastString);
		return lastString;
	}

	@Override
	public void setText(String text) {
		String wholeString = super.getText();
		if (text != null && text.equals("")) {
			super.setText(text);
		} else {
			if (wholeString != null) {
				int lastComma = wholeString.trim().lastIndexOf(",");
				if (lastComma > 0) {
					wholeString = wholeString.trim().substring(0, lastComma);
				} else {
					wholeString = "";
				}

				if (!wholeString.trim().endsWith(",")
						&& !wholeString.trim().equals("")) {
					wholeString = wholeString + ", ";
				}

				wholeString = wholeString + text + ", ";
				super.setText(wholeString);
			}
		}
	}
	
	public String getAllText(){
		return super.getText();
	}
}