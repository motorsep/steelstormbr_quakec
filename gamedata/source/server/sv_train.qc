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
////////////////////////////////////////
// Steel Storm source code
// Property of Kot-In-Action
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

// train state
enum
{
	TRAIN_STATE_IDLE,		// not activated
	TRAIN_STATE_STOPPED,	// stopped, no target is set
	TRAIN_STATE_MOVING,		// moving to path_corner (save out movespeed, movedest)
	TRAIN_STATE_PAUSED,		// stopped while moving
	_
};

// spawnflags
#define SPAWNFLAG_WALL_INVISIBLE	8

#define SPAWNFLAG_TRAIN_ORIGIN		65536 	// set automatically
#define SPAWNFLAG_TRAIN_AUTOSTOP	1 		// stop on each corner train reaches
#define SPAWNFLAG_TRAIN_DAMAGE		2 		// do damage if touch entity

void() train_reach_corner;
entity extrathink;
.void() movethink;
.vector movedest;
.vector moveang;
.float state;
.float cnt;
.float dmg;

// used for targeting
.string target;
.string targetname;
.string targetparm;

////////////////////////////////////////
// CODE
////////////////////////////////////////

void ResetTrainData(entity e) =
{
	e.angles = e.angles_base;
	setorigin(e, e.origin_base);
	e.avelocity = '0 0 0';
	e.movethink = SUB_Null;
	e.movedest = '0 0 0';
	e.moveang = '0 0 0';
	e.state = 0;
	e.cnt = 0;
}

// find entities with matching targetname (except self)
entity FindTargets(entity ignore, string t, string classname_prefix) =
{
	entity check, targ, start, e;
	float cnlen;
	
	if (t == "")
		return world;
	cnlen = strlen(classname_prefix);
	start = world;
	e = world;
	for(targ = find(world, targetname, t); targ; targ = find(targ, targetname, t))
	{
		if (cnlen && substring(targ.classname, 0, cnlen) != classname_prefix)
			continue;
		if (!e) // start chain
		{
			start = targ;
			e = targ;
			continue;
		}
		// add chain
		e.chain = targ;
		e = targ;
		e.chain = world;
		break;
	}
	return start;
}

/*
======================================================================

 Func_Wall
 
======================================================================
*/

void() InitBmodel =
{
	self.solid = SOLID_BSP;
	self.movetype = MOVETYPE_PUSH;
	if(self.model && self.model != "null")
		setmodel(self, self.model);
//	else
//		return;
		
	setorigin(self, self.origin);
	self.SendFlags = self.SendFlags | 1;
}

/*
======================================================================

 Generic ents as SS tags (so SourceScanner can parse them and export)
 
======================================================================
*/

/*SS
form=	quaked;
lang=	english;
min=	-4 -4 -4;
max=	4 4 4;
color=	0.77 0.88 1.0;
class=	_skybox;
name=	SkyBox;
desc=	Compiler-only entity that specifies a the origin of a sky box (a wholly contained, separate area of the map), similar to some games portal skies. When compiled with Q3Map2, the sky box surfaces will be visible from any place where sky is normally visible. It will cast shadows on the normal parts of the map, and can be used with cloud layers and other effects. As it is compiler-only, it cant "scale up" entities in its box.
		To use this, carve a small box in some larger structure on your map, place this entity inside that box hole, and make a small version on what should be seen in the sky there.;
key=	angle\angle\0\Yaw angle\Horizontal (yaw) angle direction in which model will be oriented;
key=	angles\angles\0 0 0\Angles\Individual control of PITCH, YAW, and ROLL;
key=	_scale\real\\Scaling factor\Scaling factor, good values are between 50 and 300, depending on the map;
*/

