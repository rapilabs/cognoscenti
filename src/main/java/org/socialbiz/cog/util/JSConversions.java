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

package org.socialbiz.cog.util;

import org.socialbiz.cog.exception.ProgramLogicError;

/**
 * This class contains some static utility routines to handle JavaScript. Most
 * importantly, it contains routines for converting strings to and from literal
 * form.
 */
public class JSConversions {
    /**
     * make private so it is a static only class
     *
     * @publish extension
     */
    private JSConversions() {
    }

    static char[] hexchars = { '0', '1', '2', '3', '4', '5', '6', '7', '8',
            '9', 'A', 'B', 'C', 'D', 'E', 'F' };
    static int[] hexvalue = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0, 0,
            0, 0, 0, 0, 0, 10, 11, 12, 13, 14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 11, 12, 13,
            14, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
            0, 0, 0, 0, 0 };

    /**
     * Encodes a single <code>String</code> value to a JavaScript literal
     * expression.
     *
     * <p>
     * If you are constructing a JavaScript expression and you have a String
     * value that you want to be expressed as a String literal in the
     * JavaScript, you must use this method to scan the String and convert any
     * embedded problematic characters into their escaped equivalents. The
     * result of the conversion is written into the String buffer that you pass
     * in. This routine also adds start and end quotes.
     * </p>
     *
     * <p>
     * <b>Do NOT simply paste quotes before and after the string!</b>
     * </p>
     *
     * @param res
     *                The <code>StringBuffer</code> object to which the
     *                encoded String value is added.
     * @param val
     *                The <code>String</code> value to encode.
     * @return The JavaScript literal expression encoded from the supplied
     *         value.
     */
    public static void quote4JS(StringBuffer res, String val) {
        // passing a null in results a no output, no quotes, nothing
        if ((val == null) || (res == null)) {
            return;
        }
        int len = val.length();
        int startPos = 0;
        String trans = null;
        res.append("\"");
        for (int i = 0; i < len; i++) {
            char ch = val.charAt(i);
            switch (ch) {
            case '\"':
                trans = "\\\"";
                break;
            case '\\':
                trans = "\\\\";
                break;
            case '\'':
                trans = "\\\'";
                break;
            case '\n':
                trans = "\\n";
                break;
            case '\t':
                trans = "\\t";
                break;
            case '\r':
                trans = "\\r";
                break;
            case '\f':
                trans = "\\f";
                break;
            case '\b':
                trans = "\\b";
                break;
            default:
                if (ch < 128) {
                    continue;
                }
                if (ch < 256) {
                    char firstHex = hexchars[(ch / 16) % 16];
                    char secondHex = hexchars[ch % 16];
                    trans = "\\x" + firstHex + secondHex;
                } else {
                    char firstHex = hexchars[(ch / 4096) % 16];
                    char secondHex = hexchars[(ch / 256) % 16];
                    char thirdHex = hexchars[(ch / 16) % 16];
                    char fourthHex = hexchars[ch % 16];
                    trans = "\\u" + firstHex + secondHex + thirdHex + fourthHex;
                }
            }
            if (trans != null) {
                if (i > startPos) {
                    res.append(val.substring(startPos, i));
                }
                res.append(trans);
                startPos = i + 1;
                trans = null;
            }
        }
        // now write out whatever is left
        if (len > startPos) {
            res.append(val.substring(startPos));
        }
        res.append("\"");
    }

    /**
     * Takes a single JavaScript literal and converts it back to a String value,
     * removing the start and end quotes, and then converting any backslash
     * escaped value into its actual value.
     *
     * <p>
     * Note: This method does not recognize the terminating quote in any
     * position except the last. It allows characters in the String that
     * JavaScript will not allow. This means you can "trick" this conversion by
     * passing an invalid literal, such as:
     * </p>
     *
     * <table>
     * <tr>
     * <td>"abc" + "def"</td>
     * <td>(this is an expression not a single literal)</td>
     * </tr>
     * <tr>
     * <td>"abc</td>
     * <td></td>
     * </tr>
     * <tr>
     * <td>def"</td>
     * <td>(invalid line end in literal not detected)</td>
     * </tr>
     * <tr>
     * <td>"abc"def"</td>
     * <td>(invalid quote in middle not detected)</td>
     * </tr>
     * </table>
     *
     * @param res
     *                The <code>StringBuffer</code> object to which the
     *                converted literalString is added.
     * @param literalString
     *                The JavaScript literal to be converted.
     * @return The String value generated from the supplied JavaScript literal.
     * @exception Exception
     *                    Thrown if the supplied <em>literalString</em> value
     *                    is empty, <code>null</code> or not surrounded by
     *                    double quotes. Furthermore this exception is thrown if
     *                    the supplied <em>res</em> value is null.
     */
    public static void unquote4JS(StringBuffer res, String literalString)
            throws Exception {
        if ((res == null) || (literalString == null) || literalString.length() == 0) {
            throw new ProgramLogicError("Passed in arguments are invalid.");
        }
        if ((literalString.charAt(0) != '\"')
                || (literalString.charAt(literalString.length() - 1) != '\"')) {
            throw new ProgramLogicError("Passed in string should start and end with double quotes.");
        }
        int lenMinusTwo = literalString.length() - 2;
        int startPos = 1;
        int pos = 0;
        while (pos < lenMinusTwo) {
            pos++;
            char ch = literalString.charAt(pos);
            if (ch != '\\') {
                continue; // skip over normal characters
            }

            // ok, we got a slash, check the next character, but first check an
            // error condition
            if (pos >= lenMinusTwo) {
                throw new ProgramLogicError("Last character is a black slash.");
            }

            // are there any normal characters to copy that we skipped over
            if (pos > startPos) {
                res.append(literalString.substring(startPos, pos));
            }
            pos++;
            ch = literalString.charAt(pos);

            // convert to the coded value. Quote and slash don't need this
            // conversion
            switch (ch) {
            case 'n':
                ch = '\n';
                break;
            case 't':
                ch = '\t';
                break;
            case 'r':
                ch = '\r';
                break;
            case 'f':
                ch = '\f';
                break;
            case 'b':
                ch = '\b';
                break;
            case 'x':
                int i1 = hexvalue[literalString.charAt(++pos)];
                int i2 = hexvalue[literalString.charAt(++pos)];
                ch = (char) (i1 * 16 + i2);
                break;
            case 'u':
                int u1 = hexvalue[literalString.charAt(++pos)];
                int u2 = hexvalue[literalString.charAt(++pos)];
                int u3 = hexvalue[literalString.charAt(++pos)];
                int u4 = hexvalue[literalString.charAt(++pos)];
                ch = (char) (u1 * 4096 + u2 * 256 + u3 * 16 + u4);
                break;
            }
            res.append(ch);
            startPos = pos + 1;
        }
        // now write out whatever is left of normal characters skipped, except
        // not the final quote!
        if (startPos <= lenMinusTwo) {
            res.append(literalString.substring(startPos, lenMinusTwo + 1));
        }
    }

    /**
     * Encodes a single <code>String</code> value to a JavaScript literal
     * expression.
     *
     * @param val
     *                The <code>String</code> value to encode.
     * @return The JavaScript literal expression encoded from the supplied
     *         value.
     */
    public static String quote4JS(String val) {
        StringBuffer sb = new StringBuffer();
        quote4JS(sb, val);
        return sb.toString();
    }

    /**
     * Converts a single JavaScript literal back to a String value.
     *
     * <p>
     * The conversion starts with removing the start and end quotes and then
     * converting any backslash escaped value into its actual value.
     * </p>
     *
     * <p>
     * Note: This method does not recognize the terminating quote in any
     * position except the last. It allows characters in the String that
     * <code>JavaScript</code> will not allow. This means you can "trick" this
     * conversion by passing an invalid literal, such as:
     * </p>
     *
     * <table>
     * <tr>
     * <td>"abc" + "def"</td>
     * <td>(this is an expression not a single literal)</td>
     * </tr>
     * <tr>
     * <td>"abc</td>
     * <td></td>
     * </tr>
     * <tr>
     * <td>def"</td>
     * <td>(invalid line end in literal not detected)</td>
     * </tr>
     * <tr>
     * <td>"abc"def"</td>
     * <td>(invalid quote in middle not detected)</td>
     * </tr>
     * </table>
     *
     * @param val
     *                The JavaScript literal to be converted.
     * @return The String value generated from the supplied JavaScript literal.
     * @exception Exception
     *                    Thrown if the supplied value is not surrounded by
     *                    double quotes or if the value is <code>null</code>.
     */
    public static String unquote4JS(String val) throws Exception {
        StringBuffer sb = new StringBuffer();
        unquote4JS(sb, val);
        return sb.toString();
    }

}
