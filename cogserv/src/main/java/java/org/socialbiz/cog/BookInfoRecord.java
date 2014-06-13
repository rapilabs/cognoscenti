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

import java.util.Vector;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class BookInfoRecord  extends DOMFace
{
    public final static int THEME_BLUE     = 0;
    public final static int THEME_BROWN    = 1;
    public final static int THEME_YELLOW   = 2;
    public final static int THEME_PURPLE   = 3;
    public final static int THEME_LAVENDER = 4;
    public final static int THEME_TAN   = 5;
    public final static int THEME_RED = 6;

    public final static String THEME_BLUE_STR     = "Blue";
    public final static String THEME_BROWN_STR    = "Brown";
    public final static String THEME_YELLOW_STR   = "Yellow";
    public final static String THEME_PURPLE_STR   = "Purple";
    public final static String THEME_LAVENDER_STR = "Lavender";
    public final static String THEME_TAN_STR   = "Tan";
    public final static String THEME_RED_STR = "Red";

    public final static String THEME_BLUE_PATH     = "theme/blue/";
    public final static String THEME_BROWN_PATH    = "theme/brown/";
    public final static String THEME_YELLOW_PATH   = "theme/yellow/";
    public final static String THEME_PURPLE_PATH   = "theme/purple/";
    public final static String THEME_LAVENDER_PATH = "theme/lavender/";
    public final static String THEME_TAN_PATH   = "theme/tan/";
    public final static String THEME_RED_PATH = "theme/red/";

    public final static String THEME_BLUE_IMG     = "iconBlueTheme.gif";
    public final static String THEME_BROWN_IMG    = "iconBrownTheme.gif";
    public final static String THEME_YELLOW_IMG   = "iconYelloTheme.gif";
    public final static String THEME_PURPLE_IMG   = "iconPurpleTheme.gif";
    public final static String THEME_LAVENDER_IMG = "iconLavenderTheme.gif";
    public final static String THEME_TAN_IMG   = "iconTanTheme.gif";
    public final static String THEME_RED_IMG = "iconRedTheme.gif";


    public BookInfoRecord(Document nDoc, Element nEle, DOMFace p)
        throws Exception
    {
        super(nDoc, nEle, p);
        //assure that the user list element is there
        requireChild("roleList", DOMFace.class);
        requireChild("Role-Requests", DOMFace.class);

    }

    /**
    public String getBookKey()
    {
        return getAttribute("book");
    }
    public void setBookKey(String newKey)
    {
        setAttribute("book", newKey);
    }
    */

    public long getModTime()
    {
        return safeConvertLong(getAttribute("modTime"));
    }
    public void setModTime(long newTime)
    {
        setAttribute("modTime", Long.toString(newTime));
    }

    public String getModUser()
    {
        return getAttribute("modUser");
    }
    public void setModUser(String newUser)
    {
        setAttribute("modUser", newUser);
    }

    public String getSynopsis()
        throws Exception
    {
        return getScalar("synopsis");
    }

    public void setSynopsis(String newVal)
        throws Exception
    {
        if (newVal == null) {
            newVal = "";
        }
        setScalar("synopsis", newVal);
    }


    String[] getPageNames() {
        Vector<String> vc = getVector("bookName");
        Vector<String> vccleaned = new Vector<String>();
        for (String chl : vc) {
            String aName = chl.trim();
            if (aName.length() > 0) {
                vccleaned.add(aName);
            }
        }

        String[] displayNames = new String[vccleaned.size()];
        vccleaned.copyInto(displayNames);
        return displayNames;
    }

    public void setPageNames(String[] newNames)
    {
        DOMUtils.removeAllNamedChild(fEle, "bookName");
        for (int i=0; i<newNames.length; i++)
        {
            String aName = newNames[i].trim();
            //only save names that are non-null
            if (aName.length()>0)
            {
                addVectorValue("bookName", aName);
            }
        }
    }

    public boolean isDeleted()
    {
        String delAttr = getAttribute("deleteUser");
        return (delAttr!=null&&delAttr.length()>0);
    }

    public void setDeleted(AuthRequest ar)
    {
        setAttribute("deleteDate", Long.toString(ar.nowTime));
        setAttribute("deleteUser", ar.getBestUserId());
    }
    public void clearDeleted()
    {
        setAttribute("deleteDate", null);
        setAttribute("deleteUser", null);
    }
    public long getDeleteDate()
    {
        return getAttributeLong("deleteDate");
    }
    public String getDeleteUser()
    {
        return getAttribute("deleteUser");
    }

    public String getAllowPublic() {
        return getAttribute("allowPublic");
    }

    public void setAllowPublic(String allowPublic) {
        setAttribute("allowPublic", allowPublic);
    }

    /**
    * Different sites can have different style sheets (themes)
    * This is the path to the folder that holds the theme files
    */
    public String getThemePath()
    {
        return getScalar("theme");
    }
    public void setThemePath(String newName)
    {
        setScalar("theme", newName);
    }

    public static String themeName(int theme)
    {
        switch (theme)
        {
            case THEME_BLUE:
                return THEME_BLUE_STR;
            case THEME_BROWN:
                return THEME_BROWN_STR;
            case THEME_YELLOW:
                return THEME_YELLOW_STR;
            case THEME_PURPLE:
                return THEME_PURPLE_STR;
            case THEME_LAVENDER:
                return THEME_LAVENDER_STR;
            case THEME_TAN:
                return THEME_TAN_STR;
            case THEME_RED:
                return THEME_RED_STR;
            default:
                return THEME_BLUE_STR;
        }
    }

    public static String themeImg(int theme)
    {
        switch (theme)
        {
            case THEME_BLUE:
                return THEME_BLUE_IMG;
            case THEME_BROWN:
                return THEME_BROWN_IMG;
            case THEME_YELLOW:
                return THEME_YELLOW_IMG;
            case THEME_PURPLE:
                return THEME_PURPLE_IMG;
            case THEME_LAVENDER:
                return THEME_LAVENDER_IMG;
            case THEME_TAN:
                return THEME_TAN_IMG;
            case THEME_RED:
                return THEME_RED_IMG;
            default:
                return THEME_BLUE_IMG;
        }
    }

    public static String themePath(int theme)
    {
        switch (theme)
        {
            case THEME_BLUE:
                return THEME_BLUE_PATH;
            case THEME_BROWN:
                return THEME_BROWN_PATH;
            case THEME_YELLOW:
                return THEME_YELLOW_PATH;
            case THEME_PURPLE:
                return THEME_PURPLE_PATH;
            case THEME_LAVENDER:
                return THEME_LAVENDER_PATH;
            case THEME_TAN:
                return THEME_TAN_PATH;
            case THEME_RED:
                return THEME_RED_PATH;
            default:
                return THEME_BLUE_PATH;
        }
    }

}
