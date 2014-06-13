/*
 * Copyright 2013 Keith D Swenson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Contributors Include: Shamim Quader, Sameer Pradhan, Kumar Raja, Jim Farris,
 * Sandia Yang, CY Chen, Rajiv Onat, Neal Wang, Dennis Tam, Shikha Srivastava,
 * Anamika Chaudhari, Ajay Kakkar, Rajeev Rastogi
 */

package org.socialbiz.cog;

import java.net.URLEncoder;

/**
 * This is a sub class of WikiConverter that handles the HTML to WIKI conversion
 * for new Editor.
 *
 * Because of threading issues, a new instance should be created on every
 * thread.  This is done for you by using writeWikiAsHtml method for conversion.
 * Constructor is private, so use writeWikiAsHtml instead.
 */
public class WikiConverterForWYSIWYG extends WikiConverter
{
    /**
    * Don't construct.  Just use writeWikiAsHtml instead.
    */
    private WikiConverterForWYSIWYG(AuthRequest destination)
    {
        super( destination );
    }

    /**
    * Static version create the object instance and then calls the
    * converter directly.   Convenience for the case where you are
    * going to use a converter only once, and only for HTML output.
    */
    public static void writeWikiAsHtml(AuthRequest destination, String tv) throws Exception
    {
        WikiConverterForWYSIWYG wc = new WikiConverterForWYSIWYG(destination);
        wc.writeWikiAsHtml(tv);
    }


    public void outputProperLink(String linkURL)
        throws Exception
    {
        int barPos = linkURL.indexOf("|");
        String linkName = linkURL.trim();
        String linkAddr = null;

        if (barPos >= 0)
        {
            linkName = linkURL.substring(0,barPos).trim();
            linkAddr = linkURL.substring(barPos+1).trim();
        }
        else
        {
            //for the WYSIWYG editors, we encode the project name into the link so that
            //the editor does not get confused by an empty link
            linkAddr = URLEncoder.encode(linkName, "UTF8");
        }

        ar.write("<a href=\"");
        ar.writeHtml(linkAddr);
        ar.write("\">");
        ar.writeHtml(linkName);
        ar.write("</a>");
    }

    protected void makeLineBreak()
        throws Exception
    {
        ar.write("<br>");
    }

    protected void makeHorizontalRule()
        throws Exception
    {
        ar.write("<hr>");
    }

    /**
    * Currently tags are output to the editor simply as text that can be
    * edited, and not as a hyperlink.   Later, we might have
    * some special coding to allow for a nice tag editor.
    */
    protected void outputTagLink(String tagName)
        throws Exception
    {
        ar.write("#");
        ar.writeURLData(tagName);
    }

}
