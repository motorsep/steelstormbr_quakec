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
.void()		FireFunc;

void SetAndPrecacheModel(entity e, string modelname);

// sound channels
// channel 0 never willingly overrides
// other channels (1-7) allways override a playing sound on that channel
float	CHAN_AUTO		= 0;
float	CHAN_WEAPON		= 1;
float	CHAN_VOICE		= 2;
float	CHAN_ITEM		= 3;
float	CHAN_BODY		= 4;

float	ATTN_NONE		= 0;
float	ATTN_NORM		= 1;
float	ATTN_IDLE		= 2;
float	ATTN_STATIC		= 3;

float		SV_UPDATEDELAY			= 0.04;

float		RESPAWNTIME = 5;
float		RESTARTTIME = 10;

float		maxplayers;
float		minplayers;

string		mission_track;

//.string		altmodelname;
//.float		usingaltmodel;

//void		SUB_Null() = {};

float		publicguesteditoraccess;
.float		onlydrawforadmins;
.float		hasguestaccess;
.float		haseditoraccess;
.float		hasadminaccess;

.float		entid;
.float		targetentid;
.float		targetstagetwoentid;
.float		targetstagethreeentid;
//.entity		targetent;
.float		associationentid;

.float		triggerentid;
.float		triggerdelaytime;
.float		istrigger;
.float		istarget;
.float		maxtriggers;
.float		touchtrigger;
.float		triggertype;

.float		permanent;

float		GSF_COLORS		= 1;
float		GSF_ITEMS		= 2;

// LISTS

.entity		list_childchain;
.entity		childchain;
.entity		childchain_prev;

.entity		list_tagentchain;
.entity		tagentchain;
.entity		tagentchain_prev;

//entity		list_notcellchain;
//.entity		notcellchain;
//.entity		notcellchain_prev;

.float		mobile;
entity		list_mobileentchain;
.entity		mobileentchain;
.entity		mobileentchain_prev;

entity		list_aichain;
.entity		aichain;
.entity		aichain_prev;

entity		list_playerchain;
.entity		playerchain;
.entity		playerchain_prev;

entity		list_objectchain;
.entity		objectchain;
.entity		objectchain_prev;

entity		list_pathchain;
.entity		pathchain;
.entity		pathchain_prev;

entity		list_dlightchain;
.entity		dlightchain;
.entity		dlightchain_prev;

entity		list_particleemitterchain;
.entity		particleemitterchain;
.entity		particleemitterchain_prev;

entity		list_teamchain;
.entity		teamchain;
.entity		teamchain_prev;

entity		list_objectivechain;
.entity		objectivechain;
.entity		objectivechain_prev;

.entity		chain2;
.entity		chain3;

.float		oldyaw;
.float		oldpitch;
.float		oldroll;
.vector		oldorigin;
.vector		origin_base;
.vector		angles_base;
.float		hasturrets;
//.float		turnvelocity;

//FLAGS
float		FL_SHARED 			= 8192;
float		FL_REVIVE			= 16384;
float		FL_NOREVIVE			= 32768;
float		FL_ISBOSS			= 65536;
float		FL_SOLIDONDEATH		= 131072;


//SHARED ENT TYPES

float		ENT_PLAYER				= 1;
float		ENT_NPC					= 2;
float		ENT_PROJECTILE			= 3;
float		ENT_BULLET				= 4;
float		ENT_BEAM				= 5;
float		ENT_OBJECT				= 6;
float		ENT_TRAIN				= 7;
float		ENT_PATH				= 8;
float		ENT_PARTICLEEMITTER		= 9;
float		ENT_AMBIENTSOUND		= 10;
float		ENT_TEAM				= 11;
float		ENT_OBJECTIVE			= 12;


float		SFL_ISNEW				= 16777215;

