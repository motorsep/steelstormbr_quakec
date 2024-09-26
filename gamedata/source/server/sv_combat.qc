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
float ProjectileCanHit(entity e) =
{
//	if(e.owner.owner.objclass != OBJ_NPC
//	&& e.owner.owner.class != CLASS_PLAYER)
//		return TRUE;

//	if(self.liberated)
//		return TRUE;
	
	// don't hit mothership
	if(!self.liberated)
	{
		if(e == self.parent.owner)
			return FALSE;
		
		// don't collide if sharing the same parent
		if(e.parent == self.parent)
			return FALSE;	
	}
	else
	if(e == self.liberator)
		return FALSE;
	
	// don't collide with other shots unless hitting energy ball circle
	if(e.class == CLASS_SHOT)
	if(!(e.shotvariant == PROJ_STORMSHIELD && !e.liberated))
		return FALSE;	

	return TRUE;
}

void UpdateClientGameStatus(entity victim) =
{
	local float playersstillalive, timeup, MSGTYPE, wep, lostitems1, lostitems2;
	local entity e;

	if(victim.class != CLASS_PLAYER)
		return;
	
	// don't print game status messages for alive players
	if(!(victim.health <= 0))
		return;

/*	if(GameMode_PlayerHasLives(gamemode) && !global_lives)
	{
		if(!server_restarttime)
		for(e = list_playerchain; e; e = e.playerchain)
		{
			if(e.health > 0)
				playersstillalive = TRUE;
		}
	
		if(playersstillalive)
		{
			msg_entity = victim;
			WriteByte(MSG_ONE, SVC_TEMPENTITY);
			WriteByte(MSG_ONE, TE_GAMEOVERFORPLAYER);
		}
		else
		{
			if(server_restarttime)
			{
				MSGTYPE = MSG_ONE;
				msg_entity = victim;
			}
			else
			{
				MSGTYPE = MSG_ALL;
				if(!singleplayer)
					server_restarttime = time + RESTARTTIME;
			}

			if(mission_maptime_total == -1)
				timeup = TRUE;
			
			WriteByte(MSGTYPE, SVC_TEMPENTITY);
			WriteByte(MSGTYPE, TE_GAMEOVERFORALL);
			WriteByte(MSGTYPE, timeup);
		}
	}		*/
	
	if(GameMode_PlayerHasLives(gamemode) && !global_lives)
	{
		msg_entity = victim;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_GAMEOVERFORALL);
		WriteByte(MSG_ONE, FALSE);	
	}
	else
	{
		if(GameMode_HasRespawnTime(gamemode))
			victim.deathtime = time;	
			
		msg_entity = victim;
		WriteByte(MSG_ONE, SVC_TEMPENTITY);
		WriteByte(MSG_ONE, TE_DEAD);
		
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((victim.atdeath_items1 & wep) && !(victim.earneditems1 & wep))
				lostitems1 = lostitems1 | wep;
		}
		
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((victim.atdeath_items2 & wep) && !(victim.earneditems2 & wep))
				lostitems2 = lostitems2 | wep;
		}	
		
		victim.atdeath_items1 = 0;
		victim.atdeath_items2 = 0;
		
		WriteLong(MSG_ONE, lostitems1);
		WriteLong(MSG_ONE, lostitems2);
	}
}

float ApplyInertia(float ftime) =
{
	local float inertia;

	if(self.velocity*self.velocity > 1)
	{
		if(!self.flags & FL_ONGROUND)
			inertia = 0.9;
		else
			inertia = self.movementinertia;
	
		self.velocity_x = self.velocity_x*inertia*(ftime/0.2);	
		self.velocity_y = self.velocity_y*inertia*(ftime/0.2);	
		
		if(self.behaviorflags & BF_FLIES)
		if(!self.isdead)
			self.velocity_z = self.velocity_z*inertia*(ftime/0.2);		
	//	print(vtos(e.velocity));print("\n");
	}
	else
	{
		return FALSE;
		self.velocity = '0 0 0';
	}
	
	return TRUE;
}

