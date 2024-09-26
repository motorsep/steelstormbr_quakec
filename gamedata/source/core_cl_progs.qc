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
#include	"shared_server_client/sh_sv_cl_defs.qc"

#include	"client/cl_constants.qc"
#include	"client/cl_builtins.qc"

#include	"shared_all/dpextensions.qc"

#include	"shared_all/sh_all_defs.qc"
#include	"shared_client_menu/sh_cl_m_defs.qc"

#include	"shared_all/sh_all_localize_defs.qc"
#include	"client/cl_localize_defs.qc"
#include	"client/cl_gamedefs.qc"

#include	"shared_server_client/sh_sv_cl_precaches.qc"

#include	"shared_all/sh_all_subs.qc"
#include	"client/cl_subs.qc"
#include	"shared_server_client/sh_sv_cl_subs.qc"

//#include	"shared_all/sh_all_gamemodes.qc"

#include	"client/cl_init.qc"

#include	"shared_all/sh_all_localize.qc"
#include	"shared_client_menu/sh_cl_m_localize.qc"
#include	"client/cl_localize.qc"

#include	"shared_client_menu/sh_cl_m_video.qc"
#include	"shared_client_menu/sh_cl_m_sound.qc"
#include	"shared_client_menu/sh_cl_m_input.qc"
#include	"shared_client_menu/sh_cl_m_menudefaults.qc"
#include	"shared_client_menu/sh_cl_m_draw.qc"
#include	"shared_client_menu/sh_cl_m_tools.qc"
#include	"shared_client_menu/sh_cl_m_mission.qc"
//#include	"shared_client_menu/sh_cl_m_profile.qc"

#include	"shared_all/sh_all_gamemodes.qc";
#include	"shared_server_client/sh_sv_cl_gamemodes.qc";

#include	"client/cl_player_effects.qc"

#include	"shared_server_client/sh_sv_cl_objects.qc"
#include	"shared_server_client/sh_sv_cl_animations_player.qc"
//#include	"shared_server_client/sh_sv_cl_weapons.qc"
#include	"shared_server_client/sh_sv_cl_mission.qc"
#include	"shared_server_client/sh_sv_cl_combat.qc"

#include	"client/cl_chains.qc"
#include	"client/cl_effects.qc"
#include	"client/cl_animations.qc"
#include	"client/cl_input.qc"
#include	"client/cl_radar.qc"
#include	"client/cl_weapons.qc"
#include	"client/cl_mission.qc"
#include	"client/cl_scoreboard.qc"

#include	"shared_server_client/sh_sv_cl_entities.qc"
#include	"client/cl_entities.qc"

#include	"client/cl_main.qc"
#include	"client/cl_addtomenudrawfuncs.qc"
#include	"client/cl_admin.qc"
#include	"client/cl_admin_entities.qc"
#include	"client/cl_mission_editor_music.qc"
#include	"client/cl_mission_editor_effects.qc"
#include	"client/cl_mission_editor_pathing.qc"
#include	"client/cl_mission_editor_menus.qc"
#include	"client/cl_hud.qc"
#include	"client/cl_view.qc"

#include	"client/cl_localize_generate.qc"