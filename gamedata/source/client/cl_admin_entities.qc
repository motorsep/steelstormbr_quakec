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
void ClearObjectLinkingData() =
{
//	linkingportal = false;
//	linkingforcefield = false;
	linkingobj = false;
	assigningaipatrolpath = false;	
	ObjectLinkFunc = SUB_Null;
	LinkRules = SUB_Null;
}

void SetTeleporterDestination() =
{
	if(hover_ent.owner == admin_editingent.owner)
		SetCurrentMenu(Draw_MisionEditor_LinkMessage_CantLinkToSelf);
	else
	if(hover_ent.objclass == OBJ_TELEPORTER)
	{
		admin_editingent.owner.targetentid = hover_ent.owner.entid;
		CommitObject(admin_editingent);
		CloseMenu();	
		SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
	}
}

/*void Menu_Portal_ChooseDestinationConfirm() =
{
//	if(admin_editingent.entid)
//		DrawConfirmationMenu("Set as portal destination?\n", SetPortalDestination);
//	else
//		DrawConfirmationMenu("Destination portal must exist on the server.\n\nCommit the target then try again.\n", CloseAdminMenu);
}*/

/*void Portal_ChooseDestinationConfirm() =
{
	admin_editingent = hover_ent.owner;
//	SetCurrentWindow('220 107.7 0', Menu_Portal_ChooseDestinationConfirm, SUB_Null, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);
}*/

float LinkRules_Teleporter(entity e) =
{
	if(e.objclass == OBJ_TELEPORTER)
		return true;
		
	return false;
}

void Portal_ChooseDestination() =
{
	SetCurrentMenu(Draw_MissionEditorSetTeleporterDestination);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetTeleporterDestination;
	LinkRules = LinkRules_Teleporter;
	linkingobj = true;
}

/*void AlignForcefields(entity frame_a, entity frame_b) =
{
	local vector forwardang;
	
	forwardang = frame_b.origin - frame_a.origin;
	forwardang = vectoangles(forwardang);
	
	frame_a.angles_y = forwardang_y;
	frame_b.angles_y = BindAngle(0, forwardang_y - 180, 360);
}*/

void SetObjectTrigger() =
{
	admin_editingent.owner.triggerentid = hover_ent.owner.entid;
	CommitObject(admin_editingent);
	CloseMenu();	
	SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
}

void SetObjectTriggerTarget() =
{
	admin_editingent.owner.targetentid = hover_ent.owner.entid;
	CommitObject(admin_editingent);
	CloseMenu();	
	SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
}

void SetObjectTriggerTarget_StageTwo() =
{
	admin_editingent.owner.targetstagetwoentid = hover_ent.owner.entid;
	CommitObject(admin_editingent);
	CloseMenu();	
	SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
}

void SetObjectTriggerTarget_StageThree() =
{
	admin_editingent.owner.targetstagethreeentid = hover_ent.owner.entid;
	CommitObject(admin_editingent);
	CloseMenu();	
	SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
}

void SetObjectTriggerAssociation() =
{
	admin_editingent.owner.associationentid = hover_ent.owner.entid;
	CommitObject(admin_editingent);
	CloseMenu();	
	SetCurrentMenu(Draw_MisionEditor_LinkMessage_LinkSuccessful);
}

void Object_ClearTrigger() =	{	admin_editingent.owner.triggerentid = 0;	CommitObject(admin_editingent);		}
void Object_ClearTriggerTarget() =	{	admin_editingent.owner.targetentid = 0;	CommitObject(admin_editingent);		}
void Object_ClearTriggerTargetStageTwo() =	{	admin_editingent.owner.targetstagetwoentid = 0;	CommitObject(admin_editingent);	}
void Object_ClearTriggerTargetStageThree() =	{	admin_editingent.owner.targetstagethreeentid = 0;	CommitObject(admin_editingent);	}
void Object_ClearTriggerAssociation() =	{	admin_editingent.owner.associationentid = 0;	CommitObject(admin_editingent);		}

float LinkRules_Object(entity e) =
{
	if(e.objclass == OBJ_PRESSUREPLATE
	|| e.objclass == OBJ_NPC
	|| e.objclass == OBJ_PORTAL
	|| e.objclass == OBJ_CRYSTAL
	|| (e.objclass == OBJ_STRUCTURE
		&& (e.variant != STRUCTURE_GASPUMP))
	|| e.objclass == OBJ_EQUIPMENT
	|| e.objclass == OBJ_EQUIPMENT_MED
	|| e.objclass == OBJ_EQUIPMENT_BIG
	|| e.objclass == OBJ_TERMINAL
	|| e.objclass == OBJ_TRIGGERRELAY
	|| e.objclass == OBJ_PATH
	|| e.objclass == OBJ_FUSIONCORERACK)
		return true;
		
	return false;
}

float LinkRules_Targets(entity e) =
{
	if(e.objclass == OBJ_DATAKEY
	|| e.objclass == OBJ_CORRUPTFUSIONCORE
	|| e.objclass == OBJ_PRESSUREPLATE
	|| e.objclass == OBJ_NPC
	|| e.objclass == OBJ_PORTAL
	|| e.owner.flags & FL_ITEM
//	|| e.objclass == OBJ_STRUCTURE
//	|| e.objclass == OBJ_EQUIPMENT
//	|| e.objclass == OBJ_EQUIPMENT_MED
//	|| e.objclass == OBJ_EQUIPMENT_BIG
	|| (e.objclass == OBJ_TRAIN && e.owner.targetname)
	|| e.objclass == OBJ_FORCEFIELD
	|| e.objclass == OBJ_ENEMYSPAWN
	|| e.objclass == OBJ_PARTICLEEMITTER
	|| e.objclass == OBJ_TRIGGERRELAY
	|| (e.objclass == OBJ_STRUCTURE
		&& (e.variant == STRUCTURE_GASPUMP
		|| e.variant == STRUCTURE_PYLON
		|| e.variant == STRUCTURE_REFINERY
	//	|| e.variant == STRUCTURE_EVAPORATOR
		|| e.variant == STRUCTURE_INCINERATOR))		)
		return true;
		
	return false;
}

