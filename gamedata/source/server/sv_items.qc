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
float HasSecondaryType(entity e, float stype) =
{
	if(stype == 0)
	if((e.items1 & WEP1_ROCKETPOD)
	|| (e.items2 & WEP2_HOMINGMISSILES)
	|| (e.items2 & WEP2_MIRVMORTAR))
		return TRUE;

	if(stype == 1)
	if((e.items1 & WEP1_BEAMCANNON)
	|| (e.items2 & WEP2_THUNDERBOLT))
		return TRUE;
		
	return FALSE;
}

void TriggerItem() =
{
	if(self.istoggled)
		return;
		
	SetObjectAppearance(self, self.objclass, self.variant);
	self.solid = SOLID_TRIGGER;
	self.istoggled = TRUE;
	self.onlydrawforadmins = FALSE;	
	self.SendFlags = self.SendFlags | SFL_TELEPORT;
	self.teleporttouchtime = time+1;
}

float InitializeItem(float e_objclass, float e_variant, void() e_touch) =
{
	if(((!self.id && missionfileexists) || (self.multiplayeronly && singleplayer)) && !self.permanent)
	{
		SH_RemoveEnt(self);
		return FALSE;
	}

	if(!SetDefaultSharedStats(self))
		return FALSE;
	
	SetOwner(self, self);
	SetParent(self, self);
	
	self.class = CLASS_OBJECT;
	self.objclass = e_objclass;
	self.variant = e_variant;
	
	self.touchfunc = e_touch;
	
	if(!self.isdead)
		self.touch = e_touch;

	SetObjectAppearance(self, self.objclass, self.variant);

//	SetObjectSize(self, self.objclass, self.variant);
	
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_NONE;
	
	self.SendEntity = SendObject;
	
	ObjectChain_Add(self);
	
//	InitializeSharedEnt(self);	
	InitializeObjectOrientation(self);		
	
	if(self.triggerentid || self.istarget)
	if(!self.istoggled)
	{
		MakeObjectInvisibleToClients(self);
		self.solid = SOLID_NOT;
		self.TriggerFunc = TriggerItem;
	}	
	
	return TRUE;
}

void RespawnItem() =
{
	self.isdead = FALSE;
	self.touch = self.touchfunc;
	self.onlydrawforadmins = FALSE;
	SetObjectAppearance(self, self.objclass, self.variant);
	self.SendFlags = self.SendFlags | SFL_RESET | SFL_TELEPORT;
	self.teleporttouchtime = time+1;
}

void StopTossedObject(entity e) =
{
	self.nextthink = 0;
	self.think = SUB_Null;
	e.movetype = MOVETYPE_NONE;		
	e.mobile = FALSE;
	MobileEntChain_Remove(e);
	e.SendFlags = e.SendFlags | SFL_ORIGIN | SFL_ORIGIN_STOP;
}

void TossThink_Item() =
{
	if(self.velocity != '0 0 0')
	{
		self.nextthink = time+0.1;
		return;
	}
	
	StopTossedObject(self);
	
	if(GameMode_RemoveDroppedItems(gamemode) && !self.persistondrop)
	{
		if(GameMode_LongItemRemoveTimes(gamemode))
			self.nextthink = time+300;
		else
			self.nextthink = time+30;
		self.think = SUB_Remove;
	}
}

void DropItem(entity item, entity e, float CLASS, float VARIANT) =
{
	local vector vel, org;

	if(!item)
	{
		item = SpawnEnt();
		item.itemtouchtime = time+1;
		item = SpawnEntity(item, CLASS, VARIANT);
		InitializeSharedEnt(item);	
	}	

	org = e.origin+'0 0 8';
	setorigin(item, org);
	item.movetype = MOVETYPE_TOSS;
	vel = randomvec();
	vel_z = 0;
	vel = vel*350;
	vel_z = 450;
	item.velocity = vel;
	item.mobile = TRUE;
	MobileEntChain_Add(item);
	item.spawnedfrom = CLASS_PLAYER;
	item.think = TossThink_Item;
	item.nextthink = time+0.1;
}

