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
float		MISSION_FILEVERSION_CURRENT = 1;
float		MISSIONEPISODE;
float		MISSION_LANGUAGE;
float		CANDAMAGEMAXDIST = 2000;

float		SECTOR_GRIDSIZE = 2500;
float		sector_startbuf;
float		sector_endbuf;
float		enthealth;
.float		sectorid;
.entity		sectorent;

/*void ManageSectors();
void SetUpSectorGrid();
void UpdateSectorEnt(entity e);
void AssignObjectToSector(entity e);
float CanAssignToSector(entity e);*/

.string		fog;

string		campaign[NUMLANGUAGES+1];
string		mission[NUMLANGUAGES+1];
string		mission_briefing[NUMLANGUAGES+1];
.string		objectivetext[NUMLANGUAGES+1];


.float		requestingepisodenum;
.float		requestingjoinpassword;
.float		jointime;
.float		joinpasswordtime;

// LISTS

.float		nonsolidsolid;
entity		list_nonsolidsolidchain;
.entity		nonsolidsolidchain;
.entity		nonsolidsolidchain_prev;

entity		list_ambientsoundchain;
.entity		ambientsoundchain;
.entity		ambientsoundchain_prev;

entity		list_sectorchain;
.entity		sectorchain;
.entity		sectorchain_prev;

entity		list_loadingsectorentchain;
.entity		loadingsectorentchain;
.entity		loadingsectorentchain_prev;

.entity		list_sectorobjectchain;
.entity		sectorobjectchain;
.entity		sectorobjectchain_prev;

entity		list_recentlycommitedentitychain;
.entity		recentlycommitedentitychain;
.entity		recentlycommitedentitychain_prev;

entity		list_cellchain; // this list is special and is only used during cell spawning and requires no _prev variable
.entity		cellchain;

entity		list_trainchain;
.entity		trainchain;

//general use

.float		fixedyaw;

.float		fallvelocity;
float		totalentities;
.entity		childchain;
.vector		oldorigin2;
.vector		oldorigin3;
.vector		oldvelocity;
.float		constantspeedtime;
.entity		trigger;
.float		istriggered;

.float		finishedviewingmissionscores;
.float		scoreviewingtime;
//.float		mapwidth;
.float		maptime_start;
.float		maptime_total;
float		mission_maptime_start;
//.float		maptime_start;
float		activityhalted;
.float		restarttime;
float		server_restarttime;
float		emptyserver_restarttime;
float		server_scoreviewingtime;
float		dropitemsinmultiplayer;
float		itemsmode;
float		itemrespawndelay;
float		weaponrespawndelay;
float		maxscoreviewingtime;
float		fraglimit;
float		capturelimit;
float		gameskill;
float		skillmultiple;

//shared ents

float		MSG_ENTITY = 5;
.float		SendFlags;
.float		nextSendFlags;
.float		stopflags;
.void()		SendEntity;
.float		sfl_sound;
.float		sfl_animation;
.float		eventflag_sound;
.float		eventflag_animation;
.float		eventflag_sound_time;
.float		eventflag_animation_time;
.float		updatetime;	
//.float		postinitthinktime;
.void()		postinitthink;

float		globalitem_datakeys[2];
float		globalitem_corruptfusioncores[2];

.float		rechargetime_minigun;
.float		rechargetime_beam;
.float		rechargetime_spread;
.float		rechargetime_thunderbolt;
.float		rechargetime_shockwave;
.float		rechargetime_powerup;
.float		globalcooldown;
.float		secondarycooldown;
.float		glitem_datakeys;
.float		glitem_corruptfusioncores;

float SendTeam(entity viewer, float sendflags);


//subs.qc

.float		removetime;


//player

