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
void NonsolidChain_Add(entity e) =	{	list_nonsolidsolidchain = LinkedList_Add(e, list_nonsolidsolidchain, nonsolidsolidchain, nonsolidsolidchain_prev);	}
void NonsolidChain_Remove(entity e) =	{	list_nonsolidsolidchain = LinkedList_Remove(e, list_nonsolidsolidchain, nonsolidsolidchain, nonsolidsolidchain_prev);	}

void AmbientSoundChain_Add(entity e) =	{	list_ambientsoundchain = LinkedList_Add(e, list_ambientsoundchain, ambientsoundchain, ambientsoundchain_prev);	}
void AmbientSoundChain_Remove(entity e) =	{	list_ambientsoundchain = LinkedList_Remove(e, list_ambientsoundchain, ambientsoundchain, ambientsoundchain_prev);	}

void SectorChain_Add(entity e) =	{	list_sectorchain = LinkedList_Add(e, list_sectorchain, sectorchain, sectorchain_prev);	}
void SectorChain_Remove(entity e) =	{	list_sectorchain = LinkedList_Remove(e, list_sectorchain, sectorchain, sectorchain_prev);	}

void LoadingSectorEntChain_Add(entity e) =	{	list_loadingsectorentchain = LinkedList_Add(e, list_loadingsectorentchain, loadingsectorentchain, loadingsectorentchain_prev);	}
void LoadingSectorEntChain_Remove(entity e) =	{	list_loadingsectorentchain = LinkedList_Remove(e, list_loadingsectorentchain, loadingsectorentchain, loadingsectorentchain_prev);	}

void RemoveChildren(entity e_parent) =
{
	local entity e, nexte;
//	e = nextent(world);
	e = e_parent.list_childchain;
	while(e)
	{
		nexte = e.childchain;
	//	if(e.owner == e_parent)
//		if(e.class == CLASS_OBJECT)
//		if(!e.tag_entity)
//		{
//			SetOwner(e, world);//e.owner = world;
//			Func_oself(e, InitLongExplode);
//		}
		if(e != e_parent)
			SH_RemoveEnt(e);
	
		e = nexte;//e.childchain;
//		e = nextent(e);
	}
}

void SH_RemoveEnt(entity e) =
{
	if(!e.tag_entity)
	if(e.objclass == OBJ_NPC || e.class == CLASS_PLAYER)
	if(!(e.behaviorflags & BF_FLIES))
	if(!(e.behaviorflags & BF_STATIONARY))// || e.class == CLASS_PLAYER)
	{
		if(e.objclass == OBJ_NPC)
		{
			UnmarkGrid(e, TRUE, FALSE);
			RemoveUnusedCells(e, e.gridpos);
		}
		else
		if(e.class == CLASS_PLAYER)
			UnmarkGrid(e, FALSE, TRUE);
	}
//	else
//		UnmarkGrid(e, FALSE, TRUE);

	if(e.carrier)
		e.carrier.flagent = world;

	RemoveTagEnts(e);
	RemoveOwnedEnts(e);
	NonsolidChain_Remove(e);
	ObjectChain_Remove(e);
	AmbientSoundChain_Remove(e);
	LoadingSectorEntChain_Remove(e);
	
	e.trigger = world;
	e.forcefieldgate = world;
	e.particleemittereffect = freezone(e.particleemittereffect);
	e.ambientsoundeffect = freezone(e.ambientsoundeffect);
	e.targetname_pointer = freezone(e.targetname_pointer);
//	e.objectname = freezone(e.objectname);
	
	RemoveEnt(e);
	if(e.class != CLASS_PLAYER)
		remove(e);		
}

void BindToWorld(entity e) =
{

	
	traceline(e.origin+'0 0 8', e.origin + '0 0 -10000', TRUE, self);

}

void WriteScoreStat(float STAT, float value) =
{
	local float FLAG;
	FLAG = GetScoreFlag(STAT);
	if(self.ScoreFlags & FLAG)
		WriteLong(MSG_ENTITY, value);
}

void SendScoreInfo(float sendflags) =
{
//	if(sendflags & SFL_SCORE || sendflags & SFL_SCORE_ACCURACY)
//		WriteShort(MSG_ENTITY, self.accuracy*10);

	if(sendflags & SFL_PING)
		WriteLong(MSG_ENTITY, self.ping);

	if(!sendflags & SFL_SCORE)
		return;
		
	WriteLong(MSG_ENTITY, self.ScoreFlags);
	
	WriteScoreStat(SCORESTAT_SCOREPLACING, self.scoreplacing);	
	WriteScoreStat(SCORESTAT_SCORE, self.points);
	WriteScoreStat(SCORESTAT_CAPTURES, self.captures);
	WriteScoreStat(SCORESTAT_RETURNS, self.returns);
	WriteScoreStat(SCORESTAT_FRAGS_PLAYER, self.frags);
	WriteScoreStat(SCORESTAT_FRAGS_AI, self.frags_npc);
	WriteScoreStat(SCORESTAT_FRAGS_OTHER, self.frags_other);
	WriteScoreStat(SCORESTAT_DEATHS, self.deaths);
	WriteScoreStat(SCORESTAT_SUICIDES, self.suicides);
	WriteScoreStat(SCORESTAT_ACCURACY, self.accuracy*100);
	WriteScoreStat(SCORESTAT_DAMAGE_DEALT, self.damagedealt);
}

