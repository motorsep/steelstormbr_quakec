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
//engine defs
void(entity e, vector org) setorigin = #2; 
void(entity e, vector min, vector max) setsize	= #4;
entity(vector org, float rad) findradius	= #22;
//void(entity e, float chan, string samp, float vol, float atten) sound = #8;
void(vector pos, string samp, float vol, float atten) ambientsound = #74;
.string	targetname;


string		campaign;
string		mission;
string		mission_briefing[NUMLANGUAGES];
.string		objectivetext[NUMLANGUAGES];
float		fraglimit;
float		capturelimit;

// edict.movetype values
float	MOVETYPE_NONE			= 0;	// never moves
float   MOVETYPE_ANGLENOCLIP    = 1;
float   MOVETYPE_ANGLECLIP              = 2;
float	MOVETYPE_WALK			= 3;	// players only
float	MOVETYPE_STEP			= 4;	// discrete, not real time unless fall
float	MOVETYPE_FLY			= 5;
float	MOVETYPE_TOSS			= 6;	// gravity
float	MOVETYPE_PUSH			= 7;	// no clip to world, push and crush
float	MOVETYPE_NOCLIP			= 8;
float	MOVETYPE_FLYMISSILE		= 9;	// fly with extra size against monsters
float	MOVETYPE_BOUNCE			= 10;
float	MOVETYPE_BOUNCEMISSILE	= 11;	// bounce with extra size

// edict.solid values
float	SOLID_NOT				= 0;	// no interaction with other objects
float	SOLID_TRIGGER			= 1;	// touch on edge, but not blocking
float	SOLID_BBOX				= 2;	// touch on edge, block
float	SOLID_SLIDEBOX			= 3;	// touch on edge, but not an onground
float	SOLID_BSP				= 4;	// bsp clip, touch on edge, block

float	stringwidth(string text, float handleColors, vector size) = #327;

float	FL_ITEM					= 256;

const float DRAWFLAG_NORMAL = 0;
const float DRAWFLAG_ADDITIVE = 1;
const float DRAWFLAG_MODULATE = 2;
const float DRAWFLAG_2XMODULATE = 3;
const float DRAWFLAG_SCREEN = 4;
const float DRAWFLAG_MIPMAP = 0x100; // only for R_BeginPolygon

//engine vars
vector	trace_plane_normal;


// status vars

float		mapwidth;

float		maptime_total_new;
float		maptime_total_ismodified;
float		maptime_total;
float		maptime_start;
float		client_initialized;
float		teamplay;

float		playerviewsetting_fpscam;
float		playerviewsetting_lockyaw;

//float		cl_menutype;


// LISTS

entity		list_shotchain;
.entity		shotchain;
.entity		shotchain_prev;

.float		shakecamera;
entity		list_camerashakechain;
.entity		camerashakechain;
.entity		camerashakechain_prev;

//.float		showonradar;
entity		list_radarchain;
.entity		radarchain;
.entity		radarchain_prev;

entity		list_ownerlesschain;
.entity		ownerlesschain;
.entity		ownerlesschain_prev;

//.float		hasavelocity;
entity		list_hasavelocitychain;
.entity		hasavelocitychain;
.entity		hasavelocitychain_prev;

entity		list_canshootchain;
.entity		canshootchain;
.entity		canshootchain_prev;

.float		hittable;
entity		list_hittablechain;
.entity		hittablechain;
.entity		hittablechain_prev;

entity		list_menuchain;
.entity		menuchain;
.entity		menuchain_prev;

entity		list_missingpathconnectionschain;
.entity		missingpathconnectionschain;
.entity		missingpathconnectionschain_prev;

entity		list_deletedpathchain;
.entity		deletedpathchain;
.entity		deletedpathchain_prev;

entity		list_controlentchain;
.entity		controlentchain;
.entity		controlentchain_prev;

entity		list_pointtextchain;
.entity		pointtextchain;
.entity		pointtextchain_prev;

entity		list_centerprintchain;
.entity		centerprintchain;
.entity		centerprintchain_prev;

entity		list_objectivetextchain;
.entity		objectivetextchain;
.entity		objectivetextchain_prev;

