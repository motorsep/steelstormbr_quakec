////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

// controls include
#include "c_data.qc"
#include "c_drawspace.qc"
#include "c_container.qc"
#include "c_picture.qc"
#include "c_label.qc"
#include "c_button.qc"
#include "c_grid.qc"
#include "c_group.qc"
#include "c_pageset.qc"
#include "c_trigger.qc"
#include "c_editbox.qc"
#include "c_slider.qc"
#include "c_keyrouter.qc"
#include "c_credits.qc"
#include "c_browser.qc"
#include "c_listbox.qc"

////////////////////////////////////////
// CODE
////////////////////////////////////////

void() Menu_ObjectLib_Init =
{
	// VISUAL
	Menu_Sys_RegisterClass(menu_proc, Object_DrawSpace);
	Menu_Sys_RegisterClass(menu_proc, Object_PageSet);
	Menu_Sys_RegisterClass(menu_proc, Object_Page);
	Menu_Sys_RegisterClass(menu_proc, Object_Picture);
	Menu_Sys_RegisterClass(menu_proc, Object_Label);
	Menu_Sys_RegisterClass(menu_proc, Object_Button);
	Menu_Sys_RegisterClass(menu_proc, Object_Grid);
	Menu_Sys_RegisterClass(menu_proc, Object_Group);
	Menu_Sys_RegisterClass(menu_proc, Object_EditBox);
	Menu_Sys_RegisterClass(menu_proc, Object_Slider);
	Menu_Sys_RegisterClass(menu_proc, Object_Credits);
	Menu_Sys_RegisterClass(menu_proc, Object_Browser);
	Menu_Sys_RegisterClass(menu_proc, Object_ListBox);
	// SPECIAL
	Menu_Sys_RegisterClass(menu_proc, Object_Container);
	Menu_Sys_RegisterClass(menu_proc, Object_KeyRouter);
	Menu_Sys_RegisterClass(menu_proc, Object_Trigger);
	Menu_Sys_RegisterClass(menu_proc, Object_MultiTrigger);
	Menu_Sys_RegisterClass(menu_proc, Object_Hotkey);
	// DATA
	Menu_Sys_RegisterClass(menu_proc, Object_DataEntry_Cvar);
	Menu_Sys_RegisterClass(menu_proc, Object_DataEntry_Temp);
	Menu_Sys_RegisterClass(menu_proc, Object_DataEntry_BindCommand);
	Menu_Sys_RegisterClass(menu_proc, Object_DataSource_Text);
	Menu_Sys_RegisterClass(menu_proc, Object_DataSource_Slider);
	Menu_Sys_RegisterClass(menu_proc, Object_DataSource_List);
	Menu_Sys_RegisterClass(menu_proc, Object_DataSource_ListCombiner);
	Menu_Sys_RegisterClass(menu_proc, Object_DataSource_BindList);
}

void() Menu_ObjectLib_Shutdown =
{
}