void UpdateScore(entity e, float SCORE_FLAG) =
{
	local float FLAG;
	
	FLAG = GetScoreFlag(SCORE_FLAG);
	e.SendFlags = e.SendFlags | SFL_SCORE;
	e.ScoreFlags = e.ScoreFlags | FLAG;	
}

void SendEventFlags(float sendflags) =
{
	if(sendflags & SFL_ANIMATE)
		WriteLong(MSG_ENTITY, self.sfl_animation);

	if(sendflags & SFL_SOUND)
		WriteLong(MSG_ENTITY, self.sfl_sound);		
}

void SetEventFlag(entity e, float FLAGTYPE, .float flagfield, .float eventfield, float flagnum) =
{
	e.SendFlags = e.SendFlags | FLAGTYPE;
	e.flagfield = flagnum*2+e.eventfield;
	e.eventfield = !e.eventfield;

	if(FLAGTYPE == SFL_SOUND)
		e.eventflag_sound_time = time;
	else
	if(FLAGTYPE == SFL_ANIMATE)
		e.eventflag_animation_time = time;
}

void SetEventFlag_Sound(entity e, float flagnum) =	{	SetEventFlag(e, SFL_SOUND, sfl_sound, eventflag_sound, flagnum);	}

void SetEventFlag_Animation(entity e, float flagnum) =	{	SetEventFlag(e, SFL_ANIMATE, sfl_animation, eventflag_animation, flagnum);	}

float SetDefaultSharedStats(entity e) =
{
	local vector org;

	if(!e.id)
	{
		e.origin_base = e.origin;
		e.angles_base = e.angles;
	}


	if(e.origin_base == '0 0 0')
		org = e.origin;
	else
		org = e.origin_base;
	
	if(org_x > world.maxs_x
	|| org_x < world.mins_x
	|| org_y > world.maxs_y
	|| org_y < world.mins_y
	|| org_z > world.maxs_z
	|| org_z < world.mins_z)
	{
		dprint("Removing object outside of world bounds.\n");
		SH_RemoveEnt(e);
		return FALSE;
	}	
	
	return TRUE;
}

void UpdateSharedOrientationData(entity e, float SFLAG, float isnewvalue) =
{
	if(!(isnewvalue || e.stopflags & SFLAG))	// if there is no new value to be sent and no event matching the current flag is in progress, then return
		return;
	
	if(e.stopflags & SFLAG && !isnewvalue)	// if an event is in progress and there is nothing new
	{
		e.SendFlags = e.SendFlags | (SFLAG*2);	// stop the event on the client
		e.stopflags -= e.stopflags & SFLAG;		// stop the event on the server
	}
	else
		e.stopflags = e.stopflags | SFLAG;	// tell the server an event is in progress that needs to notify the client when it stops

	e.SendFlags = e.SendFlags | SFLAG;		// send the updated value(s)
}

void UpdateSharedEnt(entity e) =
{
	if(!e.mobile)
		e.SendFlags = e.SendFlags | TRUE;
	else
	if(e.updatetime <= time)
	{
		e.updatetime += SV_UPDATEDELAY;
		UpdateSharedOrientationData(e, SFL_ANGLES, e.angles_y != e.oldyaw || (e.class == CLASS_SHOT && e.angles_x != e.oldpitch));
		UpdateSharedOrientationData(e, SFL_ORIGIN, e.origin != e.oldorigin2);
		
		if(e.nextSendFlags)// & SFL_TELEPORT)
		{
			e.SendFlags = e.SendFlags | e.nextSendFlags;
			e.nextSendFlags = 0;//-= e.nextSendFlags & SFL_TELEPORT;
		}
		
		if(e.class == CLASS_SHOT)
			e.oldpitch = e.angles_x;
		e.oldyaw = e.angles_y;
		e.oldorigin2 = e.origin;
	}
}

/*void InitializeStaticSharedEnt() =
{
	if(self.postinitthink)
	{
		self.nextthink = time+random();
		self.think = self.postinitthink;
		
		self.postinitthinktime = 0;
		self.postinitthink = SUB_Null;
	}
}*/

void RemoveFallenObject() =
{
	self.velocity = '0 0 0';
	if(!droptofloor())
	{
		dprint(self.netname);
		dprint(" object fell out of level at ");
		dprint(vtos(self.origin));
		dprint("\n");
		SH_RemoveEnt(self);
	}
}

