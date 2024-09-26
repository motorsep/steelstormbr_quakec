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
void ResetLanguageBuffers() =
{
	local float count;
	local entity e;

	ResetGlobalLanguageBuffers();
	ResetSharedClientMenuLanguageBuffers();
	ResetMenuLanguageBuffers();
	
	DeleteBuffer(buf_localizehudmissionstats);
	buf_localizehudmissionstats = 0;
	
	DeleteBuffer(buf_localizeobjectivetext);
	buf_localizeobjectivetext = 0;

	DeleteBuffer(buf_localizeobjectives);
	buf_localizeobjectives = 0;
	
	DeleteBuffer(buf_localizecenterprintmessages);
	buf_localizecenterprintmessages = 0;	
	
	DeleteBuffer(buf_localizemultiplekill);
	buf_localizemultiplekill = 0;
	
	DeleteBuffer(buf_localizeterminal);
	buf_localizeterminal = 0;	

	DeleteBuffer(buf_localizeadminplayerlist);
	buf_localizeadminplayerlist = 0;	
	
	DeleteBuffer(buf_localizeobjectnames);
	buf_localizeobjectnames = 0;
	
	DeleteBuffer(buf_localizemapkey);
	buf_localizemapkey = 0;
	
	DeleteBuffer(buf_localizevotestats);
	buf_localizevotestats = 0;
	
	DeleteBuffer(buf_localizescorestats);
	buf_localizescorestats = 0;	
	
	for(e = list_objectivechain; e; e = e.objectivechain)
		ClearObjectiveBuffers(e);

	SH_RemoveEnt(objectiveblock);
	objectiveblock = world;
}