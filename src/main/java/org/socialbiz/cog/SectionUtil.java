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

import org.socialbiz.cog.exception.ProgramLogicError;
import java.io.StringWriter;
import java.io.Writer;

import java.net.URLEncoder;

import java.util.Vector;
import java.util.Calendar;

/**
* Base class of the section classes, contains a number of
* utilities that are convenient for all sections, but this
* class does not in itself represent anything.
*/
public class SectionUtil
{

    public SectionUtil()
    {
       //not necessary to initialize anything
    }

    /**
    * outputLink does the job of parsing the "wiki link" value and
    * producing a valid HTML link to the desire thing.
    * Wiki Link values may have a vertical bar character separating the
    * display name of the link from the address.  If that vertical bar is
    * not there, then the entire thing is taken as an address.
    *
    * Either    [ link-name | link-address ]
    * or        [ link-address ]
    *
    * The address can either be the name of another page, or an HTTP hyperlink.
    * If the address is missing or invalid (no page can be named that)
    * then the display name is written without being a hyper link.
    * If the address is to an external page, then a normal hyperlink is made.
    * If the address is the name of a wiki page, then a hyperlink to that
    * page is made.  If the address is a valid name, but no page exists
    * with that name, then a link to the "CreatePage" function is created.
    *
    * The name part of the link
    */
    public static void outputLink(AuthRequest ar, String linkURL)
        throws Exception
    {
        boolean isImage = linkURL.startsWith("IMG:");

        int barPos = linkURL.indexOf("|");
        String linkName = linkURL.trim();
        String linkAddr = linkName;
        boolean userSpecifiedName = false;

        if (barPos >= 0)
        {
            linkName = linkURL.substring(0,barPos).trim();
            linkAddr = linkURL.substring(barPos+1).trim();
            userSpecifiedName = true;
        }

        // We treat any address that has forward slashes in it as an external
        // address which is included literally into the href.
        boolean isExternal = (linkAddr.startsWith("http") && linkAddr.indexOf("/")>=0);
        boolean pageExists = true;
        String specialGraphic = null;
        String target = null;
        String titleValue = linkURL;
        if (isExternal) {
            target = "_blank";
            titleValue = "This link leads to an external page";
        }

        //if the link is missing, then just write the name out
        //might also include an indicator of the problem ....
        if (linkAddr.length()==0)
        {
            ar.writeHtml(linkName);
            return;
        }

        if (!isExternal)
        {
            //if the sanitized version of the link is empty, which might happen if
            //the link was all punctuation, then just write the name out
            //might also include an indicator of the problem ....
            String sanitizedName = SectionWiki.sanitize(linkAddr);
            if (sanitizedName.length()==0)
            {
                ar.writeHtml(linkName);
                return;
            }

            Vector<NGPageIndex> foundPages = NGPageIndex.getPageIndexByName(linkAddr);
            if (foundPages.size()==1)
            {
                NGPageIndex foundPI = foundPages.firstElement();
                linkAddr = ar.baseURL + ar.getResourceURL(foundPI,"public.htm");
                if (!userSpecifiedName)
                {
                    linkName = foundPI.containerName;   //use the best name for page
                }
                titleValue = "Navigate to the project: "+linkName;
                pageExists = !foundPI.isDeleted;
                specialGraphic = "deletedLink.gif";
            }
            else if (foundPages.size()==0)
            {
                pageExists = false;
                specialGraphic = "createicon.gif";
                NGPage sourcePage = (NGPage)ar.ngp;
                String bookName = "mainbook";
                String sourceName = "main";
                if (sourcePage!=null)
                {
                    sourceName = sourcePage.getFullName();
                    NGBook ngb = sourcePage.getSite();
                    if (ngb!=null)
                    {
                        bookName = ngb.getKey();
                    }
                }
                titleValue = "Project does not exist, but click here to create one.";

                if(ar.isNewUI() && ar.isLoggedIn() ){
                    linkAddr = "javascript:brokenLink("+isImage+",'"+linkName+"','"+linkAddr+"')";
                }else{
                    linkAddr = ar.retPath + "CreatePage.jsp?pt="+encodeURLData(linkAddr)
                                          +"&b="+encodeURLData(bookName)
                                          +"&s="+encodeURLData(sourceName);
                }
            }
            else
            {
                //this is the case where there is more than one page
                linkAddr = ar.retPath + "Disambiguate.jsp?n="+encodeURLData(linkAddr);
                titleValue = "There is more than one project named "+linkAddr;

            }
        }
        if (isImage)
        {
            linkName = linkName.substring(4);
            if (pageExists)
            {
                ar.write("<a href=\"");
                ar.writeHtml(linkAddr);
                ar.write("\" title=\"");
                ar.writeHtml(titleValue);
                ar.write("\">");
                ar.write("<img src=\"");
                ar.writeHtml(linkName);
                ar.write("\"/>");
                ar.write("</a>");
            }
            else
            {
                ar.write("<img src=\"");
                ar.writeHtml(linkName);
                ar.write("\"/>");
            }
        }
        else   //not an image
        {
            if (pageExists)
            {
                ar.write("<a href=\"");
                ar.writeHtml(linkAddr);
                ar.write("\" title=\"");
                ar.writeHtml(titleValue);
                if (target!=null) {
                    ar.write("\" target=\"");
                    ar.writeHtml(target);
                }
                ar.write("\">");
                ar.writeHtml(linkName);
                ar.write("</a>");
            }
            else if (!ar.isLoggedIn() || ar.isStaticSite())
            {
                //if page does not exist, and you are not logged in, then simply display
                //the name without making it a link.  Anonymous people will only see
                //links (within the wiki) that work.
                ar.writeHtml(linkName);
            }
            else
            {
                ar.write("<a href=\"");
                ar.writeHtml(linkAddr);
                ar.write("\" title=\"");
                ar.writeHtml(titleValue);
                ar.write("\">");
                ar.writeHtml(linkName);
                //the icon indicates condition of page
                ar.write("<img src=\"");
                ar.write(ar.retPath);
                ar.write(specialGraphic);
                ar.write("\"/>");
                ar.write("</a>");
            }
        }

    }


