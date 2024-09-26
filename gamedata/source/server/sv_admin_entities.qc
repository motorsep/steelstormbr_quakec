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
/*void SV_ClearEntities() =
{
//	ClearClientEntClass(world, CLASS_OBJECT);
	ClearEntities();
}*/

string GetLocalObjectiveText(entity e, float language) =
{
	local float file;
	local string filename, text, line;

	if(language == MISSION_LANGUAGE)
		text = e.objectivetext;
	else	
	{
		text = "DEFAULT";
		filename = GetMissionFilename(gamemode, campaign, mission, TRUE, language);
		file = FileOpen(filename, FILE_READ);
	
		if(file != -1)
		{
			for(line = fgets(file); text == "DEFAULT" && line; line = fgets(file))
			{
				tokenize(line);
				
				if(argv(0) == "OBJECTIVE")
				if(stof(argv(2)) == e.entid)
					text = argv(3);
			}
			
			fclose(file);
		}
	}
	
	return text;
}

void UpdateObjectiveText(entity e, float MSG_TYPE) =
{
	local string s, b;
	local float count;

	for(count = 0; count < NUMLANGUAGES; count++)
	{
		b = e.(objectivetext[count+1]);
		
		if(b == "DEFAULT")
			b = e.objectivetext;
			
		s = strcat(s, "\"", b, "\" ");
	}	

	if(MSG_TYPE == MSG_ONE)
		msg_entity = self;
	
	WriteByte(MSG_TYPE, SVC_TEMPENTITY);
	WriteByte(MSG_TYPE, TE_OBJECTIVETEXT);
	WriteLong(MSG_TYPE, e.id);
	WriteString(MSG_TYPE, s);
}

void SendObjectiveTextToPlayer() =
{
	local entity e;
	
	for(e = list_objectivechain; e; e = e.objectivechain)
		UpdateObjectiveText(e, MSG_ONE);
}

void InitializeObjective(entity e) =
{
	local float count;
	local string s;

	SetOwner(e, e);
	SetParent(e, e);
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_OBJECTIVE;
	SetID(e);	
	e.effects = e.effects | EF_NODEPTHTEST;
	SetAndPrecacheModel(e, "null");
	e.isdataent = TRUE;
	e.SendEntity = SendObjective;
	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = e.(objectivetext[count+1]);
		if(!s)
		{
			s = zonecpy(s, GetLocalObjectiveText(e, count));
			e.(objectivetext[count+1]) = s;	
		}
	}
	
	UpdateObjectiveText(e, MSG_ALL);
	
	ObjectiveChain_Add(e);
	ObjectChain_Add(e);
}

void TriggerParticleEmitter() =
{
	self.istoggled = !self.istoggled;
	self.SendFlags = self.SendFlags | SFL_RESET;

}

void InitializeParticleEmitter(entity e) =
{
	if(((!e.id && missionfileexists) || (e.multiplayeronly && singleplayer)) && !e.permanent)
	{
		SH_RemoveEnt(e);
		return;
	}
	
	if(!SetDefaultSharedStats(e))
		return;	

	if(e.startstateoff)	
		e.istoggled = TRUE;
		
	SetOwner(e, e);
	SetParent(e, e);
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_PARTICLEEMITTER;
	
	SetID(e);		
	
	e.isallowedtofloat = TRUE;
//	if(adminmodeactive)
	SetObjectAppearance(e, e.objclass, e.variant);
		SetAndPrecacheModel(e, "null");
	e.SendEntity = SendParticleEmitter;	
	
	e.TriggerFunc = TriggerParticleEmitter;

	ObjectChain_Add(e);

	InitializeObjectOrientation(e);		
}

void InitializeAmbientSound(entity e) =
{
	if(((!e.id && missionfileexists) || (e.multiplayeronly && singleplayer)) && !e.permanent)
	{
		SH_RemoveEnt(e);
		return;
	}

	if(!SetDefaultSharedStats(e))
		return;
	
	SetOwner(e, e);
	SetParent(e, e);
	e.class = CLASS_OBJECT;
	e.objclass = OBJ_AMBIENTSOUND;
	
	SetID(e);		
	
	e.isallowedtofloat = TRUE;
//	if(adminmodeactive)
	SetObjectAppearance(e, e.objclass, e.variant);
		SetAndPrecacheModel(e, "null");
	e.SendEntity = SendAmbientSound;	

	ObjectChain_Add(e);
	AmbientSoundChain_Add(e);

	precache_sound(e.ambientsoundeffect);
	
	InitializeObjectOrientation(e);		

	ambientsound(e.origin, e.ambientsoundeffect, 1, ATTN_NORM);
}

void objective() =
{
	self.objectivetext = zonecpy(self.objectivetext, self.objectivetext);
	InitializeObjective(self);
}

void particle_emitter() =
{
	self.particleemittereffect = zonecpy(self.particleemittereffect, self.particleemittereffect);
	InitializeParticleEmitter(self);
}

void ambient_sound() =
{
	self.ambientsoundeffect = zonecpy(self.ambientsoundeffect, self.ambientsoundeffect);
	InitializeAmbientSound(self);	
}

void DelayedEntityLoad() =
{
	LoadEntities();
	SH_RemoveEnt(self);
}

void ResetTrains() =
{
	local entity e;
	for(e = list_trainchain; e; e = e.trainchain)
	{
		Func_oself(e, func_train);
		SendObjectToClients(e);
	}
}

void DeleteEntities() =
{
	local entity e, nexte;
	e = list_objectchain;
	while(e)
	{
		nexte = e.objectchain;
		
		if(e.objclass == OBJ_TRAIN)
			ClearCustomTrainData(e);
		else
		if(!e.permanent)
			SH_RemoveEnt(e);
	
		e = nexte;
	}
	
	e = list_sectorchain;
	while(e)
	{
		nexte = e.sectorchain;
		SectorChain_Remove(e);
		SH_RemoveEnt(e);
		e = nexte;
	}
}

void ClearEntities() =
{
	DeleteEntities();
	ResetTrains();	
}

void ReloadEntities() =
{
	admin_reloadingents = TRUE;

	DeleteEntities();
	LoadEntities();
	ResetTrains();
	
//	local entity delayfunc;
//	delayfunc = spawn();
//	delayfunc.nextthink = time + 1;
//	delayfunc.think = DelayedEntityLoad;
}