void StopObject() =
{
//	local float inertia;

//	if(self.objclass == OBJ_NPC || self.class == CLASS_PLAYER)
//	if(self.health <= 0)
/*	if(self.velocity*self.velocity > 1)
	{
		if(!self.flags & FL_ONGROUND)
			inertia = 0.9;
		else
			inertia = self.movementinertia;
	
		self.velocity_x = self.velocity_x*inertia;	
		self.velocity_y = self.velocity_y*inertia;	
	//	print(vtos(e.velocity));print("\n");
	}
	else
	{
		self.velocity = '0 0 0';*/
		
	if(!ApplyInertia(0.2))	
	{
		self.SendFlags = self.SendFlags | SFL_ORIGIN | SFL_ORIGIN_STOP;
		self.movetype = MOVETYPE_NONE;
		MobileEntChain_Remove(self);	
		self.think = SUB_Null;
		self.nextthink = 0;
		return;
	}
	
/*	local vector diff1;

	self.velocity = self.velocity*0.75;

	diff1 = self.velocity;
	if(diff1*diff1 <= 1)
	{
		self.velocity = '0 0 0';	
		self.SendFlags = self.SendFlags | SFL_ORIGIN | SFL_ORIGIN_STOP;
		self.movetype = MOVETYPE_NONE;
		MobileEntChain_Remove(self);
		return;
	}*/
			
	self.think = StopObject;
	self.nextthink = time+0.2;
}

void KillChildren(entity e_parent, entity attacker) =
{
	local entity e, nexte;
//	e = nextent(world);

	if(!(e_parent.behaviorflags & BF_SPAWNCHILDREN))
		return;

	e = e_parent.list_childchain;
	while(e)
	{
		nexte = e.childchain;
	
	//	if(e.owner == e_parent)
		if(e.class == CLASS_OBJECT)
		if(!e.tag_entity)
	//	if(!(e_parent.npcclass != NPC_CARRIERTANK && e.objclass == OBJ_NPC))
		{
		//	SetOwner(e, world);//e.owner = world;
		//	SetParent(e, world);
			if(!e.isdead && !e.explodeuntiltime)
			{
				e.health = 0;
				Kill(e, attacker);
			}

			e.flags = e.flags | FL_NOREVIVE;			
//			Func_oself(e, InitLongExplode);
		}
		
		e = nexte;
//		e = e.childchain;
//		e = nextent(e);
	}
}

void ApplyDeathSolidState(entity victim) =
{
	if(!victim.isusingcollisionhull)
	if(!victim.flags & FL_SOLIDONDEATH)
		victim.solid = SOLID_NOT;	
}

void PostApplyDeath() =
{
	SetObjectAppearance(self, self.objclass, self.variant);
	NonsolidChain_Remove(self);
	MakeObjectInvisibleToClients(self);
	ApplyDeathSolidState(self);
}

void ApplyDeath(entity victim) =
{
	UpdateClientGameStatus(victim);

	KillChildren(victim, world);
	RemoveTagEnts(victim);
	RemoveOwnedEnts(victim);	

	victim.isdead = TRUE;
	if(victim.deadmodels == -1)
	{
		victim.think = PostApplyDeath;
		victim.nextthink = time+0.1;
	}
	else
	{
	//	victim.SendFlags = victim.SendFlags | SFL_RESET;
		SetObjectAppearance(victim, victim.objclass, victim.variant);
		ApplyDeathSolidState(victim);
	}
	
	victim.hasturrets = FALSE;	
}

void SetDeadModelNum(entity e) =
{
	if(e.deadmodels)
		e.deadmodelnum = bound(1, ceil(random()*e.deadmodels), e.deadmodels);
	else
		e.deadmodelnum = 1;
}

