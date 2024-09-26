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
#include	"shared_all/sh_all_defs.qc"
#include	"shared_all/sh_all_localize_defs.qc"

#include	"server/sv_gamedefs.qc"

#include	"shared_server_client/sh_sv_cl_defs.qc"
#include	"shared_all/dpextensions.qc"
#include	"shared_server_client/sh_sv_cl_precaches.qc"
#include	"shared_server_menu/sh_sv_m_defs.qc"
#include	"shared_all/sh_all_subs.qc"
#include	"shared_server_client/sh_sv_cl_subs.qc"
#include	"shared_server_menu/sh_sv_m_subs.qc"
#include	"server/sv_subs.qc"
#include	"server/sv_effects.qc"

#include	"shared_all/sh_all_localize.qc"
#include	"server/sv_localize.qc"

#include	"shared_all/sh_all_gamemodes.qc"
#include	"shared_server_client/sh_sv_cl_gamemodes.qc"

#include	"shared_server_menu/sh_sv_m_missions.qc"

#include	"shared_server_client/sh_sv_cl_animations_player.qc"
#include	"shared_server_client/sh_sv_cl_objects.qc"
#include	"shared_server_client/sh_sv_cl_entities.qc"
#include	"shared_server_client/sh_sv_cl_mission.qc"
#include	"shared_server_client/sh_sv_cl_combat.qc"

#include	"server/sv_gamemodes.qc"
#include	"server/sv_user.qc"
#include	"server/sv_lights.qc"
#include	"server/sv_main.qc"
//server/sv_pause.qc
#include	"server/sv_triggers.qc"
#include	"server/sv_mission.qc"
#include	"server/sv_entities.qc"
#include	"server/sv_combat.qc"
#include	"server/sv_items.qc"
#include	"server/sv_weapons.qc"
#include	"server/sv_cells.qc"
#include	"server/sv_ai.qc"
#include	"server/sv_player.qc"
#include	"server/sv_objects.qc"
#include	"server/sv_enemies.qc"
#include	"server/sv_pathing.qc"
#include	"server/sv_admin_entities.qc"
#include	"server/sv_admin.qc"
#include	"server/sv_client.qc"
#include	"server/sv_dummys.qc"
#include	"server/sv_parse.qc"
//server/sv_sprites.qc		// is this used?
#include	"server/sv_train.qc"