/*SS
form=	quaked;
lang=	english;
color=	0 0.5 0.8;
class=	func_group;
name=	Group;
desc=	This is not an entity as such. It is strictly an editor utility to group world brushes and patches together for convenience (selecting, moving, copying, etc). You cannot group entities with this.;
key=	_lightmapscale\real\\Lightmap Scale\light map resolution factor, smaller = more detailed lightmaps;
key=	_castshadows\integer\\Cast Shadows\Allows per-entity control over shadow casting. Defaults to 0 on entities, 1 on world. 0 = no shadow casting. 1 = cast shadows on world. > 1 = cast shadows on entities with _rs (or _receiveshadows) with the corresponding value, AND world. Negative values imply same, but DO NOT cast shadows on world.;
key=	_receiveshadows\integer\\Receive Shadows\Allows per-entity control over shadow reception. Defaults to 1 on everything (world shadows). 0 = receives NO shadows. > 1 = receive shadows only from corresponding keyed entities (see above) and world. < 1 = receive shadows ONLY from corresponding keyed entities.;
key=	_celshader\string\\Cel Shader\Sets the cel shader used for this geometry. Note: omit the "textures/" prefix;
key=	_indexmap\string\\Index Map\Path/name for the TGA file used to guide the mapping of textures on the terrain surface;
key=	_layers\integer\\Index Layers\number of unique root shaders that will be use on the terrain;
key=	_shader\string\\Index Shader\Path to the metashader used to assign textures to the terrain entity. Note: Omit the "textures/" prefix;
key=	_offsets\string\\Index Offsets\Space separated list of height offsets for the index map;
*/

/*SS
form=	quaked;
lang=	english;
color=	0 0.5 0;
min=	-8 -8 -8;
max=	8 8 8;
class=	info_notnull;
name=	Info_NotNull;
desc=	Entity that does nothing, but may be targeted (e.g. to use its position);
*/

/*SS
form=	quaked;
lang=	english;
color=	0 0.5 0;
min=	-8 -8 -8;
max=	8 8 8;
class=	info_null;
name=	Info_Null;
desc=	Aiming target for q3map2-internal entities like _decal or light. Removes itself when loaded, so it can NOT be used for in-game stuff!;
*/

/*SS
form= quaked;
lang= english;
color=	0 1 0;
min= -64 -96 0;
max= 64 96 0;
class= info_player_start;
name= Player start;
desc= Normal player spawning location in game types without team spawns. Should touch the floor, but not the walls, and should point where the player should look when he spawns there.; 
model= models/player/player.ase;
key= angle\angle\0\Yaw angle\Horizontal (yaw) angle direction in which player will be oriented at spawn;
key= target\target\\Target\Trigger all entities with this targetname when someone spawns;
key= target\targetname\\Targetname\When targeted by a func_button, pressing the button will assign the spawn point to the team of the activator as an additional spawn point, or reassign it if it was already assigned. Also used to assign spawn points to Onslaught control points.;
*/

/*SS
form=	quaked;
lang=	english;
color=	0 1 1;
min=	-16 -16 -24;
max=	16 16 45;
class=	info_player_deathmatch;
name=	Player deathmatch start;
desc=	Normal player spawning location in game types without team spawns. Should touch the floor, but not the walls, and should point where the player should look when he spawns there.; 
model=	models/player/player.ase;
key=	cnt\real\1\Spawn Weight\Weight of spawn point for random selection. Set to a lower value if you have many spawn points close together.;
key=	target\target\\Target\Trigger all entities with this targetname when someone spawns;
key=	target\targetname\\Targetname\When targeted by a func_button, pressing the button will assign the spawn point to the team of the activator as an additional spawn point, or reassign it if it was already assigned. Also used to assign spawn points to Onslaught control points.;
*/

/*SS
form=	quaked;
lang=	english;
min=	-4 -4 -4;
max=	4 4 4;
class=	light;
name=	Light;
desc=	Non-displayed point light source. The -pointscale and -scale arguments to Q3Map2 affect the brightness of these lights. The -skyscale argument affects brightness of entity sun lights.
		Maximum intensity (in a radius 16 sphere around the light): regular lights have light/256, linear lights have light/8000-16*fade.
		Falloff radius to a negligible light amount: regular lights have light have 16*sqrt(light), linear lights have light/(fade*8000).
		By this you see that you HAVE to specify fade for a linear light... use values below 0.01 there.;
key=	light\integer\300\light level\Light level, affects radius and brightness of light;
key=	_color\color\1 1 1\light color\Weighted RGB value of light color;
key=	target\target\\spotlight target\Lights pointed at a target will be spotlights. Use info_null as targets;
key=	radius\real\64\spotlight radius\Overrides radius (in units) of a spotlight at the target point;
key=	_anglescale\real\\angle scale\Scales angle attenuation;
key=	fade\real\\fade factor\Fade factor of light attenuation of linear lights. Linear lights completely vanish at distance light/(fade*8000), so if you want the light to vanish at distance X, specify light/(8000*X) here.;
key=	_filterradius\real\\filter radius\filter radius for this light, similar to -light -filter;
key=	_sun\boolean\\infinite sun light\Set this key to Yes on a spotlight to make an infinite sun light;
key=	_deviance\integer\0\deviance radius\Non-point light simulation for softer shadows, this is radius of light sphere, a typical value is 4.;
key=	_samples\integer\1\deviance samples\How many "deviance" lights to spawn, good value is 6 or more.;flag1=1\LINEAR_FALLOFF\Linear falloff\Use a linear falloff. Default is inverse distance squared (more realistic);
flag=	1\LINEAR\Linear\Use a linear falloff. Default is inverse distance squared (more realistic).;
flag=	2\NO_ANGLE\No angle attenuation\Ignore angle attenuation.;
flag=	5\NO_GRID\No Grid\Lighting from this light does not appear in lightgrid.;
*/

