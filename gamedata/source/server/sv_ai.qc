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
void AI_FireShockwave() =
{
	local vector diff;
	local float fire, canhit;
	local entity e, oself;
	
	oself = self;
	
	if(self.enemy)
	{
		diff = self.origin - self.enemy.origin;
		if(diff*diff <= 600*600)
			fire = TRUE;
	}
	
	if(!fire)
	for(e = findradius(self.origin, 400); e; e = e.chain)
	{
		if(e.class != CLASS_SHOT)
			continue;
			
		self = e;
			if(ProjectileCanHit(oself))
				canhit = TRUE;
			else
				canhit = FALSE;
		self = oself;
		
		if(canhit)
		{
			diff = self.origin - e.origin;
			if(diff*diff <= 400*400)	
			{
				fire = TRUE;
				break;
			}
		}
	}
	
	if(fire)
		FireWeapon(FALSE, WEP2_SHOCKWAVE,FALSE, 2);
}

/*void AlertAI_audio(entity noisyent) =
{
	local entity e;
	e = findradius(noisyent.origin, 1500);
	while(e)
	{
		if(e.objclass == CLASS_NPC)
		if(vlen(e.origin - noisyent.origin) <= e.alertness_audio)
		{
			e.enemy = noisyent;
			e.action = e.action | ACT_FIGHT | ACT_MOVE;
			if(e.sound_spottedenemy)
				PlaySound(e, CHAN_VOICE, e.sound_spottedenemy);
		}
		
		e = e.chain;
	}
}*/

void NotifyChildrenOfOwnerThreat(entity victim, entity threat, float repair) =
{
	local entity e;
	e = victim.list_childchain;
	while(e)
	{
		if(e.objclass == OBJ_NPC)
	//	if((e.weapon == WEP_REPAIR && !e.ally)
	//	|| (e.weapon != WEP_REPAIR && !e.enemy))
				FoundThreat(e, threat, repair);
			
		e = e.childchain;
	}
}

void FoundThreat(entity victim, entity threat, float repair) =
{
//	if(victim.npcclass < NPC_STATIONARYTURRET || victim.npcclass > NPC_STATIONARYTURRET+NUMTURRETTYPES)

	if(((victim.weapon == WEP_REPAIR || !victim.weapon) && repair)
	|| (victim.weapon != WEP_REPAIR && !repair))
	{
		if(repair)// && (victim.weapon == WEP_REPAIR || !victim.weapon))
		{
			if(victim.ally == threat)
				return;
			victim.ally = threat;
		}
		else
		if(!repair)// && victim.weapon != WEP_REPAIR)
		{
			if(victim.enemy == threat)
				return;
			victim.enemy = threat;
		}

		victim.action = victim.action | ACT_THREATENED;
		victim.reactiontime = time + victim.alertnessdelay;	
	}
	
	NotifyChildrenOfOwnerThreat(victim, threat, repair);
}

void AI_ReactToThreat() =
{
	self.action -= self.action & ACT_THREATENED;
	self.action = self.action | ACT_FIGHT | ACT_MOVE;
	self.roamtime = 0;
}

void AI_AssessThreats() =
{
	local vector org, ang, diff1, diff2, angtothreat, v_ofs, disttodeadally, disttothreat, disttopotentialthreat, disttoenemy;
	local float diffA, assisting, dangerrange;
	local entity potential_threat, next_potential_threat, last_potential_threat, threat, deadally;
	
	dangerrange = 1800;
	
	if(self.tag_index)
	{
		org = gettaginfo(self.tag_entity, self.tag_index);
		ang = self.owner.angles + self.angles;
	}
	else
	{
		org = self.origin;
		ang = self.angles;
	}

	if(self.ally)
	if(!(self.ally.health <= 0))
		self.ally = world;
	else
	{
		deadally = self.ally;
		disttodeadally = self.ally.origin - org;
	}	

	if(self.enemy)
	if(self.enemy.adminmode || (self.enemy.flags & FL_NOTARGET)
	|| self.enemy.health <= 0)
		self.enemy = world;
	else
	{
		threat = self.enemy;
		disttothreat = self.enemy.origin - org;
	}			
				
	if(!IsAttachedAIClass(self.npcclass))	
	{
		v_ofs_z = (self.maxs_z - self.mins_z)*0.75;
		
		potential_threat = findradius(org, dangerrange);
		while(potential_threat)
		{
			diff1 = potential_threat.origin - org;
			if(diff1*diff1 > dangerrange*dangerrange)
			{
				potential_threat = potential_threat.chain;
				continue;	
			}
				
			angtothreat = vectoangles(potential_threat.origin - org);
			disttopotentialthreat = potential_threat.origin - org;
			assisting = FALSE;
			next_potential_threat = potential_threat.chain;
			
			if(potential_threat.objclass == OBJ_NPC)
			if(potential_threat == last_potential_threat)
				last_potential_threat = world;
			else
			if(potential_threat.enemy) // if another ai has an enemy assist
			{
				diff1 = self.origin - potential_threat.enemy.origin;
				diffA = dangerrange*1.5;	// at 1.5 x normal range
				if(diff1*diff1 <= diffA*diffA) 
				{
					next_potential_threat = potential_threat;
					last_potential_threat = potential_threat;
					potential_threat = potential_threat.enemy;
					assisting = TRUE;
				}
			}
			
			if(!potential_threat.adminmode)
			if(!(potential_threat.objclass == OBJ_NPC && potential_threat.godmode))
			if(!IsAttachedAIClass(potential_threat.npcclass))
			if(potential_threat != self)
			if(potential_threat != self.owner)
			{
				diff1 = potential_threat.origin - org;
				diffA = (self.maxs_x+potential_threat.maxs_x)*2+250;
				
				if((self.alertness & ALERTNESS_OMNIDIRECTIONAL || (self.alertness & ALERTNESS_CONE && AngleDifference(ang_y, angtothreat_y) <= 80)) || diff1*diff1 < diffA*diffA || assisting)
				{
					if((self.behaviorflags & BF_LOOKFORALLIES) || self.weapon == WEP_REPAIR)
					if(!potential_threat.adminmode)
					if(!potential_threat.flags & FL_NOTARGET)
					{
						if(potential_threat != self.ally)
						if(potential_threat.objclass == OBJ_NPC)
						if(potential_threat.team == self.team)
						if(!(potential_threat.flags & FL_NOREVIVE))
						if(potential_threat.isdead)//health <= 0)
						if(!deadally || (deadally && disttopotentialthreat*disttopotentialthreat < disttodeadally*disttodeadally))
						{
							self.owner.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
							traceline(org + v_ofs, potential_threat.origin + v_ofs, TRUE, self.owner);
							self.owner.dphitcontentsmask = FALSE;
							if(trace_fraction == 1)
							{
								deadally = potential_threat;				
								disttodeadally = deadally.origin - org;
							}
						}
					}
					
					if(potential_threat != self.enemy)
					if(potential_threat.class == CLASS_PLAYER || potential_threat.objclass == OBJ_NPC)
					if(potential_threat.team != self.team && potential_threat.team != -1)
					if(!(potential_threat.health <= 0))
					if(!threat || (threat && disttopotentialthreat*disttopotentialthreat < disttothreat*disttothreat))
				//	if(!self.enemy || disttopotentialthreat*disttopotentialthreat < disttoenemy*disttoenemy)
					{
						self.owner.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_BODY;
						traceline(org + v_ofs, potential_threat.origin + v_ofs, TRUE, self.owner);
						self.owner.dphitcontentsmask = FALSE;
						if(trace_fraction == 1)
						{
							threat = potential_threat;				
							disttothreat = threat.origin - org;
						}
					}
				}
			}
				
			potential_threat = next_potential_threat;
		}
		
		if(deadally)
		if(deadally != self.ally)
			FoundThreat(self, deadally, TRUE);		
		
		if(threat)
		if(threat != self.enemy)
			FoundThreat(self, threat, FALSE);
	}
	
	if(!self.enemy && !self.ally)
	{
		self.action -= self.action & ACT_FIGHT;
		self.facetarget = world;
	}
}

