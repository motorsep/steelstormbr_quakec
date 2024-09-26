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
/////////////////////////////////////////////////////////
// sys constants
///////////////////////////
// key constants

float	time_local;


float	unlocked_fpscamera;


// sounds

float menubuttontype;
float MBT_BASIC		= 0;
float MBT_CONFIRM	= 1;
float MBT_CANCEL	= 2;
float MBT_BACK		= 3;
float MBT_QUIT		= 4;

float SOUND_MOUSEOVERCLICK	= 0;
//float SOUND_SCROLLBARCLICK	= 1;
float SOUND_BASICCLICK		= 2;
float SOUND_CONFIRMCLICK	= 3;
float SOUND_CANCELCLICK		= 4;
float SOUND_BACKCLICK		= 5;
float SOUND_QUITCLICK		= 6;
float SOUND_TYPECLICK		= 7;


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
float FONT_USER1		= 9;
float FONT_USER2		= 10;
float FONT_USER3		= 11;

float findfont(string s) = #356; // find font by fontname and return it's index
float loadfont(string fontname, string fontmaps, string sizes, float slot, float fix_scale, float fix_voffset) = #357; 
// loads font immediately so stringwidth() function can be used just after builtin call
// returns a font slotnum (which is used to set drawfont to)
// first 3 parms are identical to "loadfont" console command ones
// slot could be one of FONT_ constants or result of findfont() or -1 to not use it
// if slot is given, font will be loaded to this slotnum and fontname become new title for it
// this way you can rename user* fonts to something more usable
// fix_* parms let you fix badly made fonts by applying some transformations to them
// fix_scale : per-character center-oriented scale (doesn't change line height at all)
// fix_voffset : vertical offset for each character, it's a multiplier to character height


void Font_Init(float LANGUAGE);


float TEXT_TITLE		= 0;
float TEXT_BODY			= 1;
float TEXT_OPTION		= 2;
float TEXT_INPUT		= 3;

entity	pulldownmenu;

.float	buf_contents;
.float	buf_translation;
.float	buf_list;
.float	buf_items;
.float	buf_textblock;
.float	buf_display;
//.float	hasinputbuffer;

.float	menu_style;
float	STYLE_NONE					= 0;
float	STYLE_SELECTABLE			= 1;
float	STYLE_PRIORITY				= 2;
float	STYLE_CAMERA				= 4;
float	STYLE_PERSPECTIVE			= 8;
float	STYLE_TOOLBAR				= 16;
float	STYLE_STARTFROM_BOTTOMLEFT	= 32;
float	STYLE_PERMENANT				= 64;
float	STYLE_NODIM					= 128;
float	STYLE_SLOWOPEN				= 256;
float	STYLE_FASTCLOSE				= 512;

float	BTTNPRESS_FORWARD;
float	BTTNPRESS_BACK;
float	BTTNPRESS_LEFT;
float	BTTNPRESS_RIGHT;
float	BTTNPRESS_UP;
float	BTTNPRESS_DOWN;

float	activatebuttononmousedown;
float	numericalincrementhasmin;
float	numericalincrementhasmax;
float	numericalincrementmin;
float	numericalincrementmax;
float	keyrepeating;

.vector	view_ofs;	

// appearance flags to be used with menu_appearance, border_appaerance, title_appearance, body_appearance, and option_appearance, not all flags can be used in each area

float	BACKGROUND					= 1;	// specifies that the background will be filled with color												(all but menu) 
float	IMAGE_STRETCH				= 2;	// specifies that any images used will be stretched to fit the area instead of tiled								(all but menu)
float	IMAGE						= 4;	// specifies that an image will be drawn 						(only border needs to check this but images can be used in all areas)
float	TITLE_FOOTER				= 8;	// specifies that a border will be drawn between the title and the body										(border only)
float	BACKGROUND_HIGHLIGHTONLY	= 16;	// specifies that the option background will be filled with color, but only when highlighted							(options only)
float	LIST_HORIZONTAL				= 32;	// specifies that the option list will be formatted horizontally and the menu will also stretch horizontally instead of vertically		(options only)
float	SIZE_MANUAL					= 64;	// specifies that the menu height is not set automatcally (or width in the case that the menu is horizontal) 				(menu only)
float	HIDE_BRIGHTNESS				= 128;	// multiplies all menu colors by menu_hidebrightness when menu is not in focus									(menu only)
float	HIDE_ALPHA					= 256;	// multiplies all menu alpha by menu_hidealpha when menu is not in focus									(menu only)
float	IMAGE_FULLMENU				= 512;	// specifies that title image will cover the whole menu