    public static String sanitize(String source)
    {
        StringBuffer result = new StringBuffer();
        int last = source.length();
        for (int i=0; i<last; i++) {
            char ch = source.charAt(i);
            if (ch >= 'a' && ch <= 'z') {
                result.append(ch);
            }
            else if (ch >= '0' && ch <= '9') {
                result.append(ch);
            }
            else if (ch >= 'A' && ch <= 'Z') {
                result.append((char) (ch + 32));
            }
            else if (ch == '_') {
                result.append(ch);
            }
            else if (ch == '-') {
                result.append(ch);
            }
        }
        return result.toString();
    }



    public static String encodeURLData(String in)
        throws Exception
    {
        // avoid NPE.
        if (in == null || in.length() == 0) {
            return "";
        }

        String encoded = URLEncoder.encode(in, "UTF-8");

        //here is the problem: URL encoding says that spaces can be encoded using
        //a plus (+) character.  But, strangely, sometimes this does not work, either
        //in certain combinations of browser / tomcat version, using the plus as a
        //space character does not WORK because the plus is not removed by Tomcat
        //on the other side.
        //
        //Strangely, %20 will work, so we replace all occurrances of plus with %20.
        //
        //I am not sure where the problem is, but if you see a URL with plus symbols
        //in mozilla, and the same URL with %20, they look different.  The %20 is
        //replaced with spaces in the status bar, but the plus is not.
        //
        int plusPos = encoded.indexOf("+");
        if (plusPos<0)
        {
            return encoded;
        }

        //might be faster to just write the URL conversion in the first place
        int startPos = 0;
        StringBuffer res = new StringBuffer();
        while (plusPos>=startPos)
        {
            if (plusPos>startPos)
            {
                res.append(encoded.substring(startPos, plusPos));
            }
            res.append("%20");
            startPos = plusPos+1;
            plusPos = encoded.indexOf("+", startPos);
        }
        if (startPos<encoded.length())
        {
            res.append(encoded.substring(startPos));
        }
        return res.toString();
    }

    /**
    * OpenID is a bit ugly on the page.
    * This clean them up a bit for display, but removing the
    * http and the closing slash.
    */
    static private void appendCleanName(StringBuffer res, String uopenid)
    {
        String shortName = UserManager.getShortNameByUserId(uopenid);
        if (shortName!=null && shortName.indexOf('/')==-1)
        {
            res.append(shortName);
            return;
        }
        int len = uopenid.length();
        if (uopenid.endsWith("/"))
        {
            len--;
        }
        int startPos = 0;
        if (uopenid.startsWith("http://"))
        {
            startPos = 7;
        }
        if (uopenid.startsWith("https://"))
        {
            startPos = 8;
        }

        //strip all but alphanums out, and replace with spaces
        for (int i=startPos; i<len; i++)
        {
            char ch = uopenid.charAt(i);
            if ( (ch>='0' && ch<='9') ||
                 (ch>='a' && ch<='z') ||
                 (ch>='A' && ch<='Z'))
            {
                res.append(ch);
            }
            else
            {
                res.append(" ");
            }
        }
    }


    static public String cleanName(String uopenid)
    {
        StringBuffer res = new StringBuffer();
        appendCleanName(res, uopenid);
        return res.toString();
    }