void EndExplosion() =
{
	local float OCCUPY;

	ApplyDeath(self);

	if(self.objclass == OBJ_NPC)
	if(!self.behaviorflags & BF_STATIONARY)// || self.class == CLASS_PLAYER)
	{
		if(!self.behaviorflags & BF_FLIES)
			OCCUPY = TRUE;
		UnmarkGrid(self, TRUE, OCCUPY);
		RemoveUnusedCells(self, self.gridpos);
		self.gridpos = '0 0 0';
	}	
	
	if(self.class == CLASS_PLAYER)
		StopObject();
	else
	{
		TriggerObjects(0);
	
		if(self.class == CLASS_OBJECT && !self.removewhendead)
		{
			if(self.movetype)// && self.movetype != MOVETYPE_BOUNCE)
			{
				self.SendFlags = self.SendFlags | SFL_ANGLES_STOP;
				StopObject();	
			}
		}
		else
			SH_RemoveEnt(self);
	}
}

void ShortExplode() =
{
	local float rad;

	if(self.explosionradius)
		rad = self.explosionradius;
	else
		rad = -1;

	if(self.explosiondamage)
		RadiusDamage(self, world, self.explosiondamage, rad);

	if(self.deadmodels == -1)
		NonsolidChain_Add(self);

//	ApplyDeath(self);
	
//	if(!self.isusingcollisionhull)
//		self.solid = SOLID_NOT;
	self.SendFlags = self.SendFlags | SFL_EXPLODE;		

//	TriggerObjects(0);	
	EndExplosion();
}

void LongExplode() =
{
	local float rad;

	if(self.explosiondamage)
	{
		if(self.explosionradius)
			rad = self.explosionradius;
		else
			rad = -1;
		RadiusDamage(self, world, self.explosiondamage, rad);	
	}
	
	if(self.explodeuntiltime <= time)
	{
		self.explodeuntiltime = 0;
		self.ideal_yaw = self.angles_y;

		if(!self.tag_entity)
			NonsolidChain_Remove(self);	
			
		EndExplosion();
		return;
	}
		
	self.nextthink = time + 0.2;
	self.think = LongExplode;
}

void InitLongExplode() =
{
	if(self.explodetime)
		self.explodeuntiltime = time + self.explodetime;
	else
		self.explodeuntiltime = time + 0.5;
		
	if(!self.tag_entity)
	if(!self.isusingcollisionhull)
	{
	//if(big)
		self.nonsolidsolid = TRUE;

//	UpdateMobileEntChain();
//	UpdateNonsolidChain();

	// if(big)
		NonsolidChain_Add(self);
	}
	
	self.SendFlags = self.SendFlags | SFL_EXPLODE;
	LongExplode();
}

void Explode_Large() =	{	InitLongExplode();	}
void Explode_Small() =	{	InitLongExplode();	}
void Explode_Object() =	{	ShortExplode();		}

void UpdateLives(float newlivesamount) =
{
	local entity e;
	
	global_lives = newlivesamount;
	
	for(e = list_playerchain; e; e = e.playerchain)
		e.lives = newlivesamount;
}