float LinkRules_Associate(entity e) =
{
	if(LinkRules_Object(e))
		return true;		
		
	return false;
}

float LinkRules_Objective(entity e) =
{
	if(LinkRules_Object(e)
	|| e.objclass == OBJ_WEAPONPICKUP1
	|| e.objclass == OBJ_WEAPONPICKUP2)
		return true;
		
	return false;
}

/*float LinkRules_NPC(entity e) =
{
	if(LinkRules_Object(e))
		return true;
	
	return false;
}*/

void Object_ChooseTrigger() =
{
	SetCurrentMenu(Draw_MissionEditorSetTrigger);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetObjectTrigger;
	linkingobj = true;
}

void Object_ChooseTrigger_Object() =
{
	Object_ChooseTrigger();
	LinkRules = LinkRules_Object;
}

/*void Object_ChooseTrigger_NPC() =
{
	Object_ChooseTrigger();
	LinkRules = LinkRules_NPC;
}*/

void Object_ChooseTriggerTarget() =
{
	SetCurrentMenu(Draw_MissionEditorSetTriggerTarget);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetObjectTriggerTarget;
	linkingobj = true;
	LinkRules = LinkRules_Targets;	
}

void Object_ChooseTriggerTarget_StageTwo() =
{
	SetCurrentMenu(Draw_MissionEditorSetTriggerTarget);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetObjectTriggerTarget_StageTwo;
	linkingobj = true;
	LinkRules = LinkRules_Targets;	
}

void Object_ChooseTriggerTarget_StageThree() =
{
	SetCurrentMenu(Draw_MissionEditorSetTriggerTarget);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetObjectTriggerTarget_StageThree;
	linkingobj = true;
	LinkRules = LinkRules_Targets;	
}

void Object_ChooseTriggerAssociation() =
{
	SetCurrentMenu(Draw_MissionEditorSetTriggerAssociation);
	currentmenu.CloseMenuFunc = ClearObjectLinkingData;
	ObjectLinkFunc = SetObjectTriggerAssociation;
	linkingobj = true;
	LinkRules = LinkRules_Associate;	
}

void PullDown_ConfigureNPC() =
{
/*	pulldown_option[0] = "Adjust Yaw";
	pulldown_func[0] = AdjustEntYaw;
	pulldown_option[1] = "Move";
	pulldown_func[1] = MoveHoverEnt;	
	pulldown_option[2] = "Undo Move";
	pulldown_func[2] = UndoHoverEntMove;	
	CheckPullDownAvailability(2, HoverEntOldOrgDifference());	
	
	if(hover_ent.objclass == CLASS_TELEPORTER)
	{
		pulldown_option[3] = "Choose Destination";
		pulldown_func[3] = Portal_ChooseDestination;	
	}*/
}

void PullDown_AdminMenu_NPC() =
{
/*	pulldown_option[0] = "Edit Entity";
	pulldown_func[0] = ClaimEditingRights;
	MarkPullDown(0, hover_ent.allowediting);
	CheckPullDownAvailability(0, !hover_ent.flags & FL_SPAWNEDBYMAP);
	
	pulldown_option[1] = "Configure";
	pulldown_sub[1] = PullDown_ConfigureNPC;	
	CheckPullDownAvailability(1, hover_ent.allowediting);
	
	pulldown_option[2] = "Options";
	pulldown_sub[2] = PullDown_EntityOptions;
	CheckPullDownAvailability(2, hover_ent.allowediting);*/
}

void CommitObject(entity e) =
{
	local string cmd;

	if(e.objclass == OBJ_PATH)
	{
		cmd = AppendToken("cmd commit_path", SEP_SPACE, ftos(e.owner.id));
		cmd = PrepLine_Path(cmd, e);
		cmd = strcat(cmd, "\n");
		
		if(!e.isshared)//owner.id) // temp client ent that previously didn't exist on the server
		{
			ClearPointer_Entfield(nextpathpoint, e);
			ClearPointer_Entfield(prevpathpoint, e);
		}		
	}
	else
	{	
		e.origin_base = e.origin;
		e.angles_base = e.angles;

		cmd = AppendToken("cmd commit_entity", SEP_SPACE, ftos(e.owner.id));
		
		if(e.objclass == OBJ_OBJECTIVE)
			cmd = PrepLine_Objective(cmd, e);
		else
		if(e.objclass == OBJ_TRAIN)
			cmd = PrepLine_Train(cmd, e);
		else
		if(e.objclass == OBJ_PARTICLEEMITTER)
			cmd = PrepLine_ParticleEmitter(cmd, e);
		else
		if(e.objclass == OBJ_AMBIENTSOUND)
			cmd = PrepLine_AmbientSound(cmd, e);
		else
			cmd = PrepLine_Entity(cmd, e);
		cmd = strcat(cmd, "\n");
	}
	
	if(!e.owner.isshared) // temp client ent that previously didn't exist on the server
		SH_RemoveEnt(e);	
	
	localcmd(cmd);
	
	pathfunctions = false;	
}

void UndeleteObject(entity e) =
{
	local string cmd;
	
	cmd = AppendToken("cmd undelete_ent", SEP_SPACE, ftos(e.owner.id));
	cmd = strcat(cmd, "\n");
	
	localcmd(cmd);
	
//	SH_RemoveEnt(e);	
}

