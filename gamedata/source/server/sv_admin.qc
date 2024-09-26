/*
===========================================================================

Steel Storm Burning Retribution QuakeC Source Code
Copyright (C) 2008-2024 Kot-in-Action Creative Artel.

This file is part of the Steel Storm Burning Retribution QuakeC Source Code.

License:
  - You may use, modify, and distribute modifications of this source code under the terms of the Steel Storm Burning Retribution QuakeC Source Code License Agreement.
  - No commercial use of this source code or any derivative works is permitted.
  - All mods and modifications must be distributed for free and include this license header.
 
The full text of the license is included in the license.txt file that came with this source code.

If you have questions concerning this license, you may contact info (at) kot-in-action.com

===========================================================================
*/
float ClearSharedEntModels() =
{
	local entity e;
	for(e = list_playerchain; e; e = e.playerchain)
	{
		if(e.adminmode)
			return TRUE;
	}
	
	for(e = list_objectchain; e; e = e.objectchain)
	{
		if(e.isdataent)
			continue;
	
		if(e.model == "null")
		if(e.onlydrawforadmins)
			SetAndPrecacheModel(e, "");
		
		if(!e.ismapobject)
			e.effects -= e.effects & EF_NODEPTHTEST;
	}
		
	return FALSE;
}

void SetAdminMode(float adminstate) =
{
	adminmodeactive = adminstate;
	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	WriteByte(MSG_ALL, TE_ADMINMODEACTIVE);
	WriteByte(MSG_ALL, adminstate);
}

void ClearAdminFields() =
{
	local entity e;
	self.viewingnavigationcells = FALSE;
	
//	viewcellmodeactive = ClearSharedEntModels(viewingnavigationcells, CLASS_CELL);
	SetAdminMode(ClearSharedEntModels());
	
/*	e = list_objectchain;
	while(e)
	{
		if(e.editor == self)
			e.editor = world;
		e = e.objectchain;
	}*/
}

/*void ClearClientEntClass(entity viewer, float CLASS) =
{
	local float MSG_TYPE;

	if(viewer)
	{
		msg_entity = viewer;
		MSG_TYPE = MSG_ONE;
	}
	else
		MSG_TYPE = MSG_ALL;
		
	WriteByte(MSG_TYPE, SVC_TEMPENTITY);
	WriteByte(MSG_TYPE, TE_WIPECLASS);
	WriteByte(MSG_TYPE, CLASS);	
}*/

/*void ClaimEditingRights(float e_id) =
{
	local entity e;
	e = GetLinkedListEnt_float(list_objectchain, objectchain, id, e_id);
	if(!e)
	{
		sprint(self, "Invalid entity.\n");
		return;
	}
	
	if(e.editor && e.editor != self)
		sprint(self, "That entity is currently being edited by another administrator.\n");
	else
	{
		if(!e.editor)
		{
			e.editor = self;
			e.SendFlags = e.SendFlags | SFL_EDITABLE;			
		}
		else
			e.editor = world;
	}
}*/

void SendBottleNeckedAdminEnts() =
{
	local float count;
	
	for(count = 0; server_bottleneck_ent && count < 10; server_bottleneck_ent = server_bottleneck_ent.objectchain)
	{
		count++;
	
		if(server_bottleneck_ent.isdataent)
			continue;
	
		if(!server_bottleneck_ent.model)
			SetAndPrecacheModel(server_bottleneck_ent, "null");
		server_bottleneck_ent.effects = server_bottleneck_ent.effects | EF_NODEPTHTEST;
		server_bottleneck_ent.SendFlags = server_bottleneck_ent.SendFlags | SFL_BASEDATA;
	}
}

void SetLocalPlayerAdminFlags() =
{
	if(!singleplayer && self.netaddress == "local")
	{
		self.hasadminaccess = TRUE;
		self.SendFlags = self.SendFlags | SFL_RESET;
	}
}

