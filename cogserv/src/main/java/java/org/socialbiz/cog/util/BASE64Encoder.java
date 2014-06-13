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

import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;

/**
 * @publish internal
 */
public class BASE64Encoder {
    /*
     * Encodes by byte array. When byte arrays specified for the argument are
     * null or 0 bytes, the character string of the return value becomes empty
     * string.
     *
     * @param byte[] Byte array to be encoded @return String Encoded Character
     * string
     */

    public String encode(byte[] bytes) {
        if (null == bytes || 0 == bytes.length) {
            return "";
        }

        ByteArrayOutputStream bout = new ByteArrayOutputStream(
                bytes.length * 150 / 100);

        int max = bytes.length;
        for (int i = 0; i < bytes.length; i += 3) {
            bout.write(create3byte(bytes, i, max), 0, 4);
            // add CRLF at each 76 characters
            if (54 == i % 57) {
                bout.write('\r');
                bout.write('\n');
            }
        }

        try {
            return bout.toString("UTF-8");
        } catch (UnsupportedEncodingException e) {
            return "";
        }
    }

    /*
     * Converts three bytes into four bytes. Base64 delimits the bit array in
     * three bytes by six bits, and creates four arrays of six bits. Here, 0
     * padding every two head bits of six bits for each is done. In addition,
     * the created each byte is converted into the character-code of Base64. "="
     * is supplemented to an insufficient six bit location when the value of
     * offset+2 exceeds max.
     */
    private byte[] create3byte(byte[] bytes, int offset, int max) {
        byte rr[] = new byte[4];
        int num = 0x00000000;
        num |= (bytes[offset + 0] << 16) & 0xFF0000;

        if (offset + 1 < max) {
            num |= (bytes[offset + 1] << 8) & 0xFF00;
        } else {
            num |= 0;
        }

        if (offset + 2 < max) {
            num |= (bytes[offset + 2] << 0) & 0x00FF;
        } else {
            num |= 0;
        }

        rr[0] = map((num >> 18) & 0x3F);
        rr[1] = map((num >> 12) & 0x3F);

        if (offset + 2 < max) {
            rr[2] = map((num >> 6) & 0x3F);
            rr[3] = map((num >> 0) & 0x3F);
        } else if (1 == (max % 3)) {
            rr[2] = (byte) '=';
            rr[3] = (byte) '=';
        } else if (2 == (max % 3)) {
            rr[2] = map((num >> 6) & 0x3F);
            rr[3] = (byte) '=';
        }
        return rr;
    }

    /*
     * It encodes it to the character of the Base64 form. The correspondence of
     * the numerical value and the character is taken, and ASCII code of the
     * character is set. The character string of the Base64 form is as follows.
     */
    private byte map(int code) {
        code = code & 0x3F;
        if (code <= 25) {
            return (byte) (code - 0 + 'A');
        } else if (code <= 51) {
            return (byte) (code - 26 + 'a');
        } else if (code <= 61) {
            return (byte) (code - 52 + '0');
        } else if (code == 62) {
            return (byte) '+';
        } else {
            return (byte) '/';
        }
    }
}