vector	POS_AUTO			= '-1 -1 0';	// use as a menu position to have the menu automatically set in the top center half of the screen
vector	POS_MAIN_TR			= '320 31 0';	// top right corner of main menu
vector	POS_MAIN_CR			= '225 125 0';
vector	POS_CENTER_RIGHT	= '-3 -1 0';
vector	POS_TOP_RIGHT		= '-3 -2 0';

vector SIZE_AUTO		= '-1 -1 0';
vector SIZE_DEFAULT		= '-2 -2 0';
vector SIZE_FITWIDTH	= '-3 -3 0';

vector SIZE_MAIN_RIGHTPANE;
vector SIZE_MAIN_RIGHTPANE_BOTTOMLESS;
vector		WINDOWSIZE_RIGHTPANE			= '424 0 0';

float		ALIGN_TOP 				= 1;
float		ALIGN_BOTTOM 			= 2;
float		ALIGN_SENDTOBOTTOM		= 3;
float		ALIGN_RIGHT				= 4;
float		ALIGN_LEFT				= 5;
float		ALIGN_TOPLEFT			= 6;

//vector SIZE_MAIN_RIGHTPANE;

.string	m_filename;
float	menu_initializing;
float	menu_closing;
float	menu_appearance;
string	menu_background;
float	menu_drawMOTD;
.float	m_appearance;
float	menu_hidebrightness;
float	menu_hidealpha;
.float	m_hidealpha;
.float	menu_drawaftertime;

vector	border_size;
float	border_appearance;
string	border_image_topleft;
string	border_image_topright;
string	border_image_bottomleft;
string	border_image_bottomright;
string	border_image_top;
string	border_image_bottom;
string	border_image_left;
string	border_image_right;
string	border_image_titleleft;
string	border_image_titleright;
string	border_image_titlefooterleft;
string	border_image_titlefooterright;
string	border_image_titlefooter;
string	border_image_bodyleft;
string	border_image_bodyright;
vector	border_imagecolor;
vector	border_bgcolor;
float	border_imagealpha;
float	border_bgalpha;
float	border_imageflags;
float	border_bgflags;	
	
float	title_appearance;
string	title_image;		
string	title_image_left;
string	title_image_right;
vector	title_image_offset;
vector	title_size;
vector	title_bgspread;
float	title_font;
vector	title_textalignment;
vector	title_textbordersize;
vector	title_fontsize;	
vector	title_fontcolor;
vector	title_imagecolor;
vector	title_bgcolor;	
float	title_fontalpha;
float	title_imagealpha;
float	title_bgalpha;
float	title_fontflags;
float	title_imageflags;
float	title_bgflags;
	
float	body_appearance;
string	body_bgimage;	
vector	body_bgspread;
vector	body_margin;
vector	body_alignment;
float	body_font;
vector	body_textalignment;
vector	body_textbordersize;
vector	body_fontsize;
vector	body_fontcolor;
vector	body_imagecolor;
vector	body_imagebgcolor;
vector	body_bgcolor;	
vector	body_bgimagecolor;
float	body_fontalpha;
float	body_imagealpha;
float	body_imagebgalpha;
float	body_bgalpha;
float	body_bgimagealpha;
float	body_fontflags;
float	body_imageflags;
float	body_imagebgflags;
float	body_bgflags;	
float	body_bgimageflags;

float	body_alignment_horizontal_old;
vector	body_fontsize_old;
vector	body_fontcolor_old;
vector	body_textalignment_old;
vector	body_textbordersize_old;
float	body_imagealpha_old;

vector	option_pos;
	