float		SFL_ORIGIN				= 1;
float		SFL_ORIGIN_STOP			= 2;
float		SFL_ANGLES				= 4;
float		SFL_ANGLES_STOP			= 8;
float		SFL_ANIMATE				= 16;
float		SFL_SOUND				= 32;
float		SFL_SCORE				= 64;
float		SFL_FADE				= 256;
float		SFL_FADERESET			= 512;
float		SFL_TARGETNAME			= 1024;
float		SFL_SCOREMULTIPLIER		= 2048;
float		SFL_EFFECTS				= 4096;
float		SFL_PING				= 8192;
float		SFL_TELEPORT			= 16384;
float		SFL_BASEDATA			= 32768;
float		SFL_RESET				= 65536;
float		SFL_LIBERATE			= 131072;
float		SFL_AUDIBLE				= 262144;
float		SFL_ISSELF				= 524288;
float		SFL_STATE				= 1048576;
float		SFL_EXPLODE				= 2097152;
//float		SFL_		= 4194304;
	// 8388608
	
float		SCORESTAT_SCORE			= 0;
float		SCORESTAT_CAPTURES		= 1;
float		SCORESTAT_RETURNS		= 2;
float		SCORESTAT_FRAGS_PLAYER	= 3;
float		SCORESTAT_FRAGS_AI		= 4;
float		SCORESTAT_FRAGS_OTHER	= 5;
float		SCORESTAT_ACCURACY		= 6;
float		SCORESTAT_DAMAGE_DEALT	= 7;
float		SCORESTAT_TIME_TAKEN	= 8;
float		SCORESTAT_TIME_LEFT		= 9;
float		SCORESTAT_TIME_BONUS	= 10;
float		SCORESTAT_DEATHS		= 11;
float		SCORESTAT_SUICIDES		= 12;
float		SCORESTAT_SCOREPLACING	= 13;

float	SCORESTATS_TOTAL		= 13;

// send flag sounds
float		SOUND_MINIGUN_PLAYER_STOP		= 1;
float		SOUND_STORMPLOW_PLAYER_STOP		= 2;
float		SOUND_STORMSHIELD_PLAYER_STOP	= 3;
float		SOUND_PLAYER_LAND				= 4;
float		SOUND_MINIGUN_HEAVY_STOP		= 5;
float		SOUND_MINIGUN_PLAYER_FIRE		= 6;
float		SOUND_MINIGUN_HEAVY_FIRE		= 7;
float		SOUND_FLACKGUN_PLAYER_FIRE		= 8;

float		SOUND_PICKUP_CRYSTAL_RED		= 10;
float		SOUND_PICKUP_CRYSTAL_BLUE		= 11;
float		SOUND_PICKUP_CRYSTAL_GREEN		= 12;
float		SOUND_PICKUP_SHIELD				= 13;
float		SOUND_PICKUP_ARMOR_PLATE		= 14;
float		SOUND_PICKUP_ARMOR_FULL			= 15;
float		SOUND_PICKUP_WEAPON				= 16;
float		SOUND_PICKUP_EXTRALIFE			= 17;
float		SOUND_PICKUP					= 18;
float		SOUND_PICKUP_FLAG				= 19;
float		SOUND_TERMINAL_ERROR			= 20;
float		SOUND_PICKUP_DATAKEY			= 21;
float		SOUND_PICKUP_CORRUPTFUSIONCORE	= 22;
float		SOUND_TELEPORT_ERROR			= 23;
float		SOUND_FLYERDOCKIN				= 24;
float		SOUND_FLYERDOCKOUT				= 25;
float		SOUND_TERMINAL_ACCEPT			= 26;


// send flag animations;
float		ANIM_PLAYER_MINIGUNS		= 1;
float		ANIM_PLAYER_MISSILES		= 2;

float		ANIM_DESTROYER_SHOOT1		= 4;
float		ANIM_DESTROYER_SHOOT2		= 5;

float		ANIM_TERMINAL_OPEN			= 6;
float		ANIM_TERMINAL_CLOSE			= 7;

// path flags

float	pathfunctions;

float 	PATHFUNC_EXTEND					= 1;
float	PATHFUNC_SPLIT_NEXT				= 2;
float	PATHFUNC_SPLIT_PREV				= 4;
float	PATHFUNC_CONNECT				= 8;

float		spawningsectorents;

.void()		PreRemoveFunc;
.void(entity e)		RemoveFunc;
.void()		ClearStringFunc;

.void()		EffectFunc;
.void()		DeathFunc;

.void()		Anim_Default;
.float		firingfrom;
.vector		frames_move;
.vector		frames_idle;
//.vector		frames_shoot_cannon_R;
//.vector		frames_shoot_cannon_L;
.vector		frames_shoot_hmissiles_R;
.vector		frames_shoot_hmissiles_L;