void AI_Idle() =	{}

void AI_SpawnChildren() =
{
	if(self.spawnchildrentime > time)
		return;
		
	if(self.numchildren >= self.maxchildren)
		return;

	self.spawnchildrentime = time+0.5;
		
	local entity e;
	e = SpawnEnt();		
	SetOwner(e, self);//e.owner = self;
	SetParent(e, e);
//	SetID(e);
	
	self.numchildren++;
	
	local string tagname;
	local vector org, ang;
	local float repair;
	
	tagname = strcat(self.childtagprefix, ftos(self.numchildren)); 
	e.spawnedfromtag = gettagindex(self, tagname);
	org = gettaginfo(self, e.spawnedfromtag);
	e.angles_y = self.angles_y;	
	
	if(self.npcclass == NPC_CARRIERTANK)
	{
		if(self.numchildren <= 4)
			e.angles_y += 90;
		else
			e.angles_y -= 90;
			
		SetEventFlag_Sound(e, SOUND_FLYERDOCKOUT);
	}
		
	e.spawnang = e.angles_y;
	
	ang = e.angles;
	ang_x = ang_x*-1;
		
	makevectors(ang);
		
	org = org+v_forward*e.maxs_x*2;
	setorigin(e, org);	

	e.class = CLASS_OBJECT;
	
	Func_oself(e, self.SpawnChildrenFunc);
	
	if(e.weapon == WEP_REPAIR)
		repair = TRUE;
		
	FoundThreat(e, self.enemy, repair);	
}

vector GetLeadAngle(vector firepos, entity combattarget, float WEP1) =
{
	local vector projectile_vel, projectile_ang, combattarget_speed, combarttarget_org, angtothreat;
	local float projectile_speed, missing_projectile_speed, maxleadangle;

	maxleadangle = 25;
	
	projectile_speed = GetProjectileSpeed(WEP1, 0);
	combattarget_speed = combattarget.velocity;
	
	combarttarget_org = combattarget.origin;
	combarttarget_org_z += (combattarget.maxs_z+combattarget.mins_z)*0.5;	
	
	 // shot is instant, projectile is too slow to lead, or target is moving erratically so just shoot at target's origin
	if(combattarget_speed*combattarget_speed >= projectile_speed*projectile_speed
	|| combattarget.constantspeedtime < 320/max(1, projectile_speed))
		return vectoangles(combarttarget_org - firepos);
	
	projectile_vel = combattarget.velocity + (combarttarget_org - firepos);
	missing_projectile_speed = projectile_speed - vlen(projectile_vel);
	projectile_vel = projectile_vel + normalize(combarttarget_org - firepos)*missing_projectile_speed;
	projectile_ang = vectoangles(projectile_vel);
	angtothreat = vectoangles(combarttarget_org - firepos);

	if(projectile_ang_y - angtothreat_y > maxleadangle)
		projectile_ang_y = angtothreat_y + maxleadangle;
	else
	if(projectile_ang_y - angtothreat_y < maxleadangle*-1)
		projectile_ang_y = angtothreat_y - maxleadangle;	
	
	return projectile_ang;
}