void DropItems(entity e) =
{
	local float wep;

	if(!singleplayer)
	if(dropitemsinmultiplayer)	
	{
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((e.items1 & wep)	&& !(e.earneditems1 & wep))
				DropItem(world, e, OBJ_WEAPONPICKUP1, wep);
		}
		
		for(wep = 1; wep <= 16777215; wep = wep*2)
		{
			if((e.items2 & wep)	&& !(e.earneditems2 & wep))
				DropItem(world, e, OBJ_WEAPONPICKUP2, wep);
		}	
	}
	
	e.items1 = e.earneditems1;
	e.items2 = e.earneditems2;
	
	if(e.flagent)
		DropFlag(e);
}

void DropReplacedItem(entity e, float wclass, float wepflag) =
{
	local .float wepflagfield;

	if(wclass == OBJ_WEAPONPICKUP1)
		wepflagfield = items1;
	else
	if(wclass == OBJ_WEAPONPICKUP2)
		wepflagfield = items2;

	if(!(e.wepflagfield & wepflag))
		return;
		
	e.wepflagfield -= e.wepflagfield & wepflag;
	DropItem(world, e, wclass, wepflag);
}

void TutorialFlags(entity e, float printmessages) =
{
	float secondarytype_0, secondarytype_1;
	
	secondarytype_0 = HasSecondaryType(e, 0);
	secondarytype_1 = HasSecondaryType(e, 1);
	
	if(!(e.tutorial & TUT_SECONDARYSWITCH))
	if(secondarytype_0)
	if(secondarytype_1)
	{
		e.tutorial = e.tutorial | TUT_SECONDARYSWITCH;
		if(printmessages)
			TE_CenterPrint(e, CPM_SECONDARYSWITCH);
	}
	
	if(!(e.tutorial & TUT_SECONDARYFIRE))
	if(secondarytype_0 || secondarytype_1)
	{
		e.tutorial = e.tutorial | TUT_SECONDARYFIRE;
		if(printmessages)
			TE_CenterPrint(e, CPM_SECONDARYFIRE);
	}	
}

void SetItemTouchTime(entity e) =	{	e.itemtouchtime = time+2;	}

void ItemTouch(entity e, entity item, string soundfile, float pickupstringid) =
{
	local float stype;
	
	StopTossedObject(item);
	
	if(!item.items1)
	if(!item.items2)
		TriggerObjects(0);

	e.points += item.points*skillmultiple;
	UpdateScore(e, SCORESTAT_SCORE);
	
	item.touch = SUB_Null;
	
	e.items1 = e.items1 | item.items1;
	e.items2 = e.items2 | item.items2;
//	e.globalitems1 = e.globalitems1 | item.items1;
//	e.globalitems2 = e.globalitems2 | item.items2;
	
	if(item.items1 || item.items2)
	{
		if(HasSecondaryType(item, 0))
			stype = 0;
		else
		if(HasSecondaryType(item, 1))
			stype = 1;
			
		if(!HasSecondaryType(e, !stype))
			e.secondarywep = stype;
	}
	
	if(IsBaseEnt(item))
		MakeObjectInvisibleToClients(item);
	else
		SH_RemoveEnt(item);
		
	item.isdead = TRUE;
	
	if(item.pickupsound)
		SetEventFlag_Sound(e, item.pickupsound);
	else
		SetEventFlag_Sound(e, SOUND_PICKUP);
	
	if(GameMode_RespawningPickups(gamemode))
	{
		item.think = RespawnItem;
		if(item.objclass == OBJ_WEAPONPICKUP1 || item.objclass == OBJ_WEAPONPICKUP2)
			item.nextthink = time+weaponrespawndelay;
		else
			item.nextthink = time+itemrespawndelay;
	}
	
	if(pickupstringid)
		TE_CenterPrint(e, pickupstringid);
		
	TutorialFlags(e, TRUE);
}

