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
void Precache_Models() =
{
	local float minval;

	precache_model("null");
	
	precache_model("models/player/fps_reticle.dpm");
	
	precache_model("models/player/player.dpm");
	precache_model("models/player/player_dead1.dpm");	
	precache_model("models/player/player_gibs1.dpm");
	
	precache_model("models/enemies/gibs/tank_gibs1.dpm");
//	if(CODEBASE != CLIENTCODE)
//		return;

//	precache_model("models/player/player_gibs1.dpm");

//	precache_model("models/objects/nav_cell.dpm");
	precache_model("models/misc/waypoint2.dpm");
	precache_model("models/misc/waypoint.dpm");
	
	precache_model("models/weapons/impact_sphere.dpm");
	precache_model("models/sfx/explosion1.dpm");	

	precache_model("models/weapons/spread.dpm");
	precache_model("sprites/spread_explosion.spr32");
	precache_model("sprites/plasma_explosion.spr32");	
//	precache_model("sprites/spread_impact.spr32");
	precache_model("models/weapons/proton_torpedo.dpm");
	precache_model("models/weapons/rocket.dpm");
	
	precache_model("models/enemies/rift_ht2.dpm");
	precache_model("models/enemies/rift2.dpm");
	
	minval = 2;
	if(EPISODE >= minval)
	{
		precache_model("models/weapons/hmissile.dpm");	
		precache_model("models/weapons/mirv.dpm");	
	}
}