void AI_Fight() =
{
	local vector diff1, angtothreat, ang, org, combarttarget_org, projectedorg;
	local float diffA, IGNORE, tagindex, attacker_maxpitchaim;
	local entity combattarget;
	
	if(!self.maxpitchaim)
		attacker_maxpitchaim = 25;
	else
		attacker_maxpitchaim = self.maxpitchaim;
	
	if(self.weapon == WEP_REPAIR)
		combattarget = self.ally;
	else
		combattarget = self.enemy;
		
	combarttarget_org = combattarget.origin;
	combarttarget_org_z += (combattarget.maxs_z+combattarget.mins_z)*0.5;
	
	if(self.behaviorflags & BF_SPAWNCHILDREN)
		AI_SpawnChildren();
	
	if(self.behaviorflags & BF_HARASS)
	{
		diff1 = combattarget.origin - self.origin;
		diffA = self.engagedist_far+512;
		if(diff1*diff1 > diffA*diffA || (!self.action & ACT_HARASS_ATTACK && !self.action & ACT_HARASS_FLEE))
		{
			if(!self.action & ACT_HARASS_ATTACK)
			{
				self.action = self.action - (self.action & ACT_HARASS_FLEE);
				self.action = self.action | ACT_HARASS_ATTACK;
			}
		}
		else
		if(!self.action & ACT_HARASS_FLEE)
		if(self.firetime)
		if(self.firetime <= time)
		{
			self.firetime = 0;
			self.action = self.action - (self.action & ACT_HARASS_ATTACK);
			self.action = self.action | ACT_HARASS_FLEE;
		}
	}

	if(self.ammo_rockets_max && !self.ammo_rockets_current)
		return;
		
	tagindex = self.(shootfrom_index[self.firingfrom]);	
	if(tagindex || self.owner != self)
		org = gettaginfo(self, tagindex);
	else
	{
		org = self.origin;
		org_z += (self.maxs_z+self.mins_z)*0.5;
	}
	
	if(IsAttachedAIClass(self.npcclass))// == NPC_TURRET)
		ang_y = self.angles_y + self.owner.angles_y;		
	else
		ang_y = self.angles_y;		

	makevectors(ang);
	org = org + v_forward*-self.maxs_x*1.5;
		
	if(!self.firebuilduptime)
	if(AttackFinished(self, self.weapon, 0, 1) < time)//self.(attack_finished[self.weapon]) < time)
	{
		diff1 = org - combattarget.origin;
		if(diff1*diff1 <= CANDAMAGEMAXDIST*CANDAMAGEMAXDIST)
		{
			local float coneoffire;

			if(self.weapon == WEP_REPAIR)
			{
				IGNORE = TRUE;
				coneoffire = 15;
			}
			else
			{
				IGNORE = FALSE;
				coneoffire = 15;
			}
			
			angtothreat = GetLeadAngle(org, combattarget, self.weapon);
			diff1 = org - combattarget.origin;
			
			if(AngleDifference(angtothreat_x, 0) <= attacker_maxpitchaim)
			if(AngleDifference(ang_y, angtothreat_y) <= coneoffire)
			if(!self.weaponrange || diff1*diff1 <= self.weaponrange*self.weaponrange)
			{
				local entity shooter;
				if(self.objclass == OBJ_NPC && self.tag_entity)
					shooter = self.parent;
				else
					shooter = self;	
			
				makevectors(angtothreat);
				projectedorg = org + v_forward*vlen(combarttarget_org - org);

				if(combattarget == self.ally)
					traceline(org, projectedorg+'0 0 17', IGNORE, shooter);
				else
					tracebox(org, '-16 -16 -16', '16 16 16', projectedorg+'0 0 17', IGNORE, shooter);
				if(trace_fraction == 1 || trace_ent == combattarget)
				{
					if(IsAssignedFunction(self.FiringRules))
						self.FiringRules();
					
					if(IsAssignedFunction(self.FireFunc))
						self.FireFunc();
					else
						FireWeapon(self.weapon, 0, FALSE, 1);
				}
			}
		}
	}
	else
		WeaponAutoFire(self.weapon, 0);	

	if(self.wepreleasetime)
	if(self.wepreleasetime < time)
	{
		self.wepreleasetime = FALSE;
		self.WepReleaseFunc();
	}
	
	if(IsAssignedFunction(self.SecondaryWeaponFiringRules))
		self.SecondaryWeaponFiringRules();
}

float ConditionTargYaw(float y) =
{
	if(y > self.yaw_maxleft && y > self.yaw_maxright)
		y -= 360;
	else
	if(y < self.yaw_maxleft && y < self.yaw_maxright)
		y += 360;
		
	return y;		
}

void AI_Dock() =
{
	if(time > self.refueltime)
	{
		local vector pos, ang;

		SetObjectAppearance(self, self.objclass, self.variant);
	//	SetObjectSize(self, self.objclass, self.npcclass);		
		
		pos = gettaginfo(self.owner, self.spawnedfromtag);
		ang = self.owner.angles;
		ang_y += self.spawnang;
		ang_x = ang_x*-1;
		makevectors(ang);
		pos += v_forward*self.maxs_x*2;

		self.angles_y = ang_y;
		setorigin(self, pos);
	
		self.action = self.action - (self.action & ACT_APPROACH);
		self.action = self.action - (self.action & ACT_DOCK);
		self.refueltime = time+15;
		self.ammo_rockets_current = self.ammo_rockets_max;
		SetEventFlag_Sound(self, SOUND_FLYERDOCKOUT);
	}
}

float AI_Approach() =
{
	local vector pos, ang, diff1;
	local float vel, diffA;
	
	self.facetarget = world;	
	
	pos = gettaginfo(self.owner, self.spawnedfromtag);
	ang = self.owner.angles;
	ang_y += self.spawnang;
	ang_x = ang_x*-1;
	makevectors(ang);
	pos += v_forward*self.maxs_x*2;

	ang = vectoangles(pos - self.origin);
	self.ideal_yaw = ang_y;
	self.angles_x = ang_x;
	ang = self.angles;
	ang_x = ang_x*-1;
	makevectors(ang);
	
	if(vlen(self.origin - pos) < 400)
		self.yaw_speed = self.yaw_speed_base*1.5;
	else
		self.yaw_speed = self.yaw_speed_base;
		
	self.velocity = v_forward*self.movespeed*10;//vel;
	
	diff1 = self.origin - pos;
	diffA = self.maxs_x*3;
	if(diff1*diff1 < diffA*diffA)
	{
		self.velocity = '0 0 0';
		SetAndPrecacheModel(self, "");
		self.refueltime = time + 5;
		self.action = self.action - (self.action & ACT_APPROACHING);
		self.action = self.action | ACT_DOCK;
		SetEventFlag_Sound(self.owner, SOUND_FLYERDOCKIN);
	}
	
	return TRUE;
}