void UnstickObject() =
{
	local vector ang, ofs;
	local float updist, outdist;

	traceline(self.origin, self.origin + '0 0 -100', FALSE, self);	
//	droptofloor(0, 0);
	updist += 8;
	while(!droptofloor() || trace_fraction == 1)
	{
		ang_y += 45;
		
		if(ang_y >= 360)
		{
			ang_y = 0;
			updist += 2;
			outdist += 20;
		}
	
		makevectors(ang);
		ofs = self.origin_base + v_forward*outdist;
		ofs_z = updist;
	
		setorigin(self, ofs);
		traceline(self.origin, self.origin + '0 0 -100', FALSE, self);		
//		droptofloor(0, 0);
	}
	
	self.origin_base = self.origin;
}

float IsStuck(entity e) =
{
	local entity oself;
	oself = self;
	self = e;
	
	setorigin(self, self.origin + '0 0 8');
	
	droptofloor(); 
	
	if(!walkmove(0,0))
	{
		self = oself;
		return TRUE;
	}

	self = oself;
	return FALSE;
}

void InitializeObjectOrientation(entity e) =
{
	if(spawningsectorents)
	{
		setorigin(e, e.origin);
		return;
	}

//	e.angles = e.angles_base;	

	e.angles_x = e.angles_base_x;

	if(e.chullrotation == CHULLROT_ALL)
	if(!e.isusingcollisionhull)
		e.angles_y = e.angles_base_y;
	
/*	if(e.chullrotation != CHULLROT_ALL)
	{
		if((e.angles_base_y/45) - (floor(e.angles_base_y/45)))
		{
			angfloor = floor(e.angles_base_y/45)*45;
			angceil = ceil(e.angles_base_y/45)*45;
			
			if(AngleDifference(angfloor, self.angles_base_y) < AngleDifference(angceil, self.angles_base_y))
				e.angles_base_y = angfloor;
			else
				e.angles_base_y = angceil;
		}
		
		if((e.angles_base_y/90) - (floor(e.angles_base_y/90))) // if chull is at 45 degrees subtract 45 degrees from chull angles to match alt chull model
			e.angles_y = e.angles_base_y - 45;
		else
			e.angles_y = e.angles_base_y;
	}
	else*/
//		e.angles_y = e.angles_base_y;
	
	local vector ofs;
	
	if(e.isallowedtofloat)
		setorigin(e, e.origin_base);
	else
	{
	//	tracebox(e.origin_base+'0 0 256', '-16 -16 0', '16 16 16', e.origin_base+'0 0 -512', TRUE, e);
	//	traceline(e.origin_base+'0 0 256', e.origin_base+'0 0 -512', TRUE, e);
	
		if(e.objclass == OBJ_NPC)
			ofs = '0 0 8';
		else
			ofs = '0 0 1';
	
		setorigin(e, e.origin_base+ofs);	
	
	//	Func_oself(e, RemoveFallenObject);
	}
	
//	local entity oself;
//	oself = self;
//	self = e;
//	droptofloor(0, 0);
//	self = oself;
	
//	Func_oself(e, UnstickObject);
	
//	e.velocity = '0 0 0';
}

void InitializeSharedEnt(entity e) =
{
	if(IsAssignedFunction(e.postinitthink))
	{
		Func_oself(e, e.postinitthink);
		e.postinitthink = SUB_Null;
	}
	
	if(spawningsectorents)// && time < 1)
		LoadingSectorEntChain_Add(e);
	else
	if(adminmodeactive && !admin_reloadingents && !list_playerchain.playerchain)
		e.SendFlags = FALSE;
	else
		e.SendFlags = SFL_ISNEW;
}

float ManageSendFlags(float sendflags) =
{
	local float origionalsendflags;
	origionalsendflags = sendflags;

	if(self.eventflag_animation_time+1 < time || !self.sfl_animation)
		sendflags -= sendflags & SFL_ANIMATE;
	
	if(self.eventflag_sound_time+1 < time || !self.sfl_sound)
		sendflags -= sendflags & SFL_SOUND;	
	
	if(origionalsendflags == SFL_ISNEW)
	{
//		if(!self.sfl_animation)
//			sendflags -= sendflags & SFL_ANIMATE;
//		if(!self.sfl_sound)
//			sendflags -= sendflags & SFL_SOUND;
//		sendflags -= sendflags & SFL_DAMAGE_REPAIRED;
		sendflags -= sendflags & SFL_EXPLODE;
	}			

	if(self.teleporttouchtime < time)
		sendflags -= sendflags & SFL_TELEPORT;
	
	if(!(self.health <= 0))
		sendflags -= sendflags & SFL_EXPLODE;
		
/*	if(!self.max_health
	|| !self.health
	|| (self.health > self.max_health*0.66)
	|| (self.health <= self.max_health*0.33)
	|| !(self.damage_effects & DMGEF_BURN))
		sendflags -= sendflags & SFL_DAMAGE_STAGE1;
		
	if(!self.max_health
	|| !self.health
	|| (self.health > self.max_health*0.33)
	|| !(self.damage_effects & DMGEF_BURN))
		sendflags -= sendflags & SFL_DAMAGE_STAGE2;*/
			
//		sendflags -= sendflags & SFL_HIDE;


	return sendflags;
}