.float		buttonchat_old;
.float		menus_opened;
//.float		jointime;
.vector		player_colors;
.entity		lastentdamaged;
.float		playertargetswitchtime;
float		global_lives;
.float		lives;
//.float		globalitems1;
//.float		globalitems2;
.float		earneditems1;
.float		earneditems2;
.float		deadflags;
.float		maxshields;
//.float		powerup;
.float		secondarywep;
.float		enemyhealth;
.float		enemyhealth_max;
.float		enemyobjclass;
.float		enemyvariant;
//.float		mapwidth;
.float		buttondown;
.float		godmode;
//.float		initialized;
.float		initializeditems;
.float		messagetime;
.float		deathtime;
.float		lockedcamera;

.float		tutorial;
float	TUT_SECONDARYSWITCH		= 1;
float	TUT_SECONDARYFIRE		= 2;

//void AnnounceConnectionForAllPlayers();


//weapons.qc

.float		origionalyaw;
.float		rechargetimetotal_energy;
.float		rechargetimetotal_missile; 
.float		weaponshotvariant;
//.float		wepclass;

.void(entity e)		hitfunc;

.float		hit[2];

.float		attack_finished[5];

.vector		intendeddirection;

.float		shootfrom_index[2];
.float		spreadmode;

.float		wepreleasetime;

.void() WepReleaseFunc;
float AttackFinished(entity e, float WEP1, float WEP2, float weprpiority);


//ai.qc

.float		yaw_speed_base;

.float		forcefieldtoggledcheck;

.void()		TriggerEventFunc_StageTwo;
.void()		TriggerEventFunc_StageThree;

.float		yaw_speed_base;

.float		destructatstage;

.float		firebuilduptime;
.void()		FastThink;

.float		activemovetype;

float		pauseai;

.float		spawnedfromtag;

.string		sound_spottedenemy;

.float		dodgetime;
.vector		dodgeorigin;

.float		action;

float		ACT_IDLE				= 0;
float		ACT_FIGHT				= 1;
float		ACT_MOVE				= 2;
float		ACT_FLANK				= 4;
float		ACT_DODGE				= 8;
float		ACT_STRAFE				= 16;
float		ACT_FLEE				= 32;
float		ACT_BACKOFF				= 64;
float		ACT_THREATENED			= 128;
float		ACT_ROAM				= 256;
float		ACT_DOCK				= 512;
float		ACT_APPROACHING			= 1024;
float		ACT_HARASS_ATTACK		= 2048;
float		ACT_HARASS_FLEE			= 4096;
float		ACT_APPROACH			= 8192;

float		LOW			= 0;
float		NORMAL		= 1;
float		MEDIUM		= 2;
float		HIGH		= 3;

.float		reactiontime;
.float		alertnessdelay;
.float		targetswitchdelay;

//.float		alertness_audio;

.float		burstcount;

float		AIFL_DUALFIRE				= 1;
float		AIFL_PROXIMITYDESTRUCT		= 2;

.float		ammo_rockets_max;
.float		ammo_rockets_current;
.float		refueltime;

.float		maxfiringpos;
.float		firingpos;
.float		autofiretime;

.float		movingtosource;

//.vector		origin_roambase;

.void()		FiringRules;

float		SLOWDOWNDISTANCE		= 100;

.float		spawnang;
.float		flightelevation;
.float		approachtime;

.float		movespeed;
.float		movementinertia;
/*float		SPEED_MEDIUM_HIGH			= 30;

float		MANEUVER_MEDIUM_HIGH		= 30;

float		HEALTH_LOW					= 100;*/

.float		targetswitchdelay;
.float		alertnessdelay;

.float		alertness;
float		ALERTNESS_DAMAGE			= 1;
float		ALERTNESS_CONE				= 2;
float		ALERTNESS_OMNIDIRECTIONAL	= 4;

.float		engagedist_near;
.float		engagedist_far;