void DeleteObject(entity e) =
{
	local string cmd;
	
	cmd = AppendToken("cmd remove_ent", SEP_SPACE, ftos(e.owner.id));
	cmd = strcat(cmd, "\n");
	
	localcmd(cmd);
	
	if(e.objclass != OBJ_TRAIN)
		SH_RemoveEnt(e);	
}

/*void CommitEntities() =
{
	local string cmd;
	local entity e, nexte, obj;
	
//	RemoveMarker();
	
	if(maptime_total_ismodified)
	{
		cmd = strcat("cmd setmaptime ", ftos(maptime_total_new));
		cmd = strcat(cmd, "\n");
		localcmd(cmd);
	}
	
	cmd = strcat("cmd setmissiontrack ", mission_track);
	cmd = strcat(cmd, "\n");
	localcmd(cmd);
	
	for(e = list_controlentchain; e; e = e.controlentchain)
	{
		if(!e.markedfordeletion)
			continue;
			
		for(obj = findchainfloat(triggerentid, e.owner.entid); obj; obj = obj.chain)
			obj.triggerentid = 0;
		
		for(obj = findchainfloat(targetentid, e.owner.entid); obj; obj = obj.chain)
			obj.targetentid = 0;		
			
		for(obj = findchainfloat(associationentid, e.owner.entid); obj; obj = obj.chain)
			obj.associationentid = 0;				
	}
	
	e = list_controlentchain;//findchainfloat(class, CLASS_CONTROLENT);
	while(e)
	{
		nexte = e.controlentchain;
		
		if(e != marker)
//		if(!e.restricted)
	//	if(e.allowediting || e.controlent.allowediting) 
		{
		//	if(e.controlent)
		//		e = e.controlent;
		
			if(e.markedfordeletion)
			{
				cmd = AppendToken("cmd remove_ent", SEP_SPACE, ftos(e.owner.id));
				cmd = strcat(cmd, "\n");
			}
			else
			if(e.objclass == OBJ_PATH)
			{
				cmd = AppendToken("cmd commit_path", SEP_SPACE, ftos(e.owner.id));
				cmd = PrepLine_Path(cmd, e);
				cmd = strcat(cmd, "\n");
			}
			else
			{
				e.origin_base = e.origin;
				e.angles_base = e.angles;

				cmd = AppendToken("cmd commit_entity", SEP_SPACE, ftos(e.owner.id));
				if(e.objclass == OBJ_TRAIN)
					cmd = PrepLine_Train(cmd, e);
				else
				if(e.objclass == OBJ_PARTICLEEMITTER)
					cmd = PrepLine_ParticleEmitter(cmd, e);
				else
					cmd = PrepLine_Entity(cmd, e);
				cmd = strcat(cmd, "\n");
			}
			
			if(e.objclass != OBJ_PATH)
			if(!e.owner.id) // temp client ent that previously didn't exist on the server
				SH_RemoveEnt(e);
				
			localcmd(cmd);
		}
		
		e = nexte;
	}
	
	e = list_pathchain;
	while(e)
	{
		nexte = e.pathchain;
	
		if(!e.isshared)//owner.id) // temp client ent that previously didn't exist on the server
		{
			ClearPointer_Entfield(nextpathpoint, e);
			ClearPointer_Entfield(prevpathpoint, e);
			SH_RemoveEnt(e);
		}
	
		e = nexte;
	}	
	
	localcmd("cmd commit_entities_end\n");
	CloseMenu();
}*/

//void Menu_ConfirmCommitEntities() =
//{	DrawConfirmationMenu("Are you sure you want to commit all the current marked entities?\n", CommitEntities);	}

//void ConfirmCommitEntities() =
//{/*	SetCurrentWindow('220 107.7 0', Menu_ConfirmCommitEntities, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);	*/}

void SaveEntities() =
{
	localcmd("cmd entity_saveall\n");
	
	if(active_menu)
	if(IsAssignedFunction(active_menu.CloseMenuFunc))
		active_menu.CloseMenuFunc();
	else
		CloseMenu();
}

//void Menu_ConfirmSaveEntities() =
//{	DrawConfirmationMenu("Are you sure you want to save the current entities?\n", SaveEntities);	}

void ConfirmSaveEntities() =
{	/*SetCurrentWindow('220 107.7 0', Menu_ConfirmSaveEntities, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);*/	}

void ReloadEntities() =
{
	localcmd("cmd entity_reloadall\n");
	
	if(active_menu)
	if(IsAssignedFunction(active_menu.CloseMenuFunc))
		active_menu.CloseMenuFunc();
	else
		CloseMenu();		
}

//void Menu_ConfirmReloadEntities() =
//{	DrawConfirmationMenu("Are you sure you want to reload all entities in the current level?\n", ReloadEntities);	}

void ConfirmReloadEntities() =
{	/*SetCurrentWindow('220 107.7 0', Menu_ConfirmReloadEntities, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);*/	}

void UnmarkForDeletion(entity e) =
{
	if(!e.markedfordeletion)
		return;
		
//	e.colormod += '0 1 1 ';
	SubtractColorMod(e, '1 0 0');
	e.alpha = 0;
	e.markedfordeletion = false;
}

void MarkForDeletion(entity e) =
{
	if(e.markedfordeletion)
		return;
		
//	e.colormod += '0 -1 -1';
	AddColorMod(e, '1 0 0');
	e.alpha = 0.5;
	e.markedfordeletion = true;
}

void DeleteEntities() =
{
	localcmd("cmd entity_deleteall\n");
	
/*	local entity e, nexte;
	e = list_controlentchain;//findchainfloat(class, CLASS_CONTROLENT);
	while(e)
	{
		nexte = e.controlentchain;
		
		if(e.owner.objclass != CLASS_TRAIN)
		if(e.owner.id > 0)
			MarkForDeletion(e);
		else
			SH_RemoveEnt(e);
	
		e = nexte;
	}*/
	
//	if(active_menu)
//	if(IsAssignedFunction(active_menu.CloseMenuFunc))	
//		active_menu.CloseMenuFunc();
//	else
		CloseMenu();		
}