float	option_appearance;
string	option_image;		
string	option_image_left;
string	option_image_right;
string	option_image_highlight;
string	option_image_left_highlight;
string	option_image_right_highlight;
string	option_image_selected;
vector	option_image_selected_offset;
vector	option_size;
vector	option_size_selectionbox;
float	option_spacing;	
float	option_infospacing;
string	option_sliderimage;
string	option_sliderhandleimage;
float	option_sliderspacing;
float	option_sliderinfospacing;
float	option_font;
vector	option_textalignment;
vector	option_textbordersize;
vector	option_fontsize;	
vector	option_fontcolor;
vector	option_slider_fontsize;
vector	option_imagecolor;
vector	option_slidercolor;
vector	option_sliderhandlecolor;
vector	option_bgcolor;
vector	option_fontcolor_highlight;
vector	option_imagecolor_highlight;
vector	option_slidercolor_highlight;
vector	option_sliderhandlecolor_highlight;
vector	option_bgcolor_highlight;
float	option_fontalpha;
float	option_imagealpha;
float	option_imagealpha_highlight;
float	option_slideralpha;
float	option_slideralpha_highlight;
float	option_sliderhandlealpha;
float	option_sliderhandlealpha_highlight;
vector	option_slider_alignment;
float	option_bgalpha;
float	option_fontflags;
float	option_imageflags;
float	option_bgflags;	

string	scrollbar_toparrowimage;
string	scrollbar_bottomarrowimage;
string	scrollbar_image;
string	scrollbar_handleimage;
float	scrollbar_width;

vector	bottombutton_ofs;
vector	bottombutton_pre_option_pos;

vector	incrementcontrol_fontsize;

float	input_font;
vector	input_fontsize;
vector	input_fontcolor;

//float	fontsize_multiplier;
//float	fontsize_multiplier_default;
//float	fontsize_multiplier_menu;
//float	fontsize_multiplier_user0;

//float	fontoffset_default;
//float	fontoffset_menu;
//float	fontoffset_user0;

//float	fontlinespacing;
//float	fontlinespacing_default;
//float	fontlinespacing_menu;
//float	fontlinespacing_user0;

vector	title_fontsize_base;
vector	body_fontsize_base;
vector	option_fontsize_base;
vector	input_fontsize_base;

vector	option_textalignment_old;
float	option_size_width_old;
float	option_size_height_old;
float	option_spacing_old;
vector	option_fontsize_old;
string	option_image_old;
string	option_image_highlight_old;

float	CURSOROVERMENU;

string	slider_cvar;
//string	slider_currentcvar;
float	slider_min;
//float	slider_max;
float	slider_increments;
float	slider_incrementsize;
float	slider_currentpos;

void() ApplyHideValues;
void() Menu_Defaults;

/*string		SEP_QUOTE	= "\"";
string		SEP_SPACE	= " ";
string		SEP_COLON	= ":";
string		SEP_EQUAL	= "=";
string		SEP_SEMI	= ";";
string		SEP_TAB		= "	";
string		SEP_A		= "…";*/

//string(string s) strtolower = #480; // returns the passed in string in pure lowercase form
//string(string s) strtoupper = #481; // returns the passed in string in pure uppercase form

//vector msize;	// for testing

float	DRAWMOUSE;
float	DRAWMOUSE_FORCEHIDE;
vector	mousepos;
vector	vid_size;
vector	vid_size_norm;
vector	vid_res;
//float	vid_pixelheight;
float menuActive;
float menuPrevTime;
float time;
float frametime;
// demo text
string msg;
float msgtime;
.float	drawinglist;
.float	drawingscrollbar;

float	slider_current;
float	slider_active;
var void() SliderRules;
var string(float val) ReadoutRules;

.vector		scrollbar_boxpos[5];
.vector		scrollbar_boxsize[5];
.vector		scrollbar_pos[5];
.vector		scrollbar_handlesize[5];
.vector		scrollbar_size[5];
.vector		scrollbar_ofs[5];
.vector		oldscrollbar_ofs;
.float		scrollbar_height[5];
.float		scrollbar_alignment[5];
float		WINDOWSCROLL;
vector		mousedrag_ofs;
float		scrollbar_incrementsize;
//vector		mousedrag_start;
float		atbottomofscrollingwindow;
float		gotobottomofscrollingwindow;
float		scrollwindow_up;
float		scrollwindow_down;
.float		scrollboxmeasurement;