void ToggleAdminMode() =
{
//	if(maxplayers <= 1)
	if(singleplayer)
//	if(!coop)
//	if(!deathmatch)
	{
	//	print("You may not use the editor while in single player mode.\n");
		return;
	}

	if(maxplayers > 1)
	if(!alloweditorinmultiplayer)
	{
	//	print("You do not have permission to use the editor on this server.\n");	// FIXME TRANSLATE
		return;
	}	
	
//	if(nextent(world) != self)
//	{
//		sprint(self, "Multiuser editing not enabled yet.\n");
//		return;
//	}

	if(!self.haseditoraccess)
	if(!self.hasadminaccess)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_GETSERVERPASSWORD);		
		return;
	}
	
	local float minepisode, totalobjects;
	local entity e;
	
	minepisode = 2;
	if(EPISODE < minepisode)
	{
		for(e = list_objectchain; e; e = e.objectchain)
			totalobjects++;
		if(totalobjects > 200)
		{
			msg_entity = self;
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_ADMINMODETOGGLE_MAXENTS);
			return;
		}
	}

/*	if(showingmissionscores)
	{
		showingmissionscores = FALSE;
		setpause(FALSE);	
	}*/
	
	self.adminmode = !self.adminmode;
	
	if(!self.adminmode)
	{
	//	if(GameMode_HasTeams(gamemode))
	//	if(self.team == -1)
	//		self.team = 0;
		self.haseditoraccess = FALSE;
		ClearAdminFields();
	}
	else
	{
		SetAdminMode(TRUE);		
	//	newadmin = self;
//		SpawnAllHiddenSectors();
		if(!server_bottleneck_ent)
			server_bottleneck_ent = list_objectchain;
	}

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_TOGGLEADMINMODE);
	
	UpdateBindMap();
}

/*void ToggleViewNavigationCells() =
{
	local entity e;

	self.viewingnavigationcells = !self.viewingnavigationcells;
	
	if(!self.viewingnavigationcells)
		viewcellmodeactive = ClearSharedEntModels(viewingnavigationcells, CLASS_CELL);
	else
	{
		viewcellmodeactive = TRUE;
		newcellviewer = self;
		e = findchainfloat(class, CLASS_CELL);
		while(e)
		{
			if(!e.model)
				SetAndPrecacheModel(e, "null");
		
			e.SendFlags = TRUE;
				
			e = e.chain;
		}
	}
}*/

void GrantEditorAccess() =
{
	if(!publicguesteditoraccess)
	if(!self.hasguestaccess)
		return;
	
	self.haseditoraccess = TRUE;
	self.SendFlags = self.SendFlags | SFL_RESET;	
	ToggleAdminMode();
}

void ToggleEditorAccess(float playerid) =
{
	local entity e;
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		if(e.id == playerid)
		{
			e.hasguestaccess = !e.hasguestaccess;
			e.SendFlags = e.SendFlags | SFL_RESET;
			return;
		}
	}
}

void GrantAdminAccess(string password, string c) =
{
	local string server_password;
	
	server_password = cvar_string("sv_admin_password");

	if(strlen(server_password))
	if(password == server_password)
	{
		msg_entity = self;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);	
		WriteByte(MSG_ONE, TE_ADMINACCESSGRANTED);	
		
		self.hasadminaccess = TRUE;
		self.SendFlags = self.SendFlags | SFL_RESET;
		if(c == "starteditor")
			ToggleAdminMode();
			
		return;
	}

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);	
	WriteByte(MSG_ONE, TE_ADMINACCESSDENIED);
}

entity GetAdminEnt(float e_id) =
{
	local entity e;
	
	if(!e_id)
	{
		dprint("Entity ID is null.\n");
		return world;
	}
	
	e = GetLinkedListEnt_float(list_objectchain, objectchain, id, e_id);
	
	if(!e)
	{
		dprint("Invalid entity.\n");
//		PrintNumEntsInList("INVALID");
		return world;	
	}
	
	return e;
}