entity SpawnEntity(entity e, float OBJCLASS, float VARIANT) =
{
	if(!e)
		e = SpawnEnt();

	switch(OBJCLASS)
	{
		case OBJ_NPC:
			if(VARIANT == NPC_LIGHTTANK)			e.postinitthink = light_tank;
			else
			if(VARIANT == NPC_MEDIUMTANK)			e.postinitthink = medium_tank;
			else
			if(VARIANT == NPC_HEAVYTANK_PROTON)		e.postinitthink = heavy_tank_proton;
			else
			if(VARIANT == NPC_HEAVYTANK_MINIGUN)	e.postinitthink = heavy_tank_minigun;			
			else
			if(VARIANT == NPC_LIGHTNINGTANK)		e.postinitthink = lightning_tank;
			else
			if(VARIANT == NPC_CARRIERTANK)			e.postinitthink = carrier_tank;
			else
			if(VARIANT == NPC_DESTROYERTANK)		e.postinitthink = destroyer_tank;
			else
			if(VARIANT == NPC_MICROFLYER)			e.postinitthink = micro_flyer;
			else
			if(VARIANT == NPC_LIGHTPLASMATURRET)	e.postinitthink = light_plasma_turret;
			else
			if(VARIANT == NPC_HEAVYBEAMTURRET)		e.postinitthink = heavy_beam_turret;
			else
			if(VARIANT == NPC_ROCKETTURRET)			e.postinitthink = rocket_turret;
			else
			if(VARIANT == NPC_REPAIRTURRET)			e.postinitthink = repair_turret;
			else
			if(VARIANT == NPC_FRIENDLYLIGHTTANK)	e.postinitthink = friendly_light_tank;
			break;
	
		case OBJ_ENEMYSPAWN:	e.postinitthink = enemyspawner;			break;
		case OBJ_PORTAL:		e.postinitthink = portal;				break;
			
		case OBJ_CRYSTAL:
			if(VARIANT == 0)		e.postinitthink = crystal_red;
			else
			if(VARIANT == 1)		e.postinitthink = crystal_green;
			else
			if(VARIANT == 2)		e.postinitthink = crystal_blue;
		break;			
		
		case OBJ_ARMORSHARD:		e.postinitthink = armor_shard;			break;
		case OBJ_ARMORSHELL:		e.postinitthink = armor_shell;			break;
		case OBJ_SHIELDPICKUP:		e.postinitthink = shield;				break;
		case OBJ_EXTRALIFE:			e.postinitthink = extra_life;			break;
		case OBJ_FLAGBASE:			e.postinitthink = flagbase;				break;
		
		case OBJ_WEAPONPICKUP1:
			if(VARIANT == WEP1_MINIGUN)			e.postinitthink = minigun;
			else
			if(VARIANT == WEP1_STORMPLOW)		e.postinitthink = storm_plow;		
			else			
			if(VARIANT == WEP1_BEAMCANNON)		e.postinitthink = beam_cannon;		
			else			
			if(VARIANT == WEP1_ROCKETPOD)		e.postinitthink = rocket_pod;
		break;
		
		case OBJ_WEAPONPICKUP2:
			if(VARIANT == WEP2_FLACKGUN)		e.postinitthink = flackgun;
			else
			if(VARIANT == WEP2_SHOCKWAVE)		e.postinitthink = shockwave_device;		
			else
			if(VARIANT == WEP2_STORMSPREAD)		e.postinitthink = storm_spread;		
			else			
			if(VARIANT == WEP2_STORMSHIELD)		e.postinitthink = storm_shield;		
			else
			if(VARIANT == WEP2_THUNDERBOLT)		e.postinitthink = thunderbolt;		
			else
			if(VARIANT == WEP2_HOMINGMISSILES)	e.postinitthink = homing_missiles;
			else
			if(VARIANT == WEP2_MIRVMORTAR)		e.postinitthink = mirv_mortar;
		break;		
		
		case OBJ_SPAWNPAD:		e.postinitthink = info_player_start;	break;
		case OBJ_PRESSUREPLATE:	e.postinitthink = object_pressureplate;	break;		
		case OBJ_FORCEFIELD:		e.postinitthink = object_forcefield;	break;
		case OBJ_EXITPAD:			e.postinitthink = object_exitpad;		break;
		case OBJ_TELEPORTER:		e.postinitthink = object_teleporter;	break;
		case OBJ_TERMINAL:			e.postinitthink = object_terminal;		break;
		case OBJ_DATAKEY:			e.postinitthink = object_datakey;				break;
		case OBJ_CORRUPTFUSIONCORE:	e.postinitthink = object_corruptfusioncore;		break;
		
		case OBJ_PARTICLEEMITTER:	e.postinitthink = particle_emitter;		break;
		case OBJ_AMBIENTSOUND:	e.postinitthink = ambient_sound;		break;
		
		case OBJ_OBJECTIVE:		e.postinitthink = objective;		break;
		
		case OBJ_TRIGGERRELAY:		e.postinitthink = trigger_relay;	break;
		
		case OBJ_STRUCTURE:
			if(VARIANT == STRUCTURE_PYLON)
				e.postinitthink = object_pylon;
			else
			if(VARIANT == STRUCTURE_REFINERY
			|| VARIANT == STRUCTURE_GASPUMP)
				e.postinitthink = object_toggleable;
			else
			if(VARIANT == STRUCTURE_EVAPORATOR)
				e.postinitthink = object_evaporator;
			else
			if(VARIANT == STRUCTURE_BBOSS
			|| VARIANT == STRUCTURE_BBOSS_SMALL)
				e.postinitthink = object_bboss;
			else
				InitializeObject(e, OBJCLASS, VARIANT, SOLID_BBOX);
		break;
		
		default: // environment objects
			InitializeObject(e, OBJCLASS, VARIANT, SOLID_BBOX);
		break;
	}
	
	return e;
}

void LoadPath(entity e, string s, float firstargv) =
{
//	tokenizebyseparator(s, SEP_A);

//	e.entid = stof(argv(firstargv));
//	e.pathgroupid = stof(argv(firstargv+1));
//	e.prevpathpointid = stof(argv(firstargv+2));
//	e.nextpathpointid = stof(argv(firstargv+3));
//	setorigin(e, stov(argv(firstargv+4)));
//	if(!e.entid)
//		SetEntID(e);

	InitializePath(e);
}

void LoadParticleEmitter(entity e, string s, float firstargv) =
{
//	e.origin_base = stov(argv(firstargv));
//	e.angles_base = stov(argv(firstargv+1));
//	e.entid = stof(argv(firstargv+2));
//	e.particleemittereffect = zonecpy(e.particleemittereffect, argv(firstargv+3));

//	if(!e.entid)
//		e.entid = GetNewEntID();	
}

void LoadObject(entity e, string s, float firstargv) =
{
//	e.variant = stof(argv(firstargv));
//	e.origin_base = stov(argv(firstargv+1));

//	tracebox(e.origin_base+'0 0 64', '-16 -16 0', '16 16 16', e.origin_base+'0 0 -512', TRUE, e);
	/*e.angles =*/ //e.angles_base = stov(argv(firstargv+2));
//	setorigin(e, trace_endpos);
	
	e.velocity = '0 0 0';
//	e.ideal_yaw = e.angles_y;	
	
//	e.entid = stof(argv(firstargv+3));
//	e.targetentid = stof(argv(firstargv+4));
//	e.movement_behavior = stof(argv(firstargv+5));
	
//	e.pathgroupid = stof(argv(firstargv+6));
	
//	e.triggerentid = stof(argv(firstargv+7));	
	
//	if(!e.entid)
//		e.entid = GetNewEntID();
}

void UpdateTarget(entity e, float newval) =
{
	local float e_istrigger;
	e_istrigger = e.istrigger;

	ClearEntData(e);

	e.istrigger = e_istrigger;
	e.istarget = newval;	
	
	if(e.objclass == OBJ_TRAIN)
		Func_oself(e, func_train_initialize);
	else
	{
		SpawnEntity(e, e.objclass, e.variant);
		InitializeSharedEnt(e);	
	}
	
	SendObjectToClients(e);	
}

void UpdateTriggers() =
{
	local entity e, f;
	
	for(e = list_objectchain; e; e = e.objectchain)
	{
		e.showhealth_victim = FALSE;
	
		if(e.istrigger)
		{
			for(f = list_objectchain; f; f = f.objectchain)
			{
				if(e.targetentid == f.entid || e.entid == f.triggerentid)
				if(!(f.flags & FL_ITEM))
					e.showhealth_victim = TRUE;
			}
			
			for(f = list_objectivechain; f; f = f.objectivechain)
			{
				if(e.triggerobjectiveentid == f.entid)
				{
					if((e.flags & FL_ITEM) && f.objectivepriority == 0)
					{
						e.triggerobjectiveentid = 0;
						SendObjectToClients(e);
					}
					else
						e.showhealth_victim = TRUE;
				}
			}
			
		}
	}
	
	for(e = list_objectchain; e; e = e.objectchain)
	{
		if(e.associationentid)
		{
			for(f = list_objectchain; f; f = f.objectchain)
			{
				if(e.associationentid == f.entid)
				if(f.showhealth_victim)
					e.showhealth_victim = TRUE;
			}
		}
	}
}