/*SS
form=	quaked;
lang=	english;
color=	0.13 0.29 1;
min=	-8 -8 -8;
max=	8 8 8;
class=	particle_emitter;
name=	Particle Emitter;
desc=	A particle emitter for permanent placement; 
key=	particleemittereffect\string\\Effect\What effect will be displayed from either effectinfo.txt or mapname_effectinfo.txt.;
key=	angles\angles\0 0 0\Angles\Pitch-yaw-roll angles;
key=	permanent\boolean\\Permanent\Always present (cannot be removed during mission files clean up);
*/

/*SS
form=	quaked;
lang=	english;
class=	misc_model;
color=	0.4 0.4 0.8;
min=	-16 -16 -16;
max=	16 16 16;
name=	Static Model;
desc=	Q3Map2-only. Generic placeholder for inserting models in game. Requires compilation of map geometry to be added to level. Supported map formats are: MD3, ASE, 3DS, OBJ. It is recommended to use .ASE since it is better provided and tested;
key=	model\model\\Model path\a path to model. For example: models/map/box.ase;
key=	_frame\int\\Model Frame\Model frame;
key=	target\target\\Attach target\Use to attach the misc_model to a brush entity, where its "targetname" is the same value;
key=	angle\angle\0\Yaw angle\Horizontal (yaw) angle direction in which model will be oriented;
key=	angles\angles\0 0 0\Angles\Individual control of PITCH, YAW, and ROLL;
key=	modelscale\real\1\Uniform scale\Uniform scale of model, floating-point value used to scale a model up or down (default 1.0);
key=	modelscale_vec\angles\1 1 1\Dimension scale\Dimension scaling, floating-point vector used to scale a model axes individually (default 1.0 1.0 1.0);
key=	_remap\string\\Remap textures\Used to remap textures/shaders in the model. To remap all shaders to a given shader, use "*;models/mymodel/mytexture". To remap a specific shader, use "models/mymodel/old;models/mymodel/new";
key=	_castshadows\integer\\Cast Shadows\Allows per-entity control over shadow casting. Defaults to 0 on entities, 1 on world. 0 = no shadow casting. 1 = cast shadows on world. > 1 = cast shadows on entities with _rs (or _receiveshadows) with the corresponding value, AND world. Negative values imply same, but DO NOT cast shadows on world.;
key=	_receiveshadows\integer\\Receive Shadows\Allows per-entity control over shadow reception. Defaults to 1 on everything (world shadows). 0 = receives NO shadows. > 1 = receive shadows only from corresponding keyed entities (see above) and world. < 1 = receive shadows ONLY from corresponding keyed entities.;
flag=	2\SOLID\Solid\Make the model solid;
flag=	4\EXTRUDE_NORMALS\Extrude Normals\for converting triangles to clip brushes, extrude along the model normals (by default, extrusion happens in a coordinate axis direction that is decided per triangle);
flag=	5\EXTRUDE_TERRAIN\Extrude Terrain\always extrude downwards (for terrain);
flag=	6\COLOR_TO_ALPHA\Color to Alpha\use the color value as alpha (for terrain blending);
*/

