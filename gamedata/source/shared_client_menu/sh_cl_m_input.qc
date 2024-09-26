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
float	bindmap_foreground;
float	bindmap_background;

float	CTRL_MOVEFORWARD			= 0;
float	CTRL_MOVEBACK				= 1;
float	CTRL_MOVELEFT				= 2;
float	CTRL_MOVERIGHT				= 3;

float	CTRL_FIREPRIMARY			= 4;
float	CTRL_FIRESECONDARY			= 5;
float	CTRL_FIRESHOCKWAVE			= 6;
float	CTRL_TOGGLESECONDARY		= 7;
float	CTRL_TOGGLEMISSIONMAP		= 8;
float	CTRL_TOGGLEMISSIONBRIEFING	= 9;

float	CTRL_TOGGLELIVESCORES		= 35;
float	CTRL_TALK					= 36;
float	CTRL_TALK_TEAM				= 37;
float	CTRL_VOTEYES				= 38;
float	CTRL_VOTENO					= 39;
float	CTRL_TOGGLECAMMODE			= 40;

float	CTRL_MENUBUTTON1			= 10;
float	CTRL_MENUBUTTON2			= 11;
float	CTRL_ESCAPE					= 12;
float	CTRL_MENUNAVIGATEUP			= 13;
float	CTRL_MENUNAVIGATEDOWN		= 14;
float	CTRL_MENUNAVIGATELEFT		= 15;
float	CTRL_MENUNAVIGATERIGHT		= 16;
float	CTRL_CONFIRM				= 17;
float	CTRL_BACKSPACE				= 18;
float	CTRL_DELETE					= 19;
float	CTRL_MENUSCROLLWINDOWUP		= 20;
float	CTRL_MENUSCROLLWINDOWDOWN	= 21;
float	CTRL_SHIFT_LEFT				= 41;
float	CTRL_SHIFT_RIGHT			= 42;

float	CTRL_EDITORMOVEFORWARD		= 22;
float	CTRL_EDITORMOVEBACK			= 23;
float	CTRL_EDITORMOVELEFT			= 24;
float	CTRL_EDITORMOVERIGHT		= 25;

float	CTRL_EDITORBUTTON1			= 26;
float	CTRL_EDITORBUTTON2			= 27;
float	CTRL_OBJECTYAWADD			= 28;
float	CTRL_OBJECTYAWSUBTRACT		= 29;
float	CTRL_OBJECTPITCHADD			= 30;
float	CTRL_OBJECTPITCHSUBTRACT	= 31;
float	CTRL_RESETOBJECTPITCH		= 32;
float	CTRL_ZOOMIN					= 33;
float	CTRL_ZOOMOUT				= 34;


