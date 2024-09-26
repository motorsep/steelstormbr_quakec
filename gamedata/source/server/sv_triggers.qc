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
void TriggerObjective(entity e) =
{
	if(e.istoggled)
		return;

	e.istoggled = TRUE;
	e.SendFlags = e.SendFlags | 1;
}

void ExecuteTrigger(entity triggerent, float triggerstage) =
{
	if(triggerstage == 0)
	if(!triggerent.istriggered)
		return;
	
	local entity e, ae, obj, ft, nexte, list_targets;
	local float triggernotready, skipent;

	e = world;
	ae = world;	
	obj = world;
	ft = world;
	nexte = world;
	list_targets = world;
	
	for(ft = list_frametriggerchain; ft; ft = ft.frametriggerchain)
	{
		if(triggerent == ft)
			return;
	}	
	
	if(!triggerent.triggerdelaytime)
	{
		triggerent.frametriggerchain = list_frametriggerchain;
		list_frametriggerchain = triggerent;
	}
	
	if(triggerstage == 0)
	{
		e = Chain2(findchainfloat(triggerentid, triggerent.entid));
	
		for(obj = list_objectivechain; obj; obj = obj.objectivechain)
		{
			if(obj.entid != triggerent.triggerobjectiveentid)
				continue;
				
			obj.chain2 = e;
			e = obj;
		}
	}
	
	if((triggerent.targetentid && triggerstage == 0)
	|| (triggerent.targetstagetwoentid && triggerstage == 2)
	|| (triggerent.targetstagethreeentid && triggerstage == 3))
	for(obj = list_objectchain; obj; obj = obj.objectchain)
	{
		if(obj.entid != triggerent.targetentid && triggerstage == 0)
			continue;
			
		if(obj.entid != triggerent.targetstagetwoentid && triggerstage == 2)
			continue;

		if(obj.entid != triggerent.targetstagethreeentid && triggerstage == 3)
			continue;			
			
		// don't try to trigger twice if the user has excessive trigger/target links
		if(obj.triggerentid == triggerent.entid && triggerstage == 0)
			continue;
			
		obj.chain2 = e;
		e = obj;
	}	
	
	for(; e; e = e.chain2)
	{
		skipent = FALSE;
	
		for(ft = list_frametriggerchain; ft; ft = ft.frametriggerchain)
		{
			if(e == ft)
			{
				skipent = TRUE;
				break;
			}
		}

		// avoid an endless loop
		if(skipent)
			continue;
		
		if(IsAssignedFunction(e.TriggerFunc) || e.objclass == OBJ_OBJECTIVE)
		{
			if(triggerstage == 0)
			for(ae = findchainfloat(associationentid, triggerent.entid); ae; ae = ae.chain)
			{
				if(!ae.istriggered)
					triggernotready = TRUE;
			}		
			
			if(!triggernotready)
			if(!(e.maxtriggers && e.currenttriggers >= e.maxtriggers))// || triggerstage != 0)
			{
			//	if(triggerstage == 0)
				if(e.maxtriggers)
					e.currenttriggers = e.currenttriggers+1;
			
				e.chain3 = list_targets;
				list_targets = e;
			
			//	e.frametriggerchain = list_frametriggerchain;
			//	list_frametriggerchain = e;					
			}
			
			triggernotready = FALSE;
		}
		else
		{
			eprint(e);
			dprint("Target has no trigger func!\nDaemon needs your console dump. Type \"condump triggerbug.txt\" in the console.\n");
		}
	}	
	
	e = list_targets;
	while(e)
	{
		nexte = e.chain3;
	//	list_targets = e.chain3;
		e.chain3 = world;
	
		if(e.objclass == OBJ_OBJECTIVE)
			TriggerObjective(e);
		else
		if(e.triggerdelaytime)
			Func_delay(e, e.triggerdelaytime, e.TriggerFunc);
		else
			Func_oself(e, e.TriggerFunc);	
			
		e = nexte;
	}
	
	e = list_frametriggerchain;
	while(e)
	{
		nexte = e.frametriggerchain;
		e.frametriggerchain = world;
		e = nexte;
	}
	list_frametriggerchain = world;
}

