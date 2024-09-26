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
void SH_RemoveEnt(entity e) =
{
	sound(e, CHAN_BODY, "sounds/null.wav", 1, ATTN_NORM);
	sound(e, CHAN_VOICE, "sounds/null.wav", 1, ATTN_NORM);
	
	e.netname = freezone(e.netname);
	
	ShotChain_Remove(e);
	
	e.shakecamera = FALSE;
	CameraShakeChain_Remove(e);	
	
//	e.showonradar = FALSE;
	RadarEntChain_Remove(e);
	
	OwnerlessChain_Remove(e);	
	
	HasAvelocityChain_Remove(e);

	CanShootChain_Remove(e);

	HittableChain_Remove(e);
	
	MenuChain_Remove(e);
	
	ControlEntChain_Remove(e);
	
	MissingPathConnectionsChain_Remove(e);	
//	DeletedPathChain_Remove(e);
	
	ParticleEmitterChain_Remove(e);
	
	e.entid = 0;
	e.id = 0;
	e.pathgroupid = 0;
	
	e.particleemittereffect = freezone(e.particleemittereffect);
	e.ambientsoundeffect = freezone(e.ambientsoundeffect);
	e.targetname = freezone(e.targetname);
	
	RemoveTagEnts(e);
	RemoveOwnedEnts(e);	
	
	RemoveEnt(e);
	
	if(e.class == CLASS_CONTROLENT)
	if(e.owner.controlent)
		e.owner.controlent = world;
	
	if(e.isshared)
	{
		e.drawmask = 0;
		e.solid = 0;
		e.mobile = 0;
		e.tag_entity = world;
		e.tag_index = 0;
		SetOwner(e, world);//e.owner = world;
		SetParent(e, world);
	}
	else
		remove(e);	
}

void UpdateOwners() =
{
	local entity e, nexte;
	
	e = list_ownerlesschain;
	while(e)
	{
		nexte = e.ownerlesschain;	
	
		if(e.lostownerid == self.id)	
		{
			if(e.FoundOwnerFunc && e.FoundOwnerFunc != SUB_Null)
				e.FoundOwnerFunc(e, self);
			else
			{
				e.lostownerid = FALSE;
				SetOwner(e, self);
				SetParent(e, self);
				e.colormod = self.colormod;
				e.alpha = self.alpha;

			//	if(e.tag_index)
				if(e.class != CLASS_SHOT)
				if(e.objclass == OBJ_FLAG)
					AttachFollow(e, self, e.tag_index);
				else
					Attach(e, self, e.tag_index);
					
				e.drawmask = MASK_NORMAL;
			}
			
			e.FoundOwnerFunc = SUB_Null;
			OwnerlessChain_Remove(e);
		}
	
		e = nexte;
	}
}

void UpdateAvelocityEnts() =
{
	local entity e;

	e = list_hasavelocitychain;
	while(e)
	{
		e.angles += e.avelocity*frametime;
		e = e.hasavelocitychain;
	}
}

void SetAvelocity(entity e, vector avel) =
{
//	e.hasavelocity = true;
	e.avelocity = avel;
	HasAvelocityChain_Add(e);
//	e.hasavelocitychain = list_hasavelocitychain;
//	list_hasavelocitychain = e;
}

.float	disttomovetarg;
void MobileEntPrediction() =
{
	local float updatetime, updateframetime, sv_rollangle, sv_divspeed, bounced, predownvel, gravity, lastdisttotarg, disttotarg;
	local entity e, nexte;
	local vector orgofs, ang, diff, diff2;

	sv_rollangle = cvar("sv_rollangle") * 4;
	sv_divspeed = 1 / cvar("sv_rollspeed");
	gravity = cvar("sv_gravity");
	
	updatetime = (1/SV_UPDATEDELAY);
	updateframetime = min(frametime, SV_UPDATEDELAY);
	
	e = list_mobileentchain;
	while(e)
	{
		bounced = false;
	
		if(e.movetype == MOVETYPE_BOUNCE)
		if(e.velocity != '0 0 0')
		{
			predownvel = e.velocity_z;
			if(e.velocity_z > e.density*gravity*-1)
				e.velocity_z = e.velocity_z - e.density*gravity*frametime;
			
			tracebox(e.origin, e.mins, e.maxs, e.origin+e.velocity*frametime, false, e);
			if(trace_fraction < 1)
			if(e.bouncetime < time)
			{
				e.avelocity = e.avelocity *0.9;			
			
				if(trace_plane_normal_x)
				{
					e.velocity_x = e.velocity_x*-0.5;
					e.avelocity_x = e.avelocity_x*-1;
				}
					
				if(trace_plane_normal_y)
				{
					e.velocity_y = e.velocity_y*-0.5;
					e.avelocity_z = e.avelocity_z*-1;
				}
				
				if(e.velocity_z < 0)
				{
					e.velocity_z = e.velocity_z*-0.5;
					e.avelocity_y = e.avelocity_y*-1;
					
					if(e.velocity_z < 1)
					{
						e.velocity = '0 0 0';
						e.avelocity = '0 0 0';
					}					
				}

				if(e.splattertime < time)
				if(IsAssignedFunction(e.splatterfunc))
				{
					Func_oself(e, e.splatterfunc);
					e.splattertime = time+0.2;
				}
				
				e.bouncetime = time+0.1;
				bounced = true;
			}
			else
			{
				e.velocity = '0 0 0';
				e.avelocity = '0 0 0';
				bounced = true;
			}
		}
		else
		{
			nexte = e.mobileentchain;
			MobileEntChain_Remove(e);
			e = nexte;
			continue;
		}
	
		if(!bounced)
		{
			if(e.velocity == '0 0 0' && e.isshared)
			{
				orgofs = (e.targetorigin - e.origin)*frametime;
			
				diff = e.origin - e.targetorigin;
			//	diff2 = e.origin - orgofs;

				lastdisttotarg = e.disttomovetarg;
				disttotarg = vlen(diff);
				
				if(e.disttomovetarg)
				if(disttotarg > lastdisttotarg)
				{
					disttotarg = 0;
					orgofs = e.targetorigin - e.origin;
				}
			//	else
			//	if(diff2*diff2 > diff*diff)
			//		orgofs = (e.targetorigin - e.origin);
					
				e.disttomovetarg = disttotarg;
			}
			else
			{
				e.disttomovetarg = 0;
				orgofs = e.velocity*frametime;
			}
					
			if(orgofs != '0 0 0')
				setorigin(e, e.origin + orgofs);
		}

		if(e.isshared)
		if(frametime > SV_UPDATEDELAY)
		{
			e.angles_x = e.newpitch;
			e.angles_y = e.newyaw;
			e.angles_z = e.newroll;
		}
		else
		{
			e.angles_x = NormalizeAngle(e.angles_x + NormalizeAngle(e.newpitch - e.oldpitch)*updatetime*frametime);
			if(e == player)
				e.angles_y = input_angles_y;
			else
				e.angles_y = NormalizeAngle(e.angles_y + NormalizeAngle(e.newyaw - e.oldyaw)*updatetime*frametime);
			e.angles_z = NormalizeAngle(e.angles_z + NormalizeAngle(e.newroll - e.oldroll)*updatetime*frametime);
		}
		
		if(e.class == CLASS_PLAYER || e.objclass == OBJ_NPC)
		if(!e.npcclass == NPC_MICROFLYER)
		if(!e.npcclass == NPC_CARRIERTANK)
		if(!e.npcclass == NPC_DESTROYERTANK)
		{
			local vector angvec, vel;
			local float vel_len;
			
		//	sv_rollangle = cvar("sv_rollangle") * 4;
		//	sv_divspeed = 1 / cvar("sv_rollspeed");		
			
			vel = e.velocity;
			vel_z = 0;
			angvec = vectoangles(vel);
			angvec_y -= e.angles_y;
			makevectors(angvec);
			vel_len = vlen(vel);
		
			e.oldpitch = e.angles_x;
			e.oldroll = e.angles_z;
		
			e.newpitch = bound(-1, vel_len * v_forward_x * sv_divspeed, 1) * sv_rollangle*-1;
			e.newroll = bound(-1, vel_len * v_right_x * sv_divspeed, 1) * sv_rollangle*-1;
			
		//	makevectors(e.angles);
		//	e.angles_x = bound(-1, e.velocity * v_forward * cl_divspeed, 1) * cl_rollangle*-1;
		//	e.angles_z = bound(-1, e.velocity * v_right * cl_divspeed, 1) * cl_rollangle;			
		}		
		
/*		if(e == player)
		if(reticle_mirv)
		{
			ang_y = player.angles_y;
			makevectors(ang);
			setorigin(reticle_mirv, player.origin+v_forward*375+'0 0 800');		
			reticle_mirv.angles_y = player.angles_y;
		}*/
		
		if(effectdrawtime <= time)
		if(IsAssignedFunction(e.trailfunc))
			Func_oself(e, e.trailfunc);
		
		e = e.mobileentchain;
	}
}

void GetOrientationData(float isnew, float sendflags) =
{
	local float vel;
	
	if(sendflags & SFL_ORIGIN)
	{
		local vector org;
	
		org_x = ReadCoord();
		org_y = ReadCoord();
		org_z = ReadCoord();

		vel = ReadCoord();

		if(self.mobile
		&& !(self.class == CLASS_OBJECT && (sendflags & SFL_BASEDATA || sendflags & SFL_RESET)) )// || self.immobiletime_x >= time || self.immobiletime_x == -1)) )
		{
	//		self.immobiletime_x = 0;

			if(self.oldorigin == '0 0 0' || sendflags & SFL_TELEPORT)
			{
				self.oldorigin = org;
				setorigin(self, org);
			}
			else
			{
				self.oldorigin = self.origin;
				self.velocity = normalize(org - self.origin)*vel;		
			}
		
			self.targetorigin = org;
		}
		else
		{
			if(self.mobile)
			{
			//	if(!self.immobiletime_x || self.immobiletime_x == -1)
			//	{
				//	self.immobiletime_x = time+SV_UPDATEDELAY*2;
					setorigin(self, org);
					self.oldorigin = org;
					self.targetorigin = org;
					self.velocity = '0 0 0';	
			//	}
			}
			else
				setorigin(self, org);
		}
	}
	
	if(sendflags & SFL_ANGLES)// && !self.modelflags & MF_ROTATE)
	{
		local float pitch, yaw;
		local vector ang;
		
		if(self.class == CLASS_SHOT || self.npcclass == NPC_MICROFLYER)
		{
			pitch = ReadCoord();	
		//	if(!self.mobile)
		//		self.angles_x = pitch*-1;
		//	else
				self.angles_x = pitch;
		}	
		
		yaw = ReadCoord();

	//	if(self.class != CLASS_PLAYER)
	//		print(ftos(yaw));print("\n");
		if(self.mobile
 		&& !(self.class == CLASS_OBJECT && 
			(
				(sendflags & SFL_BASEDATA)
				|| (sendflags & SFL_RESET))
			//	|| self.immobiletime_y >= time
			//	|| self.immobiletime_y == -1)
				|| (self.class == CLASS_SHOT && isnew)
			)
		)
		{
			if(sendflags & SFL_ANGLES_STOP || sendflags & SFL_TELEPORT)
			{
				if(self.class == CLASS_SHOT)
					self.oldpitch = pitch;
				self.oldyaw = yaw;
				
				if(isnew || sendflags & SFL_TELEPORT)
					self.angles_y = yaw;
			}
			else
			{
				if(self.class == CLASS_SHOT)
					self.oldpitch = self.angles_x;
				self.oldyaw = self.angles_y;
			}
			
			if(self.class == CLASS_SHOT)
				self.newpitch = pitch;

			self.newyaw = yaw; 
		}
		else
		{
			if(self.mobile)
			{
		//		if(!self.immobiletime_y || self.immobiletime_y == -1)
		//		{
				//	self.immobiletime_y = time+SV_UPDATEDELAY*2;
					self.angles_y = yaw;
					self.newyaw = yaw;
					self.oldyaw = yaw;
		//		}
			}
			else		
			{
				self.angles_y = yaw;
				ang = self.angles;
				ang_x = ang_x*-1;

				makevectors(ang);
				self.oldvelocity = self.velocity;
				self.velocity = v_forward*vel;
			}
		}
	}
	
	if(self.class == CLASS_PLAYER || self.class == CLASS_OBJECT)
	{
		if(sendflags & SFL_ORIGIN_STOP)
		{
			if(org == '0 0 0')
				org = self.origin;
			self.oldorigin = self.origin;
			self.targetorigin = org;
			self.velocity = '0 0 0';	
		}
		
		if(sendflags & SFL_ANGLES_STOP)
		{
			if(!yaw)
				yaw = self.angles_y;
			self.newyaw = yaw;
			self.oldyaw = yaw;	
		}
	}
	
//	self.oldupdatetime = time;	
}