void AI_TurretMove() =
{
	local vector ang, targang;
	local vector org, end;
	local entity combattarget;
	
	if(self.waittomovetime <= time)
	{
		if(self.yaw_speed_base)
		{
			if((self.behaviorflags & BF_INCREASESPEEDATSTAGETHREE) && self.health <= self.max_health*0.33)
				self.yaw_speed = self.yaw_speed_base*3;	
			else
			if((self.behaviorflags & BF_INCREASESPEEDATSTAGETWO) && self.health <= self.max_health*0.66)
				self.yaw_speed = self.yaw_speed_base*2;				
			else
				self.yaw_speed = self.yaw_speed_base;
		}
	}		
	
	if(self.enemy)
		combattarget = self.enemy;
	else
	if(self.ally)
		combattarget = self.ally;

	if(combattarget)
	{
		org = gettaginfo(self.tag_entity, self.tag_index);	
//		targang = vectoangles(combattarget.origin - org);
		targang = GetLeadAngle(org, combattarget, self.weapon);
		targang_y -= self.owner.angles_y;	
		
		targang_y = ConditionTargYaw(targang_y);
		
		if(!((self.yaw_maxleft || self.yaw_maxright) && (targang_y > self.yaw_maxleft || targang_y < self.yaw_maxright)))
		{
			end = combattarget.origin;
			end_z += combattarget.mins_z + (combattarget.maxs_z - combattarget.mins_z)*0.5;
		
			traceline(org, end, TRUE, self.owner);
		
			if(trace_fraction == 1)
				ang = targang;
		}
	}

	if(!ang_y && self.angles_y != 0.1+self.yaw_baseofs)
		ang_y = 0.1+self.yaw_baseofs; // 0 ideal yaw makes ents not turn, so 0.1 is added to make them return to center
		
	self.ideal_yaw = ang_y;	
}

vector AvoidObstacles(vector targetdest) =
{
	return targetdest;
}

/*entity GetNearestDeadAlly() =
{
	local entity e, closestdeadally;
//	e = nextent(world);
	e = list_aichain;
	while(e)
	{
		if(e != self)
	//	if(e.objclass == CLASS_NPC)
		if(!IsAttachedAIClass(e.npcclass))// != NPC_TURRET)
		if(e.health <= 0)
		if(!closestdeadally || (e.owner == self && closestdeadally.owner != self) || (vlen(e.origin - self.origin) < vlen(closestdeadally.origin - self.origin)))
			closestdeadally = e;
	
		e = e.aichain;
	//	e = nextent(e);
	}
	
	return closestdeadally;
}*/

/*void RunAIDebugger(entity e, vector center, vector angA, vector angB, float angdiff, float roamrange) =
{
	local entity furthestcell, furthestalternatecell;

	self.colormod = '1 0 0';
	
	while(e)
	{
		if(e.class == CLASS_CELL)
		if(vlen(e.origin - center) <= roamrange)
		{
			SetAndPrecacheModel(e, "models/objects/nav_cell.dpm");
		
			if(!self.cellzone || e.cellzone == self.cellzone)
			{	print("A\n");
			if(!furthestcell || vlen(e.origin - center) > vlen(furthestcell.origin - center) || self.action & ACT_HARASS_ATTACK)
			{	print("B\n");	print(ftos(vlen(center - e.origin)));	print(" - ed: ");	print(ftos(self.engagedist_near));	print("\n");
		//	if(self.deadally || !self.enemy || (self.enemy && vlen(center - e.origin) >= self.engagedist_near-CELL_MAXS_x))
		//	{	print("C\n");
				if(self.enemy)
				{
					e.colormod = '0 1 0';
				
					angA = vectoangles(self.origin - self.enemy.origin);
					angB = vectoangles(e.origin - self.enemy.origin);
					
					angdiff = AngleDifference(angA_y, angB_y);
			
					if(!(self.ally || !self.enemy || (self.enemy && vlen(center - e.origin) >= self.engagedist_near-CELL_MAXS_x)))
					if( (self.behaviorflags & BF_FLIES && angdiff < 90 && vlen(self.origin - center) <= roamrange)
					|| (!(self.behaviorflags & BF_FLIES) && !self.action & ACT_HARASS_FLEE && angdiff > 45 && !self.ally)
					|| (self.action & ACT_HARASS_ATTACK && vlen(e.origin - center) > self.engagedist_far)
					|| (self.action & ACT_HARASS_FLEE && vlen(e.origin - center) <= self.engagedist_far)
					)
					{
						e.colormod = '1 0 0';
					
						if(self.behaviorflags & BF_FLIES)
							furthestalternatecell = e;
						else
						if(!EntityInCellProximity(e, FALSE))
							furthestalternatecell = e;

						e = e.chain2;
						continue; // skip this cell
					}
				}

				print("D\n");
				
				if(self.behaviorflags & BF_FLIES)
					furthestcell = e;
				else
				 if(!EntityInCellProximity(e, TRUE))
					furthestcell = e;
			}}
			
			e.colormod_z = 1;/// = '0 0 1';
		}
	
		e = e.chain2;
	}	
}*/