entity		list_newmapobjectchain;
.entity		newmapobjectchain;
.entity		newmapobjectchain_prev;

entity		list_reticlechain;
.entity		reticlechain;
.entity		reticlechain_prev;

//general use

//void		SUB_Null();// = {};

.float		isshared;

.float		lostownerid;

float		esctime;

float		effectdrawtime;

void SH_RemoveEnt(entity e);
void() SUB_Remove = {SH_RemoveEnt(self);};

string		string_null;
//void()		SUB_Null;
//entity 		NULL_Ent;

//vector		vid_size;
//vector		vid_res;

entity		player;
float		player_hittime;
float		player_hittime_total;
//string		targetobjectname;
float		targethealth_old;
float		drawtargethealthtime;

vector		camera_origin;
vector		playercamera_origin;
float		playercamera_angle;
float		playercamera_pitch;

//entity		list_playerchain;
//.entity		playerchain;

.vector		velocity;
.vector		newvelocity;
.vector		oldvelocity;
.vector		neworigin;
.float		newyaw;
.float		newpitch;
.float		newroll;

//.float		oldupdatetime;
//.float		newupdatetime;

//void() UpdateHasAvelocityChain;



//init defs
float		EFFECT_MAXFPS		= 60;
float		EFFECT_MAXPPF		= 5;

float		PEF_PLAYER_BUTTONCHAT;
float		PEF_MINIGUN_TRACE;
float		PEF_MINIGUN_MUZZLEFLASH;
float		PEF_MINIGUN_HIT;
float		PEF_MINIGUN_SHELLEJECT;
float		PEF_FLACKGUN_TRACE;
float		PEF_FLACKGUN_MUZZLEFLASH;
float		PEF_FLACKGUN_HIT;
float		PEF_FLACKGUN_SHELLEJECT;
float		PEF_BEAMCANNON_TRACE;
float		PEF_BEAMCANNON_MUZZLEFLASH;
float		PEF_BEAMCANNON_HIT;
float		PEF_TURRETBEAM_TRACE;
float		PEF_TURRETBEAM_MUZZLEFLASH;
float		PEF_TURRETBEAM_HIT;
float		PEF_TURRETBEAM_SMOKE;
float		PEF_DESTROYERBEAM_TRACE;
float		PEF_DESTROYERBEAM_MUZZLEFLASH;
float		PEF_DESTROYERBEAM_HIT;
float		PEF_SPREAD_MUZZLEFLASH;
float		PEF_SPREAD_HIT;
float		PEF_THUNDERBOLT;
float		PEF_THUNDERBOLT_MUZZLEFLASH;
float		PEF_THUNDERBOLT_HIT;
float		PEF_LIGHTNINGBOLT_HIT;
float		PEF_REPAIR_TRACE;
float		PEF_REPAIR_MUZZLEFLASH;
float		PEF_REPAIR_HIT;
float		PEF_PROTON_HIT;
float		PEF_HEAVYTANK_MINIGUN_TRACE;
float		PEF_HEAVYTANK_MINIGUN_MUZZLEFLASH;
float		PEF_HEAVYTANK_MINIGUN_HIT;	
float		PEF_WINGTRAIL;
float		PEF_JETS_IDLE;
float		PEF_JETS_MOBILE;
float		PEF_MISSILE_EXHAUST;
float		PEF_MISSILE_SMOKE;
float		PEF_SHOCKWAVE;
float		PEF_SPAWNCHARGE_SMALL;
float		PEF_SPAWNCHARGE_MEDIUM;
float		PEF_SPAWNCHARGE_SMALL_EXPLODE;
float		PEF_SPAWNCHARGE_MEDIUM_EXPLODE;
float		PEF_PATHCONNECTIONLINE;
float		PEF_PATHCONNECTIONLINETEMP;
float		PEF_PATHCONNECTIONLINETRANSFER;
float		PEF_PATHCONNECTIONLINESELECTEDGROUP;
float		PEF_PATHCONNECTIONLINESELECTEDGROUPTRANSFER;
float		PEF_PATHCONNECTIONLINEFORAI;
float		PEF_ENTITY_DAMAGE_SMOKE;
float		PEF_ENTITY_DAMAGE_SMOKE_MED;
float		PEF_ENTITY_DAMAGE_SMOKE_LARGE;
float		PEF_ENTITY_DAMAGE_BURN;
float		PEF_ENTITY_DAMAGE_BURN_MED;
float		PEF_ENTITY_DAMAGE_BURN_LARGE;	
float		PEF_ENTITY_EFFECT_STUN;
float		PEF_ENTITY_EFFECT_WEPDISABLE;

