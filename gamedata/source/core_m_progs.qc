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
#include	"menu/m_builtin.qc"

#include	"shared_all/sh_all_defs.qc"
#include	"shared_all/sh_all_localize_defs.qc"
#include	"shared_client_menu/sh_cl_m_defs.qc"
#include	"shared_server_menu/sh_sv_m_defs.qc"
#include	"menu/m_defs.qc"

#include	"shared_all/sh_all_subs.qc"
#include	"shared_server_menu/sh_sv_m_subs.qc"

#include	"shared_all/sh_all_localize.qc"
#include	"shared_client_menu/sh_cl_m_localize.qc"
#include	"menu/m_localize.qc"

#include	"shared_all/sh_all_gamemodes.qc"

#include	"shared_server_menu/sh_sv_m_missions.qc"

#include	"shared_client_menu/sh_cl_m_video.qc"
#include	"shared_client_menu/sh_cl_m_sound.qc"
#include	"shared_client_menu/sh_cl_m_input.qc"
#include	"shared_client_menu/sh_cl_m_menudefaults.qc"
#include	"shared_client_menu/sh_cl_m_draw.qc"
#include	"shared_client_menu/sh_cl_m_tools.qc"
#include	"shared_client_menu/sh_cl_m_mission.qc"
//#include	"shared_client_menu/sh_cl_m_profile.qc"

//#include	"menu/m_compatibility.qc"
#include	"menu/m_commands.qc"
#include	"menu/m_menu_campaigneditor.qc"
#include	"menu/m_menu_serverlist.qc"
#include	"menu/m_menu_profile.qc"
#include	"menu/m_menu_system.qc"
#include	"menu/m_menu_controls.qc"
#include	"menu/m_menu_language.qc"
#include	"menu/m_quitstrings.qc"
#include	"menu/m_menus.qc"
#include	"menu/m_main.qc"

#include	"menu/m_localize_generate.qc"