float SharedEntAdminRules(float sendflags, entity viewer) =
{
	local float origionalsendflags;
	
	origionalsendflags = sendflags;

	sendflags = ManageSendFlags(sendflags);

	if(self.onlydrawforadmins)
	if(!viewer.adminmode)
	if(!sendflags & SFL_EXPLODE)
		return FALSE;
	
//	sendflags -= sendflags & SFL_EDITABLE;
//	sendflags -= sendflags & SFL_REVERT;

/*	if(self.editor == viewer)
	{
		if(origionalsendflags & SFL_EDITABLE)
			sendflags = sendflags | SFL_EDITABLE;
		
//		if(origionalsendflags != SFL_ISNEW)
//		if(origionalsendflags & SFL_REVERT)
//			sendflags = sendflags | SFL_REVERT;
	}*/
	//	if(self.npcclass == NPC_MICROFLYER)
	//		print("trying to removing micro basedata\n");
//	if((newadmin && viewer != newadmin) || (!newadmin && !viewer.adminmode) || !IsBaseEnt(self))//self.owner != self)//self.origin_base == '0 0 0')
	if(!viewer.adminmode || !IsBaseEnt(self))	
	{
	//	if(self.npcclass == NPC_MICROFLYER)
	//		print("removing micro basedata\n");
	
		sendflags -= sendflags & SFL_BASEDATA;
		}
		
	return sendflags;
}

void SendSharedEntStats(float sendflags) =
{
	local float hashealth, maptargetid;
	local entity maptarget;
	
	if(sendflags & SFL_EFFECTS)
		WriteLong(MSG_ENTITY, self.effectflags);
	
	if(!(sendflags & SFL_RESET))
		return;

	if(self.max_health)
		hashealth = TRUE;
		
	if(self.objclass == OBJ_TELEPORTER)
	if(self.targetentid)
	{
		maptarget = findfloat(world, entid, self.targetentid); 	
		maptargetid = maptarget.id;	
	}
	
	WriteLong(MSG_ENTITY, self.id);
	WriteByte(MSG_ENTITY, self.istoggled);	
	WriteByte(MSG_ENTITY, self.activated);
	WriteByte(MSG_ENTITY, self.isdead);
	WriteByte(MSG_ENTITY, self.deadmodelnum);
	WriteLong(MSG_ENTITY, self.triggerobjectiveentid);
	WriteByte(MSG_ENTITY, self.mapicon);
	WriteLong(MSG_ENTITY, maptargetid);
	WriteByte(MSG_ENTITY, hashealth);
	WriteByte(MSG_ENTITY, self.terminaltype);
	WriteLong(MSG_ENTITY, self.object_activationtime);
	WriteByte(MSG_ENTITY, self.requireskey);
	WriteLong(MSG_ENTITY, self.team);
}

void SendSharedEntBaseData(float sendflags) =
{
	if(!sendflags & SFL_BASEDATA)
		return;

	WriteLong(MSG_ENTITY, self.entid);		
	WriteLong(MSG_ENTITY, self.targetstagetwoentid);
	WriteLong(MSG_ENTITY, self.targetstagethreeentid);
	WriteLong(MSG_ENTITY, self.triggerentid);
	WriteLong(MSG_ENTITY, self.targetentid);	
	WriteLong(MSG_ENTITY, self.associationentid);
	WriteByte(MSG_ENTITY, self.isdeletedformission);
	WriteByte(MSG_ENTITY, self.startstateoff);
	WriteLong(MSG_ENTITY, self.triggerdelaytime);
	WriteByte(MSG_ENTITY, self.touchtrigger);
	WriteShort(MSG_ENTITY, self.maxtriggers);
	WriteByte(MSG_ENTITY, self.multiplayeronly);
	
	WriteShort(MSG_ENTITY, self.spawner_max_areaents);
	WriteShort(MSG_ENTITY, self.spawner_max_ents);
	WriteShort(MSG_ENTITY, self.spawner_max_lighttanks);
	WriteShort(MSG_ENTITY, self.spawner_max_mediumtanks);
	WriteShort(MSG_ENTITY, self.spawner_max_lightningtanks);
	WriteShort(MSG_ENTITY, self.spawner_max_heavytanks);
	
	WriteCoord(MSG_ENTITY, self.origin_base_x);
	WriteCoord(MSG_ENTITY, self.origin_base_y);
	WriteCoord(MSG_ENTITY, self.origin_base_z); // unnecessary
	WriteCoord(MSG_ENTITY, self.angles_base_x);
	WriteCoord(MSG_ENTITY, self.angles_base_y);
	WriteCoord(MSG_ENTITY, self.angles_base_z);	// unnecessary
	
	WriteShort(MSG_ENTITY, self.movement_behavior);
	WriteLong(MSG_ENTITY, self.pathgroupid);	
	
	WriteByte(MSG_ENTITY, self.permanent);
}

