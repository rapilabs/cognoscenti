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

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.StringWriter;
import java.io.Writer;
import java.util.HashSet;
import java.util.Properties;
import java.util.Timer;
import java.util.TimerTask;

import javax.mail.Address;
import javax.mail.Authenticator;
import javax.mail.FetchProfile;
import javax.mail.Flags.Flag;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Multipart;
import javax.mail.Part;
import javax.mail.PasswordAuthentication;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.UIDFolder;
import javax.swing.text.html.HTMLEditorKit;

import org.socialbiz.cog.exception.NGException;

public class EmailListener extends TimerTask{

    private static EmailListener singletonListener = null;

    public static Exception threadLastCheckException = null;

    //expressed in milliseconds
    private final static long EVERY_MINUTE = 1000*60;

    private static Session session = null;

    private File emailPropFile = null;
    private static Properties emailProperties = null;
    private AuthRequest ar;
    private static HashSet<String> alreadyProcessed = new HashSet<String>();

    //TODO: this can probably be eliminated, and replaced with the PAUSE/REINIT model
    public static boolean propertiesChanged = false;
    public static long lastFolderRead;

    private EmailListener() throws Exception
    {
        this.ar = AuthDummy.serverBackgroundRequest();
        this.emailPropFile = ConfigFile.getFile("EmailNotification.properties");
        setEmailProperties(emailPropFile);
    }

    /**
     * This is an initialization routine, and should only be called once, when the
     * server starts up.  There are some error checks to make sure that this is the case.
     */
     public static void initListener(Timer timer) throws Exception
     {
         singletonListener = new EmailListener();
         String user = emailProperties.getProperty("mail.pop3.user");
         if (user==null || user.length()==0) {
             System.out.println("Email listener: no configuration for mail.pop3.user");
             return;
         }
         String pwd = emailProperties.getProperty("mail.pop3.password");
         if (pwd==null || pwd.length()==0) {
             System.out.println("Email listener: no configuration for mail.pop3.password");
             return;
         }
         timer.scheduleAtFixedRate(singletonListener, 60000, EVERY_MINUTE);
     }

     public void run()
     {
         // make sure that this method doesn't throw any exception
         try
         {
             // start by checking the configuration, and just skip out if not configured
             // TODO: need a better way to report these configuration problem
             // for now, just exit without a fuss
             if(emailProperties == null) {
                 System.out.println("Email listener: is not configured");
                 return;
             }
             String user = emailProperties.getProperty("mail.pop3.user");
             if (user==null || user.length()==0) {
                 System.out.println("Email listener: no configuration for mail.pop3.user");
                 return;
             }
             String pwd = emailProperties.getProperty("mail.pop3.password");
             if (pwd==null || pwd.length()==0) {
                 System.out.println("Email listener: no configuration for mail.pop3.password");
                 return;
             }

             //now really attempt to read the email.  Errors after this point recorded in file
             handlePOP3Folder();
         }
         catch(Exception e)
         {
             Exception failure = new Exception("Failure in the EmailListener thread run method. Thread died.", e);
             ar.logException("EMAIL LISTENER PROBLEM: ", failure);
             threadLastCheckException = failure;
             try {
                 SuperAdminLogFile.setEmailListenerPropertiesFlag(false);
                 SuperAdminLogFile.setEmailListenerProblem(failure);
             } catch (Exception ex) {
                 ar.logException("Could not set EmailListenerPropertiesFlag in superadmin.logs file.", ex);
             }
         }
     }