void MarkTriggers(entity e, float hadtrigger, float hadtarget, float hadtargetstagetwo, float hadtargetstagethree) =
{
	local entity obj, lastobj, oldtrigger, oldtarget, oldtargetstagetwo, oldtargetstagethree;	
		
	if(e.triggerentid)
		e.istarget = TRUE;
		
	if(e.triggerobjectiveentid)
		e.istrigger = TRUE;
		
	if(e.targetentid || e.targetstagetwoentid || e.targetstagethreeentid)
		e.istrigger = TRUE;
		
	for(obj = list_objectchain; obj; obj = obj.objectchain)
	{
		if(!obj.entid)
			continue;
	
		if(obj.triggerentid == e.entid) // set when trigger ent spawns after it's target object
			e.istrigger = TRUE;
			
		if(e.triggerentid != hadtrigger)
		if(obj.entid == e.triggerentid) // found newtrigger
			obj.istrigger = TRUE;
		else
		if(obj.entid == hadtrigger) // found old trigger
		{
			oldtrigger = obj;
			oldtrigger.istrigger = FALSE;
		}
		
		// set when target ent spawns after it's trigger object
		if(obj.targetentid == e.entid || obj.targetstagetwoentid == e.entid || obj.targetstagethreeentid == e.entid) 
			e.istarget = TRUE;
		
		if(e.targetentid != hadtarget || e.targetstagetwoentid != hadtargetstagetwo || e.targetstagethreeentid != hadtargetstagethree)
		if(obj.entid == e.targetentid || obj.entid == e.targetstagetwoentid || obj.entid == e.targetstagethreeentid) // found newtarget
			UpdateTarget(obj, TRUE);//obj.istarget = TRUE;
		else
		{
			if(e.targetentid != hadtarget && obj.entid == hadtarget) // found old target
				oldtarget = obj;	
			
			if(e.targetstagetwoentid != hadtargetstagetwo && obj.entid == hadtargetstagetwo) // found old target
				oldtargetstagetwo = obj;	
			
			if(e.targetstagethreeentid != hadtargetstagethree && obj.entid == hadtargetstagethree) // found old target
				oldtargetstagethree = obj;	
		}				
	}

	if(e.triggerentid != hadtrigger)
	{
		if(oldtrigger) // set old trigger as a trigger if it is still a trigger of another object
		for(obj = list_objectchain; obj; obj = obj.objectchain)
		{
			if(obj.triggerentid == oldtrigger.entid)
			{
				oldtrigger.istrigger = TRUE;
				break;
			}
		}
	}
	
	if(oldtarget || oldtargetstagetwo || oldtargetstagethree) // set old target as a trigger if it is still a target of another object
	{
		for(obj = list_objectchain; obj && (oldtarget || oldtargetstagetwo || oldtargetstagethree); obj = obj.objectchain)
		{
			if(oldtarget)
			if(obj.targetentid == oldtarget.entid)
			{
				UpdateTarget(oldtarget, TRUE);//oldtarget.istarget = TRUE;
				oldtarget = world;
			}
			
			if(oldtargetstagetwo)
			if(obj.targetstagetwoentid == oldtargetstagetwo.entid)
			{
				UpdateTarget(oldtargetstagetwo, TRUE);//oldtarget.istarget = TRUE;
				oldtargetstagetwo = world;
			}
			
			if(oldtargetstagethree)
			if(obj.targetstagethreeentid == oldtargetstagethree.entid)
			{
				UpdateTarget(oldtargetstagethree, TRUE);//oldtarget.istarget = TRUE;
				oldtargetstagethree = world;
			}
		}
	
		if(oldtarget)
			UpdateTarget(oldtarget, FALSE);
		if(oldtargetstagetwo)
			UpdateTarget(oldtargetstagetwo, FALSE);
		if(oldtargetstagethree)
			UpdateTarget(oldtargetstagethree, FALSE);				
	}
}

void LoadEntity(entity e, string s, float firstargv) =
{
	local float count, hadtrigger, hadtarget, hadtargetstagetwo, hadtargetstagethree;
	local string o;
	
	hadtrigger = e.triggerentid;
	hadtarget = e.targetentid;
	hadtargetstagetwo = e.targetstagetwoentid;
	hadtargetstagethree = e.targetstagethreeentid;
	
	tokenize(s);
	for(count = firstargv; argv(count); count+=2)
	{
		switch(argv(count))
		{
			case "TEAM":						e.team							= stof(argv(count+1));								break;
			case "STARTSTATEOFF":				e.startstateoff					= stof(argv(count+1));								break;
			case "MULTIPLAYERONLY":				e.multiplayeronly				= stof(argv(count+1));								break;
			case "ISTRIGGER":					e.istrigger						= stof(argv(count+1));								break;
			case "ISTARGET":					e.istarget						= stof(argv(count+1));								break;
			case "ISDELETEDFORMISSION":			e.isdeletedformission			= stof(argv(count+1));								break;
			case "ISDEAD":						e.isdead						= stof(argv(count+1));								break;
			case "DEADMODELNUM":				e.deadmodelnum					= stof(argv(count+1));								break;
			case "HEALTH":						enthealth						= stof(argv(count+1));								break;
			case "PATHFUNCTIONS":				pathfunctions					= stof(argv(count+1));								break;	
			case "OBJCLASS":					e.objclass						= stof(argv(count+1));								break;
			case "VARIANT":						e.variant						= stof(argv(count+1));								break;
			case "ORIGIN":						setorigin(e, stov(argv(count+1)));													break;
			case "ANGLES":						e.angles						= stov(argv(count+1));								break;
			case "ORIGINBASE":					e.origin_base					= stov(argv(count+1));								break;
			case "ANGLESBASE":					e.angles_base					= stov(argv(count+1));								break;
			case "ENTID":						e.entid							= stof(argv(count+1));								break;
			case "TARGETENTID":					e.targetentid					= stof(argv(count+1));								break;
			case "TARGETSTAGETWOENTID":			e.targetstagetwoentid			= stof(argv(count+1));								break;
			case "TARGETSTAGETHREEENTID":		e.targetstagethreeentid			= stof(argv(count+1));								break;
			case "TRIGGERENTID":				e.triggerentid					= stof(argv(count+1));								break;
			case "TRIGGERDELAY":				e.triggerdelaytime				= stof(argv(count+1));								break;
			case "ASSOCIATIONENTID":			e.associationentid				= stof(argv(count+1));								break;
			case "TRIGGEROBJECTIVEENTID":		e.triggerobjectiveentid			= stof(argv(count+1));								break;
			case "PATHGROUPID":					e.pathgroupid					= stof(argv(count+1));								break;
			case "PREVPATHENTID":				e.prevpathpointid				= stof(argv(count+1));								break;
			case "NEXTPATHENTID":				e.nextpathpointid				= stof(argv(count+1));								break;
			case "MOVEMENTBEHAVIOR":			e.movement_behavior				= stof(argv(count+1));								break;
			case "MAPICON":						e.mapicon						= stof(argv(count+1));								break;
			case "NOFLAG":						e.noflag						= stof(argv(count+1));								break;
			case "MAXTRIGGERS":					e.maxtriggers					= stof(argv(count+1));								break;
			case "TOUCHTRIGGER":				e.touchtrigger					= stof(argv(count+1));								break;
			case "ACTIVATIONTIME":				e.object_activationtime			= stof(argv(count+1));								break;
			case "TERMINALTYPE":				e.terminaltype					= stof(argv(count+1));								break;
			case "INDESTRUCTIBLE":				e.indestructible				= stof(argv(count+1));								break;
			case "REQUIRESKEY":					e.requireskey					= stof(argv(count+1));								break;
			
			case "PRIORITY":					e.objectivepriority				= stof(argv(count+1));								break;
			case "OBJECTIVETEXT":
				e.objectivetext = zonecpy(e.objectivetext, argv(count+1));	
				if(!server_loadingobjectsfromfile)
				{
					o = e.(objectivetext[currentlanguage+1]);
					o = zonecpy(o, e.objectivetext);
					e.(objectivetext[currentlanguage+1]) = o;
					MISSION_LANGUAGE = currentlanguage;
				}
				break;
			
			case "SPAWNER_MAXAREAENTS":			e.spawner_max_areaents			= stof(argv(count+1));								break;
			case "SPAWNER_MAXENTS":				e.spawner_max_ents				= stof(argv(count+1));								break;
			case "SPAWNER_MAXLIGHTTANKS":		e.spawner_max_lighttanks		= stof(argv(count+1));								break;
			case "SPAWNER_MAXMEDIUMTANKS":		e.spawner_max_mediumtanks		= stof(argv(count+1));								break;
			case "SPAWNER_MAXLIGHTNINGTANKS":	e.spawner_max_lightningtanks	= stof(argv(count+1));								break;
			case "SPAWNER_MAXHEAVYTANKS":		e.spawner_max_heavytanks		= stof(argv(count+1));								break;			
			case "PARTICLEEMITTEREFFECT":		e.particleemittereffect			= zonecpy(e.particleemittereffect, argv(count+1));	break;
			case "AMBIENTSOUND":				e.ambientsoundeffect			= zonecpy(e.ambientsoundeffect, argv(count+1));		break;
			
			case "SCALE":						e.scale							= stof(argv(count+1));								break;

			case "TARGETNAME":					e.targetname_pointer			= zonecpy(e.targetname_pointer, argv(count+1));		break;
		}
	}

	e.velocity = '0 0 0';	
	
	if(e.mapicon)
		SetMapObject(e);
		
	if(!(server_loadingobjectsfromfile && mission_fileversion < 1))
		MarkTriggers(e, hadtrigger, hadtarget, hadtargetstagetwo, hadtargetstagethree);
}