void SendDeathData(float sendflags) =
{
	if(!sendflags & SFL_EXPLODE)
		return;
	//WriteByte(MSG_ENTITY, explodevelocity);

	WriteByte(MSG_ENTITY, self.deadmodelnum);
}

.float filloccupancy;
/*float SendCell(entity viewer, float sendflags) =
{
//	if(!viewer.adminmode)
//		return FALSE;
		
//	if(!viewer.viewingnavigationcells)
//		return FALSE;

	local entity connection;

	WriteByte(MSG_ENTITY, CLASS_CELL);
	WriteLong(MSG_ENTITY, self.id);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);	*/
	
/*	connection = GetCellConnection(self, 0, FALSE);//self.(cellconnection[0]);
	WriteLong(MSG_ENTITY, connection.id);
	connection = GetCellConnection(self, 1, FALSE);//self.(cellconnection[1]);
	WriteLong(MSG_ENTITY, connection.id);
	connection = GetCellConnection(self, 2, FALSE);//self.(cellconnection[2]);
	WriteLong(MSG_ENTITY, connection.id);
	connection = GetCellConnection(self, 3, FALSE);//self.(cellconnection[3]);
	WriteLong(MSG_ENTITY, connection.id);*/
	
/*	WriteCoord(MSG_ENTITY, self.occupancy);
	
	return TRUE;
}*/

float SendObjective(entity viewer, float sendflags) =
{
	WriteByte(MSG_ENTITY, ENT_OBJECTIVE);
	WriteLong(MSG_ENTITY, sendflags);
	
	WriteByte(MSG_ENTITY, self.istoggled);	

	if(sendflags & SFL_RESET)
	{
		WriteLong(MSG_ENTITY, self.id);
		WriteLong(MSG_ENTITY, self.entid);
//		WriteString(MSG_ENTITY, self.objectivetext);
		WriteByte(MSG_ENTITY, self.objectivepriority);
	}
	
	return TRUE;
}

float SendTrain(entity viewer, float sendflags) =
{
	float bits, addflags;
	
	sendflags = SharedEntAdminRules(sendflags, viewer);		
	
	if(sendflags & SFL_BASEDATA)
		addflags = addflags | SFL_BASEDATA;
		
//	self.SendFlags = 0;
	// inherit send bits which change the type of data sended
	bits = 32; // always fade
	if (self.angles_x || self.angles_z) bits |= 1;
	if (self.velocity != '0 0 0') bits |= 2;	
	if (self.avelocity != '0 0 0') bits |= 4;	
	if (sendflags & SFL_RESET) { bits |= 8; if (self.originalmodelindex > 255) bits |= 16;	}
	
	bits = bits | addflags;
	
	// send base
	WriteByte(MSG_ENTITY, ENT_TRAIN);
	WriteLong(MSG_ENTITY, bits);
	
	// always write current orientation, optional y-only or xyz angles
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	if (bits & 1)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
		WriteCoord(MSG_ENTITY, self.angles_z);
	}
	else WriteCoord(MSG_ENTITY, self.angles_y);

	// send full update?, modelindex could be 1 byte of 2 bytes
	if (bits & 8)
	{
		WriteLong(MSG_ENTITY, self.id);
		WriteString(MSG_ENTITY, self.targetname);
		if (bits & 16)
			WriteShort(MSG_ENTITY, self.originalmodelindex);
		else
			WriteByte(MSG_ENTITY, self.originalmodelindex);
	}
	
	// train-related stuff
	if (bits & 2)
	{
		WriteCoord(MSG_ENTITY, self.velocity_x);
		WriteCoord(MSG_ENTITY, self.velocity_y);
		WriteCoord(MSG_ENTITY, self.velocity_z);
	}
	if (bits & 4)
	{
		WriteCoord(MSG_ENTITY, self.avelocity_x);
		WriteCoord(MSG_ENTITY, self.avelocity_y);
		WriteCoord(MSG_ENTITY, self.avelocity_z);
	}
	
	SendSharedEntBaseData(bits);
	
	return TRUE;
}

float SendPath(entity viewer, float sendflags) =
{
	sendflags = SharedEntAdminRules(sendflags, viewer);		
	
	if(!sendflags)
		return FALSE;

	local float islastplacedpoint;	
		
	WriteByte(MSG_ENTITY, ENT_PATH);
	WriteLong(MSG_ENTITY, sendflags);
	WriteLong(MSG_ENTITY, self.id);
	WriteLong(MSG_ENTITY, self.entid);
	WriteLong(MSG_ENTITY, self.pathgroupid);
	WriteLong(MSG_ENTITY, self.prevpathpointid);
	WriteLong(MSG_ENTITY, self.nextpathpointid);
	WriteLong(MSG_ENTITY, self.targetentid);
	WriteLong(MSG_ENTITY, self.triggerobjectiveentid);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);	
	
	if(viewer.lastplacedpathpoint == self)
		islastplacedpoint = TRUE;
	WriteByte(MSG_ENTITY, islastplacedpoint);
		