float GetControlIDForBind(string bind) =
{
	local float ctrlid;

	switch(bind)
	{
		case "+forward":					ctrlid = CTRL_MOVEFORWARD;				break;
		case "+back":						ctrlid = CTRL_MOVEBACK;					break;
		case "+moveleft":					ctrlid = CTRL_MOVELEFT;					break;
		case "+moveright":					ctrlid = CTRL_MOVERIGHT;				break;	

		case "+attack":						ctrlid = CTRL_FIREPRIMARY;				break;
		case "+jump":						ctrlid = CTRL_FIRESECONDARY;			break;
		case "impulse 4":					ctrlid = CTRL_FIRESHOCKWAVE;			break;
		case "impulse 10":					ctrlid = CTRL_TOGGLESECONDARY;			break;		
		case "impulse 11":					ctrlid = CTRL_TOGGLEMISSIONMAP;			break;
		case "impulse 12":					ctrlid = CTRL_TOGGLEMISSIONBRIEFING;	break;
		case "impulse 13":					ctrlid = CTRL_TOGGLELIVESCORES;			break;
		case "messagemode":					ctrlid = CTRL_TALK;						break;
		case "messagemode2":				ctrlid = CTRL_TALK_TEAM;				break;
		case "impulse 20":					ctrlid = CTRL_VOTEYES;					break;
		case "impulse 21":					ctrlid = CTRL_VOTENO;					break;
		case "impulse 22":					ctrlid = CTRL_TOGGLECAMMODE;			break;
		
		case "impulse 50":					ctrlid = CTRL_MENUBUTTON1;				break;
		case "impulse 51":					ctrlid = CTRL_MENUBUTTON2;				break;
		case "togglemenu":					ctrlid = CTRL_ESCAPE;					break;
		case "impulse 53":					ctrlid = CTRL_MENUNAVIGATEUP;			break;
		case "impulse 54":					ctrlid = CTRL_MENUNAVIGATEDOWN;			break;
		case "impulse 55":					ctrlid = CTRL_MENUNAVIGATELEFT;			break;
		case "impulse 56":					ctrlid = CTRL_MENUNAVIGATERIGHT;		break;
		case "impulse 57":					ctrlid = CTRL_CONFIRM;					break;
		case "impulse 58":					ctrlid = CTRL_BACKSPACE;				break;
		case "impulse 59":					ctrlid = CTRL_DELETE;					break;
		case "impulse 60":					ctrlid = CTRL_MENUSCROLLWINDOWUP;		break;
		case "impulse 61":					ctrlid = CTRL_MENUSCROLLWINDOWDOWN;		break;
		case "impulse 75":					ctrlid = CTRL_SHIFT_LEFT;				break;
		case "impulse 76":					ctrlid = CTRL_SHIFT_RIGHT;				break;
		
		case "impulse 62":					ctrlid = CTRL_EDITORMOVEFORWARD;		break;
		case "impulse 63":					ctrlid = CTRL_EDITORMOVEBACK;			break;
		case "impulse 64":					ctrlid = CTRL_EDITORMOVELEFT;			break;
		case "impulse 65":					ctrlid = CTRL_EDITORMOVERIGHT;			break;	
		
		case "impulse 66":					ctrlid = CTRL_EDITORBUTTON1;			break;
		case "impulse 67":					ctrlid = CTRL_EDITORBUTTON2;			break;
		case "impulse 68":					ctrlid = CTRL_OBJECTYAWADD;				break;
		case "impulse 69":					ctrlid = CTRL_OBJECTYAWSUBTRACT;		break;			
		case "impulse 70":					ctrlid = CTRL_OBJECTPITCHADD;			break;
		case "impulse 71":					ctrlid = CTRL_OBJECTPITCHSUBTRACT;		break;
		case "impulse 72":					ctrlid = CTRL_RESETOBJECTPITCH;			break;
		case "impulse 73":					ctrlid = CTRL_ZOOMIN;					break;
		case "impulse 74":					ctrlid = CTRL_ZOOMOUT;					break;
		
		default:							ctrlid = -1;							break;
	
	}
	
	return ctrlid;
}