vector GetRoamDest() =
{
	local float roamrange, r;
	local vector diff1, center, ang, pos, ofs;

	if(!(self.approachtime && time < self.approachtime))
	if((self.refueltime && time >= self.refueltime) || (self.ammo_rockets_max && !self.ammo_rockets_current))
	{
		self.action = self.action | ACT_APPROACH;
	
		pos = gettaginfo(self.owner, self.spawnedfromtag);
		ang = self.owner.angles;
		ang_y += self.spawnang;
		ang_x = ang_x*-1;
		makevectors(ang);
		pos += v_forward*self.maxs_x*10;
		ang = self.owner.angles;
		ang_x = ang_x*-1;
		makevectors(ang);
		pos += v_forward*vlen(self.owner.velocity);

		ang = vectoangles(pos - self.origin);
		self.ideal_yaw = ang_y;
		
		diff1 = self.origin - pos;
		if(diff1*diff1 < 350*350)
		{
			self.approachtime = time+6;
			self.action = self.action | ACT_APPROACHING;
		}

		return pos;
	}
	
	ofs_z = self.maxs_z*0.6;
	
	if(self.ally)
	{
		center = self.ally.origin;
		roamrange = self.engagedist_far;
		ang = vectoangles(self.origin - self.ally.origin);
		ang_x = 0;	ang_z = 0;
	}
	else
	if(!self.enemy)
	{
		if(self.owner != self)
			center = self.owner.origin;
		else
			center = self.origin_base;
		
		if(self.behaviorflags & BF_FLIES)
			center_z = center_z + self.flightelevation;
		
		roamrange = random()*800;
		ang_y = (random()*360)-180;
	}
	else
	if(self.action & ACT_HARASS_ATTACK)
	{
		center = self.enemy.origin;
		roamrange = self.engagedist_far;
		ang = vectoangles(self.origin - self.enemy.origin);
		ang_x = 0;	ang_z = 0;
		ang_y += random()*60-30;
	}
	else
	if(self.action & ACT_HARASS_FLEE)
	{
		center = self.origin;
		roamrange = 1400;
	//	ang = vectoangles(self.origin - self.enemy.origin);
	//	ang_x = 0;	ang_z = 0;
		ang_y = random()*360;//90-450;	
	}
	else
	if(self.behaviorflags & BF_FLIES)
	{
		center = self.enemy.origin;
		center_z += self.flightelevation;
		roamrange = random()*800;
		ang_y = (random()*360)-180;	
	}
	else
	{
		center = self.enemy.origin;
		roamrange = 600+random()*200;
		ang = vectoangles(self.origin - self.enemy.origin);
		ang_x = 0;	ang_z = 0;
		r = random();
		if(r < 0.5)
			ang_y += 30;
		else
			ang_y -= 30;	
	}
	
	makevectors(ang);
	tracebox(center+ofs, self.mins*1.2, self.maxs*1.2, center+ofs+v_forward*roamrange, FALSE, self);
	
	pos = trace_endpos;
	pos -= ofs;

	return pos;
}

entity GetNearestPathPointInGroup(vector org, float pgid) =
{
	local entity e, closestpath;
	local vector dist, closestdist;
	
	e = list_pathchain;
	while(e)
	{
		dist = org - e.origin;
		if(e != self.prevpathpoint)
		if(e.pathgroupid == self.pathgroupid)
		if(closestdist == '0 0 0' || dist*dist < closestdist*closestdist)
		{
			closestpath = e;
			closestdist = dist;
		}
		
		e = e.pathchain;
	}
	
	if(!closestpath)
		closestpath = self.prevpathpoint;
	
	return closestpath;
}

.float lookforpositiontime;
.vector movetoposition;

void AI_ArriveAtNextPoint() =
{
	if(self.prevpathpoint != self.nextpathpoint)
		Func_oself(self.nextpathpoint, TriggerObjects_StageZero);

	self.prevpathpoint = self.nextpathpoint;			
	if(self.nextpathpoint.nextpathpoint)
		self.nextpathpoint = self.nextpathpoint.nextpathpoint;
}

.vector	lastflightlocation;
vector GetValidFlightPath(entity e, vector desiredlocation) =
{
	local vector directionvec, ang, desiredang;
	local float count, r, len, yawmod, distmin;

	tracebox(e.origin, e.mins, e.maxs, desiredlocation, FALSE, e);
	
	if(trace_fraction == 1)
		return desiredlocation;

	directionvec = desiredlocation - e.origin;
	len = vlen(directionvec);
	ang = vectoangles(directionvec);
	
	for(count = 1; count < 36; count++)
	{
		yawmod = count*5;
		r = random();
		
		if(r < 0.5)
			yawmod = yawmod*-1;
			
		desiredang_y = ang_y+yawmod;
		desiredang_x = 0;
		makevectors(desiredang);
		
		if(e.action & ACT_APPROACH)
			distmin = 0;
		else
			distmin = 200;
		
		desiredlocation = e.origin + v_forward*bound(distmin, len*0.5, 500);
		tracebox(e.origin+v_forward*-50, e.mins, e.maxs, desiredlocation, FALSE, e);
		
		if(trace_fraction == 1)
		{
			e.lastflightlocation = desiredlocation;
			return desiredlocation;
		}
	}

	return e.lastflightlocation;
}