/*void GetOrientationDataOLD(float isnew, float sendflags) =
{
	local float vel;
		
	self.oldupdatetime = self.newupdatetime;
	self.newupdatetime = time;

	vel = vlen(self.velocity);
	
	if(sendflags & SFL_ORIGIN)
	{
		local vector org;
	
		org_x = ReadCoord();
		org_y = ReadCoord();
		org_z = ReadCoord();

		vel = ReadLong();
		
		if(self.mobile)
		{
			if(self.origin == '0 0 0')
				setorigin(self, org);
		
			if(!sendflags & SFL_ORIGIN_STOP)
				self.oldvelocity = self.newvelocity;
			
			if(!isnew)
				self.newvelocity = normalize(org - self.neworigin)*vel;		

			if( sendflags & SFL_ORIGIN_STOP)
			{
				self.velocity = self.newvelocity = self.oldvelocity = '0 0 0';
				self.origin = self.oldorigin = org;
				self.lastorgofs = '0 0 0';
			}
			else
				self.oldorigin = self.origin;

		//	if(vlen(org - self.oldorigin) > (vlen(self.newvelocity)*2)*SV_UPDATEDELAY) // PACKETLOSS HACK
		//		self.origin = self.oldorigin = org;
			
			self.neworigin = org;
		}
		else
			setorigin(self, org);

	}
	
	if(sendflags & SFL_ANGLES)
	{
		local float pitch, yaw;
		
		if(self.class == CLASS_SHOT || self.npcclass == NPC_MICROFLYER)
		{
			pitch = ReadCoord();	
			self.angles_x = pitch;
		}	
		
		yaw = ReadCoord();
		
		if(self.mobile)
		{
			if(sendflags & SFL_ANGLES_STOP)
			{
				if(self.class == CLASS_SHOT)
					self.oldpitch = pitch;
				self.oldyaw = yaw;
			}
			else
			{
				if(self.class == CLASS_SHOT)
					self.oldpitch = self.angles_x;
				self.oldyaw = self.angles_y;
			}
			
			if(time - self.oldupdatetime > 0.08)
			{
				if(self.class == CLASS_SHOT)
					self.angles_x = self.oldpitch = pitch;
				self.angles_y = self.oldyaw = yaw;
			}
			
			if(self.class == CLASS_SHOT)
				self.newpitch = pitch;

			self.newyaw = yaw; 
		}
		else
			self.angles_y = yaw;
	}
	
	if(!self.mobile)
	{
		makevectors(self.angles);
		self.velocity = v_forward*vel;
	}
}*/


void SetMapObject(entity e) =
{
	e.ismapobject = true;
}

void PortalThink() =
{
	local string soundname;

	if(self.istoggled)
		return;

	PlaySoundLoop(self, self, CHAN_BODY, "sounds/enemies/portal/ss_portal_idle.wav", PortalThink);
}

void InitPortal(entity obj) =
{
	if(!obj.istoggled)
	{
		if(obj.AnimFunc != portal_open)
			obj.AnimFunc = portal_idle_opened;
			
		obj.Anim_Default = portal_idle_opened;
	}
	else
	{
		if(obj.AnimFunc != portal_close)
			obj.AnimFunc = portal_idle_closed;
	
		obj.Anim_Default = portal_idle_closed;
	}
//	obj.showonradar = true;
	obj.blipsize = 5;
//	obj.shieldscale = 2.5;
//	UpdateRadarEntChain();
	RadarEntChain_Add(obj);
	
	obj.think = PortalThink;
	obj.nextthink = time;
}

void ForceFieldThink() =
{
	if(self.istoggled)
		return;

	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_forcefield_hum.wav", ForceFieldThink);
}

void TerminalHackThink() =
{
//	if(self.AnimFunc != terminal_close && self.AnimFunc != terminal_operating)
//		return;

	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_terminal_hacking.wav", TerminalHackThink);
}

void SpawnTerminalHackSoundEnt(entity e) =
{
	local entity h;
	h = spawn();
	h.class = CLASS_SOUND;
	SetOwner(h, e);
	SetParent(h, e);
	setorigin(h, e.origin+'0 0 64');
	h.think = TerminalHackThink;
	h.nextthink = time;
}

void TerminalThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_terminal_hum.wav", TerminalThink);		}

void PylonHumThink() =	{	PlaySoundLoop(self, self.owner, CHAN_VOICE, "sounds/equipment/ss_pylon_hum.wav", PylonHumThink);	}

void SpawnPylonHumSoundEnt(entity e) =
{
	local entity h;
	h = spawn();
	h.class = CLASS_SOUND;
	SetOwner(h, e);
	SetParent(h, e);
	h.think = PylonHumThink;
	h.nextthink = time;
}

void PylonThink() =
{
	if(self.istoggled)
		return;
		
	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_forcefield_hum.wav", PylonThink);
}

void ObeliskThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_obelisk_loop.wav", ObeliskThink);		}

void IncineratorThink() =
{
	if(self.istoggled)
		return;	

	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_incinerator_loop.wav", IncineratorThink);
}

void EvaporatorOperatingThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_evaporator_operating.wav", EvaporatorOperatingThink);	}

void EvaporatorThink() =
{
	if(self.istoggled)
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_evaporator_idle.wav", EvaporatorThink);
	else
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_evaporator_start_withloop.wav", EvaporatorOperatingThink);
}

void BigPumpOperatingThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_bigpump_operating.wav", BigPumpOperatingThink);	}

void BigPumpThink() =
{
	if(self.istoggled)
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_bigpump_idle.wav", BigPumpThink);
	else
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_bigpump_start_withloop.wav", BigPumpOperatingThink);
}

void RefineryOperatingThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_refinery_operating.wav", RefineryOperatingThink);	}

void RefineryThink() =
{
	if(self.istoggled)
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_refinery_idle.wav", RefineryThink);
	else
		PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_refinery_start_withloop.wav", RefineryOperatingThink);
}

void CorruptFusionCoreThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_corr_fusioncore_hum.wav", CorruptFusionCoreThink);		}

void FusionCoreRackThink() =	{	PlaySoundLoop(self, self, CHAN_BODY, "sounds/equipment/ss_fusioncorerack_hum.wav", FusionCoreRackThink);		}

void InitObject(entity obj) =
{
	if(obj.isdead)
		return;
	
	switch(obj.objclass)
	{
		case OBJ_TERMINAL:				obj.think = TerminalThink;	obj.nextthink = time;	break;
		case OBJ_FUSIONCORERACK:		obj.think = FusionCoreRackThink;	obj.nextthink = time;	break;
		case OBJ_CORRUPTFUSIONCORE:		obj.think = CorruptFusionCoreThink; obj.nextthink = time;	break;
		case OBJ_FORCEFIELD:		if(!obj.istoggled)	{	obj.think = ForceFieldThink;	obj.nextthink = time;	}	break;
		case OBJ_STRUCTURE:
			if(obj.variant == STRUCTURE_PYLON)
			{	SpawnPylonHumSoundEnt(obj);		obj.think = PylonThink;	obj.nextthink = time;		}
			else
			if(obj.variant == STRUCTURE_OBELISK)
			{	obj.think = ObeliskThink; obj.nextthink = time;		}
			else
			if(obj.variant == STRUCTURE_INCINERATOR)
			{	obj.think = IncineratorThink; obj.nextthink = time;		}	
			else
			if(obj.variant == STRUCTURE_EVAPORATOR)
			{	obj.think = EvaporatorThink; obj.nextthink = time;		}
			else
			if(obj.variant == STRUCTURE_GASPUMP)
			{	obj.think = BigPumpThink; obj.nextthink = time;		}
			else
			if(obj.variant == STRUCTURE_REFINERY)
			{	obj.think = RefineryThink; obj.nextthink = time;		}			
		break;
		case OBJ_PORTAL:			InitPortal(obj);					break;	
		default:														break;
	}
}

void AddNewMapObject(entity obj) =
{
	local entity e, nexte;

	if(newmapobjecttime < time)
	{
		e = list_newmapobjectchain;
		while(e)
		{
			nexte = e.newmapobjectchain;
			e.isnewobject = false;
			NewMapObjectChain_Remove(e);
			e = nexte;
		}
	}

	obj.isnewobject = true;
	newmapobjecttime = time+3;
	NewMapObjectChain_Add(obj);
}

void ToggleObject(entity obj) =
{
	local string soundname;

	if(obj.istoggled)	
	{
		sound(obj, CHAN_BODY, "sounds/null.wav", 1, ATTN_NORM);
		switch(obj.objclass)
		{
			case OBJ_PORTAL:		
				obj.AnimFunc = portal_close;	
				obj.Anim_Default = portal_idle_closed;
				soundname = "sounds/enemies/portal/ss_portal_activate.wav";
				break;
			case OBJ_PRESSUREPLATE:							soundname = "sounds/equipment/ss_pressurepad_push.wav";		break;
			case OBJ_FORCEFIELD:	AddNewMapObject(obj);	soundname = "sounds/equipment/ss_forcefield_open.wav";		break;
			case OBJ_STRUCTURE:
				if(obj.variant == STRUCTURE_PYLON)			soundname = "sounds/equipment/ss_forcefield_open.wav";
				if(obj.variant == STRUCTURE_INCINERATOR)	soundname = "sounds/equipment/ss_incinerator_deactivate.wav";
				if(obj.variant == STRUCTURE_EVAPORATOR)		soundname = "sounds/equipment/ss_evaporator_deactivate.wav";
				if(obj.variant == STRUCTURE_GASPUMP)		soundname = "sounds/equipment/ss_bigpump_deactivate.wav";
				if(obj.variant == STRUCTURE_REFINERY)		soundname = "sounds/equipment/ss_refinery_deactivate.wav";
				break;
		}	
	}
	else
	{
		switch(obj.objclass)
		{
			case OBJ_PORTAL:
				obj.AnimFunc = portal_open;
				obj.Anim_Default = portal_idle_opened;
				soundname = "sounds/enemies/portal/ss_portal_activate.wav";
				break;		
			case OBJ_FORCEFIELD:	AddNewMapObject(obj);	soundname = "sounds/equipment/ss_forcefield_close.wav";		break;
			case OBJ_PRESSUREPLATE:							soundname = "sounds/equipment/ss_pressurepad_push.wav";		break;
			case OBJ_STRUCTURE:
				if(obj.variant == STRUCTURE_PYLON)			soundname = "sounds/equipment/ss_forcefield_close.wav";
				if(obj.variant == STRUCTURE_INCINERATOR)	soundname = "sounds/equipment/ss_incinerator_activate.wav";
				break;
		}
	}
	
	if(soundname)
		pointsound(obj.origin, soundname, 1, ATTN_NORM);
}