void SimultaneousKill(entity attacker, entity victim) =
{
	local float prev_simultaneouskills_max, old_simultaneouskilltime;
	
//	prev_simultaneouskills_max = attacker.simultaneouskills_max;

	old_simultaneouskilltime = attacker.simultaneouskilltime;
	attacker.simultaneouskilltime = time+2;

	if(old_simultaneouskilltime < time)
	{
		attacker.simultaneouskills = 1;
		return;
	}

	attacker.simultaneouskills = attacker.simultaneouskills+1;
	if(victim.class != CLASS_PLAYER)
		victim.scoremultiplier = attacker.simultaneouskills;
	victim.killedby = attacker;
	victim.SendFlags = victim.SendFlags | SFL_SCOREMULTIPLIER;
	
//	attacker.simultaneouskills_max = max(attacker.simultaneouskills_max, attacker.simultaneouskills);

	attacker.scoremultiplier = attacker.scoremultiplier + attacker.simultaneouskills;
	attacker.SendFlags = attacker.SendFlags | SFL_SCOREMULTIPLIER;
	
	if(attacker.simultaneouskills >= 5)
		attacker.challenge_berserker = TRUE;
	
/*	if(prev_simultaneouskills_max >= attacker.simultaneouskills_max)
		return;
		
	if(attacker.simultaneouskills_max == 2)
		centerprint(attacker, "CHALLENGE: DOUBLEKILL");
	else
	if(attacker.simultaneouskills_max == 3)
		centerprint(attacker, "CHALLENGE: TRIPLEKILL");
	else
	if(attacker.simultaneouskills_max == 4)
		centerprint(attacker, "CHALLENGE: QUADKILL");
	else
	if(attacker.simultaneouskills_max == 5)
		centerprint(attacker, "CHALLENGE: QUINKILL");*/
}	

void KillClient(entity victim, entity attacker) =
{
	local string s, vicname, conjunction;
	local entity e;
	
	if(!(victim.health <= 0))
		return;

	if(singleplayer)
	{
		vicname = "You";
		conjunction = "have";	
	}
	else
	{
		vicname = victim.netname;
		conjunction = "has";
	}
	
/*	if(!attacker || attacker == victim)
		s = strcat("^1", vicname, SEP_SPACE, conjunction, SEP_SPACE, "commited suicide.\n");
	else
	if(attacker.class == CLASS_PLAYER)
		s = strcat("^1", vicname, SEP_SPACE, conjunction, SEP_SPACE, "been killed by ", attacker.netname, ".\n");
	else
		s = strcat("^1", vicname, SEP_SPACE, conjunction, SEP_SPACE, "been killed.\n");
	bprint(s);*/
	
	victim.atdeath_items1 = victim.items1;
	victim.atdeath_items2 = victim.items2;
	
	DropItems(victim);	
		
	for(e = list_aichain; e; e = e.aichain)
	{
		if(e.enemy == victim)
			e.enemy = world;
	}
}

float GetVictimPoints(entity attacker, entity victim, float newpoints) =
{
	local float dist, simukills, pointsmultiple, rampcutoff;
	
	dist = vlen(attacker.origin - victim.origin);
	rampcutoff = CANDAMAGEMAXDIST*0.5;
	simukills = 1;	
	pointsmultiple = 1;
	
	if(attacker.class == CLASS_PLAYER)
	{
		simukills = attacker.simultaneouskills;
		if(victim.class == CLASS_PLAYER || (victim.flags & FL_ISBOSS))	
		{
			if(dist > CANDAMAGEMAXDIST*0.6)
				pointsmultiple = 0.6;
		}
		else
		{
			if(dist > rampcutoff)
				pointsmultiple = 1 - (dist-rampcutoff)/(CANDAMAGEMAXDIST-rampcutoff);
		}
	}
	
	newpoints = newpoints*simukills*pointsmultiple;
	newpoints = floor(newpoints*0.1)*10;	
	
	return newpoints;
}

