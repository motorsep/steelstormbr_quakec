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
void SetPathModelForOrientation(entity e) =
{
	if(!e.nextpathpoint)
		SetAndPrecacheModel(e, "models/misc/waypoint2.dpm");
	else
	{
		local vector ang;
		SetAndPrecacheModel(e, "models/misc/waypoint.dpm");
		ang = vectoangles(e.nextpathpoint.origin - e.origin);
		e.angles_y = ang_y;
	}
}

void SetPathModelForOrientationLead(entity point) =
{
	local entity e;
	e = list_pathchain;
	while(e)
	{
		if(e.nextpathpoint == point)
			SetPathModelForOrientation(e);
		e = e.pathchain;
	}
}

float AllowPathConnection(entity e) =
{
	local entity cursorpath;
	
	if(marker.objclass == OBJ_PATH)
		cursorpath = marker;
	else
	if(movingent.objclass == OBJ_PATH)
		cursorpath = movingent;
	
	if(cursorpath)
	if(e.objclass == OBJ_PATH
	&& e.prevpathpoint != cursorpath
	&& e.nextpathpoint != cursorpath
	&& cursorpath.prevpathpoint != e
	&& cursorpath.nextpathpoint != e
	&& !(cursorpath.nextpathpoint && e.nextpathpoint)
	&& e.temppathconnection != cursorpath)
		return true;
		
	return false;
}

/*float SetNewPathGroupIDForSeveredPath(entity e, float newid) =
{
	local float initialid, dumpcount;
	local entity initiale, lastdumpfrom;
	
	initiale = e;
	initialid = false;
	dumpcount = 0;
	
	if(!newid)
	{
		newid = GetNewPathGroupID(true);
		initialid = e.pathgroupid;
	}

	while(e && e.pathgroupid != newid)
	{
		e.pathgroupid = newid;

		if(e.prevpathpoint.pathgroupid != newid)
		if(e.prevpathpoint.nextpathpoint == e)
			SetNewPathGroupIDForSeveredPath(e.prevpathpoint, newid);
		
		if(e.nextpathpoint.prevpathpoint != e)
			break;
		
		e = e.nextpathpoint;
	}
	
	if(initialid)
	{
		if(initiale)
		if(!initiale.prevpathpoint)
		{
			e = list_pathchain;
			while(e)
			{
				if(e.nextpathpoint == initiale)
				{
					dumpcount++;
					if(dumpcount > 1)
						break;
					lastdumpfrom = e;
				}
				e = e.pathchain;
			}

			if(dumpcount == 1)
			{
				initiale.prevpathpoint = lastdumpfrom;
				SetNewPathGroupIDForSeveredPath(lastdumpfrom, newid);
			}
		}

		e = list_pathchain;
		while(e)
		{
			if(e.pathgroupid == initialid)
				return newid;
			e = e.pathchain;
		}

		e = list_pathchain;
		while(e)
		{
			if(e.pathgroupid == newid)
				e.pathgroupid = initialid;

			e = e.pathchain;
		}
	}
	
	return initialid;
}*/

void ExtendPath() =
{
	connectingpathfrom = admin_editingent;
	PlacePathConnection();
}

void TransferAIPathIDFromMissingPath(float oldid, float newid) =
{
	local entity e;

	if(!oldid)
		return;
	
	e = list_pathchain;
	while(e)
	{
		if(e.pathgroupid == oldid)
			return;
		e = e.pathchain;
	}
	
	e = findchainfloat(pathgroupid, oldid);//list_aichain;
	while(e)
	{
		if(e.objclass != OBJ_PATH)
			e.pathgroupid = newid;
		e = e.chain;
	}
	
//	e = list_aichain;
//	{
//		if(e.pathgroupid == oldid)
//			e.pathgroupid = newid;
//		e = e.aichain;
//	}
}

