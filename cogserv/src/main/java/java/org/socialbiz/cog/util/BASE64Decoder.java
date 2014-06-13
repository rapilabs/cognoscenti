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

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.UnsupportedEncodingException;

/**
 * @publish internal
 */
public class BASE64Decoder {
    /*
     * It decipher the passed encoded string. And it return the result in a byte
     * array. If the specified character string can not be deciphered Exception
     * is thrown.
     *
     * @param String Character string to be deciphered @return byte[] Byte array
     * containing the deciphered bytes @exception Exception If failed during the
     * decipherment
     */

    public byte[] decodeBuffer(String str) throws IOException {
        byte[] bytes = null;
        try {
            bytes = str.getBytes("UTF-8");
        } catch (UnsupportedEncodingException e) {
            return null;
        }

        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        ByteArrayInputStream bin = new ByteArrayInputStream(bytes);

        byte bb[] = new byte[4];

        int index = 0;
        int bValue;

        while ((bValue = bin.read()) != -1) {
            if (bValue == '\r' || bValue == '\n' || bValue == ' ') {
                continue;
            }

            bb[index++] = (byte) bValue;

            if (index != 4) {
                continue;
            }

            byte rr[] = decode3byte(bb, 0, 4);
            bout.write(rr, 0, rr.length);

            index = 0;
        }

        if (index != 0) {
            byte rr[] = decode3byte(bb, 0, index);
            bout.write(rr, 0, rr.length);
        }
        return bout.toByteArray();
    }

    /*
     * It converts the passed byte array into byte array of three bytes (24
     * bits). Confirm and operate the length of the byte on the operated side.
     */
    private byte[] decode3byte(byte[] bb, int offset, int max)
            throws IOException {
        int num = 0x00000000;
        int len = 0;
        for (int i = 0; i < 4; i++) {
            if (offset + i >= max || bb[offset + i] == '=') {
                if (i < 2) {
                    throw new IOException(
                            "BASE64Decoder: Incomplete BASE64 character");
                } else {
                    break;
                }
            }
            num |= (unmap(bb[offset + i]) << 2) << (24 - 6 * i);
            len++;
        }
        if (len < 3) {
            len = 1;
        } else {
            len--;
        }

        byte rr[] = new byte[len];

        for (int i = 0; i < len; i++) {
            rr[i] = (byte) (num >> (24 - 8 * i));
        }
        return rr;
    }

    /*
     * Converts the character of the Base64 form into the numerical value.
     */
    private byte unmap(int cc) throws IOException {
        if (cc >= 'A' && cc <= 'Z') {
            return (byte) (cc - 'A');
        } else if (cc >= 'a' && cc <= 'z') {
            return (byte) (cc - 'a' + 26);
        } else if (cc >= '0' && cc <= '9') {
            return (byte) (cc - '0' + 52);
        } else if (cc == '+') {
            return 62;
        } else if (cc == '/') {
            return 63;
        } else {
            throw new IOException("BASE64Decoder: Illegal character:= "
                    + (char) cc);
        }
    }
}