/*SS
form= 	quaked;
lang= 	english;
class= 	misc_gamemodel;
color= 	0 0.5 0.8;
min= 	-8 -8 -8;
max= 	8 8 8;
name= 	Game Model;
desc= 	A way to load models from a map by the engine (e.g. self-animated zym models).
		Is non-solid by default.
		The keys below actually apply to most engine-loaded model entities as they are engine features,
		however, they are described here as they arent overridden by game code in misc_gamemodel.
		Its q3map2 keys below will work on any brush entity!;
		
key=	model\model\\Model path\a path to model. For example: models/map/box.ase;
key=	frame\int\\Model Frame\Animation frame to play (for self-animated zym models);
key=	skin\int\\Model Skin\Number of skin to load (when model is used);
key=	modelscale\real\1\Model scale\Uniform scale of model, floating-point value used to scale a model up or down (default 1.0);
key=	solid\list\\Solidity\One of engine solid type\0\NOT\1\TRIGGER\2\BBOX\3\SLIDEBOX\4\BSP\5\CORPSE;
key=	avelocity\angles\\Avelocity\vector giving its angular velocity (useful for spinning models);
key=	colormap\int\\Colormap\1024 + 16 * pantscolor + shirtcolor;
key=	angles\angles\0 0 0\Angles\Initial looking direction;
key=	effects\int\0\Effects\sum of 1 = BRIGHTFIELD, 4 = BRIGHTLIGHT, 8 = DIMLIGHT, 32 = ADDITIVE, 64 = BLUE, 128 = RED, 512 = FULLBRIGHT, 1024 = FLAME, 2048 = STARDUST, 4096 = NOSHADOW, 8192 = NODEPTHTEST, 32768 = DOUBLESIDED, 8388608 = NOMODELFLAGS (ignores the following coming from a model file), 16777216 = ROCKET, 33554432 = GRENADE, 67108864 = GIB, 134217728 = ROTATE, 268435456 = TRACER, 536870912 = ZOMGIB, 1073741824 = TRACER2, -2147483648 = TRACER3;
key=	loddistance1\int\1000\LOD Distance 1\Distance after which to show the first LOD model replacement;
key=	loddistance2\int\2000\LOD Distance 2\Distance after which to show the second LOD model replacement;
key=	lodmodel1\model\\LOD Model 1\First LOD model replacement;
key=	lodmodel2\model\\LOD Model 2\Second LOD model replacement;
key=	targetname\targetname\\Targetname\When invoking it by a button etc., it changes the color to the initiator of the action (e.g. the one pressing a button). In Onslaught, this can be used to color control points for team who owns them. In other game types, this can be used as a fun feature.;
key=	originjitter\angles\\Origin jitter\A vector describing a random offset this entity will be moved on initial spawn. This corresponds to the "origin" field. Works on any non-q3map2-only entity.;
key=	anglesjitter\angles\\Angles jitter\A vector in the order "pitch yaw roll" describing a random angles change on this entity on initial spawn. The value 180 180 180 makes the angles entirely random and uniformly distributed (among euler angles). This corresponds to the "angles" field. Works on any non-q3map2-only entity.;
key=	anglejitter\real\\Yaw jitter\A float describing a random yaw angle change on this entity on initial spawn. The value 180 makes the yaw angle entirely random (maybe good for items). This corresponds to the "angle" field. Works on any non-q3map2-only entity.;
key=	gametypefilter\real\\Gametype Filter\Either a + sign and a comma separated list of game types or the aliases "teams" and "noteams" to ONLY show the entity in the listed game types, or a - sign and a comma separated list of game types or the aliases "teams" and "noteams" to NOT show the entity in the listed game types. The syntax is the same as in sbar_columns_set strings. Works on any non-q3map2-only entity.;
key=	_frame\int\\Q3Map2 Frame\frame of model to include (set equal to frame if _castshadows is set);
key=	_castshadows\integer\\Q3Map2 Cast Shadows\Allows per-entity control over shadow casting. Defaults to 0 on entities, 1 on world. 0 = no shadow casting. 1 = cast shadows on world. > 1 = cast shadows on entities with _rs (or _receiveshadows) with the corresponding value, AND world. Negative values imply same, but DO NOT cast shadows on world.;
key=	_receiveshadows\integer\\Q3Map2 Receive Shadows\Allows per-entity control over shadow reception. Defaults to 1 on everything (world shadows). 0 = receives NO shadows. > 1 = receive shadows only from corresponding keyed entities (see above) and world. < 1 = receive shadows ONLY from corresponding keyed entities.;
flag=	1\ALIGN_ORIGN\Align Origin\Align the origin to the surface below the model;
flag=	2\ALIGN_BOTTOM\Align Bottom\Align the bottom of the model to the surface below it;
*/