/*void DeletePoint() =
{
	local entity nextpoint, e;
	local float oldid;
	nextpoint = admin_editingent.nextpathpoint;

	PathChain_Remove(admin_editingent);

//	if(admin_editingent.prevpathpoint)
//	{
//		admin_editingent.prevpathpoint.nextpathpoint = world;
//		SetPathModelForOrientation(admin_editingent.prevpathpoint);		
//	}
	
	if(admin_editingent.nextpathpoint.prevpathpoint == admin_editingent)
	{
		nextpoint.prevpathpoint = world;
	
		e = list_pathchain;
		while(e)
		{
			if(e.pathgroupid == nextpoint.pathgroupid)
			if(e.nextpathpoint == nextpoint)
			{
				nextpoint.prevpathpoint = e;
				break;
			}
			
			e = e.pathchain;
		}
		
		SetPathModelForOrientation(admin_editingent.nextpathpoint);
	}
	
	oldid = admin_editingent.pathgroupid;
//	admin_editingent.pathgroupid = 0;
	TransferAIPathIDFromMissingPath(oldid, 0);
	
	e = list_pathchain;
	while(e)
	{
		if(e.nextpathpoint == admin_editingent)
		{
			e.nextpathpoint = world;
			SetPathModelForOrientation(e);	
		}
			
		e = e.pathchain;
	}
	
	admin_editingent.pathgroupid = 0;
	admin_editingent.nextpathpoint = world;
	admin_editingent.prevpathpoint = world;
	SetPathModelForOrientation(admin_editingent);	
	
	if(admin_editingent.isshared)
	{
	//	DeletedPathChain_Add(admin_editingent);	
		admin_editingent.markedfordeletion = true;
		admin_editingent.alpha = 0.5;
	//	admin_editingent.drawmask = false;
	}
	else	
		SH_RemoveEnt(admin_editingent);		
		
//	admin_editingent = world;
	
	if(nextpoint)
		SetNewPathGroupIDForSeveredPath(nextpoint, false);	
	
//	CloseMenu();
}*/

void TemporaryPathConnection_Prev() =
{
	connectingpathfrom = admin_editingent.prevpathpoint;
	admin_editingent.prevpathpoint.temppathconnection = self;
}

void TemporaryPathConnection_Next() =
{
//	connectingfrompath = self;
	self.temppathconnection = admin_editingent.nextpathpoint;
}

/*void SetPathSplit_Prev() =
{
	PathChain_Add(placedent);
	
	admin_editingent.prevpathpoint.temppathconnection = world;
	admin_editingent.prevpathpoint.nextpathpoint = placedent;	

	placedent.pathgroupid = admin_editingent.pathgroupid;
	
	placedent.prevpathpoint = admin_editingent.prevpathpoint;	
	admin_editingent.prevpathpoint = world;	
	
	SetNewPathGroupIDForSeveredPath(admin_editingent, false);

	SetPathModelForOrientation(placedent);
	SetPathModelForOrientationLead(placedent);
}*/

/*void SetPathSplit_Next() =
{
	PathChain_Add(placedent);
	
	placedent.temppathconnection = world;
//	admin_editingent.prevpathpoint.temppathconnection = world;
	if(admin_editingent.nextpathpoint.prevpathpoint == admin_editingent)
	{
		admin_editingent.nextpathpoint.prevpathpoint = placedent;	
		placedent.pathgroupid = admin_editingent.pathgroupid;
	}
	
	placedent.nextpathpoint = admin_editingent.nextpathpoint;	
	admin_editingent.nextpathpoint = world;	
	
	SetNewPathGroupIDForSeveredPath(admin_editingent, false);
	SetNewPathGroupIDForSeveredPath(placedent, false);
	
//	placedent.pathgroupid = admin_editingent.pathgroupid;	

	SetPathModelForOrientation(placedent);
	SetPathModelForOrientationLead(placedent);
	SetPathModelForOrientation(admin_editingent);	
}*/

/*void SplitPathFromPrev() =
{
	PlaceEntity(OBJ_PATH, 		0,		TemporaryPathConnection_Prev,	SetPathSplit_Prev);
}*/

/*void SplitPathFromNext() =
{
	PlaceEntity(OBJ_PATH, 		0,		TemporaryPathConnection_Next,	SetPathSplit_Next);
}*/

/*void SplicePaths() =
{
	admin_editingent.nextpathpoint.prevpathpoint = admin_editingent;
	SetNewPathGroupIDForSeveredPath(admin_editingent, false);
}*/