float CanGetItem(entity e) =
{
	if(e.class != CLASS_PLAYER)
		return FALSE;

	if(e.health <= 0)
		return FALSE;

	if(self.itemtouchtime > time)
		return FALSE;		
		
//	if(!e.initialized) // is this needed?
//		return FALSE;

	if(e.adminmode)
		return FALSE;
		
	if(self.items1)
	if(e.items1 & self.items1)
		return FALSE;
	
	if(self.items2)
	if(e.items2 & self.items2)
		return FALSE;
	
	return TRUE;
}

void CrystalTouch() =
{
	if(!CanGetItem(other))
		return;

	ItemTouch(other, self, "", 0);
}

void crystal_red() =
{
	if(!InitializeItem(OBJ_CRYSTAL, 0, CrystalTouch))
		return;
		
	self.skin = 0;
	self.netname = "Red Crystal";
	self.points = 100;
	self.pickupsound = SOUND_PICKUP_CRYSTAL_RED;
}

void crystal_green() =
{
	if(!InitializeItem(OBJ_CRYSTAL, 1, CrystalTouch))
		return;
		
	self.skin = 1;
	self.netname = "Green Crystal";
	self.points = 1000;
	self.pickupsound = SOUND_PICKUP_CRYSTAL_GREEN;	
}

void crystal_blue() =
{
	if(!InitializeItem(OBJ_CRYSTAL, 2, CrystalTouch))
		return;
		
	self.skin = 2;
	self.netname = "Blue Crystal";
	self.points = 10000;
	self.pickupsound = SOUND_PICKUP_CRYSTAL_BLUE;	
}

void armor_shard_touch() =
{
	if(!CanGetItem(other))
		return;
	
	if(other.health >= 100)
		return;
	
	local float repairvalue;
		
	repairvalue = min(25, other.max_health-other.health);	
	other.health = other.health + repairvalue;
	ApplyStructuralEffects(other, repairvalue*-1);
	
	ItemTouch(other, self, "", 0);
}

void armor_shard() =
{
	if(!InitializeItem(OBJ_ARMORSHARD, 0, armor_shard_touch))
		return;
		
	self.points = 100;
	self.pickupsound = SOUND_PICKUP_ARMOR_PLATE;	
}

void armor_shell_touch() =
{
	if(!CanGetItem(other))
		return;
		
	if(other.health >= 100)
		return;	
		
//	if(other.health <= other.max_health*0.66)
//		other.SendFlags = other.SendFlags | SFL_DAMAGE_REPAIRED;
		
	other.health = 100;
	ItemTouch(other, self, "", 0);
}

void armor_shell() =
{
	if(!InitializeItem(OBJ_ARMORSHELL, 0, armor_shell_touch))
		return;
		
	self.points = 500;
	self.pickupsound = SOUND_PICKUP_ARMOR_FULL;	
}

void shield_touch() =
{
	if(!CanGetItem(other))
		return;
		
	if(other.armorvalue >= 400)
		return;
		
	if(other.maxshields < 400)
		other.maxshields = bound(0, other.maxshields + 100, 400);

	other.armorvalue = other.maxshields;//bound(0, other.armorvalue + 100, 400);
	ItemTouch(other, self, "", 0);
}

void shield() =
{
	if(!InitializeItem(OBJ_SHIELDPICKUP, 0, shield_touch))
		return;
		
	self.points = 1000;
	self.pickupsound = SOUND_PICKUP_SHIELD;	
}

void extra_life_touch() =
{
	local entity e;	

	if(!CanGetItem(other))
		return;
		
	if(GameMode_PlayerHasLives(gamemode))
	{	
		if(global_lives >= maxplayers+4)
			return;
		UpdateLives(global_lives + 1);	

		for(e = list_playerchain; e; e = e.playerchain)
			UpdateClientGameStatus(e);		
	}

	ItemTouch(other, self, "", 0);	
}