//void Menu_ConfirmDeleteEntities() =
//{	DrawConfirmationMenu("Are you sure you want to delete all entities in the current level?\n", DeleteEntities);	}

void ConfirmDeleteEntities() =
{	/*SetCurrentWindow('220 107.7 0', Menu_ConfirmDeleteEntities, CloseAdminMenu, MF_CLOSEABLE | MF_CONFIRMATION | MF_ADMIN);*/	}

/*string GetCommitEntityString() =
{
	admin_editingent.origin_base = admin_editingent.origin;
	admin_editingent.angles_base = admin_editingent.angles;
	
	local string cmd;
	cmd = "cmd commit_entity";
	cmd = AppendToken(cmd, SEP_SPACE, ftos(admin_editingent.owner.id));
	cmd = PrepLine_Entity(cmd, admin_editingent);
	cmd = strcat(cmd, "\n");

	return cmd;
}

void Commit_Entity() =	{	localcmd(GetCommitEntityString());	}*/

entity SpawnObject(entity e, float CLASS, float VARIANT, void() PostSpawnFunc) =
{
	if(!e)
		e = spawn();
	if(e.colormod == '0 0 0')
		e.colormod = '1 1 1';
	SetOwner(e, e);
	SetParent(e, e);
	e.class = CLASS_OBJECT;
	e.objclass = CLASS;
	e.variant = VARIANT;
	SetObjectAppearance(e, CLASS, VARIANT);
//	SetObjectSize(e, CLASS, VARIANT);
	InitObject(e);	
	
	if(e.modelflags)
		e.predraw = DrawModelFlags;
	
//	e.PullDownMenuFunc = Draw_AdminMenu_Object;
//	e.CommitFunc = Commit_Entity;
	e.drawmask = MASK_NORMAL;
	
//	justspawned = e;
	if(PostSpawnFunc)
		Func_oself(e, PostSpawnFunc);
//	justspawned = world;
	
	return e;
}

void PlaceEntity(float CLASS, float VARIANT, void() PostSpawnFunc, void() PostPlacedFunc) =
{
	local float totalobjects;

//	cl_button = 0;
	
//	if(admin_editingent)
//		DeselectAdminEditingentAndCloseMenu();

	if(!marker)
	{
		SetCurrentMenu(Draw_MissionEditorPlacingEntity);
		currentmenu.ESCFunc = MissionEditorPlacingEntityESCFunc;
		currentmenu.CloseMenuFunc = RemoveMarker;
	}
	
	RemoveMarker();
	
	marker = SpawnObject(world, CLASS, VARIANT, PostSpawnFunc);
	marker.allowediting = true;
//	marker.colormod = '1 1 1';
	PostMarkerPlacedFunc = PostPlacedFunc;
	
	if(placedent_randomyaw && AllowRandomYaw(marker))
		marker.angles_y = floor(random()*8)*45;
	else
	{
		if(marker.chullrotation >= CHULLROT_ALL)
			marker.angles_y = defaultentangles_y;
		else
			marker.angles_y = floor(defaultentangles_y/45)*45;
	}
	
	if(marker.allowrandomscale)
	{
		if(placedent_randomscale)
		{
			marker.scale = randomscale_min + random()*(randomscale_max-randomscale_min);
			SetObjectSize(marker, marker.mins*marker.scale, marker.maxs*marker.scale);
		}
		else
			marker.scale = 1;
	}
	
	if(marker.allowpitchadjustment)
		marker.angles_x = defaultentangles_x;
		
	local vector org, start, end;
	org = getmousepos();
	start = unproject(org);
	org_z = start_z - player.origin_z - 500;
	start = unproject(org);
	end = unproject(org + '0 0 10000');	
	UpdateMarker(start, end, trace_plane_normal);//start, end);
}

void PlaceCrystal_Red() =		{	PlaceEntity(OBJ_CRYSTAL, 		0,		SUB_Null,	PlaceCrystal_Red);		}
void PlaceCrystal_Green() =		{	PlaceEntity(OBJ_CRYSTAL, 		1,		SUB_Null,	PlaceCrystal_Green);	}
void PlaceCrystal_Blue() =		{	PlaceEntity(OBJ_CRYSTAL, 		2,		SUB_Null,	PlaceCrystal_Blue);		}

/*void PullDown_Admin_Entities_Pickups_Crystals() =
{
	pulldown_option[0] = "Red";
	pulldown_func[0] = PlaceCrystal_Red;
	pulldown_option[1] = "Green";
	pulldown_func[1] = PlaceCrystal_Green;	
	pulldown_option[2] = "Blue";
	pulldown_func[2] = PlaceCrystal_Blue;
}*/

