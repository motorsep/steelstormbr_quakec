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
void ObjectHealth(entity e, float OBJCLASS, float VARIANT) =
{
	local float dmgfx;
	dmgfx = 0;
	
	switch(OBJCLASS)
	{
		case OBJ_STRUCTURE:
		
			if(e.indestructible)
				e.health = 0;
			else		
			if(VARIANT == STRUCTURE_GASPUMP)
				e.health = 0;
			else
			if(VARIANT == STRUCTURE_INCINERATOR)
				e.health = 5000;		
			else
			if(VARIANT == STRUCTURE_HANGAR)
				e.health = 2500;		
			else
			if(VARIANT == STRUCTURE_COOLINGTOWER || VARIANT == STRUCTURE_COOLINGTOWER_TWIN)
				e.health = 1000;		
			else
			if(VARIANT == STRUCTURE_OBELISK)
				e.health = 25000;		
			else
			if(VARIANT == STRUCTURE_REFINERY)
				e.health = 5000;
			else
			if(VARIANT == STRUCTURE_EVAPORATOR)
				e.health = 0;	
			else
			if(VARIANT == STRUCTURE_BBOSS)
				e.health = 5000;
			else
			if(VARIANT == STRUCTURE_BBOSS_SMALL)
				e.health = 3000;
			else
				e.health = 1500;
				
			dmgfx = DMGEF_BURN;
			e.max_health = e.health;
		break;

		case OBJ_STONE:				e.health = e.max_health = 150;							break;
		case OBJ_ENVCRYSTAL:		e.health = e.max_health = 150;							break;		
		case OBJ_EQUIPMENT:			e.health = e.max_health = 25;	dmgfx = DMGEF_BURN;		break;
		case OBJ_EQUIPMENT_BIG:		e.health = e.max_health = 85;	dmgfx = DMGEF_BURN;		break;
		case OBJ_EQUIPMENT_MED:		e.health = e.max_health = 65;	dmgfx = DMGEF_BURN;		break;
		case OBJ_TREE:				e.health = e.max_health = 50;							break;
		case OBJ_PLANT:				e.health = e.max_health = 25;							break;	
		case OBJ_FUSIONCORERACK:	e.health = e.max_health = 175;	dmgfx = DMGEF_BURN;		break;
	}
	
	e.damage_effects = e.damage_effects | dmgfx;
	
//	if(spawningsectorents)
//	{
//		e.health = enthealth;
//		enthealth = 0;
//	}
}

void ObjectExplosionDamage(entity e, float OBJCLASS, float VARIANT) =
{
	switch(OBJCLASS)
	{
		case OBJ_STRUCTURE:
			if(VARIANT == STRUCTURE_INCINERATOR)
				e.explosiondamage = 100;		
			else
			if(VARIANT == STRUCTURE_HANGAR)
				e.explosiondamage = 50;		
			else
			if(VARIANT == STRUCTURE_COOLINGTOWER || VARIANT == STRUCTURE_COOLINGTOWER_TWIN)
				e.explosiondamage = 50;		
			else
			if(VARIANT == STRUCTURE_OBELISK)
				e.explosiondamage = 100;		
			else
				e.explosiondamage = 50;
		break;

		case OBJ_EQUIPMENT:			e.explosiondamage = 20;		break;
		case OBJ_EQUIPMENT_BIG:		e.explosiondamage = 75;		break;
		case OBJ_EQUIPMENT_MED:		e.explosiondamage = 45;		break;
		case OBJ_FUSIONCORERACK:	e.explosiondamage = 600;	e.explosionradius = 1000;	break;
	}	
}

/*void SpawnCollisionHull(entity e, float CLASS, float VARIANT) =
{
	if(e.chull)
		return;

	print("spawning hull\n");
		
	switch(CLASS)
	{
		case CLASS_STRUCTURE:
			if(VARIANT == 0)	{		}
			else
			if(VARIANT == 1)	{		}
			else
			if(VARIANT == 2)	{		}
			else
			if(VARIANT == 3)	{	chullmodel = "models/objects/pylon/pylon_chull.bsp"	}			
		break;
	}
	
	e_model = e.model
	e.chull = spawn();
	SetAndPrecacheModel(e.chull, chullmodel);
	e.movetype = MOVETYPE_FOLLOW;
}*/