void RecentlyCommitedEntityChain_Add(entity e) =	{	list_recentlycommitedentitychain = LinkedList_Add(e, list_recentlycommitedentitychain, recentlycommitedentitychain, recentlycommitedentitychain_prev);	}
void RecentlyCommitedEntityChain_Remove(entity e) =	{	list_recentlycommitedentitychain = LinkedList_Remove(e, list_recentlycommitedentitychain, recentlycommitedentitychain, recentlycommitedentitychain_prev);	}

void SetUpEntPointers() =
{
	local entity e, pathe, ente;
	
	e = list_pathchain;
	while(e)
	{
		e.nextpathpoint = world;
		e.prevpathpoint = world;
	
		if(e.nextpathpointid || e.prevpathpointid)
		{
			pathe = list_pathchain;
			while(pathe)
			{
				if(e.nextpathpointid == pathe.entid)
					e.nextpathpoint = pathe;
				if(e.prevpathpointid == pathe.entid)
					e.prevpathpoint = pathe;
			
			//	if(pathe.nextpathpointid == e.entid)
			//		pathe.nextpathpoint = e;
			//	if(pathe.prevpathpointid == e.entid)
			//		pathe.prevpathpoint = e;

				pathe = pathe.pathchain;
			}
		}
		
		e = e.pathchain;
	}
	
/*	e = list_objectchain;
	while(e)
	{
		e.targetent = world;
		if(e.targetentid)
		{
			ente = list_objectchain;
			while(ente)
			{
				if(e.targetentid == ente.entid)
					e.targetent = ente;
					
				ente = ente.objectchain;
			}
		}
		e = e.objectchain;
	}*/
}

void SendObjectToClients(entity e) =
{
	e.effects = e.effects | EF_NODEPTHTEST;
	e.SendFlags = SFL_ISNEW;
}

void SetUpObjectIDs(entity e) =
{
	if(e.entid < 0)
		SetPermanentID(e);
}

void ClearEntData(entity e) =
{
	if(!(e.flags & FL_REVIVE))
	{
		e.istrigger = FALSE;
		e.istarget = FALSE;	
		e.flags = 0;	
		e.activated = FALSE;	
		e.istoggled = FALSE;
		e.istriggered = FALSE;	
		e.hastriggered_stagetwo = FALSE;
		e.hastriggered_stagethree = FALSE;			
		e.currenttriggers = 0;		
		e.TriggerFunc = SUB_Null;
		e.scale = 0;
	}

	e.roamtargetdest = '0 0 0';
	e.damage_effects = FALSE;
	e.action = FALSE;
	e.effects = 0;
	e.keyed = FALSE;
	e.requireskey = FALSE;
	e.indestructible = FALSE;
	e.FastThink = SUB_Null;
	e.waittomovetime = 0;
	e.firebuilduptime = 0;
	e.explodeuntiltime = 0;
	e.killedby = world;
	e.hadenemylastframe = FALSE;
	e.onlydrawforadmins = FALSE;
	e.nextthink = 0;
	e.think = SUB_Null;
	e.isdead = FALSE;
	e.deadmodelnum = 0;
	e.godmode = FALSE;
	RemoveOwnedEnts(e);
	RemoveChildren(e);		
	e.trigger = world;
	e.hasturrets = FALSE;
	e.numchildren = 0;
	e.nextpathpoint = world;	
	e.nonsolidsolid = FALSE;
	NonsolidChain_Remove(e);		
}

void FindBogusEnt(string s) =
{
	local entity e;
	for(e = list_objectchain; e; e = e.objectchain)
	{
		if(e.objclass == 0)
		{
			dprint(s);
			dprint(" - Bogus object found!\n");
		//	eprint(e);
		}
	}
}

void Commit_Entity(string cmd) =
{
	local entity e;
	local float e_id, totalobjects, minversion;
	
	minversion = 1.5;
	if(EPISODE < minversion)
	{
		for(e = list_objectchain; e; e = e.objectchain)
			totalobjects++;
		if(totalobjects >= 200)
			return;
	}	

	tokenize(cmd);
	
//	newadmin = world;	
	self.lastplacedpathpoint = world;
	
	e_id = stof(argv(0));
	if(e_id)
	{
		e = GetLinkedListEnt_float(list_objectchain, objectchain, id, e_id);
		if(e)
			ClearEntData(e);
	}
	
	if(!e)
		e = SpawnEnt();

	LoadEntity(e, cmd, 1);	

	if(e.objclass == OBJ_TRAIN)
	{
		ResetTrainData(e);
		Func_oself(e, func_train_initialize);
	}
	else
	{
		e = SpawnEntity(e, e.objclass, e.variant);
//		e.editor = self;
		InitializeSharedEnt(e);	
//		InitializeObjectOrientation(e);
	}

	if(LOADINGFROMEPISODE > EPISODE)
	{
		SH_RemoveEnt(e);
		return;
	}
	
	SetUpObjectIDs(e);

//	RecentlyCommitedEntityChain_Add(e);
	SetUpEntPointers();	
	SendObjectToClients(e);	

	UpdateTriggers();
}

void Remove_Path(float pathid) =
{
	local entity e;
	e = findfloat(world, id, pathid);
	if(e)
		SH_RemoveEnt(e);
	else
		dprint("Invalid Path Point.\n");
}

void Commit_Path(string cmd)
{
	local entity e, oldpath_next, oldpath_prev;
	local float e_id, totalobjects, minversion;
	
	minversion = 1.5;
	if(EPISODE < minversion)
	{
		for(e = list_objectchain; e; e = e.objectchain)
			totalobjects++;
		if(totalobjects >= 200)
			return;
	}	
	
	tokenize(cmd);
	
	e_id = stof(argv(0));
	if(e_id)
		e = GetLinkedListEnt_float(list_pathchain, pathchain, id, e_id);

	if(!e)
		e = SpawnEnt();		
	else
	{
		oldpath_next = e.nextpathpoint;
		oldpath_prev = e.prevpathpoint;
	}
	
	LoadEntity(e, cmd, 1);
	
	InitializePath(e);
	
//	if(e.pathgroupid < 0)
//		e.oldpathgroupid = e.pathgroupid;
	
//	RecentlyCommitedEntityChain_Add(e);
	
//	e.editor = self;
	
	SetUpObjectIDs(e);
	
	SetUpPaths(e, oldpath_next, oldpath_prev, !e_id);
	pathfunctions = FALSE;
	
	SetUpEntPointers();	
}