/*void CommitPathGroup() =
{
	local entity e, starte, nexte;
	local string cmd;
	
	e = starte = findchainfloat(pathgroupid, admin_editingent.pathgroupid);
	while(e)
	{
		if(e.markedfordeletion)
		{
			cmd = strcat(cmd, "cmd remove_path");
			cmd = AppendToken(cmd, SEP_SPACE, ftos(e.owner.id));
			cmd = strcat(cmd, "\n");
		}
		else
		{
		//	e.origin_base = e.origin;
		//	e.angles_base = e.angles;

			cmd = strcat(cmd, "cmd commit_path");
			cmd = AppendToken(cmd, SEP_SPACE, ftos(e.owner.id));
			cmd = PrepLine_Path(cmd, e);
			cmd = strcat(cmd, "\n");
		}
			
		e = e.chain;
	}
	
		print(cmd);	
	
	e = starte;
	while(e)
	{
		nexte = e.chain;
	
		if(!e.owner.id) // temp client ent that previously didn't exist on the server
			SH_RemoveEnt(e);
	
		e = nexte;
	}
	
	cmd = strcat(cmd, SEP_SPACE);
	cmd = strcat(cmd, "cmd commit_path_end\n");
	
	localcmd(cmd);
	CloseMenu();
}*/

//.float	restricted;

string GetCommitPathsString() =
{
	local entity e, nexte;
	local string cmd;
	
	e = list_pathchain;
	while(e)
	{
//		if(!e.restricted)
		{
			cmd = strcat(cmd, "cmd commit_path");
			cmd = AppendToken(cmd, SEP_SPACE, ftos(e.owner.id));
			cmd = PrepLine_Path(cmd, e);
			cmd = strcat(cmd, "\n");
		}
			
		e = e.pathchain;
	}
	
/*	e = list_deletedpathchain;
	while(e)
	{
		nexte = e.deletedpathchain;
	
		cmd = strcat(cmd, "cmd remove_path");
		cmd = AppendToken(cmd, SEP_SPACE, ftos(e.owner.id));
		cmd = strcat(cmd, "\n");		
		SH_RemoveEnt(e);
		
		e = nexte;//e.deletedpathchain;
	}*/
	
	e = list_pathchain;
	while(e)
	{
		nexte = e.pathchain;
	
		if(!e.isshared)//owner.id) // temp client ent that previously didn't exist on the server
		{
			ClearPointer_Entfield(nextpathpoint, e);
			ClearPointer_Entfield(prevpathpoint, e);
			SH_RemoveEnt(e);
		}
	
		e = nexte;
	}
	
	return cmd;
}

/*void CommitPaths() =
{
	localcmd(GetCommitPathsString());
	CloseMenu();	
}*/

/*void Draw_CommitPathsConfirmation() =
{
	Menu_Start_ConfirmationMenu("Commit Path Groups?", '0 0 0');
	Menu_Option_Text("Yes", CommitPaths);
	Menu_Option_Text("No", CloseMenu);
	Menu_End();
}*/

void ClearPathGroup() =
{
	local string cmd;
	cmd = strcat("cmd remove_pathgroup ", ftos(admin_editingent.pathgroupid));
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
	CloseMenu();
}

void ClearPathGroupOld() =
{
	local entity e, removepoint, nextremovepoint;
	local float groupid;

	groupid = admin_editingent.pathgroupid;

	removepoint = list_pathchain;
	while(removepoint)
	{
		nextremovepoint = removepoint.pathchain;	
	
		if(removepoint.pathgroupid == groupid)
		{
			PathChain_Remove(removepoint);

			e = list_pathchain;
			while(e)
			{
				if(e.pathgroupid != removepoint.pathgroupid)
				if(e.nextpathpoint == removepoint)
				{
					e.nextpathpoint = world;
					SetPathModelForOrientation(e);	
				}
					
				e = e.pathchain;
			}
		
			if(removepoint.isshared)
			{
			//	DeletedPathChain_Add(removepoint);
				removepoint.markedfordeletion = true;
				removepoint.alpha = 0.5;
			}		
			else
				SH_RemoveEnt(removepoint);
		}

		removepoint = nextremovepoint;
	}	
		
//	admin_editingent = world;
	
//	CloseMenu();
}

