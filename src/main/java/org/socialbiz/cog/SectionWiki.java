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

import java.io.Writer;
import java.util.Vector;

import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.socialbiz.cog.exception.ProgramLogicError;

/**
 * Implements the Wiki formatting
 */
public class SectionWiki extends SectionUtil implements SectionFormat {

    public SectionWiki() {

    }

    public String getName() {
        return "Wiki Format";
    }

    public void findLinks(Vector<String> v, NGSection section) throws Exception {
        LineIterator li = new LineIterator(section.asText().trim());
        while (li.moreLines())
        {
            String thisLine = li.nextLine();
            scanLineForLinks(thisLine, v);
        }
    }

    protected void scanLineForLinks(String thisLine, Vector<String> v) {
        int bracketPos = thisLine.indexOf('[');
        int startPos = 0;
        while (bracketPos >= startPos) {
            int endPos = thisLine.indexOf(']', bracketPos);
            if (endPos <= startPos) {
                return; // could not find any more closing brackets, leave
            }
            String link = thisLine.substring(bracketPos + 1, endPos);
            v.add(link);
            startPos = endPos + 1;
            bracketPos = thisLine.indexOf('[', startPos);
        }
    }

    //TODO: should take an AuthRequest, and WikiConverter
    public void writePlainText(NGSection section, Writer out) throws Exception {

        if (section == null || out == null) {
            return;
        }

        LineIterator li = new LineIterator(section.asText().trim());
        while (li.moreLines()) {
            String thisLine = li.nextLine();
            removeWikiFormattings(out, thisLine);
            out.write(" ");
        }
    }

    //TODO: should take an AuthRequest, and WikiConverter
    private void removeWikiFormattings(Writer out, String line)
            throws Exception {
        if (line == null || ((line = line.trim()).length()) == 0) {
            return;
        }

        if (line.startsWith("----")) {
            line = subString(line, 4);
        } else if (line.startsWith("!!!") || (line.startsWith("***"))) {
            line = subString(line, 3);
        } else if (line.startsWith("!!") || (line.startsWith("**"))) {
            line = subString(line, 2);
        } else if (line.startsWith("!") || (line.startsWith("*"))) {
            line = subString(line, 1);
        }
        writeTextWithLB(line, out);
    }

    //TODO: should take an AuthRequest, and WikiConverter
    private String subString(String line, int length) {
        if (line == null) {
            return "";
        }

        if (line.length() > length) {
            return line.substring(length);
        }
        return "";
    }

    // this method is used for Section comments and for private sections.
    public void writePlainTextForComments(NGSection section, Writer out)
            throws Exception {

        if (section == null || out == null) {
            return;
        }

        Element secElem = section.getElement();
        NodeList nl = DOMUtils.findNodesOneLevel(secElem,
                SectionComments.LEAFLET_NODE_NAME);

        for (int i = 0; i < nl.getLength(); i++) {
            Element ei = (Element) nl.item(i);
            String owner = DOMUtils.getChildText(ei,
                    SectionComments.OWNER_NODE_NAME);
            SectionUtil.writeTextWithLB(owner, out);

            String cTime = DOMUtils.getChildText(ei,
                    SectionComments.CREATE_NODE_NAME);
            SectionUtil.writeTextWithLB(cTime, out);

            String subject = DOMUtils.getChildText(ei,
                    SectionComments.SUBJECT_NODE_NAME);
            SectionUtil.writeTextWithLB(subject, out);

            String tv = DOMUtils.getChildText(ei,
                    SectionComments.DATA_NODE_NAME).trim();
            LineIterator li = new LineIterator(tv);
            while (li.moreLines()) {
                String thisLine = li.nextLine();
                removeWikiFormattings(out, thisLine);
                out.write(" ");
            }
        }
    }

    /**
     * get the text and return whether there is any non-white-space
     */
    public boolean isEmpty(NGSection section) throws Exception {
        String sectionValue = section.asText().trim();
        return (sectionValue.length() == 0);
    }

    // returns true so that this type gets migrated to a wiki tag.
    public boolean isJustText() {
        return true;
    }


    /**
    * Converts a Wiki section to a note, copying appropriate information
    * from the wiki section to the note.  The idea is that all (displayable)
    * sections will become notes in the future.
    * This might be called just before deleting the section.
    * Returns NULL if the section is empty.
    */
    public NoteRecord convertToLeaflet(NGSection noteSection,
                   NGSection wikiSection) throws Exception
    {
        SectionDef def = wikiSection.def;
        SectionFormat sf = def.format;
        if (sf != this)
        {
            throw new ProgramLogicError("Method convertToLeaflet must be called on the format object for the section being converted");
        }
        String data = wikiSection.asText();
        if (data==null || data.length()==0)
        {
            //this section is empty, so don't create any leaflet, and return null
            return null;
        }
        NoteRecord newNote = noteSection.createChildWithID(
            SectionComments.LEAFLET_NODE_NAME, NoteRecord.class, "id", IdGenerator.generateKey());
        newNote.setOwner(wikiSection.getLastModifyUser());
        newNote.setLastEditedBy(wikiSection.getLastModifyUser());
        newNote.setLastEdited(wikiSection.getLastModifyTime());
        newNote.setEffectiveDate(wikiSection.getLastModifyTime());
        newNote.setSubject(def.displayName + " - " + wikiSection.parent.getFullName());
        newNote.setData(data);
        newNote.setVisibility(def.viewAccess);
        newNote.setEditable(NoteRecord.EDIT_MEMBER);
        return newNote;
    }

}