void PlaceMiniguns() =			{	PlaceEntity(OBJ_WEAPONPICKUP1, 	WEP1_MINIGUN,		SUB_Null,	PlaceMiniguns);		}
void PlaceFlackGuns() =			{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_FLACKGUN,		SUB_Null,	PlaceFlackGuns);	}
void PlaceShockwaveDevice() =	{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_SHOCKWAVE,		SUB_Null,	PlaceShockwaveDevice);	}
void PlaceStormPlow() =			{	PlaceEntity(OBJ_WEAPONPICKUP1, 	WEP1_STORMPLOW,		SUB_Null,	PlaceStormPlow);	}
void PlaceStormSpread() =		{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_STORMSPREAD,	SUB_Null,	PlaceStormSpread);	}
void PlaceStormShield() =		{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_STORMSHIELD,	SUB_Null,	PlaceStormShield);	}
void PlaceThunderbolt() =		{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_THUNDERBOLT,	SUB_Null,	PlaceThunderbolt);	}
void PlaceBeamCannon() =		{	PlaceEntity(OBJ_WEAPONPICKUP1, 	WEP1_BEAMCANNON,		SUB_Null,	PlaceBeamCannon);	}
void PlaceRocketPod() =			{	PlaceEntity(OBJ_WEAPONPICKUP1, 	WEP1_ROCKETPOD,		SUB_Null,	PlaceRocketPod);	}
void PlaceHomingMissiles() =	{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_HOMINGMISSILES,	SUB_Null,	PlaceHomingMissiles);	}
void PlaceMIRVMortar() =		{	PlaceEntity(OBJ_WEAPONPICKUP2, 	WEP2_MIRVMORTAR,		SUB_Null,	PlaceMIRVMortar);	}

/*void PullDown_Admin_Entities_Pickups_Weapons() =
{
	pulldown_option[0] = "Rocket Pod";
	pulldown_func[0] = PlaceRocketPod;
	pulldown_option[1] = "Homing Missiles";
	pulldown_func[1] = PlaceHomingMissiles;	
	pulldown_option[2] = "MIRV Mortar";
	pulldown_func[2] = PlaceMIRVMortar;
}*/

void PlaceArmorShard() =		{	PlaceEntity(OBJ_ARMORSHARD, 	0,		SUB_Null,	PlaceArmorShard);	}
void PlaceArmorShell() =		{	PlaceEntity(OBJ_ARMORSHELL, 	0,		SUB_Null,	PlaceArmorShell);	}
void PlaceShield() =			{	PlaceEntity(OBJ_SHIELDPICKUP, 	0,		SUB_Null,	PlaceShield);		}
void PlaceExtraLife() =			{	PlaceEntity(OBJ_EXTRALIFE, 		0,		SUB_Null,	PlaceExtraLife);	}

/*void PullDown_Admin_Entities_Pickups() =
{
	pulldown_option[0] = "Crystals";
	pulldown_sub[0] = PullDown_Admin_Entities_Pickups_Crystals;
	pulldown_option[1] = "Armor Shard";
	pulldown_func[1] = PlaceArmorShard;	
	pulldown_option[2] = "Armor Shell";
	pulldown_func[2] = PlaceArmorShell;
	pulldown_option[3] = "Shield";
	pulldown_func[3] = PlaceShield;	
	pulldown_option[4] = "Extra Life";
	pulldown_func[4] = PlaceExtraLife;
	pulldown_option[5] = "Weapons";
	pulldown_sub[5] = PullDown_Admin_Entities_Pickups_Weapons;		
}*/

void PlaceEnemy_LightTank() =			{	PlaceEntity(OBJ_NPC, NPC_LIGHTTANK,			SUB_Null,	PlaceEnemy_LightTank);	}
void PlaceEnemy_MediumTank() =			{	PlaceEntity(OBJ_NPC, NPC_MEDIUMTANK,		SUB_Null,	PlaceEnemy_MediumTank);	}
void PlaceEnemy_HeavyTank_Proton() =	{	PlaceEntity(OBJ_NPC, NPC_HEAVYTANK_PROTON,	SUB_Null,	PlaceEnemy_HeavyTank_Proton);	}
void PlaceEnemy_HeavyTank_Minigun() =	{	PlaceEntity(OBJ_NPC, NPC_HEAVYTANK_MINIGUN,	SUB_Null,	PlaceEnemy_HeavyTank_Minigun);	}
void PlaceEnemy_LightningTank() =		{	PlaceEntity(OBJ_NPC, NPC_LIGHTNINGTANK,		SUB_Null,	PlaceEnemy_LightningTank);	}

/*void PullDown_Admin_Entities_BasicEnemies() =
{
	pulldown_option[0] = "Light Tank";
	pulldown_func[0] = PlaceEnemy_LightTank;
	pulldown_option[1] = "Medium Tank";
	pulldown_func[1] = PlaceEnemy_MediumTank;
	pulldown_option[2] = "Heavy Tank";
	pulldown_func[2] = PlaceEnemy_HeavyTank;	
	pulldown_option[3] = "Lightning Tank";
	pulldown_func[3] = PlaceEnemy_LightningTank;
}*/

void PlaceEnemy_CarrierTank() =		{	PlaceEntity(OBJ_NPC, NPC_CARRIERTANK,		SUB_Null,	PlaceEnemy_CarrierTank);	}
void PlaceEnemy_DestroyerTank() =	{	PlaceEntity(OBJ_NPC, NPC_DESTROYERTANK,		SUB_Null,	PlaceEnemy_DestroyerTank);	}

/*void PullDown_Admin_Entities_Bosses() =
{
	pulldown_option[0] = "Carrier Tank";
	pulldown_func[0] = PlaceEnemy_CarrierTank;
	pulldown_option[1] = "Destroyer Tank";
	pulldown_func[1] = PlaceEnemy_DestroyerTank;
}*/

void PlaceTurret_LightPlasma() =	{	PlaceEntity(OBJ_NPC, NPC_LIGHTPLASMATURRET,		SUB_Null,	PlaceTurret_LightPlasma);	}
void PlaceTurret_HeavyBeam() =		{ 	PlaceEntity(OBJ_NPC, NPC_HEAVYBEAMTURRET,		SUB_Null,	PlaceTurret_HeavyBeam);	}
void PlaceTurret_Rocket() =			{ 	PlaceEntity(OBJ_NPC, NPC_ROCKETTURRET,			SUB_Null,	PlaceTurret_Rocket);	}
void PlaceTurret_Repair() =			{ 	PlaceEntity(OBJ_NPC, NPC_REPAIRTURRET,			SUB_Null,	PlaceTurret_Repair);	}