/*void SetAIPatrolPath() =
{
	if(hover_ent.owner == admin_editingent.owner)
		SetCurrentMenu(Draw_MisionEditor_etAIPatrolPathError_CantLinkToSelf);
	else
	if(hover_ent.objclass == CLASS_PATH)
	{
		if(hover_ent.owner.entid)
		{
			admin_editingent.owner = hover_ent.pathgroupid;
			CloseMenu();	
			SetCurrentMenu(Draw_MisionEditor_SetAIPatrolPath_LinkSuccessful);
		}
		else
			SetCurrentMenu(Draw_MisionEditor_SetAIPatrolPathError_DestinationDoesntExist);
	}
	else
		print("Not a path point.\n");	
}*/

/*void ClearAIPatrolPathLinkingData() =
{
	assigningaipatrolpath = false;
//	TogglePathPointVisibility();	
}*/

/*void Draw_MisionEditor_SetAIPatrolPath_LinkSuccessful() =
{
	Menu_Start_ConfirmationMenu("", '300 0 0');
	Menu_Text("AI path set successfully.");
	BR();
	Menu_Option_Text("Continue", CloseMenu);
	Menu_End();
}*/

void SetAIPatrolPath() =
{
	if(!LinkRules(hover_ent))
		return;

	admin_editingent.owner.pathgroupid = hover_ent.pathgroupid;
//	SetMovementBehaviorPatrol();
	CloseMenu();
//	SetCurrentMenu(Draw_MisionEditor_SetAIPatrolPath_LinkSuccessful);
	CommitObject(admin_editingent);
}

void Draw_MissionEditorSetAIPatrolPath() =
{
	Menu_Start_MissionEditor("Select Patrol Path", __FUNC__);
	
	Menu_Option_Text("Select", ObjectLinkFunc);	
	Menu_Option_Text_Cancel("Cancel", CloseMenu);
	
	Menu_End();		
}

float LinkRules_AIPatrolPath(entity e) =
{
	if(e.objclass == OBJ_PATH)
		return true;
		
	return false;
}

void CallSetAIPatrolPath() =
{
//	TogglePathPointVisibility();
	SetCurrentMenu(Draw_MissionEditorSetAIPatrolPath);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetAIPatrolPath;
	LinkRules = LinkRules_AIPatrolPath;	
	linkingobj = true;
	assigningaipatrolpath = true;
}