.float	frame1time;
.float	frame2time;
.float	frame2;
.float	lerpfrac;
.float	framespeed;
.void() AnimFunc;

.float		id;
//.float		cl_id;
//.float		wpid;

.entity		parent;

/*string		SEP_SPACE	= " ";
string		SEP_QUOTE	= "\"";
string		SEP_A		= "…";
string		SEP_BR		= "ÿ";
string		SEP_LBRAK	= "[";
string		SEP_RBRAK	= "]";
string		SEP_PERIOD	= ".";
string		SEP_COMMA	= ",";*/

.float		class;
.float		variant;
.float		shotclass;
.float		shotvariant;

float		CLASS_PLAYER				= 1;
float		CLASS_SOUND					= 2;
float		CLASS_CELL					= 4;
float		CLASS_CONTROLENT			= 5;
float		CLASS_OBJECT				= 6;
float		CLASS_SHOT					= 10;
float		CLASS_DLIGHT				= 11;

// shot classes
float		SHOT_PROJECTILE		= 1;
float		SHOT_BULLET			= 2;
float		SHOT_BEAM				= 3;

// shot variants
float		PROJ_STORMPLOW				= 1;
float		PROJ_STORMSPREAD			= 2;
float		PROJ_STORMSHIELD			= 3;
float		PROJ_ROCKET					= 4;
float		PROJ_MISSILE				= 5;
float		PROJ_MIRV					= 6;
float		PROJ_MINIMIRV				= 7;
float		PROJ_PLASMA_LIGHT			= 8;
float		PROJ_PLASMA_MED				= 9;
float		PROJ_PLASMA_HEAVY			= 10;
float		PROJ_PLASMA_DEEP			= 11;
float		PROJ_PROTON					= 12;
float		PROJ_PROTON_MED				= 13;

float		BULL_MINIGUN_PLAYER			= 1;
float		BULL_MINIGUN_HEAVY			= 2;
float		BULL_FLACKGUN_PLAYER		= 3;

float		BEAM_CANNON					= 1;
float		BEAM_THUNDERBOLT			= 2;
float		BEAM_LIGHTNINGBOLT			= 3;
float		BEAM_TURRETBEAM				= 4;
float		BEAM_REPAIR					= 5;
float		BEAM_DESTROYERBEAM			= 6;

.float		objclass;
float		OBJ_PATH				= 3;
float		OBJ_NPC					= 7;
float		OBJ_PARTICLEEMITTER		= 8;
float		OBJ_AMBIENTSOUND		= 9;
float		OBJ_TRAIN				= 12;
float		OBJ_OBJECTIVE			= 13;
float		OBJ_TRIGGERRELAY		= 14;

float		OBJ_PORTAL				= 64;
float		OBJ_ENEMYSPAWN			= 65;
float		OBJ_FORCEFIELD			= 66;
float		OBJ_PRESSUREPLATE		= 67;
float		OBJ_TELEPORTER			= 68;
float		OBJ_CIVILIANSTRUCT		= 69;
float		OBJ_OBJECTIVESTRUCT		= 70;
float		OBJ_TREE				= 71;
float		OBJ_STONE				= 72;
float		OBJ_VEHICLE				= 73;
float		OBJ_RUBBLE				= 74;
float		OBJ_EQUIPMENT			= 75;
float		OBJ_SPAWNPAD			= 76;
float		OBJ_EXITPAD				= 77;
float		OBJ_ROCKGROUP			= 78;
float		OBJ_STRUCTURE			= 79;
float		OBJ_ENVCRYSTAL			= 80;
float		OBJ_STALAGMITE			= 81;
float		OBJ_VOLCANO				= 82;
float		OBJ_ROADBLOCK			= 83;
float		OBJ_ROCKFORMATION		= 84;
float		OBJ_PLANT				= 85;
float		OBJ_GRASS				= 86;
float		OBJ_EQUIPMENT_BIG		= 87;
float		OBJ_EQUIPMENT_MED		= 88;
float		OBJ_FLAGBASE			= 89;
float		OBJ_FLAG				= 90;
float		OBJ_TERMINAL			= 91;
float		OBJ_DATAKEY				= 92;
float		OBJ_CORRUPTFUSIONCORE	= 93;
float		OBJ_FUSIONCORERACK		= 94;