/*SS
form=	quaked;
lang=	english;
class=	worldspawn;
name=	World entity;
desc=	If you see this, the currently selected brush is not of an entity.;
key=	message\string\\Map name\Text to print at user logon. Used for name of level. Ideally: "NAMEOFLEVEL by AUTHOR". Will get copied to the "title" and "author" entries of the mapinfo file when none is present.;
key=	author\string\\Map author\Name of the author of the map, if not specified in "message". Will get copied to the "author" entry of the mapinfo file when none is present.;
key=	_description\string\\Map description\One-line description of the map. Will get copied to the "description" entry of the mapinfo file when none is present.;
key=	fog\string\\Fog\fog parameters of the map (density red green blue alpha mindist maxdist); works just like the "fog" console command.;
key=	_blocksize\angles\\BSP Block Size\vector specifying the automatic vis subdivision block size (default: 1024 1024 1024).;
key=	gridsize\angles\\Lightgrid Size\Lightgrid granularity vector (default: 64 64 128).;
key=	_color\angles\\Light color\Color of the global light parameters;
key=	_ambient\real\\Ambient light\Light added to all surfaces;
key=	_mingridlight\real\\Min gridlight\Minimum grid light;
key=	_minlight\real\\Min light\Minimum light value on both surfaces and lightgrid;
key=	_keepLights\boolean\\Keep lights\Do not remove light entities from the map (useful e.g. for realtime lighting);
key=	_floodlight\string\\Flood light\Flood light parameters (red green blue distance intensity), start with 240 240 255 1024 128;
key=	_farplanedist\real\\Far plane dist\Range after which everything is completely invisible by fog (when fog is being used);
key=	_noshadersun\boolean\\No Sun Shader\Turn off sun defined by shaders (useful if you defined your own light entity to be a sun);
key=	_ignoreleaks\boolean\\Ignore leaks\Ignore leaks when compiling;
key=	_lightmapscale\boolean\\Lightmap Scale\light map resolution factor;
key=	_celshader\string\\Cel Shader\Sets the global cel shader used for world geometry (not entities). Note: omit the "textures/" prefix;
*/

/*SS
form=	quaked;
lang=	english;
class= _decal;
color= 0 1 0;
name=	AutoDecal;
desc= Q3Map2-only. compiler-only entity that specifies a decal to be projected. Should contain 1 or more patch meshes (curves) and target an info_null entity. The distance between the center of the _decal entity and the target is the axis and distance of projection;
key= target\target\\Target\The name of the entity targetted at for projection;
*/

void SetThink(entity ent, void() thnkfunc, float nxtthink)
{
	if (!ent)
		return;
	if (ent.movetype == MOVETYPE_PUSH || ent.solid == SOLID_BSP)
		nxtthink = ent.ltime + nxtthink;
	else
		nxtthink = time + nxtthink;
	ent.think = thnkfunc;
	ent.nextthink = nxtthink;
}

void Continue(void() thnkfunc, float nxtthink) =
{
	if (!extrathink)
		return;
	extrathink.movethink = thnkfunc;
	extrathink.nextthink = time + nxtthink;
}

void() ExtraThink =
{
	// run think
	extrathink = self;
	extrathink.nextthink = 0;
	if (self.goalentity)
	{
		self = self.goalentity;
		if (extrathink.movethink)
			extrathink.movethink();
	}
	if (extrathink.nextthink) // yet another think is set
		return;
	SH_RemoveEnt(extrathink);
}

entity SetExtraThink(entity ent, string thinkname, void() thnkfunc, float nxtthink)
{
	entity extra;

	extra = spawn();
	extra.classname = "extra_think";
	extra.goalentity = ent;
	extra.movethink = thnkfunc;
	extra.netname = thinkname;
	extra.think = ExtraThink;
	extra.nextthink = time + nxtthink;
	return extra;
}

entity CheckExtraThink(entity e, string thinkname)
{
	entity extra;
	
	extra = findchain(classname, "extra_think");
	while(extra)
	{
		if (extra.netname == thinkname)
			return extra;
		extra = extra.chain;
	}
	return world;
}

/*
======================================================================

 path_ stuff

======================================================================
*/

/*SS
form= quaked;
lang= english;
color= 0 0.5 0;
min= -8 -8 -8;
max= 8 8 8;
class= path_corner;
name= Path corner;
desc= Path points that trains should ride. While moving, train is rotating to angle of path_corner;
key= wait\real\0\Wait time\If set, path follower will wait this number of seconds before proceeding to next path corner;
key= target\target\\Target\Used to target this path point to others;
key= targetname\targetname\\Targetname\Used to target other path points to this;
model= models/editor/path_corner.md2;
*/