float	menu_count;
.float	draworder;
.void()	DrawMenu;
//.void() CloseMenuFunc; // not used
.vector	menusize;
.float	mflags;
//entity	menuundercursor;
entity	world;
//entity	focusmenu;
.float	guiclass;
float		GUI_MENU			= 1;
//.entity	chain;
//.entity	parent;
entity	currentmenu;
entity	active_menu;
.entity	parentmenu;
//entity	focusnewmenu;
//entity	nextfocusmenu;
//void		SUB_Null() = {}
string	string_null;
.vector	menupos;

float		MF_CLOSEABLE			= 1;
float		MF_RESIZEABLE			= 2;
float		MF_INCREMENTAL			= 4;
float		MF_CONFIGURABLE			= 8;
float		MF_FLIPPABLE			= 16;
float		MF_ROTATEABLE			= 32;
float		MF_NOTITLE				= 64;
float		MF_HIDDEN				= 128;
float		MF_CONFIRMATION			= 256;
float		MF_UNLOGGED				= 512;
float		MF_TEMP					= 1024;
float		MF_ADMIN				= 2048;
float		MF_FULLSCREEN			= 4096;

.entity		linkcontrolstomenu;
float		arrowkeymovement;
float		option_current;
float		option_lastclick;
.float		user_current_option;
.float		user_current_selection;
entity		list_menuchain;
.entity		menuchain;
float		option_off;
float		option_last;
float		viewingtextlist;
float		selectedtextlist;
float		allowoptionselection;
float		collapsemenusonaction;

.float		skippedoptionslots;

float		optionalt_up;
float		optionalt_down;
float		optionalt_left;
float		optionalt_right;
float		optionselection_horizontal;
float		current_optionalt_up;
float		current_optionalt_down;
float		current_optionalt_left;
float		current_optionalt_right;
float		current_optionselection_horizontal;	

float		option_current_sendtobottomoflist;

float		optionnum_min;
float		optionnum_max;

.float		page_current;
.float		page_total;

//float	total_args;
//float	count_args;

//string	mission_mapfile[100];
//string	mission_objectfile[100];
//string	gliststring_filenames;
//string	campaign_path;
//string	mission_path;

.string	bodystring;
//.string	liststring;
//.string liststring2;
.string	listitemstring;
.float	listid;

float	connected;


vector	lastimagepos;
vector	lastimagesize;
vector	active_image_pos;
//.float	errorimgnum;

//float	mousedrag;

float		NUM_GAMECONTROLS = 43;
float		cl_button;
float		cl_release;
float		cl_buttondown[NUM_GAMECONTROLS];
float		cl_lastbutton;
float		cl_button_ucs;
float		cl_lastbutton_ucs;
float		cl_button_ucs_vkb;
float		keyrepeattime;
float		dontclearbuttons;

//float	clearmenusatendofframe;

.void()	CloseMenuFunc;
.void() ESCFunc;

//float	zones;

string	menu_func;

float	inputstring_shift;
float	inputstring_shift_disable;

float	active_input;
float	active_vkb;
float	vkb_uppercase;
float	active_textblock;
float	input_current;

float	INPUTTYPE_ALL		= 1; // all characters
float	INPUTTYPE_NUMERICAL	= 2; // numbers only
float	INPUTTYPE_TEXT		= 3; // numbers letters and spaces

float	maxinputchars;
float	input_cursorpos;
vector	input_cursorscreenpos;
float	textcursor_blinktime;
float	textcursor_nodraw;
//float		cl_button_ucs;

float	adminmode;
entity	menu_death;

.float		buf_textblock_objectives_primary[20];
.float		buf_textblock_objectives_secondary[20];

.entity		targetent;

void CloseMenu();
void ClosePulldownMenu();

void Menu_Start(string title, vector pos, vector bsize, string filename);
//void ToggleESCMenu();
//float SH_CursorInsideBox(vector pos, float width, float height);
void ClearAllInputValues();
//void SetFont(float texttype, float fontnum);
//vector DrawFontSize(vector fontsize);
//void DrawString(vector pos, string text, vector fontsize, vector rgb, float alph, float flag);
void Menu_Image_Bordered(vector pos, string imgleft, string imgright, string imgcenter, vector imgboxsize, vector imgcolor, float imgalpha, float imgflags, float imgappearance);


// challenges

float		buf_list_challenges;


// localize

float	menu_resetlanguagebuffers;

void GenerateMenuFiles();