void RemoveCell(entity e) =
{
	viewingnavigationcells = false;
	SH_RemoveEnt(e);
}

.float	filloccupancy;
void UpdateCell(float isnew) =
{
	viewingnavigationcells = true;

	local vector org;
	local float cell_id, celloccupancy;
	
	cell_id = ReadLong();
	
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();
	
//	for(count = 0; count < 4; count++)
//		self.(cellconnection_id[count]) = ReadLong();
	
	celloccupancy = ReadCoord();
	
	if(isnew)
	{
		self.class = CLASS_CELL;
		self.id = cell_id;
		setorigin(self, org);
		SetAndPrecacheModel(self, "models/objects/nav_cell.dpm");
		self.alpha = 0.1;
		self.solid = 5;
		setsize(self, CELL_MINS, CELL_MAXS);
		self.drawmask = MASK_NORMAL;
		self.RemoveFunc = RemoveCell;
		self.filloccupancy = celloccupancy;
	}

	self.filloccupancy = celloccupancy;	
}

void SortPlayerListByScores() =
{
	local entity e, c, templist_playerchain;
	
	templist_playerchain = list_playerchain;
	for(e = list_playerchain; e; e = e.playerchain)
		e.chain = e.playerchain;
	
	for(e = templist_playerchain; e; e = e.chain)
	{
		for(c = list_playerchain; c; c = c.playerchain)
		{
			if(c == e)
				continue;
		
			if(BeatsScore(e, c, "", true))
			{
				if(c == list_playerchain)
				{
					list_playerchain = e;
					
					e.playerchain_prev.playerchain = e.playerchain;
					if(e.playerchain)
						e.playerchain.playerchain_prev = e.playerchain_prev;					

					e.playerchain_prev = world;						
					e.playerchain = c;
					c.playerchain_prev = e;
				}
			
				break;
			}
			
			// close gap
			if(e == list_playerchain)
			{
				list_playerchain = c;
				c.playerchain_prev = world;
			}
			else
			{
				e.playerchain_prev.playerchain = e.playerchain;
				if(e.playerchain)
					e.playerchain.playerchain_prev = e.playerchain_prev;
			}
			
			// insert into new position
			if(c.playerchain)
				c.playerchain.playerchain_prev = e;
			e.playerchain = c.playerchain;
			
			c.playerchain = e;
			e.playerchain_prev = c;
		}
	}
}

void ReadScoreStat(float STAT, .float s_field, float s_flags) =
{
	local float FLAG;
	FLAG = GetScoreFlag(STAT);
	if(s_flags & FLAG)	
	{
		self.s_field = ReadLong();
		
		if(STAT == SCORESTAT_ACCURACY)
			self.s_field = self.s_field*0.01;
	}
}

void ReadScores(float sendflags) =
{
	local float scoreflags;

//	if((sendflags & SFL_SCORE) || (sendflags & SFL_SCORE_ACCURACY))
//		self.accuracy = ReadShort()*0.1;

	if(sendflags & SFL_PING)
		self.ping = ReadLong();

	if(!(sendflags & SFL_SCORE))
		return;
		
	scoreflags = ReadLong();

	ReadScoreStat(SCORESTAT_SCOREPLACING,	scoreplacing,	scoreflags);
	ReadScoreStat(SCORESTAT_SCORE,			points,			scoreflags);
	ReadScoreStat(SCORESTAT_CAPTURES,		captures,		scoreflags);
	ReadScoreStat(SCORESTAT_RETURNS,		returns,		scoreflags);
	ReadScoreStat(SCORESTAT_FRAGS_PLAYER,	frags,			scoreflags);
	ReadScoreStat(SCORESTAT_FRAGS_AI,		frags_npc,		scoreflags);
	ReadScoreStat(SCORESTAT_FRAGS_OTHER,	frags_other,	scoreflags);
	ReadScoreStat(SCORESTAT_DEATHS,			deaths,			scoreflags);
	ReadScoreStat(SCORESTAT_SUICIDES,		suicides,		scoreflags);	
	ReadScoreStat(SCORESTAT_ACCURACY,		accuracy,		scoreflags);
	ReadScoreStat(SCORESTAT_DAMAGE_DEALT,	damagedealt,	scoreflags);		
		
	SortPlayerListByScores();
}

void ReadEventFlags(float sendflags) =
{
	local float r, vars, animnum, soundnum, t_lastanimflag, t_lastsoundflag, ATTN;
	local string soundname, soundname2;
	
	if(sendflags & SFL_ANIMATE)
	{
		animnum = ReadLong();
		
		t_lastanimflag = self.lastanimflag;
		self.lastanimflag = animnum;
		
		if(animnum != t_lastanimflag)
		{
			animnum = floor(animnum/2);	
			switch(animnum)
			{
				case ANIM_PLAYER_MINIGUNS:		shoot_miniguns();		break;
				case ANIM_PLAYER_MISSILES:		shoot_missiles();		break;
			
				case ANIM_DESTROYER_SHOOT1:		self.AnimFunc = destroyer_tank_shoot1;		break;
				case ANIM_DESTROYER_SHOOT2:		self.AnimFunc = destroyer_tank_shoot2;		break;
				
				case ANIM_TERMINAL_OPEN:
					self.AnimFunc = terminal_open;
					SpawnTerminalHackSoundEnt(self);
					soundname = "sounds/equipment/ss_terminal_activate.wav";
					break;
					
				case ANIM_TERMINAL_CLOSE:
					self.AnimFunc = terminal_close;	
					SilenceObjectSounds(self, true);
					soundname = "sounds/equipment/ss_terminal_deactivate.wav";	
					break;				
			}
		}
	}
	
	if(sendflags & SFL_SOUND)
	{
		soundnum = ReadLong();
		
		t_lastsoundflag = self.lastsoundflag;
		self.lastsoundflag = soundnum;
		ATTN = ATTN_NORM;
		
		if(soundnum != t_lastsoundflag)
		{
			soundnum = floor(soundnum/2);
			switch(soundnum)
			{
			
				case SOUND_MINIGUN_PLAYER_FIRE:		soundname = "sounds/weapons/miniguns/ss_ship_gun";			vars = 4;	break;
				case SOUND_FLACKGUN_PLAYER_FIRE:	soundname = "sounds/weapons/flack/ss_flak_";				vars = 4;	break;
				case SOUND_MINIGUN_HEAVY_FIRE:		soundname = "sounds/enemies/heavy_tank/ss_heavytank_gun";	vars = 4;	break;
			
				case SOUND_PLAYER_LAND:				soundname = "sounds/player/ss_ship_land.wav";					break;
				case SOUND_MINIGUN_PLAYER_STOP:		soundname = "sounds/weapons/miniguns/ss_ship_gun_rel.wav";		break;
				case SOUND_STORMPLOW_PLAYER_STOP:	soundname = "sounds/weapons/miniguns/ss_ship_gun_rel.wav";
													soundname2 = "sounds/weapons/plow/ss_ship_stormplow_rel.wav";	break;
				case SOUND_STORMSHIELD_PLAYER_STOP:	soundname = "sounds/weapons/miniguns/ss_ship_gun_rel.wav";
													soundname2 = "sounds/weapons/plow/ss_ship_stormshield_rel.wav";	break;
													
				case SOUND_MINIGUN_HEAVY_STOP:		soundname = "sounds/enemies/heavy_tank/ss_heavytank_rel.wav";	break;
				
				case SOUND_FLYERDOCKIN:				soundname = "sounds/enemies/carrier/ss_flier_dockin.wav";		break;
				case SOUND_FLYERDOCKOUT:			soundname = "sounds/enemies/carrier/ss_flier_dockout.wav";		break;
				
				case SOUND_PICKUP_CRYSTAL_RED:		soundname = "sounds/items/ss_crystal_red3.wav";					break;
				case SOUND_PICKUP_CRYSTAL_BLUE:		soundname = "sounds/items/ss_crystal_blue3.wav";				break;
				case SOUND_PICKUP_CRYSTAL_GREEN:	soundname = "sounds/items/ss_crystal_green3.wav";				break;
				case SOUND_PICKUP_SHIELD:			soundname = "sounds/items/ss_shield.wav";						break;
				case SOUND_PICKUP_ARMOR_PLATE:		soundname = "sounds/items/ss_armor_plate.wav";					break;
				case SOUND_PICKUP_ARMOR_FULL:		soundname = "sounds/items/ss_armor_full.wav";					break;
				case SOUND_PICKUP_WEAPON:			soundname = "sounds/items/ss_weapns.wav";						break;
				case SOUND_PICKUP_EXTRALIFE:		soundname = "sounds/items/ss_extralife.wav";					break;
				case SOUND_PICKUP_DATAKEY:			soundname = "sounds/items/ss_datakey_2_pickup.wav";				break;
				case SOUND_PICKUP_CORRUPTFUSIONCORE:	soundname = "sounds/items/ss_fusioncore_pickup.wav";		break;
				case SOUND_PICKUP:					soundname = "sounds/items/weapon_pickup1c.wav";					break;
				
				case SOUND_TERMINAL_ERROR:			soundname = "sounds/equipment/ss_terminal_error_1.wav";			break;
				case SOUND_TERMINAL_ACCEPT:	
					soundname = "sounds/equipment/ss_terminal_accept_2.wav";
					self.istoggled = true;
					break;
					
				case SOUND_TELEPORT_ERROR:			soundname = "sounds/equipment/ss_teleport_error.wav";			break;
				
				case SOUND_PICKUP_FLAG:
					ATTN = ATTN_NONE;
					if(self.team == player.team)	soundname = "sounds/ctf/ss_ctf_player_flag_cap.wav";
					else							soundname = "sounds/ctf/ss_ctf_enemy_flag_cap.wav";
					break;
					
			}
		}
	}

	if(vars)
	{
		r = max(1, ceil(random()*vars));
		soundname = strcat(soundname, ftos(r));
		soundname = strcat(soundname, ".wav");	
	}
	
	if(soundname)
		pointsound(self.origin, soundname, 1, ATTN);

	if(soundname2)
		pointsound(self.origin, soundname2, 1, ATTN);	
}

void GetSharedEntStats(float sendflags, float isnew) =
{
	local float wastoggled, neweffectflags;

	if(sendflags & SFL_EFFECTS)
	{
		neweffectflags = ReadLong();
		UpdateEffects(neweffectflags);
	}

	if(!sendflags & SFL_RESET)
		return;

	wastoggled = self.istoggled;

	self.id = ReadLong();
	self.istoggled = ReadByte();
	self.activated = ReadByte();
	self.isdead = ReadByte();
	self.deadmodelnum = ReadByte();
	self.triggerobjectiveentid = ReadLong();
	self.mapicon = ReadByte();
	self.maptargetid = ReadLong();
	self.hashealth = ReadByte();
	self.terminaltype = ReadByte();
	self.object_activationtime = ReadLong();
	self.requireskey = ReadByte();
	self.team = ReadLong();
//	print(ftos(self.team));print(" : TEAM\n");
	
	if(!isnew || self.activated)
	if(self.istoggled != wastoggled)
		self.toggle = true;
	
//	UpdateOwners();	
}