string GetBindForControlID(float ctrlid) =
{
	local string bind;

	switch(ctrlid)
	{
		case CTRL_MOVEFORWARD:				bind = "+forward";			break;
		case CTRL_MOVEBACK:					bind = "+back";				break;
		case CTRL_MOVELEFT:					bind = "+moveleft";			break;
		case CTRL_MOVERIGHT:				bind = "+moveright";		break;		

		case CTRL_FIREPRIMARY:				bind = "+attack";			break;
		case CTRL_FIRESECONDARY:			bind = "+jump";				break;
		case CTRL_FIRESHOCKWAVE:			bind = "impulse 4";			break;
		case CTRL_TOGGLESECONDARY:			bind = "impulse 10";		break;	
		case CTRL_TOGGLEMISSIONMAP:			bind = "impulse 11";		break;
		case CTRL_TOGGLEMISSIONBRIEFING:	bind = "impulse 12";		break;
		case CTRL_TOGGLELIVESCORES:			bind = "impulse 13";		break;		
		case CTRL_TALK:						bind = "messagemode";		break;
		case CTRL_TALK_TEAM:				bind = "messagemode2";		break;
		case CTRL_VOTEYES:					bind = "impulse 20";		break;
		case CTRL_VOTENO:					bind = "impulse 21";		break;
		case CTRL_TOGGLECAMMODE:			bind = "impulse 22";		break;
		
		case CTRL_MENUBUTTON1:				bind = "impulse 50";		break;
		case CTRL_MENUBUTTON2:				bind = "impulse 51";		break;
		case CTRL_ESCAPE:					bind = "togglemenu";		break;
		case CTRL_MENUNAVIGATEUP:			bind = "impulse 53";		break;
		case CTRL_MENUNAVIGATEDOWN:			bind = "impulse 54";		break;
		case CTRL_MENUNAVIGATELEFT:			bind = "impulse 55";		break;
		case CTRL_MENUNAVIGATERIGHT:		bind = "impulse 56";		break;
		case CTRL_CONFIRM:					bind = "impulse 57";		break;
		case CTRL_BACKSPACE:				bind = "impulse 58";		break;
		case CTRL_DELETE:					bind = "impulse 59";		break;
		case CTRL_MENUSCROLLWINDOWUP:		bind = "impulse 60";		break;
		case CTRL_MENUSCROLLWINDOWDOWN:		bind = "impulse 61";		break;
		case CTRL_SHIFT_LEFT:				bind = "impulse 75";		break;
		case CTRL_SHIFT_RIGHT:				bind = "impulse 76";		break;
		
		case CTRL_EDITORMOVEFORWARD:		bind = "impulse 62";		break;
		case CTRL_EDITORMOVEBACK:			bind = "impulse 63";		break;
		case CTRL_EDITORMOVELEFT:			bind = "impulse 64";		break;
		case CTRL_EDITORMOVERIGHT:			bind = "impulse 65";		break;			
		
		case CTRL_EDITORBUTTON1:			bind = "impulse 66";		break;
		case CTRL_EDITORBUTTON2:			bind = "impulse 67";		break;
		case CTRL_OBJECTYAWADD:				bind = "impulse 68";		break;
		case CTRL_OBJECTYAWSUBTRACT:		bind = "impulse 69";		break;			
		case CTRL_OBJECTPITCHADD:			bind = "impulse 70";		break;
		case CTRL_OBJECTPITCHSUBTRACT:		bind = "impulse 71";		break;
		case CTRL_RESETOBJECTPITCH:			bind = "impulse 72";		break;
		case CTRL_ZOOMIN:					bind = "impulse 73";		break;
		case CTRL_ZOOMOUT:					bind = "impulse 74";		break;
	}

	return bind;
}