void AI_Move() =
{
//	if(self.movetype == MOVETYPE_NONE)
	if(self.behaviorflags & BF_STATIONARY)
		return;

	if(self.tag_entity)
		return;

	if(self.groundentity.objclass == OBJ_TRAIN)
	if(self.groundentity.velocity != '0 0 0')
		return;
		
	local vector diff1, diff2, desiredlocation, ang, newvelocity, org;
	local float distancefromtarget, touchdist, inertiamultiple, OCCUPY, angdiff, moving, tagindex, canfaceally;
	local entity endcell;
	
	touchdist = CELL_MAXS_x*2;
	
	inertiamultiple = self.movementinertia;

	if(self.waittomovetime <= time)
	{
		if(self.yaw_speed_base)
		{
			if((self.behaviorflags & BF_INCREASESPEEDATSTAGETHREE) && self.health <= self.max_health*0.33)
				self.yaw_speed = self.yaw_speed_base*3;	
			else
			if((self.behaviorflags & BF_INCREASESPEEDATSTAGETWO) && self.health <= self.max_health*0.66)
				self.yaw_speed = self.yaw_speed_base*2;				
			else
				self.yaw_speed = self.yaw_speed_base;
		}
		
		if(!self.behaviorflags & BF_FLIES)
		if(self.origin != self.gridpos)
		{
		//	if(!self.behaviorflags & BF_FLIES)
		//		OCCUPY = TRUE;

			UnmarkGrid(self, TRUE, FALSE);
			MarkGrid(self, TRUE, FALSE, self.gridpos);
		}	
		
		if(self.action & ACT_DODGE)
		{
			diff1 = self.origin - self.dodgeorigin;
			if(self.dodgetime < time || diff1*diff1 <= touchdist*touchdist)
			{
				self.dodgetime = 0;
				self.action =  self.action - self.action & ACT_DODGE;
			}
		}
		
		if(self.action & ACT_DODGE)
			desiredlocation = self.dodgeorigin;
		else
		if((self.movement_behavior == MB_ROAM && (self.behaviorflags & BF_ROAM || (self.behaviorflags & BF_ROAM_NOTARGET && !self.enemy)))
		|| ((self.behaviorflags & BF_ROAM) && !(self.behaviorflags & BF_ROAM_NOTARGET) && self.enemy))
		{
			diff1 = self.origin - self.roamtargetdest;
			if(self.roamtargetdest == '0 0 0' || self.roamtime < time || diff1*diff1 <= touchdist*touchdist)
			{
				if(self.behaviorflags & BF_FLIES)
					self.roamtime = time + 1;
				else
					self.roamtime = time + 12 + random()*2;
					
				self.roamtargetdest = GetRoamDest();
			}
				
			desiredlocation = self.roamtargetdest;
		}
		else	
		if(self.enemy)
		{
			tagindex = self.(shootfrom_index[self.firingfrom]);	
			org = gettaginfo(self, tagindex);
			
			tracebox(org, '-16 -16 -16', '16 16 16', self.enemy.origin+'0 0 17', FALSE, self);
			if(trace_ent != self.enemy)
			{
				self.cantshootenemy = TRUE;
				desiredlocation = self.enemy.origin;
			}
			else
			{
				self.cantshootenemy = FALSE;
				distancefromtarget = vlen(self.enemy.origin - self.origin);
				if(distancefromtarget > self.engagedist_far)
					distancefromtarget = self.engagedist_far;
				else
				if(distancefromtarget < self.engagedist_near)
					distancefromtarget = self.engagedist_near;

				desiredlocation = self.enemy.origin + normalize(self.origin - self.enemy.origin)*distancefromtarget;			
			}

			if(self.behaviorflags & BF_FLIES)
				desiredlocation_z = self.enemy.origin_z + self.flightelevation;	
			
			if(self.movement_behavior == MB_PATROL && self.pathgroupid)
			{
				if(!self.nextpathpoint)
					self.nextpathpoint = GetNearestPathPointInGroup(self.origin, self.pathgroupid);
			
				if(self.nextpathpoint)
				{
					diff1 = self.origin - self.prevpathpoint.origin;
					diff2 = self.origin - self.nextpathpoint.origin;
			
					if(diff2*diff2 <= diff1*diff1
					|| !self.prevpathpoint)
						AI_ArriveAtNextPoint();
				}
			}
		}
		else
		if(self.movement_behavior == MB_PATROL && self.pathgroupid)
		{
			if(!self.nextpathpoint)
				self.nextpathpoint = GetNearestPathPointInGroup(self.origin, self.pathgroupid);

			diff1 = self.nextpathpoint.origin - self.origin;
			if(diff1*diff1 <= (touchdist*1.5)*(touchdist*1.5))
				AI_ArriveAtNextPoint();
			
			if(self.nextpathpoint)
				desiredlocation = self.nextpathpoint.origin;
			else
				desiredlocation = self.origin;
		}
		else	// return home
			desiredlocation = self.owner.origin_base;
			
		if(!(self.behaviorflags & BF_FLIES))
		{
			endcell = GetClosestCell(self.origin, desiredlocation, TRUE);	
			desiredlocation = endcell.origin;
		}
		
		diff1 = self.origin-desiredlocation;
		if(diff1*diff1 > touchdist*touchdist)
		{
			if(!(self.behaviorflags & BF_FLIES))
				SetUpCellPath(self.origin, endcell);
			
			if(!self.isblocked)
			{
				moving = TRUE;
				if(self.behaviorflags & BF_FLIES)
					desiredlocation = GetValidFlightPath(self, desiredlocation);
				else
					desiredlocation = GetFurthestAcessableCellPath();	
					
				ang = vectoangles(desiredlocation - self.origin);
			//	print(vtos(ang));print("\n");
			}
		}	
		else
			self.roamtime = 0;
	}
	
	if((self.behaviorflags & BF_STRAFEINCOMBAT) && self.ally)
		canfaceally = TRUE;
	
	if((self.behaviorflags & BF_STRAFEINCOMBAT) && self.enemy && !(self.action & ACT_APPROACH)
	&& ((self.weapon && self.weapon != WEP_REPAIR) || !canfaceally))
		self.facetarget = self.enemy;
	else
	if(canfaceally)
		self.facetarget = self.ally;	
	else
	{
		self.facetarget = world;
		if(self.behaviorflags & BF_FLIES)
			self.angles_x = ang_x;
		self.ideal_yaw = ang_y;
		ang = self.angles;		
	}
	
	if(moving)
	{
		ang_x = -ang_x;	
		makevectors(ang);
		local float mspeed;
		if(((self.movement_behavior == MB_PATROL && self.pathgroupid)
		|| self.roamtime > time)
		&& !self.enemy)
			mspeed = 30;
		else
		{
			if(self.behaviorflags & BF_INCREASESPEEDATSTAGETHREE && self.health <= self.max_health*0.33)
				mspeed = self.movespeed*3;			
			else		
			if(self.behaviorflags & BF_INCREASESPEEDATSTAGETWO && self.health <= self.max_health*0.66)
				mspeed = self.movespeed*2;
			else
				mspeed = self.movespeed;
		}
		
		newvelocity = v_forward*mspeed*10;
		
		if(!self.behaviorflags & BF_STRAFEINCOMBAT || (!self.enemy && !self.ally) || self.behaviorflags & BF_FLIES)
		{
			angdiff = AngleDifference(self.angles_y, self.ideal_yaw);
			if(self.behaviorflags & BF_FLIES)
				angdiff = angdiff*0.1;
			if(angdiff)
				newvelocity = newvelocity*bound(0.25, 1-angdiff/45, 1);	
		}				
	}		
	
	local float fallvel;
	fallvel = self.velocity_z;
	self.velocity = newvelocity + (self.velocity-newvelocity)*inertiamultiple;	

	if(!self.behaviorflags & BF_FLIES)
		self.velocity_z = fallvel;
}