void Commit_Entities_End() =
{
	local entity e, pathe, nexte, obj;
	local float newid, oldid;
	
	//pathgroupid
	e = list_pathchain;
	while(e)
	{
		if(e.pathgroupid < 0)
		{
			newid = GetNewPathGroupID(FALSE);
			oldid = e.pathgroupid;

			pathe = findchainfloat(pathgroupid, oldid);
			while(pathe)
			{
				if(pathe.pathgroupid == oldid)
					pathe.pathgroupid = newid;
					
				pathe = pathe.chain;
			}
		}
		
		e = e.pathchain;
	}

//	newadmin = world;
	
	//entid
/*	e = list_pathchain;
	while(e)
	{
		if(e.entid < 0)
		{
			oldid = e.entid;
			SetPermanentID(e);
			newid = e.entid;
		//	print("oldid: ");	print(ftos(oldid));	print(" newid: ");	print(ftos(newid));	print("\n");			
		
			pathe = list_pathchain;
		//	pathe = findchainfloat(pathgroupid, oldid);
			while(pathe)
			{
				if(pathe.nextpathpointid == oldid)
					pathe.nextpathpointid = newid;
				if(pathe.prevpathpointid == oldid)
					pathe.prevpathpointid = newid;
			//	pathe = pathe.chain;	
				pathe = pathe.pathchain;
			}
			
		//	e.entid = newid;
		}
		
	//	e.SendFlags = TRUE;
		
		e = e.pathchain;
	}*/
	
	e = list_recentlycommitedentitychain;
	while(e)
	{	
		if(e.entid < 0)
		{
			oldid = e.entid;		
			SetPermanentID(e);
			newid = e.entid;	
			
			obj = list_recentlycommitedentitychain;
			while(obj)
			{
				if(obj.targetentid == oldid)
					obj.targetentid = newid;
				if(obj.triggerentid == oldid)
					obj.triggerentid = newid;
				if(obj.associationentid == oldid)
					obj.associationentid = newid;
					
				obj = obj.recentlycommitedentitychain;
			}
			
			if(e.objclass == OBJ_PATH)
			{
				pathe = list_pathchain;
			//	pathe = findchainfloat(pathgroupid, oldid);
				while(pathe)
				{
					if(pathe.nextpathpointid == oldid)
						pathe.nextpathpointid = newid;
					if(pathe.prevpathpointid == oldid)
						pathe.prevpathpointid = newid;
				//	pathe = pathe.chain;	
					pathe = pathe.pathchain;
				}			
			}
			
//			e.entid = newid;
		}
		
		e = e.recentlycommitedentitychain;
	}
	
	e = list_recentlycommitedentitychain;
	while(e)
	{
		nexte = e.recentlycommitedentitychain;
		
		e.effects = e.effects | EF_NODEPTHTEST;
		e.SendFlags = SFL_ISNEW;

		RecentlyCommitedEntityChain_Remove(e);
		e = nexte;
	}
	
	SetUpEntPointers();	
	
	UpdateTriggers();
}

/*string GetMissionFilename(float mode, string cname, string mname) =
{
	local string s;
	
	s = strcat(GetGameMode_String(mode, TRUE), "/");
	
	if(mode == GAMEMODE_CAMPAIGN)
	{
		s = strcat(s, "_");
		s = strcat(s, uri_escape(cname));
		s = strcat(s, "/");
	}
	
	s = strcat(s, "_");
	s = strcat(s, uri_escape(mname));
	s = strcat(s, ".mission");
	
	return s;
}*/

void BroadcastMissionTrack() =
{
	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	WriteByte(MSG_ALL, TE_MISSIONTRACK);
	WriteString(MSG_ALL, mission_track);
}

void BroadcastMissionBriefing() =
{
	local string s, b;
	local float count;
	
	WriteByte(MSG_ALL, SVC_TEMPENTITY);
	WriteByte(MSG_ALL, TE_MISSIONBRIEFING);
	
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		b = mission_briefing[count+1];
		if(b == "DEFAULT")
			b = mission_briefing;
		s = strcat(s, "\"", b, "\" ");
	}
	WriteString(MSG_ALL, s);
}

void SpawnPlayers() =
{
	local entity e;
	
	for(e = list_playerchain; e; e = e.playerchain)
		Func_oself(e, PutClientInServer);
}
/*
void SetUpSectorGrid() =
{
	local vector gridsize;
	local float width, height, buf, numbuffers, count;

	gridsize = world.maxs - world.mins;
	width = ceil(gridsize_x / SECTOR_GRIDSIZE);
	height = ceil(gridsize_y / SECTOR_GRIDSIZE);

	sector_endbuf = width*height;

	for(count = 0; count < sector_endbuf; count++)
	{
		buf = CreateBuffer();
		if(!sector_startbuf)
			sector_startbuf = buf;
	}
}

float GetGridSectorID(vector ent_org) =
{
	local vector gridsize, origin_offset;
	local float width, height, grid_col, grid_row, grid_id;

	gridsize = world.maxs - world.mins;
	width = ceil(gridsize_x / SECTOR_GRIDSIZE);
	height = ceil(gridsize_y / SECTOR_GRIDSIZE);

	if(ent_org_x < world.mins_x
	|| ent_org_x > world.mins_x + width*SECTOR_GRIDSIZE
	|| ent_org_y < world.mins_y
	|| ent_org_y > world.mins_y + height*SECTOR_GRIDSIZE)
		return -1;	
	
	origin_offset = ent_org - world.mins;
	grid_col = floor((origin_offset_x/(width*SECTOR_GRIDSIZE))*width)+1;
	grid_row = floor((origin_offset_y/(height*SECTOR_GRIDSIZE))*height)+1;
	grid_id = (grid_row-1)*width + grid_col;
	
	return grid_id;
}

float CanAssignToSector(entity e) =
{
	if(e.objclass == OBJ_PATH
	|| e.istarget
	|| e.istrigger
	|| e.associationentid
	|| e.triggerentid //&& !(e.objclass != OBJ_FORCEFIELD && e.istoggled))
	|| e.pathgroupid
	|| e.objclass == OBJ_TELEPORTER
	|| e.ismapobject
	|| e.objclass == OBJ_TRAIN
	|| e.objclass == OBJ_OBJECTIVE
	|| e.objclass == OBJ_ENEMYSPAWN
	|| e.objclass == OBJ_PORTAL
	|| e.spawnedfrom)
		return FALSE;
		
	return TRUE;
}

void AssignObjectToSector(entity e) =
{
	if(adminmodeactive)
		return;

	if(!CanAssignToSector(e))
		return;

	local string line;
	local float grid_id;
	local entity sector;	
	
	grid_id = GetGridSectorID(e.origin);

	if(e.explodeuntiltime)
		e.isdead = TRUE;
	
	line = strcat("ISDEAD ", ftos(e.isdead));
	line = strcat(line, " DEADMODELNUM ");
	line = strcat(line , ftos(e.deadmodelnum));	
	line = strcat(line, " HEALTH ");
	line = strcat(line , ftos(e.health));
	line = strcat(line, " ORIGIN ");
	line = strcat(line, vtos(e.origin));	
	line = strcat(line, " ANGLES ");
	line = strcat(line, vtos(e.angles));
	if(e.objclass == OBJ_PARTICLEEMITTER)
		line = PrepLine_ParticleEmitter(line, e);
	else
		line = PrepLine_Entity(line, e);
	AddBufferString(sector_startbuf + grid_id - 1, line, 0);
	SH_RemoveEnt(e);
}

void UpdateSectorEnt(entity e) =
{
	local float grid_id;
	local entity sector;
	
	grid_id = GetGridSectorID(e.origin);
	if(e.sectorent.sectorid == grid_id)
		return;

	if(e.sectorent)
		e.sectorent.list_sectorobjectchain = LinkedList_Remove(e, e.sectorent.list_sectorobjectchain, sectorobjectchain, sectorobjectchain_prev);
		
	for(sector = list_sectorchain; sector; sector = sector.sectorchain)
	{
		if(sector.sectorid == grid_id)
		{
			sector.list_sectorobjectchain = LinkedList_Add(e, sector.list_sectorobjectchain, sectorobjectchain, sectorobjectchain_prev);
			e.sectorent = sector;
			return;
		}
	}
}

float loadsectorentchaintime;
void SendBottleNeckedSectorEnts() =
{
//	if(loadsectorentchaintime > time)
//		return;

//	loadsectorentchaintime = time+0.1;
		
	list_loadingsectorentchain.SendFlags = SFL_ISNEW;
	LoadingSectorEntChain_Remove(list_loadingsectorentchain);
}

void SpawnSector(float grid_id) =
{
	local entity e, sector;
	local float buf, count, buffersize;
	local string line;
	local vector ang;
	
	sector = spawn();
	sector.sectorid = grid_id;
	SectorChain_Add(sector);
	
	buf = sector_startbuf + grid_id - 1;
	
	spawningsectorents = TRUE;
	buffersize = GetBufferSize(buf);
	for(count = 0; count < buffersize; count++)
	{
		line = GetBufferString(buf, count);
		FreeBufferString(buf, count);
		e = SpawnEnt();
		LoadEntity(e, line, 0);	
		ang = e.angles;
		ObjectChain_Add(e);
		SpawnEntity(e, e.objclass, e.variant);
		e.angles = ang;
		InitializeSharedEnt(e);
		sector.list_sectorobjectchain = LinkedList_Add(e, sector.list_sectorobjectchain, sectorobjectchain, sectorobjectchain_prev);
		e.sectorent = sector;
		
		if(e.isdead)
			ApplyDeathSolidState(e);
	}
	
//	SetUpEntPointers();
	
	spawningsectorents = FALSE;
}

void SpawnAllHiddenSectors() =
{
	local float grid_id, sector_exists;
	local entity sector;

	for(grid_id = 1; grid_id <= sector_endbuf; grid_id++)
	{
		for(sector = list_sectorchain; sector; sector = sector.sectorchain)
		{
			if(sector.sectorid == grid_id)
			{
				sector_exists = TRUE;
				break;
			}
		}
		
		if(!sector_exists)
			SpawnSector(grid_id);
		else
			sector_exists = FALSE;	
	}
}

vector GetGridOffsetForSectionNum(float num) =
{
	local float row, column, sec;
	local vector offset;

	sec = num;

	row = ceil(sec/3);
	column = sec-((row-1)*3);
	offset_x = SECTOR_GRIDSIZE*(column-2);
	offset_y = SECTOR_GRIDSIZE*(row-2);	
	
	return offset;
}

void ManageSectors() =
{
	local float grid_id, sector_exists, playerinsector, row, column, count;
	local entity e, sector, nexte, nextsector;
	local vector offset;
	
	for(e = list_playerchain; e; e = e.playerchain)
	{
		for(count = 1; count <= 9; count++)
		{
			offset = GetGridOffsetForSectionNum(count);
			grid_id = GetGridSectorID(e.origin+offset);
			
			if(grid_id != -1)
			{
				for(sector = list_sectorchain; sector; sector = sector.sectorchain)
				{
					if(sector.sectorid == grid_id)
					{
						sector_exists = TRUE;
						break;
					}
				}
				
				if(!sector_exists)
					SpawnSector(grid_id);
				else
					sector_exists = FALSE;	
			}
		}
	}
	
	sector = list_sectorchain;
	while(sector)
	{
		nextsector = sector.sectorchain;
		playerinsector = FALSE;
		
		for(e = list_playerchain; e && !playerinsector; e = e.playerchain)
		{
			for(count = 1; count <= 9 && !playerinsector; count++)
			{
				offset = GetGridOffsetForSectionNum(count);
				grid_id = GetGridSectorID(e.origin+offset);		
		
				if(grid_id == sector.sectorid)
					playerinsector = TRUE;
			}
		}
	
		if(!playerinsector)
		{
			sector.sectorid = 0;
			e = sector.list_sectorobjectchain;
			while(e)
			{
				nexte = e.sectorobjectchain;
				AssignObjectToSector(e);
				e = nexte;
			}
			
			SectorChain_Remove(sector);
			SH_RemoveEnt(sector);
		}
		else
			playerinsector = FALSE;
		
		sector = nextsector;
	}
}*/

