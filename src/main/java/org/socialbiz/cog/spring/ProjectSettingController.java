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

package org.socialbiz.cog.spring;

import java.util.List;
import java.util.Vector;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.socialbiz.cog.AddressListEntry;
import org.socialbiz.cog.AuthRequest;
import org.socialbiz.cog.HistoryRecord;
import org.socialbiz.cog.NGContainer;
import org.socialbiz.cog.NGPage;
import org.socialbiz.cog.NGRole;
import org.socialbiz.cog.RoleRequestRecord;
import org.socialbiz.cog.UtilityMethods;
import org.socialbiz.cog.exception.NGException;
import org.socialbiz.cog.exception.ProgramLogicError;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.view.RedirectView;

@Controller
public class ProjectSettingController extends BaseController {

    @RequestMapping(value = "/{siteId}/{pageId}/EditRole.htm", method = RequestMethod.GET)
    public ModelAndView editRole(@PathVariable String siteId,@PathVariable String pageId,
            @RequestParam String roleName,
            HttpServletRequest request,
            HttpServletResponse response)
    throws Exception {

        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            if(!ar.isLoggedIn()){
                return showWarningView(ar, "message.loginalert.see.page");
            }
            NGContainer nGPage  = registerRequiredProject(ar, siteId, pageId);

            List<NGRole> roles = nGPage.getAllRoles();

            modelAndView = new ModelAndView("editrole");
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
            request.setAttribute("roleName", roleName);
            request.setAttribute("roles", roles);
            request.setAttribute("title", " : " + nGPage.getFullName());
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.edit.role.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;

    }
    @RequestMapping(value = "/{siteId}/{pageId}/roleRequest.htm", method = RequestMethod.GET)
    public ModelAndView remindersTab(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);