.float		particleindex;

/*float		KEY_TAB				= 9;
float		KEY_ENTER			= 13;
float		KEY_ESC				= 27;
float		KEY_SPACE			= 32;
float		KEY_SLASH			= 47;
float		KEY_SEMICOLON		= 59;
float		KEY_TILDE			= 96;
float		KEY_ALT				= 132;
float		KEY_CTRL			= 133;
float		KEY_SHIFT			= 134;
float		KEY_BACKSPACE		= 127;
float		KEY_UPARROW			= 128;
float		KEY_DOWNARROW		= 129;
float		KEY_LEFTARROW		= 130;
float		KEY_RIGHTARROW		= 131;
float		KEY_DELETE			= 148;
float		KEY_KEYPADENTER		= 172;

float		BTTN_MOUSE1			= 512;
float		BTTN_MOUSE2			= 513;
float		BTTN_MWHEEL			= 514;
float		MWHEEL_UP			= 515;
float		MWHEEL_DOWN			= 516;*/

vector		FONTSIZE_HUD;

vector		COLOR_HUD_INFO;

float		PERCENTBAR_PERCENT		= 1;
float		PERCENTBAR_RATIO		= 2;

vector		WAYPOINT_OFS;

//Input.qc

vector		mousepos;
vector		oldmousepos;
//vector		mousetargetpos;

//float		DRAWMOUSE;

float		ACTIVE_INPUT;
float		ACTIVE_INPUT;
float		INPUT_CHAT			= 1;
float		INPUT_CURRENTMENU	= 2;
float		INPUT_CURRENTMENU2	= 3;

float		clicktime;
float		lastbuttonclick;

float		CLICK_SINGLE	= 0;
float		CLICK_DOUBLE	= 1;
float		CLICK_HOLD		= 2;

entity		hover_ent;
entity		marker;
float		badmarkerplacement;
entity		movingent;

float		ESCMENU;

void SH_MenuControls();
void SH_PreMenuControls();


//Admin.qc

//float		editingwaypoints;
.float		cellconnection_id[4];
float		viewingnavigationcells;
entity		admin_editingent;
//.float		wp_connection[10];
//float		showallwplinks;
entity		justspawned;

void ToggleAdminMode();
void AdminModeActive();
//void CL_ToggleWaypointEditingMode();
//void RecieveWaypoint();
//void WipeClass();

float		SCALE_WAYPOINT	= 1;

var void()		MarkerPlacedFunc;
var void()		PostMarkerPlacedFunc;


//float		updatingentyaw;
//vector		oldangles;
//var void()		admin_EditingFunc;
//.void()		CommitFunc;
.float		allowediting;

//void UpdateMovingEntWaypointToServer();

void MoveEntity(vector start, vector end, vector planes);//vector start, vector end);
//void Set_PullDown_Admin_Navigation();
//void UpdateWaypointToServer(entity wp);


//Admin_Entities.qc

vector		defaultentangles;
float		placedent_randomyaw;
float		placedent_randomscale;
float		randomscale_min;
float		randomscale_max;
//float		currentplacementheight;
//.float		allowheightadjustment;
.float		allowpitchadjustment;
.float		unstackable;
//entity		selectedlinkobject;
//float		linkingportal;
//float		linkingforcefield;
float		linkingobj;

//.float		chargetime;
.float		chargeeffect;
.float		chargeeffect2;
.float		riftscale;
//.float		dead;
.entity		controlent;
entity		placedent;

var void()		ObjectLinkFunc;
var float(entity e)		LinkRules;

//void Portal_ChooseDestinationConfirm();
void ClearObjectLinkingData();
//void Draw_AdminMenu_Object();
//void Commit_Entity();
//void CloseMenu_AdminMenu_Object();
void CommitObject(entity e);
float AllowRandomYaw(entity e);


