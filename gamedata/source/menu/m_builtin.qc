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
//////////////////////////////////////////////////
// common cmd
//////////////////////////////////////////////////
// AK FIXME: Create perhaps a special builtin file for the common cmds

//#define PROFILESTRZONE
//#define FIXEDFOPEN

void 	checkextension(string ext) = #1;

// error cmds
void 	error(string err,...) 	= #2;
void 	objerror(string err,...) 	= #3;

// print

void 	print(string text,...) 	= #4;
void 	bprint(string text,...)	= #5;
void	sprint(float clientnum, string text,...) = #6;
void 	centerprint(string text,...) = #7;

// vector stuff

vector	normalize(vector v) 	= #8;
float 	vlen(vector v)			= #9;
float  	vectoyaw(vector v)		= #10;
vector 	vectoangles(vector v)	= #11;

float	random(void)  = #12;

void	cmd(string command, ...) = #13;

// cvar cmds

float 	cvar(string name) = #14;
const string cvar_string(string name) = #71;
const string cvar_defstring(string name) = #89;
void	cvar_set(string name, string value) = #15;

//void	dprint(string text,...) = #16;

// conversion functions

string	ftos(float f)  = #17;
float	fabs(float f)	= #18;
string	vtos(vector v)  = #19;
string	etos(entity e) = #20;

float	stof(string val,...)  = #21;

entity	spawn(void) = #22;
void	remove(entity e) = #23;

entity	findstring(entity start, .string _field, string match)  = #24;
entity	findfloat(entity start, .float _field, float match) = #25;
entity	findentity(entity start, .entity _field, entity match) = #25;

entity	findchainstring(.string _field, string match) = #26;
entity	findchainfloat(.float _field, float match) = #27;
entity	findchainentity(.entity _field, entity match) = #27;

entity	findflags(entity start, .float field, float match) = #87;
entity	findchainflags(.float field, float match) = #88;

string	precache_file(string file) = #28;
string	precache_sound(string sample) = #29;

void	crash(void)	= #72;
void	coredump(void) = #30;
void	stackdump(void) = #73;
void	traceon(void) = #31;
void	traceoff(void) = #32;

void	eprint(entity e)  = #33;
float	rint(float f) = #34;
float	floor(float f)  = #35;
float	ceil(float f)  = #36;
entity	nextent(entity e)  = #37;
float	sin(float f)  = #38;
float	cos(float f)  = #39;
float	sqrt(float f)  = #40;
vector	randomvec(void)  = #41;

float	registercvar(string name, string value, float flags)  = #42; // returns 1 if success
float	min(float f,...)  = #43;
float	max(float f,...)  = #44;
float	bound(float min,float value, float max)  = #45;
float	pow(float a, float b)  = #46;
void	copyentity(entity src, entity dst)  = #47;

#ifdef FIXEDFOPEN
float 	_fopen( string filename, float mode ) = #48;
#else
float	fopen(string filename, float mode)  = #48;
#endif
void	fclose(float fhandle)  = #49;
string	fgets(float fhandle)  = #50;
void	fputs(float fhandle, string s)  = #51;

float	strlen(string s)  = #52;
//string	strcat(string s1,string s2,...)  = #53;
string	strcat(string s1, ...)  = #53;
string	substring(string s, float start, float length)  = #54;

vector	stov(string s)  = #55;

#ifdef PROFILESTRZONE
string	_strzone(string s)  = #56;
void	_strunzone(string s) = #57;

string( string s ) strzone =
{
	return _strzone( s );
};

void( string s ) strunzone =
{
	return _strunzone( s );
};
#else
string	strzone(string s)  = #56;
void	strunzone(string s) = #57;
#endif

float	tokenize(string s) = #58;
float(string s, string separator1, ...) tokenizebyseparator = #479;
string	argv(float n)  = #59;

