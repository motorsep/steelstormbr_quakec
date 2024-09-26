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
void GetClientStats() =
{
	local float getstatflags, file, numepisode, clientitems1, clientitems2;
	local string playername, filename, line;
	local vector playercolors;

	#ifdef COMPILE_SERVICE_ONLIVE
		playername = "player";
	#else
		playername = ReadString();	
	#endif
	
	getstatflags = ReadLong();
	
	filename = strcat("profiles/_", uri_escape(playername));
	filename = strcat(filename, ".profile");

	file = FileOpen(filename, FILE_READ);	

	if(file == -1)
		line = ("cmd items 1 1 0\n");
	else
	{
		for(line = fgets(file); line && line != "GAMEPROGRESS"; line = fgets(file))
		{
			tokenizebyseparator(line, SEP_SPACE);
			
			if(argv(0) == "COLORS")
			{
				playercolors_x = stof(argv(1));
				playercolors_y = stof(argv(2));
				playercolors_z = stof(argv(3));
			}
		/*	else
			if(argv(0) == "ITEMS")
			{
				globalitems1 = stof(argv(1));
				globalitems2 = stof(argv(2));
				break;
			}*/
		}

		if(gamemode == GAMEMODE_CAMPAIGN)
		{
			line = fgets(file);
			while(line && !clientitems1 && !clientitems2)
			{
				tokenizebyseparator(line, SEP_SPACE);
				if(argv(0) == campaign)
				{
					if(argv(1) != "EPISODE")
						clientitems1 = stof(argv(1));
					else
					{
						numepisode = stof(argv(2));
						clientitems1 = stof(argv(3));
						if(numepisode >= 2)
							clientitems2 = stof(argv(4));
					}
					
					break;
				}
				
				if(!clientitems1 && !clientitems2)
					line = fgets(file);
			}
		}
	//	else
	//	{
	//		clientitems1 = globalitems1;
	//		clientitems2 = globalitems2;
	//	}

		if(!numepisode)
			numepisode = 1;
		
		fclose(file);
		
		line = string_null;
		
		if(getstatflags & GSF_COLORS)
		{
			line = strcat(line, "cmd playercolors ");
			line = strcat(line, ftos(playercolors_x));
			line = strcat(line, " ");
			line = strcat(line, ftos(playercolors_y));
			line = strcat(line, " ");
			line = strcat(line, ftos(playercolors_z));
			line = strcat(line, ";");
		}
			
		if(getstatflags & GSF_ITEMS)
		{
			line = strcat(line, "cmd items ", ftos(numepisode), " ");
			line = strcat(line, ftos(clientitems1));
			if(numepisode >= 2)
				line = strcat(line, " ", ftos(clientitems2));
		//	line = strcat(line, " ");
		//	line = strcat(line, ftos(globalitems1)); 
		//	line = strcat(line, " ", ftos(globalitems2));	
			line = strcat(line, ";");
		}
	}

	if(line)
		localcmd(line);	
	
	client_initialized = true;			
}

float connection_initialized;
void Connection_Init() =
{
	local float mode, count;
	local string s;

	UpdateBindMap();	

//	deathmatch = false;
//	coop = false;
	
	mission_locked = ReadByte();
	gamemode = ReadByte();
	teamplay = ReadByte();
	singleplayer = ReadByte();	
	maxplayers = ReadLong();
	allowvoting = ReadByte();
	publicguesteditoraccess = ReadByte();
	fraglimit = ReadLong();
	capturelimit = ReadLong();
	
	campaign = zonecpy(campaign, ReadString());
	mission = zonecpy(mission, ReadString());	
	
	world_fog = zonecpy(world_fog, ReadString());
	
	s = ReadString();
	tokenize(s);
	for(count = 0; count < NUMLANGUAGES; count++)
	{
		s = mission_briefing[count];
		s = zonecpy(s, argv(count));
		mission_briefing[count] = s;
	}
	
	alloweditorinmultiplayer = ReadByte();
	
	s = AppendToken("menu_cmd game_init", SEP_SPACE, ftos(gamemode));
	s = AppendToken(s, SEP_SPACE, ftos(singleplayer));
	s = AppendToken(s, SEP_SPACE, ftos(maxplayers));
	s = AppendToken(s, SEP_SPACE, ftos(alloweditorinmultiplayer));

	if(!connection_initialized)
	{
		if(cvar("chase_lockyaw"))
			s = strcat(s, "; cmd lockcamera 1");
		
		if(!singleplayer)
		if(maxplayers == 1)
			s = strcat(s, "; cmd missioneditor");	
	}
	
	s = strcat(s, "\n");
	
	localcmd(s);	
	
	if(singleplayer)
	{
		timestopped = true;
		ToggleMissionBriefing();
	}		
	
	connection_initialized = true;
}