// Entities.qc

.float	toggle;
.vector lastorgofs;
.vector	targetorigin;
.float	lastanimflag;
.float	lastsoundflag;
.float	cantbemoved;
.float	hashealth;

.void(entity e, entity o)	FoundOwnerFunc;

//.vector immobiletime;

void beam_turret_firefunc() = {}
void minigun_turret_firefunc() = {};

void RadarEntChain_Add(entity e);
void RadarEntChain_Remove(entity e);
void CameraShakeChain_Add(entity e);
void CameraShakeChain_Remove(entity e);
void OwnerlessChain_Add(entity e);
void OwnerlessChain_Remove(entity e);
void HasAvelocityChain_Add(entity e);
void HasAvelocityChain_Remove(entity e);
void ControlEntChain_Add(entity e);
void ControlEntChain_Remove(entity e);
void Draw_MisionEditor_LinkMessage_LinkSuccessful();
void Draw_MisionEditor_LinkMessage_CantLinkToSelf();
//void Draw_MisionEditor_TeleporterLinkError_DestinationDoesntExist();
entity SpawnObject(entity e, float CLASS, float VARIANT, void() PostSpawnFunc);


//Other

.void()		ClearStringFunc;
.void()		PreRemoveFunc;
.void(entity e)		RemoveFunc;


//Admin_Menu.qc

.float		guiclass;
//float		GUI_MENU			= 1;

/*.float		state;
float		STATE_OPENED			= 1;
float		STATE_DEFAULT			= 2;
float		STATE_UNOPENED			= 4;
float		STATE_UNSCRIPTEDSWAP	= 8;
float		STATE_UNSCRIPTEDDROP	= 16;
float		STATE_VERTICAL			= 32;
float		STATE_FLIPPED			= 64;*/

//.string		menustring[10];

.vector		menupos;

.float		draworder;
float		menu_count;
.void()		DrawMenu;
.void()		CloseMenuFunc;

//vector		scrollboxwithbuttons_pos;
//vector		scrollboxwithbuttons_size;

//float		SCROLLTYPE_CHAT				= 0;
float		SCROLLTYPE_CURRENTMENU		= 1;

vector		boxsize;
//vector		percentbox;
float		titlethickness;
//float		lineheight;
float		linespace;
float		borderspace;
float		BORDERSPACE_PULLDOWN;

/*float		MF_CLOSEABLE			= 1;
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
float		MF_FULLSCREEN			= 4096;*/

float		SHOWHUD_HUD;
float		SHOWHUD_ADMINTOOLS;
vector		FONTSIZE_MENU_TITLE;
vector		FONTSIZE_PULLDOWN;
float		ALPHA_MENU;
float		ALPHA_HUD;
float		ALPHA_CHAT;
float		ALPHA_PULLDOWN;

//float		SFLAGS_MENU;
//float		SFLAGS_HUD;
//float		SFLAGS_CHAT;
//float		SFLAGS_PULLDOWN;

entity		active_menu;
entity		currentmenu;

//float		DRAWMOUSE;
//entity		menuundercursor;
//entity		nextfocusmenu;
//entity		focusnewmenu;
//entity		focusmenu;
//entity		draggingmenu;
//float		menumoved;
//entity		dragitem;
//float		dragshortcut;
//vector		iconpos;
//vector		mousedrag_ofs;
vector		mousedrag_start;
float		dragstate;
float		dragbutton;
//float		DRAG_START				= 1;
//float		DRAG_MOVE				= 2;
//float		DRAG_STILL				= 3;
//float		DRAG_END				= 4;

//entity		draggingmenu;

.vector		menupos;
.vector		menusize;
.float		mflags;

//string		menubar_option_name[10];
//var void()	menubar_option_func[] = {SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null}
//float		menubar_openmenu;