void Kill(entity victim, entity attacker) =
{
	local float newpoints;

	SetDeadModelNum(victim);
	victim.ballcontroller = world;
	victim.facetarget = world;
	victim.ideal_yaw = 0;

	if(victim.behaviorflags & BF_FLIES)
	{
		victim.movetype = MOVETYPE_BOUNCE;	
		victim.flags = victim.flags - (victim.flags & FL_ONGROUND);
	}
//	else
//		victim.velocity = victim.velocity*0.5;

	if(victim.isusingcollisionhull)
		victim.solid = SOLID_BSP;
	
	if(victim.objclass == OBJ_NPC)
		ai_killed = ai_killed + 1;
	
	if(victim.class == CLASS_PLAYER)
	{
		if(victim == attacker)
		{
			victim.suicides = victim.suicides + 1;
			UpdateScore(victim, SCORESTAT_SUICIDES);
		}
	
		victim.deaths = victim.deaths + 1; // scoreboard
		UpdateScore(victim, SCORESTAT_DEATHS);
		
		if(attacker)
		{
			if(attacker.class == CLASS_PLAYER)
			if(GameMode_PlayerVSPlayer(gamemode))
			if(!(GameMode_HasTeams(gamemode) && victim.team == attacker.team))
			{
				attacker.frags = attacker.frags + 1; // scoreboard
				UpdateScore(attacker, SCORESTAT_FRAGS_PLAYER);
				SimultaneousKill(attacker, victim);
			}
				
			if(GameMode_HasFragLimit(gamemode))
			if(fraglimit)
			if(attacker.frags >= fraglimit)
			if(!adminmodeactive)
				MissionScores(MSG_ALL);	
		}
		
		if(attacker.class == CLASS_PLAYER)
		if(GameMode_PlayerVSPlayer(gamemode))
		if(!(GameMode_HasTeams(gamemode) && victim.team == attacker.team))
		{
			newpoints = GetVictimPoints(attacker, victim, max(200, victim.points*0.1));
			attacker.points = attacker.points + newpoints;	
			UpdateScore(attacker, SCORESTAT_SCORE);
		}			
		
		KillClient(victim, attacker);
	}
	else
	if(attacker)
	{
		if(attacker.class == CLASS_PLAYER)
		if(victim.objclass == OBJ_NPC)
		{
			if(victim.flags & FL_ISBOSS)
				attacker.challenge_annihilator = TRUE;
		
			if(!(GameMode_HasTeams(gamemode) && victim.team == attacker.team))
			{
				attacker.frags_npc = attacker.frags_npc + 1;
				UpdateScore(attacker, SCORESTAT_FRAGS_AI);
				SimultaneousKill(attacker, victim);	
			}
		}
		else
		{
			attacker.frags_other = attacker.frags_other + 1;
			UpdateScore(attacker, SCORESTAT_FRAGS_OTHER);
		}
			
		newpoints = GetVictimPoints(attacker, victim, victim.points*skillmultiple);
		attacker.points = attacker.points + newpoints;//max(200, victim.points*0.1)*attacker.simultaneouskills;	

		if(attacker.class == CLASS_PLAYER)
			UpdateScore(attacker, SCORESTAT_SCORE);
	}
	
	if(IsAssignedFunction(victim.DeathFunc))
	{
		// delay to avoid problems with radius damage chain breaking
		victim.nextthink = time+0.1;
		victim.think = victim.DeathFunc;
	}
//		Func_oself(victim, victim.DeathFunc);
		
//	if(attacker)
//		attacker.SendFlags = attacker.SendFlags | SFL_SCORE;
//	victim.SendFlags = victim.SendFlags | SFL_SCORE;
}

void RechargeShields() =
{
	if(!frametime)
		return;

	if(self.health <= 0)
		return;

	if(self.armorchargetime + 3 > time)
		return;
		
	local float fullchargetime;
	fullchargetime = 8;
		
	if(self.armorvalue < self.maxshields)
		self.armorvalue = bound(0, self.armorvalue+(100/(fullchargetime/frametime)), self.maxshields);
}