void PostObjectUpdate() =
{
	if(self.toggle)
	{
		self.toggle = false;
		ToggleObject(self);
	}
}

void RemoveControlEnt() =	{	/*self.owner.alpha = 0;*/	self.owner.controlent = world;	}

void ManageControlEnts(float sendflags) =
{
	local vector c_colormod;

	if(sendflags & SFL_BASEDATA)
	{
	//	if(self.npcclass == NPC_REPAIRTURRET)
	//		print("basedata repairturret csqc\n");
	
	//	if(self.npcclass == NPC_MICROFLYER)
	//		print("flyer reading basedata!?!\n");
	
	//	if(self.npcclass == NPC_TURRET)
	//		print("turret reading basedata!?!\n");
	
		local vector ce_origin_base, ce_angles_base;
		
		self.entid = ReadLong();		
		self.targetstagetwoentid = ReadLong();
		self.targetstagethreeentid = ReadLong();
		self.triggerentid = ReadLong();
		self.targetentid = ReadLong();		
		self.associationentid = ReadLong();
		self.isdeletedformission = ReadByte();
		self.startstateoff = ReadByte();
		self.triggerdelaytime = ReadLong();
		self.touchtrigger = ReadByte();
		self.maxtriggers = ReadShort();
		self.multiplayeronly = ReadByte();
		
		self.spawner_max_areaents = ReadShort();
		self.spawner_max_ents = ReadShort();
		self.spawner_max_lighttanks = ReadShort();
		self.spawner_max_mediumtanks = ReadShort();
		self.spawner_max_lightningtanks = ReadShort();
		self.spawner_max_heavytanks = ReadShort();
		
		ce_origin_base_x = ReadCoord();
		ce_origin_base_y = ReadCoord();
		ce_origin_base_z = ReadCoord();
		ce_angles_base_x = ReadCoord();
		ce_angles_base_y = ReadCoord();
		ce_angles_base_z = ReadCoord();
		
		self.movement_behavior = ReadShort();
		self.pathgroupid = ReadLong();	
		
		self.permanent = ReadByte();
		
		if(!self.permanent)
		if(adminmode)
		{
			if(!self.controlent)
			{
				self.controlent = spawn();
				self.controlent.colormod = '1 1 1';
				SetOwner(self.controlent, self);
				SetParent(self.controlent, self);
				self.controlent.modelflags = self.modelflags;
				self.controlent.predraw = self.predraw;
				self.controlent.class = CLASS_CONTROLENT;
				self.controlent.objclass = self.objclass;
				self.controlent.variant = self.variant;
				self.controlent.drawmask = MASK_NORMAL;
				self.controlent.PreRemoveFunc = RemoveControlEnt;				
				ControlEntChain_Add(self.controlent);
			}
			else
			if(self.controlent.colormod != '0 0 0')
				c_colormod = self.controlent.colormod;
			
			self.controlent.istoggled = self.startstateoff;
			self.controlent.touchtrigger = self.touchtrigger;
			self.controlent.multiplayeronly = self.multiplayeronly;

			self.controlent.object_activationtime = self.object_activationtime;
			
			self.controlent.spawner_max_areaents = self.spawner_max_areaents;				
			self.controlent.spawner_max_ents = self.spawner_max_ents;
			self.controlent.spawner_max_lighttanks = self.spawner_max_lighttanks;
			self.controlent.spawner_max_mediumtanks = self.spawner_max_mediumtanks;
			self.controlent.spawner_max_heavytanks = self.spawner_max_heavytanks;
			self.controlent.spawner_max_lightningtanks = self.spawner_max_lightningtanks;
			
			if(self.objclass == OBJ_TRAIN)
				self.controlent.modelindex = self.modelindex;
			else
				SetObjectAppearance(self.controlent, self.objclass, self.variant);
				
			if(c_colormod != '0 0 0')
				self.controlent.colormod = c_colormod;	
				
		//	self.controlent.scale = self.scale;
			SetObjectSize(self.controlent, self.mins, self.maxs);
			setorigin(self.controlent, ce_origin_base);
			self.controlent.origin_base = ce_origin_base;
			self.controlent.angles = self.controlent.angles_base = ce_angles_base;
			
			if(self.objclass == OBJ_NPC)
				self.controlent.solid = SOLID_BBOX;
			else
				self.controlent.solid = 4;				
		}
	}
	
/*	if(self.controlent)
	{
		if(sendflags & SFL_EDITABLE)
			self.controlent.allowediting = true;
	
//		if(sendflags & SFL_REVERT)
//		{print("revert?\n");
//			setorigin(self.controlent, self.origin_base);
//			self.controlent.angles = self.angles_base;
//		}
	}*/
	
	if(adminmode)
		SetAdminModeAlpha(self);

//	else
//		self.alpha = 0;
}

void ResetObjectiveText() =
{
	if(menu_missionbriefing)
		ClearObjectiveBuffers(menu_missionbriefing);
	if(objectiveblock)
		ClearObjectiveBuffers(objectiveblock);
}

void RemoveObjective(entity e) =
{
	ResetObjectiveText();
	SH_RemoveEnt(e);
}

void SetObjectiveTextFromTextEnt(entity obj_e, entity text_e) =
{
	local float count;
	local string s;

	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = text_e.(objectivetext[count]);
		obj_e.(objectivetext[count]) = s;
	}

	ObjectiveTextChain_Remove(text_e);
	remove(text_e);
}

void SetObjectiveTextToEnt(entity e, string text) =
{
	local float count;
	local string s;

	tokenize(text);
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = e.(objectivetext[count]);
		s = zonecpy(s, argv(count));
		e.(objectivetext[count]) = s;
	}	
}

void UpdateObjectiveText() =
{
	local float e_id;
	local string text;
	local entity e, ownerent;

	e_id = ReadLong();
	text = ReadString();
	
	ownerent = GetLinkedListEnt_float(list_objectivechain, objectivechain, id, e_id);
	
	if(ownerent)
	{
		ResetObjectiveText();
		SetObjectiveTextToEnt(ownerent, text);
	}
	else
	{
		e = spawn();
		e.lostownerid = e_id;
		ObjectiveTextChain_Add(e);
		SetObjectiveTextToEnt(e, text);
	}
}

void CreateObjectiveCompleteCenterprint(string s) =
{
	local string filename;
	local string str_objectivecomplete;

	filename = __FUNC__;
	buf_localizeobjectivetext = InitializeNonstandardTranslations(buf_localizeobjectivetext, filename, false);
	str_objectivecomplete	= Localize("OBJECTIVE COMPLETE", buf_localizeobjectivetext);
	WriteNonstandardTranslations(buf_localizeobjectivetext, filename, false, false);

	if(LOCALIZE_GENERATING)
		return;
	
	s = strcat(str_objectivecomplete, ";", s);
	SpawnCenterPrintText(s, '0.46 0.62 0.75');
}

void UpdateObjective(float isnew) =
{
	local float sendflags, wastoggled;
	local entity textent;
	local string s, soundname;
	
	wastoggled = self.istoggled;
	
	sendflags = ReadLong();
	self.istoggled = ReadByte();

	ResetObjectiveText();
		
	if(sendflags & SFL_RESET)
	{
		SetOwner(self, self);
		self.class = CLASS_OBJECT;
		self.objclass = OBJ_OBJECTIVE;
		self.id = ReadLong();
		self.entid = ReadLong();
//		self.objectivetext = zonecpy(self.objectivetext, ReadString());
		self.objectivepriority = ReadByte();
		ObjectiveChain_Add(self);
		self.RemoveFunc = RemoveObjective;
		
		textent = GetLinkedListEnt_float(list_objectivetextchain, objectivetextchain, lostownerid, self.id);
		if(textent)
			SetObjectiveTextFromTextEnt(self, textent);
	}
	
	if(!wastoggled)
	if(self.istoggled)
	{
		s = self.(objectivetext[currentlanguage]);
		CreateObjectiveCompleteCenterprint(s);
		if(self.objectivepriority == 0)
			soundname = "sounds/announcements/ss_voice_primary.wav";
		else
			soundname = "sounds/announcements/ss_voice_secondary.wav";
			
		pointsound('0 0 0', soundname, 1, ATTN_NONE);
	}
}

void TrainPredraw() =
{
	setorigin(self, self.origin + self.velocity*frametime);
	self.angles = self.angles + self.avelocity*frametime;
}

void TrainPredrawWithFade() =
{
	float destalpha, oldsolid;
	
	if (self.velocity != '0 0 0')
		setorigin(self, self.origin + self.velocity*frametime);
	if (self.avelocity != '0 0 0')
		self.angles = self.angles + self.avelocity*frametime;

	// update alpha
	// check if close to player, if so - trace
	if(self.class == CLASS_CONTROLENT)
		destalpha = 1;
	else
	{
		oldsolid = self.solid;
		self.solid = SOLID_BSP;
		traceline(camera_origin, player.origin+'0 0 32', MOVE_NORMAL, player);
		if (trace_ent == self)
			destalpha = 0;
		else
			destalpha = 1;
		self.solid = oldsolid;
	}
	
	// interpolate alpha
	if (destalpha)
		self.alpha = min(1, self.alpha + frametime*5);
	else
		self.alpha = max(0.2, self.alpha - frametime*5);
	
	// if opaque - become solid
	if (self.alpha == 1 && !(adminmodeactive && self.class != CLASS_CONTROLENT))
		self.solid = SOLID_BSP;
	else
		self.solid = SOLID_NOT;
}

void UpdateTrain(float isnew) =
{
	float bits, st;
	
	bits = ReadLong();

	// always read origin & angles
	self.origin_x = ReadCoord();
	self.origin_y = ReadCoord();
	self.origin_z = ReadCoord();
	self.angles = '0 0 0';
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	if (bits & 1)
	{
		self.angles_x = ReadCoord();
		self.angles_y = ReadCoord();
		self.angles_z = ReadCoord();
	}
	else self.angles_y = ReadCoord();
			
	// full update?
	if (bits & 8)
	{
		self.class = CLASS_OBJECT;
		self.objclass = OBJ_TRAIN;
		self.id = ReadLong();
		self.targetname = zonecpy(self.targetname, ReadString());
		self.cantbemoved = TRUE;
		if (bits & 16)
			setmodelindex(self, ReadShort());
		else
			setmodelindex(self, ReadByte());
		self.drawmask = MASK_NORMAL;
	}
	
	// set predraw
	self.predraw = world.think;
	if (bits & 32)	
		self.predraw = TrainPredrawWithFade;
	else if (bits & (2+4))	
		self.predraw = TrainPredraw;

	// train related update
	if (bits & (2+4))
	{
		if (bits & 2)
		{
			self.velocity_x = ReadCoord();
			self.velocity_y = ReadCoord();
			self.velocity_z = ReadCoord();
		}
		if (bits & 4)
		{
			self.avelocity_x = ReadCoord();
			self.avelocity_y = ReadCoord();
			self.avelocity_z = ReadCoord();
		}
	}
	

	ManageControlEnts(bits);	
}