void extra_life() =
{
	if(!InitializeItem(OBJ_EXTRALIFE, 0, extra_life_touch))
		return;

	self.points = 10000;
	self.pickupsound = SOUND_PICKUP_EXTRALIFE;	
}

void minigun_touch() =
{
	if(!CanGetItem(other))
		return;
		
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_FLACKGUN);		
	ItemTouch(other, self, "", CPM_PICKUP_MINIGUN);
}

void minigun() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP1, WEP1_MINIGUN, minigun_touch))
		return;
		
	self.items1 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}

void flackgun_touch() =
{
	if(!CanGetItem(other))
		return;
		
	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_MINIGUN);		
	ItemTouch(other, self, "", CPM_PICKUP_FLACKGUN);
}

void flackgun() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_FLACKGUN, flackgun_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}

void shockwave_device_touch() =
{
	if(!CanGetItem(other))
		return;

	ItemTouch(other, self, "", CPM_PICKUP_SHOCKWAVE);
}

void shockwave_device() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_SHOCKWAVE, shockwave_device_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}

void storm_plow_touch() =
{
	if(!CanGetItem(other))
		return;
		
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_STORMSPREAD);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_STORMSHIELD);
	ItemTouch(other, self, "", CPM_PICKUP_STORMPLOW);
}

void storm_plow() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP1, WEP1_STORMPLOW, storm_plow_touch))
		return;
		
	self.items1 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}

void storm_spread_touch() =
{
	if(!CanGetItem(other))
		return;

	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_STORMPLOW);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_STORMSHIELD);		
	ItemTouch(other, self, "", CPM_PICKUP_STORMSPREAD);
}

void storm_spread() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_STORMSPREAD, storm_spread_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}

void storm_shield_touch() =
{
	if(!CanGetItem(other))
		return;

	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_STORMPLOW);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_STORMSPREAD);	
	ItemTouch(other, self, "", CPM_PICKUP_STORMSHIELD);
}

void storm_shield() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_STORMSHIELD, storm_shield_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;		
}

void thunderbolt_touch() =
{
	if(!CanGetItem(other))
		return;

	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_BEAMCANNON);	
	ItemTouch(other, self, "", CPM_PICKUP_THUNDERBOLT);
}

void thunderbolt() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_THUNDERBOLT, thunderbolt_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;		
}

void beam_cannon_touch() =
{
	if(!CanGetItem(other))
		return;

	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_THUNDERBOLT);		
	ItemTouch(other, self, "", CPM_PICKUP_BEAMCANNON);
}

void beam_cannon() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP1, WEP1_BEAMCANNON, beam_cannon_touch))
		return;
		
	self.items1 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;		
}

void rocket_pod_touch() =
{
	if(!CanGetItem(other))
		return;
		
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_HOMINGMISSILES);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_MIRVMORTAR);	
	ItemTouch(other, self, "", CPM_PICKUP_ROCKETPOD);
}

void rocket_pod() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP1, WEP1_ROCKETPOD, rocket_pod_touch))
		return;
		
	self.items1 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;		
}

void homing_missiles_touch() =
{
	if(!CanGetItem(other))
		return;
		
	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_ROCKETPOD);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_MIRVMORTAR);		
	ItemTouch(other, self, "", CPM_PICKUP_HOMINGMISSILES);
}

void homing_missiles() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_HOMINGMISSILES, homing_missiles_touch))
		return;
		
	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;		
}

void mirv_mortar_touch() =
{
	if(!CanGetItem(other))
		return;

	DropReplacedItem(other, OBJ_WEAPONPICKUP1, WEP1_ROCKETPOD);
	DropReplacedItem(other, OBJ_WEAPONPICKUP2, WEP2_HOMINGMISSILES);	
	ItemTouch(other, self, "", CPM_PICKUP_MIRV);
}

void mirv_mortar() =
{
	if(!InitializeItem(OBJ_WEAPONPICKUP2, WEP2_MIRVMORTAR, mirv_mortar_touch))
		return;

	self.items2 = self.variant;
	self.pickupsound = SOUND_PICKUP_WEAPON;	
}