//void DropObject() =	{	droptofloor(0, 0);	}



float InitializeObject(entity e, float CLASS, float VARIANT, float SOLIDSTATE) =
{
	if(((!e.id && missionfileexists) || (e.multiplayeronly && singleplayer)) && !e.permanent)
	{
		SH_RemoveEnt(e);
		return FALSE;
	}

	if(!SetDefaultSharedStats(e))
		return FALSE;
	
	if(e.startstateoff)	
		e.istoggled = TRUE;	
	
//	SetObjectName(e, CLASS, VARIANT);
	
	SetOwner(e, e);//e.owner = e;
	SetParent(e, e);
	e.class = CLASS_OBJECT;	
	e.objclass = CLASS;	
	e.variant = VARIANT;
	e.showhealth = TRUE;
	SetID(e);
	
	ObjectHealth(e, CLASS, VARIANT);
	ObjectExplosionDamage(e, CLASS, VARIANT);
//	SetAndPrecacheModel(e, "");

	SetObjectAppearance(e, e.objclass, e.variant);
	
//	if(IsUsingCollisionHull(e))
	if(e.isusingcollisionhull) // collision hull
		SOLIDSTATE = SOLID_BSP;
	else
	if(e.maxs_z == e.mins_z) // flat
		SOLIDSTATE = SOLID_NOT;
	else
	if(e.issolidcorpse) // ?
		SOLIDSTATE = SOLID_CORPSE;
	
//	if(SOLIDSTATE != SOLID_BSP)
//		SetObjectSize(e, e.objclass, e.variant);

	e.solid = SOLIDSTATE;	

//	print(ftos(e.solid));print(" solid\n");
	
	e.SendEntity = SendObject;	
	
	ObjectChain_Add(e);

//	InitializeSharedEnt(e);	
	InitializeObjectOrientation(e);	
//	eprint(e);
	return TRUE;
}

void SetMapObject(entity e) =
{
	e.ismapobject = TRUE;
	e.effects = e.effects | EF_NODEPTHTEST;
}

void ToggleToggleable() =
{
	self.istoggled = !self.istoggled;
	SetObjectAppearance(self, self.objclass, self.variant);	
	self.SendFlags = self.SendFlags | SFL_RESET;
}

void object_toggleable() =
{
	InitializeObject(self, self.objclass, self.variant, SOLID_BBOX);
	self.TriggerFunc = ToggleToggleable;
}

void TrainChain_Add(entity e) =
{
	if(e.entid)
		return;

	e.trainchain = list_trainchain;
	list_trainchain = e;
}

void ClearCustomTrainData(entity e) =
{
	ClearEntData(e);
	e.triggerentid = 0;
	e.isdeletedformission = FALSE;
	e.startstateoff = FALSE;
	e.triggerdelaytime = 0;
	ResetTrainData(e);
}

void CustomizeTrain(entity e) =
{
	local entity train_info;
	
	TrainChain_Add(e);		
	
	if(strlen(e.targetname))
	{
		train_info = find(world, targetname_pointer, e.targetname);
		if(train_info)
		{
			e.entid = train_info.entid;
			e.triggerentid = train_info.triggerentid;
			e.isdeletedformission = train_info.isdeletedformission;
			e.startstateoff = train_info.startstateoff;
			e.triggerdelaytime = train_info.triggerdelaytime;
			SH_RemoveEnt(train_info);
		}
	}
	
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_TRAIN;			
	SetID(e);		
	e.SendEntity = SendTrain;		
	e.origin_base = e.origin;
	e.angles_base = e.angles;
	
	ObjectChain_Add(e);
}

void info_player_start() =
{
	if(GameMode_HasTeams(gamemode))
	{
		if(!self.variant)
			self.variant = 1;
	}
	else
		self.variant = 0;
		
	InitializeObject(self, OBJ_SPAWNPAD, self.variant, SOLID_BBOX);
}