void UpdateMissingPathConnections() =
{
	local entity e, nexte;
	
	e = list_missingpathconnectionschain;
	while(e)
	{
		nexte = e.missingpathconnectionschain;	
	
		if(e.prevpathpointid == self.entid)	
		{
			e.prevpathpoint = self;
			e.prevpathpointid = 0;
		}
	
		if(e.nextpathpointid == self.entid)
		{
			e.nextpathpoint = self;
			e.nextpathpointid = 0;
			SetPathModelForOrientation(e);	
		}
	
		if(!e.prevpathpointid && !e.nextpathpointid)
			MissingPathConnectionsChain_Remove(e);
	
		e = nexte;
	}	
}

void UpdatePath(float isnew) =
{
	local vector org;
	local float sendflags, oldpathgroupid, placedbyviewer;
	local entity e_prevpathpoint, e_nextpathpoint, e;
	
	sendflags = ReadLong();
	
	self.flags = self.flags | FL_SHARED;
	
	self.id = ReadLong();
	self.entid = ReadLong();
	self.pathgroupid = ReadLong();
	self.prevpathpointid = ReadLong();
	self.nextpathpointid = ReadLong();
	self.targetentid = ReadLong();
	self.triggerobjectiveentid = ReadLong();
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();

	placedbyviewer = ReadByte();
	
	if(placedbyviewer)
	if(marker.objclass == OBJ_PATH)
	{
		connectingpathfrom = self;
		self.temppathconnection = marker;
	}
		
	
/*	if(sendflags & SFL_EDITABLE)
	{
		oldpathgroupid = ReadLong();	
		
		if(oldpathgroupid)
		{
			e = findchainfloat(pathgroupid, oldpathgroupid);//list_aichain;
			while(e)
			{
			//	if(ai.pathgroupid == oldpathgroupid)
				if(e.objclass != CLASS_PATH)
					e.pathgroupid = self.pathgroupid;
			
				e = e.chain;
			}
		}
	}*/
	
	SpawnObject(self, OBJ_PATH, 0, SUB_Null);
	
	if(!editingpaths)
		self.drawmask = false;
	
	self.solid = 5;
	self.class = CLASS_CONTROLENT;	
	ControlEntChain_Add(self);
	
	setorigin(self, org);
	
	if(self.prevpathpointid)
	{
		self.prevpathpoint = findfloat(world, entid, self.prevpathpointid);
		if(!self.prevpathpoint)
			MissingPathConnectionsChain_Add(self);
		else
			self.prevpathpointid = 0;
	}
	else
		self.prevpathpoint = world;
		
	if(self.nextpathpointid)
	{
		self.nextpathpoint = findfloat(world, entid, self.nextpathpointid);
		if(!self.nextpathpoint)
			MissingPathConnectionsChain_Add(self);
		else
		{
			self.nextpathpointid = 0;
			SetPathModelForOrientation(self);	
		}
	}
	else
		self.nextpathpoint = world;
	
	UpdateMissingPathConnections();	
	
	PathChain_Add(self);
}

void UpdateAmbientSound(float isnew)
{
	local float sendflags;
	local vector org;

	sendflags = ReadLong();
	
	self.flags = self.flags | FL_SHARED;
	
//	if(sendflags & SFL_EDITABLE)
//		self.allowediting = true;
	
	self.class = CLASS_OBJECT;
	self.objclass = OBJ_AMBIENTSOUND;
	self.id = ReadLong();
	self.entid = ReadLong();
	
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();
	
	setorigin(self, org);

	self.ambientsoundeffect = zonecpy(self.ambientsoundeffect, ReadString());

	if(sendflags & SFL_RESET)
	{
		SetOwner(self, self);
		SetParent(self, self);
		SetObjectAppearance(self, self.objclass, self.variant);
	//	SetObjectSize(self, self.objclass, self.variant);
		
		self.predraw = DrawModelFlags;		
		
		if(adminmode)
			self.drawmask = MASK_NORMAL;
	
		self.onlydrawforadmins = true;
	
//		AmbientSoundChain_Add(self);
//		self.RemoveFunc = RemoveParticleEmitter;
	}
	
	ManageControlEnts(sendflags);
	if(adminmode)
	if(self.controlent)
		self.controlent.ambientsoundeffect = zonecpy(self.controlent.ambientsoundeffect, self.ambientsoundeffect);
}

void RemoveParticleEmitter(entity e) =
{
	RemoveOwnedEnts(e);
	SH_RemoveEnt(e);	
}

void UpdateParticleEmitter(float isnew)
{
	local float sendflags;
	local vector org, ang;

	sendflags = ReadLong();
	
	self.flags = self.flags | FL_SHARED;
	
//	if(sendflags & SFL_EDITABLE)
//		self.allowediting = true;
	
	self.class = CLASS_OBJECT;
	self.objclass = OBJ_PARTICLEEMITTER;
	self.id = ReadLong();
	self.entid = ReadLong();
	self.istoggled = ReadByte();
	
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();
	ang_x = ReadCoord();
	ang_y = ReadCoord();
	
	setorigin(self, org);
	self.angles = ang;

	self.particleemittereffect = zonecpy(self.particleemittereffect, ReadString());
	self.particleindex = particleeffectnum(self.particleemittereffect);	

	if(sendflags & SFL_RESET)
	{
		SetOwner(self, self);
		SetParent(self, self);
		SetObjectAppearance(self, self.objclass, self.variant);
	//	SetObjectSize(self, self.objclass, self.variant);
		
		if(adminmode)
			self.drawmask = MASK_NORMAL;
	
		self.onlydrawforadmins = true;
	
		if(self.istoggled)
			ParticleEmitterChain_Remove(self);
		else
			ParticleEmitterChain_Add(self);
		
		self.RemoveFunc = RemoveParticleEmitter;
	}
	
	ManageControlEnts(sendflags);
	if(adminmode)
	if(self.controlent)
	{
		self.controlent.particleemittereffect = zonecpy(self.controlent.particleemittereffect, self.particleemittereffect);
		self.controlent.particleindex = self.particleindex;
		self.controlent.allowpitchadjustment = true;
	}
//	self.controlent.allowheightadjustment = true;
//	self.controlent.unstackable = true;
}

void UpdateTeam(float isnew) =
{
	local float sendflags, hadpoints;
	local string soundname;
	
	hadpoints = self.points;
	
	sendflags = ReadLong();
	
	if(sendflags & SFL_RESET)
		self.team = ReadLong();
	
	if(sendflags & SFL_SCORE)
		self.points = ReadLong()*0.1;

	if(isnew)
		TeamChain_Add(self);
		
	if(self.points > hadpoints)
	{
		if(self.team == player.team)
			soundname = "sounds/ctf/ss_ctf_player_score.wav";
		else
			soundname = "sounds/ctf/ss_ctf_enemy_score.wav";
	
		sound(self, CHAN_BODY, soundname, 1, ATTN_NONE);
	}
}

//void RemoveObject(entity e) =
//{
//	Func_oself(e, Explode_Object);
//	SH_RemoveEnt(e);	
//}

void UpdateObject(float isnew)
{
	local float sendflags, ownerid, wasdead;
	local vector org, ang;
	local entity ownerent;

	wasdead = self.isdead;
	
	self.flags = self.flags | FL_SHARED;	
	
	sendflags = ReadLong();
	
	if(sendflags & SFL_RESET)
		SilenceObjectSounds(self, false);
	
	GetSharedEntStats(sendflags, isnew);	
	self.mobile = ReadByte();	
		
	if(sendflags & SFL_RESET)
	{
		RemoveObjectEffects(self);
		RemoveTagEnts(self);
		ParticleEmitterChain_Remove(self);
		
		self.objclass = ReadLong();
		self.variant = ReadLong();
		self.scale = ReadLong()/10;
		
		if(self.objclass == OBJ_FLAG)
		{
			SetOwner(self, self);		
			AttachFollow(self, world, 0);
			ownerid = ReadLong();

		//	if(!self.owner)
			if(ownerid)		
			{
				ownerent = findfloat(world, id, ownerid);
				if(ownerent)
				{
					SetOwner(self, ownerent);
					SetParent(self, ownerent);
				}
			}

			if(self.owner)
			if(self.owner != self)
				AttachFollow(self, self.owner, 0);	
				
			self.AnimFunc = self.Anim_Default = anim_movement;
			self.predraw = Predraw;
		}

		self.class = CLASS_OBJECT;
		self.scale = 0;
		SetObjectAppearance(self, self.objclass, self.variant);
//		if(self.scale)
//			SetObjectSize(self, self.mins*self.scale, self.maxs*self.scale);
//		else
//			self.scale = 1;

	/*	if(self.frames_idle != '0 0 0')
		{print("B\n");
			self.AnimFunc = self.Anim_Default = anim_movement;
			self.predraw = Predraw;
		}
		else*/
		if(!IsAssignedFunction(self.predraw))
		if(self.modelflags)
			self.predraw = DrawModelFlags;
		else
		{		
			self.predraw = Predraw;	
	
			if(!IsAssignedFunction(self.AnimFunc))	
				self.AnimFunc = self.Anim_Default = anim_movement;	
		}
		
		if(ownerid && !self.owner)
		{
			self.lostownerid = ownerid;
			OwnerlessChain_Add(self);
		}		
		else
			self.drawmask = MASK_NORMAL;
			
		if(!self.owner)
		if(!self.lostownerid)
		{
			SetOwner(self, self);
			SetParent(self, self);
		}
		
		InitObject(self);
		HittableChain_Add(self);
	}

	PostObjectUpdate();	
	
	if(self.mobile)
		MobileEntChain_Add(self);
	else
		MobileEntChain_Remove(self);
	
	if((self.ismapobject || self.mapicon) && !self.isdead)
		RadarEntChain_Add(self);
	else
		RadarEntChain_Remove(self);
	
	GetOrientationData(isnew, sendflags);

	ManageControlEnts(sendflags);
	
	if(sendflags & SFL_TELEPORT)
		SpawnTeleportEffect();		
	
	ApplyVisualEffects(sendflags, isnew);
	
	ReadEventFlags(sendflags);
//	if(!wasdead && self.isdead)
//		SilenceObjectSounds(self);
	UpdateOwners();	
}

void RemovePlayer(entity e) =
{
//	RemoveTagEnts(e);
//	RemoveOwnedEnts(e);
	self.ballcontroller = world;
//	e.part_cannon = world;
//	SH_RemoveEnt(e.part_cannon);
	SH_RemoveEnt(e);
}

/*void PlayerPredraw() =
{
	setorigin(self, self.origin + self.velocity*frametime);
	self.angles = self.angles + self.avelocity*frametime;
	
	Predraw();
}*/

void GetPlayerOrientationData(float sendflags) =
{
	local vector vec;

	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.angles_y = 0;

	vec_x = ReadCoord();
	vec_y = ReadCoord();
	vec_z = ReadCoord();	
	setorigin(self, vec);
	
	self.angles_y = ReadCoord();
	
	if(sendflags & SFL_ORIGIN)
	{
		vec_x = ReadCoord();
		vec_y = ReadCoord();
		vec_z = ReadCoord();	
		self.velocity = vec;
	}	
	
	if(sendflags & SFL_ANGLES)
		self.avelocity_y = ReadCoord();
}

