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
string GetGameMode_String_Local(float mode, float path) =
{
	local string s, filename;
	local float translation;
	
	filename = __FUNC__;	
	translation = skiptranslation;
	
	if(path)
		skiptranslation = TRUE;
	else
		skiptranslation = FALSE;	

	buf_localizegamemode = InitializeNonstandardTranslations(buf_localizegamemode, filename, TRUE);
	
	local string str_campaign, str_deathmatch, str_ctf;
	str_campaign	= Localize("campaign", buf_localizegamemode);
	str_deathmatch	= Localize("deathmatch", buf_localizegamemode);
	str_ctf			= Localize("ctf", buf_localizegamemode);

	WriteNonstandardTranslations(buf_localizegamemode, filename, TRUE, TRUE);
	
	switch(mode)
	{
		case GAMEMODE_CAMPAIGN:		s = str_campaign;		break;
		case GAMEMODE_DEATHMATCH:	s = str_deathmatch;		break;
		case GAMEMODE_CTF:			s = str_ctf;			break;
	}
	
	skiptranslation = translation;
	
	return s;
}

string GetGameMode_String(float mode, float path) =
{
	if(LOCALIZE_GENERATING)
		return string_null;

	return GetGameMode_String_Local(mode, path);
}

float GameMode_ShowScore_Score(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}

float GameMode_ShowScore_Time_Taken(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;
		
	return FALSE;
}

float GameMode_ShowScore_TimeLeft(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}
		
float GameMode_ShowScore_TimeBonus(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}
		
float GameMode_ShowScore_Captures(float mode) =
{
	if(mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}

float GameMode_ShowScore_Returns(float mode) =
{
	if(mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}

float GameMode_ShowScore_Frags_Player(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}

float GameMode_ShowScore_Frags_AI(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN)
		return TRUE;

	return FALSE;
}

float GameMode_ShowScore_Frags_Other(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}
		
float GameMode_ShowScore_Deaths(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}
	
float GameMode_ShowScore_Suicides(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}
		
float GameMode_ShowScore_Accuracy(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}
	
float GameMode_ShowScore_Damage_Dealt(float mode) =
{
	if(mode == GAMEMODE_CAMPAIGN
	|| mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;

	return FALSE;
}		
		
float GameMode_PlayerVSPlayer(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH
	|| mode == GAMEMODE_CTF)
		return TRUE;
		
	return FALSE;
}

float GameMode_HasFlags(float mode) =
{
	if(mode == GAMEMODE_CTF)
		return TRUE;
		
	return FALSE;
}

float GameMode_HasTeams(float mode) =
{
	if(mode == GAMEMODE_CTF)
		return TRUE;
		
	return FALSE;
}

float GameMode_HasFragLimit(float mode) =
{
	if(mode == GAMEMODE_DEATHMATCH)
		return TRUE;
		
	return FALSE;	
}

float GameMode_AllowMinPlayers(float mode) =
{

	return FALSE;
}