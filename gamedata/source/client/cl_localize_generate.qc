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
void GenerateMenuFiles() =
{
	LOCALIZE_GENERATING = true;
	ResetLanguageBuffers();
	
	active_menu = spawn();

	Draw_MissionEditorMovingEntity();
	DrawObjectives();
	DrawHudMissionStats();
	Draw_LimitedVersion_EntCount();
	Draw_DeathMenu();
	Draw_GameOver_Player();
	Draw_GameOver_All();
	Draw_MissionScores();
	Draw_MissionBriefing();
	Draw_SetParticleEffect();
	Draw_SetAmbientSound();
	Draw_MissionEditor_Effects();
	Draw_WaitingForServerMenu();
	Draw_MissionEditor_SetActivationTime();
	Draw_MissionEditor_SetTriggerDelayTime();
	Draw_MissionEditor_SetMaxTriggers();
	Draw_MissionEditorEntityOptions();
	Draw_MisionEditor_LinkMessage_LinkSuccessful();
	Draw_MisionEditor_LinkMessage_CantLinkToSelf();
	Draw_MissionEditorSetTeleporterDestination();
	Draw_MissionEditorSetTrigger();
	Draw_MissionEditorSetTriggerTarget();
	Draw_MissionEditorSetTriggerAssociation();
	Draw_MissionEditorPlacingEntity();
	Draw_MissionEditor_Crystals();
	Draw_MissionEditor_Weapons();
	Draw_MissionEditor_Pickups();
	Draw_MissionEditor_Enemies();
	Draw_MissionEditor_Friendlies();
	Draw_MissionEditor_Objects();
	Draw_MissionEditor_Stones();
	Draw_MissionEditor_EnvCrystals();
	Draw_MissionEditor_Stalagmites();
	Draw_MissionEditor_Volcanoes();
	Draw_MissionEditor_Roadblocks();
	Draw_MissionEditor_RockFormations();
	Draw_MissionEditor_Trees();
	Draw_MissionEditor_Grass();
	Draw_MissionEditor_Plants();
	Draw_MissionEditor_Equipment();
	Draw_MissionEditor_Structures();
	Draw_MissionEditor_Vehicles();
	Draw_MissionEditor_Environment();
	Draw_MissionEditor_CTF();
	Draw_SaveMissionConfirmation();
	Draw_OverwriteMissionConfirmation();
	Draw_SaveMissionAs_MissingCampaign();
	Draw_SaveMissionAs_MissingMission();
	Draw_SaveMissionAsConfirmation();
	SetNewCampaignName_CampaignExists();
	Draw_SetNewCampaignName();
	Draw_CampaignList();
	Draw_SetMissionName();
	Draw_SaveMissionAs();
	Draw_ReloadAllConfirmation();
	Draw_DeleteAllConfirmation();
	Draw_EditMissionBriefing();
	Draw_EditObjective();
	Draw_ObjectiveList();
	Draw_MissionEditor_SetMapTime();
	Draw_MissionEditor();
	Draw_MusicTrackList();
	Draw_MissionEditorSetAIPatrolPath();
	Draw_MissionEditor_PlacingPath();
	Draw_MissionEditor_Pathing();
	Draw_MissingMinimapMenu();
	Draw_AdminPlayerList();
	Draw_GetServerPassword();
	Draw_AdminAccessDenied();
	Draw_LightEditorConfirmation();
	DrawMapKey('0 0 0');
	Draw_GetJoinPassword();
	Draw_VoteMenu();
	Draw_GameModeList();
	Draw_MissionList();
	Draw_VoteStats();
	Draw_KickMenu();
	Draw_KickConfirm();
	Draw_EditorOptions();
		
	ListOption_AdminPlayerList_Local(0);
	CreateObjectiveCompleteCenterprint(string_null);
	GetCenterPrintMessage(0);
	DrawKillMultipleAnnouncement(0, 0);
	DrawActiveTerminal();
	GetObjectName(0, 0);
	SetScoreDisplayInfo(world, world, 0, 0, true);
	
	ResetLanguageBuffers();
	
	remove(active_menu);
	active_menu = world;
	
	LOCALIZE_GENERATING = false;
}