//string		pulldown_option[20];
//var void()	pulldown_func[] = {	SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null,
//								SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null	}
//var void()	pulldown_sub[] = {	SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null,
//								SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null, SUB_Null	}
//float		pulldown_flags[20];
//vector		pulldown_pos[5];
//vector		pulldown_box[5];
//float		pulldown_active_sub[5];
//float		pulldown_attached;
//vector		pulldown_ofs;
//vector		pulldown_mainofs;
//entity		pulldown_parent;
//float		pulldown_currentoption;
//entity		pulldown_ent;
//float		pulldown_interactid;
//var void()	pulldown_mainfunc;
//float		mouseoverpulldownmenu;
//.void()		PullDownMenuFunc;
//var void()	pulldown_tool;
//float		pulldown_tooltype;
//float		PDT_SUB					= 1;
//float		PDT_FUNC				= 2;
//float		pulldown_fadetime;

//float		PDFLAG_MARKED			= 1;
//float		PDFLAG_UNAVAILABLE		= 2;
//float		PDFLAG_MARKABLE			= 4;

//vector		input_cursorrealpos;
float		textcursor_blinktime;
float		textcursor_nodraw;
//float		inputstring_pos[10];

//float		INPUTTYPE_ALL		= 1;
//float		INPUTTYPE_NUMERICAL	= 2;

//float CursorInsideBox(vector pos, float width, float height);


//void MoveWaypoint();
//void Clear_PullDownMenu();
//void Toggle_PullDown(void() pulldownmenusetup, float ATTACH, entity pdent, float interactid, float openmenubar)

//effects

.float		density;
.float		bouncetime;
.vector		lastgibtrailorg;
.void()		trailfunc;
.void()		splatterfunc;
.float		splattertime;
float		global_splattersoundtime;
.float		spawningrift;

void SetObjectLight_Client(entity e, vector rgb, float rad, float lstyle, float shadows, string tag, vector ofs);


//PlayerEffects.qc

float		TAG_CANNON_R;
float		TAG_CANNON_L;
float		TAG_MINIGUN_R;
float		TAG_MINIGUN_L;
float		TAG_JET_R;
float		TAG_JET_L;
float		TAG_WINGTRAIL_R;
float		TAG_WINGTRAIL_L;
.vector		oldwingtrailRpos;
.vector		oldwingtrailLpos;


void ParticleTrail(entity e, float EFFECT, vector start, .vector end);


//Weapons.qc

.entity		hitent;

//entity		list_shieldballchain;
//.entity		shieldballchain;

.vector		org_start[2];
.vector		org_end[2];

.float		borntime;
.float		drawtime;

.entity		shieldent;

//entity		reticle_mirv;

void DrawThunderBoltPolygon(vector start, vector end, float maxlen, string texturename);


//Radar.qc

float		newmapobjecttime;
.float		isnewobject;
.float		blipsize;
float		mapimageexists;
.float		maptargetid;


//PlayerColor.qc

//vector		oldplayercolor;
//float		editingplayercolor;

//void Toggle_SetPlayerColor();


//Hud.qc
float		STAT_ITEMS1					= 42;
float		STAT_ITEMS2					= 43;

float		STAT_SECONDARYWEP			= 59;

float		STAT_MAPTIMESTART			= 58;
float		STAT_MAPTIMER				= 60;
float		STAT_LIVES					= 61;
float		STAT_POINTS					= 62;

float		STAT_FRAGS					= 64;
float		STAT_FRAGS_NPC				= 65;
float		STAT_FRAGS_OTHER			= 66;

float		STAT_SCOREVIEWINGTIME		= 70;
float		STAT_RESTARTTIME			= 71;

//float		scoreviewingtime_elapsed;
float		globalcooldownstart;
float		globalcooldownend;
float		scooldownstart;
float		scooldownend;

float		timestopped;
float		showmissionmap;
float		shield_old;
float		currenthealth_old;
float		points_old;
float		scoremultiplier_old;
vector		scorepos;
float		gainedarmortime;
float		lostarmortime;
float		gainedshieldtime;
float		lostshieldtime;

entity		objectiveblock;


//View.qc

//float		cameraflags;
float		CAMFL_SHAKE						= 1;
float		CAMFL_SHAKE_REVERSEFADE			= 2;

//float		camerashaketime;
float		fpscam;
vector		camerashakeofs;
float		camerashakeintervaltime;
.vector		camerashake;

