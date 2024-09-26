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
/*void UpdateRadar() =
{
	local entity e;
	local float RADAR_RANGE;
	RADAR_RANGE = 2500;

	if(self.radarupdatetime > time)
		return;
		
	self.radarupdatetime = time + 0.5;

	msg_entity = self;
	WriteByte(MSG_ONE, SVC_TEMPENTITY);
	WriteByte(MSG_ONE, TE_RADARUPDATE);
	
	e = findradius(self.origin, RADAR_RANGE);
	while(e)
	{
		if(e.class == CLASS_NPC)
		{
			WriteShort(MSG_ONE, e.id);
			WriteCoord(MSG_ONE, e.origin_x);
			WriteCoord(MSG_ONE, e.origin_y);
		}
		e = e.chain;
	}
	
	WriteShort(MSG_ONE, 0);
}*/