.float		behaviorflags;
float		BF_MOVEANDFIRE					= 1;
float		BF_ROAM							= 2;
float		BF_ROAM_NOTARGET				= 4;
float		BF_HOVER						= 8;
float		BF_STRAFEINCOMBAT				= 16;
float		BF_TURRET						= 32;
float		BF_SPAWNCHILDREN				= 64;
float		BF_FLIES						= 128;
float		BF_ROAM_ALTERNATE				= 256;
float		BF_AVOIDEDGES					= 512;
float		BF_HARASS						= 1024;
float		BF_STATIONARY					= 2048;
float		BF_INCREASESPEEDATSTAGETWO		= 4096;
float		BF_INCREASESPEEDATSTAGETHREE	= 8192;
float		BF_NOSLEEP						= 16384;
float		BF_LOOKFORALLIES				= 32768;

.vector		roamdata;

float		TARGET_ENEMY				= 1;

float		WEP_PLASMA;

.vector		burstrate;
.vector		firingrate;
.vector		secondaryfiringrate;
.vector		secondaryburstrate;
.void()		SecondaryWeaponFiringRules;

.float		maxpitchaim;

//.entity		goalentity_sub;

.float		timespathblocked;
.vector		roamtargetdest;
.float		roamtime;
.float		driveby;
.float		weaponrange;
.float		yaw_maxleft;
.float		yaw_maxright;
.float		yaw_baseofs;
.entity		facetarget;

.void()		SpawnChildrenFunc;
.float		spawnchildrentime;
.float		numchildren;
.float		maxchildren;
.entity		ally;
.entity		killedby;
//.float		lookfordeadallytime;

.float		firetime;

void AIChain_Add(entity e);
void AIChain_Remove(entity e);
void WeaponAutoFire(float WEP1, float WEP2);
//void AlertAI_audio(entity noisyent);
void AI_TurretMove();
void AI_Dodge(entity victim, entity attacker);
void AI_Think();
void FoundThreat(entity victim, entity threat, float repair);
float AI_Sleep();
vector GetLeadAngle(vector firepos, entity combattarget, float WEP);
void AI_Wake();


//enemies.qc

var void()	PostTurretSpawnFunc;

void TriggerEnemy();

//admin.qc

float		viewcellmodeactive;
.float		viewingnavigationcells;
.float		adminmode;
//.entity		editor;
//entity		newadmin;
entity		newcellviewer;
entity		server_bottleneck_ent;

//void ClearClientEntClass(entity viewer, float CLASS);
void ToggleAdminMode();
void ClearEntIDFields(.float idfloat, float idnum);
void SendBottleNeckedAdminEnts();


//admin_entities.qc

float		admin_reloadingents;
float		mission_fileversion;

.float		spawnedfrom;
.float		teleporttouchtime;
.float		exittouchtime;
.float		terminaltouchtime;
.float		hastriggered_stagetwo;
.float		hastriggered_stagethree;
float		missionfileexists;
.string		childtagprefix;
.float		isdataent;
.entity		placedby;
.entity		lastplacedpathpoint;
float		server_loadingobjectsfromfile;
.float		currenttriggers;

void SaveEntities(float backup);
void LoadEntities();
entity SpawnEntity(entity e, float CLASS, float VARIANT);
void SendObjectToClients(entity e);
void SetUpEntPointers();
void ParseObjectsFromFile();
string GetMissionFilename(float mode, string cname, string mname, float local, float language);
void ClearEntData(entity e);
//void SendBottleNeckedSectorEnts();

//combat.qc

.float		stuntime;
.float		wepdisabletime;
.float		armorchargetime;
.float		explodetime;
.float		removewhendead;
.float		explosiondamage;
.float		explosionradius;
.entity		liberator;

void InitLongExplode();
void Kill(entity victim, entity attacker);
void KillClient(entity e, entity a);
void RadiusDamage(entity dmgent, entity victim, float damage, float rad);


//entities.qc

.float		ScoreFlags;
//.string		objectname;
.float		mute;
.float		isallowedtofloat;
.float		showhealth;
.float		showhealth_victim;
//.float		oldpathgroupid;

void beam_turret_firefunc();
void minigun_turret_firefunc();

void UpdateSharedEnt(entity e);
float SendObject(entity viewer, float sendflags);
void InitializeObjectOrientation(entity e);
void UpdateScore(entity e, float SCORE_FLAG);