void ParseObjectsFromFile() =
{
	local string line;
	local entity e, nexte;
	local float file, count, entsperframe, minversion, totalobjects;
	
	entsperframe = 10000000;	
	
	file = server_loadingobjectsfromfile;
	line = fgets(file);
	for(count = 0; line && count < entsperframe; count++)
	{
		minversion = 1.5;
		if(EPISODE < minversion)
		if(!singleplayer)
		if(maxplayers == 1 || alloweditorinmultiplayer) 
		if(adminmodeactive || (!singleplayer && maxplayers == 1))
		{		
			if(totalobjects >= 200)
			{
				server_loadingobjectsfromfile = FALSE;
				fclose(file);
				missionfileexists = FALSE;
		//		SpawnAllHiddenSectors();
				ClearEntities();
				return;
			}

			totalobjects++;		
		}
		
		e = SpawnEnt();
		LoadEntity(e, line, 0);	
		
		ObjectChain_Add(e);

		if(mission_fileversion >= 1)
		{
			if(e.objclass != OBJ_TRAIN)
			if(e.objclass == OBJ_OBJECTIVE)
				InitializeObjective(e);
			else
			if(e.objclass == OBJ_PATH)
				InitializePath(e);
			else
			{
			//	print(ftos(e.objclass));print(" - ");print(ftos(e.variant));print("\n");
			
				e = SpawnEntity(e, e.objclass, e.variant);
				InitializeSharedEnt(e);
				
				if(LOADINGFROMEPISODE > EPISODE)
					SH_RemoveEnt(e);
		//		else
		//			AssignObjectToSector(e);
			}
		}
		
		e = world;
		if(count+1 < entsperframe)
			line = fgets(file);
	}

	if(count == entsperframe)
		return;

	server_loadingobjectsfromfile = FALSE;
	
	fclose(file);	

	if(mission_fileversion < 1)
	{
		e = list_objectchain;
		while(e)
		{
			nexte = e.objectchain;

			if(e.objclass != OBJ_TRAIN)
			if(e.objclass == OBJ_OBJECTIVE)
				InitializeObjective(e);
			else
			if(e.objclass == OBJ_PATH)
				InitializePath(e);
			else
			{
				e = SpawnEntity(e, e.objclass, e.variant);
				InitializeSharedEnt(e);
				if(LOADINGFROMEPISODE > EPISODE)
					SH_RemoveEnt(e);
		//		else
		//			AssignObjectToSector(e);
			}	
			
			e = nexte;
		}
	}
	
	SetUpEntPointers();
	
	SpawnPlayers();
	
	if(adminmodeactive)
	if(!server_bottleneck_ent)
		server_bottleneck_ent = list_objectchain;
	
	UpdateTriggers();	
	
	admin_reloadingents	= FALSE;
	
	dprint("Entities loaded.\n");
}

string GetLocalMissionBriefing(float language) =
{
	local float file;
	local string filename, briefing, line;

	if(language == MISSION_LANGUAGE)
		briefing = mission_briefing;
	else
	{
		briefing = "DEFAULT";
		filename = GetMissionFilename(gamemode, campaign, mission, TRUE, language);
		file = FileOpen(filename, FILE_READ);

		if(file != -1)
		{
			for(line = fgets(file); line && briefing == "DEFAULT"; line = fgets(file))
			{
				tokenize(line);
				
				if(argv(0) == "BRIEFING")
					briefing = argv(1);
			}
			
			fclose(file);
		}
	}
	
	return briefing;
}

void ResetServerStats() =
{
	SetUpEntPointers();	
	cvar_set("campaign", "");
	cvar_set("mission", "");
	cvar_set("singleplayer", "0");
	SetServerStats();			
//	AnnounceConnectionForAllPlayers();
}

void LoadEntities() =
{
	local float file, count, new_maptime_total, new_mission_fileversion, new_mission_language, new_mission_episode;
	local string s, filename, line, c, new_mapname, new_mission_track, new_mission_briefing;
	
	if(!mission)
	{
		if(singleplayer)
			ResetServerStats();
		return;
	}
	
	filename = GetMissionFilename(gamemode, campaign, mission, FALSE, FALSE);
	file = FileOpen(filename, FILE_READ);
	
	if(file == -1)
	{
		dprint("Mission file not found for current map.\n");
		ResetServerStats();
		return;
	}
	
	local entity e;
	line = fgets(file);
	tokenize(line);
	c = argv(0);
	while(line && c != "ENTITIES")
	{
		switch(c)
		{
			case "VERSION":		new_mission_fileversion = stof(argv(1));	break;	
			case "LANGUAGE":	new_mission_language = stof(argv(1));		break;
			case "MAP":			new_mapname = argv(1);						break;
			case "TIME":		new_maptime_total = stof(argv(1));			break;
			case "TRACK":		new_mission_track = argv(1);				break;
			case "BRIEFING":	new_mission_briefing = argv(1);				break;
			case "EPISODE":		new_mission_episode = stof(argv(1));		break;
		}
		
		if(argv(0) == "MAP")
		if(new_mapname != mapname)
		{
			dprint("Warning: The specified mission was not designed for this map. Loading aborted.\n");
			fclose(file);
			ResetServerStats();
			return;
		}

		line = fgets(file);
		if(line)
		{
			tokenize(line);	
			c = argv(0);
		}			
	}	
	
	missionfileexists = TRUE;
	mission_fileversion = new_mission_fileversion;
	MISSION_LANGUAGE = new_mission_language;
	MISSIONEPISODE = new_mission_episode;	
	mission_maptime_total = new_maptime_total;
	mission_track = zonecpy(mission_track, new_mission_track);
	mission_briefing = zonecpy(mission_briefing, new_mission_briefing);

	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = mission_briefing[count+1];
		s = zonecpy(s, GetLocalMissionBriefing(count));
		mission_briefing[count+1] = s;
	}
	
	if(!MISSIONEPISODE)
		MISSIONEPISODE = 1;
	
	BroadcastMissionTrack();
	BroadcastMissionBriefing();
	
	if(c != "ENTITIES")
	{
		dprint("Warning: Mission is missing entities.\n");
		fclose(file);
		SetUpEntPointers();	
		return;
	}
	
	
	if(mission_fileversion < MISSION_FILEVERSION_CURRENT)
		dprint("WARNING: This mission file is out of date, please save and reload it to update.\n");
	
	server_loadingobjectsfromfile = file;
	
	ParseObjectsFromFile();
}