float		OBJ_CRYSTAL				= 100;
float		OBJ_ARMORSHARD			= 101;
float		OBJ_ARMORSHELL			= 102;
float		OBJ_SHIELDPICKUP		= 103;
float		OBJ_EXTRALIFE			= 104;
float		OBJ_WEAPONPICKUP1		= 105;
float		OBJ_WEAPONPICKUP2		= 106;




// variant used with weapon pickup, player item storage, and weapon firing function calling

// npc weapons
float		WEP_TURRETBEAM			= 100;
float		WEP_LASER				= 101;
float		WEP_LIGHTNING			= 102;
float		WEP_PLASMA				= 103;
float		WEP_PROTON				= 104;
float		WEP_PROTON_MED			= 105;
float		WEP_REPAIR				= 106;
float		WEP_HMISSILES			= 107;
float		WEP_DESTROYERBEAM		= 108;

.float		npcclass;
float		NPC_TURRET					= 1;
float		NPC_LIGHTTANK				= 2;
float		NPC_MEDIUMTANK				= 3;
float		NPC_HEAVYTANK_PROTON		= 4;
float		NPC_LIGHTNINGTANK			= 5;
float		NPC_CARRIERTANK				= 6;
float		NPC_DESTROYERTANK			= 7;
float		NPC_MICROFLYER				= 8;
float		NPC_HEAVYTANK_MINIGUN		= 9;

float		NPC_STATIONARYTURRET		= 10;
float		NPC_LIGHTPLASMATURRET		= 11;
float		NPC_HEAVYBEAMTURRET			= 12;
float		NPC_ROCKETTURRET			= 13;
float		NPC_REPAIRTURRET			= 14;

float		NPC_FRIENDLYLIGHTTANK		= 102;

float		NPC_TURRETHEAD_HEAVYTANK_PROTON_L	= 50;
float		NPC_TURRETHEAD_HEAVYTANK_PROTON_R	= 51;
float		NPC_TURRETHEAD_HEAVYTANK_PLASMA_L	= 52;
float		NPC_TURRETHEAD_HEAVYTANK_PLASMA_R	= 53;
float		NPC_TURRETHEAD_HEAVYTANK_PROTON_MED	= 54;
float		NPC_TURRETHEAD_HEAVYTANK_MINIGUN	= 55;
float		NPC_TURRETHEAD_CARRIERTANK_REPAIR	= 56;
float		NPC_TURRETHEAD_DESTROYER_PLASMA_L	= 57;
float		NPC_TURRETHEAD_DESTROYER_PLASMA_R	= 58;
float		NPC_TURRETHEAD_DESTROYER_REPAIR		= 59;
float		NPC_TURRETHEAD_STATIONARY_PLASMA	= 60;
float		NPC_TURRETHEAD_STATIONARY_BEAM		= 61;
float		NPC_TURRETHEAD_STATIONARY_ROCKET	= 62;
float		NPC_TURRETHEAD_STATIONARY_REPAIR	= 63;


float		NUMTURRETTYPES				= 4;

float		STRUCTURE_INCINERATOR				= 0;
float		STRUCTURE_BUNKER					= 1;
float		STRUCTURE_HANGAR					= 2;
float		STRUCTURE_BARRACKS					= 3;
float		STRUCTURE_COOLINGTOWER				= 4;
float		STRUCTURE_COOLINGTOWER_TWIN			= 5;
float		STRUCTURE_OBELISK					= 6;
float		STRUCTURE_PYLON						= 7;
float		STRUCTURE_GASPUMP					= 8;
float		STRUCTURE_REFINERY					= 9;
float		STRUCTURE_EVAPORATOR				= 10;
float		STRUCTURE_BBOSS						= 11;
float		STRUCTURE_BBOSS_SMALL				= 12;


float		TE_REQUESTEPISODENUM			= 150;

float		TE_REQUESTJOINPASSWORD			= 151;
float		TE_GAMEJOINGRANTED				= 152;
float		TE_GAMEJOINDENIED				= 153;

float		TE_TOGGLEADMINMODE				= 129;
float		TE_TOGGLEWAYPOINTEDITINGMODE	= 130;
float		TE_SENDWAYPOINT					= 132;
float		TE_ADMINMODEACTIVE				= 133;
float		TE_ADMINMODETOGGLE_MAXENTS		= 134;