//	if(sendflags & SFL_EDITABLE)
//	{
//		WriteLong(MSG_ENTITY, self.oldpathgroupid);
//		self.oldpathgroupid = 0;
//	}
	
	return TRUE;
}

float SendAmbientSound(entity viewer, float sendflags) =
{
	sendflags = SharedEntAdminRules(sendflags, viewer);		
	
	if(!sendflags)
		return FALSE;

	WriteByte(MSG_ENTITY, ENT_AMBIENTSOUND);
	WriteLong(MSG_ENTITY, sendflags);
	WriteLong(MSG_ENTITY, self.id);
	WriteLong(MSG_ENTITY, self.entid);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);	
	WriteString(MSG_ENTITY, self.ambientsoundeffect);
	
	SendSharedEntBaseData(sendflags);	
	
	return TRUE;
}

float SendParticleEmitter(entity viewer, float sendflags) =
{
	sendflags = SharedEntAdminRules(sendflags, viewer);		
	
	if(!sendflags)
		return FALSE;

	WriteByte(MSG_ENTITY, ENT_PARTICLEEMITTER);
	WriteLong(MSG_ENTITY, sendflags);
	WriteLong(MSG_ENTITY, self.id);
	WriteLong(MSG_ENTITY, self.entid);
	WriteByte(MSG_ENTITY, self.istoggled);
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);	
	WriteCoord(MSG_ENTITY, self.angles_x);
	WriteCoord(MSG_ENTITY, self.angles_y);
	WriteString(MSG_ENTITY, self.particleemittereffect);
	
	SendSharedEntBaseData(sendflags);	
	
	return TRUE;
}

float SendTeam(entity viewer, float sendflags) =
{
	WriteByte(MSG_ENTITY, ENT_TEAM);
	WriteLong(MSG_ENTITY, sendflags);

	if(sendflags & SFL_RESET)
		WriteLong(MSG_ENTITY, self.team);
	
	if(sendflags & SFL_SCORE)
		WriteLong(MSG_ENTITY, self.points*10);
		
	return TRUE;
}

float SendObject(entity viewer, float sendflags) =
{
//	if(!viewer.adminmode)
//	if(time - viewer.jointime > 1)
//	if(self == list_loadingsectorentchain || self.loadingsectorentchain || self.loadingsectorentchain_prev)
//		return FALSE;

	local float vel_len, pushvel_len;

	sendflags = SharedEntAdminRules(sendflags, viewer);		

//	if(self.modelflags & MF_ROTATE)
//		sendflags -= sendflags & SFL_ANGLES;
		
//	if(!self.mobile)
//		sendflags -= sendflags & SFL_ORIGIN;

	if(!sendflags)
		return FALSE;
	
//	if(!self.mobile)
//		sendflags = sendflags | SFL_ORIGIN | SFL_ANGLES;		
		
	WriteByte(MSG_ENTITY, ENT_OBJECT);
	WriteLong(MSG_ENTITY, sendflags);

	SendSharedEntStats(sendflags);
	
	WriteByte(MSG_ENTITY, self.mobile);
	
	if(sendflags & SFL_RESET)
	{
		WriteLong(MSG_ENTITY, self.objclass);
		WriteLong(MSG_ENTITY, self.variant);
		WriteLong(MSG_ENTITY, self.scale*10);
		if(self.objclass == OBJ_FLAG)
			WriteLong(MSG_ENTITY, self.carrier.id);
	}
//	WriteLong(MSG_ENTITY, self.id);
//	WriteLong(MSG_ENTITY, self.entid);
//	WriteLong(MSG_ENTITY, self.targetentid);
//	WriteLong(MSG_ENTITY, self.triggerentid);
//	WriteByte(MSG_ENTITY, self.istoggled);

//	WriteCoord(MSG_ENTITY, self.origin_base_x);
//	WriteCoord(MSG_ENTITY, self.origin_base_y);
//	WriteCoord(MSG_ENTITY, self.origin_base_z);
//	WriteCoord(MSG_ENTITY, self.angles_base_y);

	if(sendflags & SFL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		vel_len = vlen(self.origin - self.lastorigin)/frametime;//self.velocity);
		
/*		vel_len = vlen(self.velocity);
		
		if(self.oldorigin != '0 0 0')
		{
			pushvel_len = vlen(self.origin-self.oldorigin)*(1/frametime);

			if(pushvel_len > vel_len)
				vel_len = pushvel_len;		
		}*/
		
		WriteCoord(MSG_ENTITY, vel_len);	
	}
	
	if(sendflags & SFL_ANGLES)
		WriteCoord(MSG_ENTITY, self.angles_base_y);
	
	SendSharedEntBaseData(sendflags);

//	if(sendflags & SFL_SKIN)
//		WriteShort(MSG_ENTITY, self.skin);
	
	SendDeathData(sendflags);
	
	SendEventFlags(sendflags);	
	
	return TRUE;
}
 //.vector pushvelocity;