    public Session getSession()throws Exception {
        try {
            if(emailProperties == null){
                throw new NGException("nugen.exception.email.config.file.not.found",
                        new Object[]{emailPropFile.getAbsolutePath()});
            }

            String user = emailProperties.getProperty("mail.pop3.user");
            if (user==null || user.length()==0) {
                throw new Exception("In order to read email, there must be a setting for 'mail.pop3.user' in "+emailPropFile.getAbsolutePath()+".");
            }
            String pwd = emailProperties.getProperty("mail.pop3.password");
            if (pwd==null || pwd.length()==0) {
                throw new Exception("In order to read email, there must be a setting for 'mail.pop3.password' in "+emailPropFile.getAbsolutePath()+".");
            }

            if (user == null || user.length() == 0 || pwd == null || pwd.length() == 0) {
                throw new NGException("nugen.exception.email.config.incorrect.invalid.user.or.password",
                        new Object[]{emailPropFile.getAbsolutePath()});
            }

            return Session.getInstance(emailProperties, new EmailAuthenticator(user, pwd));
        }catch (Exception e) {
            throw new NGException("nugen.exception.email.unable.to.create.session",new String[]{"user", "pwd"},e);
        }
    }

    public Store getPOP3Store()throws Exception {
        try {

            if(session == null || propertiesChanged ){
                session = getSession();
                propertiesChanged = false;
            }
            return session.getStore("pop3");

        }catch (MessagingException me) {
            throw new NGException("nugen.exception.email.unable.to.create.pop3store",null,me);
        }
    }

    private Folder connectToMailServer()throws Exception {
        Store store = null;
        try {

            store = getPOP3Store();
            store.connect();

            Folder popFolder = store.getFolder("INBOX");
            popFolder.open(Folder.READ_WRITE);
            if (!popFolder.isOpen()) {
                throw new Exception("for some reason the 'INBOX' folder was not opened.");
            }

            SuperAdminLogFile.setEmailListenerPropertiesFlag(true);

            return popFolder;

        }catch (MessagingException me) {
            throw new NGException("nugen.exception.email.unable.to.connect.to.mail.server",null,me);
        } finally {
            // close the store.
            // but wait!  Won't that close the folder?
            if (store != null) {
                /*
                try {
                    store.close();
                } catch (MessagingException me) {
                    // ignore this exception
                }
                */
            }
        }
    }

    private void handlePOP3Folder() throws Exception {
        Folder popFolder = null;
        try {

            popFolder = connectToMailServer();

            if (!popFolder.isOpen()) {
                throw new Exception("for some reason the 'INBOX' folder was not opened.");
            }
            Message[] messages = popFolder.getMessages();
            if (messages == null || messages.length == 0) {
                // nothing to process.
                return;
            }

            FetchProfile fp = new FetchProfile();
            fp.add(UIDFolder.FetchProfileItem.UID);
            popFolder.fetch(messages, fp);

            for (int i = 0; i < messages.length; i++) {
                Message message = messages[i];

                // most of the POP mail servers/providers does not support flags
                // for other then delete
                if (message.isSet(Flag.DELETED)) {
                    continue;
                }

                String signature = message.getSubject() + message.getSentDate();
                if (alreadyProcessed.contains(signature)) {
                    //skip processing of messages already seen
                    continue;
                }
                alreadyProcessed.add(signature);

                try {
                    processEmailMsg(message);
                }
                catch (Exception e) {
                    //failure of one message should not stop the processing of other email messages
                    //this is kind of dangerous...should have a list of previously processed
                    //messages someplace.
                    ar.logException("Error Processing Message "+i, e);
                }
            }
            lastFolderRead = System.currentTimeMillis();

        }catch (Exception e) {
            throw new NGException("nugen.exception.email.listner.thread.read.fail",null, e);
        }finally {
            try {
                if(popFolder != null){
                    popFolder.close(true);
                }
            } catch (Exception e) {
                /* ignore this exception */
            }
        }
    }

    private void processEmailMsg(Message message) throws Exception {
        try{

            createNoteFromMail(message);
            message.setFlag(Flag.DELETED, true);

        }catch (Exception e) {
            //May be in this case we should also send reply to sender stating that 'note could not be created due to some reason'.
            throw new NGException("nugen.exception.could.not.process.email", new Object[]{message.getSubject()},e);
        }
    }