    /**
    * Print out the amount of time that has passed between that time and
    * the time that is passed as the "current time".  The great thing about
    * this approach is that since it is relative, it works in all time zones.
    *
    * There is one place where values can be sorted by this value, and to
    * make that work out correctly, we will prepend spaces to the values.
    * Those space characters will not be seen in the HTML, but will still
    * cause the values to sort with minnutes before hours before days.
    *
    * Days: spaces padded to make it three digits
    * Hours: spaces to pad to five digits
    * Minutes: spaces to pad to seven digits
    * Seconds: spaces to pad to nine digits
    * a moment ago: nine spaces before
    */
    public static void nicePrintTime(AuthRequest ar, long timestamp, long currentTime)
        throws Exception
    {
        if (ar.isStaticSite())
        {
            nicePrintDate(ar.w, timestamp);
        }
        else
        {
            nicePrintTime(ar.w, timestamp, currentTime);
        }
    }


    public static void nicePrintTime(Writer out, long timestamp, long currentTime)
        throws Exception
    {
        if (timestamp==0)
        {
            //null value, don't write anything
            return;
        }
        long diff = (currentTime - timestamp)/1000;
        if (timestamp>currentTime)
        {
            out.write("Future");
            return;
        }
        if (diff < 3)
        {
            out.write("          a moment ago");
            return;
        }
        if (diff < 90)
        {
            writePadded(out, 10, Long.toString(diff));
            out.write(" seconds ago.");
            return;
        }
        diff = diff/60;
        if (diff < 90)
        {
            writePadded(out, 8, Long.toString(diff));
            out.write(" minutes ago.");
            return;
        }
        diff = diff/60;
        if (diff < 36)
        {
            writePadded(out, 6, Long.toString(diff));
            out.write(" hours ago.");
            return;
        }
        diff = diff/24;
        if (diff < 14)
        {
            writePadded(out, 4, Long.toString(diff));
            out.write(" days ago.");
            return;
        }
        //old than that, just print the date out
        nicePrintDate(out, timestamp);
    }


    public static void writePadded(Writer out, int desiredLen, String value)
        throws Exception
    {
        int len = desiredLen - value.length();
        while (len > 0)
        {
            len--;
            out.write(" ");
        }
        out.write(value);
    }

    public static String getNicePrintTime(long timestamp, long currentTime)
        throws Exception
    {
        StringWriter out = new StringWriter();
        nicePrintTime(out, timestamp, currentTime);
        return out.toString();
    }



    /**
    * format is MM/DD/YYYY
    */
    public static void nicePrintDate(Writer out, long timestamp)
        throws Exception
    {
        if (timestamp==0)
        {
            //special null value
            out.write(" ");
            return;
        }
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(timestamp);
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int month = cal.get(Calendar.MONTH);
        int year = cal.get(Calendar.YEAR);

        write2Digits(out, month+1);
        out.write("/");
        write2Digits(out, day);
        out.write("/");
        write4Digits(out, year);
    }

    /**
    * format is MM/DD/YYYY hh:mm:ss
    */
    public static void nicePrintDateAndTime(Writer out, long timestamp)
        throws Exception
    {
        if (timestamp==0)
        {
            //special null value
            out.write(" ");
            return;
        }
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(timestamp);
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int month = cal.get(Calendar.MONTH);
        int year = cal.get(Calendar.YEAR);
        int hours = cal.get(Calendar.HOUR_OF_DAY);
        int mins = cal.get(Calendar.MINUTE);
        int secs = cal.get(Calendar.SECOND);

        write2Digits(out, month+1);
        out.write("/");
        write2Digits(out, day);
        out.write("/");
        write4Digits(out, year);
        out.write(" ");
        write2Digits(out, hours);
        out.write(":");
        write2Digits(out, mins);
        out.write(":");
        write2Digits(out, secs);
    }

    /**
    * format is YYYY/MM/DD hh:mm:ss
    */
    public static void nicePrintTimestamp(Writer out, long timestamp)
        throws Exception
    {
        if (timestamp==0)
        {
            //special null value
            out.write(" ");
            return;
        }
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(timestamp);
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int month = cal.get(Calendar.MONTH);
        int year = cal.get(Calendar.YEAR);
        int hours = cal.get(Calendar.HOUR_OF_DAY);
        int mins = cal.get(Calendar.MINUTE);
        int secs = cal.get(Calendar.SECOND);

        write4Digits(out, year);
        out.write("/");
        write2Digits(out, month+1);
        out.write("/");
        write2Digits(out, day);
        out.write(" ");
        write2Digits(out, hours);
        out.write(":");
        write2Digits(out, mins);
        out.write(":");
        write2Digits(out, secs);
    }

    /** write the last two digits of this number */
    public static void write2Digits(Writer out, int value) throws Exception
    {
        out.write( (char) ('0'+  ((value/10) % 10)));
        out.write( (char) ('0'+  (value % 10)));
    }