void info_player_start2()       = {} // what is this?
void info_player_deathmatch()   = {}
void info_player_coop()         = {}

void SpawnTrigger(void() TouchFunc, vector ofs, float tsize) =
{
	local vector e_mins, e_maxs;

	if(self.trigger)
		return;

	if(!tsize)
		tsize = 64;
		
	self.trigger = spawn();
	setorigin(self.trigger, self.origin+ofs);
	self.trigger.solid = SOLID_TRIGGER;
	self.trigger.touch = TouchFunc;
	SetOwner(self.trigger, self);
	SetParent(self.trigger, self);
	e_mins_x = e_mins_y = tsize*-0.5;
	e_maxs_x = e_maxs_y = tsize*0.5;
	e_maxs_z = 128;
	setsize(self.trigger, e_mins, e_maxs);
}

void TeleporterTouch() =
{
	if(other.class != CLASS_PLAYER)
		return;
		
//	te_spark(self.origin, '0 0 10000', 100000);	
		
	local entity destteleporter;	
	local vector ofs;
	
	if(other.teleporttouchtime <= time)
	{
		if(self.owner.targetentid)
			destteleporter = GetLinkedListEnt_float(list_objectchain, objectchain, entid, self.owner.targetentid);
		
		if(!destteleporter)
			SetEventFlag_Sound(self.owner, SOUND_TELEPORT_ERROR);	
		else
		{
			SetMapObject(self.owner);
			SetMapObject(destteleporter);
			self.owner.activated = TRUE;
			destteleporter.activated = TRUE;
			self.owner.SendFlags = self.owner.SendFlags | SFL_RESET;
			destteleporter.SendFlags = destteleporter.SendFlags | SFL_RESET;
			ofs_z = self.maxs_z+2;

			other.angles = destteleporter.angles_base;
			other.fixangle = TRUE;
			other.oldorigin = destteleporter.origin+ofs;	
			setorigin(other,destteleporter.origin+ofs);		
			other.velocity = '0 0 0';
	
			self.owner.teleporttouchtime = time+0.1;
			self.owner.SendFlags = self.owner.SendFlags | SFL_TELEPORT;
			other.SendFlags = other.SendFlags | SFL_TELEPORT | SFL_ORIGIN | SFL_ORIGIN_STOP;
		}
	}
	
	other.teleporttouchtime = time+0.1;	
}

void object_teleporter() =
{
	if(!InitializeObject(self, OBJ_TELEPORTER, 0, SOLID_BSP))
		return;

	SpawnTrigger(TeleporterTouch, '0 0 0', 0);
}

void CloseTerminal() =
{
	msg_entity = self.user;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_TERMINAL_CLOSE);

	self.nextthink = 0;
	self.think = SUB_Null;
	self.user = world;
	self.activation_starttime = 0;
//	self.hastriggered_stagetwo = FALSE;
//	self.hastriggered_stagethree = FALSE;
	SetEventFlag_Animation(self, ANIM_TERMINAL_CLOSE);
}

void RunTerminal() =
{
	local float keys;

	if(!self.activation_starttime)
	{
		//open terminal
		msg_entity = self.user;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_TERMINAL_OPEN);
		WriteLong(MSG_ONE, self.id);
		self.activation_starttime = time;
		SetEventFlag_Animation(self, ANIM_TERMINAL_OPEN);
	}
	else
	{
		if(time >= self.activation_starttime + (1-0.33)*self.object_activationtime)
		if(!self.hastriggered_stagethree)
		{
			TriggerObjects(3);
			self.hastriggered_stagethree = TRUE;
		}

		if(time >= self.activation_starttime + (1-0.66)*self.object_activationtime)
		if(!self.hastriggered_stagetwo)
		{
			TriggerObjects(2);
			self.hastriggered_stagetwo = TRUE;
		}	

		if(time >= self.activation_starttime + self.object_activationtime)
		{
			if(self.requireskey)
			{
				TE_CenterPrint(self.user, CPM_USEDDATAKEY);
				keys = globalitem_datakeys[self.user.team-1];
				globalitem_datakeys[self.user.team-1] = keys - 1;
				self.keyed = TRUE;
			}		
		
			TriggerObjects(0);
			CloseTerminal();
			self.istoggled = TRUE;
			SetEventFlag_Sound(self, SOUND_TERMINAL_ACCEPT);
			return;
		}
	}
	
	self.nextthink = time+0.2;	
	self.think = CloseTerminal;
}

