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
void Sound_Init() =
{
	precache_sound ("sounds/menu/ss_ui_hover_2.wav");
//	precache_sound ("sounds/menu/ss_ui_scroll_click.wav");	
	precache_sound ("sounds/menu/ss_ui_click_5.wav");
	precache_sound ("sounds/menu/ss_ui_accept_2.wav");
//	precache_sound ("sounds/menu/ss_ui_cancel_click.wav");
	precache_sound ("sounds/menu/ss_ui_back_1.wav");
	precache_sound ("sounds/menu/ss_ui_quit_click.wav");	
	precache_sound ("sounds/menu/ss_ui_type.wav");	
}

void MenuSound(float soundnum) =
{
	local string s, soundname;

	switch(soundnum)
	{
		case SOUND_MOUSEOVERCLICK:		soundname = "sounds/menu/ss_ui_hover_2.wav";				break;	
//		case SOUND_SCROLLBARCLICK:		soundname = "sounds/menu/ss_ui_scroll_click.wav";			break;
		case SOUND_BASICCLICK:			soundname = "sounds/menu/ss_ui_click_5.wav";				break;
		case SOUND_CONFIRMCLICK:		soundname = "sounds/menu/ss_ui_accept_2.wav";				break;
		case SOUND_CANCELCLICK:			soundname = "sounds/menu/ss_ui_back_1.wav";					break;
	//	case SOUND_BACKCLICK:			soundname = "sounds/menu/ss_ui_back_1.wav";					break;
		case SOUND_QUITCLICK:			soundname = "sounds/menu/ss_ui_quit_click.wav";				break;	
		case SOUND_TYPECLICK:			soundname = "sounds/menu/ss_ui_type.wav";					break;
	}

	s = strcat("play2 ", soundname);
	s = strcat(s, "\n");
	
	localcmd(s);
}