void BOGUSENT(entity e, string msg) =
{
	if(e.objclass == 0)
		dprint(msg);
}

void SaveEntities(float backup) =
{
	local entity e;
	local float file, missionep;
	local string filename, line, s, b;
	
	s = mission;	
/*	if(backup)
		s = strcat(mission, "_autosave_", ftos(gettime(GETTIME_REALTIME)));
	else
	{
		autosavemissiontime = time;
		bprint("Mission saved manually.\nResetting autosave time to 5 mins from now.\n");
	}*/
	
	filename = GetMissionFilename(gamemode, campaign, s, FALSE, FALSE);
	
	if(backup)
	{
		filename = substring(filename, 0, strlen(filename)-8);
		filename = strcat(filename, "/_", uri_escape(UnderscoreString(cvar_string("mission"))), "_autosave_", strftime(TRUE, "%Y-%m-%d_%H%M%S.mission"));
	}
	else
	{
		autosavemissiontime = time;
	//	bprint("Mission saved manually.\nResetting autosave time to 5 mins from now.\n");
	}	
	
	file = FileOpen(filename, FILE_WRITE);

	NewFileLine(file, AppendToken("VERSION", SEP_SPACE, ftos(MISSION_FILEVERSION_CURRENT)));
	NewFileLine(file, AppendToken("LANGUAGE", SEP_SPACE, ftos(MISSION_LANGUAGE)));	
	NewFileLine(file, AppendToken("MAP", SEP_SPACE, mapname)); // map name
	NewFileLine(file, AppendToken("TIME", SEP_SPACE, ftos(mission_maptime_total)));
	NewFileLine(file, AppendToken("TRACK", SEP_SPACE, mission_track));
	s =  AppendToken("BRIEFING", SEP_SPACE, SEP_QUOTE);
	b = mission_briefing[currentlanguage+1];
	if(b == "DEFAULT")
		b = mission_briefing;
	s =  AppendToken(s, b, SEP_QUOTE);
	NewFileLine(file, s);
	
	if(MISSIONEPISODE)
		missionep = MISSIONEPISODE;
	else
		missionep = EPISODE;
	
	NewFileLine(file, AppendToken("EPISODE", SEP_SPACE, ftos(missionep)));
	
	NewFileLine(file, "ENTITIES");
	
	for(e = list_objectivechain; e; e = e.objectivechain)
	{
		line = "";		
		line = PrepLine_Objective(line, e);
		NewFileLine(file, substring(line, 1, strlen(line)-1));			
	}	
	
	for(e = list_trainchain; e; e = e.trainchain)
	{

		if(!strlen(e.targetname))
			continue;
			BOGUSENT(e, "Bogus train saved\n");
		line = "";
		line = PrepLine_Train(line, e);
		NewFileLine(file, substring(line, 1, strlen(line)-1));
	}
	
	for(e = list_ambientsoundchain; e; e = e.ambientsoundchain)
	{
		if(e.permanent)
			continue;
				BOGUSENT(e, "Bogus ambient sound saved\n");
		line = "";		
		line = PrepLine_AmbientSound(line, e);
		NewFileLine(file, substring(line, 1, strlen(line)-1));			
	}
	
	e = list_objectchain;
	while(e)
	{		
		if(IsBaseEnt(e))
		if(!e.permanent)
		if(e.objclass != OBJ_OBJECTIVE)
		if(e.objclass != OBJ_AMBIENTSOUND)
		if(e.objclass != OBJ_TRAIN)
		{BOGUSENT(e, "Bogus object saved\n");
			line = "";
			
			if(e.objclass == OBJ_PATH)
				line = PrepLine_Path(line, e);
			else
			if(e.objclass == OBJ_PARTICLEEMITTER)
				line = PrepLine_ParticleEmitter(line, e);
			else
			{
				if(!e.entid)
					SetPermanentID(e);
				line = PrepLine_Entity(line, e);	
			}

			NewFileLine(file, substring(line, 1, strlen(line)-1));
		}
		
		e = e.objectchain;
	}

	fclose(file);	
}

void SaveEntities_Default() =	{	SaveEntities(FALSE);	}
void SaveEntities_Backup() =	{	SaveEntities(TRUE);		}

float CampaignExists(string cname) =
{
	local string filename;
	local float file;

	filename = strcat("campaign/_", uri_escape(cname));
	filename = strcat(filename, "/missions.txt");

	file = FileOpen(filename, FILE_READ);
	
	if(file != -1)
	{
		fclose(file);
		return TRUE;
	}

	return FALSE;
}

void SaveEntitiesAs(float mode, string cname, string mname) =
{
	local string filename;
	local float file;
	local entity e;

	cname = UnderscoreString(cname);
	mname = UnderscoreString(mname);
	
	if(mode == GAMEMODE_CAMPAIGN)
	if(!CampaignExists(cname))
	{
		filename = strcat("campaign/_", uri_escape(cname));
		filename = strcat(filename, "/missions.txt");
		
		file = FileOpen(filename, FILE_WRITE);
		fclose(file);
	}	
	
	cvar_set("sv_gamemode", ftos(mode));
	cvar_set("singleplayer", ftos(singleplayer));
//	cvar_set("sv_itemsmode", ftos(itemsmode));
	cvar_set("campaign", cname);
	cvar_set("mission", mname);
	
	SetServerStats();	
	SaveEntities_Default();
	
	e = list_playerchain;
	while(e)
	{
		Func_oself(e, AnnounceConnection);
		e = e.playerchain;
	}
}

void SaveEntitiesAs_Check(float mode, string cname, string mname) =
{
	local string filename;
	local float file;

	cname = UnderscoreString(cname);
	mname = UnderscoreString(mname);	
	
	filename = GetMissionFilename(mode, cname, mname, FALSE, FALSE);
	file = FileOpen(filename, FILE_READ);
	
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	if(file == -1)
	{
		WriteByte(MSG_ONE, TE_ALLOWMISSIONSAVE);
		SaveEntitiesAs(mode, cname, mname);
	}
	else
	{
		WriteByte(MSG_ONE, TE_OVERWRITEMISSIONCONFIRMATION);
		fclose(file);
	}
}

void CreateCampaign_Check(string cname) =
{
	local float existingcampaign;
	cname = UnderscoreString(cname);
	existingcampaign = CampaignExists(cname);
	
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	
	if(existingcampaign)
		WriteByte(MSG_ONE, TE_DENYCAMPAIGNCREATION);
	else
		WriteByte(MSG_ONE, TE_ALLOWCAMPAIGNCREATION);
}

void RequestCampaignListToClient() =
{
	if(!self.haseditoraccess)
	if(!self.hasadminaccess)
	if(!allowvoting)
		return;

	local float searchhandle, numfiles, count, buf;
	local string campaign_title;

	buf = CreateBuffer();
	searchhandle = search_begin("data/campaign/*/missions.txt", TRUE, TRUE);
	numfiles = search_getsize(searchhandle);	

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_CAMPAIGNLIST);

	if(searchhandle != -1)
	{
		for(count = 0; count < numfiles; count++)
		{
			campaign_title = search_getfilename(searchhandle, count);
			
			if(!HasDuplicateStringInList(buf, campaign_title))
			{
				WriteString(MSG_ONE, campaign_title); 
				AddBufferString(buf, campaign_title, 0);
			}
		}	
	}
	
	WriteString(MSG_ONE, "LIST_END");
	search_end(searchhandle);
	DeleteBuffer(buf);
}