void AI_Dodge(entity victim, entity attacker) =
{
	local float dir;

	makevectors(vectoangles(attacker.origin - victim.origin));
	
	if(random() < 0.5)
		dir = 1;
	else
		dir = -1;
	if(victim.dodgetime < time)	
	{
		victim.dodgeorigin = victim.origin + v_right*dir*500;//victim.maxs_x*3;
		victim.dodgetime = max(time+1, self.nextthink+1.5+(1-self.movespeed/100)*2.15);
	}
	victim.action = victim.action | ACT_DODGE;
}

void AI_Roam() =
{
	if(self.enemy)
	if(self.behaviorflags & BF_ROAM_ALTERNATE)
	{
		if(self.roamdata_z && self.roamdata_z < time)
		{
			if(self.behaviorflags & BF_ROAM_NOTARGET)
			{
				self.behaviorflags -= self.behaviorflags & BF_ROAM_NOTARGET;
				self.behaviorflags = self.behaviorflags | BF_ROAM;
				self.roamdata_z = time+self.roamdata_y;
			}
			else
			{
				self.behaviorflags -= self.behaviorflags & BF_ROAM;
				self.behaviorflags = self.behaviorflags | BF_ROAM_NOTARGET;	
				self.roamdata_z = time+self.roamdata_x;
			}
		}
		else
		if(!self.roamdata_z)
			self.roamdata_z = time+self.roamdata_x;
	}

	if(!self.movement_behavior == MB_ROAM)
		return;	
	
	if(self.behaviorflags & BF_ROAM || (self.behaviorflags & BF_ROAM_NOTARGET && !self.enemy))
		self.action = self.action | ACT_MOVE;	
}

float WaitingToThink() =
{
//	if(!activestartframe)
//		return TRUE;
		
//	if(numcells)
//		return TRUE;

	if(self.owner.teleporttouchtime > time)
	{
		self.think = AI_Think;
		self.nextthink = self.owner.teleporttouchtime;	

		return TRUE;
	}
	else
	if(self.owner.teleporttouchtime && self.owner.teleporttouchtime <= time)
	{
		self.owner.teleporttouchtime = 0;
		self.owner.movetype = self.owner.activemovetype;
		self.owner.solid = SOLID_SLIDEBOX;	
	}
	
	return FALSE;
}

float AI_Sleep() =
{
	local float activerange;
	local entity e, ai;
	local vector diff1;

	activerange = 3000;
		
	if(!activityhalted)
	{//return FALSE;
		if(self.movement_behavior == MB_PATROL
		|| (self.behaviorflags & BF_NOSLEEP)
		|| self.groundentity)
			return FALSE;

		if(self.tag_entity)
			ai = self.tag_entity;
		else
			ai = self;	
		
		e = list_playerchain;
		while(e)
		{
			diff1 = e.origin - ai.origin;
			if(diff1*diff1 < activerange*activerange)
				return FALSE;
			e = e.playerchain;
		}
	}
	
	if(!self.behaviorflags & BF_STATIONARY)
	{
		UnmarkGrid(self, TRUE, TRUE);
		RemoveUnusedCells(self, self.gridpos);
		self.mobile = FALSE;
		MobileEntChain_Remove(self);
		self.ideal_yaw = self.angles_y;
		self.velocity = '0 0 0';
		self.SendFlags = self.SendFlags | SFL_ORIGIN | SFL_ANGLES | SFL_ORIGIN_STOP | SFL_ANGLES_STOP;
	}
	self.think = SUB_Null;
	self.nextthink = 0;
	self.movetype = MOVETYPE_NONE;
	
	return TRUE;
}

float AI_IsDestructed() =
{
	local float destruct;

	if(!self.destructatstage)
		return FALSE;
		
	if(self.destructatstage == 3 && self.owner.health <= self.owner.max_health*0.33)
		destruct = TRUE;
	else
	if(self.destructatstage == 2 && self.owner.health <= self.owner.max_health*0.66)
		destruct = TRUE;

	if(destruct)
		Kill(self, self);
	
	return destruct;
}

