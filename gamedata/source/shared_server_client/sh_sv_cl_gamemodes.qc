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
float GameMode_HideTeleporters(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}

float GameMode_CanSpawnEnemies(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}

float GameMode_PlayerHasLives(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
	if(singleplayer)
		return TRUE;

	return FALSE;
}

float GameMode_AlwaysCarryWeaponsToNextMap(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;
		
	return FALSE;
}

/*float GameMode_AlwaysResetItemsOnRespawn(float mode) =
{

	return FALSE;
}*/

float GameMode_RespawningPickups(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}

float GameMode_HasRespawnTime(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;
		
	return FALSE;
}

float GameMode_ShowPickupsOnMap(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;
		
	return FALSE;
}

float GameMode_NoFriendlyPlayers(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH)
		return TRUE;

	return FALSE;
}