void TerminalTouch() =
{
	local float keys, missingkey, wrongteam;

	if(self.owner.istoggled)
		return;

	if(other.class != CLASS_PLAYER)
		return;
		
	if(other.health <= 0)
		return;
		
	keys = globalitem_datakeys[other.team-1];
		
	if(self.owner.requireskey)
	if(!self.owner.keyed)
	if(!keys)
		missingkey = TRUE;
	
	if(self.owner.team)
	{
		if(other.team != self.owner.team)
			wrongteam = TRUE;

		if(self.owner.terminaltype == TERMINAL_HACKING)
			wrongteam = !wrongteam;
	}
	
	if(missingkey || wrongteam)
	{
		if(other.messagetime < time)
		{
			other.messagetime = time+3;			
			SetEventFlag_Sound(self.owner, SOUND_TERMINAL_ERROR);
			if(missingkey)
			if(!wrongteam)
				TE_CenterPrint(other, CPM_FINDADATAKEY);
		}
		return;
	}
	
	if(!self.owner.user)
		self.owner.user = other;
	
	if(other == self.owner.user)
		Func_oself(self.owner, RunTerminal);
}

void object_terminal() =
{
	local vector ofs;

	if(!InitializeObject(self, OBJ_TERMINAL, self.variant, SOLID_BSP))
		return;

	makevectors(self.angles_base);
	if(self.variant == 0)
		ofs = v_forward*300;
	else
	if(self.variant == 1)
		ofs = v_forward*100;
		
	SpawnTrigger(TerminalTouch, ofs, 0);
}

void PickUpObject() =
{
//	TriggerObjects(0);

	self.touch = SUB_Null;

	if(self.pickupsound)
		SetEventFlag_Sound(other, self.pickupsound);
	else
		SetEventFlag_Sound(other, SOUND_PICKUP);	
		
	if(IsBaseEnt(self))
	{
		self.isdead = TRUE;	
		MakeObjectInvisibleToClients(self);
	}
	else
		SH_RemoveEnt(self);
}

void datakey_touch() =
{
	local float keys;

	if(!CanGetItem(other))
		return;

	keys = globalitem_datakeys[other.team-1];
	globalitem_datakeys[other.team-1] = keys+1;
	PickUpObject();
}

void object_datakey() =
{
	InitializeItem(OBJ_DATAKEY, self.variant, datakey_touch);
	self.pickupsound = SOUND_PICKUP_DATAKEY;
}

void corruptfusioncore_touch() =
{
	local float cores;

	if(!CanGetItem(other))
		return;
		
	cores = globalitem_corruptfusioncores[other.team-1];
	globalitem_corruptfusioncores[other.team-1] = cores+1;	
	PickUpObject();
}

void object_corruptfusioncore() =
{
	InitializeItem(OBJ_CORRUPTFUSIONCORE, self.variant, corruptfusioncore_touch);
	self.pickupsound = SOUND_PICKUP_CORRUPTFUSIONCORE;
}