    public void createNoteFromMail(Message message) throws Exception {
        String subject = message.getSubject();
        try{
            Address[] recipientAdrs= message.getAllRecipients();
            String pageKey =  getProjectKey(recipientAdrs[0].toString(), subject);
            NGPage ngp = NGPageIndex.getProjectByKeyOrFail(pageKey);

            NoteRecord note = ngp.createNote();

            note.setSubject( subject );

            note.setVisibility(SectionDef.MEMBER_ACCESS);
            note.setEditable(NoteRecord.EDIT_MEMBER);

            String bodyText = getEmailBody(message);
            HtmlToWikiConverter htmlToWikiConverter = new HtmlToWikiConverter();
            String wikiText = htmlToWikiConverter.htmlToWiki(ar.baseURL,bodyText);

            note.setData(wikiText);

            note.setEffectiveDate(System.currentTimeMillis());
            note.setLastEdited(System.currentTimeMillis());
            note.setSaveAsDraft("no");

            Address[] fromAdrs = message.getFrom();
            String fromAdd = getFromAddress(fromAdrs[0].toString());
            note.setLastEditedBy(fromAdd);

            ngp.save(fromAdrs[0].toString(), ar.nowTime,"");

            handleEmailAttachments(ngp, message);

            NGPageIndex.releaseLock(ngp);
        }catch(Exception e){
            throw new NGException("nugen.exception.cant.create.note.from.msg", new Object[]{subject},e);
        }
    }

    private String getFromAddress(String fromAdr) {
        int startBrace = fromAdr.indexOf("<");
        int endBrace = fromAdr.indexOf(">");
        if(startBrace >= 0 && endBrace > startBrace+1) {
            return fromAdr.substring(startBrace+1, endBrace);
        }
        return fromAdr;
    }

    private String getProjectKey(String recipientAdr, String subject) throws Exception {
        int afterPlusPos = recipientAdr.indexOf("+")+1;
        int atPos = recipientAdr.indexOf("@");
        if(afterPlusPos > 0 && atPos > afterPlusPos){
            return recipientAdr.substring(afterPlusPos, atPos);
        }

        //no clue in the to address, so try the subject
        int afterStartBrace = subject.indexOf("[cog:")+5;
        int endBrace = subject.indexOf("]");
        if(afterStartBrace > 4 && endBrace > afterStartBrace){
            return subject.substring(afterStartBrace, endBrace);
        }

        throw new Exception("Unable to find a page id in the destination email address: ("
                +recipientAdr+") or in subject: ("+subject+")");
    }

    private static String getEmailBody(Message msg) throws Exception {
        return getText(msg);
    }

    private static String getText(Part p) throws Exception {

        if (p.isMimeType("text/*")) {
            String str = (String) p.getContent();
            boolean textIsHtml = p.isMimeType("text/html");
            if (textIsHtml) {
                str = getPlainText(p.getInputStream()).toString();
            }
            return str;
        }else if (p.isMimeType("multipart/alternative")) {
            // prefer html text over plain text
            Multipart mp = (Multipart) p.getContent();
            String text = null;
            for (int i = 0; i < mp.getCount(); i++) {
                Part bp = mp.getBodyPart(i);
                if (bp.isMimeType("text/plain")) {
                    if (text == null) {
                        text = getText(bp);
                    }
                    continue;
                } else if (bp.isMimeType("text/html")) {
                    String str = getText(bp);
                    if (str != null) {
                        return str;
                    }
                } else {
                    return getText(bp);
                }
            }
            return text;
        } else if (p.isMimeType("multipart/*")) {
            Multipart mp = (Multipart) p.getContent();
            for (int i = 0; i < mp.getCount(); i++) {
                String str = getText(mp.getBodyPart(i));
                if (str != null) {
                    return str;
                }
            }
        }
        return "";
    }

    private static StringBuffer getPlainText(InputStream is) throws Exception {
        StringWriter out = new StringWriter();
        InputStreamReader isr = new InputStreamReader(is, "UTF-8");
        char[] buf = new char[3333];
        int len = isr.read(buf);
        while (len>0) {
            out.write(buf, 0, len);
            len = isr.read(buf);
        }
        return out.getBuffer();
    }