void Effect_Init() =
{
	linklineimage						= "gfx/gui/link_line.tga";

	PEF_PLAYER_BUTTONCHAT				= particleeffectnum("TE_PLAYER_BUTTONCHAT");
	
	PEF_MINIGUN_TRACE					= particleeffectnum("TE_MINIGUN_TRACE");
	PEF_MINIGUN_MUZZLEFLASH				= particleeffectnum("TE_MINIGUN_MUZZLEFLASH");
	PEF_MINIGUN_HIT						= particleeffectnum("TE_MINIGUN_HIT");
	PEF_MINIGUN_SHELLEJECT				= particleeffectnum("TE_MINIGUN_SHELLEJECT");
	PEF_FLACKGUN_TRACE					= particleeffectnum("TE_FLACKGUN_TRACE");
	PEF_FLACKGUN_MUZZLEFLASH			= particleeffectnum("TE_FLACKGUN_MUZZLEFLASH");
	PEF_FLACKGUN_HIT					= particleeffectnum("TE_FLACKGUN_HIT");
	PEF_FLACKGUN_SHELLEJECT				= particleeffectnum("TE_FLACKGUN_SHELLEJECT");	
	PEF_BEAMCANNON_TRACE				= particleeffectnum("TE_BEAMCANNON_TRACE");
	PEF_BEAMCANNON_MUZZLEFLASH			= particleeffectnum("TE_BEAMCANNON_MUZZLEFLASH");
	PEF_BEAMCANNON_HIT					= particleeffectnum("TE_BEAMCANNON_HIT");
	PEF_TURRETBEAM_TRACE				= particleeffectnum("TE_TURRETBEAM_TRACE");
	PEF_TURRETBEAM_MUZZLEFLASH			= particleeffectnum("TE_TURRETBEAM_MUZZLEFLASH");
	PEF_TURRETBEAM_HIT					= particleeffectnum("TE_TURRETBEAM_HIT");	
	PEF_TURRETBEAM_SMOKE				= particleeffectnum("TE_TURRETBEAM_SMOKE");
	PEF_DESTROYERBEAM_TRACE				= particleeffectnum("TE_DESTROYERBEAM_TRACE");
	PEF_DESTROYERBEAM_MUZZLEFLASH		= particleeffectnum("TE_DESTROYERBEAM_MUZZLEFLASH");
	PEF_DESTROYERBEAM_HIT				= particleeffectnum("TE_DESTROYERBEAM_HIT");
	PEF_SPREAD_MUZZLEFLASH				= particleeffectnum("TE_SPREAD_MUZZLEFLASH");
	PEF_SPREAD_HIT						= particleeffectnum("TE_SPREAD_HIT");
	PEF_THUNDERBOLT						= particleeffectnum("TE_THUNDERBOLT");
	PEF_THUNDERBOLT_MUZZLEFLASH			= particleeffectnum("TE_THUNDERBOLT_MUZZLEFLASH");
	PEF_THUNDERBOLT_HIT					= particleeffectnum("EF_ELECTRO_IMPACT_PLAYER");
	PEF_LIGHTNINGBOLT_HIT				= particleeffectnum("EF_ELECTRO_IMPACT_ENEMY");
	PEF_REPAIR_TRACE					= particleeffectnum("TE_REPAIR_TRACE");
	PEF_REPAIR_MUZZLEFLASH				= particleeffectnum("TE_REPAIR_MUZZLEFLASH");
	PEF_REPAIR_HIT						= particleeffectnum("TE_REPAIR_HIT");
	PEF_PROTON_HIT						= particleeffectnum("TE_PROTON_HIT");
	PEF_HEAVYTANK_MINIGUN_TRACE			= particleeffectnum("TE_HEAVYTANK_MINIGUN_TRACE");
	PEF_HEAVYTANK_MINIGUN_MUZZLEFLASH	= particleeffectnum("TE_HEAVYTANK_MINIGUN_MUZZLEFLASH");
	PEF_HEAVYTANK_MINIGUN_HIT			= particleeffectnum("TE_HEAVYTANK_MINIGUN_HIT");	
	
	PEF_JETS_IDLE						= particleeffectnum("TE_JETFLAME_IDLE");
	PEF_JETS_MOBILE						= particleeffectnum("TE_JETFLAME_MOBILE");
	PEF_WINGTRAIL						= particleeffectnum("TE_WINGTRAIL");
	
	PEF_MISSILE_EXHAUST					= particleeffectnum("TE_MISSILE_EXHAUST");
	PEF_MISSILE_SMOKE					= particleeffectnum("TE_MISSILE_SMOKE");
	
	PEF_SHOCKWAVE						= particleeffectnum("TE_SHOCKWAVE");
	
	PEF_SPAWNCHARGE_SMALL				= particleeffectnum("TE_SPAWNCHARGE_SMALL");
	PEF_SPAWNCHARGE_MEDIUM				= particleeffectnum("TE_SPAWNCHARGE_MEDIUM");
	PEF_SPAWNCHARGE_SMALL_EXPLODE		= particleeffectnum("TE_SPAWNCHARGE_SMALL_EXPLODE");
	PEF_SPAWNCHARGE_MEDIUM_EXPLODE		= particleeffectnum("TE_SPAWNCHARGE_MEDIUM_EXPLODE");	
	
	PEF_PATHCONNECTIONLINE				= particleeffectnum("TE_PATHCONNECTIONLINE");
	PEF_PATHCONNECTIONLINETEMP			= particleeffectnum("TE_PATHCONNECTIONLINETEMP");
	PEF_PATHCONNECTIONLINETRANSFER		= particleeffectnum("TE_PATHCONNECTIONLINETRANSFER");
	PEF_PATHCONNECTIONLINESELECTEDGROUP	= particleeffectnum("TE_PATHCONNECTIONLINESELECTEDGROUP");
	PEF_PATHCONNECTIONLINESELECTEDGROUPTRANSFER	= particleeffectnum("TE_PATHCONNECTIONLINESELECTEDGROUPTRANSFER");	
	PEF_PATHCONNECTIONLINEFORAI			= particleeffectnum("TE_PATHCONNECTIONLINEFORAI");
	
	PEF_ENTITY_DAMAGE_SMOKE				= particleeffectnum("EF_ENTITY_DAMAGE_SMOKE");
	PEF_ENTITY_DAMAGE_SMOKE_MED			= particleeffectnum("EF_ENTITY_DAMAGE_SMOKE_MED");
	PEF_ENTITY_DAMAGE_SMOKE_LARGE		= particleeffectnum("EF_ENTITY_DAMAGE_SMOKE_LARGE");

	PEF_ENTITY_DAMAGE_BURN				= particleeffectnum("EF_ENTITY_DAMAGE_BURN");
	PEF_ENTITY_DAMAGE_BURN_MED			= particleeffectnum("EF_ENTITY_DAMAGE_BURN_MED");
	PEF_ENTITY_DAMAGE_BURN_LARGE		= particleeffectnum("EF_ENTITY_DAMAGE_BURN_LARGE");	
	
	PEF_ENTITY_EFFECT_STUN				= particleeffectnum("EF_ELECTRO_IMPACT_STUN");
	PEF_ENTITY_EFFECT_WEPDISABLE		= particleeffectnum("EF_ELECTRO_IMPACT_WEPDISABLE");
}

