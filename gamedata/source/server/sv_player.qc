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
void UpdateBindMap() =
{
	if(self.adminmode)
		stuffcmd(self, "in_bindmap 2 0\n");
	else
		stuffcmd(self, "in_bindmap 1 0\n");
}

/*void CycleSecondaryWep(float dir) =
{
	self.secondarywep += dir;
	
	if(self.secondarywep > 1)
		self.secondarywep = 0;
	else
	if(self.secondarywep < 0)
		self.secondarywep = 1;
}*/

/*void PlayerInput_Misc() =
{
	if(self.impulse == 20)
		Vote(TRUE);
	else
	if(self.impulse == 21)
		Vote(FALSE);
}*/

void PlayerInput() =
{
	local float stype0, stype1;

/*	local entity e;
	if(self.impulse == 26)
	{
		for(e = findradius(self.origin, 200); e; e = e.chain)
		{
			if(e.objclass == OBJ_NPC)
			if(!e.isdead)
				eprint(e);
		}
	}*/
	
	if(showingmissionscores)
		return;
	
/*	if(self.adminmode)
	if(self.impulse >= 53 && self.impulse <= 56)
	{
		local entity e;
		local vector ofs;
		local float movedist;
		movedist = cvar("editor_shiftobjdist");
		
		for(e = list_objectchain; e; e = e.objectchain)
		{
			if(self.impulse == 53)
				ofs_y = movedist;
			else
			if(self.impulse == 54)
				ofs_y = -movedist;
			else
			if(self.impulse == 55)
				ofs_x = -movedist;
			else
			if(self.impulse == 56)
				ofs_x = movedist;
			
			e.origin_base = e.origin_base+ofs;
			setorigin(e, e.origin_base);
		}
		
		server_bottleneck_ent = list_objectchain;
	
	}*/

	local float buttonwasdown;

/*	if(self.impulse == 99)
	{
		self.godmode = !self.godmode;
		
		if(self.godmode)
			print("GODMODE ON\n");
		else
			print("GODMODE OFF\n");
	}
	
	if(self.impulse == 25)
	{
		if(pauseai)
		{
			bprint("AI Unpaused\n");
			ClearCellPattern();
		}
		else
			bprint("AI Paused\n");
			
		pauseai = !pauseai;
	}*/

	if(!self.adminmode)
	if(!(self.health <= 0))
	{
		local float WEP1, WEP2;
	
	//	if(self.impulse >= 1)
	//	if(self.impulse <= 2)
	//		self.secondarywep = self.impulse-1;
			
		if(self.impulse == 10)
		{
			stype0 = HasSecondaryType(self, 0);
			stype1 = HasSecondaryType(self, 1);
			if(stype0 && stype1)
				self.secondarywep = !self.secondarywep;
		}
			
/*		if(self.impulse == 6)
		{
			if(self.spreadmode < 2)
				self.spreadmode++;
			else
				self.spreadmode = 0;
		}		*/
			
	/*	if(self.impulse == 10)
			CycleSecondaryWep(-1);
		else
		if(self.impulse == 11)
			CycleSecondaryWep(1);*/
			
		if(self.button0)// || self.button7)
		{
			WEP1 = self.items1 & WEP1_MINIGUN;
			WEP2 = self.items2 & WEP2_FLACKGUN;
			FireWeapon(WEP1, WEP2, FALSE, 1);
			
			WEP1 = self.items1 & WEP1_STORMPLOW;
			WEP2 = self.items2 & WEP2_STORMSPREAD;
			WEP2 += self.items2 & WEP2_STORMSHIELD;
			FireWeapon(WEP1, WEP2, FALSE, 1);
		}
			
//		if(self.wepdisabletime <= time)
//		{		
			if(self.button2)// || self.button7)// || self.button3)
			{
				if(self.secondarywep == 1)// && !self.button3)
				{
					WEP2 = self.items2 & WEP2_THUNDERBOLT;
					WEP1 = self.items1 & WEP1_BEAMCANNON;
					FireWeapon(WEP1, WEP2, FALSE, 1);
				}
				else
				{
					WEP1 = self.items1 & WEP1_ROCKETPOD;
					WEP2 = self.items2 & WEP2_HOMINGMISSILES;
					WEP2 += self.items2 & WEP2_MIRVMORTAR;
					FireWeapon(WEP1, WEP2, FALSE, 1);
				}
			//	if(self.secondarywep == 2)
			//		FireWeapon(self.powerup, FALSE);
			//	else
			//		FireWeapon(self.secondarywep+1, FALSE);
			}
			
	/*		if(self.button3)
			if(!self.secondarywep)
			{
				WEP = self.items & WEP_ROCKETPOD;
				WEP += self.items & WEP_HOMINGMISSILES;
				WEP += self.items & WEP_MIRVMORTAR;
				FireWeapon(WEP, FALSE);		
			}*/
			
			if(self.impulse == 4)
				FireWeapon(0, WEP2_SHOCKWAVE, FALSE, 1);
//		}
	}
	
	buttonwasdown = self.buttondown;
	
	if(self.button0)
		self.buttondown = TRUE;
	else
	{
		self.buttondown = FALSE;	
		if(buttonwasdown)
		{
			if(self.items1 & WEP1_STORMPLOW)
				SetEventFlag_Sound(self, SOUND_STORMPLOW_PLAYER_STOP);
			else
			if(self.items2 & WEP2_STORMSHIELD)
				SetEventFlag_Sound(self, SOUND_STORMSHIELD_PLAYER_STOP);
			else
			if(self.items1 & WEP1_MINIGUN)
				SetEventFlag_Sound(self, SOUND_MINIGUN_PLAYER_STOP);
		}
	}
	
}

void WeaponAutoFire(float WEP1, float WEP2) =
{
	if(WEP1 & WEP1_ROCKETPOD)
	if(self.autofiretime)
	if(self.autofiretime <= time)
	{
		FireWeapon(WEP1_ROCKETPOD, 0, TRUE, 1);
		
		if(!self.firingpos)
		{
			self.autofiretime = 0;
			self.rechargetime_powerup = time + 1;
		}
	}
}