void() path_corner =
{
	setsize(self, '-4 -4 -4', '4 4 4');
}

/*SS
form= quaked;
lang= english;
color= 0 0.5 0;
min= -8 -8 -8;
max= 8 8 8;
class= path_rotate;
name= Path rotate;
desc= Like path_corner but rotation is handled differently. 
	  Train will not rotate while moving to this path corner but will do it while waiting (or instantly switch to angles if wait is -1);
key= wait\real\0\Wait time\If set, path follower will wait this number of seconds before proceeding to next path corner;
key= target\target\\Target\Used to target this path point to others;
key= targetname\targetname\\Targetname\Used to target other path points to this;
model= models/editor/path_corner.md2;
*/

void() path_rotate =
{
	setsize(self, '-4 -4 -4', '4 4 4');
}

/*
======================================================================

 train_move_ routines

 calculate movement to reach destinatino position

======================================================================
*/

void() train_move_done =
{
	setorigin(self, self.movedest);
	self.angles = self.moveang;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.think = world.think;
	self.nextthink = 0;
	self.SendFlags = self.SendFlags | 1;
	// reach corner
	if (self.movethink)
		self.movethink();
}

void train_rotate_to(vector destang, float traveltime)
{
	self.avelocity = (destang - self.angles)*(1/traveltime);
	self.SendFlags = self.SendFlags | 1;
}

void train_move_to(vector destpos, vector destang, float mspeed, void() reachfunc)
{
	vector delta;
	float traveltime;
	
	self.avelocity = '0 0 0';
	if (!mspeed)
	{
		setorigin(self, destpos);
		self.angles = destang;
		self.SendFlags = self.SendFlags | 1;
		if (reachfunc)
			reachfunc();
		return;
	}
	self.movethink = reachfunc;
	self.movedest = destpos;
	self.moveang = destang;
	// set destdelta to the vector needed to move
	delta = destpos - self.origin;
	// divide by speed to get time to reach dest
	traveltime = vlen(delta)/mspeed;
	if (traveltime < 0.1)
	{
		setorigin(self, destpos);
		self.angles = destang;
		self.SendFlags = self.SendFlags | 1;
		if (reachfunc)
			reachfunc();
		return;
	}
	// set nextthink to trigger a think when dest is reached
	self.think = train_move_done;
	if (self.movetype == MOVETYPE_PUSH)
		self.nextthink = self.ltime + traveltime;
	else
		self.nextthink = time + traveltime;
	// scale the destdelta vector by the time spent traveling to get velocity
	self.velocity = delta*(1/traveltime); // qcc won't take vec/float
	self.SendFlags = self.SendFlags | 1;
	// set avelocity
	train_rotate_to(self.moveang, traveltime);
};

/*
======================================================================

 func_train
 
======================================================================
*/

/*SS 
form= quaked;
lang= english;
color= 0.3 0.3 0.3;
class= func_train;
name= Train;
desc= Trains are moving platforms that players can ride. 
Trains must have "origin" brush inside it to know what point to use for corners placement. Otherwise XYZ min corner will be used. 

Use "path_" entities for train movement spots, when train will reach them, it will wait path_corner's "wait" seconds (-1 to wait forever), and then change it's targets to path_corner's ones and continue move. Also "speed" of movement could be set to override train default speed, it's determined from target path_corner when train move starts.

Train spawns at the first target it is pointing at (or saves it's position if no target is set), if "wait" is set, train will travel to it's starting target with "wait" seconds delay. Value of -1 means forever delay.

If train is the target of a button or trigger, it will not begin moving until activated.

key= speed\integer\20\Move speed\Train move speed in game units per second;
key= dmg\integer\0\Damage\Amount damage train is blocked (or touched if SPAWNFLAG_SPIKE) by someone;		
key= wait\integer\0\Start delay\Delay in seconds before start move;		
key= noise\sound\\Start sound\Sound played at the start of move;	
key= noise1\sound\\Move sound\Movement sound, starts with start sound (on second channel), should have loopmark to be looped;
key= noise2\sound\\End sound\Sound played at the end of move;
key= noise3\sound\\Retrain sound\Sound played when train reach corner by didnt stop (proceeded to next corner);

flag=1\AUTOSTOP\AUTOSTOP\Causes train to stop on each corner it reachs;
flag=2\HURT\HURT\Causes train to damage player if touches it, defaults damage to 5;
*/