float GetBindMapForControlID(float ctrlid) =
{
	local float bindmap;

	switch(ctrlid)
	{
		case CTRL_MOVEFORWARD:				bindmap = 1;		break;
		case CTRL_MOVEBACK:					bindmap = 1;		break;
		case CTRL_MOVELEFT:					bindmap = 1;		break;
		case CTRL_MOVERIGHT:				bindmap = 1;		break;		

		case CTRL_FIREPRIMARY:				bindmap = 1;		break;
		case CTRL_FIRESECONDARY:			bindmap = 1;		break;
		case CTRL_FIRESHOCKWAVE:			bindmap = 1;		break;
		case CTRL_TOGGLESECONDARY:			bindmap = 1;		break;
		case CTRL_TOGGLEMISSIONMAP:			bindmap = 1;		break;
		case CTRL_TOGGLEMISSIONBRIEFING:	bindmap = 1;		break;
		case CTRL_TOGGLELIVESCORES:			bindmap = 1;		break;		
		case CTRL_TALK:						bindmap = 1;		break;
		case CTRL_TALK_TEAM:				bindmap = 1;		break;
		case CTRL_VOTEYES:					bindmap = 1;		break;
		case CTRL_VOTENO:					bindmap = 1;		break;
		case CTRL_TOGGLECAMMODE:			bindmap = 1;		break;
	
		case CTRL_MENUBUTTON1:				bindmap = 0;		break;
		case CTRL_MENUBUTTON2:				bindmap = 0;		break;
		case CTRL_ESCAPE:					bindmap = 0;		break;
		case CTRL_MENUNAVIGATEUP:			bindmap = 0;		break;
		case CTRL_MENUNAVIGATEDOWN:			bindmap = 0;		break;
		case CTRL_MENUNAVIGATELEFT:			bindmap = 0;		break;
		case CTRL_MENUNAVIGATERIGHT:		bindmap = 0;		break;
		case CTRL_CONFIRM:					bindmap = 0;		break;
		case CTRL_BACKSPACE:				bindmap = 0;		break;
		case CTRL_DELETE:					bindmap = 0;		break;
		case CTRL_MENUSCROLLWINDOWUP:		bindmap = 0;		break;
		case CTRL_MENUSCROLLWINDOWDOWN:		bindmap = 0;		break;	
		case CTRL_SHIFT_LEFT:				bindmap = 0;		break;
		case CTRL_SHIFT_RIGHT:				bindmap = 0;		break;
	
		case CTRL_EDITORMOVEFORWARD:		bindmap = 2;		break;
		case CTRL_EDITORMOVEBACK:			bindmap = 2;		break;
		case CTRL_EDITORMOVELEFT:			bindmap = 2;		break;
		case CTRL_EDITORMOVERIGHT:			bindmap = 2;		break;	
		
		case CTRL_EDITORBUTTON1:			bindmap = 2;		break;
		case CTRL_EDITORBUTTON2:			bindmap = 2;		break;
		case CTRL_OBJECTYAWADD:				bindmap = 2;		break;
		case CTRL_OBJECTYAWSUBTRACT:		bindmap = 2;		break;			
		case CTRL_OBJECTPITCHADD:			bindmap = 2;		break;
		case CTRL_OBJECTPITCHSUBTRACT:		bindmap = 2;		break;
		case CTRL_RESETOBJECTPITCH:			bindmap = 2;		break;
		case CTRL_ZOOMIN:					bindmap = 2;		break;
		case CTRL_ZOOMOUT:					bindmap = 2;		break;
		
		default:							bindmap = -1;		break;
	}

	return bindmap;
}

float GetControlIDForKeyNumber(float keynum, float bindmap) =
{
	local string key, bind;
	local float ctrlid;
	
	bind = getkeybind_bindmap(keynum, bindmap);
	
	if(!bind)
		return -1;
	
	ctrlid = GetControlIDForBind(bind);
	
	return ctrlid;
}

float GameControlState(float keynum) =
{
	local float ctrlid, count, state;
	
	for(count = 0; count < 2; count++)
	{
		if(count == 0)
			ctrlid = GetControlIDForKeyNumber(keynum, bindmap_foreground);
		else
		if(count == 1)
			ctrlid = GetControlIDForKeyNumber(keynum, bindmap_background);

		if(ctrlid >= 0)
			state = cl_buttondown[ctrlid];
	}	

	return state;
}

void SetGameControlState(float keynum, float state) =
{
	local float ctrlid, count;
	
	for(count = 0; count < 2; count++)
	{
		if(count == 0)
			ctrlid = GetControlIDForKeyNumber(keynum, bindmap_foreground);
		else
		if(count == 1)
			ctrlid = GetControlIDForKeyNumber(keynum, bindmap_background);

		if(ctrlid >= 0)
			cl_buttondown[ctrlid] = state;
	}
}