void ExitPadTouch() =
{
	local entity e;

	if(other.class != CLASS_PLAYER)
		return;

	// don't bring up scoreboard and save scores if in local editor mode
	if(maxplayers == 1)
	if(!singleplayer)
		return;
		
	if(other.exittouchtime > time)
		return;
		
	other.exittouchtime = time+2;		
		
	if(adminmodeactive)
	{
	//	centerprint(other, "Cannot access exit pads while an administrator is actively editing the mission.");
		TE_CenterPrint(other, CPM_CANTACCESSEXITPADSWHILEADMINISEDITING);
		return;
	}
		
	for(e = list_objectivechain; e; e = e.objectivechain)
	{
		if(e.objectivepriority == 0)
		if(e.istoggled == 0)
		{
		//	centerprint(other, "You have not finished all of the primary objectives.");
			TE_CenterPrint(other, CPM_PRIMARYOBJECTIVESINCOMPLETE);
			return;
		}
	}
	
		
	self.touch = SUB_Null;
	
/*	objective = list_primaryobjectives;
	while(objective)
	{
		if(!objective.objective_complete)
		{
			centerprint("Primary objectives incomplete!");
			return;
		}
		
		objective = objective.objectivechain;
	}*/
	
	MissionScores(MSG_ALL);
}

void object_exitpad() =
{
	if(!GameMode_CanSpawnEnemies(gamemode))
	{
		SH_RemoveEnt(self);
		return;
	}
	
	if(!InitializeObject(self, OBJ_EXITPAD, 0, SOLID_BBOX))
		return;

	SpawnTrigger(ExitPadTouch, '0 0 0', 0);
}

/*void SpawnForcefieldGate() =
{
	if(self.forcefieldgate)
		return;
		
	if(!self.targetent)
		return;
		
	local vector size_mins, size_maxs;	
		
	self.forcefieldgate = self.targetent.forcefieldgate = spawn();
	setorigin(self.forcefieldgate, (self.origin + self.targetent.origin)*0.5);
	size_maxs_y = vlen(self.forcefieldgate.origin - self.targetent.forcefieldgate.origin)*0.5;
	size_maxs_x = 4;
	size_maxs_z = 128;
	size_mins_y = size_maxs_y*-1;
	size_mins_x = -4;
	setsize(self.forcefieldgate, size_mins, size_maxs);
	self.forcefieldgate.angles_y = self.angles_y+90;
	self.forcefieldgate.solid = SOLID_BSP;
}*/

.float ffprinttime;
void ForcefieldToggle() =
{
	local entity e;
	local float OCCUPY;
	local vector diff;
	
	self.istoggled = !self.istoggled;
	SetMapObject(self);
	self.activated = TRUE;
	SetObjectAppearance(self, self.objclass, self.variant);	
	self.SendFlags = self.SendFlags | SFL_RESET;
	
	for(e = list_aichain; e; e = e.aichain)
	{
		if(!(e.behaviorflags & BF_TURRET))
		{
			if(!e.behaviorflags & BF_FLIES)
				OCCUPY = TRUE;
		
			UnmarkGrid(e, TRUE, OCCUPY);
			RemoveUnusedCells(e, e.gridpos);
		//	MarkGrid(e, TRUE, OCCUPY, e.gridpos);
			OCCUPY = FALSE;
		}
	}
	
//	if(self.istoggled)
//	if(ffprinttime < time)
//	{
//		ffprinttime = time+3;
	
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(e.ffprinttime < time)
			{
				diff = e.origin - self.origin;
				if(diff*diff > 1600*1600)
				{
					e.ffprinttime = time+3;
					TE_CenterPrint(e, CPM_FORCEFIELDOPENED);
				}
			}
		}
//	}
		//	centerprint(e, "A forcefield has opened somewhere.\nCheck your map.");
}

void ForcefieldTouch() =
{
	if(self.istoggled)
		return;

	if(other.class != CLASS_PLAYER)
		return;
		
	if(!self.owner.istarget)
		return;
		
	if(other.messagetime < time)
	{
		other.messagetime = time+3;
	//	centerprint(other, "You must find a way to open this force field.");
		TE_CenterPrint(other, CPM_FINDAWAYTOOPENFORCEFIELD);
	}
}

void object_forcefield() =
{
	if(self.startstateoff)	
		self.istoggled = TRUE;

	if(!InitializeObject(self, OBJ_FORCEFIELD, self.variant, SOLID_BBOX))
		return;
		
	self.touch = ForcefieldTouch;
	self.TriggerFunc = ForcefieldToggle;
//	SpawnForcefieldGate();
}