void PlaceAI_FriendlyLightTank() =	{	PlaceEntity(OBJ_NPC, NPC_FRIENDLYLIGHTTANK,		SUB_Null,	PlaceAI_FriendlyLightTank);	}

void PlaceGroupSpawn() =		{	PlaceEntity(OBJ_ENEMYSPAWN, 			0,		SetEnemySpawnerMaxValues,	PlaceGroupSpawn);	}
void PlacePortal() =			{	PlaceEntity(OBJ_PORTAL, 				0,		SetPortalMaxValues,			PlacePortal);	}

void PlaceSpawnPad() =				{	PlaceEntity(OBJ_SPAWNPAD,			0,		SUB_Null,	PlaceSpawnPad);	}
void PlaceSpawnPad_Red() =			{	PlaceEntity(OBJ_SPAWNPAD,			1,		SUB_Null,	PlaceSpawnPad_Red);	}
void PlaceSpawnPad_Blue() =			{	PlaceEntity(OBJ_SPAWNPAD,			2,		SUB_Null,	PlaceSpawnPad_Blue);	}
void PlaceExitPad() =				{	PlaceEntity(OBJ_EXITPAD,			0,		SUB_Null,	PlaceExitPad);	}
void PlaceForceField() =			{	PlaceEntity(OBJ_FORCEFIELD, 		0,		SUB_Null,	PlaceForceField);	}
void PlaceForceFieldT() =			{	PlaceEntity(OBJ_FORCEFIELD, 		1,		SUB_Null,	PlaceForceFieldT);	}
void PlacePressurePlate() =			{	PlaceEntity(OBJ_PRESSUREPLATE, 		0,		SUB_Null,	PlacePressurePlate);	}
void PlaceTeleporter() =			{	PlaceEntity(OBJ_TELEPORTER, 		0,		SUB_Null,	PlaceTeleporter);	}
void PlaceTerminal() =				{	PlaceEntity(OBJ_TERMINAL,			0,		SetTerminalDefaultValues,	PlaceTerminal);		}
void PlaceTerminal_Small() =		{	PlaceEntity(OBJ_TERMINAL,			1,		SetTerminalDefaultValues,	PlaceTerminal_Small);	}
void PlaceDataKey() =				{	PlaceEntity(OBJ_DATAKEY,			0,		SUB_Null,	PlaceDataKey);		}
void PlaceFlag_Neutral() =			{	PlaceEntity(OBJ_FLAGBASE, 			0,		SUB_Null,	PlaceFlag_Neutral);	}
void PlaceFlag_Red() =				{	PlaceEntity(OBJ_FLAGBASE, 			1,		SUB_Null,	PlaceFlag_Red);	}
void PlaceFlag_Blue() =				{	PlaceEntity(OBJ_FLAGBASE, 			2,		SUB_Null,	PlaceFlag_Blue);	}
void PlaceObelisk_1() =				{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_OBELISK,		SUB_Null,	PlaceObelisk_1);		}
void PlacePylon_1() =				{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_PYLON,		SUB_Null,	PlacePylon_1);			}
void PlaceGasPump() =				{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_GASPUMP,		SUB_Null,	PlaceGasPump);			}
void PlaceRefinery() =				{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_REFINERY,		SUB_Null,	PlaceRefinery);			}
void PlaceEvaporator() =			{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_EVAPORATOR,	SUB_Null,	PlaceEvaporator);		}
void PlaceCorruptFusionCore() =		{	PlaceEntity(OBJ_CORRUPTFUSIONCORE,	0,		SUB_Null,	PlaceCorruptFusionCore);			}
void PlaceFusionCoreRack() =		{	PlaceEntity(OBJ_FUSIONCORERACK,		0,		SUB_Null,	PlaceFusionCoreRack);		}
void PlaceBBoss() =					{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_BBOSS,		SUB_Null,	PlaceBBoss);			}
void PlaceBBoss_Small() =			{	PlaceEntity(OBJ_STRUCTURE,			STRUCTURE_BBOSS_SMALL,	SUB_Null,	PlaceBBoss_Small);		}

void PlaceStone_1() =				{	PlaceEntity(OBJ_STONE, 				0,		SUB_Null,	PlaceStone_1);	}
void PlaceStone_2() =				{	PlaceEntity(OBJ_STONE, 				1,		SUB_Null,	PlaceStone_2);	}
void PlaceStone_3() =				{	PlaceEntity(OBJ_STONE, 				2,		SUB_Null,	PlaceStone_3);	}
void PlaceStone_4() =				{	PlaceEntity(OBJ_STONE, 				3,		SUB_Null,	PlaceStone_4);	}
void PlaceStone_5() =				{	PlaceEntity(OBJ_STONE, 				4,		SUB_Null,	PlaceStone_5);	}
void PlaceStone_6() =				{	PlaceEntity(OBJ_STONE, 				5,		SUB_Null,	PlaceStone_6);	}
void PlaceStone_7() =				{	PlaceEntity(OBJ_STONE, 				6,		SUB_Null,	PlaceStone_7);	}
void PlaceStone_8() =				{	PlaceEntity(OBJ_STONE, 				7,		SUB_Null,	PlaceStone_8);	}
void PlaceStone_9() =				{	PlaceEntity(OBJ_STONE, 				8,		SUB_Null,	PlaceStone_9);	}
void PlaceStone_10() =				{	PlaceEntity(OBJ_STONE, 				9,		SUB_Null,	PlaceStone_10);	}
void PlaceStone_11() =				{	PlaceEntity(OBJ_STONE, 				10,		SUB_Null,	PlaceStone_11);	}
void PlaceRockGroup_1() =			{	PlaceEntity(OBJ_ROCKGROUP,			0,		SUB_Null,	PlaceRockGroup_1);	}
void PlaceRockGroup_2() =			{	PlaceEntity(OBJ_ROCKGROUP,			1,		SUB_Null,	PlaceRockGroup_2);	}
void PlaceRockGroup_3() =			{	PlaceEntity(OBJ_ROCKGROUP,			2,		SUB_Null,	PlaceRockGroup_3);	}