//float		TE_REMOVEENT					= 139;
float		TE_WIPECLASS					= 140;


//float		TE_BEAM_HIT						= 104;
float		TE_SHOCKWAVE					= 105;

float		TE_MISSIONLOCKSTATUS			= 110;

float		TE_ALLOWCAMPAIGNCREATION		= 195;
float		TE_DENYCAMPAIGNCREATION			= 196;

float		TE_ALLOWMISSIONSAVE				= 197;
float		TE_OVERWRITEMISSIONCONFIRMATION	= 198;
float		TE_CAMPAIGNLIST					= 199;

float		TE_SHOWMISSIONSCORES			= 200;
float		TE_PLAYERSFINISHEDVIEWINGMISSIONSCORES = 201;
float		TE_CONNECTED					= 202;

float		TE_MISSIONTRACK					= 203;
float		TE_MISSIONBRIEFING				= 204;

float		TE_DEAD							= 205;
float		TE_GAMEOVERFORPLAYER			= 206;
float		TE_GAMEOVERFORALL				= 207;

float		TE_SENDCHALLENGES				= 208;
float		TE_SAVECHALLENGES				= 209;

float		TE_CHOOSETEAM					= 210;
float		TE_SETTEAM						= 211;

float		TE_OBJECTIVETEXT				= 212;

float		TE_CENTERPRINT					= 213;

float		TE_TERMINAL_OPEN				= 214;
float		TE_TERMINAL_CLOSE				= 215;

float		TE_GETSERVERPASSWORD			= 120;
float		TE_ADMINACCESSDENIED			= 121;
float		TE_ADMINACCESSGRANTED			= 122;

float		TE_GETCLIENTSTATS				= 218;

float		TE_VOTEMENU						= 219;
float		TE_GAMEMODELIST					= 220;
float		TE_MISSIONLIST					= 221;
float		TE_VOTESTATS					= 222;

#ifdef COMPILE_SERVICE_ONLIVE
	float		TE_ASKFORPLAYERNAME				= 230;
#endif


float		CPM_CANTFINISHGAMEWILEADMINISEDITING		= 1;
float		CPM_CANTACCESSEXITPADSWHILEADMINISEDITING	= 2;	
float		CPM_PRIMARYOBJECTIVESINCOMPLETE				= 3;
float		CPM_FORCEFIELDOPENED						= 4;
float		CPM_FINDAWAYTOOPENFORCEFIELD				= 5;
float		CPM_FINDADATAKEY							= 6;
float		CPM_USEDDATAKEY								= 7;
float		CPM_USEDCORRUPTFUSIONCORE					= 8;
float		CPM_FUSIONCORENEEDED						= 9;
float		CPM_PICKUP_MINIGUN							= 10;
float		CPM_PICKUP_FLACKGUN							= 11;
float		CPM_PICKUP_BEAMCANNON						= 12;
float		CPM_PICKUP_THUNDERBOLT						= 13;
float		CPM_PICKUP_STORMPLOW						= 14;
float		CPM_PICKUP_STORMSPREAD						= 15;
float		CPM_PICKUP_STORMSHIELD						= 16;
float		CPM_PICKUP_ROCKETPOD						= 17;
float		CPM_PICKUP_HOMINGMISSILES					= 18;
float		CPM_PICKUP_MIRV								= 19;
float		CPM_PICKUP_SHOCKWAVE						= 20;
float		CPM_SECONDARYSWITCH							= 21;
float		CPM_SECONDARYFIRE							= 22;
float		CPM_FLAG_DROPPED							= 23;
float		CPM_FLAG_PICKUP								= 24;
float		CPM_FLAG_RETURN								= 25;
float		CPM_FLAG_CAPTURE							= 26;

//sh_subs.qc

void SH_RemoveEnt(entity e);


//sh_entities.qc

//void UpdateMobileEntChain();
void MobileEntChain_Add(entity e);
void MobileEntChain_Remove(entity e);
entity Turret(entity e, string tagname, vector offset, float VARIANT, float WEP, float WEPVAR, vector f_rate, vector b_rate, float turret_yaw_speed, float turret_yaw_maxleft, float turret_yaw_maxright, float yawofs, float destructstage);