    private void handleEmailAttachments(NGPage ngp, Message message) throws Exception {
        try{
            Address[] fromAdrs = message.getFrom();
            String fromAdd = getFromAddress(fromAdrs[0].toString());

            Multipart mp = (Multipart) message.getContent();
            if (true)  {
                for (int i = 0, n = mp.getCount(); i < n; i++) {
                    Part part = mp.getBodyPart(i);
                    String disposition = part.getDisposition();
                    if (disposition == null)  {
                        //what is this if it is null???
                        continue;
                    }
                    if (disposition.equals(Part.ATTACHMENT) ||
                            disposition.equals(Part.INLINE)) {

                        InputStream is = part.getInputStream();
                        String fileName = part.getFileName();
                        createDocumentRecord(ngp, is, fileName, fromAdd);
                    }
                }
            }
        }catch (Exception e) {
            throw new NGException("nugen.exception.cant.handle.email.att", new Object[]{message},e);
        }
    }

    private void createDocumentRecord(NGPage ngp,InputStream is,String fileName,String fromAdd) throws Exception {
        try{
            ar.assertNotFrozen(ngp);
            ar.setPageAccessLevels(ngp);
            String fileExtension = fileName.substring(fileName.indexOf("."));

            int version = 0;
            AttachmentRecord attachment = ngp.findAttachmentByName(fileName);
            if(attachment == null){
                attachment =  ngp.createAttachment();
                attachment.setDisplayName(fileName);
                attachment.setVisibility(1);
            }
            else {
                version = attachment.getVersion();
            }

            attachment.setComment("Uploaded through received Email.");
            attachment.setModifiedBy(fromAdd);
            attachment.setModifiedDate(System.currentTimeMillis());
            attachment.setType("FILE");
            attachment.setVersion(version+1);

            saveUploadedFile(ar, attachment, is,fileExtension,fromAdd,ngp);

            ngp.save(fromAdd,ar.nowTime, "Uploaded through received Email.");

            NGPageIndex.releaseLock(ngp);
        }catch(Exception e){
            throw new NGException("nugen.exception.cant.carete.doc.from.email",null,e);
        }
    }

    public static void saveUploadedFile(AuthRequest ar, AttachmentRecord att,
           InputStream is,String fileExtension, String fromAdd, NGContainer ngp) throws Exception {

        att.streamNewVersion(ar, ngp, is);

        att.setModifiedDate(System.currentTimeMillis());

        //TODO: is this the right setting?  What if this is not a real user?
        att.setModifiedBy(fromAdd);
    }

    private Properties setEmailProperties(File emailPropFile) throws Exception {

        if (!emailPropFile.exists()) {
            throw new NGException("nugen.exception.incorrect.sys.config", new Object[]{emailPropFile.getAbsolutePath()});
        }

        emailProperties = new Properties();
        FileInputStream fis = new FileInputStream(emailPropFile);
        emailProperties.load(fis);

        emailProperties.setProperty("mail.pop3.connectionpooltimeout", "500");
        emailProperties.setProperty("mail.pop3.connectiontimeout", "500");
        emailProperties.setProperty("mail.pop3.timeout", "500");

        return emailProperties;
    }

    public static EmailListener getEmailListener(){
        return singletonListener;
    }

    public static Properties getEmailProperties(){
        return emailProperties;
    }
    public File getEmailPropertiesFile(){
        return emailPropFile;
    }

    public void reStart() {
        propertiesChanged = true;
        run();
    }

}

class EmailAuthenticator extends Authenticator {
    private PasswordAuthentication auth;

    public EmailAuthenticator(String username, String password) {
        auth = new PasswordAuthentication(username, password);
    }

    protected PasswordAuthentication getPasswordAuthentication() {
        return auth;
    }
}

class Outliner extends HTMLEditorKit.ParserCallback {

    private Writer out;

    public Outliner(Writer out) {
        this.out = out;
    }

    public void handleText(char[] text, int position) {
        try {
            out.write(text);
            out.flush();
        } catch (IOException ioe) {
            ioe.printStackTrace();
            /* Ignore this Exception */
        }
    }
}