void RevertEnt(float e_id) =
{
	local entity e;
	e = GetAdminEnt(e_id);
	if(!e)
		return;
	
	if(e.SendEntity)
		e.SendFlags = e.SendFlags | SFL_BASEDATA;//SFL_REVERT;
	else
		sprint(self, "Entity cannot be reverted.\n");
}

void ClearEntIDFields(.float idfloat, float idnum) =
{
	if(!idnum)
		return;
		
	local entity obj;
	for(obj = list_objectchain; obj; obj = obj.objectchain)
	{
		if(obj.idfloat != idnum)
			continue;
	
		obj.idfloat = 0;
		SendObjectToClients(obj);
	}
}	

void Admin_RemoveEnt(float e_id) =
{
	local entity e, obj;
	local float oldid, keepid, teamflags;
	
	e = GetAdminEnt(e_id);
	if(!e)
		return;

	if(!e.SendEntity)
	{
		dprint("removing non shared ent?\n");
	//	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	//	WriteByte(MSG_ALL, TE_REMOVEENT);
	//	WriteShort(MSG_ALL, e.id);
	}
	
/*	obj = list_objectchain;
	while(obj)
	{
		if(obj.targetentid == e.entid)
		{
			obj.targetentid = 0;
			RecentlyCommitedEntityChain_Add(obj);
		}
		
		obj = obj.objectchain;
	}*/
	
	if(e.objclass == OBJ_FLAGBASE)
	{
		for(obj = findchainfloat(objclass, OBJ_FLAGBASE); obj; obj = obj.chain)
		{
			if(obj.team == e.variant)
				teamflags++;
		}
		
		if(teamflags <= 1)
		for(obj = list_teamchain; obj; obj = obj.teamchain)
		{
			if(obj.team == e.variant)
			{
				SH_RemoveEnt(obj);
				break;
			}
		}
	}
	
	if(e.objclass == OBJ_PATH)
	{
		oldid = e.pathgroupid;
		DeletePoint(e);
		
		keepid = FALSE;
		for(obj = findchainfloat(pathgroupid, oldid); obj; obj = obj.chain)
		{
			if(obj.objclass == OBJ_PATH)
			if(obj != e)
				keepid = TRUE;
		}
		
		if(!keepid)
			ClearEntIDFields(pathgroupid, oldid);
	}
			
	ClearEntIDFields(triggerobjectiveentid, e.entid);
	ClearEntIDFields(triggerentid, e.entid);		
	ClearEntIDFields(targetentid, e.entid);	
	ClearEntIDFields(targetstagetwoentid, e.entid);
	ClearEntIDFields(targetstagethreeentid, e.entid);	
	ClearEntIDFields(associationentid, e.entid);
	
	if(e.objclass == OBJ_TRAIN)
	{
		if(e.isdeletedformission)
			return;	
	
		ResetTrainData(e);
		e.isdeletedformission = TRUE;
		e.onlydrawforadmins = TRUE;
		e.solid = SOLID_NOT;
		e.movetype = MOVETYPE_NONE;
		MakeObjectInvisibleToClients(e);
		SendObjectToClients(e);
	}
	else
	{
		RemoveChildren(e);	
		SH_RemoveEnt(e);
	}
	
	SetUpEntPointers();
	UpdateTriggers();
}

void Admin_UndeleteEnt(float e_id) =
{
	local entity e;

	e = GetAdminEnt(e_id);
	if(!e)
		return;
		
	if(!e.isdeletedformission)
		return;
		
	if(e.objclass == OBJ_TRAIN)
	{
		e.isdeletedformission = FALSE;
		e.onlydrawforadmins = FALSE;
		e.modelindex = e.originalmodelindex;
		Func_oself(e, func_train_initialize);
		SendObjectToClients(e);
	}
}

void SetMissionLock(float lock) =
{
	mission_locked = lock;
	WriteByte(MSG_ALL, SVC_TEMPENTITY);	
	WriteByte(MSG_ALL, TE_MISSIONLOCKSTATUS);	
	WriteByte(MSG_ALL, lock);		
}