void TriggerPressurePlate() =
{
	if(self.maxtriggers && self.currenttriggers >= self.maxtriggers)
		self.istoggled = TRUE;
	else
		self.istoggled = !self.istoggled;
		
	self.istriggered = self.istoggled;
	self.SendFlags = self.SendFlags | SFL_RESET;
}

void PressurePlateTouch() =
{
	if(other.class != CLASS_PLAYER)
		return;
		
	if(self.istoggled)
		return;
		
	if(self.maxtriggers && self.currenttriggers >= self.maxtriggers)
		return;
		
	self.currenttriggers += 1;	
		
	self.istoggled = TRUE;
	self.SendFlags = self.SendFlags | SFL_RESET;
	TriggerObjects(0);
}

void object_pressureplate() =
{
	if(self.startstateoff)	
	{
		self.istoggled = TRUE;
		self.istriggered = TRUE;
	}

	if(!InitializeObject(self, OBJ_PRESSUREPLATE, 0, SOLID_TRIGGER))
		return;

	self.touch = PressurePlateTouch;
	self.TriggerFunc = TriggerPressurePlate;
}

void DropFlag(entity e) =
{
	DropItem(e.flagent, e, OBJ_FLAG, e.flagent.variant);
	e.flagent.touch = flag_touch;
//	bprint(strcat(e.netname, " has dropped the ", GetTeamName(e.flagent.variant), " flag!\n"));
	TE_CenterPrint(world, CPM_FLAG_DROPPED);
	TE_CenterPrint_ExtendedInfo_Flag(world, e.netname, e.flagent.variant);
	e.flagent.carrier = world;
	e.flagent.SendFlags = e.flagent.SendFlags | SFL_RESET | SFL_ORIGIN;	
	e.flagent = world;
	
}

void PickupFlag(entity e, entity eflag) =
{
	if(e.flagtouchtime <= time)
	{
		StopTossedObject(eflag);
	
		// drop any flags that are being carried
		if(e.flagent)
			DropFlag(e);
			
		// remove from base	
		eflag.owner.flagent = world;		
			
		// pickup flag	
		setorigin(eflag, '0 0 0');
		eflag.touch = SUB_Null;
		eflag.carrier = e;
		e.flagent = eflag;
//		bprint(strcat(e.netname, " has the ", GetTeamName(eflag.variant), " flag!\n"));
		TE_CenterPrint(world, CPM_FLAG_PICKUP);
		TE_CenterPrint_ExtendedInfo_Flag(world, e.netname, eflag.variant);		
		SetEventFlag_Sound(e, SOUND_PICKUP_FLAG);
		eflag.SendFlags = eflag.SendFlags | SFL_RESET;
	}
	
	e.flagtouchtime = time+0.1;	
}

void flag_touch() =
{
	if(!CanGetItem(other))
		return;

	// return flag
	if(self.variant == other.team)
	{
		StopTossedObject(self);
		other.returns = other.returns +1;
		UpdateScore(other, SCORESTAT_RETURNS);
		setorigin(self, '32 0 0');
		self.touch = SUB_Null;
		self.owner.flagent = self;
		self.carrier = self.owner;
//		bprint(strcat(other.netname, " has returned the ", GetTeamName(self.variant), " flag!\n"));
		TE_CenterPrint(world, CPM_FLAG_RETURN);
		TE_CenterPrint_ExtendedInfo_Flag(world, other.netname, self.variant);			
		SetEventFlag_Sound(other, SOUND_PICKUP);
		self.SendFlags = self.SendFlags | SFL_RESET;
		return;
	}	

	PickupFlag(other, self);
}

void flag(entity e) =
{
	local entity eflag, oself;

	oself = self;
	
	eflag = SpawnEnt();
	self = eflag;
	
	InitializeItem(OBJ_FLAG, e.variant, SUB_Null);

	setorigin(self, '32 0 0');
	self.carrier = e;	
	SetOwner(self, e);
	SetParent(self, e);
	self.persistondrop = TRUE;
	
	e.flagent = eflag;

	self = oself;	
}