void Precache_Models_OLD() =
{
	precache_model("null");

	//player
	
	precache_model("models/weapons/impact_sphere.dpm");
	
	precache_model("models/player/player.dpm");
	precache_model("models/player/player_dead1.dpm");	
	precache_model("models/player/player_gibs1.dpm");
//	precache_model("models/player/cannon.dpm");
//	precache_model("models/player/mirv_mortar.dpm");	
	
	//weapons
	precache_model("models/weapons/hmissile.dpm");
	precache_model("models/weapons/rocket.dpm");
	precache_model("models/weapons/mirv.dpm");	
	precache_model("models/weapons/spread.dpm");
	precache_model("models/weapons/proton_torpedo.dpm");	
//	precache_model("models/weapons/plasma.dpm");
	precache_model("sprites/ball.spr32");	
	precache_model("models/weapons/spread_impact.dpm"); // CLIENT ONLY
	precache_model("models/weapons/minigun_sparks.dpm"); // CLIENT ONLY
	precache_model("sprites/spread_impact.spr32"); // CLIENT ONLY
	precache_model("sprites/plasma_explosion.spr32"); // CLIENT ONLY
	precache_model("sprites/spread_explosion.spr32"); // CLIENT ONLY
	precache_model("models/weapons/mirv_reticle.dpm"); // CLIENT ONLY
	
	//items
	precache_model("models/items/crystal.dpm");
//	precache_model("models/items/armorshard.dpm");
	precache_model("models/items/armor_small.dpm");
	precache_model("models/items/armor_big.dpm");
	precache_model("models/items/orb1.dpm");
	
//	precache_model ("models/weapons/cell_pack.dpm");	
	precache_model("models/weapons/pickup_shockwave.dpm");
	precache_model("models/weapons/pickup_stormplow.dpm");
	precache_model("models/weapons/pickup_stormspread.dpm");
	precache_model("models/weapons/pickup_stormshield.dpm");	
	precache_model("models/weapons/pickup_thunderbolt.dpm");
	precache_model("models/weapons/pickup_beamcannon.dpm");	
	precache_model("models/weapons/mirv_pickup.dpm");
	precache_model("models/weapons/rocket_pack.dpm");
//	precache_model ("models/weapons/bullet_pack.dpm");	
	precache_model ("models/weapons/hmissiles_pack.dpm");

/*	precache_model ("models/items/crystal_white.dpm");
	precache_model ("models/items/crystal_blue.dpm");
	precache_model ("models/items/crystal_red.dpm");
	precache_model ("models/items/crystal_higgs.dpm");
	precache_model ("models/items/powerup.dpm");*/

	//enemies
	precache_model("models/enemies/light_tank/light_tank.dpm");
	precache_model("models/enemies/light_tank/light_tank_dead1.dpm");
	precache_model("models/enemies/medium_tank/medium_tank.dpm");	
	precache_model("models/enemies/medium_tank/medium_tank_dead1.dpm");
	precache_model("models/enemies/heavy_tank/heavy_tank.dpm");
	precache_model("models/enemies/heavy_tank/heavy_tank_dead1.dpm");
	precache_model("models/enemies/heavy_tank/ht_minigun_turret.dpm");
	precache_model("models/enemies/heavy_tank/ht_plasma_turret_L.dpm");
	precache_model("models/enemies/heavy_tank/ht_plasma_turret_R.dpm");	
	precache_model("models/enemies/lightning_tank/lightning_tank.dpm");	
	precache_model("models/enemies/lightning_tank/lightning_tank_dead1.dpm");	
	precache_model("models/enemies/carrier_tank/carrier_tank.dpm");
	precache_model("models/enemies/carrier_tank/carrier_tank_dead1.dpm");
	precache_model("models/enemies/carrier_tank/carrier_tank_chull_dead1.dpm");
	precache_model("models/enemies/carrier_tank/carrier_turret.dpm");
	precache_model("models/enemies/flier/flier.dpm");
	precache_model("models/enemies/destroyer/destroyer_tank.dpm");
	precache_model("models/enemies/destroyer/destroyer_tank_dead1.dpm");
	precache_model("models/enemies/destroyer/destroyer_tank_chull_dead1.dpm");
	precache_model("models/enemies/destroyer/dt_pturret_l.dpm");
	precache_model("models/enemies/destroyer/dt_pturret_r.dpm");
	precache_model("models/enemies/destroyer/dt_rturret.dpm");
	precache_model("models/enemies/turrets/turret_base.dpm");
	precache_model("models/enemies/turrets/turret_base_dead1.dpm");	
	precache_model("models/enemies/turrets/turret_base_chull.bsp");
	precache_model("models/enemies/turrets/turret_plasma.dpm");	
	precache_model("models/enemies/turrets/turret_plasma_dead1.dpm");
	precache_model("models/enemies/turrets/turret_beam.dpm");
	precache_model("models/enemies/turrets/turret_beam_dead1.dpm");
	precache_model("models/enemies/turrets/turret_rocket.dpm");
	precache_model("models/enemies/turrets/turret_rocket_dead1.dpm");
	precache_model("models/enemies/turrets/turret_repair.dpm");
	precache_model("models/enemies/turrets/turret_repair_dead1.dpm");
	precache_model("models/enemies/gibs/tank_gibs1.dpm");


	//misc
	precache_model("models/objects/pressure_plate/pressure_plate.dpm");	
	precache_model("models/objects/force_field/force_field_on_chull.bsp");
	precache_model("models/objects/force_field/force_field_off_chull.bsp");	
	precache_model("models/objects/force_field/force_field_emitter.dpm");
	precache_model("models/objects/force_field/force_field2_on_chull.bsp");
	precache_model("models/objects/force_field/force_field2_off_chull.bsp");	
	precache_model("models/objects/force_field/force_field2_emitter.dpm");
	precache_model("models/objects/exit_pad/exit_pad.dpm");
	precache_model("models/objects/exit_pad/exit_pad_chull.bsp");
	precache_model("models/objects/spawn_pad/spawn_pad.dpm");
	precache_model("models/objects/spawn_pad/spawn_pad_chull.bsp");
	precache_model("models/objects/teleport/teleport.dpm");
	precache_model("models/objects/teleport/teleport_chull.bsp");
	precache_model("models/objects/stones/stones.dpm");
	precache_model("models/objects/stones/stone_group.dpm");
	precache_model("models/objects/stones/stone1.dpm");
	precache_model("models/objects/stones/stone1_b.dpm");
	precache_model("models/objects/stones/stone1_s.dpm");
	precache_model("models/objects/stones/stone1_chull.bsp");
	precache_model("models/objects/stones/stone1_b_chull.bsp");
	precache_model("models/objects/stones/stone1_s_chull.bsp");
	precache_model("models/objects/stones/stone2.dpm");
	precache_model("models/objects/stones/stone2_b.dpm");
	precache_model("models/objects/stones/stone2_chull.bsp");
	precache_model("models/objects/stones/stone2_b_chull.bsp");
	precache_model("models/objects/stones/stone3.dpm");
	precache_model("models/objects/stones/stone3_b.dpm");
	precache_model("models/objects/stones/stone3_s.dpm");
	precache_model("models/objects/stones/stone3_chull.bsp");
	precache_model("models/objects/stones/stone3_b_chull.bsp");
	precache_model("models/objects/stones/stone3_s_chull.bsp");
	precache_model("models/objects/stones/stone4.dpm");
	precache_model("models/objects/stones/stone4_b.dpm");
	precache_model("models/objects/stones/stone4_chull.bsp");
	precache_model("models/objects/stones/stone4_b_chull.bsp");
	precache_model("models/objects/stones/stones_dead.dpm");
	precache_model("models/objects/stones/stones_dead_chull.dpm");
	precache_model("models/objects/stones/stones_dead_gib.dpm");
	precache_model("models/objects/crystals/cave_crystals.dpm");	
	precache_model("models/objects/crystals/cave_crystals_chull.bsp");	
	precache_model("models/objects/crystals/cave_crystals_dead1.dpm");
	precache_model("models/objects/crystals/cave_crystals_gibs.dpm");
	precache_model("models/objects/stalagmites/stalagmites1.dpm");	
	precache_model("models/objects/stalagmites/stalagmites1_chull.bsp");	
	precache_model("models/objects/stalagmites/stalagmites2.dpm");
	precache_model("models/objects/stalagmites/stalagmites2_chull.bsp");
	precache_model("models/objects/volcano/volcano1.dpm");
	precache_model("models/objects/volcano/volcano1_medium.dpm");
	precache_model("models/objects/volcano/volcano1_small.dpm");
	precache_model("models/objects/volcano/volcano1_chull.bsp");
	precache_model("models/objects/volcano/volcano1_medium_chull.bsp");
	precache_model("models/objects/volcano/volcano1_small_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock1.dpm");
	precache_model("models/objects/roadblocks/roadblock1_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock1_dropped.dpm");
	precache_model("models/objects/roadblocks/roadblock1_dropped_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock2.dpm");
	precache_model("models/objects/roadblocks/roadblock2_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock2_dropped.dpm");
	precache_model("models/objects/roadblocks/roadblock2_dropped_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock3.dpm");
	precache_model("models/objects/roadblocks/roadblock3_chull.bsp");
	precache_model("models/objects/roadblocks/roadblock4.dpm");
	precache_model("models/objects/roadblocks/roadblock4_chull.bsp");
	precache_model("models/objects/rock_formations/rock_formation1.dpm");
	precache_model("models/objects/rock_formations/rock_formation1_chull.bsp");
	precache_model("models/objects/plants/palmtree1_med.dpm");
	precache_model("models/objects/plants/palmtree1_med_chull.bsp");
	precache_model("models/objects/plants/palmtree2_med.dpm");
	precache_model("models/objects/plants/palmtree2_med_chull.bsp");
	precache_model("models/objects/plants/palmtree3_med.dpm");
	precache_model("models/objects/plants/palmtree3_med_chull.bsp");
	precache_model("models/objects/plants/palmtree_dead1.dpm");
	precache_model("models/objects/plants/palmtree_gibs.dpm");
	precache_model("models/objects/plants/grass_patch1.dpm");
	precache_model("models/objects/plants/grass_patch2.dpm");
	precache_model("models/objects/plants/grass_patch3.dpm");
	precache_model("models/objects/plants/plant1.dpm");
	precache_model("models/objects/plants/plant1_gibs.dpm");
	precache_model("models/objects/plants/plant1_noflowers.dpm");
	precache_model("models/objects/plants/plant2.dpm");
	precache_model("models/objects/plants/plant2_gibs.dpm");
	precache_model("models/objects/plants/plant3.dpm");
	precache_model("models/objects/plants/plant3_gibs.dpm");
	precache_model("models/objects/plants/cactus1.dpm");
	precache_model("models/objects/plants/cactus1_chull.bsp");
	precache_model("models/objects/plants/cactus2.dpm");
	precache_model("models/objects/plants/cactus2_chull.bsp");
	precache_model("models/objects/plants/cactus3.dpm");
	precache_model("models/objects/plants/cactus3_chull.bsp");
	precache_model("models/objects/plants/cactus4.dpm");
	precache_model("models/objects/plants/cactus4_chull.bsp");
	precache_model("models/objects/plants/cactus_small_dead1.dpm");
	precache_model("models/objects/plants/cactus_big_dead1.dpm");
	precache_model("models/objects/plants/cactus_gibs.dpm");
	precache_model("models/objects/containers/barrel01.dpm");
	precache_model("models/objects/containers/barrel01_chull.bsp");
	precache_model("models/objects/containers/barrel01a.dpm");
	precache_model("models/objects/containers/barrel01a_chull.bsp");
	precache_model("models/objects/containers/barrel02.dpm");
	precache_model("models/objects/containers/barrel02_chull.bsp");
	precache_model("models/objects/containers/container01.dpm");
	precache_model("models/objects/containers/container01_chull.bsp");
	precache_model("models/objects/containers/container02.dpm");
	precache_model("models/objects/containers/container02_chull.bsp");
	precache_model("models/objects/containers/container03.dpm");	
	precache_model("models/objects/containers/container03_chull.bsp");	
	precache_model("models/objects/structures/building01.bsp");
	precache_model("models/objects/structures/building01_dead1.bsp");
	precache_model("models/objects/structures/building02.bsp");
	precache_model("models/objects/structures/building02_dead1.bsp");
	precache_model("models/objects/structures/building03.bsp");
	precache_model("models/objects/structures/building03_dead1.bsp");
	precache_model("models/objects/structures/building04.bsp");
	precache_model("models/objects/structures/building04_dead1.bsp");
	precache_model("models/objects/structures/cooling_tower01.bsp");
	precache_model("models/objects/structures/cooling_tower01_dead1.bsp");
	precache_model("models/objects/structures/cooling_tower02.bsp");
	precache_model("models/objects/structures/cooling_tower02_dead1.bsp");
	precache_model("models/objects/obelisk/obelisk01.dpm");
	precache_model("models/objects/obelisk/obelisk01_chull.bsp");
	precache_model("models/objects/pylon/pylon01.dpm");
	precache_model("models/objects/pylon/pylon_chull.bsp");
	
//	precache_model("models/enemies/rift_ht.spr32");	
//	precache_model("models/enemies/rift_ht.dpm");
	
	precache_model("models/sfx/explosion1.dpm");

	precache_model("sprites/explode1.spr32");	// CLIENT ONLY
	precache_model("sprites/explode1a.spr32");
	precache_model("sprites/explode1b.spr32");	
	precache_model("models/enemies/rift2.dpm");
	precache_model("models/enemies/rift_ht2.dpm");	

	precache_model("models/enemies/group_spawner/group_spawner.dpm");
	precache_model("models/enemies/portal/portal.dpm");
	precache_model("models/blank.mdl");
	
	precache_model("models/misc/waypoint.dpm");
	precache_model("models/misc/waypoint2.dpm");
	
	precache_model("models/editor/pemitter.dpm");
	precache_model("models/editor/ambient_sound.dpm");
	
	precache_model("models/objects/nav_cell.dpm");
	
	//temp
	precache_model("sprites/s_explod.spr");
	precache_model("models/weapons/beam.mdl");	
//	precache_model("progs/missile.mdl");
//	precache_model("progs/spike.mdl");

//	precache_model("progs/grenade.mdl");
}