/*void Key_Init() =
{
	CTRL_ATTACK				= BTTN_MOUSE2;
	CTRL_BLOCK				= BTTN_MOUSE1;
	CTRL_MOUSEPRIMARY		= BTTN_MOUSE1;
	CTRL_MOUSESECONDARY		= BTTN_MOUSE2;
	CTRL_TOGGLEHUD			= 104;	// H
	CTRL_TOGGLEINVENTORY	= KEY_TAB;
	CTRL_TOGGLESHORTCUTBAR	= 116;	// T
	CTRL_TOGGLEADMINTOOLS	= 109;	// M
	CTRL_CLOSECONTAINERS	= 98;	// B
//	CTRL_TOGGLEEQUIPMENT	= KEY_TAB;
	CTRL_MOUSECURSOR		= KEY_SHIFT;
	CTRL_MOVEFORWARD		= 119;	// W
	CTRL_MOVEBACK			= 115;	// S
	CTRL_MOVELEFT			= 97;	// A
	CTRL_MOVERIGHT			= 100;	// D
	CTRL_MOVEUP				= 114;	// R
	CTRL_MOVEDOWN			= 102;	// F
	CTRL_JUMP				= KEY_SPACE;
}*/

/*void Color_Init() =
{
	COLOR_SELECTION					= COLOR_RED;//HIGHLIGHT;
	COLOR_MENU_BACKGROUND			= COLOR_DARKGREY;
	COLOR_MENU_TITLE				= COLOR_DEFAULT;
	COLOR_MENU_CATEGORY				= COLOR_RUST;
	COLOR_MENU_TEXT					= COLOR_DEFAULT;
	COLOR_HUD_TEXT					= COLOR_RUST;
	COLOR_HUD_INFO					= COLOR_DEFAULT;
	COLOR_CHAT_OTHER				= COLOR_DEFAULT;
	COLOR_CHAT_SELF					= COLOR_GREY;
	COLOR_CHAT_INFO					= COLOR_YELLOW;
	COLOR_CHAT_INPUT				= COLOR_DEFAULT;
	COLOR_INVENTORY_TEXT			= COLOR_RUST;
	COLOR_SHORTCUT_TEXT				= COLOR_DEFAULT;
	COLOR_PULLDOWN_SELECTED			= COLOR_BLOOD;
	COLOR_PULLDOWN_UNSELECTED		= COLOR_BLACK;
	COLOR_PULLDOWN_TEXT				= COLOR_DEFAULT;
	COLOR_PULLDOWN_TEXT_UNAVAILABLE	= COLOR_GREY;
}*/