void AI_Think() =
{
//	BindToWorld(self);

/*	if(!self.behaviorflags & BF_STATIONARY)
	if(IsBaseEnt(self))	
	if(CanAssignToSector(self))
	if(!adminmodeactive)
		UpdateSectorEnt(self);*/
		
	RemoveExpiredEffects();		
		
	if(AI_IsDestructed())
		return;
	
	if(AI_Sleep())
		return;

	local float thinkdelay, approaching;
	thinkdelay = 0.2;

	self.nextthink = time + thinkdelay;
	
	if(pauseai)
	{
		self.velocity = '0 0 0';
		AI_Idle();
		return;
	}

	if(WaitingToThink())
	{
		AI_Idle();
		return;
	}	

	AI_AssessThreats();

	if(self.stuntime > time || (IsAttachedAIClass(self.npcclass) && self.owner.stuntime > time))
	{
		self.velocity_x = self.velocity_x*self.movementinertia;
		self.velocity_y = self.velocity_y*self.movementinertia;
		if(self.behaviorflags & BF_FLIES)
		if(!self.isdead)
			self.velocity_z = self.velocity_z*self.movementinertia;
		self.ideal_yaw = self.angles_y;
		AI_Idle();
		return;
	}

	if(self.action & ACT_DOCK)
	{
		AI_Dock();
		return;
	}

	if(!self.action)
		AI_Idle();

	if(self.action & ACT_THREATENED)
	if(self.reactiontime <= time)
		AI_ReactToThreat();

	if(self.action & ACT_FIGHT)
		AI_Fight();

	AI_Roam();

	if(self.action & ACT_APPROACHING)
		approaching = AI_Approach();	

	if(!approaching)
	if(self.action & ACT_MOVE || self.movement_behavior == MB_PATROL)
		AI_Move(); 	
	else
	{
		self.velocity_x = self.velocity_x*self.movementinertia;	
		self.velocity_y = self.velocity_y*self.movementinertia;	
		if(self.behaviorflags & BF_FLIES)
		if(!self.isdead)
			self.velocity_z = self.velocity_z*self.movementinertia;		
	}	
}

void WakeAI(entity e) =
{
	local entity c;

	e.mobile = TRUE;
	MobileEntChain_Add(e);	
	e.think = AI_Think;
	e.nextthink = time + 0.2*random()*0.1;
	e.movetype = e.activemovetype;
	
	for(c = e.list_childchain; c; c = c.childchain)
	{
		if(c.npcclass == NPC_TURRET)
			WakeAI(c);
	}
}

void AI_Wake() =
{
	local entity e, ai, c;
	local float activerange;
	local vector diff1;
	
	activerange = 3000;

	e = findradius(self.origin, activerange);//list_aichain;//
	while(e)
	{
		if(e.objclass == OBJ_NPC)
		if(!e.tag_entity)
		{
		//	if(e.tag_entity)
		//		ai = e.tag_entity;
		//	else
				ai = e;
	//	te_spark(ai.origin, '0 0 100000', 10000);
			if(!((ai.triggerentid || ai.istarget)&& !ai.istoggled))
			if(!(ai.health <= 0) && !(ai.isdead || ai.explodeuntiltime || (ai.behaviorflags & BF_NOSLEEP)))
		/*	if(vlen(ai.origin - self.gridpos) > activerange && ai.nextthink)
			{//print("deactivating\n");
				ai.ideal_yaw = 0;
				ai.velocity = '0 0 0';
				ai.think = SUB_Null;
				ai.nextthink = 0;
				ai.movetype = MOVETYPE_NONE;
			}
			else*/
			if(!ai.nextthink)
			{
				diff1 = ai.origin - self.origin;
				if(diff1*diff1 <= activerange*activerange)
					WakeAI(ai);
			}
			else
			if(ai.list_childchain)
			if(!ai.list_childchain.nextthink)
			{
				diff1 = ai.origin - self.origin;
				if(diff1*diff1 <= activerange*activerange)
				{
					for(c = ai.list_childchain; c; c = c.childchain)
					{
						if(c.npcclass == NPC_TURRET)
							WakeAI(c);
					}
				}
			}
		}
		
		e = e.chain;//aichain;
	}
}

void RemoveNPC() =
{
	self.mobile = FALSE;
	RemoveTagEnts(self);
	RemoveOwnedEnts(self);
//	UpdateMobileEntChain();	
}

float thinkorder;
void StartAI() =
{
//	SetID(self);
//	self.enemy = world; // unnecessary
	
//	if(!self.part_cannon)
//		self.part_cannon = self;

/*	if(!self.owner)
	{
		SetOwner(self, self);//self.owner = self;
		SetParent(self, self);
	}*/
	
//	self.SendEntity = SendNPC;
//	self.updatetime = time+random()*SV_UPDATEDELAY;
	
	if(self.isdead)
		return;
	
	if(!(self.flags & FL_REVIVE))
	if(self.owner.objclass == OBJ_NPC)
	if(self.owner.triggerentid || self.owner.istarget)
	if(!self.owner.istoggled)
	{
		MakeObjectInvisibleToClients(self);
		self.solid = SOLID_NOT;
		self.godmode = TRUE;
		self.TriggerFunc = TriggerEnemy;
		return;
	}

	if(self.movement_behavior == MB_PATROL
	|| (self.behaviorflags & BF_NOSLEEP)
	|| self.groundentity)// || (self.flags & FL_REVIVE))
	{	
/*	//	if(!self.behaviorflags & BF_STATIONARY)
	//	{
			self.mobile = TRUE;
			MobileEntChain_Add(self);	
	//	}
		
		self.think = AI_Think;
		self.movetype = self.activemovetype;
//	if(self.behaviorflags & BF_FLIES)
//		AI_Think();
//	else
		self.nextthink = self.updatetime = time+thinkorder;//random()*0.5;//SV_UPDATEDELAY;

		thinkorder += 0.01;
		
		if(thinkorder >= 0.2)//SV_UPDATEDELAY)
			thinkorder = 0;*/
			WakeAI(self);
	}
	else
	{ // initialize sleep regardless of nearby players
		self.think = SUB_Null;
		self.nextthink = 0;		
	}
	
	self.flags -= (self.flags & FL_REVIVE);		
	
	setorigin(self, self.origin + '0 0 4');
}