float GameControl(float CTRL, float buttonstate) =
{
//	buttonstate
//	-1	= button release 
//	0	= normal keypress
//	1	= button held down

	local float keynum, bindmap;
	local string key, keybind, bind;

	if(buttonstate > 0)
	{
		if(cl_buttondown[CTRL])
			return true;
		else
			return false;	
	}

//	if(cl_button == -K_MWHEELUP || cl_button == -K_MWHEELDOWN)
//		buttonstate = -1;
	
	keynum = cl_button;
	
	if(buttonstate == -1)
		keynum = keynum*-1;

	if(keynum <= 0)
		return false;
	
	bind = GetBindForControlID(CTRL);
	bindmap = GetBindMapForControlID(CTRL);
	
//	key = keynumtostring(keynum);
	keybind = getkeybind_bindmap(keynum, bindmap);

	if(keybind == bind)
		return true;
	
	return false;
}

void SetKeyRepeatTime() =
{
	if(!keyrepeattime)
		keyrepeattime = time_local + 0.5;
	else
		keyrepeattime = time_local + 0.1;
}

void ClearAllInputValues() =
{
	local float count;

	input_cursorpos = 0;		
	input_cursorscreenpos = '0 0 0';
	active_input = false;
	active_textblock = false;
	active_vkb = false;
	vkb_uppercase = false;

	keyrepeating = false;
	keyrepeattime = 0;	
	
	option_lastclick = 0;
	option_current_sendtobottomoflist = false;
	atbottomofscrollingwindow = false;
	gotobottomofscrollingwindow = false;
	
//	if(active_menu)
//	{
//		active_menu.user_current_option = 0;
//	}

	if(!dontclearbuttons)
	{
		cl_button = 0;
		cl_button_ucs = 0;	
		cl_lastbutton = 0;
		cl_lastbutton_ucs = 0;	

		for(count = 0; count < NUM_GAMECONTROLS; count++)
			cl_buttondown[count] = 0;
	}	
	
	dontclearbuttons = false;	
}

void ClearInput() =
{
//	if(cl_button == K_MOUSE1)
	if(GameControl(CTRL_MENUBUTTON1, 0))
	if(!option_lastclick)
	if(!keyrepeating)
		option_lastclick = -1;

//	if(cl_button == -K_MOUSE1)
	if(GameControl(CTRL_MENUBUTTON1, -1))
		option_lastclick = 0;

	if(keyrepeattime && /*active_input &&*/ keyrepeattime < time_local)
	{
		keyrepeating = true;
		cl_button = cl_lastbutton;
		cl_button_ucs = cl_lastbutton_ucs;
		SetKeyRepeatTime();
	}
	else
	{
		keyrepeating = false;
		cl_button = 0;
		cl_button_ucs = 0;
	}

	if(cl_button_ucs_vkb)
		cl_button_ucs = cl_button_ucs_vkb;
	cl_button_ucs_vkb = 0;
	
//	CURSOROVERMENU = false;	
}

void ReleaseKey(float nKey) =
{
	cl_button = -nKey;
	if(nKey == cl_lastbutton)
	{
		cl_lastbutton = 0;
		cl_lastbutton_ucs = 0;
	}

	keyrepeattime = 0;
	SetGameControlState(nKey, false);
}

void FastKeyRelease() =
{
	if(!cl_release)
		return;

	ReleaseKey(cl_release);
	cl_release = 0;
}

void InterfaceKeys(float bKeyReleased, float nKey, float UCS) =
{
	local float dKey;

	if(nKey == K_MWHEELUP || nKey == K_MWHEELDOWN)
		bKeyReleased = false;
		
	if(bKeyReleased)
	{
		if(!cl_button)
			ReleaseKey(nKey);
		else
			cl_release = nKey;
	}
	else
//	if(GameControlState(nKey) != 1)
	{
		cl_button = nKey;
		cl_button_ucs = UCS;
	
		keyrepeattime = 0;
		
		if(nKey == K_MWHEELUP || nKey == K_MWHEELDOWN)
			return;
			
		SetKeyRepeatTime();
		cl_lastbutton = nKey;
		cl_lastbutton_ucs = UCS;

		SetGameControlState(nKey, true);
	}
}