void UpdatePlayer(float isnew) =
{
	local float sendflags;
	sendflags = ReadLong();

//	if(sendflags & SFL_TARGETNAME)
//	{
//		targetobjectname = zonecpy(targetobjectname, ReadString());
//		targethealth_old = 0;
//	}
	
	if(sendflags & SFL_STATE)
		self.buttonchat = ReadByte();
	
	GetSharedEntStats(sendflags, isnew);

	if(sendflags & SFL_BASEDATA)
	{
		self.netname = zonecpy(self.netname, ReadString());		
	//	self.team = ReadLong();
		self.colormod_x = ReadCoord();
		self.colormod_y = ReadCoord();
		self.colormod_z = ReadCoord();	
		
		if(GameMode_HasTeams(gamemode))
			self.colormod = self.colormod*0.35 + GetTeamColor(self.team)*0.75;
	}

	if(sendflags & SFL_RESET)
	{
		self.hasguestaccess = ReadByte();
		self.hasadminaccess = ReadByte();
	
		ParticleEmitterChain_Remove(self);
	
		self.class = CLASS_PLAYER;
	//	PlayerChain_Add(self);
		SetOwner(self, self);
		SetParent(self, self);
	//	SetAndPrecacheModel (self, "models/player/player.dpm");
//		self.isdead = false;
	//	setsize(self, '-64 -64 0', '64 64 128');
		SetObjectAppearance(self, 0, 0);
		self.mobile = true;
		self.blipsize = 2;
	//	self.colormod = '1 1 1';
		self.shieldscale = 1;
		
		if(!self.isdead)
		{
			TAG_CANNON_R = gettagindex(self, "tag_cannon.R");
		//	TAG_CANNON_L = gettagindex(self, "tag_cannon.L");
			TAG_MINIGUN_R = gettagindex(self, "minigun.R");
			TAG_MINIGUN_L = gettagindex(self, "minigun.L");
			TAG_JET_R = gettagindex(self, "jet.R");
			TAG_JET_L = gettagindex(self, "jet.L");
			TAG_WINGTRAIL_R = gettagindex(self, "wing_trail.R");
			TAG_WINGTRAIL_L = gettagindex(self, "wing_trail.L");
		}
		
		if(self.hashealth)
			self.drawmask = MASK_NORMAL;
		else
			self.drawmask = false;
		
		RadarEntChain_Add(self);
		MobileEntChain_Add(self);
		PlayerChain_Add(self);
		CanShootChain_Add(self);
		HittableChain_Add(self);
		
/*		self.part_cannon = spawn();
		SetOwner(self.part_cannon, self);
		SetParent(self.part_cannon, self);
		SetAndPrecacheModel(self.part_cannon, "models/player/cannon.dpm");
		Attach(self.part_cannon, self, gettagindex(self, "tag_cannon"));
		self.part_cannon.Anim_Default = player_cannon_idle;
		self.part_cannon.drawmask = MASK_NORMAL;*/
		
//		self.frames_idle			= '1 12 12';
//		self.frames_move			= '13 13 12';
	//	self.part_cannon.frames_idle = '1 1 1';
	//	self.part_cannon.frames_shoot_cannon_R = '1 6 48';
	//	self.part_cannon.frames_shoot_cannon_L = '13 18 48';
//		self.frames_shoot_hmissiles_R = '85 96 12';
//		self.frames_shoot_hmissiles_L = '97 108 12';	
		
	//	self.part_cannon.AnimFunc = self.part_cannon.Anim_Default = player_cannon_idle;
		self.AnimFunc = self.Anim_Default = anim_movement;
		self.predraw = Predraw;
		
	//	self.predraw = PlayerPredraw;
		self.RemoveFunc = RemovePlayer;
	}
	
	PostObjectUpdate();	
	
//	else
//	if(sendflags & SFL_TELEPORT)
//		SpawnTeleportEffect();		

//	self.oldupdatetime = self.newupdatetime;
//	self.newupdatetime = time;
	
	GetOrientationData(isnew, sendflags);
//	GetPlayerOrientationData(sendflags);
	
	if(sendflags & SFL_SCOREMULTIPLIER)
		self.scoremultiplier = ReadLong();
	
	if(!isnew && (sendflags & SFL_RESET) && !self.isdead)
		SpawnRespawnEffect();
	else
	if(sendflags & SFL_TELEPORT)
		SpawnTeleportEffect();	
	
	if((sendflags & SFL_BASEDATA) || (sendflags & SFL_TELEPORT))
	if(sendflags & SFL_ISSELF)
	{
		player = self;
		playercamera_origin = self.origin;
	}	
	
/*	if(!isnew)
	{
		if(sendflags & SFL_ANIM_SHOOT_MINIGUNS)
			shoot_miniguns();
		else
		if(sendflags & SFL_ANIM_SHOOT_MISSILES)
			shoot_missiles();
		else
		if(sendflags & SFL_ANIM_SHOOT_HMISSILES)
		{
			self.firingfrom = !self.firingfrom;
			shoot_hmissiles();
		}
	}*/
	
	ApplyVisualEffects(sendflags, isnew);
		
	ReadEventFlags(sendflags);
	
	ReadScores(sendflags);
	
	UpdateOwners();
}

void RemoveNPC(entity e) =
{
//	RemoveTagEnts(e);
//	RemoveOwnedEnts(e);
	SH_RemoveEnt(e);
}

entity Turret(entity e, string tagname, vector offset, float VARIANT, float WEP, float WEPVAR, vector f_rate, vector b_rate, float turret_yaw_speed, float turret_yaw_maxleft, float turret_yaw_maxright, float yawofs, float destructstage) =
{	
	if(e.hasturrets || e.isdead)
		return world;		
	
	local entity turret;
	local float tagindex;
	
	turret = spawn();		
//	SetAndPrecacheModel(turret, mdlname);
	SetObjectAppearance(turret, OBJ_NPC, VARIANT);
	if(strlen(tagname))
		tagindex = gettagindex(e, tagname);
	Attach(turret, e, tagindex);	
	setorigin(turret, offset);
	SetOwner(turret, e);
	SetParent(turret, e);
	turret.colormod = '1 1 1';
	turret.drawmask = MASK_NORMAL;
	
	return world;
}

/*void ServerDebug() =
{
	local string cmd;
	cmd = strcat("cmd debugent ", ftos(hover_ent.id));
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
}*/

void UpdateNPC(float isnew) =
{
	local float sendflags, t_class, ownerid, mdl_index;
	local entity ownerent;
	
	sendflags = ReadLong();
	
//	self.id = ReadLong();
//	self.entid = ReadLong();
//	UpdateOwners();

	GetSharedEntStats(sendflags, isnew);	

	if(sendflags & SFL_RESET)
	{
		t_class = ReadByte();
		self.team = ReadByte();
				
//	if(t_class == NPC_STATIONARYTURRET)
//		t_class += ReadByte()*0.1;
	
		ParticleEmitterChain_Remove(self);
	
		if(IsAttachedAIClass(t_class))// == NPC_TURRET)
		{
			ownerid = ReadLong();

			if(!self.owner)
			if(ownerid)		
			{
				ownerent = GetLinkedListEnt_float(list_aichain, aichain, id, ownerid);
				SetOwner(self, ownerent);
				SetParent(self, ownerent);
			}

			self.variant = ReadShort();
			self.tag_index = ReadShort();
			if(self.owner)
			{
				self.colormod = self.owner.colormod;
				self.alpha = self.owner.alpha;
				Attach(self, self.owner, self.tag_index);		
			}
		}
//	}
	
//	if(sendflags & SFL_RESET)
//	{
		self.hasturrets = true;
	//	self.solid = 5;
	//	self.PullDownMenuFunc = ServerDebug;
	
	//	self.immobiletime = '-1 -1 0';
	//	self.colormod = '0 0 0';
//		self.isdead = false;
		self.think = SUB_Null;
	
		self.class = CLASS_OBJECT;
		self.objclass = OBJ_NPC;
		if(!self.variant)
			self.variant = t_class;
		self.npcclass = t_class;

		if(!self.owner && IsAttachedAIClass(t_class))// == NPC_TURRET)
		{
			self.lostownerid = ownerid;
			OwnerlessChain_Add(self);
		}		
		else
			self.drawmask = MASK_NORMAL;
		
		if(!self.owner)
		if(!self.lostownerid)
		{
			SetOwner(self, self);
			SetParent(self, self);
		}
		
	//	if(IsAttachedAIClass(t_class))// == NPC_TURRET)
	//		self.modelindex = mdl_index;
	//	else
	
		if(!IsAttachedAIClass(t_class))
		{
			self.colormod = '1 1 1' - randomvec()*0.2;
			self.colormod_x = bound(0.8, self.colormod_x, 1);
			self.colormod_y = bound(0.8, self.colormod_y, 1);
			self.colormod_z = bound(0.8, self.colormod_z, 1);
		}
	
			SetObjectAppearance(self, OBJ_NPC, self.variant);	
		
	//	SetObjectSize(self, CLASS_NPC, t_class);
		
/*		if(t_class == NPC_LIGHTTANK)
		{
			self.frames_idle			= '1 12 12';
			self.frames_move			= '13 13 12';
			self.chargeeffect			= PEF_SPAWNCHARGE_SMALL;
			self.chargeeffect2			= PEF_SPAWNCHARGE_SMALL_EXPLODE;
			self.riftscale				= 0.74;
			self.chargetime				= 0.5;
		}
		else
		if(t_class == NPC_MEDIUMTANK)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
			self.chargeeffect			= PEF_SPAWNCHARGE_SMALL;
			self.chargeeffect2			= PEF_SPAWNCHARGE_SMALL_EXPLODE;
			self.riftscale				= 0.74;
			self.chargetime				= 1;
		}		
		else
		if(t_class == NPC_HEAVYTANK_PROTON || t_class == NPC_HEAVYTANK_MINIGUN)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
			self.chargeeffect			= PEF_SPAWNCHARGE_MEDIUM;
			self.chargeeffect2			= PEF_SPAWNCHARGE_MEDIUM_EXPLODE;
			self.riftscale				= 1;
			self.chargetime				= 2;
		}
		else
		if(t_class == NPC_LIGHTNINGTANK)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
			self.chargeeffect			= PEF_SPAWNCHARGE_SMALL;
			self.chargeeffect2			= PEF_SPAWNCHARGE_SMALL_EXPLODE;
			self.riftscale				= 0.74;
			self.chargetime				= 0.75;
		}
		else
		if(t_class == NPC_MICROFLYER)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
		}
		else
		if(t_class == NPC_CARRIERTANK)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
		}
		else	
		if(t_class == NPC_DESTROYERTANK)
		{
			self.frames_idle			= '1 48 24';
			self.frames_move			= '49 60 24';
		}
		else		
		if(t_class == NPC_TURRET)
		{
			self.frames_idle			= '0 0 24';
			self.frames_move			= '0 0 24';
		}
		else		
		if(t_class > NPC_STATIONARYTURRET && t_class <= NPC_STATIONARYTURRET+NUMTURRETTYPES)
		{
			self.frames_idle			= '0 0 12';
			self.frames_move			= '0 0 12';
			self.riftscale				= 0.74;
			self.chargetime				= 0.5;			
		}*/
		
		self.blipsize = self.shieldscale*2;
		
		if(!self.isdead)
		if(!IsAttachedAIClass(self.npcclass))
			RadarEntChain_Add(self);
			
		AIChain_Add(self);
		CanShootChain_Add(self);
		if(!IsAttachedAIClass(self.npcclass))// != NPC_TURRET)
			HittableChain_Add(self);
		
	//	if(t_class > NPC_STATIONARYTURRET && t_class <= NPC_STATIONARYTURRET+NUMTURRETTYPES)
	//	{
			self.mobile = true;
			MobileEntChain_Add(self);
	//	}

		self.AnimFunc = self.Anim_Default = anim_movement;
		self.predraw = Predraw;//InterpolateAnimation;
		
		self.RemoveFunc = RemoveNPC;
	}
	
	PostObjectUpdate();
	
/*	else
	{
		if(self.npcclass == NPC_DESTROYERTANK)
		{
			if(sendflags & SFL_ANIM_SHOOT1)
				self.AnimFunc = destroyer_tank_shoot1;
		
			if(sendflags & SFL_ANIM_SHOOT2)
				self.AnimFunc = destroyer_tank_shoot2;
		}
	}*/

	GetOrientationData(isnew, sendflags);
	ManageControlEnts(sendflags);
	
	if(sendflags & SFL_SCOREMULTIPLIER)
		SpawnPointText(0, ReadLong(), self.origin);
	
//	if(sendflags & SFL_BASEDATA || sendflags & SFL_RESET)
//		SetObjectAppearance(self, CLASS_NPC, self.variant);	
	
//	if(sendflags & SFL_RESET)
//		self.pathgroupid = ReadLong();

	ApplyVisualEffects(sendflags, isnew);
		
	if(sendflags & SFL_TELEPORT)
	{
//		local float port;
//		port = ReadShort();
		
//		if(port == CLASS_TRIGGER)
//			SpawnTeleportEffect();
		
//		if(port == CLASS_PORTAL)
			SpawnRift();
	}
	
	ReadEventFlags(sendflags);
	
	UpdateOwners();	
}

