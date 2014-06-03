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

package org.socialbiz.cog.api;

import java.net.HttpURLConnection;
import java.net.URL;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;
import org.socialbiz.cog.License;

/**
* A remote project is access purely through URLs and REST oriented web services
*/
public class RemoteProject
{
    String     urlStr;
    JSONObject root;

    public RemoteProject(String s) throws Exception {
        urlStr = s;
    }

    public JSONObject getJSONObj() throws Exception {
        try {
            if (root == null) {
                URL url = new URL(urlStr);
                InputStream is = url.openStream();
                JSONTokener jt = new JSONTokener(is);
                root = new JSONObject(jt);
            }
            return root;
        }
        catch (Exception e) {
            throw new Exception("Unable to get site detail from url=" + urlStr, e);
        }
    }

    public JSONArray getNotes() throws Exception {
        return getJSONObj().getJSONArray("notes");
    }
    public JSONArray getDocs() throws Exception {
        return getJSONObj().getJSONArray("docs");
    }
    public JSONArray getGoals() throws Exception {
        return getJSONObj().getJSONArray("goals");
    }
    public License getLicense() throws Exception {
        return new RemoteLicense(getJSONObj().optJSONObject("license"));
    }
    public String getName() throws Exception {
        return getJSONObj().optString("projectname");
    }
    public String getSiteURL() throws Exception {
        return getJSONObj().optString("siteinfo");
    }
    public String getSiteName() throws Exception {
        return getJSONObj().optString("sitename");
    }

    /**
     * Send a JSONObject to this server as a POST and
     * get a JSONObject back with the response.
     */
    public JSONObject call(JSONObject msg) throws Exception {
        try {
            URL url = new URL(urlStr);
            HttpURLConnection httpCon = (HttpURLConnection) url.openConnection();
            httpCon.setDoOutput(true);
            httpCon.setDoInput(true);
            httpCon.setUseCaches(false);
            httpCon.setRequestProperty( "Content-Type", "application/json" );
            httpCon.setRequestProperty("Accept", "application/json");
            httpCon.setRequestMethod("POST");
            httpCon.connect();
            OutputStream os = httpCon.getOutputStream();
            OutputStreamWriter osw = new OutputStreamWriter(os, "UTF-8");
            msg.write(osw, 2, 0);
            osw.flush();
            osw.close();
            os.close();


            InputStream is = httpCon.getInputStream();
            JSONTokener jt = new JSONTokener(is);
            JSONObject resp = new JSONObject(jt);

            int responseCode = resp.getInt("responseCode");
            if (responseCode!=200) {
                JSONObject exception = resp.getJSONObject("exception");
                JSONArray errorMsgs = exception.getJSONArray("msgs");
                Exception lastExp = null;
                int len = errorMsgs.length();
                for (int i=0; i<len; i++) {
                    String oneMsg = errorMsgs.getString(i);
                    if (lastExp==null) {
                        lastExp = new Exception(oneMsg);
                    }
                    else {
                        lastExp = new Exception(oneMsg, lastExp);
                    }
                }
                throw new Exception("RemoteProjectException: ("+responseCode+"): ", lastExp);
            }

            return resp;
        }
        catch (Exception e) {
            throw new Exception("Unable to call the server site located at "+urlStr, e);
        }
    }
}