float	isserver(void)  = #60;
float	clientcount(void)  = #61;
float	clientstate(void)  = #62;
void	clientcommand(float client, string s)  = #63;
void	changelevel(string map)  = #64;
void	localsound(string sample)  = #65;
vector	getmousepos(void)  	= #66;
float	gettime(void)		= #67;
void 	loadfromdata(string data) = #68;
void	loadfromfile(string file) = #69;

float	mod(float val, float m) = #70;

float	search_begin(string pattern, float caseinsensitive, float quiet) = #74;
void	search_end(float handle) = #75;
float	search_getsize(float handle) = #76;
string	search_getfilename(float handle, float num) = #77;

string	chr(float ascii) = #78;

float 	etof(entity ent) = #79;
entity 	ftoe(float num)	 = #80;

float   validstring(string str) = #81;

float 	altstr_count(string str) = #82;
string  altstr_prepare(string str) = #83;
string  altstr_get(string str, float num) = #84;
string  altstr_set(string str, float num, string set) = #85;
string 	altstr_ins(string str, float num, string set) = #86;

/////////////////////////////////////////////////
// Write* Functions
/////////////////////////////////////////////////
void	WriteByte(float data, float dest, float desto)	= #401;
void	WriteChar(float data, float dest, float desto)	= #402;
void	WriteShort(float data, float dest, float desto)	= #403;
void	WriteLong(float data, float dest, float desto)	= #404;
void	WriteAngle(float data, float dest, float desto)	= #405;
void	WriteCoord(float data, float dest, float desto)	= #406;
void	WriteString(string data, float dest, float desto)= #407;
void	WriteEntity(entity data, float dest, float desto) = #408;

//////////////////////////////////////////////////
// Draw funtions
//////////////////////////////////////////////////

float	iscachedpic(string name)	= #451;
string	precache_pic(string name)	= #452;
void	freepic(string name)		= #453;

float	drawcharacter(vector position, float character, vector scale, vector rgb, float alpha, float flag) = #454;

float	drawstring(vector position, string text, vector scale, vector rgb, float alpha, float flag) = #455;
float   drawcolorcodedstring(vector position, string text, vector scale, float alpha, float flag) = #467;
float	stringwidth(string text, float handleColors, vector size) = #468;

float	drawpic(vector position, string pic, vector size, vector rgb, float alpha, float flag) = #456;
float	drawsubpic(vector position, vector size, string pic, vector srcPosition, vector srcSize, vector rgb, float alpha, float flag) = #469;

float	drawfill(vector position, vector size, vector rgb, float alpha, float flag) = #457;

void	drawsetcliparea(float x, float y, float width, float height) = #458;

void	drawresetcliparea(void) = #459;

vector  drawgetimagesize(string pic) = #460;

float	cin_open(string file, string name) 	= #461;
void	cin_close(string name) 			= #462;
void	cin_setstate(string name, float type) 	= #463;
float	cin_getstate(string name)		= #464;

////////////////////////////////////////////////
// Menu functions
////////////////////////////////////////////////

void	setkeydest(float dest) 	= #601;
float	getkeydest(void)	= #602;

void	setmousetarget(float trg) = #603;
float	getmousetarget(void)	  = #604;

float	isfunction(string function_name) = #607;
void	callfunction(...) = #605;
void	writetofile(float fhandle, entity ent) = #606;
vector	getresolution(float number) = #608;
string	keynumtostring(float keynum) = #609;
//string	findkeysforcommand(string command, float bindmap) = #610;

float	gethostcachevalue(float type) = #611;
string	gethostcachestring(float type, float hostnr) = #612;

void 	parseentitydata(entity ent, string data) = #613;

//float	stringtokeynum(string key) = #614;

