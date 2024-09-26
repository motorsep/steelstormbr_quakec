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
float GameMode_DropPlayerItemsOnDisconnect(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;
		
	return FALSE;
}

float GameMode_RemoveDroppedItems(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return FALSE;

	return TRUE;
}

float GameMode_HasMissionProgression(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}

float GameMode_LongItemRemoveTimes(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}