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
void SH_MenuControls() =	{}
void SH_PreMenuControls() =	{}

float	uri_get(string url, float id) = #513;
void	drawline(float width, vector pos1, vector pos2, vector rgb, float alpha, float flags) = #466;
string	(string format, ...) sprintf = #627;

float		updatesavailable;

// dpextensions
string(string s) strtolower = #480; // returns the passed in string in pure lowercase form
string(string s) strtoupper = #481; // returns the passed in string in pure uppercase form
string(string in) uri_escape = #510;
string(string in) uri_unescape = #511;

//vector		updateconsizeforres;

//void ToggleESCMenu() =	{	m_toggle();	}

//float CursorInsideBox(vector pos, float width, float height) =	{	return SH_CursorInsideBox(pos, width, height);	}

float		mission_finished;

float		gametype;
float		GAMETYPE_SINGLEPLAYER			= 1;
float		GAMETYPE_MULTIPLAYER			= 2;
float		GAMETYPE_HOSTMULTIPLAYER		= 3;
float		GAMETYPE_OFFLINEMISSIONEDITOR	= 4;

string		profile_active;
string		profile_active_filename;
float		campaign_active;
float		missionid;
string		mission_map;

float		maxplayers;
//float		coop;
//float		deathmatch;
float		missioneditor_enabled;
float		requestingjoinpassword;

float		OBJ_OBJECTIVE = 13;
.float		buf_objectives_primary;
.float		buf_objectives_secondary;


/*entity		list_serverchain;
.entity		serverchain;
.entity 	serverchain_prev;*/

/*.string 	host_campaign;
.string		host_mission;
.string		host_mode;
.string		host_name;	
.string		host_map;
.string		host_mod;
.float		host_ping;
.float		host_numplayers;
.float		host_maxplayers;*/

float		fullscreenserverlist;

string		filter_serverlist_hostname;
string		filter_serverlist_mod;
string		filter_serverlist_campaign;
string		filter_serverlist_mission;
string		filter_serverlist_episode;

float		refreshhostcachetime;

float		serverlist_sortorder;
float		serverlist_sortby;

.string		host_name;
.float		host_episode;
.string		host_campaign;
.string		host_mission;
.string		host_map;
.string		host_mod;
.string		host_mode;
.string		host_skill;
.float		host_ping;
.float		host_numplayers;
.float		host_maxplayers;
.float		host_minplayers;
.string		host_address;

.float		editingcampaign;

float	quitalpha;

void PreserveSystemSettings();
void RestoreSystemSettings(float applynewsettings);
void SpawnMainMenu();
//void SliderRules();
void Call_CampaignMenu();
void Call_MissionMenu_NonTiered(string pathstring, float filenamenum, float editingcampaignval);
void Call_MissionMenu(float editingcampaignval);
//void Call_MissionMenu_Coop(float editingcampaignval);
void Call_MissionMenu_Campaign(float editingcampaignval);
void Call_ProfileMenu();
void SetName();
void ListOption_Mission(float count);
void Call_ControlsMenu_Player();
void Call_ControlsMenu_Misc();
void Call_ControlsMenu_Editor();
void Call_ControlsMenu_Input();
void Call_MultiPlayerMenu();
void SetGameMode_Campaign();
void SetGameMode_Deathmatch();
void SetGameMode_CTF();
void SetGameTypeOfflineMissionEditor();
void Call_MapMenu();
void GetCampaignList();
void GetDeathmatchMissionList();
void GetCTFMissionList();
void Call_SystemOptions();
void Call_SoundOptions();
//void Call_ControlsMenu();


// credits

float		buf_credits;
vector 		menucredits_scrollpos;


// scenes

float		game_intro_playing;
float		game_intro_starttime;
float		buf_scenetext;
float		drawscene_stage;


//system

float		resetresolutiontime;
vector		vid_res_safe;

void ApplyVideoSettings(float needsconfirmation);


// unlocks

float	unlocked_fpscamera;

// controls

float	settingkeybind;


// menus

entity	menu_main;

void GetMOTD();