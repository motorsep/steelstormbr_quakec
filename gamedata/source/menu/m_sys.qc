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
#pragma flag off fastarrays // make dp behave with new fteqcc versions. remove when dp bug with fteqcc fastarrays is fixed

//////////////////////////////////////////////////////////
// sys globals

entity self;

/////////////////////////////////////////////////////////
void		end_sys_globals;
/////////////////////////////////////////////////////////
// sys fields

/////////////////////////////////////////////////////////
void		end_sys_fields;
/////////////////////////////////////////////////////////
// sys functions

void() m_init;
void(float keynr, float ascii) m_keydown;
void() m_draw;
void() m_display; 	// old NG Menu
void() m_toggle;
void() m_hide;		// old NG Menu
void() m_shutdown;
void() m_quit;
/*
/////////////////////////////////////////////////////////
// sys constants
///////////////////////////
// key constants

//
// these are the key numbers that should be passed to Key_Event
//
float K_TAB			=	9;
float K_ENTER		=	13;
float K_ESCAPE		=	27;
float K_SPACE		=	32;

// normal keys should be passed as lowercased ascii

float K_BACKSPACE	=	127;
float K_UPARROW		=	128;
float K_DOWNARROW	=	129;
float K_LEFTARROW	=	130;
float K_RIGHTARROW	=	131;

float K_ALT		=	132;
float K_CTRL	=	133;
float K_SHIFT	=	134;
float K_F1		=	135;
float K_F2		=	136;
float K_F3		=	137;
float K_F4		=	138;
float K_F5		=	139;
float K_F6		=	140;
float K_F7		=	141;
float K_F8		=	142;
float K_F9		=	143;
float K_F10		=	144;
float K_F11		=	145;
float K_F12		=	146;
float K_INS		=	147;
float K_DEL		=	148;
float K_PGDN	=	149;
float K_PGUP	=	150;
float K_HOME	=	151;
float K_END		=	152;

float K_KP_HOME			=	160;
float K_KP_UPARROW		=	161;
float K_KP_PGUP			=	162;
float K_KP_LEFTARROW	=	163;
float K_KP_5			=	164;
float K_KP_RIGHTARROW	=	165;
float K_KP_END			=	166;
float K_KP_DOWNARROW	=	167;
float K_KP_PGDN			=	168;
float K_KP_ENTER		=	169;
float K_KP_INS   		=	170;
float K_KP_DEL			=	171;
float K_KP_SLASH		=	172;
float K_KP_MINUS		=	173;
float K_KP_PLUS			=	174;

float K_PAUSE		=	255;

//
// joystick buttons
//
float K_JOY1		=	768;
float K_JOY2		=	769;
float K_JOY3		=	770;
float K_JOY4		=	771;

//
// aux keys are for multi-buttoned joysticks to generate so they can use
// the normal binding process
//
float K_AUX1		=	772;
float K_AUX2		=	773;
float K_AUX3		=	774;
float K_AUX4		=	775;
float K_AUX5		=	776;
float K_AUX6		=	777;
float K_AUX7		=	778;
float K_AUX8		=	779;
float K_AUX9		=	780;
float K_AUX10		=	781;
float K_AUX11		=	782;
float K_AUX12		=	783;
float K_AUX13		=	784;
float K_AUX14		=	785;
float K_AUX15		=	786;
float K_AUX16		=	787;
float K_AUX17		=	788;
float K_AUX18		=	789;
float K_AUX19		=	790;
float K_AUX20		=	791;
float K_AUX21		=	792;
float K_AUX22		=	793;
float K_AUX23		=	794;
float K_AUX24		=	795;
float K_AUX25		=	796;
float K_AUX26		=	797;
float K_AUX27		=	798;
float K_AUX28		=	799;
float K_AUX29		=	800;
float K_AUX30		=	801;
float K_AUX31		=	802;
float K_AUX32		=	803;

//
// mouse buttons generate virtual keys
//
float K_MOUSE1		=	512;
float K_MOUSE2		=	513;
float K_MOUSE3		=	514;
float K_MWHEELUP	=	515;
float K_MWHEELDOWN	=	516;
float K_MOUSE4		=	517;
float K_MOUSE5		=	518;
float K_MOUSE6		=	519;
float K_MOUSE7		=	520;
float K_MOUSE8		=	521;
float K_MOUSE9		=	522;
float K_MOUSE10		=	523;
float K_MOUSE11		=	524;
float K_MOUSE12		=	525;
float K_MOUSE13		=	526;
float K_MOUSE14		=	527;
float K_MOUSE15		=	528;
float K_MOUSE16		=	529;
*/
///////////////////////////
// key dest constants