void FlagBaseTouch() =
{
	local float cappoints, teamflags;
	local entity e_team;

	if(!CanGetItem(other))
		return;
		
	if(self.owner.flagent == world)
		return;

	if(self.owner.variant == other.team)
	{
		if(other.flagent)
		if(other.flagent.variant != self.owner.variant)
		{
			for(e_team = list_teamchain; e_team; e_team = e_team.teamchain)
			{
				if(e_team.team != 0)
				if(!e_team.noflag)
				{
					teamflags = TRUE;
					break;
				}
			}
		
			if(other.flagent.variant == 0 && teamflags)
				cappoints = 0.5; // half point for neutral flag if other flags exist
			else
				cappoints = 1;
			
			other.captures = other.captures +1;
			UpdateScore(other, SCORESTAT_CAPTURES);
		
			setorigin(other.flagent, '32 0 0');
			other.flagent.carrier = other.flagent.owner;
			other.flagent.owner.flagent = other.flagent;
//			bprint(strcat(other.netname, " has captured the ", GetTeamName(other.flagent.variant), " flag!\n"));
			TE_CenterPrint(world, CPM_FLAG_CAPTURE);
			TE_CenterPrint_ExtendedInfo_Flag(world, other.netname, other.flagent.variant);			
			other.flagent.SendFlags = other.flagent.SendFlags | SFL_RESET | SFL_ORIGIN | SFL_ORIGIN_STOP;
			other.flagent = world;
			
			AddTeamCapture(other.team, cappoints);
		}
		
		return;
	}
	
	PickupFlag(other, self.owner.flagent);
}

void flagbase() =
{
	if(!GameMode_HasFlags(gamemode))
	{
		SH_RemoveEnt(self);
		return;
	}

	if(!InitializeObject(self, OBJ_FLAGBASE, self.variant, SOLID_BBOX))
		return;
		
	CreateTeam(self.variant, self.noflag);
		
	SpawnTrigger(FlagBaseTouch, '0 0 0', 0);	

	if(!self.noflag)
		flag(self);
}

void PylonToggle() =
{
	self.istoggled = !self.istoggled;
	self.godmode = !self.istoggled;
	SetObjectAppearance(self, self.objclass, self.variant);	
	self.SendFlags = self.SendFlags | SFL_RESET;
}

void object_pylon() =
{
	if(self.startstateoff)	
		self.istoggled = TRUE;
	else
		self.godmode = TRUE;

	if(!InitializeObject(self, OBJ_STRUCTURE, STRUCTURE_PYLON, SOLID_BBOX))
		return;
		
//	if(!self.objectname)
//		self.objectname = zonecpy(self.objectname, "Pylon");
		
	self.TriggerFunc = PylonToggle;
}

void EvaporatorTouch() =
{
	if(other.class != CLASS_PLAYER)
		return;
		
	if(other.health <= 0)
		return;
		
	local float cores, wrongteam;
	local entity oself;
	oself = self;
		
	if(self.owner.team)
	if(other.team == self.owner.team)
		wrongteam = TRUE;
		
	if(!wrongteam)
	if(!self.owner.istoggled)
	{
		cores = globalitem_corruptfusioncores[other.team-1];	
		if(cores)
		{
			TE_CenterPrint(other, CPM_USEDCORRUPTFUSIONCORE);
			globalitem_corruptfusioncores[other.team-1] = cores - 1;
			self = self.owner;
				TriggerObjects(0);
				ToggleToggleable();
			self = oself;
		}
		else
		if(other.messagetime < time)
		{
			other.messagetime = time+3;
			TE_CenterPrint(other, CPM_FUSIONCORENEEDED);
		}
	}	
}

void object_evaporator() =
{
	local vector ofs;
	local float tsize;

	if(!InitializeObject(self, OBJ_STRUCTURE, self.variant, SOLID_BSP))
		return;

	makevectors(self.angles_base);
	ofs = v_forward*900;
	tsize = 600;
	SpawnTrigger(EvaporatorTouch, ofs, tsize);
}

void object_bboss() =
{
	InitializeObject(self, self.objclass, self.variant, SOLID_BBOX);
	self.showhealth = 2;
}