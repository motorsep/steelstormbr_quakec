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
void Effects_Player() =					{}
void Effects_NPC_LightTank() =			{}
void Effects_NPC_MediumTank() =			{}
void Effects_NPC_HeavyTank() =			{}
void Effects_NPC_LightningTank() =		{}
void Effects_NPC_MicroFlyer() =			{}
void Effects_NPC_CarrierTank() =		{}
void Effects_NPC_DestroyerTank() =		{}
void Effects_NPC_Turret_Generic() =		{}
void Effects_NPC_HeavyTank_TurretHead() =	{}
void Effects_NPC_TurretHead_Plasma() =		{}
void Effects_NPC_TurretHead_Beam() =		{}

void SetObjectLight_Client(entity e, vector rgb, float rad, float lstyle, float shadows, string tag, vector ofs) =	{}

void RemoveEffect(float fx) =
{
	self.effectflags -= self.effectflags & fx;
	self.SendFlags = self.SendFlags | SFL_EFFECTS;		
}

void RemoveExpiredEffects() =
{
	if(self.stuntime)
	if(self.stuntime < time)
	{
		self.stuntime = 0;
		RemoveEffect(EFF_STUN);
	}
	
	if(self.wepdisabletime)
	if(self.wepdisabletime < time)
	{
		self.wepdisabletime = 0;
		RemoveEffect(EFF_WEPDISABLE);
	}	
	
	if(self.effectflags & EFF_SMOKE)
	if(self.health <= 0 || self.health > self.max_health*0.66)
		RemoveEffect(EFF_SMOKE);
	
	if(self.effectflags & EFF_BURN)
	if(self.health <= 0 || self.health > self.max_health*0.33)
		RemoveEffect(EFF_BURN);
}
