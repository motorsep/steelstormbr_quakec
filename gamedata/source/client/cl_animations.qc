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
void destroyer_tank_shoot1() =
{
	NextFrame('61 72 12', destroyer_tank_shoot1);
	
	if(self.frame == 61)
	{
		self.skin = 1;
		sound(self, CHAN_WEAPON, "sounds/enemies/destroyer/ss_destroyer_cannon_charge.wav", 1, ATTN_NORM);
	}
	else
	if(self.frame == 65)
		self.skin = 2;
	else
	if(self.frame == 69)
		self.skin = 3;	
}

void destroyer_tank_shoot2() =
{
	NextFrame('73 84 12', destroyer_tank_shoot2);
	
	if(self.frame == 73)
		self.skin = 4;
	else
	if(self.frame == 84)
		self.skin = 0;
}

void terminal_operating() =
{
	NextFrame('31 60 24', terminal_operating);
}

void terminal_open() =
{	
	NextFrame('2 30 64', terminal_open);
	
	if(self.frame >= 30)
		self.AnimFunc = terminal_operating;
}

void terminal_close() =
{
	PreviousFrame('2 30 24', terminal_close);

	if(self.frame == 2)
	{
		if(self.istoggled)
		if(self.requireskey)
			self.skin = 3;
		else
			self.skin = 2;	
			
		self.AnimFunc = anim_movement;
	}
}

void portal_idle_opened() =
{
	NextFrame('26 37 10', portal_idle_opened);
}

void portal_idle_closed() =
{
	NextFrame('1 12 10', portal_idle_closed);
}

void portal_open() =
{
	NextFrame('14 25 10', portal_open);
	
	if(self.frame >= 24)
		self.AnimFunc = portal_idle_opened;
}

void portal_close() =
{
//	PreviousFrame('13 24 10', portal_close);
	NextFrame('38 49 10', portal_close);
	
	if(self.frame == 13)
		self.AnimFunc = portal_idle_closed;
}