void RemoveBullet(entity e) =	{	SH_RemoveEnt(e);	}

/*void AssignBulletData(float shotnum, float TAG, vector ang) =
{
	local float shot_len, hit_id;
	local entity e;
	shot_len = ReadLong();
	hit_id = ReadLong();
	self.(org_start[shotnum]) = gettaginfo(self.owner, TAG)+randomvec()*5;
	
	pointsound(self.(org_start[shotnum]), "sounds/weapons/miniguns/miniguns_burst.wav", 1, ATTN_NORM);	

	if(hit_id)
		e = GetLinkedListEnt_float(list_hittablechain, hittablechain, id, hit_id);//findfloat(world, id, hit_id);

	makevectors(ang);
	self.(org_end[shotnum]) = self.(org_start[shotnum]) + v_forward*shot_len;
	setorigin(self, (self.org_end + self.org_start)*0.5);
	pointparticles(PEF_MINIGUN_MUZZLEFLASH, self.(org_start[shotnum]), v_forward, 1);
	
	local vector start, end;
	start = self.(org_start[shotnum]);
	end = self.(org_end[shotnum]);
	
	if(e.shieldscale)
		self.(org_end[shotnum]) = DrawDirectShieldEffect(end, shot_len, self, self.angles, e);
	
	makevectors(ang);
	pointparticles(PEF_MINIGUN_HIT, self.(org_end[shotnum]), v_forward*-1, 1);	
}*/

void UpdateBullet(float isnew) =
{
	local float SHOTVARIANT, shot_len, hit_id, muzzleflasheffect, hiteffect, rad, rad_end;
	local vector ang, org, rgb;
	local entity e;

	SHOTVARIANT = ReadByte();
	
	self.class = CLASS_SHOT;
	self.shotclass = SHOT_BULLET;
	self.shotvariant = SHOTVARIANT;
//	self.blipsize = 1;
	self.drawtime = time+0.05;		
	self.borntime = time;
	
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();
	ang_x = ReadCoord();
	ang_y = ReadCoord();
	shot_len = ReadLong();
	hit_id = ReadLong();
	
	setorigin(self, org);
	self.angles = ang;
	
	makevectors(ang);
	self.org_end = self.origin + v_forward*shot_len;	
	
	if(hit_id)
	{
		e = GetLinkedListEnt_float(list_hittablechain, hittablechain, id, hit_id);

		if(e.shieldscale)
			self.org_end = DrawDirectShieldEffect(self.org_end, self, self.angles, e);	
	}

	if(SHOTVARIANT == BULL_FLACKGUN_PLAYER)
	{
		rgb = '0.33 0.22 0.05';
		rad = 200;
		rad_end = 150;
		muzzleflasheffect = PEF_FLACKGUN_MUZZLEFLASH;
		hiteffect = PEF_FLACKGUN_HIT;
	}
	else
	if(SHOTVARIANT == BULL_MINIGUN_PLAYER)
	{
		rgb = '1 0.66 0.14';
		rad = 150;
		muzzleflasheffect = PEF_MINIGUN_MUZZLEFLASH;
		hiteffect = PEF_MINIGUN_HIT;	
	}
	else
	if(SHOTVARIANT == BULL_MINIGUN_HEAVY)
	{
		rgb = '0.93 0.33 0';
		rad = 250;
		muzzleflasheffect = PEF_HEAVYTANK_MINIGUN_MUZZLEFLASH;
		hiteffect = PEF_HEAVYTANK_MINIGUN_HIT;
	}
	
	makevectors(ang);
	pointparticles(muzzleflasheffect, self.origin, v_forward, 1);	

	local float r;
	local string soundname;
	
//	if(SHOTVARIANT == BULL_MINIGUN_PLAYER)
//		soundname = "sounds/weapons/miniguns/ss_ship_gun";
//	else
//	if(SHOTVARIANT == BULL_FLACKGUN_PLAYER)
//		soundname = "sounds/weapons/flack/ss_flak_";
//	else
//	if(SHOTVARIANT == BULL_MINIGUN_HEAVY)
//		soundname = "sounds/enemies/heavy_tank/ss_heavytank_gun";
	
/*	if(soundname)
	{
		r = max(1, ceil(random()*4));
		soundname = strcat(soundname, ftos(r));
		soundname = strcat(soundname, ".wav");	
		pointsound(self.origin, soundname, 1, ATTN_NORM);
	}*/
	
	SetDynamicLight(self, rgb, rad, 0, FALSE, 0.16);
	e = spawn();
	SetOwner(e, self);
	setorigin(e, self.org_end+v_forward*-48);
	if(rad_end)
		rad = rad_end;
	SetDynamicLight(e, rgb, rad, 0, FALSE, 0.16);	
	
	pointparticles(hiteffect, self.org_end, v_forward*-1, 1);
	
	self.RemoveFunc = RemoveBullet;
	
	ShotChain_Add(self);
//	RadarEntChain_Add(self);
}

void UpdateBeam(float isnew) =
{
	local vector rgb;
	local float rad, rad_end, SHOTVARIANT, ownerid;
	local string firesound;
	local entity ownerent;
	
	SHOTVARIANT = ReadByte();
	
	self.class = CLASS_SHOT;
	self.shotclass = SHOT_BEAM;
	self.shotvariant = SHOTVARIANT;
//	self.blipsize = 1;
//	ownerid = ReadLong();
//	if(ownerid)
//	if(!self.owner)
//	{
//		ownerent = GetLinkedListEnt_float(list_canshootchain, canshootchain, id, ownerid);
//		SetOwner(self, ownerent);//	findfloat(world, id, ownerid));//self.owner = findfloat(world, id, ownerid);
//		SetParent(self, ownerent);
//	}
	
	local vector ang, org;
	
	org_x = ReadCoord();
	org_y = ReadCoord();
	org_z = ReadCoord();

	setorigin(self, org);
	
	self.angles_x = ReadCoord();
	self.angles_y = ReadCoord();	
	
	self.shotlen = ReadLong();
	
//	if(IsAttachedAIClass(self.owner.npcclass))// == NPC_TURRET)
//		ang_y += self.owner.owner.angles_y;
	
//	makevectors(ang);
//	setorigin(self, self.owner.origin+v_forward*(self.shotlen*0.5));	
	
	local float hit;
	hit = ReadLong();

	if(SHOTVARIANT == BEAM_THUNDERBOLT
	|| SHOTVARIANT == BEAM_LIGHTNINGBOLT)
	{
		ownerid = ReadLong();

		if(!self.lostownerid)
		if(!self.owner)
		if(ownerid)		
		{
			ownerent = findfloat(world, id, ownerid);
			
			if(!ownerent)
			{
				self.lostownerid = ownerid;
				OwnerlessChain_Add(self);
			}
			else
				SetOwner(self, ownerent);
		}	
	}
	
	if(hit)
		self.hitent = GetLinkedListEnt_float(list_hittablechain, hittablechain, id, hit);//findfloat(world, id, hit);
	else
		self.hitent = world;
		
//	if(!self.mute)
//	{
//		self.mute = true;
		

//	}
	
	if(isnew)
	{
		switch(self.shotvariant)
		{
			case BEAM_DESTROYERBEAM:
				rgb = '4 0 0';
				rad = 600;
				rad_end = 700;
				firesound = "sounds/enemies/destroyer/ss_destroyer_cannon_shot.wav";
				break;
				
			case BEAM_TURRETBEAM:
				rgb = '1 0 0';
				rad = 250;
				rad_end = 300;
				firesound = "sounds/enemies/heavy_beam_turret/ss_heavybeam_shot.wav";
				break;
			
			case BEAM_THUNDERBOLT:
				rgb = '0 0 1';
				rad = 200;
				rad_end = 250;
				firesound = "sounds/weapons/thunderbolt/electric_discharge1.wav";
				break;
				
			case BEAM_CANNON:
				rgb = '0 0 4';
				rad = 250;
				rad_end = 200;
				firesound = "sounds/weapons/beam/ss_ship_beamcannon.wav";
				break;
			
			case BEAM_REPAIR:
				rgb = '4 2.44 0';
				rad = 200;
				rad_end = 500;
				firesound = "sounds/enemies/repair_turret/ss_repairbeam.wav";
				break;
			
			case BEAM_LIGHTNINGBOLT:
				rgb = '0 1 0.5';
				rad = 150;
				rad_end = 200;
				firesound = "sounds/enemies/lightning_tank/ss_lightning_shot.wav";
				break;
		}

		sound(self, CHAN_WEAPON, firesound, 1, ATTN_NORM);
	
		self.RemoveFunc = RemoveBullet;	
	
		SetDynamicLight(self, rgb, rad, 0, FALSE, 0);
		local entity e;
		e = spawn();
		SetOwner(e, self);
		setorigin(e, self.origin);
		
		if(rad_end)
			rad = rad_end;
		SetDynamicLight(e, rgb, rad, 0, FALSE, 0);
	
	
		ShotChain_Add(self);
	//	RadarEntChain_Add(self);
	}
}

void RocketThink() =
{
	sound(self, CHAN_WEAPON, "sounds/weapons/rockets/rocket_fly.wav", 1, ATTN_NORM);
	self.nextthink = time+0.69;
}

void MissileThink() =
{
	sound(self, CHAN_WEAPON, "sounds/weapons/rockets/ss_ship_homingmissile_jet.wav", 1, ATTN_NORM);
	self.nextthink = time+4.46;
}

void RemoveProjectile(entity e) =
{
	e.shieldent = world;
	SH_RemoveEnt(e);
}

/*float CanDamageEnt(entity victim, entity projectile) =
{
// UNCOMMENT for TEAM DAMAGE
//	if(!GameMode_CanHitAllies(gamemode))
//	if(projectile.team == victim.team)
//		return false
	
	if(projectile.parent == player)
		return false;
	
	return true;
}*/

