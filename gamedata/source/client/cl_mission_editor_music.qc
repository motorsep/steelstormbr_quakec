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
void SetMissionTrackFromServer() =
{
	mission_track = zonecpy(mission_track, ReadString());
	
	if(!iseditingmissiontrack)
		PlayBGMusic(mission_track);
}

void ClearTrackListValues() =
{
	iseditingmissiontrack = false;
}

void SetMusicTrack() =
{
	local string cmd;

	mission_track = zonecpy(mission_track, GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1));

	cmd = strcat("cmd setmissiontrack ", mission_track);
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
	
	CloseMenu();
}

void MusicTrackList_PlayTrack() =
{
	local string s, trackname, tracknum;
	
	trackname = GetBufferString(active_menu.buf_list, active_menu.user_current_selection-1);
	PlayBGMusic(trackname);
}

void SelectMusicTrack() =	{	active_menu.user_current_selection = active_menu.listid+1;	}

void ListOption_MusicTrackList(float count) =
{
	active_menu.listid = count;	
	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	
	Menu_Option_Text(strcat("  ", active_menu.listitemstring), SelectMusicTrack);
	
	if(active_menu.user_current_selection-1 == count)
	{
		option_pos = GetLastLinePos();
		Menu_AlignedText(">", ALIGN_LEFT);			
		BR();
	}		
}

void Draw_MusicTrackList() =
{
	local float numtracks, numlistoptions, windowwidth, buttonwidth, lastoptnum, firstoptnum;
	local vector option_pos_start, backbuttonpos;
	local string listitem;
	
	Menu_Start_OptionMenu("Tracks", '600 500 0', __FUNC__);
	
	local string str_playselectedtrack;

	windowwidth = 300;
	
	body_alignment = '-1 0 0';
	body_textalignment = '-1 0 0';
	
	option_size_x = 300;
	
	option_pos_start = option_pos;

	numtracks = GetBufferSize(active_menu.buf_list);
	
	if(numtracks > 0)
		lastoptnum = 16;
		
	if(numtracks > 0)
			numlistoptions = Draw_ScollingList(numtracks, 17, 0, windowwidth, 19, 17, SUB_Null, ListOption_MusicTrackList);
	else
		option_pos_y += 10*(option_size_y+option_spacing);
		
	BR();

	option_textalignment = '0 0 0';

	backbuttonpos = option_pos;
	buttonwidth = 150;
	
	body_fontsize = option_fontsize;

	option_pos = option_pos_start;	
	option_pos_x += windowwidth + 20;	
	
	TempMenuSetting_body_fontcolor(option_fontcolor);
	Menu_Text("Current Mission Track:");
	RestoreMenuSetting_body_fontcolor();
	option_pos_y += body_fontsize_y + option_spacing;	
	skiptranslation = true;
	Menu_Text(mission_track);
	skiptranslation = false;
	option_pos_y += body_fontsize_y + option_spacing;			
	
	str_playselectedtrack	= Translate("Play Selected Track");
	
	skiptranslation = true;
	if(numtracks > 0)
	{
		if(!active_menu.user_current_selection)
			active_menu.user_current_selection = 1;
	
		firstoptnum = 1;
	
		option_pos_x = option_pos_start_x;
		option_pos_x += windowwidth + (active_menu.menusize_x - windowwidth - border_size_x - body_margin_x - buttonwidth)*0.5 ;	
		BR();

		HorizontalListButton(0, buttonwidth, str_playselectedtrack, MusicTrackList_PlayTrack, 1, 0, 1, 0, MBT_BASIC);		
	}	
	else
	{
		firstoptnum = 0;
		numlistoptions = 0;
	}

	skiptranslation = false;
	
	option_pos = backbuttonpos;
	
	BeginBottomButtons(2);
	DrawElement_BottomButton("Confirm", SetMusicTrack, numlistoptions, firstoptnum, 0, 0, MBT_CANCEL);	
	DrawElement_BottomButton("Cancel", CloseMenu, numlistoptions, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();			
	
	Menu_End();
}

void Call_MusicTrackList() =
{
	local float searchhandle, numfiles, count, file;
	local string track_name;

	iseditingmissiontrack = true;
	
	SetCurrentMenu(Draw_MusicTrackList);
	currentmenu.buf_list = CreateBuffer();
	currentmenu.CloseMenuFunc = ClearTrackListValues;
	
	searchhandle = search_begin("music/*.ogg", TRUE, TRUE);
	if(searchhandle == -1)
		return;
	
	numfiles = search_getsize(searchhandle);	

	for(count = 0; count < numfiles; count++)
	{
		track_name = search_getfilename(searchhandle, count);
		if(!HasDuplicateStringInList(currentmenu.buf_list, track_name))
			AddBufferString(currentmenu.buf_list, track_name, 0);
	}	
	
	search_end(searchhandle);
	SortBuffer(currentmenu.buf_list, 99, FALSE);	
}