.float		light_life_endtime;
.float		light_duration;
.vector		light_ofs;

entity		menu_generateminimap;
//entity		menu_missionmap;
//float		drawfog;

string		world_fog;
float		fog_replaced;

void DrawModelFlags();
void SpawnPointText(float pointsize, float multiplier, vector org);


//MissionEditorMenus.qc

string	defaultemittereffectname;
string	defaultambientsoundname;

//float	mission_gamemode;
float	gamemode_new;
//string	mission_campaign;
//string	mission_name;

float editorzoom;
vector	admincamera_ofs;
float	modifyingentangles;

.float	markedfordeletion;

.vector	oldangles;

.entity	temppathconnection;
entity	connectingpathfrom;

//.float	pathhead;
float	assigningaipatrolpath;

float	editingpaths;

entity	menu_missioneditor;

string	linklineimage;

float	waitingforserverresponse;
float	WFSR_ENTITYSAVEALLASCHECK	= 1;
float	WFSR_CREATECAMPAIGNECHECK	= 2;
float	WFSR_REQUESTLISTCAMPAIGNS	= 3;
float	WFSR_REQUESTADMINACCESS		= 4;
float	WFSR_REQUESTLISTGAMEMODES	= 5;
float	WFSR_REQUESTLISTMISSIONS	= 6;
float	WFSR_REQUESTGAMEJOIN		= 7;

//void SetMovementBehaviorPatrol();
void PlacePathConnection();
float AllowPathConnection(entity e);
//void PlacePathSplit_Next();
//void PlacePathSplit_Prev();

void RemoveMarkerAndCloseMenu();
void Draw_MissionEditor();
void ObjectMouseControls(entity e);
void ObjectKeyControls();
void EntAngleControls(entity e);
//void EntHeightControls(entity e);
void SetAdminModeAlpha(entity e);
void UnsetAdminModeAlpha(entity e);
void DeselectAdminEditingentAndCloseMenu();
void Draw_MissionEditorPlacingEntity();
//void Call_EditorExitConfirmation();
void Draw_MissionEditorSetTeleporterDestination();
void Draw_MissionEditorSetTrigger();
void Draw_MissionEditorSetTriggerTarget();
void Draw_MissionEditorSetTriggerAssociation();
//void LinkToHoverEntPath();
//void ReversedLinkToHoverEntPath();
void SetPathModelForOrientation(entity e);
void SetPathModelForOrientationLead(entity point);
void PathChain_Remove(entity e);
//void SetPathSplit_Next();
//void SetPathSplit_Prev();
//float SetNewPathGroupIDForSeveredPath(entity e, float pathid);
void TogglePathPointVisibility();
//void UpdateDeletedPathIDs(float oldid, float newid);
void TransferAIPathIDFromMissingPath(float oldid, float newid);
string GetCommitPathsString();
void ExitEditor();
void Draw_MissionEditorEntityOptions();
void DeselectAdminEditingent();
void Call_CampaignList();
void AllowMissionSave();
void Call_OverwriteMissionConfirmation();
void SetNewCampaignName();
void SetNewCampaignName_CampaignExists();
void MissionEditorPlacingEntityESCFunc();
void SetEmitterMarkerParticleEffect();
void SetEmitterMarkerAmbientSound();
void Call_EditObjectives();
void Call_GetServerPassword();
void AdminAccessDenied();
void AdminAccessGranted();
void RequestFromServer_CampaignList();
void Call_WaitingForServerMenu();


//cl_mission.qc

float	waitingonplayers;
float	deathtime;
//entity	menu_death;
entity	menu_missionbriefing;
entity	menu_scores;
entity	menu_votemenu;
entity	menu_endscores;
entity	menu_chooseteam;
.float	team;

entity	active_terminal;
entity	menu_terminal;

//cl_mission_editor_particles.qc

//void Call_SetParticleEffect();

void OpenTerminal();
void CloseTerminal();
void ToggleMissionBriefing();


//music

float	iseditingmissiontrack;

void SetMissionTrackFromServer();


// main

void SpawnCenterPrintText(string s, vector rgb);




void Call_GetJoinPassword();
void GameJoinGranted();
void GameJoinDenied();