void TriggerObjects(float triggerstage) =
{
	local entity triggerent;

	if(!self.istrigger)
	if(!self.associationentid)	
		return;

	if(!self.entid)
		return;

	if(triggerstage == 0)
		self.istriggered = TRUE;
	
	ExecuteTrigger(self, triggerstage);	
	
	if(triggerstage == 0)
	if(self.associationentid)
	{
		triggerent = findfloat(world, entid, self.associationentid);
		ExecuteTrigger(triggerent, 0);
	}
}

float PlayersHaveWeapon(float e_objclass, float e_variant) =
{
	local entity e;
	local .float field;

	if(e_objclass == OBJ_WEAPONPICKUP1)
		field = items1;
	else
	if(e_objclass == OBJ_WEAPONPICKUP2)
		field = items2;

	for(e = list_playerchain; e; e = e.playerchain)
	{
		if(e.field & e_variant)
			return TRUE;
	}

	return FALSE;
}

void TriggerMissionEndObjectives() =
{
	local entity e, o;
	local float o_hasnonitemtrigger, o_executednonitemtrigger;
	
	for(o = list_objectivechain; o; o = o.objectivechain)
	{
/*		for(e = list_objectchain; e; e = e.objectchain)
		{	
			if(e.triggerobjectiveentid)
			if(e.triggerobjectiveentid == o.entid)
			if(e.objclass != OBJ_WEAPONPICKUP1)
			if(e.objclass != OBJ_WEAPONPICKUP2)
			{
				o_hasnonitemtrigger = TRUE;
				if(e.istriggered)
					o_executednonitemtrigger = TRUE;
			}
		}*/
	
		for(e = list_objectchain; e; e = e.objectchain)
		{
			if(e.triggerobjectiveentid)
			if(e.triggerobjectiveentid == o.entid)
		//	if(!(o_hasnonitemtrigger && !o_executednonitemtrigger))
			if(e.objclass == OBJ_WEAPONPICKUP1 
			|| e.objclass == OBJ_WEAPONPICKUP2)
			if(PlayersHaveWeapon(e.objclass, e.variant))
				TriggerObjective(o);
		}
	}
}

void TriggerObjects_StageZero() =	{	TriggerObjects(0);	}
void TriggerObjects_StageTwo() =	{	TriggerObjects(2);	}
void TriggerObjects_StageThree() =	{	TriggerObjects(3);	}

void TriggerTriggerRelay() =
{
	if(self.istoggled) // started off, does nothing the first time
	{
		self.istoggled = FALSE;
		self.istriggered = FALSE;
		return;
	}

	TriggerObjects(0);
//	if(!self.touchtrigger)
//		self.istriggered = FALSE;
}

void TriggerRelayTouch() =
{
	if(other.class != CLASS_PLAYER)
		return;
		
	if(self.istriggered)
		return;

	TriggerObjects(0);
}

void trigger_relay() =
{
	if(((!self.id && missionfileexists) || (self.multiplayeronly && singleplayer)) && !self.permanent)
	{
		SH_RemoveEnt(self);
		return;
	}

	if(self.startstateoff)	
	{
		self.istoggled = TRUE;
		self.istriggered = TRUE;
	}

	SetOwner(self, self);
	SetParent(self, self);
	self.class = CLASS_OBJECT;
	self.objclass = OBJ_TRIGGERRELAY;
	SetID(self);	
	SetObjectAppearance(self, OBJ_TRIGGERRELAY, self.variant);
	self.effects = self.effects | EF_NODEPTHTEST;
//	SetAndPrecacheModel(self, "");
	MakeObjectInvisibleToClients(self);
	self.SendEntity = SendObject;
	self.TriggerFunc = TriggerTriggerRelay;
	if(self.touchtrigger)
	{
		self.solid = SOLID_TRIGGER;
		self.touch = TriggerRelayTouch;
	}
	else
	{
		self.solid = SOLID_NOT;
		self.touch = SUB_Null;
	}
	ObjectChain_Add(self);
	InitializeObjectOrientation(self);		
}