/*void Font_Init() =
{
	FONTSIZE_MENU 			= '6 6 0';
	FONTSIZE_MENU_TITLE		= '5 5 0';
	FONTSIZE_BUTTON_LARGE	= '8 8 0';
	FONTSIZE_BUTTON_SMALL	= '6 6 0';
	FONTSIZE_HUD			= '6 6 0';
	FONTSIZE_CHAT			= '5 5 0';
	FONTSIZE_CHAT_INPUT		= '6 6 0';
	FONTSIZE_INVENTORY		= '5 5 0';
	FONTSIZE_SHORTCUT		= '4 4 0';
	FONTSIZE_PULLDOWN		= '6 6 0';
}*/

/*void Menu_Init() =
{
//	dragshortcut = -1;

	SHOWHUD_HUD = true;
	SHOWHUD_ADMINTOOLS = false;
	
	titlethickness = FONTSIZE_MENU_TITLE_y + 1;
	borderspace = 5.85;
	BORDERSPACE_PULLDOWN = 2;
	linespace = 2;

	ALPHA_MENU = 0.8;
	ALPHA_HUD = 0.8;
	ALPHA_CHAT = 0.8;	
	ALPHA_PULLDOWN = 1;
}*/

void Waypoint_Init() =
{
	WAYPOINT_OFS			= '0 0 12';
}
