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
float	buf_localizechallenges;
float	buf_localizemenuinputwarnings;

void ClearObjectiveBuffers(entity e) =
{
	local float count, buf;

	for(count = 0; count < 20; count++)
	{
		buf = e.(buf_textblock_objectives_primary[count]);
		if(buf)
		{
			DeleteBuffer(buf);
			e.(buf_textblock_objectives_primary[count]) = 0;
		}
		
		buf = e.(buf_textblock_objectives_secondary[count]);
		if(buf)
		{
			DeleteBuffer(buf);		
			e.(buf_textblock_objectives_secondary[count]) = 0;
		}
	}	
}

void ResetMenuLanguageBuffers() =
{
	local entity e;

	for(e = list_menuchain; e; e = e.menuchain)
	{
		e.menusize = '0 0 0';	// reinitializes the menu			THIS BREAKS CLIENT MENUS
		DeleteBuffer(e.buf_translation);
		e.buf_translation = 0;
		DeleteBuffer(e.buf_textblock);
		e.buf_textblock = 0;
		ClearObjectiveBuffers(e);
	}
}

void ResetSharedClientMenuLanguageBuffers() =
{
	DeleteBuffer(buf_localizechallenges);
	buf_localizechallenges = 0;
	
	DeleteBuffer(buf_localizemenuinputwarnings);
	buf_localizemenuinputwarnings = 0;
}