void DrawPathConnections() =
{
	if(!adminmode)
		return;

	if(!(editingpaths || assigningaipatrolpath || admin_editingent.owner.movement_behavior == MB_PATROL))
	{
		if(list_pathchain)
		if(list_pathchain.drawmask)
			TogglePathPointVisibility();
		return;	
	}
	else
	if(list_pathchain)
	if(!list_pathchain.drawmask)
		TogglePathPointVisibility();
		
	local entity e, p, drawto, closestpath;
	local vector ofs;
	local vector dist, closestdist;
	ofs = '0 0 32';
		
	local vector screenpos;		

	e = list_controlentchain;//findchainfloat(class, CLASS_CONTROLENT); // FIXME use a linked list
	while(e)
	{
		if(e.objclass != OBJ_PATH)
		if(e.owner.pathgroupid)
		{
			p = list_pathchain;
			while(p)
			{
				if(p.pathgroupid == e.owner.pathgroupid)
				{
					dist = e.origin - p.origin;
				
					if(!closestpath || dist*dist < closestdist*closestdist)
					{
						closestpath = p;
						closestdist = dist;
					}
				}
				
				p = p.pathchain;
			}
			
			if(closestpath)
				DrawPolygonBeam(e.origin+ofs, closestpath.origin+ofs, linklineimage, '1 0 0', 0);	
			//	trailparticles(e, particleeffectnum("TE_PATHCONNECTIONLINEAI"), e.origin+ofs, closestpath.origin+ofs);
				
		//	screenpos = cs_project(e.origin);
		//	screenpos_z = 0;
		//	drawstring(screenpos, ftos(e.owner.pathgroupid), '8 8 0', '1 1 1', 1, 0);		
		}
		
		closestpath = world;
		closestdist = '0 0 0';
	
		e = e.controlentchain;
	}
	
/*	e = list_deletedpathchain;
	while(e)
	{
		screenpos = cs_project(e.origin);
		screenpos_z = 0;
		drawstring(screenpos, ftos(e.entid), '8 8 0', '1 1 1', 1, 0);
		e = e.deletedpathchain;
	}*/
	
	e = list_pathchain;
	while(e)
	{
		screenpos = cs_project(e.origin);
		screenpos_z = 0;
		drawstring(screenpos, ftos(e.pathgroupid), '8 8 0', '1 1 1', 1, 0);
	
	//	if(e.prevpathpoint)
	//		trailparticles(e, particleeffectnum("TE_PATHCONNECTIONLINEPREV"), e.origin+ofs, e.prevpathpoint.origin+ofs);
	
		if(e.nextpathpoint /*&& e.nextpathpoint.drawmask*/ && !e.temppathconnection && !(marker.temppathconnection && marker.temppathconnection == e.nextpathpoint && admin_editingent == e))
		{		
			if(e.nextpathpoint.prevpathpoint == e)
			{
				if(assigningaipatrolpath)
				if(admin_editingent.owner.pathgroupid == e.pathgroupid)
					trailparticles(e, PEF_PATHCONNECTIONLINEFORAI, e.origin+ofs, e.nextpathpoint.origin+ofs);
			
				if(e.pathgroupid == admin_editingent.pathgroupid)
					trailparticles(e, PEF_PATHCONNECTIONLINESELECTEDGROUP, e.origin+ofs, e.nextpathpoint.origin+ofs);
				else
					trailparticles(e, PEF_PATHCONNECTIONLINE, e.origin+ofs, e.nextpathpoint.origin+ofs);
			}
			else
			{
				if(assigningaipatrolpath)
				if(admin_editingent.owner.pathgroupid == e.pathgroupid)			
					trailparticles(e, PEF_PATHCONNECTIONLINEFORAI, e.origin+ofs, e.nextpathpoint.origin+ofs);
			
				if(e.pathgroupid == admin_editingent.pathgroupid)
					trailparticles(e, PEF_PATHCONNECTIONLINESELECTEDGROUPTRANSFER, e.origin+ofs, e.nextpathpoint.origin+ofs);
				else
					trailparticles(e, PEF_PATHCONNECTIONLINETRANSFER, e.origin+ofs, e.nextpathpoint.origin+ofs);
			}
		}
		else
		if(e.temppathconnection)
			trailparticles(e, PEF_PATHCONNECTIONLINETEMP, e.origin+ofs, e.temppathconnection.origin+ofs);

		e = e.pathchain;
	}
	
	if(marker.temppathconnection)
		trailparticles(marker, PEF_PATHCONNECTIONLINETEMP, marker.origin+ofs, marker.temppathconnection.origin+ofs);
}

//.float	pathgroupid;

void Draw_MissionEditor_PlacingPath() =
{
	Menu_Start_MissionEditor("Placing Path", __FUNC__);
	
	Menu_Option_Text("Place", PlaceMarkerAtLocation);	
	Menu_Option_Text_Cancel("Cancel", RemoveMarkerAndCloseMenu);
	
	Menu_End();
}

/*void UpdateDeletedPathIDs(float oldid, float newid) =
{
	local entity e;
	e = list_deletedpathchain;
	while(e)
	{
		if(e.pathgroupid == oldid)
			e.pathgroupid = newid;
	
		e = e.deletedpathchain;
	}
}*/

