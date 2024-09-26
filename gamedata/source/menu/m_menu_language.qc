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
void SetLanguage(float LANGUAGE) =
{
	cvar_set("localize_language", ftos(LANGUAGE));
	Font_Init(LANGUAGE);
}

void SetLanguage_English() =		{	SetLanguage(LANGUAGE_ENGLISH);			}
void SetLanguage_German() =			{	SetLanguage(LANGUAGE_GERMAN);			}
void SetLanguage_French() =			{	SetLanguage(LANGUAGE_FRENCH);			}
void SetLanguage_Spanish_MX() =		{	SetLanguage(LANGUAGE_SPANISH_MX);		}
void SetLanguage_Spanish_ES() =		{	SetLanguage(LANGUAGE_SPANISH_ES);		}
void SetLanguage_Russian() =		{	SetLanguage(LANGUAGE_RUSSIAN);			}
void SetLanguage_Italian() =		{	SetLanguage(LANGUAGE_ITALIAN);			}
void SetLanguage_Polish() =			{	SetLanguage(LANGUAGE_POLISH);			}
void SetLanguage_Portuguese_BR() =	{	SetLanguage(LANGUAGE_PORTUGUESE_BR);	}
void SetLanguage_Portuguese_PT() =	{	SetLanguage(LANGUAGE_PORTUGUESE_PT);	}
void SetLanguage_Japanese() =		{	SetLanguage(LANGUAGE_JAPANESE);			}

void Draw_LanguageMenu() =
{
	local vector option_pos_start;
	
	Menu_Start_ESCMenu("LANGUAGE", POS_MAIN_TR, SIZE_MAIN_RIGHTPANE, __FUNC__);
	option_size_x = 168;
	option_pos_start = option_pos;
	
	
	local string str_english, str_german, str_french, str_spanishmx, str_spanishes, str_russian, str_italian, str_polish, str_portuguesebr, str_portuguesept, str_japanese;
	str_english			= Translate("English");
	str_german			= Translate("German");
	str_french			= Translate("French");
	str_spanishmx		= Translate("Spanish (SP)");
	str_spanishes		= Translate("Spanish (ES)");
	str_russian			= Translate("Russian");
	str_italian			= Translate("Italian");
	str_polish			= Translate("Polish");
	str_portuguesebr	= Translate("Portuguese (BR)");
	str_portuguesept	= Translate("Portuguese (PT)");
	str_japanese		= Translate("Japanese");
	skiptranslation = true;
	
	option_size_selectionbox = option_size;
	option_size_selectionbox_x = option_sliderspacing+36;
	
	Menu_Option_Text(str_english, SetLanguage_English);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_ENGLISH);
	BR();

	Menu_Option_Text(str_french, SetLanguage_French);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_FRENCH);
	BR();
	
	Menu_Option_Text(str_german, SetLanguage_German);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_GERMAN);
	BR();

/*	Menu_Option_Text(str_italian, SetLanguage_Italian);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_ITALIAN);
	BR();*/

	Menu_Option_Text(str_japanese, SetLanguage_Japanese);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_JAPANESE);
	BR();		
	
	Menu_Option_Text(str_polish, SetLanguage_Polish);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_POLISH);
	BR();	
	
/*	Menu_Option_Text(str_portuguesebr, SetLanguage_Portuguese_BR);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_PORTUGUESE_BR);
	BR();	*/	
	
	Menu_Option_Text(str_portuguesept, SetLanguage_Portuguese_PT);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_PORTUGUESE_PT);
	BR();		

	Menu_Option_Text(str_russian, SetLanguage_Russian);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_RUSSIAN);	
	BR();	
	
	Menu_Option_Text(str_spanishmx, SetLanguage_Spanish_MX);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_SPANISH_MX);
	BR();	
	
/*	Menu_Option_Text(str_spanishes, SetLanguage_Spanish_ES);
	option_pos = GetLastLinePos();
	DrawElement_CheckBox(option_pos, option_sliderspacing, cvar("localize_language") == LANGUAGE_SPANISH_ES);
	BR();	*/
	
	skiptranslation = false;
	
	BeginBottomButtons(1);
	DrawElement_BottomButton("Back", CloseMenu, 0, 1, 0, 0, MBT_CANCEL);
	EndBottomButtons();
	
	Menu_End();
}

void Call_LanguageMenu() =	{	SetCurrentMenu(Draw_LanguageMenu);	}