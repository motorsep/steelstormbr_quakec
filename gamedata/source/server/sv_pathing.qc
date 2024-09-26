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
void InitializePath(entity e) =
{
	if(((!e.id && missionfileexists) || (e.multiplayeronly && singleplayer)) && !e.permanent)	
	{
		SH_RemoveEnt(e);
		return;
	}

//	Func_oself(e, DropObject);	

	SetOwner(e, e);
	SetParent(e, e);
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_PATH;

	SetID(e);		
	
	MakeObjectInvisibleToClients(e);
	e.SendEntity = SendPath;	
	
	PathChain_Add(e);
	ObjectChain_Add(e);	
}

void path_point() =
{
	InitializePath(self);
}

float SetNewPathGroupIDForSeveredPath(entity e, float newid) =
{
	local float initialid, dumpcount;
	local entity initiale, lastdumpfrom;
	
	initiale = e;
	initialid = FALSE;
	dumpcount = 0;
	
	if(!newid)
	{
		newid = GetNewPathGroupID(FALSE);
		initialid = e.pathgroupid;
	}

	while(e && e.pathgroupid != newid)
	{
		e.pathgroupid = newid;
		SendObjectToClients(e);

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
			{
				e.pathgroupid = initialid;
				SendObjectToClients(e);
			}

			e = e.pathchain;
		}
	}
	
	return initialid;
}

void Remove_PathGroup(float groupid) =
{
	local entity e;

	for(e = findchainfloat(pathgroupid, groupid); e; e = e.chain)
		SH_RemoveEnt(e);

	ClearEntIDFields(pathgroupid, groupid);
	SetUpEntPointers();
}

void DeletePoint(entity deletepoint) =
{
	local entity nextpoint, e;
	local float oldid;
	
	nextpoint = deletepoint.nextpathpoint;

	PathChain_Remove(deletepoint);

//	if(admin_editingent.prevpathpoint)
//	{
//		admin_editingent.prevpathpoint.nextpathpoint = world;
//		SetPathModelForOrientation(admin_editingent.prevpathpoint);		
//	}
	
	if(nextpoint.prevpathpoint == deletepoint)
	{
		nextpoint.prevpathpointid = 0;
		nextpoint.prevpathpoint = world;
	
		e = list_pathchain;
		while(e)
		{
			if(e.pathgroupid == nextpoint.pathgroupid)
			if(e.nextpathpoint == nextpoint)
			{
				nextpoint.prevpathpointid = e.entid;
				break;
			}
			
			e = e.pathchain;
		}
	}
	
	e = list_pathchain;
	while(e)
	{
		if(e.nextpathpoint == deletepoint)
		{
			e.nextpathpointid = 0;
			e.nextpathpoint = world;
			SendObjectToClients(e);	
		}
			
		e = e.pathchain;
	}
	
	deletepoint.pathgroupid = 0;
	deletepoint.nextpathpoint = world;
	deletepoint.prevpathpoint = world;
	
	if(nextpoint)
		SetNewPathGroupIDForSeveredPath(nextpoint, FALSE);	
}

void SetUpPaths(entity e, entity oldpath_next, entity oldpath_prev, float isnew) =
{
	local entity pointA, pointB;

	if(e.pathgroupid < 0)
		e.pathgroupid = GetNewPathGroupID(FALSE);	
	
	if(isnew)
		self.lastplacedpathpoint = e;		
	
	
	if(pathfunctions & PATHFUNC_CONNECT)
	{
		pointA = GetLinkedListEnt_float(list_pathchain, pathchain, entid, e.prevpathpointid);
		pointB = GetLinkedListEnt_float(list_pathchain, pathchain, entid, e.nextpathpointid);
		
		pointA.nextpathpointid = pointB.entid;
		
		if(!pointB.prevpathpoint
		|| pointB.prevpathpoint == e)
			pointB.prevpathpointid = pointA.entid;

		if(pointA.pathgroupid != pointB.pathgroupid)	
			SetNewPathGroupIDForSeveredPath(pointA, pointB.pathgroupid);
			
		SendObjectToClients(pointA);
		SendObjectToClients(pointB);
		SH_RemoveEnt(e);
		return;
	}
	
	
	if(pathfunctions & PATHFUNC_EXTEND)
	{
		pointA = GetLinkedListEnt_float(list_pathchain, pathchain, entid, e.prevpathpointid);
		pointA.nextpathpointid = e.entid;
		SendObjectToClients(pointA);
	}		
	
/*	if(e.nextpathpointid)
	{
		point = GetLinkedListEnt_float(list_pathchain, pathchain, entid, e.nextpathpointid);
		point.prevpathpointid = e.entid;
		point.effects = point.effects | EF_NODEPTHTEST;
		point.SendFlags = SFL_ISNEW;
	}	*/
	
	SendObjectToClients(e);
}