float KEY_UNKNOWN	= 	-1;
float KEY_GAME 		=	0;
float KEY_MENU		=	2;
float KEY_MENU_GRABBED = 3;

///////////////////////////
// file constants

float FILE_READ = 0;
float FILE_APPEND = 1;
float FILE_WRITE = 2;

///////////////////////////
// logical constants (just for completeness)

float TRUE 	= 1;
float FALSE = 0;

///////////////////////////
// boolean constants

float true  = 1;
float false = 0;

///////////////////////////
// msg constants

float MSG_BROADCAST		= 0;		// unreliable to all
float MSG_ONE			= 1;		// reliable to one (msg_entity)
float MSG_ALL			= 2;		// reliable to all
float MSG_INIT			= 3;		// write to the init string

/////////////////////////////
// mouse target constants

float MT_MENU = 1;
float MT_CLIENT = 2;

/////////////////////////
// client state constants

float CS_DEDICATED 		= 0;
float CS_DISCONNECTED 	= 1;
float CS_CONNECTED		= 2;

///////////////////////////
// blend flags

float DRAWFLAG_NORMAL		= 0;
float DRAWFLAG_ADDITIVE 	= 1;
float DRAWFLAG_MODULATE 	= 2;
float DRAWFLAG_2XMODULATE   = 3;


///////////////////////////
// cvar constants

float CVAR_SAVE 	= 1;
float CVAR_NOTIFY 	= 2;
float CVAR_READONLY	= 4;

///////////////////////////
// server list constants

float SLIST_HOSTCACHEVIEWCOUNT  = 0;
float SLIST_HOSTCACHETOTALCOUNT = 1;
float SLIST_MASTERQUERYCOUNT 	= 2;
float SLIST_MASTERREPLYCOUNT 	= 3;
float SLIST_SERVERQUERYCOUNT 	= 4;
float SLIST_SERVERREPLYCOUNT 	= 5;
float SLIST_SORTFIELD		= 6;
float SLIST_SORTDESCENDING	= 7;

float SLIST_LEGACY_LINE1 	= 1024;
float SLIST_LEGACY_LINE2 	= 1025;

float SLIST_TEST_CONTAINS	= 0;
float SLIST_TEST_NOTCONTAIN	= 1;
float SLIST_TEST_LESSEQUAL	= 2;
float SLIST_TEST_LESS		= 3;
float SLIST_TEST_EQUAL		= 4;
float SLIST_TEST_GREATER	= 5;
float SLIST_TEST_GREATEREQUAL	= 6;
float SLIST_TEST_NOTEQUAL	= 7;

float SLIST_MASK_AND = 0;
float SLIST_MASK_OR  = 512;

float NET_CURRENTPROTOCOL = 3;

////////////////////////////////
// cinematic action constants

float CINE_PLAY 	= 1;
float CINE_LOOP 	= 2;
float CINE_PAUSE 	= 3;
float CINE_FIRSTFRAME 	= 4;
float CINE_RESETONWAKEUP= 5;

///////////////////////////
// null entity (actually it is the same like the world entity)

entity null_entity;

///////////////////////////
// error constants

// file handling
float ERR_CANNOTOPEN			= -1; // fopen
float ERR_NOTENOUGHFILEHANDLES 	= -2; // fopen
float ERR_INVALIDMODE 			= -3; // fopen
float ERR_BADFILENAME 			= -4; // fopen

// drawing functions

float ERR_NULLSTRING			= -1;
float ERR_BADDRAWFLAG			= -2;
float ERR_BADSCALE			= -3;
//float ERR_BADSIZE			= ERR_BADSCALE;
float ERR_NOTCACHED			= -4;

float GECKO_BUTTON_DOWN 		= 0;
float GECKO_BUTTON_UP 			= 1;
// either use down and up or just press but not all of them!
float GECKO_BUTTON_PRESS 		= 2;
// use this for mouse events if needed?
float GECKO_BUTTON_DOUBLECLICK 	= 3;

/* not supported at the moment
///////////////////////////
// os constants

float OS_WINDOWS	= 0;
float OS_LINUX		= 1;
float OS_MAC		= 2;
*/

/*
float drawfont; // set this to one of the following for draw text routines to work with another font
float FONT_DEFAULT		= 0;
float FONT_CONSOLE		= 1;
float FONT_SBAR			= 2;
float FONT_NOTIFY		= 3;
float FONT_CHAT			= 4;
float FONT_CENTERPRINT	= 5;
float FONT_INFOBAR		= 6;
float FONT_MENU			= 7;
float FONT_USER0		= 8; // add to this the index, like FONT_USER+3 = user3. At least 8 of them are supported.
*/