/*void LinkToHoverEntPath() =
{
	local float oldid;
	oldid = connectingpathfrom.pathgroupid;
	
	if(connectingpathfrom)
	{
		connectingpathfrom.temppathconnection = world;
		connectingpathfrom.nextpathpoint = hover_ent;
	
		if(!hover_ent.prevpathpoint)
		{
			hover_ent.prevpathpoint = connectingpathfrom;
			SetNewPathGroupIDForSeveredPath(connectingpathfrom, hover_ent.pathgroupid);
		}	
	}
	
	if(PostMarkerPlacedFunc == SetPathSplit_Prev)
	{
		admin_editingent.prevpathpoint = world;	
		SetNewPathGroupIDForSeveredPath(admin_editingent, false);
	}			
	
	TransferAIPathIDFromMissingPath(oldid, hover_ent.pathgroupid);	
	
	if(connectingpathfrom)
		SetPathModelForOrientation(connectingpathfrom);
		
	connectingpathfrom = world;
}*/

/*void ReversedLinkToHoverEntPathOld() =
{
//	connectingpathfrom.temppathconnection = world;
	hover_ent.nextpathpoint = movingent.nextpathpoint;
	
//	if(!movingent.prevpathpoint)
//	{
		movingent.nextpathpoint.prevpathpoint = hover_ent;
		SetNewPathGroupIDForSeveredPath(hover_ent.nextpathpoint, hover_ent.pathgroupid);
//	}	
	
	SetPathModelForOrientation(hover_ent);
//	connectingpathfrom = world;
}*/

/*void ReversedLinkToHoverEntPath() =
{
//	connectingpathfrom.temppathconnection = world;
	hover_ent.nextpathpoint = admin_editingent.nextpathpoint;
	
//	if(!movingent.prevpathpoint)
//	{
		admin_editingent.nextpathpoint.prevpathpoint = hover_ent;
		SetNewPathGroupIDForSeveredPath(hover_ent.nextpathpoint, hover_ent.pathgroupid);
//	}	
	
	SetPathModelForOrientation(hover_ent);
//	connectingpathfrom = world;
}*/

void ConnectNextPathPoint() =
{
	placedent.pathgroupid = connectingpathfrom.pathgroupid;
	placedent.prevpathpoint = connectingpathfrom;	
	connectingpathfrom.temppathconnection = world;
	connectingpathfrom.nextpathpoint = placedent;
	SetPathModelForOrientation(connectingpathfrom);
	connectingpathfrom = placedent;
	PathChain_Add(placedent);	
	SetPathModelForOrientation(placedent);	
	PlacePathConnection();
	pathfunctions = pathfunctions | PATHFUNC_EXTEND;
}

void BeginNewPathPlacement() =
{
	placedent.pathgroupid = -1;//GetNewPathGroupID(true);
//	placedent.temppathconnection = world;
	connectingpathfrom = placedent;
	PathChain_Add(placedent);
	SetPathModelForOrientation(placedent);	
	PlacePathConnection();
}

void TemporaryPathConnection() =	{	connectingpathfrom.temppathconnection = self;	}

void PlacePathConnection() =	{	PlaceEntity(OBJ_PATH, 		0,		TemporaryPathConnection,	ConnectNextPathPoint);	}
void CreateNewPath() =			{	PlaceEntity(OBJ_PATH, 		0,		SUB_Null,					BeginNewPathPlacement);	}

void Draw_MissionEditor_Pathing() =
{
	Menu_Start_MissionEditor("Pathing", __FUNC__);
	
	Menu_Option_Text("New Path", CreateNewPath);
	BR();
//	Menu_CallSubMenu_Text("Commit Paths", Draw_CommitPathsConfirmation);
//	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}

void TogglePathPointVisibility() =
{
	local entity e;
	e = list_pathchain;
	while(e)
	{
		if(e.drawmask == MASK_NORMAL)
			e.drawmask = false;
		else
			e.drawmask = MASK_NORMAL;
			
		e = e.pathchain;
	}

}

void EndPathingEditMode() =
{
	editingpaths = false;
//	TogglePathPointVisibility();
}

void Toggle_MissionEditor_Pathing() =	{		editingpaths = !editingpaths;	}

void Call_MissionEditor_Pathing() =
{
	editingpaths = true;
//	TogglePathPointVisibility();
	SetCurrentMenu(Draw_MissionEditor_Pathing);
	currentmenu.CloseMenuFunc = EndPathingEditMode;
}