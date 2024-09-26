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
void ServerListESCFunc() =
{
	refreshhostcachetime = 0;

	CloseMenu();
	SpawnMainMenu();
	if(collapsemenusonaction)
		return;	
	currentmenu.user_current_selection = 2;	
	Call_MultiPlayerMenu();
//	filter_serverlist_hostname = freezone(filter_serverlist_hostname);
}

void SortServerList(string key, float sortby) =
{
	if(sortby == serverlist_sortby)
	{
		serverlist_sortorder++;
		if(serverlist_sortorder > 1)
		{
			serverlist_sortorder = 0;
			serverlist_sortby = 0;
			sethostcachesort(0, 0);
			resorthostcache();
			return;
		}
	}
	else
		serverlist_sortby = sortby;
		
	sethostcachesort(gethostcacheindexforkey(key), serverlist_sortorder);
	resorthostcache();
}

void ServerListFilter(string key, string filtertext, float mask) =
{
	sethostcachemaskstring(mask, gethostcacheindexforkey(key), filtertext, SLIST_TEST_CONTAINS);
	resorthostcache();
	CloseMenu();
}

void Draw_ServerListFilter(string title, string text, void() func_confirm, void() func_clear) =
{
	local string s;

	Menu_Start_ConfirmationMenu("Filter", '300 0 0', __FUNC__);
	
	local string str_hostname, str_mod, str_campaign, str_mission, str_episode;
	
	str_hostname	= Translate("Filter Host Name");
	str_mod			= Translate("Filter Mod");
	str_campaign	= Translate("Filter Campaign");
	str_mission		= Translate("Filter Mission");
	str_episode		= Translate("Filter Episode");
	
	switch(title)
	{
		case "HOSTNAME":	s = str_hostname;		break;
		case "MOD":			s = str_mod;			break;
		case "CAMPAIGN":	s = str_campaign;		break;
		case "MISSION":		s = str_mission;		break;
		case "EPISODE":		s = str_episode;		break;
	}
	
	s = strcat(s, ":");
	
	skiptranslation = true;
	Menu_AlignedText(s, ALIGN_LEFT);
	skiptranslation = false;
	Menu_Input_All('200 0 0', text, ALIGN_RIGHT, 0, func_confirm);	
	
	BeginBottomButtons(3);
	DrawElement_BottomButton("Set", func_confirm, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Clear", func_clear, 0, 0, 0, 0, MBT_BASIC);		
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void ServerListFilter_Name() =	{	ServerListFilter("name", filter_serverlist_hostname, 0);	}

void SetServerListFilter_Name() =
{
	filter_serverlist_hostname = zonecpy(filter_serverlist_hostname, GetBufferString(active_menu.buf_list, input_current-1));
	ServerListFilter_Name();
}

void ClearFilter_ServerList_Name() =
{
	filter_serverlist_hostname = freezone(filter_serverlist_hostname);
	ServerListFilter_Name();
}

void Draw_ServerListFilter_Name() =	{	Draw_ServerListFilter("HOSTNAME", filter_serverlist_hostname, SetServerListFilter_Name, ClearFilter_ServerList_Name);	}

void SortServerList_Name() =
{
	SetCurrentMenu(Draw_ServerListFilter_Name);
	active_input = 1;	
}

void SortServerList_Mode() =	{	SortServerList("qcstatus", 2);	}

void SortServerList_Ping() =	{	SortServerList("ping", 3);	}

void ServerListFilter_Mod() =	{	ServerListFilter("mod", filter_serverlist_mod, 0);	}

void SetServerListFilter_Mod() =
{
	filter_serverlist_mod = zonecpy(filter_serverlist_mod, GetBufferString(active_menu.buf_list, input_current-1));
	ServerListFilter_Mod();
}

void ClearFilter_ServerList_Mod() =
{
	filter_serverlist_mod = freezone(filter_serverlist_mod);
	ServerListFilter_Mod();
}

void Draw_ServerListFilter_Mod() =	{	Draw_ServerListFilter("MOD", filter_serverlist_mod, SetServerListFilter_Mod, ClearFilter_ServerList_Mod);	}

void SortServerList_Mod() =
{
	SetCurrentMenu(Draw_ServerListFilter_Mod);
	active_input = 1;	
}

void ServerListFilter_Campaign() =	{	ServerListFilter("qcstatus", ConvertToQCStatusString(filter_serverlist_campaign, QCSF_CAMPAIGN), 0);	}

void SetServerListFilter_Campaign() =
{
	filter_serverlist_campaign = zonecpy(filter_serverlist_campaign, GetBufferString(active_menu.buf_list, input_current-1));
	ServerListFilter_Campaign();
}

void ClearFilter_ServerList_Campaign() =
{
	filter_serverlist_campaign = freezone(filter_serverlist_campaign);
	ServerListFilter_Campaign();
}

void Draw_ServerListFilter_Campaign() =	{	Draw_ServerListFilter("CAMPAIGN", filter_serverlist_campaign, SetServerListFilter_Campaign, ClearFilter_ServerList_Campaign);	}

void SortServerList_Campaign() =
{
	SetCurrentMenu(Draw_ServerListFilter_Campaign);
	active_input = 1;
}

void ServerListFilter_Mission() =	{	ServerListFilter("qcstatus", ConvertToQCStatusString(filter_serverlist_mission, QCSF_MISSION), 1);	}

void SetServerListFilter_Mission() =
{
	filter_serverlist_mission = zonecpy(filter_serverlist_mission, GetBufferString(active_menu.buf_list, input_current-1));
	ServerListFilter_Mission();
}

void ClearFilter_ServerList_Mission() =
{
	filter_serverlist_mission = freezone(filter_serverlist_mission);
	ServerListFilter_Mission();
}

void Draw_ServerListFilter_Mission() =	{	Draw_ServerListFilter("MISSION", filter_serverlist_mission, SetServerListFilter_Mission, ClearFilter_ServerList_Mission);	}

void SortServerList_Mission() =
{
	SetCurrentMenu(Draw_ServerListFilter_Mission);
	active_input = 1;
}

void ServerListFilter_Episode() =	{	ServerListFilter("qcstatus", ConvertToQCStatusString(filter_serverlist_episode, QCSF_EPISODE), 0);	}

void SetServerListFilter_Episode() =
{
	filter_serverlist_episode = zonecpy(filter_serverlist_episode, GetBufferString(active_menu.buf_list, input_current-1));
	ServerListFilter_Episode();
}

void ClearFilter_ServerList_Episode() =
{
	filter_serverlist_episode = freezone(filter_serverlist_episode);
	ServerListFilter_Episode();
}

void Draw_ServerListFilter_Episode() =	{	Draw_ServerListFilter("EPISODE", filter_serverlist_episode, SetServerListFilter_Episode, ClearFilter_ServerList_Episode);	}

void SortServerList_Episode() =
{
	SetCurrentMenu(Draw_ServerListFilter_Episode);
	active_input = 1;
}

void SortServerList_Map() =	{	SortServerList("map", 7);	}

void SortServerList_Players() =	{	SortServerList("numplayers", 8);	}

void ServerListText(vector slist_option_start, float xpos, string text) =
{
	option_pos = slist_option_start;
	option_pos_x += xpos;
	Menu_AlignedText(text, ALIGN_LEFT);
}

/*void SetSmallServerList() =
{
	currentmenu.user_current_option = 8;
	arrowkeymovement = TRUE;	
	fullscreenserverlist = false;
	currentmenu.ESCFunc = ServerListESCFunc;
	ResetScrollingWindow();
}*/

/*void SetFullScreenServerList() =
{
	currentmenu.user_current_option = 0;
	arrowkeymovement = TRUE;	
	fullscreenserverlist = true;
	currentmenu.ESCFunc = SetSmallServerList;
}*/

void ForceRefreshHostCache() =
{
	refreshhostcachetime = time + 30;
	refreshhostcache();
}

void RefreshHostCache() =
{
	if(time < refreshhostcachetime)
		return;
		
	ForceRefreshHostCache();
}

void JoinServerCloseFunc() =
{
	currentmenu.host_mode		= freezone(currentmenu.host_mode);
	currentmenu.host_skill		= freezone(currentmenu.host_skill);
	currentmenu.host_campaign	= freezone(currentmenu.host_campaign);
	currentmenu.host_mission	= freezone(currentmenu.host_mission);

	currentmenu.host_name		= freezone(currentmenu.host_name);	
	currentmenu.host_map		= freezone(currentmenu.host_map);
	currentmenu.host_mod		= freezone(currentmenu.host_mod);

	currentmenu.host_ping		= 0;
	currentmenu.host_numplayers	= 0;
	currentmenu.host_maxplayers	= 0;
	currentmenu.host_minplayers = 0;
	
	currentmenu.host_address 	= freezone(currentmenu.host_address);
	
//	CloseMenu();
}

void JoinServer(string address) =
{
	cvar_set("episode", ftos(EPISODE));
	cvar_set("gameversion", ftos(EPISODE));
	cvar_set("chase_fpscam", ftos(unlocked_fpscamera));
	
	local string s;
	SetName();
	s = strcat("connect ", address);
	s = strcat(s, "\n");
	localcmd(s);
	
//	collapsemenusonaction = true;
//	JoinServerESCFunc();
//	CloseMenu();
//	ServerListESCFunc();
//	collapsemenusonaction = false;

	m_hide();
}

void JoinSelectedServer() =	{	JoinServer(active_menu.host_address);	}

void JoinManualServer() =
{
	local string ip, port, s;

	if(InvalidInputString(0))
		return;

	if(InvalidInputString(1))
		return;		
		
	ip = GetBufferString(active_menu.buf_list, 0);
	port = GetBufferString(active_menu.buf_list, 1);
	s = strcat(ip, ":", port);
	JoinServer(s);
}

void Draw_IPConnect() =
{
	local vector input_size;

	Menu_Start_ConfirmationMenu("Enter Address", '300 0 0', __FUNC__);

	Menu_InputWarnings();

	local string str_ip, str_port, str_connect, str_cancel;	
	str_ip			= Translate("IP Address:");
	str_port		= Translate("Port:");
	str_connect		= Translate("Connect");
	str_cancel		= Translate("Cancel");
	skiptranslation = true;

	input_size_x = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - stringwidth(str_ip, false, body_fontsize) - body_fontsize_x;
	
	Menu_AlignedText(str_ip, ALIGN_LEFT);
	Menu_Input(input_size, "", ALIGN_RIGHT, 0, JoinManualServer, INPUTTYPE_NUMERICAL);
	
	option_pos = GetLastLinePos();
	option_pos_y += 14;
	
	Menu_AlignedText(str_port, ALIGN_LEFT);
	Menu_Input(input_size, "26000", ALIGN_RIGHT, 0, JoinManualServer, INPUTTYPE_NUMERICAL);

	BeginBottomButtons(2);
	DrawElement_BottomButton(str_connect, JoinManualServer, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton(str_cancel, CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		

	skiptranslation = false;	
	Menu_End();	
}

void Call_IPConnect() =
{
	SetCurrentMenu(Draw_IPConnect);
	active_input = 1;
}

void UpdateViewServerStats(entity serverlist, entity viewserver) =
{
	viewserver.host_mode		= zonecpy(viewserver.host_mode, serverlist.host_mode);	
	viewserver.host_skill		= zonecpy(viewserver.host_skill, serverlist.host_skill);
	viewserver.host_campaign	= zonecpy(viewserver.host_campaign, TitleString(ConvertFromQCStatusString(serverlist.host_campaign, QCSF_CAMPAIGN)));
	viewserver.host_mission		= zonecpy(viewserver.host_mission, TitleString(ConvertFromQCStatusString(serverlist.host_mission, QCSF_MISSION)));
	viewserver.host_minplayers	= serverlist.host_minplayers;

	viewserver.host_name		= zonecpy(viewserver.host_name, serverlist.host_name);	
	viewserver.host_map			= zonecpy(viewserver.host_map, serverlist.host_map);
	viewserver.host_mod			= zonecpy(viewserver.host_mod, serverlist.host_mod);

	viewserver.host_ping		= serverlist.host_ping;
	viewserver.host_numplayers	= serverlist.host_numplayers;
	viewserver.host_maxplayers	= serverlist.host_maxplayers;
	
	viewserver.host_address 	= zonecpy(viewserver.host_address, serverlist.host_address);
}

void ViewServerInfo(string s, string info) =
{
	local float pos_col2, option_width_old;
	pos_col2 = 120;

	option_width_old = option_size_x;
	
	option_size_x = 120;
	Menu_AlignedText(s, ALIGN_LEFT);
	option_pos_x += pos_col2;
//	Menu_AlignedText(substring(info, 0, floor((450-body_margin_x*2-border_size_x*2-pos_col2)/body_fontsize_x)) , ALIGN_LEFT);
//	Menu_AlignedText(FitStringToWidth(info, 450-body_margin_x*2-border_size_x*2-pos_col2, body_fontsize), ALIGN_LEFT);
	option_size_x = 450-body_margin_x*2-border_size_x*2-pos_col2;
	Menu_AlignedText(info, ALIGN_LEFT);	
	option_pos_x -= pos_col2;
	option_size_x = option_width_old;
	BR();
}

void Draw_Confirm_JoinServer() =
{
	Menu_Start_OptionMenu("JOIN SERVER?", '450 0 0', __FUNC__);
	
	local string str_skill;
	
	ViewServerInfo("Host Name:", active_menu.host_name);
//	ViewServerInfo("Address:", active_menu.host_address);
	
	ViewServerInfo("Modification:", active_menu.host_mod);
	ViewServerInfo("Game Mode:", active_menu.host_mode);
	
	str_skill	= Translate("Skill:");
	
	skiptranslation = true;
	if(strlen(active_menu.host_skill))
		ViewServerInfo(str_skill, active_menu.host_skill);
	skiptranslation = false;	
		
	ViewServerInfo("Campaign:", active_menu.host_campaign);
	ViewServerInfo("Mission:", active_menu.host_mission);
	ViewServerInfo("Map:", active_menu.host_map);	

	ViewServerInfo("Address:", active_menu.host_address);	
	ViewServerInfo("Ping:", ftos(active_menu.host_ping));
	ViewServerInfo("Players:", ftos(active_menu.host_numplayers));
	Translate("Min Players");Translate("");
//	ViewServerInfo("Min Players:", ftos(active_menu.host_minplayers));
	ViewServerInfo("Max Players:", ftos(active_menu.host_maxplayers));
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Join", JoinSelectedServer, 0, 0, 0, 0, MBT_CONFIRM);	
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();		
}

void Draw_InaccessableEpisode() =
{
	local string s;
	
	Menu_Start_ConfirmationMenu("Access Denied", '0 0 0', __FUNC__);
	
	s = Translate("You cannot join this server because you have not purchased the episode that it is current running. Please purchase the necessary episode in order to join this server. Visit www.steel-storm.com for more info.");
	
	active_menu.buf_textblock = DrawTextBlock(active_menu.buf_textblock, option_pos, -1, '320 100 0', s, body_fontsize, body_fontcolor, body_fontalpha, body_fontflags);	
	BR();
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);	
	EndBottomButtons();		
	
	Menu_End();	
}

void Confirm_JoinServer() =
{
	if(active_menu.host_episode > EPISODE)
	{
		SetCurrentMenu(Draw_InaccessableEpisode);
		return;
	}
	
//	viewhost_address = zonecpy(viewhost_address, host_address);
	SetCurrentMenu(Draw_Confirm_JoinServer);
	UpdateViewServerStats(active_menu, currentmenu);
	currentmenu.CloseMenuFunc = JoinServerCloseFunc;
}

void ToggleServerListPause() =
{
	local float ispaused;
	local string s;
	
	ispaused = cvar("net_slist_pause");
	ispaused = !ispaused;
	s = strcat("net_slist_pause ", ftos(ispaused));
	s = strcat(s, "\n");
	localcmd(s);
	
	if(!ispaused)
		refreshhostcachetime = 0;
}

string GetSkillName(float skill, string str_arcade, string str_classic) =
{
	local string s;
	
	if(skill == 0)
		s = str_arcade;
	else
	if(skill == 1)
		s = str_classic;

	return s;
}

void Draw_ServerList() =
{
	local float option_width_old, ispaused, listslots, ofs, opsize, count, dist, viewservers, totalservers, slist_colpos_start, slist_colpos_campaign, slist_colpos_mission, slist_colpos_map, slist_colpos_mod, slist_colpos_mode, slist_colpos_ping, slist_colpos_numplayers, host_index_qcstatus, host_index_name, host_index_map, host_index_mod, host_index_ping, host_index_numplayers, host_index_maxplayers, host_index_address, info_pos, info_pos_host, info_size_host, info_pos_mod, info_size_mod, info_pos_episode, info_size_episode, info_pos_mode, info_size_mode, info_pos_ping, info_size_ping, info_pos_campaign, info_size_campaign, info_pos_mission, info_size_mission, info_pos_map, info_size_map, info_pos_players, info_size_players, mode, skill, nextarg;
	local string s, host_qcstatus, players;
	local vector slist_option_start, windowsize, windowstart, old_body_textbordersize, old_option_textbordersize;
	
	ispaused = cvar("net_slist_pause");
	
	Menu_Start_ESCMenu_ServerList("Servers", POS_AUTO, vid_size-'25 25 0', __FUNC__);		
	
	info_pos_host = 0;				info_size_host = 316;//532;
	info_pos += info_size_host + option_spacing;
	info_pos_mod = info_pos;		info_size_mod = 214;	
	info_pos += info_size_mod + option_spacing;	
	info_pos_mode = info_pos;		info_size_mode = 124;
	info_pos += info_size_mode + option_spacing;
	info_pos_ping = info_pos;		info_size_ping = 75;
	info_pos = 0;
	
	info_pos_episode = 0;			info_size_episode = 100;	
	info_pos += info_size_episode + option_spacing;
	info_pos_campaign = info_pos;	info_size_campaign = 214;
	info_pos += info_size_campaign + option_spacing;
	info_pos_mission = info_pos;	info_size_mission = 214;
	info_pos += info_size_mission + option_spacing;
	info_pos_map = info_pos;		info_size_map = 124;
	info_pos += info_size_map + option_spacing;
	info_pos_players = info_pos;	info_size_players = 75;	
	info_pos = 0;
	
	host_index_qcstatus		= gethostcacheindexforkey("qcstatus");
	host_index_name 		= gethostcacheindexforkey("name");
	host_index_map 			= gethostcacheindexforkey("map");
	host_index_mod 			= gethostcacheindexforkey("mod");
	host_index_ping 		= gethostcacheindexforkey("ping");	
	host_index_numplayers 	= gethostcacheindexforkey("numplayers");	
	host_index_maxplayers 	= gethostcacheindexforkey("maxplayers");	
	host_index_address		= gethostcacheindexforkey("cname");
	
	local string str_servers, str_refreshinginxseconds, str_paused, str_ep, str_unpause, str_pause, str_arcade, str_classic;
	
	str_servers					= Translate("Servers:");
	str_refreshinginxseconds	= Translate("Refreshing in %s seconds.");
	str_paused					= Translate("Paused");
	str_ep						= Translate("Ep");
	str_unpause					= Translate("Unpause");
	str_pause					= Translate("Pause");
	str_arcade					= Translate("Arcade");
	str_classic					= Translate("Classic");
	skiptranslation = true;
	
	TempMenuSetting_option_size_height(16);	
	TempMenuSetting_body_alignment_horizontal(-1);
	TempMenuSetting_option_fontsize('8 8 0');
	TempMenuSetting_option_textalignment('-1 0 0');

	viewservers 			= gethostcachevalue(SLIST_HOSTCACHEVIEWCOUNT);
	totalservers 			= gethostcachevalue(SLIST_HOSTCACHETOTALCOUNT);
	
	local float badservers;
	
	for(count = 0; count < viewservers; count++)
	{
		active_menu.host_map		= gethostcachestring(host_index_map, count);
		if(!active_menu.host_map)
			badservers++;
	}

	viewservers -= badservers;
	totalservers -= badservers;
	
	s = strcat(str_servers, SEP_SPACE, ftos(viewservers));
	s = strcat(s, "/");
	s = strcat(s, ftos(totalservers));
	Menu_AlignedText(s, ALIGN_LEFT);	

	if(!ispaused)
	{
		s = sprintf(str_refreshinginxseconds, ftos(ceil(refreshhostcachetime - time)));
		Menu_AlignedText(s, ALIGN_RIGHT);
	}
	else
		Menu_AlignedText(str_paused, ALIGN_RIGHT);
	
	BR();

//	if(!fullscreenserverlist)
//	{	
		optionselection_horizontal = true;

		if(serverlist_sortorder)
			s = "+";
		else
			s = "-";
		
		slist_option_start = option_pos;	
		ServerListText(slist_option_start, info_pos_host, filter_serverlist_hostname);
		ServerListText(slist_option_start, info_pos_mod, filter_serverlist_mod);
		
		if(serverlist_sortby == 2)
			ServerListText(slist_option_start, info_pos_mode, s);
		else
		if(serverlist_sortby == 3)
			ServerListText(slist_option_start, info_pos_ping, s);
		
		option_pos = slist_option_start;
		BR();
		
		skiptranslation = false;
		HorizontalListButton(info_pos_host, info_size_host, "Host Name", SortServerList_Name, 0, 5, 0, 0, MBT_BASIC);
		HorizontalListButton(info_pos_mod, info_size_mod, "Modification", SortServerList_Mod, 23, 7, 0, 0, MBT_BASIC);
		HorizontalListButton(info_pos_mode, info_size_mode, "Mode", SortServerList_Mode, 23, 8, 0, 0, MBT_BASIC);
		HorizontalListButton(info_pos_ping, info_size_ping, "Ping", SortServerList_Ping, 23, 9, 0, 0, MBT_BASIC);	
		BR();

		HorizontalListButton(info_pos_episode, info_size_episode, "Episode", SortServerList_Episode, 1, 9, 0, 0, MBT_BASIC);	
		HorizontalListButton(info_pos_campaign, info_size_campaign, "Campaign", SortServerList_Campaign, 1, 9, 0, 0, MBT_BASIC);	
		HorizontalListButton(info_pos_mission, info_size_mission, "Mission", SortServerList_Mission, 2, 9, 0, 0, MBT_BASIC);
		HorizontalListButton(info_pos_map, info_size_map, "Map", SortServerList_Map, 3, 9, 0, 0, MBT_BASIC);
		HorizontalListButton(info_pos_players, info_size_players, "Players", SortServerList_Players, 4, 0, 0, 0, MBT_BASIC);		
		BR();
		
		skiptranslation = true;
		
		slist_option_start = option_pos;
		ServerListText(slist_option_start, info_pos_episode, filter_serverlist_episode);
		ServerListText(slist_option_start, info_pos_campaign, filter_serverlist_campaign);
		ServerListText(slist_option_start, info_pos_mission, filter_serverlist_mission);
		if(serverlist_sortby == 7)
			ServerListText(slist_option_start, info_pos_map, s);
		else
		if(serverlist_sortby == 8)
			ServerListText(slist_option_start, info_pos_players, s);
		
	//	optionselection_horizontal = false;
		
		option_pos = slist_option_start;	
		BR();
//	}
/*	else
	{
		optionnum_min = 1;
		optionnum_max = 16;
		listslots = optionnum_max;
	}*/
	local float serverlistoptionheight;
	
	RestoreMenuSetting_option_textalignment();
	RestoreMenuSetting_option_size_height();
	RestoreMenuSetting_body_alignment_horizontal();	
	
	serverlistoptionheight = option_fontsize_y + body_fontsize_y + option_textbordersize_y*2 + option_spacing;
	listslots = floor(380/(serverlistoptionheight+option_spacing));//13;
	
	TempMenuSetting_option_size_height(serverlistoptionheight);//26);
	TempMenuSetting_option_size_width(718);			
	
	opsize = option_size_y + option_spacing;
	windowstart_y = option_pos_y;
	windowsize_x = option_size_x+2;
	windowsize_y = opsize*listslots - option_spacing;

	if(viewservers <= listslots)// || !fullscreenserverlist)
	{
		listslots = viewservers;
		option_size_x += scrollbar_width + option_spacing;
		windowsize_x += scrollbar_width;
	}
	
/*	if(!fullscreenserverlist)
	{
		TempMenuSetting_option_size_width(windowsize_x);	
		TempMenuSetting_option_size_height(windowsize_y);	
		TempMenuSetting_option_image("");
		TempMenuSetting_option_image_highlight("");
		optionalt_up = 4;
		Menu_Option_Text("", SetFullScreenServerList);
		RestoreMenuSetting_option_size_width();
		RestoreMenuSetting_option_size_height();
		RestoreMenuSetting_option_image();
		RestoreMenuSetting_option_image_highlight();
		windowstart_x = option_pos_x + 2;
		windowstart_y += 2;
		windowsize -= '4 4 0';
		drawfill(windowstart, windowsize, option_bgcolor*0.5, option_bgalpha, 0);
		windowstart += '2 2 0';
		windowsize -= '4 4 0';
	}*/
	
	option_pos_y = windowstart_y;
	
//	if(fullscreenserverlist)
	if(viewservers > listslots)
	{
//		windowsize_y -= 8;
		
		scrollbar_incrementsize = opsize;
		option_pos_y = BeginScrollingWindow(option_pos, windowsize, 0,0);
		ofs = windowstart_y - option_pos_y;
		option_pos_y += ((ofs/opsize) - floor(ofs/opsize))*opsize;
//		option_size_x += 8;
	}
//	else
/*	{
		option_last = option_current;
		option_current = -1;
		option_off = true;	
		option_pos_x += 4;
	}*/

	if(active_menu.user_current_option >= 10-1 && active_menu.user_current_option <= 10-1+listslots-1)
	{
		optionnum_min = 10;
		optionnum_max = optionnum_min+listslots-1;
	}
	
	local float skippedservers;
	
	old_option_textbordersize = option_textbordersize;
	old_body_textbordersize = body_textbordersize;
	
	for(count = 0; count < viewservers+badservers; count++)
	{
		active_menu.host_map		= gethostcachestring(host_index_map, count);
		if(!active_menu.host_map)
		{
			skippedservers++;
			continue;
		}
		
		if(count > skippedservers)
			BR();	

		dist += option_size_y + option_spacing;
	
		if((option_pos_y + option_spacing < windowstart_y)
		|| (option_pos_y + option_size_y > windowstart_y + windowsize_y + option_spacing))
			continue;
		
	//	if(active_menu.user_current_option > option_current)
	//	if(viewservers < listslots)
	//		active_menu.user_current_option++;
		
		host_qcstatus = gethostcachestring(host_index_qcstatus, count);
		tokenizebyseparator(host_qcstatus, SEP_A);	
		mode = stof(argv(0));
		
		if(mode == GAMEMODE_CAMPAIGN)
		{
			active_menu.host_campaign	= argv(1);
			active_menu.host_mission	= argv(2);
			nextarg = 3;
		}
		else
		{
			active_menu.host_campaign	= "";
			active_menu.host_mission	= argv(1);
			nextarg = 2;
		}
		
		s = ConvertFromQCStatusString(argv(nextarg), QCSF_EPISODE);
		active_menu.host_episode = stof(s);

		skill = stof(argv(nextarg+1));
		active_menu.host_mode = GetGameMode_String(mode, false);	
		
		if(!GameMode_PlayerVSPlayer(mode))
			active_menu.host_skill = GetSkillName(skill, str_arcade, str_classic);		
		
	//	active_menu.host_episode = stof(ConvertFromQCStatusString(argv(nextarg), QCSF_EPISODE));
		
	//	if(GameMode_AllowMinPlayers(mode))
	//		active_menu.host_minplayers	= stof(argv(nextarg));

		active_menu.host_name		= gethostcachestring(host_index_name, count);	
	//	active_menu.host_map		= gethostcachestring(host_index_map, count);
		active_menu.host_mod		= gethostcachestring(host_index_mod, count);
//	if(host_mod == "gamedata")
//		host_mod = "Steel Storm";
		active_menu.host_ping		= gethostcachenumber(host_index_ping, count);
		active_menu.host_numplayers	= gethostcachenumber(host_index_numplayers, count);
		active_menu.host_maxplayers	= gethostcachenumber(host_index_maxplayers, count);
		active_menu.host_address 	= gethostcachestring(host_index_address, count);
		
		players = strcat(ftos(active_menu.host_numplayers), "/");
		if(GameMode_AllowMinPlayers(mode))
		{
			players = strcat(players, ftos(active_menu.host_minplayers));				
			players = strcat(players, "-");			
		}
		players = strcat(players, ftos(active_menu.host_maxplayers));
	//	players = strcat(players, ")");
		
		if(active_menu != currentmenu)
		if(active_menu.host_address == currentmenu.host_address)
			UpdateViewServerStats(active_menu, currentmenu);
		
	//	if(!viewhost_address || viewhost_address == host_address)
	//		viewhost_num = count;
		
		optionalt_left = 9;
		optionalt_right = 10+listslots;	
		optionselection_horizontal = true;
		
		slist_option_start = option_pos;
		
		option_pos_x = slist_option_start_x + info_pos_host;	
		option_textbordersize_x = 12;
	//	option_width_old = option_size_x;
	//	option_size_x = info_size_host-option_textbordersize_x;
		option_fontsize_old = option_fontsize;
		option_fontsize = FitFontSizeToWidth(active_menu.host_name, info_size_host-option_textbordersize_x, option_fontsize);
	//	Menu_Option_Text(FitStringToWidth(active_menu.host_name, info_size_host-option_textbordersize_x, body_fontsize), Confirm_JoinServer);
		Menu_Option_Text(active_menu.host_name, Confirm_JoinServer);		
		option_textbordersize = old_option_textbordersize;
		option_fontsize = option_fontsize_old;
	//	option_size_x = option_width_old;
		option_pos = GetLastLinePos();	
		
		option_pos_x = slist_option_start_x + info_pos_mod;
		//Menu_AlignedText(FitStringToWidth(active_menu.host_mod, info_size_mod-body_textbordersize_x, body_fontsize), ALIGN_TOPLEFT);	
		option_width_old = option_size_x;
		option_size_x = info_size_mod-body_textbordersize_x;		
		Menu_AlignedText(active_menu.host_mod, ALIGN_TOPLEFT);
		option_size_x = option_width_old;
		option_pos_x = slist_option_start_x + info_pos_mode;
		if(GameMode_PlayerVSPlayer(mode))
			Menu_AlignedText(active_menu.host_mode, ALIGN_TOPLEFT);
		else
			Menu_AlignedText(strcat(active_menu.host_mode, " - ", active_menu.host_skill), ALIGN_TOPLEFT);	
		
		option_pos_x = slist_option_start_x + info_pos_ping;
		Menu_AlignedText(ftos(active_menu.host_ping), ALIGN_TOPLEFT);	

		option_pos_y = slist_option_start_y + option_fontsize_y + option_spacing;		
		
		option_pos_x = slist_option_start_x + info_pos_episode;		
		body_textbordersize_x = 12;
//	print(active_menu.host_episode); print(" active_menu.host_episode A\n");
//		active_menu.host_episode = strcat("Ep ", ConvertFromQCStatusString(active_menu.host_episode, QCSF_EPISODE));
//	print(active_menu.host_episode); print(" active_menu.host_episode B\n");		
		//Menu_AlignedText(FitStringToWidth(strcat(str_ep, SEP_SPACE, ftos(active_menu.host_episode)), info_size_episode-body_textbordersize_x, body_fontsize), ALIGN_TOPLEFT);	
		option_width_old = option_size_x;
		option_size_x = info_size_episode-body_textbordersize_x;		
		Menu_AlignedText(strcat(str_ep, SEP_SPACE, ftos(active_menu.host_episode)), ALIGN_TOPLEFT);			
		body_textbordersize = old_body_textbordersize;
		option_pos_x = slist_option_start_x + info_pos_campaign;
		active_menu.host_campaign = ConvertFromQCStatusString(active_menu.host_campaign, QCSF_CAMPAIGN);
		//Menu_AlignedText(FitStringToWidth(TitleString(active_menu.host_campaign), info_size_campaign-body_textbordersize_x, body_fontsize), ALIGN_TOPLEFT);	
		option_size_x = info_size_campaign-body_textbordersize_x;		
		Menu_AlignedText(TitleString(active_menu.host_campaign), ALIGN_TOPLEFT);	
		option_pos_x = slist_option_start_x + info_pos_mission;
		active_menu.host_mission = ConvertFromQCStatusString(active_menu.host_mission, QCSF_MISSION);
		//Menu_AlignedText(FitStringToWidth(TitleString(active_menu.host_mission), info_size_mission-body_textbordersize_x, body_fontsize), ALIGN_TOPLEFT);
		option_size_x = info_size_mission-body_textbordersize_x;		
		Menu_AlignedText(TitleString(active_menu.host_mission), ALIGN_TOPLEFT);
		option_pos_x = slist_option_start_x + info_pos_map;
		//Menu_AlignedText(FitStringToWidth(active_menu.host_map, info_size_map-body_textbordersize_x, body_fontsize), ALIGN_TOPLEFT);
		option_size_x = info_size_map-body_textbordersize_x;		
		Menu_AlignedText(active_menu.host_map, ALIGN_TOPLEFT);	
		option_size_x = option_width_old;		
		option_pos_x = slist_option_start_x + info_pos_players;
		Menu_AlignedText(players, ALIGN_TOPLEFT);		

		option_pos = slist_option_start;
	}
	
	RestoreMenuSetting_option_size_width();
	RestoreMenuSetting_option_size_height();
//	RestoreMenuSetting_option_fontsize();
		
	if(option_current < 22)
		option_current = 22;
		
	if(active_menu.user_current_option > 8+listslots && active_menu.user_current_option < 22)
		active_menu.user_current_option = 22;
	
//	if(fullscreenserverlist)
	if(viewservers > listslots)
		EndScrollingWindow(dist-option_spacing, 0, 0);
//	else
/*	{
		option_off = false;
		option_current = option_last;		
		option_pos_x -= 4;	
	}*/

	option_pos_y = vid_size_y - option_size_y - 34;	
	
	option_textalignment = '0 0 0';	
//	TempMenuSetting_option_size_height(16);	
	TempMenuSetting_body_alignment_horizontal(-1);
	option_size = '120 22 0';
	
	skiptranslation = false;
	HorizontalListButton(0, option_size_x, "Refresh", ForceRefreshHostCache, 9+listslots, 1, 9+listslots, 0, MBT_BASIC);
	skiptranslation = true;
	
	slist_option_start = option_pos;	
	if(ispaused)
		s = str_unpause;
	else
		s = str_pause;
	HorizontalListButton(option_size_x+option_spacing, option_size_x, s, ToggleServerListPause, 9+listslots, 1, 0, 0, MBT_BASIC);
	skiptranslation = false;
	HorizontalListButton((option_size_x+option_spacing)*2, option_size_x, "Enter Address", Call_IPConnect, 9+listslots, 1, 0, 0, MBT_BASIC);	
	HorizontalListButton((option_size_x+option_spacing)*3, option_size_x, "Back", currentmenu.ESCFunc, 9+listslots, 0, 0, 0, MBT_CANCEL);	
//	ServerListButton(slist_option_start, 102, 100, "Refresh", refreshhostcache);

//	RestoreMenuSetting_option_size_height();
	RestoreMenuSetting_body_alignment_horizontal();		
	
	Menu_End();	
	
	RefreshHostCache();
}

void ShowServerList() =
{
	CloseMenuBranch(1);
	RefreshHostCache();
	SetCurrentMenu(Draw_ServerList);
	currentmenu.ESCFunc = ServerListESCFunc;
//	currentmenu.user_current_option = 8;
}