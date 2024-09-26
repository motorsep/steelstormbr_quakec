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
string		REVISION	= "v2.00.02904";
float		EPISODE		= 2;
float		missioneditorenabled	= TRUE;

float		PROFILE_FILEVERSION_CURRENT = 1.1;

float		TEAMS_MAX = 2;

float		skiptranslation;
float		filetextline;
float		filetextline_old;
float		menu_initializing;

float		LOADINGFROMEPISODE;
float		OPTION_EPISODE_MIN;

float		CODEBASE;
float		SERVERCODE	= 0;
float		CLIENTCODE	= 1;
float		MENUCODE	= 2;

float		singleplayer;
float		gamemode;
float		allowvoting;
float		alloweditorinmultiplayer;

float		GAMEMODE_CAMPAIGN	= 0;
float		GAMEMODE_DEATHMATCH = 1;
float		GAMEMODE_CTF		= 2;

float		ITEMSMODE_BASIC		= 0;
float		ITEMSMODE_EARNED	= 1;

.entity		chain;

void		SUB_Null() = {};

string		SEP_QUOTE	= "\"";
string		SEP_SPACE	= " ";
string		SEP_COLON	= ":";
string		SEP_EQUAL	= "=";
string		SEP_SEMI	= ";";
string		SEP_TAB		= "	";
string		SEP_A		= "…";
string		SEP_BR		= ";";//"¶";

void UpdateBindMap();
void ResetLanguageBuffers()


// player weapons
// ep 1
float		WEP1_MINIGUN			= 1;
float		WEP1_STORMPLOW			= 4;
float		WEP1_BEAMCANNON			= 64;
float		WEP1_ROCKETPOD			= 128;
// ep 2
float		WEP2_SHOCKWAVE			= 1;
float		WEP2_STORMSPREAD		= 2;
float		WEP2_STORMSHIELD		= 4;
float		WEP2_THUNDERBOLT		= 8;
float		WEP2_HOMINGMISSILES		= 16;
float		WEP2_MIRVMORTAR			= 32;
float		WEP2_FLACKGUN			= 64;