void PlaceEnvCrystals_Blue() =		{	PlaceEntity(OBJ_ENVCRYSTAL, 		0,		SUB_Null,	PlaceEnvCrystals_Blue);	}
void PlaceEnvCrystals_Green() =		{	PlaceEntity(OBJ_ENVCRYSTAL, 		1,		SUB_Null,	PlaceEnvCrystals_Green);	}
void PlaceEnvCrystals_Purple() =	{	PlaceEntity(OBJ_ENVCRYSTAL, 		2,		SUB_Null,	PlaceEnvCrystals_Purple);	}
void PlaceEnvCrystals_Red() =		{	PlaceEntity(OBJ_ENVCRYSTAL, 		3,		SUB_Null,	PlaceEnvCrystals_Red);	}
void PlaceEnvCrystals_Turquoise() =	{	PlaceEntity(OBJ_ENVCRYSTAL, 		4,		SUB_Null,	PlaceEnvCrystals_Turquoise);	}
void PlaceEnvCrystals_Yellow() =	{	PlaceEntity(OBJ_ENVCRYSTAL, 		5,		SUB_Null,	PlaceEnvCrystals_Yellow);	}

void PlaceStalagmites1() =			{	PlaceEntity(OBJ_STALAGMITE, 		0,		SUB_Null,	PlaceStalagmites1);	}
void PlaceStalagmites2() =			{	PlaceEntity(OBJ_STALAGMITE, 		1,		SUB_Null,	PlaceStalagmites2);	}

void PlaceVolcano1() =				{	PlaceEntity(OBJ_VOLCANO, 			0,		SUB_Null,	PlaceVolcano1);	}
void PlaceVolcano1_medium() =		{	PlaceEntity(OBJ_VOLCANO, 			1,		SUB_Null,	PlaceVolcano1_medium);	}
void PlaceVolcano1_small() =		{	PlaceEntity(OBJ_VOLCANO, 			2,		SUB_Null,	PlaceVolcano1_small);	}
void PlaceVolcano2() =				{	PlaceEntity(OBJ_VOLCANO, 			3,		SUB_Null,	PlaceVolcano2);	}
void PlaceVolcano2_medium() =		{	PlaceEntity(OBJ_VOLCANO, 			4,		SUB_Null,	PlaceVolcano2_medium);	}
void PlaceVolcano2_small() =		{	PlaceEntity(OBJ_VOLCANO, 			5,		SUB_Null,	PlaceVolcano2_small);	}
void PlaceVolcano3() =				{	PlaceEntity(OBJ_VOLCANO, 			6,		SUB_Null,	PlaceVolcano3);	}
void PlaceVolcano3_medium() =		{	PlaceEntity(OBJ_VOLCANO, 			7,		SUB_Null,	PlaceVolcano3_medium);	}
void PlaceVolcano3_small() =		{	PlaceEntity(OBJ_VOLCANO, 			8,		SUB_Null,	PlaceVolcano3_small);	}
void PlaceVolcano4() =				{	PlaceEntity(OBJ_VOLCANO, 			9,		SUB_Null,	PlaceVolcano4);	}
void PlaceVolcano4_medium() =		{	PlaceEntity(OBJ_VOLCANO, 			10,		SUB_Null,	PlaceVolcano4_medium);	}
void PlaceVolcano4_small() =		{	PlaceEntity(OBJ_VOLCANO, 			11,		SUB_Null,	PlaceVolcano4_small);	}

void PlaceRoadblock1() =			{	PlaceEntity(OBJ_ROADBLOCK, 			0,		SUB_Null,	PlaceRoadblock1);	}
void PlaceRoadblock1_dropped() =	{	PlaceEntity(OBJ_ROADBLOCK, 			1,		SUB_Null,	PlaceRoadblock1_dropped);	}
void PlaceRoadblock2() =			{	PlaceEntity(OBJ_ROADBLOCK, 			2,		SUB_Null,	PlaceRoadblock2);	}
void PlaceRoadblock2_dropped() =	{	PlaceEntity(OBJ_ROADBLOCK, 			3,		SUB_Null,	PlaceRoadblock2_dropped);	}
void PlaceRoadblock3() =			{	PlaceEntity(OBJ_ROADBLOCK, 			4,		SUB_Null,	PlaceRoadblock3);	}
void PlaceRoadblock4() =			{	PlaceEntity(OBJ_ROADBLOCK, 			5,		SUB_Null,	PlaceRoadblock4);	}

void PlaceRockFormation1() =		{	PlaceEntity(OBJ_ROCKFORMATION, 		0,		SUB_Null,	PlaceRockFormation1);	}

void PlacePalmtree1() =				{	PlaceEntity(OBJ_TREE, 				0,		SUB_Null,	PlacePalmtree1);	}
void PlacePalmtree2() =				{	PlaceEntity(OBJ_TREE, 				1,		SUB_Null,	PlacePalmtree2);	}
void PlacePalmtree3() =				{	PlaceEntity(OBJ_TREE, 				2,		SUB_Null,	PlacePalmtree3);	}