void() TrainStopSound =
{
	// stop sounds
	if (self.state != TRAIN_STATE_STOPPED)
	{	
		if (self.noise2 != "")
			sound(self, 1, self.noise2, 1, ATTN_NORM);
		else if (self.noise != "")
			sound(self, 1, "", 0, ATTN_NORM);
	}
	if (self.noise1 != "")
		sound(self, 2, "sounds/null.wav", 1, ATTN_NORM);
}

// stop the train
void() TrainStop =
{
	TrainStopSound();
	self.state = TRAIN_STATE_STOPPED;
	self.velocity = '0 0 0';
	self.avelocity = '0 0 0';
	self.think = world.think;
	self.nextthink = 0;
	self.SendFlags = self.SendFlags | 1;
}

void() TrainGoMove =
{
	if (self.goalentity.state == TRAIN_STATE_MOVING)
		sound(self.goalentity, 2, self.goalentity.noise2, 1, ATTN_NORM);
	SH_RemoveEnt(self);
}

// move train
void() TrainGo =
{
	entity e;
	
	if (self.state != TRAIN_STATE_MOVING)
	{
		if (self.noise != "")
			sound(self, 1, self.noise, 1, ATTN_NORM);
		if (self.noise1 != "")	
			sound(self, 2, self.noise1, 1, ATTN_NORM);
	}
	else // retrain
	{
		if (self.noise3 != "")
			sound(self, 1, self.noise3, 1, ATTN_NORM);
	}
	self.state = TRAIN_STATE_MOVING;
	train_move_to(self.movedir, self.moveang, self.cnt, train_reach_corner);
}

// set a target
float TrainTarget(string t)
{
	self.goalentity = FindTargets(self, t, "path_");
	if (!self.goalentity)
	{
		print("TrainTarget: failed to find target '", t, "'\n");
		return 0;
	}
	return 1;
}

// change to target's target
float() TrainNextTarget =
{
	if (!self.goalentity)
	{
		print("TrainNextTarget: no current target!\n");
		return 0;
	}
	return TrainTarget(self.goalentity.target);
}

// set a custom destination point
void TrainDestPos(entity ent, vector org, vector ang, float mspeed) =
{
	self.goalentity = ent;
	self.movedir = org;
	self.moveang = ang;
	if (mspeed)
		self.cnt = mspeed;
	else
		self.cnt = self.speed;
}

// set a entity destination point
void TrainDest(entity ent) =
{
	if (ent.classname == "path_rotate")
	{
		TrainDestPos(ent, ent.origin, self.angles, ent.speed);
		return;
	}
	TrainDestPos(ent, ent.origin, ent.angles, ent.speed);
}

// 1 damage per 0.5 econds
#define TRAIN_BLOCKED_DAMAGE_TIME		0.25
#define TRAIN_BLOCKED_DAMAGE_MINDELAY	0.05
void() train_blocked =
{
	if (time < self.lip)
		return;
	Damage(self, other, world, self.dmg);
	self.lip = time + max(TRAIN_BLOCKED_DAMAGE_MINDELAY, TRAIN_BLOCKED_DAMAGE_TIME / self.dmg);
}

void() train_damage_restoresolid =
{
	self.solid = SOLID_BSP;
	force_retouch = 2;
}

void() train_damage_restorevelocity =
{
	self.velocity = self.pos2;
	Continue(train_damage_restoresolid, 0.1);
}

void() train_damage_touch =
{
	vector knockvec;
	
	if (time < self.lip)
		return;
	if (other.class != CLASS_PLAYER)
		return;
		
	self.pos2 = self.velocity;
	self.solid = SOLID_NOT;
	knockvec = (self.absmin + self.absmax)*0.5 - other.origin;
	//if (self.dmg > 0) // fixme: hack
	//	damage(other, self, world, DT_SPIKES, self.dmg, self.origin, other.velocity);
	//Knockback(other, knockvec, 180);	
	self.lip = time + 0.5;
	SetExtraThink(self, "restorevelocity", train_damage_restorevelocity, 0.01);
}

void() train_resume =
{
	self.avelocity = '0 0 0';
	TrainGo();
}