void ApplyStructuralEffects(entity e, float damage) =
{
//	local float e_damage_stage1, e_damage_stage2;
	
	if(e.damage_effects & DMGEF_BURN)
	{
//		e_damage_stage1 = e.max_health*0.66;
//		e_damage_stage2 = e.max_health*0.33;
		
/*		if(e.health > e_damage_stage1)
		if(e.health + damage <= e_damage_stage1)
		{
			e.effectflags -= e.effectflags & EFF_SMOKE;
			e.effectflags -= e.effectflags & EFF_BURN;
			e.SendFlags = e.SendFlags | SFL_EFFECTS;	
		}*/
//			e.SendFlags = e.SendFlags | SFL_DAMAGE_REPAIRED;
		
		if(e.health <= e.max_health*0.66)
		if(!(e.effectflags & EFF_SMOKE))
//		if(e.health > e_damage_stage2)
//		if(e.health + damage > e_damage_stage1)
//		|| e.health + damage <= e_damage_stage2)
		{
			e.effectflags = e.effectflags | EFF_SMOKE;
			e.SendFlags = e.SendFlags | SFL_EFFECTS;				
		}
			
		if(e.health <= e.max_health*0.33)
		if(!(e.effectflags & EFF_BURN))
//		if(e.health + damage > e_damage_stage2)
		{
			e.effectflags = e.effectflags | EFF_BURN;
			e.SendFlags = e.SendFlags | SFL_EFFECTS;				
		}
	}
}

void Damage(entity attacker, entity victim, entity projectile, float damage) =
{
	local float unblockedshielddamage, oldhealth;

//	if(coop)
//	if(attacker.class == CLASS_PLAYER)
//	if(victim.class == CLASS_PLAYER)
//		return;

	if(activityhalted)
		return;

	if(victim.flags & FL_GODMODE || victim.godmode)
		return;

	if(victim.health <= 0)
		return;
		
	if(victim.adminmode)
		return;
		
	if(!projectile.liberated)
	if(!CanDamage(attacker, victim, world))
		return;
		
	if(damage < 0)	// goes through armor
		damage = damage*-1;
	else
	if(victim.armorvalue)
	{
		unblockedshielddamage = min(victim.armorvalue, damage);
		unblockedshielddamage = unblockedshielddamage*(0.2-(0.04*ceil(victim.armorvalue/100)));
	
		victim.armorchargetime = time;
		victim.armorvalue = victim.armorvalue - damage;
		
		if(victim.armorvalue < 0)
		{
			damage = victim.armorvalue*-1;
			victim.armorvalue = 0;
		}
		else
			damage = 0;
			
		if(victim.armorvalue <= victim.maxshields - 100)
	//	if(victim.maxshields)// > 100)
			victim.maxshields = ceil(victim.armorvalue*0.01)*100;
	}
		
	oldhealth = victim.health;
	victim.health = max(0, victim.health - damage - unblockedshielddamage);
	
	if(attacker.class == CLASS_PLAYER)
	{
		attacker.damagedealt = attacker.damagedealt + damage; // scoreboard
		UpdateScore(attacker, SCORESTAT_DAMAGE_DEALT);
	}
	
	if(victim.class == CLASS_OBJECT)
	{
		if(victim.health <= victim.max_health*0.66 && oldhealth > victim.max_health*0.66)
			Func_oself(victim, TriggerObjects_StageTwo);
		if(victim.health <= victim.max_health*0.33 && oldhealth > victim.max_health*0.33)
			Func_oself(victim, TriggerObjects_StageThree);	
			
		if(victim.health <= victim.max_health*0.33 && oldhealth > victim.max_health*0.33 && IsAssignedFunction(victim.TriggerEventFunc_StageThree))
			Func_oself(victim, victim.TriggerEventFunc_StageThree);
		else
		if(victim.health <= victim.max_health*0.66 && oldhealth > victim.max_health*0.66 && IsAssignedFunction(victim.TriggerEventFunc_StageTwo))
			Func_oself(victim, victim.TriggerEventFunc_StageTwo);				
	}
	
	if(victim.health <= 0)
	{
		Kill(victim, attacker);
		Challenges_Kills(attacker, victim, projectile);
	}
	else
	{
		ApplyStructuralEffects(victim, damage);
	
		if(victim.objclass == OBJ_NPC)
		{
			if(!victim.enemy)
			if(victim.alertness & ALERTNESS_DAMAGE)
				FoundThreat(victim, attacker, FALSE);
				
			if(victim.enemy)
				AI_Dodge(victim, attacker);
		}
	}
	
	if(attacker.class == CLASS_PLAYER)
	{
		if(victim.showhealth)
		if(victim.objclass == OBJ_NPC
		|| ((victim.istrigger || victim.associationentid) && victim.showhealth_victim)
		|| victim.showhealth == 2)
		{
			if(attacker.lastentdamaged != victim)
			if(attacker.playertargetswitchtime < time)
			{
				attacker.playertargetswitchtime = time + 1;
				attacker.SendFlags = attacker.SendFlags | SFL_TARGETNAME;
				attacker.lastentdamaged = victim;
			}
				
			if(victim == attacker.lastentdamaged)
			{
				attacker.enemyhealth_max = victim.max_health;
				attacker.enemyhealth = victim.health;
				attacker.enemyobjclass = victim.objclass;
				attacker.enemyvariant = victim.variant;
			}
		}
	}
}