//cells.qc

float		AI_SPACING					= 2;

.vector		cellpath[5];
float		CELLPATHPOINTS_MAX 			= 5;
//.entity		cellconnection[4];
.entity		cellconnection_0;
.entity		cellconnection_1;
.entity		cellconnection_2;
.entity		cellconnection_3;
.float		occupancy;
.vector		gridpos;
.float		pathpattern;
float		numcells;
.float		cellzone;
.float		hadenemylastframe;
.float		cantshootenemy;

.float		isblocked;
.float		waittomovetime;



entity		cellfiller;
float		CELL_MAXFILLDIST	= 300;
float		CELL_MAXFILLDIST_COMBAT = 1000;
float		CELL_MINFILLDIST_FLIGHT = 350;
float		LARGEOBJECT_WIDTH	= 160;

vector		CELLBBOX_MAXS;
vector		CELLBBOX_MINS;

entity		list_newcellchain;
.entity		newcellchain;
.entity 	newcellchain_prev;

void ConnectCells();
//void MarkCellsAroundLargeObjects();
void CellFill(entity cell, vector org, float cellfillradius, float loopnum);
void MarkGrid(entity e, float FILLCELLS, float OCCUPYCELLS, vector lastgridpos);
void UnmarkGrid(entity e, float FILLCELLS, float OCCUPYCELLS);
void RemoveUnusedCells(entity e, vector lastgridpos);
entity GetCellConnection(entity cell, float count, float GETWALL);
float CreateCell(vector org, float loopnum, float cellfillradius, float zoneid);
//void InitializeNavigationCells();
float EntityInCellProximity(entity cell, float AVOIDWALLS);
void SetUpCellPath(vector start, entity endcell);


//sv_mission.qc

#ifdef COMPILE_SERVICE_ONLIVE
	float		realarcade_waitingformissioncompleteresponse;
	float 		savescorestime;
	float		MAXSCORESAVES		= 20;
	
	void SaveScores(float WRITESCORES);
	void SendMissionScores(float MSGTYPE);
#else
	float		MAXSCORESAVES		= 50;
#endif


float		missionscores_endgame;
float		showingmissionscores;
float		vote_applysettingstime;
float		vote_tallytime;
float		vote_tally_yes;
float		vote_tally_no;
.float		stat_vote_applysettingstime;
.float		stat_vote_tallytime;
.float		stat_vote_tally_yes;
.float		stat_vote_tally_no;
.float		vote_ballot;

void MissionTimeUp(float MSGTYPE);
void ApplyVoteSettings();
void CountVotes();
void Vote(float v);

//sv_client.qc

void AnnounceConnection();
void UpdateLives(float newlivesamount);


//objects

.float		keyed;
.void()		touchfunc;
.entity		forcefieldgate;
.void()		TriggerFunc;
.string		targetname_pointer;
.float		pickupsound;
float		activatedtrains;
.float		originalmodelindex;

.float		damage_effects;
float		DMGEF_BURN		= 1;

//void InitializeTrains();
void func_train_initialize();
void ResetTrainData(entity e);
void TrainStop();
void DropItems(entity victim);
void func_train();


// CTF
.entity		flagent;
.entity		carrier;
.float		flagtouchtime;

void DropFlag(entity e);


// items

.float		items1;
.float		items2;
.float		atdeath_items1;
.float		atdeath_items2;
.float		itemtouchtime;
.float		persistondrop;

void flag_touch();
void DropItem(entity item, entity e, float CLASS, float VARIANT);


// triggers

.entity		user;
entity		list_frametriggerchain;
.entity		frametriggerchain;


// challenges

.float		challenge_annihilator;
.float		challenge_berserker;
.float		challenge_perforator;
.float		challenge_morbidblanket;
.float		attemptedhits;
.float		connectedhits;
.float		lastkillwep;
.float		consecutivewepkillcount;
.float		simultaneouskills;
.float		simultaneouskilltime;
float		ai_total;
float		ai_killed;