float SendPlayer(entity viewer, float sendflags) =
{
	local float vel_len, pushvel_len;

	sendflags = ManageSendFlags(sendflags);

	if(viewer == self)
		sendflags = sendflags | SFL_ISSELF;
	else
		sendflags -= sendflags & SFL_ISSELF;

	if(viewer != self || !self.lastentdamaged)
		sendflags -= sendflags & SFL_TARGETNAME;
	
	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteLong(MSG_ENTITY, sendflags);
	
//	if(sendflags & SFL_TARGETNAME)
//		WriteString(MSG_ENTITY, self.lastentdamaged.objectname);
	
//	if(sendflags & SFL_RESET)
//		WriteLong(MSG_ENTITY, self.id);
	
	if(sendflags & SFL_STATE)
		WriteByte(MSG_ENTITY, self.buttonchat_old);
		
	SendSharedEntStats(sendflags);
	
	if(sendflags & SFL_BASEDATA)
	{
		WriteString(MSG_ENTITY, self.netname);		
		WriteCoord(MSG_ENTITY, self.player_colors_x);
		WriteCoord(MSG_ENTITY, self.player_colors_y);
		WriteCoord(MSG_ENTITY, self.player_colors_z);
	}
	
	if(sendflags & SFL_RESET)
	{
		WriteByte(MSG_ENTITY, self.hasguestaccess);
		WriteByte(MSG_ENTITY, self.hasadminaccess);
	}
	
	if(sendflags & SFL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
		
		vel_len = vlen(self.origin - self.lastorigin)/frametime;//self.velocity);		
		
/*		vel_len = vlen(self.velocity);
		
		if(self.oldorigin != '0 0 0')
		{
			pushvel_len = vlen(self.origin-self.oldorigin)*(1/frametime);

			if(pushvel_len > vel_len)
				vel_len = pushvel_len;		
		}*/
		
		WriteCoord(MSG_ENTITY, vel_len);
	}
	
	if(sendflags & SFL_ANGLES)
		WriteCoord(MSG_ENTITY, self.angles_y);
		
/*	if(sendflags & SFL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.pushvelocity_x);
		WriteCoord(MSG_ENTITY, self.pushvelocity_y);
		WriteCoord(MSG_ENTITY, self.pushvelocity_z);		
	}
	
	if(sendflags & SFL_ANGLES)
		WriteCoord(MSG_ENTITY, self.avelocity_y);*/
		
	if(sendflags & SFL_SCOREMULTIPLIER)
		WriteLong(MSG_ENTITY, self.scoremultiplier);	
		
	SendDeathData(sendflags);
	
	SendEventFlags(sendflags);
	
	SendScoreInfo(sendflags);
	
	return TRUE;
}	

/*float DistanceSendInterval(entity viewer) =
{
	local entity o;

	if(self.tag_entity)
		o = self.owner;
	else
		o = self;
		
	if(vlen(o.origin - viewer.origin) <= 2000)
		return TRUE;
		
	return FALSE;
}*/

float SendNPC(entity viewer, float sendflags) =
{
//	if(!viewer.adminmode)
//	if(time - viewer.jointime > 1)
//	if(self == list_loadingsectorentchain || self.loadingsectorentchain || self.loadingsectorentchain_prev)
//		return FALSE;

//	if(!DistanceSendInterval(viewer))
//		return FALSE;

	local float vel_len, pushvel_len;

	sendflags = SharedEntAdminRules(sendflags, viewer);
		
	if(viewer != self.killedby || !self.scoremultiplier)
		sendflags -= sendflags & SFL_SCOREMULTIPLIER;
		
	if(!sendflags)
		return FALSE;

	WriteByte(MSG_ENTITY, ENT_NPC);
	WriteLong(MSG_ENTITY, sendflags);
	
//	WriteLong(MSG_ENTITY, self.id);
//	WriteLong(MSG_ENTITY, self.entid);	
	SendSharedEntStats(sendflags);
	
	if(sendflags & SFL_RESET)
	{
		WriteByte(MSG_ENTITY, self.npcclass);
		WriteByte(MSG_ENTITY, self.team);	
	
/*	if(floor(self.npcclass) == NPC_STATIONARYTURRET)
	{
		print(ftos((self.npcclass-NPC_STATIONARYTURRET)*10));	print("\n");
	
		WriteByte(MSG_ENTITY, (self.npcclass-NPC_STATIONARYTURRET)*10);
		}*/
	
		if(IsAttachedAIClass(self.npcclass))// == NPC_TURRET)
		{
			WriteLong(MSG_ENTITY, self.owner.id);
			WriteShort(MSG_ENTITY, self.variant);
			WriteShort(MSG_ENTITY, self.tag_index);
		}
	}
		
	if(sendflags & SFL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);

		vel_len = vlen(self.origin - self.lastorigin)/frametime;//self.velocity);
		
//		if(self.oldorigin != '0 0 0')
//		{
//			pushvel_len = vlen(self.origin-self.oldorigin)*(1/frametime);

//			if(pushvel_len > vel_len)
//				vel_len = pushvel_len;		
//		}
		
		WriteCoord(MSG_ENTITY, vel_len);
	}

	if(sendflags & SFL_ANGLES)
	{
		if(self.npcclass == NPC_MICROFLYER)
			WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);
	}		
	
	SendSharedEntBaseData(sendflags);

	if(sendflags & SFL_SCOREMULTIPLIER)
	{
		WriteLong(MSG_ENTITY, self.scoremultiplier);	
		self.killedby = world;
		self.scoremultiplier = 0;
	}
	