    /** write the last four digits of this number */
    public static void write4Digits(Writer out, int value) throws Exception
    {
        //i am assuming that divide is so fast we don't need to be concerned about optimizing
        out.write( (char) ('0'+  ((value/1000) % 10)));
        out.write( (char) ('0'+  ((value/100) % 10)));
        out.write( (char) ('0'+  ((value/10) % 10)));
        out.write( (char) ('0'+  (value % 10)));
    }


    public static String getNicePrintDate(long timestamp)
        throws Exception
    {
        StringWriter out = new StringWriter();
        nicePrintDate(out, timestamp);
        return out.toString();
    }

    public static long niceParseDate(String dateImage)
        throws Exception
    {
        if (dateImage == null)
        {
            return 0;
        }
        if (dateImage.length()==0)
        {
            return 0;
        }
        if ("0/0/0000".equals(dateImage))
        {
            return 0;
        }
        int slash1 = dateImage.indexOf('/');
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(System.currentTimeMillis());
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int month = cal.get(Calendar.MONTH);
        int year = cal.get(Calendar.YEAR);

        if (slash1<0)
        {
            //no slashes found, so entire string is the day of this current month.
            day = DOMFace.safeConvertInt(dateImage);
            cal.set(Calendar.DAY_OF_MONTH, day);
            return cal.getTimeInMillis();
        }
        if (slash1==0)
        {
            throw new ProgramLogicError("Error parsing date value.  Date must be in the format of MM/DD/YYYY.  No month value found");
        }
        month = DOMFace.safeConvertInt(dateImage.substring(0,slash1))-1;
        cal.set(Calendar.MONTH, month);
        int slash2 = dateImage.indexOf('/', slash1+1);
        if (slash2<=slash1)
        {
            //no second slash, so the entire rest is the day
            day = DOMFace.safeConvertInt(dateImage.substring(slash1+1));
            cal.set(Calendar.DAY_OF_MONTH, day);
            return cal.getTimeInMillis();
        }
        if (slash2==slash1+1)
        {
            throw new ProgramLogicError("Error parsing date value.  Date must be in the format of MM/DD/YYYY. No day value found.");
        }
        day = DOMFace.safeConvertInt(dateImage.substring(slash1+1,slash2));
        cal.set(Calendar.DAY_OF_MONTH, day);
        year = DOMFace.safeConvertInt(dateImage.substring(slash2+1));
        cal.set(Calendar.YEAR, year);
        return cal.getTimeInMillis();
    }

    public static void writeTextWithLB(String text, Writer out) throws Exception
    {
        if (out == null || text == null || text.length() == 0) {
            return;
        }

        out.write(text + "\n");
    }

    static long lastKey = 0;
    public synchronized static String getNewKey()
    {
        long ctime = System.currentTimeMillis();
        if (ctime <= lastKey)
        {
            ctime = lastKey+1;
        }
        lastKey = ctime;

        StringBuffer res = new StringBuffer();
        while (ctime>0)
        {
            res.append((char)('A' + (ctime % 26)));
            ctime = ctime / 26;
        }
        return res.toString();
    }

    public static String getFullyQualifiedUrl(String urlFragment, String contextPath)
    {

        if (urlFragment != null)
        {
            // incase of a relative URL name append the context root to the URL.
            if ((urlFragment.toUpperCase().indexOf("HTTP://") == -1) && (urlFragment.toUpperCase().indexOf("WWW.") == -1))
            {
                if (!urlFragment.startsWith("/"))
                {
                    urlFragment = "/" + urlFragment;
                }
                urlFragment = contextPath + urlFragment;
            }
        }
        return urlFragment;
    }

    /**
    * Walk through whatever elements this owns and put all the four digit
    * IDs into the vector so that we can generate another ID and assure it
    * does not duplication any id found here.
    */
    public void findIDs(Vector<String> v, NGSection sec)
        throws Exception
    {
        //default behavior ... do nothing
    }


    public String editButtonName()
    {
        return "Edit";
    }

    /**
    * Some sections have a number of smaller pieces, where each piece can appear
    * at different levels.  This flag returns true is this is the case, and false
    * it is a normal section that appears only at one level.
    */
    public boolean appearsAtMultipleLevels()
    {
        return false;
    }

    /**
    * by default, assume that the section is NOT empty.
    * Each particular format should return something better than this.
    */
    public boolean isEmpty(NGSection section) throws Exception
    {
        return false;
    }

    // default setting
    public boolean isJustText()
    {
        return false;
    }

    public NoteRecord convertToLeaflet(NGSection noteSection,
                   NGSection wikiSection) throws Exception
    {
        throw new ProgramLogicError("convertToLeaflet is not implemented on this section format");
    }


    //default befavior is to not find any links
    public void findLinks(Vector<String> v, NGSection section)
        throws Exception
    {
        //not implemented yet
    }

}