void() train_reach_corner =
{
	entity reachent;
	
	if (!self.goalentity || self.goalentity.target == "")
		return;
	reachent = self.goalentity;
	TrainNextTarget();
	TrainDest(self.goalentity);
	if (reachent.wait < 0 || (self.spawnflags & SPAWNFLAG_TRAIN_AUTOSTOP))
	{
		TrainStop();
		return;
	}
	if (reachent.wait)
	{
		self.state = TRAIN_STATE_PAUSED;
		if (reachent.classname == "path_rotate")
		{
			self.state = TRAIN_STATE_MOVING;
			train_rotate_to(reachent.angles, reachent.wait);
		}
		else
		{
			TrainStopSound();
		}
		SetThink(self, train_resume, reachent.wait);
		return;
	}
	if (reachent.classname == "path_rotate")
		self.angles = reachent.angles;
	TrainGo();
}

/*
void train_attachzones(vector ofs) =
{
	entity z;
	
	// attach zones
	z = FindTargeted(self, self.targetname, "zone_");
	while(z)
	{
		if (ofs != '0 0 0')
			setorigin(z, z.origin + ofs);
		SetFollow(z, self);
		z = z.chain;
	}
}
*/

void() train_start =
{
	//train_attachzones('0 0 0');
	// start
	if (self.wait && !self.startstateoff)// && self.targetname == "")
	{
		self.state = TRAIN_STATE_PAUSED;
		TrainTarget(self.target);
		TrainDest(self.goalentity);
		if (self.wait > 0)
			SetThink(self, TrainGo, self.wait);
		return;
	}
	TrainTarget(self.target);
	train_move_to(self.goalentity.origin, self.angles, 0, world.think);
	TrainNextTarget();
	TrainDest(self.goalentity);
//	if (self.targetname == "")
	if(!self.startstateoff)
		TrainGo();
}

void TriggerTrain() =
{
	self.istoggled = TRUE;
	
	if(!self.target)
		return;
	
	if (self.state != TRAIN_STATE_MOVING)
		TrainGo();
	else
		TrainStop();
}

void func_train_initialize() =
{
	InitBmodel();
	
//	if(!self.modelindex) // bogus train from .bsp
//	{
//		remove(self);
//		return;
//	}
	
	self.originalmodelindex = self.modelindex;	
	
	self.permanent = FALSE;
	SetOwner(self, self);

	//self.noise = "sounds/equipment/ss_lift1_start.wav";
	//self.noise1 = "sounds/equipment/ss_lift1_move.wav";
	//self.noise2 = "sounds/equipment/ss_lift1_stop.wav";
	//self.noise3 = "sounds/equipment/ss_lift1_stop.wav";
	
	if (self.noise != "")
		precache_sound(self.noise);
	if (self.noise1 != "")
		precache_sound(self.noise1);	
	if (self.noise2 != "")
		precache_sound(self.noise2);
	if (self.noise3 != "")
		precache_sound(self.noise3);
		
	self.pos1 = self.origin;
	//self.use = train_call;
	self.TriggerFunc = TriggerTrain;
	self.blocked = train_blocked;
	self.movetype = MOVETYPE_PUSH;
	if (!self.speed)
		self.speed = 300;
	if (!self.dmg)
		self.dmg = 2;
	if (self.origin != '0 0 0') 
		self.spawnflags = self.spawnflags | SPAWNFLAG_TRAIN_ORIGIN;
	if (self.spawnflags & SPAWNFLAG_TRAIN_DAMAGE)
	{
		if (!self.dmg)
			self.dmg = 5;
		self.touch = train_damage_touch;
		self.movetype = MOVETYPE_FLY;
	}
	// starting state
	if (self.target == "")
	{
		self.state = TRAIN_STATE_IDLE;
		return;
	}
	self.state = TRAIN_STATE_STOPPED;
	
	if(self.isdeletedformission || (self.multiplayeronly && singleplayer))
	{
		self.onlydrawforadmins = TRUE;
		self.movetype = MOVETYPE_NONE;
		self.solid = SOLID_NOT;
		MakeObjectInvisibleToClients(self);
		return;
	}
	
	SetThink(self, train_start, 0.2);
}

/*SS
form= quaked;
lang= english;
color= 0.3 0.3 0.6;
class= func_wall;
name= Wall;
desc= Just a solid wall;	
key= targetname\string\\Targetname\Use to target other triggers to this;
key= avelocity\angles\\Avelocity\Constant angle rotation;
*/

void func_train() =
{	
	if(self.model && self.model != "null")
	{
		CustomizeTrain(self);
		func_train_initialize();
	}
	else
		remove(self);
}

void() func_wall =
{	
	self.target = "";
	self.classname = "func_train"; // InitializeTrains() using this
	func_train();
}