void RadiusDamage(entity dmgent, entity victim, float damage, float rad) =
{
	local entity cd, nextcd;
	local vector diff1;

	if(rad == -1)
		rad = dmgent.maxs_x*2 + 200;
	
	cd = findradius(dmgent.origin, rad);
	while(cd)
	{
		nextcd = cd.chain;
	
		if(cd != dmgent.parent)
		if(cd != victim)
		if(cd != dmgent)
		if(ProjectileCanHit(cd))
		{
			diff1 = cd.origin - dmgent.origin;
			if(diff1*diff1 <= rad*rad)		
				Damage(dmgent.parent, cd, dmgent, damage - damage*vlen(cd.origin - dmgent.origin)/rad);
		}
		cd = nextcd;
	}
}

void AddStunTime(entity e, float addtime) =
{
	if(e.stuntime < time)
		e.stuntime = time + addtime;
	else
		e.stuntime = e.stuntime + addtime;
		
	e.effectflags = e.effectflags | EFF_STUN;
	e.SendFlags = e.SendFlags | SFL_EFFECTS;
}

void AddWepDisableTime(entity e, float addtime) =
{
	if(e.wepdisabletime < time)
		e.wepdisabletime = time + addtime;
	else
		e.wepdisabletime += addtime;
		
	if(e.wepdisabletime > time+5)
		e.wepdisabletime = time+5;
		
	e.globalcooldown = e.secondarycooldown = e.wepdisabletime;
	
	e.effectflags = e.effectflags | EFF_WEPDISABLE;
	e.SendFlags = e.SendFlags | SFL_EFFECTS;	
}

void Revive(entity e) =
{
	local entity e_ally, e_enemy;

	if((e.flags & FL_REVIVE) || !(e.health <= 0))
		return;

	e.think = SUB_Null;
	e.nextthink = 0;
	e.velocity = '0 0 0';
	e.movetype = MOVETYPE_NONE;
	e.solid = SOLID_NOT;
	e.flags = e.flags | FL_REVIVE;

	e_ally = e.ally;
	e_enemy = e.enemy;
	e.ally = e.enemy = world;
	
/*	e.isdead = FALSE;
	e.deadmodelnum = 0;
	e.nonsolidsolid = FALSE;
	NonsolidChain_Remove(e);		*/
	ClearEntData(e);

	SpawnEntity(e, e.objclass, e.variant);
	e.SendFlags = e.SendFlags | SFL_RESET;
	InitializeSharedEnt(e);

	if(e_ally)
	if(e_ally.health <= 0)
		FoundThreat(e, e_ally, TRUE);		
		
	if(e_enemy)
	if(!(e_enemy.health <= 0))
		FoundThreat(e, e_enemy, FALSE);
		
	if(e.objclass == OBJ_NPC)
		e.points = 0;	
}