//Player
//.entity		part_cannon;
.float		scoreplacing;
.float		points;
.float		scoremultiplier;
.float		captures;
.float		returns;
.float		frags;
.float		frags_npc;
.float		frags_other;
.float		accuracy;
.float		damagedealt;
.float		deaths;
.float		suicides;



// Weapons

.float		direction;
.float		shotlen;
.float		shieldscale;
//.entity		hitent;
.float		fadetime;
.float		ballnum;
.entity		ballcontroller;


// Combat

.float		explodeuntiltime;
.float		isdead;

// Cells

vector		BASE_CELL_MAXS			= '96 96 0';
vector		BASE_CELL_MINS			= '-96 -96 0';
vector		BASE_CELLBBOX_MAXS		= '96 96 0';
vector		BASE_CELLBBOX_MINS		= '-96 -96 0';

vector		CELL_MAXS;
vector		CELL_MINS;

float		CELL_SCALE				= 0.6;

//vector		CELL_MAXS			= '48 48 0';
//vector		CELL_MINS			= '-48 -48 0';
//vector		CELLBBOX_MAXS		= '16 16 0';
//vector		CELLBBOX_MINS		= '-16 -16 0';


// Mission Editor

float		adminmodeactive;
.float		spawner_max_areaents;
.float		spawner_max_ents;
.float		spawner_max_lighttanks;
.float		spawner_max_mediumtanks;
.float		spawner_max_lightningtanks;
.float		spawner_max_heavytanks;

.float		allowrandomscale;

.string		particleemittereffect;
.float		particleindex;
.string		ambientsoundeffect;
.float		movement_behavior;
float		MB_STATIONARY	= 0;
float		MB_ROAM			= 1;
float		MB_PATROL		= 2;


// Pathing

.float		pathgroupid;
.entity		nextpathpoint;
.entity 	prevpathpoint;
.float		prevpathpointid;
.float		nextpathpointid;


// Objects

.float		canhaveteam;
.float		activated;
.float		requireskey;
.float		indestructible;
.float		deadmodelnum;
.float		deadmodels;
.float		istoggled;
.float		isusingcollisionhull;
.float		issolidcorpse;
.float		ismapobject;
.float		mapicon;
.float		spawntime;
.float		noflag;
.float		isdeletedformission;
.float		startstateoff;
.float		multiplayeronly;
.void()		DelayFunc;
.float		object_activationtime;
.float		activation_starttime;

.float		terminaltype;
float		TERMINAL_HACKING		= 0;
float		TERMINAL_UPLOADING		= 1;
float		TERMINAL_DOWNLOADING	= 2;
float		TERMINAL_ACTIVATING		= 3;
float		TERMINAL_DEACTIVATING	= 4;

.float		chullrotation;
float		CHULLROT_SHARP	= 0; // normal chull only rotates at 45 degrees, (chull and model)
float		CHULLROT_ROUND	= 1; // round chull only rotates at 45 degrees, (model rotates but chull stays at 0 angle)
float		CHULLROT_ALL	= 2; // round or no chull rotates at all angles (model rotates, but chull statys at 0 angle)

void SetMapObject(entity e);


// Combat

.float		liberated;
void Explode_Large();
void Explode_Small();
void Explode_Object();


// effects

.float		gibscale;
float		effectdrawtime;

.float		effectflags;

float		EFF_STUN			= 1;
float		EFF_WEPDISABLE		= 2;
float		EFF_SMOKE			= 4;
float		EFF_BURN			= 8;
float		EFF_BUTTONCHAT		= 16;


// mission

float		mission_locked;

float		vote_kickplayer;
float		vote_gamemode;
float		vote_gamemode_t;
string		vote_campaign;
string		vote_mission;
float		vote_fraglimit;
float		vote_capturelimit;
float		vote_force;
float		vote_type;
float		VOTE_MISSION	= 1;
float		VOTE_KICK		= 2;

float		mission_maptime_total;
float		mission_finished_time;
.float		objectivepriority;
.float		triggerobjectiveentid;

float GetTimeBonus(entity e);
float GetStatFromScoreString(string s, string stat);
string GenerateProfileGlobalItemsString(entity e, float globalitems1_old, float globalitems2_old);
string GenerateProfileItemString(entity e);