void Precache_Sounds() =
{
	precache_sound("sounds/null.wav");

	// Debris
	precache_sound("sounds/debris/ss_tree_softsurface.wav");
	precache_sound("sounds/debris/ss_debris_cactus.wav");
	precache_sound("sounds/debris/ss_rock_softsurface.wav");
	precache_sound("sounds/debris/ss_crystal_softsurface.wav");
	precache_sound("sounds/debris/ss_metal_softsurface.wav");
	precache_sound("sounds/debris/ss_metal_gib.wav");
	precache_sound("sounds/debris/ss_plant_softsurface.wav");

	// Explosions
	precache_sound("sounds/weapons/explosions/ss_expl_deep2.wav");
	precache_sound("sounds/weapons/explosions/ss_explosion1.wav");
	precache_sound("sounds/weapons/explosions/ss_explosion2.wav");

	// Player
	precache_sound("sounds/player/ss_ship_idle.wav");	
	precache_sound("sounds/player/ss_ship_move.wav");
	precache_sound("sounds/player/ss_ship_land.wav");
	precache_sound("sounds/player/ss_respawn.wav");
	precache_sound("sounds/weapons/beam/ss_ship_beamcannon.wav");
	precache_sound("sounds/weapons/thunderbolt/electric_discharge1.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormplow1.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormplow2.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormplow3.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormplow_rel.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormshield.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormshield_rel.wav");
	precache_sound("sounds/weapons/storm/ss_ship_stormspread.wav");
	precache_sound("sounds/weapons/shockwave/ss_ship_shockwave.wav");
	precache_sound("sounds/weapons/miniguns/ss_ship_gun1.wav");
	precache_sound("sounds/weapons/miniguns/ss_ship_gun2.wav");
	precache_sound("sounds/weapons/miniguns/ss_ship_gun3.wav");
	precache_sound("sounds/weapons/miniguns/ss_ship_gun4.wav");
	precache_sound("sounds/weapons/miniguns/ss_ship_gun_rel.wav");		

	precache_sound("sounds/weapons/flack/ss_flak_1.wav");
	precache_sound("sounds/weapons/flack/ss_flak_2.wav");
	precache_sound("sounds/weapons/flack/ss_flak_3.wav");
	precache_sound("sounds/weapons/flack/ss_flak_4.wav");	
	
	precache_sound("sounds/weapons/rockets/ss_ship_homingmissile_fire.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_homingmissile_jet.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_homingmissile_explosion.wav");	

	precache_sound("sounds/weapons/rockets/ss_ship_MIRV_launch.wav");		
	precache_sound("sounds/weapons/rockets/ss_ship_MIRV_explosions.wav");	
		
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_triggershort.wav");		
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_explosion1.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_explosion2.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_explosion3.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_explosion4.wav");	
	precache_sound("sounds/weapons/rockets/ss_ship_rocketpod_explosion5.wav");		

	// Items
	precache_sound("sounds/items/ss_weapns.wav");
	precache_sound("sounds/items/ss_armor_full.wav");
	precache_sound("sounds/items/ss_armor_plate.wav");
	precache_sound("sounds/items/ss_crystal_blue3.wav");
	precache_sound("sounds/items/ss_crystal_green3.wav");
	precache_sound("sounds/items/ss_crystal_red3.wav");
	precache_sound("sounds/items/ss_extralife.wav");
	precache_sound("sounds/items/ss_shield.wav");
	
	// Equipment
	precache_sound("sounds/equipment/ss_obelisk_loop.wav");
	precache_sound("sounds/equipment/ss_incinerator_loop.wav");
	precache_sound("sounds/equipment/ss_exitpad.wav");
	precache_sound("sounds/equipment/ss_forcefield_hum.wav");
	precache_sound("sounds/equipment/ss_forcefield_open.wav");
	precache_sound("sounds/equipment/ss_forcefield_close.wav");	
	precache_sound("sounds/equipment/ss_pressurepad_push.wav");
	precache_sound("sounds/equipment/ss_pylon_hum.wav");
	precache_sound("sounds/equipment/ss_teleport.wav");

	// Ambient
	precache_sound("sounds/ambient/ss_ambience_desert_high.ogg");
	precache_sound("sounds/ambient/ss_ambience_desert_low.ogg");
	precache_sound("sounds/ambient/ss_ambience_fire.wav");
	precache_sound("sounds/ambient/ss_ambience_metalbridge.wav");
	precache_sound("sounds/ambient/ss_rock_hardsurface.wav");

	// Enemies
	precache_sound("sounds/enemies/light_tank/ss_lighttank_idle.wav");
	precache_sound("sounds/enemies/light_tank/ss_lighttank_move.wav");
	precache_sound("sounds/enemies/light_tank/ss_lighttank_shot.wav");
	precache_sound("sounds/enemies/medium_tank/ss_medtank_idle.wav");
	precache_sound("sounds/enemies/medium_tank/ss_medtank_move.wav");
	precache_sound("sounds/enemies/medium_tank/ss_medtank_shot.wav");
	precache_sound("sounds/enemies/light_plasma_turret/ss_lightturr_rot.wav");
	precache_sound("sounds/enemies/light_plasma_turret/ss_lightturr_shot.wav");
	precache_sound("sounds/enemies/repair_turret/ss_repairbeam.wav");
	precache_sound("sounds/enemies/heavy_beam_turret/ss_heavybeam_rot.wav");
	precache_sound("sounds/enemies/heavy_beam_turret/ss_heavybeam_shot.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_gun1.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_gun2.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_gun3.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_gun4.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_rel.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_idle.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_move.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_shot.wav");
	precache_sound("sounds/enemies/heavy_tank/ss_heavytank_turr_rot.wav");
	precache_sound("sounds/enemies/lightning_tank/ss_lightning_shot.wav");

	precache_sound("sounds/weapons/plasma/plasma_shot1.wav");
	precache_sound("sounds/weapons/thunderbolt/electric_discharge1.wav");
//	precache_sound("sounds/player/jet_engine1.wav");	
	precache_sound("sounds/weapons/explosions/explosion1.wav");
	precache_sound("sounds/weapons/rockets/rocket1.wav");
	precache_sound("sounds/weapons/rockets/rocket_fly.wav");
	precache_sound("sounds/items/weapon_pickup1c.wav");
	precache_sound("sounds/items/ss_items_spawn.wav");
	precache_sound("sounds/weapons/beam/beam1f.wav");	
	
	precache_sound("sounds/player/ss_player_hit.wav");
	precache_sound("sounds/enemies/ss_enemy_hit.wav");	
	
	precache_sound("sounds/enemies/portal/ss_portal_activate.wav");
	precache_sound("sounds/enemies/portal/ss_portal_dying.wav");
	precache_sound("sounds/enemies/portal/ss_portal_idle.wav");
	precache_sound("sounds/enemies/portal/ss_portal_spawning.wav");	
	
	precache_sound("sounds/equipment/ss_corr_fusioncore_hum.wav");
	precache_sound("sounds/equipment/ss_fusioncorerack_hum.wav");
	precache_sound("sounds/equipment/ss_incinerator_activate.wav");
	precache_sound("sounds/equipment/ss_incinerator_deactivate.wav");
	precache_sound("sounds/items/ss_datakey_2_pickup.wav");
	precache_sound("sounds/items/ss_fusioncore_pickup.wav");	
	
	precache_sound("sounds/equipment/ss_teleport_error.wav");
	
	precache_sound("sounds/equipment/ss_terminal_error_1.wav");
	precache_sound("sounds/equipment/ss_terminal_activate.wav");
	precache_sound("sounds/equipment/ss_terminal_deactivate.wav");
	precache_sound("sounds/equipment/ss_terminal_hacking.wav");
	precache_sound("sounds/equipment/ss_terminal_hum.wav");
	precache_sound("sounds/equipment/ss_terminal_accept_2.wav");
	
	precache_sound("sounds/equipment/ss_evaporator_idle.wav");
	precache_sound("sounds/equipment/ss_evaporator_start_withloop.wav");
//	precache_sound("sounds/equipment/ss_evaporator_operating_fullforce.wav");
	precache_sound("sounds/equipment/ss_evaporator_operating.wav");
	precache_sound("sounds/equipment/ss_evaporator_deactivate.wav");	
	
	precache_sound("sounds/equipment/ss_bigpump_deactivate.wav");
	precache_sound("sounds/equipment/ss_bigpump_idle.wav");
	precache_sound("sounds/equipment/ss_bigpump_start_withloop.wav");
	precache_sound("sounds/equipment/ss_bigpump_operating.wav");
	
	precache_sound("sounds/equipment/ss_refinery_deactivate.wav");
	precache_sound("sounds/equipment/ss_refinery_idle.wav");
	precache_sound("sounds/equipment/ss_refinery_start_withloop.wav");
	precache_sound("sounds/equipment/ss_refinery_operating.wav");
	
	precache_sound("sounds/enemies/destroyer/ss_destroyer_cannon_charge.wav");
	precache_sound("sounds/enemies/destroyer/ss_destroyer_move.wav");
	precache_sound("sounds/enemies/destroyer/ss_destroyer_cannon_shot.wav");
	precache_sound("sounds/enemies/destroyer/ss_destroyer_idle.wav");
	
	precache_sound("sounds/enemies/carrier/ss_carrier_idle.wav");
	precache_sound("sounds/enemies/carrier/ss_flier_dockin.wav");
	precache_sound("sounds/enemies/carrier/ss_flier_dockout.wav");
	precache_sound("sounds/enemies/carrier/ss_flier_flying.wav");
	precache_sound("sounds/enemies/carrier/ss_carrier_move.wav");
	
	precache_sound("sounds/weapons/shockwave/ss_boss_shockwave.wav");

	precache_sound("sounds/announcements/ss_voice_primary.wav");
	precache_sound("sounds/announcements/ss_voice_secondary.wav");
}