void ProjectileHit() =
{
	local float hit, rad;
	local vector diff, end;		
	local entity cd;
	
	hit = ReadCoord();	

	if(self.drawmask && hit != 0)
	{
		// RADIUS EFFECTS
		switch(self.shotvariant)
		{
//			case CLASS_STORMPLOW:	rad = 250;		break;
			case PROJ_MISSILE:		rad = 250;		break;
			case PROJ_ROCKET:		rad = 250;		break;		
			case PROJ_MINIMIRV:		rad = 300;		break;		
		}
		
		self.drawmask = 0;
	
		if(hit > 0)
		{
			local entity hit_ent;
			hit_ent = GetLinkedListEnt_float(list_hittablechain, hittablechain, id, hit);//findfloat(world, id, hit);
			if(hit_ent)
			if(hit_ent.shieldscale)
				end = DrawDirectShieldEffect(self.origin, self, self.angles, hit_ent);
		}

		makevectors(self.angles);
		
		if(end == '0 0 0')
			end = self.origin+v_forward*-vlen(self.velocity)*frametime; // trace into the wall to get a more accurate location
			
		if(self.shotvariant == PROJ_PLASMA_LIGHT || self.shotvariant == PROJ_PLASMA_MED || self.shotvariant == PROJ_PLASMA_HEAVY || self.shotvariant == PROJ_PLASMA_DEEP)
			SpawnPlasmaHit(end, 1, 2.4);
		else
		if(self.shotvariant == PROJ_PROTON)
		{
			SpawnPlasmaHit(end, 2, 2.4);
		//	pointparticles(PEF_PROTON_HIT, end, normalize(self.velocity)*-1, 1); 
		}
		else
		if(self.shotvariant == PROJ_PROTON_MED)
		{
			SpawnPlasmaHit(end, 2, 3.4);
		//	pointparticles(PEF_PROTON_HIT, end, normalize(self.velocity)*-1, 1); 
		}			
		else	
		if(self.shotvariant == PROJ_STORMPLOW)
			SpawnPlasmaHit(end, 0, 2.4);
		else	
		if(self.shotvariant == PROJ_STORMSPREAD || self.shotvariant == PROJ_STORMSHIELD)
			SpawnPlasmaHit(end, 0, 2.4);
		else
		if(self.shotvariant == PROJ_ROCKET)
			SpawnRocketHit(end);
		else
		if(self.shotvariant == PROJ_MISSILE)
			SpawnMissileHit(end);
		else
		if(self.shotvariant == PROJ_MINIMIRV)
			SpawnMIRVHit(end);
		
		if(rad)
		if(!self.spawnedshields)
		{
			self.spawnedshields = true;
			cd = findradius(self.origin, rad);
			while(cd)
			{
				diff = cd.origin - self.origin;
				if(diff*diff <= rad*rad)
				if(cd.shieldscale)
				if(cd.hittable)
				if(!cd.isdead)
				if(cd != hit_ent)
				if(CanDamage(self.parent, cd, world) || self.liberated)
					DrawIndirectShieldEffect(self.origin, cd);
					
				cd = cd.chain;
			}
		}
	}	
	else
	if(!hit)
		self.drawmask = MASK_NORMAL;
}

void FoundOwnerStormShield(entity e, entity ownerent) =
{
	if(!ownerent.ballcontroller)
	{
		ownerent.ballcontroller = spawn();
		SetOwner(ownerent.ballcontroller, ownerent);
		SetParent(ownerent.ballcontroller, ownerent);
		SetAvelocity(ownerent.ballcontroller, '0 500 0');	
	}	
	
	SetOwner(e, ownerent.ballcontroller);
	SetParent(e, ownerent);

	Spread_CircleThink();		
}

void UpdateProjectile_StormShield(float sendflags) =
{
	local float ownerent_id;
	
	ownerent_id = ReadLong();
	self.ballnum = ReadByte();
	self.direction = ReadCoord();
	
	if(!self.owner && !self.liberated)
	{
		local entity ownerent;
		ownerent = GetLinkedListEnt_float(list_canshootchain, canshootchain, id, ownerent_id);
	
		if(ownerent_id)
		if(!ownerent)
		{
			self.lostownerid = ownerent_id;
			OwnerlessChain_Add(self);
			self.FoundOwnerFunc = FoundOwnerStormShield;
		}		
		else
			FoundOwnerStormShield(self, ownerent);
	}
	else
	if(sendflags & SFL_LIBERATE)
	{
		self.nextthink = 0;
		self.think = SUB_Null;
		self.angles = vectoangles(self.velocity);
	}
	
	if((sendflags & SFL_FADE) && !(sendflags & SFL_FADERESET))
		self.fadetime = time;

	if(sendflags & SFL_FADERESET)
	{
		self.fadetime = 0;
		self.alpha = 1;
	}
}

void UpdateProjectile(float isnew) =
{
	local float sendflags, SHOTVARIANT, firesoundvol, numsounds, parententid;
	local string firesound;
	local entity e;

	sendflags = ReadLong();
	SHOTVARIANT = ReadByte();

	if(sendflags & SFL_RESET)
	{
		parententid = ReadLong();	
		e = findfloat(world, entid, parententid);
		if(e)
			self.parent = e;
	}
	else
	if(sendflags & SFL_LIBERATE)
		self.liberated = true;
	
	if(!self.class)
	{
		self.class = CLASS_SHOT;
		self.shotclass = SHOT_PROJECTILE;
		self.shotvariant = SHOTVARIANT;
		self.blipsize = 1;
		self.RemoveFunc = RemoveProjectile;
		
		ShotChain_Add(self);
		HittableChain_Add(self);
		
	//	if(!self.mobile)
		if(SHOTVARIANT == PROJ_STORMPLOW)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			self.scale = 1.4;
			SetDynamicLight(self, '0 0.4 1', 100, 0, FALSE, 0);
			if(sendflags & SFL_AUDIBLE)
			{
			//	self.skin = 1;
				numsounds = 3;
				firesound = "sounds/weapons/storm/ss_ship_stormplow";
				firesoundvol = 1;
			}
		}
		else	
		if(SHOTVARIANT == PROJ_STORMSPREAD)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			self.scale = 1.4;
			SetDynamicLight(self, '0 0.4 1', 100, 0, FALSE, 0);
			if(sendflags & SFL_AUDIBLE)
			{
				firesound = "sounds/weapons/storm/ss_ship_stormspread.wav";
				firesoundvol = 1;
			}
		}
		else
		if(SHOTVARIANT == PROJ_STORMSHIELD)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			self.scale = 3;
			SetDynamicLight(self, '0 0.4 1', 200, 0, FALSE, 0);
			if(sendflags & SFL_AUDIBLE)
			{
				firesound = "sounds/weapons/storm/ss_ship_stormshield.wav";
				firesoundvol = 1;
			}
		}
		else
		if(SHOTVARIANT == PROJ_PLASMA_LIGHT)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			self.skin = 1;
			SetDynamicLight(self, '1 0.5 0', 100, 0, FALSE, 0);
			firesound = "sounds/enemies/light_tank/ss_lighttank_shot.wav";
			firesoundvol = 1;
		}
		else
		if(SHOTVARIANT == PROJ_PLASMA_MED)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			SetDynamicLight(self, '1 0.5 0', 100, 0, FALSE, 0);
			self.skin = 1;
			firesound = "sounds/enemies/medium_tank/ss_medtank_shot.wav";
			firesoundvol = 1;
		}
		else
		if(SHOTVARIANT == PROJ_PLASMA_HEAVY)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			SetDynamicLight(self, '1 0.5 0', 100, 0, FALSE, 0);
			self.skin = 1;
			firesound = "sounds/enemies/heavy_tank/ss_heavytank_shot.wav";
			firesoundvol = 1;
		}
		else
		if(SHOTVARIANT == PROJ_PLASMA_DEEP)
		{
			SetAndPrecacheModel(self, "models/weapons/spread.dpm");
			SetDynamicLight(self, '1 0.5 0', 100, 0, FALSE, 0);
			self.skin = 1;
			firesound = "sounds/enemies/light_plasma_turret/ss_lightturr_shot.wav";
			firesoundvol = 1;
		}		
		else
		if(SHOTVARIANT == PROJ_PROTON)
		{
			SetAndPrecacheModel(self, "models/weapons/proton_torpedo.dpm");
			SetDynamicLight(self, '1 0 1', 150, 0, FALSE, 0);
			self.skin = 1;
			firesound = "sounds/weapons/storm/ss_ship_stormplow1.wav";
			firesoundvol = 1;
		}
		else		
		if(SHOTVARIANT == PROJ_PROTON_MED)
		{
			SetAndPrecacheModel(self, "models/weapons/proton_torpedo.dpm");
			SetDynamicLight(self, '1 0 1', 200, 0, FALSE, 0);
			self.skin = 1;
			self.scale = 1.5;
			firesound = "sounds/weapons/storm/ss_ship_stormplow1.wav";
			firesoundvol = 1;
		}
		else		
		if(SHOTVARIANT == PROJ_MISSILE)
		{
			self.mobile = true;
			MobileEntChain_Add(self);
			SetAndPrecacheModel(self, "models/weapons/hmissile.dpm");
			SetDynamicLight(self, '1 0.7 0.06', 100, 0, FALSE, 0);
			self.light_ofs = '-96 0 0';
			firesound = "sounds/weapons/rockets/ss_ship_homingmissile_fire.wav";
			firesoundvol = 1;			
			self.think = MissileThink;
			self.nextthink = time;			
		}
		else
		if(SHOTVARIANT == PROJ_ROCKET)
		{
			self.mobile = true;
			MobileEntChain_Add(self);
			SetAndPrecacheModel(self, "models/weapons/rocket.dpm");
			SetDynamicLight(self, '1 0.7 0.06', 100, 0, FALSE, 0);
			self.light_ofs = '-96 0 0';
			self.scale = 2;
			firesound = "sounds/weapons/rockets/rocket1.wav";
			firesoundvol = 1;
			self.borntime = time;
			self.think = RocketThink;
			self.nextthink = time;
		}
		else
		if(SHOTVARIANT == PROJ_MIRV)
		{
			self.mobile = true;
			MobileEntChain_Add(self);
			SetAndPrecacheModel(self, "models/weapons/mirv.dpm");
			SetDynamicLight(self, '1 0.7 0.06', 100, 0, FALSE, 0);
			self.light_ofs = '-96 0 0';			
			firesound = "sounds/weapons/rockets/ss_ship_MIRV_launch.wav";			
			firesoundvol = 1;
			self.think = RocketThink;
			self.nextthink = time;			
		}
		else
		if(SHOTVARIANT == PROJ_MINIMIRV)
		{
			self.mobile = true;
			MobileEntChain_Add(self);
			SetAndPrecacheModel(self, "models/weapons/rocket.dpm");
			SetDynamicLight(self, '1 0.7 0.06', 100, 0, FALSE, 0);
			self.light_ofs = '-96 0 0';			
		//	firesound = "sounds/weapons/rockets/rocket1.wav";			
		//	firesoundvol = 1;
			self.think = RocketThink;
			self.nextthink = time;			
		}
	}
	
	
	GetOrientationData(isnew, sendflags);
	
	if(firesound)
	{
		if(numsounds)
		{
			local float r;
			r = max(1, ceil(random()*numsounds));
			firesound = strcat(firesound, ftos(r));
			firesound = strcat(firesound, ".wav");
		}
	
		pointsound(self.origin, firesound, firesoundvol, ATTN_NORM);
	}

	if(SHOTVARIANT == PROJ_STORMSHIELD)
		UpdateProjectile_StormShield(sendflags);

	ProjectileHit();
}