//	if(sendflags & SFL_RESET)
//		WriteLong(MSG_ENTITY, self.pathgroupid);	
	
	SendDeathData(sendflags);
	
/*	local float so_spawnedfrom;
	if(sendflags & SFL_TELEPORT)
	{
		if(IsAttachedAIClass(self.npcclass))// == NPC_TURRET)
			so_spawnedfrom = self.owner.spawnedfrom;
		else
			so_spawnedfrom = self.spawnedfrom;
	
		WriteShort(MSG_ENTITY, so_spawnedfrom);
	}*/
	
	SendEventFlags(sendflags);	
	
	return TRUE;
}

float SendBullet(entity viewer, float sendflags) =
{
	WriteByte(MSG_ENTITY, ENT_BULLET);
	WriteByte(MSG_ENTITY, self.shotvariant);
//	WriteLong(MSG_ENTITY, self.owner.id);
	
	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);
	WriteCoord(MSG_ENTITY, self.angles_x);
	WriteCoord(MSG_ENTITY, self.angles_y);
	WriteLong(MSG_ENTITY, self.shotlen);	
	WriteLong(MSG_ENTITY, self.hit);		
	
/*	if(IsAttachedAIClass(self.owner.npcclass))// == NPC_TURRET)
	{
		WriteCoord(MSG_ENTITY, self.owner.owner.angles_y+self.owner.angles_y);
		WriteLong(MSG_ENTITY, self.shotlen_x);	
		WriteLong(MSG_ENTITY, self.hit);
	}
	else
	{
		WriteCoord(MSG_ENTITY, self.owner.angles_y);
		WriteLong(MSG_ENTITY, self.shotlen_x);
		WriteLong(MSG_ENTITY, self.hit);
		WriteLong(MSG_ENTITY, self.shotlen_y);	
		WriteLong(MSG_ENTITY, self.(hit[1]));		
	}*/

	return TRUE;
}

float SendBeam(entity viewer, float sendflags) =
{
	WriteByte(MSG_ENTITY, ENT_BEAM);
	WriteByte(MSG_ENTITY, self.shotvariant);
	
//	WriteLong(MSG_ENTITY, self.owner.id);

	WriteCoord(MSG_ENTITY, self.origin_x);
	WriteCoord(MSG_ENTITY, self.origin_y);
	WriteCoord(MSG_ENTITY, self.origin_z);	
	WriteCoord(MSG_ENTITY, self.angles_x);
	WriteCoord(MSG_ENTITY, self.angles_y);
		
	WriteLong(MSG_ENTITY, self.shotlen);
	WriteLong(MSG_ENTITY, self.hit);
	
	if(self.shotvariant == BEAM_THUNDERBOLT
	|| self.shotvariant == BEAM_LIGHTNINGBOLT)
		WriteLong(MSG_ENTITY, self.owner.id);
		
	return TRUE;
}

float SendProjectile(entity viewer, float sendflags) =
{// FIXME MINIMIZE SENDFLAGS
	if(self.mute)
		sendflags -= sendflags & SFL_AUDIBLE;
	
	WriteByte(MSG_ENTITY, ENT_PROJECTILE);
	WriteLong(MSG_ENTITY, sendflags);
	WriteByte(MSG_ENTITY, self.shotvariant);
	
	if(sendflags & SFL_RESET)
		WriteLong(MSG_ENTITY, self.parent.entid);
	
	if(sendflags & SFL_ORIGIN)
	{
		WriteCoord(MSG_ENTITY, self.origin_x);
		WriteCoord(MSG_ENTITY, self.origin_y);
		WriteCoord(MSG_ENTITY, self.origin_z);
		WriteCoord(MSG_ENTITY, vlen(self.velocity));
	}

	if(sendflags & SFL_ANGLES)
	{
		WriteCoord(MSG_ENTITY, self.angles_x);
		WriteCoord(MSG_ENTITY, self.angles_y);	
	}		
	
	if(self.shotvariant == PROJ_STORMSHIELD)
	{
		WriteLong(MSG_ENTITY, self.owner.owner.id);
		WriteByte(MSG_ENTITY, self.ballnum);
		WriteCoord(MSG_ENTITY, self.direction);
	}
	
	WriteCoord(MSG_ENTITY, self.hit);

	return TRUE;
}