            NGPage nGPage = registerRequiredProject(ar, siteId, pageId);
            ar.setPageAccessLevels(nGPage);
            if(!ar.isLoggedIn()){
                request.setAttribute("property_msg_key", "nugen.project.role.request.login.msg");
                modelAndView=new ModelAndView("Warning");
            }else if(!ar.isMember()){
                request.setAttribute("property_msg_key", "nugen.projecthome.rolerequest.memberlogin");
                modelAndView=new ModelAndView("Warning");
            }else{
                modelAndView=new ModelAndView("roleRequest");
                modelAndView.addObject("page", nGPage);
                request.setAttribute("subTabId", "nugen.projectsettings.subtab.role.request");
            }
            request.setAttribute("realRequestURL", ar.getRequestURL());
            request.setAttribute("tabId", "Project Settings");
        }catch(Exception ex){
            throw new NGException("nugen.operation.fail.project.role.request.page", new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;

    }

    @RequestMapping(value = "/{siteId}/{pageId}/pageRoleAction.form", method = RequestMethod.POST)
    public ModelAndView pageRoleAction(@PathVariable String siteId,@PathVariable String pageId,
            HttpServletRequest request, HttpServletResponse response)
            throws Exception {
        ModelAndView modelAndView = null;
        try{
            AuthRequest ar = AuthRequest.getOrCreate(request, response);
            if(!ar.isLoggedIn()){
                return showWarningView(ar, "message.loginalert.see.page");
            }
            NGPage ngp = registerRequiredProject(ar, siteId, pageId);

            String r  = ar.reqParam("r");   //role name
            boolean sendEmail  = ar.defParam("sendEmail", null)!=null;
            String op = ar.reqParam("op");  //operation: add or remove
            String go = ar.reqParam("go");  //where to go afterwards

            ar.setPageAccessLevels(ngp);
            ar.assertMember("Unable to modify roles.");
            ar.assertNotFrozen(ngp);

            NGRole role = ngp.getRole(r);
            if (role==null)
            {
                if (op.equals("Create Role"))
                {
                    String desc = ar.reqParam("desc");
                    ngp.createRole(r,desc);
                    ngp.saveContent(ar, "create new role "+r);
                    response.sendRedirect(go);
                    return null;
                }
                throw new NGException("nugen.exception.role.not.found", new Object[]{r,ngp.getFullName()});
            }

            boolean isPlayer = role.isExpandedPlayer(ar.getUserProfile(), ngp);
            if (!isPlayer) {
                ar.assertAdmin("You must be a player of the role or project admin to change role '"
                        +r+"'.");
            }

            String id = ar.reqParam("id");  //user being added/removed

            AddressListEntry ale =null;
            if (!op.equals("Add Member")) {
                String parseId = pasreFullname(id );
                ale = AddressListEntry.newEntryFromStorage(parseId);
            }

            int eventType = 0;
            String pageSaveComment = null;

            if (op.equals("Add"))
            {
                if (id.length()<5)
                {
                    throw new NGException("nugen.exception.id.too.small", new Object[]{id});
                }
                eventType = HistoryRecord.EVENT_PLAYER_ADDED;
                pageSaveComment = "added user "+id+" to role "+r;
                role.addPlayerIfNotPresent(ale);
            }
            else if (op.equals("Remove"))
            {
                eventType = HistoryRecord.EVENT_PLAYER_REMOVED;
                pageSaveComment = "removed user "+id+" from role "+r;
                role.removePlayer(ale);
            }
            else if (op.equals("Add Role"))
            {
                eventType = HistoryRecord.EVENT_ROLE_ADDED;
                pageSaveComment = "added new role "+r;
                ale.setRoleRef(true);
                role.addPlayer(ale);
            }
            else if (op.equals("Update Details"))
            {
                eventType = HistoryRecord.EVENT_ROLE_MODIFIED;
                pageSaveComment = "modified details of role "+r;
                String desc = ar.defParam("desc", "");
                String reqs = ar.defParam("reqs", "");
                role.setDescription(desc);
                role.setRequirements(reqs);
            }
            else if (op.equals("Delete Role"))
            {
                eventType = HistoryRecord.EVENT_ROLE_MODIFIED;
                String confirmDelete = ar.defParam("confirmDelete", "no");
                if (!"yes".equals(confirmDelete)) {
                    throw new Exception("Please check the 'conform delete' if you really want to delete this role.");
                }
                pageSaveComment = "deleted role "+r;
                ngp.deleteRole(r);
            }
            else if(op.equals("Add Member"))
            {
                Vector<AddressListEntry> emailList = AddressListEntry.parseEmailList(id);
                for (AddressListEntry addressListEntry : emailList) {
                    eventType = HistoryRecord.EVENT_PLAYER_ADDED;
                    pageSaveComment = "added user "+addressListEntry.getUniversalId()+" to role "+r;

                    RoleRequestRecord roleRequestRecord = ngp.getRoleRequestRecord(role.getName(),
                            addressListEntry.getUniversalId());
                    if(roleRequestRecord != null){
                        roleRequestRecord.setState("Approved");
                    }

                    role.addPlayerIfNotPresent(addressListEntry);
                    if (sendEmail) {
                        NGWebUtils.sendInviteEmail( ar, pageId,  addressListEntry.getEmail(), r );
                    }
                }
            }
            else
            {
                throw new NGException("nugen.exceptionhandling.did.not.understand.option", new Object[]{op});
            }

            //make sure that the options above set the variables with the right values.
            if (eventType == 0 || pageSaveComment == null)
            {
                throw new ProgramLogicError("variables eventType and pageSaveComment have not been maintained properly.");
            }

            HistoryRecord.createHistoryRecord(ngp,id, HistoryRecord.CONTEXT_TYPE_ROLE,0,eventType, ar, "");
            ngp.saveContent(ar, "added user "+id+" to role "+r);

           if(go!=null){
               response.sendRedirect(go);
           }else{
               modelAndView = new ModelAndView(new RedirectView("EditRole.htm"));
               // modelAndView.addObject works in case of redirect. It adds the parameter
               // in query string.
               modelAndView.addObject("roleName",r);
           }

        }
        catch(Exception ex) {
            throw new NGException("nugen.operation.fail.project.update.role.or.member",
                    new Object[]{pageId,siteId} , ex);
        }
        return modelAndView;
    }

    private static String pasreFullname(String fullNames) throws Exception
    {
        String assigness = "";
        String[] fullnames = UtilityMethods.splitOnDelimiter(fullNames, ',');
        for(int i=0; i<fullnames.length; i++){
            String fname = fullnames[i];
            int bindx = fname.indexOf('<');
            int length = fname.length();
            if(bindx > 0){
                fname = fname.substring(bindx+1,length-1);
            }
            assigness = assigness + "," + fname;

        }
        if(assigness.startsWith(",")){
            assigness = assigness.substring(1);
        }
        return assigness;
    }

}
