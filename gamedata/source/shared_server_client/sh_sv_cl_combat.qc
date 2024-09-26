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
float CanDamage(entity attacker, entity victim, entity chainedfroment) =
{
	if(attacker.objclass != OBJ_NPC)
	if(attacker.class != CLASS_PLAYER)
		return TRUE;

//	if(victim.health <= 0)
//		return FALSE;
		
	// don't try to hit world
	if(!victim)
		return FALSE;
		
	// don't try to damage the dead	
	if(victim.isdead)
		return FALSE;
		
	// don't try to damage attachments	
	if(IsAttachedAIClass(victim.npcclass))	
		return FALSE;
		
	// don't try to damage team members in teamplay mode
	if(teamplay && !GameMode_NoFriendlyPlayers(gamemode))
	if(victim.team == attacker.team)
		return FALSE;
		
	// don't try to damage invisible (unspawned) ents
	if(victim.onlydrawforadmins)
//	if((victim.triggerentid || victim.istarget) && !victim.istoggled)	
		return FALSE;
		
	// don't spread to attacker, only spread to players and npcs, only spread from players and npcs, don't spread to team members if a team member is damaged	
	if(chainedfroment)
	if((victim.class != CLASS_PLAYER && victim.objclass != OBJ_NPC)
	|| (chainedfroment.class != CLASS_PLAYER && chainedfroment.objclass != OBJ_NPC)
	|| victim == attacker
	|| (victim.team == chainedfroment.team && attacker.team == chainedfroment.team))
		return FALSE;
/*		
	// team games rules
	// never damage a team member if friendly fire is off
	// never chain to a team member if the attacker is also on the same team
	if(GameMode_HasTeams(gamemode))
	if(teamplay || victim.team == chainedfroment.team)
	if(attacker.team == victim.team)
		return FALSE;
*/
/*		
	// coop rules
	// players can't damage other players if friendly fire is off
	// npcs can't chain npcs, and player's can't chain players if the attacker is the same class as the ent the damage is chaining from
	if(!GameMode_PlayerVSPlayer(gamemode))
	if((teamplay && attacker.class == CLASS_PLAYER) || victim.class == chainedfroment.class)
	if(attacker.class == victim.class)
		return FALSE;
*/
	
	return TRUE;
}