void RequestMissionListToClient(float mode, string cname) =
{
	if(!self.hasadminaccess)
	if(!allowvoting)
		return;

	local float searchhandle, numfiles, count, buf;
	local string path, mission_name;

	buf = CreateBuffer();
	
	path = strcat("data/", GetGameMode_String(mode, TRUE));
	path = strcat(path, "/");
	
	if(mode == GAMEMODE_CAMPAIGN)
	{
		path = strcat(path, "_");
		path = strcat(path, uri_escape(UnderscoreString(cname)));
		path = strcat(path, "/");
	}
	
	path = strcat(path, "*.mission");
	
	searchhandle = search_begin(path, TRUE, TRUE);
	numfiles = search_getsize(searchhandle);	

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_MISSIONLIST);

	if(searchhandle != -1)
	{
		for(count = 0; count < numfiles; count++)
		{
			mission_name = search_getfilename(searchhandle, count);
			
			if(!HasDuplicateStringInList(buf, mission_name))
			{
				WriteString(MSG_ONE, mission_name); 
				AddBufferString(buf, mission_name, 0);
			}
		}	
	}
	
	WriteString(MSG_ONE, "LIST_END");
	search_end(searchhandle);
	DeleteBuffer(buf);
}

void RequestGameModeListToClient() =
{
	local float minepisode, allowmode;

	if(!self.hasadminaccess)
	if(!allowvoting)
		return;
		
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_GAMEMODELIST);
	
	WriteByte(MSG_ONE, cvar("sv_allowgamemode_campaign") || gamemode == GAMEMODE_CAMPAIGN);
	WriteByte(MSG_ONE, cvar("sv_allowgamemode_deathmatch") || gamemode == GAMEMODE_DEATHMATCH);

	minepisode = 2;
	if(EPISODE >= minepisode)
	if(cvar("sv_allowgamemode_ctf") || gamemode == GAMEMODE_CTF) 
		allowmode = TRUE;
	WriteByte(MSG_ONE, allowmode);
}

void ResetPlayerVotes() =
{
	local entity e;
	for(e = list_playerchain; e; e = e.playerchain)
	{
		e.stat_vote_tally_yes = 0;
		e.stat_vote_tally_no = 0;
		e.stat_vote_tallytime = 0;
		e.vote_ballot = FALSE;
	}
}

void CancelVote() =
{
	vote_type = 0;
	vote_force = 0;
	vote_applysettingstime = 0;
	vote_tallytime = 0;
	vote_tally_yes = 0;
	vote_tally_no = 0;
	vote_gamemode = gamemode;
	vote_campaign = freezone(vote_campaign);
	vote_mission = freezone(vote_mission);
	vote_fraglimit = 0;
	vote_capturelimit = 0;
	vote_kickplayer = 0;
	ResetPlayerVotes();	
}

void DefaultVoteSettings() =
{
	vote_gamemode = gamemode;
	vote_campaign = zonecpy(vote_campaign, campaign);
	vote_mission = zonecpy(vote_mission, mission);
	vote_fraglimit = fraglimit;
	vote_capturelimit = capturelimit;
	vote_kickplayer = 0;	
}

void ApplyVoteSettings_Mission() =
{
	cvar_set("fraglimit", ftos(vote_fraglimit));	
	cvar_set("capturelimit", ftos(vote_capturelimit));	
	StartMissionMap(vote_gamemode, vote_campaign, vote_mission);	
}

void ApplyVoteSettings_Kick() =
{
	local entity e;

	for(e = list_playerchain; e && e.id != vote_kickplayer; e = e.playerchain)
	{}
	
	dropclient(e);
	CancelVote();
}

void ApplyVoteSettings() =
{
	vote_applysettingstime = 0;
	vote_tallytime = 0;

	if(vote_type == VOTE_MISSION)
		ApplyVoteSettings_Mission();
	else
	if(vote_type == VOTE_KICK)
		ApplyVoteSettings_Kick();
}

void CountVotes() =
{
	local entity e;

	if(!vote_type)
		return;

	if(time < vote_tallytime)
	{
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(!e.requestingjoinpassword)
			if(!e.vote_ballot)
				return;
		}
	}

	if(vote_tally_yes > vote_tally_no)
		ApplyVoteSettings();
	else
		CancelVote();	
}

void UpdateVoteStatsForDisconnectingPlayer() =
{
	if(vote_kickplayer == self.id)
		CancelVote();

	if(self.vote_ballot == 1)
		vote_tally_no --;
	else
	if(self.vote_ballot == 2)
		vote_tally_yes --;
		
	CountVotes();
}

void Vote(float v) =
{
	if(!vote_tallytime)
		return;

	if(self.vote_ballot)
		return;
		
	self.vote_ballot = v+1;
	
	if(v)
		vote_tally_yes++;
	else
		vote_tally_no++;
		
	CountVotes();
}

void UpdateVoteStatsToClient(entity e, float MSG_TYPE) =
{
	if(!vote_type)
		return;

	if(MSG_TYPE == MSG_ONE)
		msg_entity = e;

	WriteByte(MSG_TYPE, SVC_TEMPENTITY);
	WriteByte(MSG_TYPE, TE_VOTESTATS);
	WriteByte(MSG_TYPE, vote_type);
		
	if(vote_type == VOTE_KICK)
		WriteLong(MSG_TYPE, vote_kickplayer);	
	else
	if(vote_type == VOTE_MISSION)
	{
		WriteByte(MSG_TYPE, vote_force);
		WriteByte(MSG_TYPE, vote_gamemode);
		WriteString(MSG_TYPE, vote_campaign);
		WriteString(MSG_TYPE, vote_mission);
		WriteShort(MSG_TYPE, vote_fraglimit);
		WriteShort(MSG_TYPE, vote_capturelimit);	
	}
}

void KickSubmit(string s) =
{
	local float pid, count, force;
	local string t;
	local entity e;
	
	if(!self.hasadminaccess)
	if(!allowvoting)
		return;
	
	count = 0;

	tokenizebyseparator(s, SEP_SPACE);
	
	if(argv(count) == "force")
	{
		force = TRUE;
		count++;
	}
	
	pid = stof(argv(count));
	for(e = list_playerchain; e && e.id != pid; e = e.playerchain)
	{}
	
	if(!e)
		return;	
	
	if(force)
	{
		if(self.hasadminaccess)	
			dropclient(e);
		return;
	}
		
	if(vote_tallytime || vote_applysettingstime)
		return;
			
	vote_tallytime = time + cvar("sv_votetallytime");
	vote_type = VOTE_KICK;
	vote_kickplayer = e.id;	
		
	UpdateVoteStatsToClient(world, MSG_ALL);
}

void VoteSubmit(string s) =
{
	local float minepisode, count, force, v_gamemode;
	local string t;

	if(!self.hasadminaccess)
	if(!allowvoting || mission_locked)
		return;
	
	tokenizebyseparator(s, SEP_SPACE);
	
	count = 0;
	if(argv(0) == "force")
		count = 1;
	
	for(t = argv(count); t; t = argv(count))
	{
		if(t == "gamemode")
			v_gamemode = stof(argv(count+1));
		count+=2;		
	}	
	count = 0;
	
	minepisode = 2;
	if(v_gamemode == GAMEMODE_CTF)
	if(minepisode > EPISODE)
		return;		
	
	if(argv(0) == "force")
	{
		if(!self.hasadminaccess)	
			return;

		CancelVote();			
		force = TRUE;
		vote_force = TRUE;
		vote_applysettingstime = time + cvar("sv_applysettingstime");
		count++;
	}
	else
	{
		if(vote_tallytime || vote_applysettingstime)
			return;
			
		vote_tallytime = time + cvar("sv_votetallytime");
	}
	
	DefaultVoteSettings();
	vote_type = VOTE_MISSION;
		
	for(t = argv(count); t; t = argv(count))
	{
		switch(t)
		{
			case "gamemode":			vote_gamemode = stof(argv(count+1));						break;
			case "campaign":			vote_campaign = zonecpy(vote_campaign, argv(count+1));		break;
			case "mission":				vote_mission = zonecpy(vote_mission, argv(count+1));		break;
			case "fraglimit":			vote_fraglimit = stof(argv(count+1));						break;
			case "capturelimit":		vote_capturelimit = stof(argv(count+1));					break;
		}
		
		count+=2;
	}
	
	UpdateVoteStatsToClient(world, MSG_ALL);
}

void InitiateVoteMenu() =
{
	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_VOTEMENU);		
}