void PlacePlant1() =				{	PlaceEntity(OBJ_PLANT, 				0,		SUB_Null,	PlacePlant1);	}
void PlacePlant1_NoFlowers() =		{	PlaceEntity(OBJ_PLANT, 				1,		SUB_Null,	PlacePlant1_NoFlowers);	}
void PlacePlant2() =				{	PlaceEntity(OBJ_PLANT, 				2,		SUB_Null,	PlacePlant2);	}
void PlacePlant3() =				{	PlaceEntity(OBJ_PLANT, 				3,		SUB_Null,	PlacePlant3);	}
void PlaceCactus1() =				{	PlaceEntity(OBJ_PLANT, 				4,		SUB_Null,	PlaceCactus1);	}
void PlaceCactus2() =				{	PlaceEntity(OBJ_PLANT, 				5,		SUB_Null,	PlaceCactus2);	}
void PlaceCactus3() =				{	PlaceEntity(OBJ_PLANT, 				6,		SUB_Null,	PlaceCactus3);	}
void PlaceCactus4() =				{	PlaceEntity(OBJ_PLANT, 				7,		SUB_Null,	PlaceCactus4);	}

void PlaceGrass1() =				{	PlaceEntity(OBJ_GRASS, 				0,		SUB_Null,	PlaceGrass1);	}
void PlaceGrass2() =				{	PlaceEntity(OBJ_GRASS, 				1,		SUB_Null,	PlaceGrass2);	}
void PlaceGrass3() =				{	PlaceEntity(OBJ_GRASS, 				2,		SUB_Null,	PlaceGrass3);	}

void PlaceBarrel_1() =				{	PlaceEntity(OBJ_EQUIPMENT,			0,		SUB_Null,	PlaceBarrel_1);	}
void PlaceBarrel_2() =				{	PlaceEntity(OBJ_EQUIPMENT,			1,		SUB_Null,	PlaceBarrel_2);	}
void PlaceBarrel_3() =				{	PlaceEntity(OBJ_EQUIPMENT,			2,		SUB_Null,	PlaceBarrel_3);	}
void PlaceContainer_1() =			{	PlaceEntity(OBJ_EQUIPMENT_BIG,		0,		SUB_Null,	PlaceContainer_1);	}
void PlaceContainer_1a() =			{	PlaceEntity(OBJ_EQUIPMENT_BIG,		1,		SUB_Null,	PlaceContainer_1a);	}
void PlaceContainer_2() =			{	PlaceEntity(OBJ_EQUIPMENT_MED,		0,		SUB_Null,	PlaceContainer_2);	}
void PlaceContainer_3() =			{	PlaceEntity(OBJ_EQUIPMENT_MED,		1,		SUB_Null,	PlaceContainer_3);	}

void PlaceBuilding_1() =		{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_INCINERATOR,			SUB_Null,	PlaceBuilding_1);		}
void PlaceBuilding_2() =		{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_BUNKER,				SUB_Null,	PlaceBuilding_2);		}
void PlaceBuilding_3() =		{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_HANGAR,				SUB_Null,	PlaceBuilding_3);		}
void PlaceBuilding_4() =		{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_BARRACKS,				SUB_Null,	PlaceBuilding_4);		}
void PlaceCoolingTower_1() =	{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_COOLINGTOWER,			SUB_Null,	PlaceCoolingTower_1);	}
void PlaceCoolingTower_2() =	{	PlaceEntity(OBJ_STRUCTURE,	STRUCTURE_COOLINGTOWER_TWIN,	SUB_Null,	PlaceCoolingTower_2);	}

void PlaceDLightTank() =			{	PlaceEntity(OBJ_VEHICLE,			0,		SUB_Null,	PlaceDLightTank);	}
void PlaceDMediumTank() =			{	PlaceEntity(OBJ_VEHICLE,			1,		SUB_Null,	PlaceDMediumTank);	}
void PlaceDLightningTank() =		{	PlaceEntity(OBJ_VEHICLE,			2,		SUB_Null,	PlaceDLightningTank);	}
void PlaceDHeavyTank() =			{	PlaceEntity(OBJ_VEHICLE,			3,		SUB_Null,	PlaceDHeavyTank);	}
void PlaceDCarrierTank() =			{	PlaceEntity(OBJ_VEHICLE,			4,		SUB_Null,	PlaceDCarrierTank);	}
void PlaceDDestroyerTank() =		{	PlaceEntity(OBJ_VEHICLE,			5,		SUB_Null,	PlaceDDestroyerTank);	}
void PlaceDPlasmaTurret() =			{	PlaceEntity(OBJ_VEHICLE,			6,		SUB_Null,	PlaceDPlasmaTurret);	}
void PlaceDRocketTurret() =			{	PlaceEntity(OBJ_VEHICLE,			7,		SUB_Null,	PlaceDRocketTurret);	}
void PlaceDBeamTurret() =			{	PlaceEntity(OBJ_VEHICLE,			8,		SUB_Null,	PlaceDBeamTurret);	}
void PlaceDRepairTurret() =			{	PlaceEntity(OBJ_VEHICLE,			9,		SUB_Null,	PlaceDRepairTurret);	}
void PlaceDPlayerTank() =			{	PlaceEntity(OBJ_VEHICLE,			10,		SUB_Null,	PlaceDPlayerTank);	}

void PlaceParticleEmitter() =	{	PlaceEntity(OBJ_PARTICLEEMITTER,		0,		SetEmitterMarkerParticleEffect,	PlaceParticleEmitter);	}
void PlaceAmbientSound() =		{	PlaceEntity(OBJ_AMBIENTSOUND,			0,		SetEmitterMarkerAmbientSound,	PlaceAmbientSound);	}

void PlaceTriggerRelay() =		{	PlaceEntity(OBJ_TRIGGERRELAY,			0,		SUB_Null,	PlaceTriggerRelay);	}

void TogglePlacedEntRandomYaw() =	{	placedent_randomyaw = !placedent_randomyaw;	}
void TogglePlacedEntRandomScale() =	{	placedent_randomscale = !placedent_randomscale;	}