void 	resethostcachemasks(void) = #615;
void 	sethostcachemaskstring(float mask, float fld, string str, float op) = #616;
void	sethostcachemasknumber(float mask, float fld, float num, float op) = #617;
void 	resorthostcache(void) = #618;
void	sethostcachesort(float fld, float descending) = #619;
void	refreshhostcache(void) = #620;
float	gethostcachenumber(float fld, float hostnr) = #621;
float	gethostcacheindexforkey(string key) = #622;
void	addwantedhostcachekey(string key) = #623;
string	getextresponse(void) = #624;

// AK the builtin numbers may change - the code might be removed again
float gecko_create( string name ) = #487;
void gecko_destroy( string name ) = #488;
void gecko_navigate( string name, string URI ) = #489;
float gecko_keyevent( string name, float key, float eventtype ) = #490;
void gecko_mousemove( string name, float x, float y ) = #491;
void gecko_resize( string name, float w, float h ) = #492;
vector gecko_get_texture_extent( string name ) = #493;

//FTE_STRINGS
//idea: many
//darkplaces implementation: KrimZon
//description:
//various string manipulation functions
float(string str, string sub, float startpos) strstrofs = #221;
float(string str, float ofs) str2chr = #222;
string(float c, ...) chr2str = #223;
string(float ccase, float calpha, float cnum, string s, ...) strconv = #224;
string(float chars, string s, ...) strpad = #225;
string(string info, string key, string value, ...) infoadd = #226;
string(string info, string key) infoget = #227;
float(string s1, string s2, float len) strncmp = #228;
float(string s1, string s2) strcasecmp = #229;
float(string s1, string s2, float len) strncasecmp = #230;

//DP_QC_STRINGBUFFERS
//idea: ??
//darkplaces implementation: LordHavoc
//functions to manage string buffer objects - that is, arbitrary length string arrays that are handled by the engine
float() buf_create = #440;
void(float bufhandle) buf_del = #441;
float(float bufhandle) buf_getsize = #442;
void(float bufhandle_from, float bufhandle_to) buf_copy = #443;
void(float bufhandle, float sortpower, float backward) buf_sort = #444;
string(float bufhandle, string glue) buf_implode = #445;
string(float bufhandle, float string_index) bufstr_get = #446;
void(float bufhandle, float string_index, string str) bufstr_set = #447;
float(float bufhandle, string str, float order) bufstr_add = #448;
void(float bufhandle, float string_index) bufstr_free = #449;

//DP_QC_CRC16
//idea: div0
//darkplaces implementation: div0
//Some hash function to build hash tables with. This has to be be the CRC-16-CCITT that is also required for the QuakeWorld download protocol.
//When caseinsensitive is set, the CRC is calculated of the lower cased string.
float(float caseinsensitive, string s, ...) crc16 = #494;

#ifdef FIXEDFOPEN
float 	fopen( string filename, float mode ) =
{
	local float handle;
	if( mode == FILE_READ ) {
		return _fopen( filename, mode );
	}

	// check for data/
	filename = strzone( filename );
	if( substring( filename, 0, 5 ) != "data/" ) {
		print( "menu: fopen: all output must go into data/!\n" );
		return -1;
	}
	handle = _fopen( substring( filename, 5, 10000 ), mode );
	strunzone( filename );
	return handle;
};
#endif

void(entity client, string s)stuffcmd = #21;
void(string s) localcmd = #13;

string (float key, float bindmap)							getkeybind = #342;
float ()								isdemo = #349;

//DP_CSQC_BINDMAPS
//idea: daemon, motorsep
//darkplaces implementation: divVerent
//builtin definitions:
string(float key, float bindmap) getkeybind_bindmap = #342;
float(float key, string bind, float bindmap) setkeybind_bindmap = #630;
vector() getbindmaps = #631;
void(vector bm) setbindmaps = #632;
string(string command, float bindmap) findkeysforcommand = #610;
float(string key) stringtokeynum = #341;
//<also allowed builtin number to match EXT_CSQC> string(float keynum) keynumtostring = #340;
//description: key bind setting/getting including support for switchable
//bindmaps.

float() videoplaying = #355;