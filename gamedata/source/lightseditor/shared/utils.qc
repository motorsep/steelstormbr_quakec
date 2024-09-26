////////////////////////////////////////
// Blood Omnicide source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

#ifndef __MATH__
#define __MATH__ 1

/*
=================
 constants
=================
*/

#define	null_string	""
entity null_entity;
void() null_function = {};
float() truef { return 1; }
float() falsef { return 0; }
vector null_vector = '0 0 0';

var void() varvoid;
var float() varfloat;
var vector() varvector;
var string() varstr;

#define false		0
#define true		1
#define FALSE		0
#define DEFAULT		0
#define TRUE		1
#define POSITIVE	1
#define NEGATIVE	-1
#define MATH_PI		3.14159265
#define MATH_RAD	57.2957796
#define INFINITE	1000000000.0

#define V_ONE		'1 1 1'
#define V_FORWARD   '1 0 0'
#define V_RIGHT		'0 1 0'
#define V_UP		'0 0 1'
#define V_BACK		'-1 0 0'
#define V_LEFT		'0 -1 0'
#define V_DOWN		'0 0 -1'

/*
=================
 math
=================
*/

#define deg2rad(a)	(a/MATH_RAD)
#define rad2deg(a)	(a*MATH_RAD)
#define tg(a)	sin(a)/cos(a)
#define ctg(a)	cos(a)/sin(a)
#define NaN(s)	ftos(stof(s))!=s
#define in(v,min,max)	((v >= min) && (v <= max))
#define lerp(mn,lerrp,mx)	mn+((mx)-(mn))*lerrp

// get natural frac from decimal one, like 0.5 will return 1/2
string natural(float num, float base)
{
	float n, n2, m, d;
	
	// divide to get less numbers
	if (num > base) m = base/2; else m = num/2;
	if (m > 100) m = 100;
	while(1)
	{
		for (d = 2; d < m; d++) { n = num/d; n2 = base/d; if (floor(n) == n && floor(n2) == n2) break; }
		if (d >= m) break;
		num = num / d;
		base = base / d;
	}
	return strcat(ftos(num), "/", ftos(base));
}

float round(float num, float dec) { return rint(num/dec)*dec; } 
float hlen(vector v) { v_z = 0; return vlen(v); };
// crossproduct of 2 vectors
vector crossproduct(vector a, vector b) = { vector c; c_x = (a_y * b_z) - (a_z * b_y); c_y = (a_z * b_x) - (a_x * b_z); c_z = (a_x * b_y) - (a_y * b_x); return c; }
// scale vector by another vector
vector vectorscale(vector v, vector scale_map) = { v_x = v_x*scale_map_x; v_y = v_y*scale_map_y; v_z = v_z*scale_map_z; return v; }
// scale vector by uniform using vector scale map
vector vectorscalemap(vector v, vector scale_map, float scale_mod) = { scale_map = normalize(scale_map); if (scale_map_x) v_x = v_x*scale_map_x*scale_mod; if (scale_map_y) v_y = v_y*scale_map_y*scale_mod; if (scale_map_z) v_z = v_z*scale_map_z*scale_mod; return v; }
// mirror reflection against normal, used for bouncing
vector reflect(vector v, vector normal) = { float dot, l; vector o; l = vlen(v); v = normalize(v); normal = normalize(normal); dot = v*normal; o_x = v_x-2 * dot*normal_x; o_y = v_y-2 * dot*normal_y; o_z = v_z-2 * dot*normal_z; return o*l; }
// build vector base on three floats :)
vector vec3(float x, float y, float z) = { vector v; v_x = x; v_y = y; v_z = z; return v; }
// build vector based on 2 floats :)
vector vec2(float x, float y) = { vector v; v_x = x; v_y = y; v_z = 0; return v; }
// build vector based on 1 float :)
vector vec1(float x) = { vector v; v_x = x; v_y = 0; v_z = 0; return v; }
// build vector with x,y,z = float
vector vec(float x) = { vector v; v_x = x; v_y = x; v_z = x; return v; }
// vector with func on all axises
vector vfunc(vector v, float(float x) f) = { v_x = f(v_x); v_y = f(v_y); v_z = f(v_z); return v; }

/*
===================
 angle stuff
===================
*/

void makevectors(vector a);
vector vectoangles(vector v, ...);
// normalize angle for 0-360space
float anglemod(float v) = { while(v >= 360) v -= 360; while(v < 0) v += 360; return v; }
// normalize angle for -90-90 space
float pitchmod(float v) = { while(v >= 360) v -= 360; while(v < 0) v += 360; v = 180 - v; if (v > 90) v = 180 - v; if (v < -90) v = -180 - v; return v; }
// substracts one angle from another
float anglecomp(float y1, float y2) = { float a; a = y1 - y2; while (a > 180) a = a - 360; while (a < -180) a = a + 360; return a; }
// anglecomp for vector
vector anglecomp3(vector v1, vector v2) = { vector a; a_x = v1_x -  v2_x; while (a_x > 180) a_x = a_x - 360; while (a_x < -180) a_x = a_x + 360; a_y = v1_y -  v2_y; while (a_y > 180) a_y = a_y - 360; while (a_y < -180) a_y = a_y + 360; a_z = v1_z -  v2_z; while (a_z > 180) a_z = a_z - 360; while (a_z < -180) a_z = a_z + 360; return a; }
// substracts one angle from another, returns absolute value
float absanglecomp(float y1, float y2) = { return fabs(anglecomp(y1, y2)); }
// absolute anglecomp for vector
vector absanglecomp3(vector v1, vector v2)
{
	vector a;
	
	a_x = v1_x -  v2_x; while (a_x > 180) a_x = a_x - 360; while (a_x < -180) a_x = a_x + 360;
	a_x = fabs(a_x); a_y = v1_y -  v2_y; while (a_y > 180) a_y = a_y - 360; while (a_y < -180) a_y = a_y + 360;
	a_y = fabs(a_y); a_z = v1_z -  v2_z; while (a_z > 180) a_z = a_z - 360; while (a_z < -180) a_z = a_z + 360;
	a_z = fabs(a_z);
	return a;
}
// check if angles is in some interval
float facing_ideal(float a, float b, float deviat) = { if (fabs(anglecomp(a, b)) > deviat) return 0; return 1; }
// vector to pitch
float vectopitch(vector v) = { v = vectoangles(v); return pitchmod(v_x); }
// convert vector to client-like angles
vector vectoclientangles(vector v) = { v = vectoangles(v); if (v_x <= 90) v_x = 0-v_x; else v_x = 360-v_x; if (v_y > 180) v_y = 0 - (360 - v_y); return v; };
// get a client-like pitch from vector
float vectoclientpitch(vector v) = { v = vectoangles(v); if (v_x <= 90) v_x = 0-v_x; else v_x = 360-v_x; return v_x; }
// get a client-like yaw from vector
float vectoclientyaw(vector v) = { v = vectoangles(v); if (v_y > 180) v_y = 0 - (360 - v_y); return v_y; }
// vectorvectors that is always right
void vectovectors2(vector v) = { v = vectoclientangles(v); makevectors(v); }

/*
===================
 interpolation 
===================
*/

float interpolate(float a, float b, float s)
{
	float temp, f1, f2;

	f1 = b - a;
	temp = a + f1*s;
	f2 = b - temp;
	if (f1*f2 < 0) // reached
		return b;
	return temp;
}

vector interpolatevec(vector a, vector b, vector s)
{
	vector temp, v1, v2;

	v1 = normalize(b - a); // initial movedir
	temp_x = a_x + v1_x*s_x; 
	temp_y = a_y + v1_y*s_y;
	temp_z = a_z + v1_z*s_z;
	v2 = normalize(b - temp);
	if (v1*v2 < 0) // reached
		return b;
	return temp;
}

float rotation(float a, float b, float s)
{
	float swing, swingabs;

	if (a == b)
		return b;

	swing = anglecomp(b, a);
	if (swing < 0)
		s = s*-1;
	swingabs = fabs(swing);
	// modify aSpeed based on angles difference to give non-linear feel
	if (swingabs < 5)
		s *= 2;
	else if (swingabs < 13) 
		s *= 5;
	else if (swingabs < 25)
		s *= 10;
	else
		s *= 20;
	swingabs = a + s;
	if ((swing*anglecomp(b, swingabs)) < 0)
		swingabs = b; // reached
	return swingabs;
};

float pitchlerp(float cur, float ideal, float _spd)
{
	float m;
	
	if (cur == ideal)
		return cur;
	_spd = _spd*frametime*10;
	m = ideal - cur;
	if (ideal > cur)
	{
		if (m >= 180)
			m = m - 360;
	}
	else if (m <= -180)
		m = m + 360;
	if (m > 0)
	{
		if (m > _spd)
			m = _spd;
	}
	else if (m < -_spd)
		m = -_spd;
	return cur + m;
}

// rotate angles vector to destination one with given axis speeds
vector rotationangles(vector a, vector b, vector s) = { if (s_x) a_x = rotation(a_x, b_x, s_x); if (s_y) a_y = rotation(a_y, b_y, s_y); if (s_z) a_z = rotation(a_z, b_z, s_z); return a; }

/*
===================
 random
===================
*/

// c-style random (-1 - 1)
float crandom() {return 2*(random()-0.5);}

// returns int from this range
float lhrandomint(float x, float y) {return rint(x + random()*(y - x));}

// returns float from this range
float lhrandom(float x, float y) {return x + random()*(y - x);}

// displaced random
#define RANDOM_NORMAL	0
#define RANDOM_UPPER	1	// 1.5 power disp, upper values have greater spawning ability
#define RANDOM_LOWER	2	// sqrt disp, lower values have greater spawning ability
float drandom(float d) 
{
	float r;

	r = random();
	if (d == RANDOM_LOWER) return pow(r, 1.5);
	if (d == RANDOM_UPPER) return sqrt(r);
	return r;
}

// returns random entity from all matching search_field string field
entity erandom(.string search_field, string match_field)
{
	entity targ;
	float targets_num, target_want;
		
	// find count of matching targets
	for(targ = find(world, search_field, match_field); targ; targets_num = targets_num + 1)
		targ = find(targ, search_field, match_field);
	// take random from range of targets_num
	target_want = lhrandomint(1, targets_num);
	// return it
	for(targ = find(world, search_field, match_field); target_want > 1; target_want = target_want - 1)
		targ = find(targ, search_field, match_field);
	return targ;
}

// return random argv from token string
string srandom(string s)
{
	local float len, rand;
	len = tokenize(s);
	rand = lhrandomint(0, len - 1);
	return argv(rand);
}

// returns random origin from bbox
vector brandom(vector m1, vector m2)
{
	local vector v;
	v_x = lhrandom(m1_x, m2_x);
	v_y = lhrandom(m1_y, m2_y);
	v_z = lhrandom(m1_z, m2_z);
	return v;
}

// returns random vector
vector randomvec();

// returns random vector
vector randomvec2d()
{
	local vector v;

	v = randomvec();
	v_z = 0;
	return normalize(v);
}

// returns random direction
vector() randomdir = 
{
	return normalize(randomvec());
}

// returns cylindrical spread of dir vector, by given spread radius and spread attenuation (vr, vu)
vector cylindric_spread(vector vf, vector vr, vector vu, vector spreadpower) 
{
	float r, len;
	vector dir, spreads;

	// get random angle
	r = lhrandom(0-MATH_PI, MATH_PI); 
	// get base spread vector
	dir_x = spreadpower_x*cos(r);
	dir_y = spreadpower_y*sin(r);
	// get max vector lenght for that angle
	len = sqrt(dir_x*dir_x + dir_y*dir_y);
	// scale vector by random lenght
	dir = normalize(dir)*lhrandom(0, len);
	// apply initial rotation matrix
	spreads = vf + vf*spreadpower_x*random() + vr*dir_x + vu*dir_y;
	return spreads;
}

/*
=============
 metric
=============
*/

#define POINTS_PER_METER 64 // a 64 points is approx 1 meter in quake
#define metric_dist(v) vlen(v)/POINTS_PER_METER
#define metric_height(e) (e.maxs_z - e.mins_z)/POINTS_PER_METER
#define metric_volume(mn,mx) (volumeof(mn,mx))/(POINTS_PER_METER*POINTS_PER_METER*POINTS_PER_METER)
float volumeof(vector bmin, vector bmax) = { return (bmax_x-bmin_x)*(bmax_y-bmin_y)*(bmax_z-bmin_z); }

/*
=================
 bbox-based operations
=================
*/

// returns center of bound box
#define bbox_origin(e) (e.absmin+(e.absmax-e.absmin)*0.5)
// height of bound box
#define bbox_height(e) (e.maxs_z-e.mins_z)
// volume of bound box
float bbox_volume(vector bmin, vector bmax) = { vector s; s = bmax - bmin; return s_x*s_y*s_z; }
// average radius of boundbox
float bbox_radius(vector bmin, vector bmax) = { float r1, r2, r; r1 = fabs(bmax_x) + fabs(bmin_x); r2 = fabs(bmax_y) + fabs(bmin_y); if (r1 > r2) return r1/2; return r2/2; }
// get a minimal corner at per-axis base
vector bbox_min(vector v1, vector v2) = { if (v2_x < v1_x) v1_x = v2_x; if (v2_y < v1_y) v1_y = v2_y; if (v2_z < v1_z) v1_z = v2_z; return v1; }
// get a maximap corner at per-axis base
vector bbox_max(vector v1, vector v2) = { if (v2_x > v1_x) v1_x = v2_x; if (v2_y > v1_y) v1_y = v2_y; if (v2_z > v1_z) v1_z = v2_z; return v1; }
// check if point is in bound box
float pointinbox(vector p, vector m1, vector m2) = { return p_x >= m1_x && p_x <= m2_x && p_y >= m1_y && p_y <= m2_y && p_z >= m1_z && p_z <= m2_z; }
// check if two boxes overlap
float boxesoverlap(vector m1, vector m2, vector m3, vector m4) = { return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y && m2_z >= m3_z && m1_z <= m4_z; }
// check of point is in xy space of bound box
float pointinsector(vector p, vector m1, vector m2) = { return p_x >= m1_x && p_x <= m2_x && p_y >= m1_y && p_y <= m2_y; }
// check if two bound boxes overlap at xy
float sectorsoverlap(vector m1, vector m2, vector m3, vector m4) = { return m2_x >= m3_x && m1_x <= m4_x && m2_y >= m3_y && m1_y <= m4_y; }

/*
=================
 default fields
=================
*/

#define copyfield(from,to,f) to.f = from.f
void defaultvalue(.float f, float deff) = {  if (self.f == 0) self.f = deff; }
void defaultstring(.string s, string defs) = { if (self.s == "") self.s = defs;  }
void defaultvector(.vector v, vector defv) = { if (self.v == '0 0 0') self.v = defv; }

#ifndef TARG_MENUPROGS
string precache_model(string m);
string precache_sound(string m);
void defaultmodel(.string ms, string m) = { if (self.ms != "") return; precache_model(m); self.ms = m; }
void defaultsound(.string ss, string s) = { if (self.ss != "")	return; precache_sound(s); self.ss = s; }
#endif

/*
=================
 warning
=================
*/

void(string s) warning =
{
	string str;
	
	#ifdef TARGET_GAMEPROGS
		str = strcat(str, "^3WARNING!!!^7\ncast from ");
		str = strcat(str, etos(self));
		str = strcat(str, " - ");
		str = strcat(str, self.classname);
		str = strcat(str, ": ");
		str = strcat(str, s);
		str = strcat(str, "\n");
	#else
		str = strcat(str, "^3WARNING!!!^7: ");
		str = strcat(str, s);
		str = strcat(str, "\n");
	#endif
	print(str);
};

/*
=================
 strings
=================
*/

// builtin prototypes:
float strlen(string s);
string strcat(string s1, string s2, ...);
string strzone(string s);
void strunzone(string s);
string substring(string s, float start, float length);
string ftos (float f);
string vtos (vector v);
string etos (entity ent);
vector stov(string s);
#define etof(e) stof(substring(etos(e), 7, 100))
float fopen(string filename, float mode);
void fclose(float fhandle);
void fputs(float fhandle, string s, ...);

// creates nul zoned string
#define newzone() strzone(null_string)

// creates zoned string and immediately fills it with data
#define zone(v) strzone(v)

// unzones zoned string and returns it's value as tempstring
string zonemaketemp(string s) { string t; t = strcat(s, ""); strunzone(s);  return t; }
string zonedestroy(string s) { strunzone(s); return ""; }
#define unzone(s) s = zonedestroy(s)
#define maketemp(s) s = zonemaketemp(s)

// alternate the zoned string with new value
string zonerezone(string a, string b) { strunzone(a); return strzone(b); }
#define rezone(a,b) a = zonerezone(a, b)

// NEW TEMPSTRING OPERATIONS

// for converting first-chars of string to upper or lower format
string(string s) strftolower = { return strcat(strtolower(substring(s, 0, 1)), substring(s, 1, 100000)); }
string(string s) strftoupper = { return strcat(strtoupper(substring(s, 0, 1)), substring(s, 1, 100000)); }

// sleft and sright
#define sleft(s,l) substring(s, 0, l)
#define sright(s,l) substring(s, strlen(s)-l, l)

// new temporary string from give one
string strtemp(string s) { return strcat(s,""); }

// expands string with [add] up to [c] length, cuts to [c] length if larger
string strexpand(string s, string add, float c, float addbefore) { float ls, l; add = strcat(add, add, add, add, add, add, add, add); add = strcat(add, add, add, add, add, add, add, add); add = strcat(add, add, add, add, add, add, add, add); if (addbefore) { s = strcat(add, s); s = substring(s, strlen(s)-c, 10000); return s; } s = strcat(s, add); s = substring(s, 0, c); return s; }

// compares two characters by acsii value of them
const string strcomp_chartab = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
#define strcomp_chartab_len 62
float charcomp(string s1, string s2)
{
	float f1, f2;
	s1 = substring(s1,0,1);
	s2 = substring(s2,0,1);
	// for s1
	for (f1=strcomp_chartab_len;f1>=0;f1--)
		if (substring(strcomp_chartab, f1, 1) == s1)
			break;
	// for s2
	for (f2=strcomp_chartab_len;f2>=0;f2--)
		if (substring(strcomp_chartab, f2, 1) == s2)
			break;
	if (f1 > f2)
		return POSITIVE;
	if (f1 < f2)
		return NEGATIVE;
	return FALSE;
}

// replace 1 component in a string
string str_replace(string aStr, string aFind, string aReplace)
{
	float tFindLen, tPos, tAddPos, tLen;
	string tFrag, tResult;

	tLen = strlen(aStr); 
	tFindLen = strlen(aFind);
	for (tPos = 0; tPos < tLen; tPos += 1)
	{
		tFrag = substring(aStr, tPos, tFindLen);
		if (tFrag == aFind)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace);
			tAddPos = tPos + tFindLen;
		}
	}
	tResult = strcat(tResult, substring(aStr, tAddPos, tPos-tAddPos));

	return tResult;
}

// replace 2 components in string
string str_replace2(string aStr, string aFind, string aReplace, string aFind2, string aReplace2)
{
	float tFindLen, tPos, tAddPos, tLen;
	string tFrag, tResult;

	tLen = strlen(aStr); 
	tFindLen = strlen(aFind);
	if (tFindLen != strlen(aFind2))
	{
		warning(strcat("strreplace2: mismatch length on aFind and aFind2 (", aFind, " vs ", aFind2, ")"));
		return aStr;
	}
	for (tPos = 0; tPos < tLen; tPos += 1)
	{
		tFrag = substring(aStr, tPos, tFindLen);
		if (tFrag == aFind)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace);
			tAddPos = tPos + tFindLen;
		}
		else if (tFrag == aFind2)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace2);
			tAddPos = tPos + tFindLen;
		}
	}
	tResult = strcat(tResult, substring(aStr, tAddPos, tPos-tAddPos));
	return tResult;
}

// replace 3 components in string
// faster than three separate strreplace, but lenght of aFind, aFind2 and aFind3 must be equal
string str_replace3(string aStr, string aFind, string aReplace, string aFind2, string aReplace2, string aFind3, string aReplace3)
{
	float tFindLen, tPos, tAddPos, tLen;
	string tFrag, tResult;

	tLen = strlen(aStr); 
	tFindLen = strlen(aFind);

	if (tFindLen != strlen(aFind2) || tFindLen != strlen(aFind3))
	{
		warning(strcat("strreplace3: mismatch length on aFind, aFind2 and aFind('", aFind, "' vs '", aFind2, "' vs '", aFind3, "')"));
		return aStr;
	}
	for (tPos = 0; tPos < tLen; tPos += 1)
	{
		tFrag = substring(aStr, tPos, tFindLen);
		if (tFrag == aFind)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace);
			tAddPos = tPos + tFindLen;
		}
		else if (tFrag == aFind2)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace2);
			tAddPos = tPos + tFindLen;
		}
		else if (tFrag == aFind3)
		{
			tFrag = substring(aStr, tAddPos, tPos-tAddPos);
			tResult = strcat(tResult, tFrag, aReplace3);
			tAddPos = tPos + tFindLen;
		}
	}
	tResult = strcat(tResult, substring(aStr, tAddPos, tPos-tAddPos));
	return tResult;
}

// cound newlines in a string
float strcountnl(string tStr) { float tPos, tLen, tNumNewLines; tLen = strlen(tStr); for (tPos = 0; tPos < tLen; tPos++) if (substring(tStr, tPos, 1) == "\n") tNumNewLines++; return tNumNewLines+1; }

// same as strmaketoken but quicker (and less readable)
string strquickmaketoken(string tStr) { if (strlen(tStr) == 1) if (tStr == "\\" || tStr == ":" || tStr == "(" || tStr == ")" || tStr == "[" || tStr == "]" || tStr == "{" || tStr == "}" || tStr == ";" || tStr == ",") return tStr; if (strstr(tStr, "\"") >= 0) tStr = strreplace("\"", "\\\"", tStr); return strcat("\"", tStr, "\""); }

// prepare string to be included in token-string, adds quotes if needed
string strmaketoken(string tStr)
{
	if (tStr == "")
		return "\"\"";
	if (strlen(tStr) == 1)
		if (tStr == "\\" || tStr == ":" || tStr == "(" || tStr == ")" || tStr == "[" || tStr == "]" || tStr == "{" || tStr == "}" || tStr == ";" || tStr == ",")
			return tStr;
	tStr = strreplace("\n", "\\n", tStr);
	if (strstrofs(tStr, "\"", 0) >= 0) { tStr = strreplace("\"", "\\\"", tStr); return strcat("\"", tStr, "\""); }
	if (strstrofs(tStr, " ", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "	", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "\n", 0) >= 0) return strcat("\"", tStr, "\"");	
	if (strstrofs(tStr, "'", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "#", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "\\", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "/", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "(", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, ")", 0) >= 0) return strcat("\"", tStr, "\"");	
	if (strstrofs(tStr, "[", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, "]", 0) >= 0) return strcat("\"", tStr, "\"");	
	if (strstrofs(tStr, "{", 0) >= 0) return strcat("\"", tStr, "\"");	
	if (strstrofs(tStr, "}", 0) >= 0) return strcat("\"", tStr, "\"");	
	if (strstrofs(tStr, ":", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, ";", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, ",", 0) >= 0) return strcat("\"", tStr, "\"");
	if (strstrofs(tStr, ".", 0) >= 0) return strcat("\"", tStr, "\"");
	return tStr;	
}

// like ftos but do not make 1.500000 like values
string ftos2(float tF) { string tS, tChar; float tPos; if (tF == floor(tF)) return ftos(tF); tS = ftos(tF); tPos = strlen(tS)-1; while(tPos >= 0) { tChar = substring(tS, tPos, 1); if (tChar != "0") break; tPos = tPos - 1; } if (tChar == ".") return substring(tS, 0, tPos); return substring(tS, 0, tPos+1); }

// check if string is altstring
float altstr_check(string str) { if (substring(str, 0, 1) != "'") return 0; if (substring(str, strlen(str)-1, 1) != "'") return 0;	return 1;		 }

// get altstring length
float altstr_len(string tStr) { float tPos, tLen, tCount; string tC; for(tLen = strlen(tStr); tPos < tLen ; tPos++) { tC = substring(tStr, tPos, 1); if (tC == "'") tCount++; else if (tC == "\\") tPos++; } return floor(tCount/2); };

// get a fragment from altstring
string altstr_frag(string tString, float tIndex)
{
	float tCount; 
	float tPos; 
	float tLen; 
	string tC, tFrag;
	
	tIndex = tIndex*2 + 1; // number of ' until item starts
	tLen = strlen(tString);
	for (tPos = 0; tPos < tLen && tCount < tIndex; tPos++) 
	{
		tC = substring(tString, tPos, 1);
		if(tC == "'")
			tCount++;
		else if (tC == "\\")
			tPos++;
	}
	// get fragment, unescape \'
	if (tCount != tIndex)
		return strtemp("");
	for (tFrag = ""; tPos < tLen; tPos++) 
	{
		tC = substring(tString, tPos, 1 );
		if (tC == "'")
			break;
		if (tC == "\\") 
		{
			tPos++;
			if (tPos >= tLen)
				break;
			tC = substring(tString, tPos, 1);
		}
		tFrag = strcat(tFrag, tC);
	}
	return tFrag; 
};

// get a part from sub-string (like a|b|c) and set strpart_pos global
nosave float strpart_pos;
string strpart(string tStr, string tSep, float tStart)
{
	strpart_pos = strstrofs(tStr, tSep, tStart);
	// end string, return rest of line
	if (strpart_pos < 0)
		return substring(tStr, tStart, 10000);
	// mid of line 
	tStr = substring(tStr, tStart, strpart_pos - tStart);
	strpart_pos += strlen(tSep);
	return tStr;
}

/*
=======================================
  SEPARATED STRINGS
  strings containing several fragments with space between them
  NOTE: Always create sepstrings using sepstr_create because it places info about separator.
        Using string created without sepstr_create can be dangerous
  NOTE: Separator only can be 1 char-length.
=======================================
*/

nosave string sepstr_separator;

string sepstr_create(string pSep); // create new sepstring
float sepstr_len(string str); // get length of sepstring
string sepstr_frag(string str, float pFrag); // get fragment of sepstring
string sepstr_nextfrag(string str, float pPos); // get next frag after pPos (faster than sepstr_frag)
string sepstr_del(string str, float pFrag); // delete fragment from sepstring
string sepstr_ins(string str, float pFrag, string pElement); // insert new element to sepstring before pFrag one
string sepstr_set(string str, float pFrag, string pElement); // set requested element of sepstring

// create new sepstring
string sepstr_create(string pSep) { return substring(pSep, 0, 1); }

// length of sepstring
float sepstr_len(string str)
{
	float tPos, tLen, tCount;

	sepstr_separator = substring(str, 0, 1);

	tLen = strlen(str);
	for (tPos = 1; tPos < tLen; tPos++)
	{
		if (substring(str, tPos, 1) == sepstr_separator)
			tCount++;
	}

	return tCount;
}

// get a sepstring fragment
string sepstr_frag(string str, float pFrag)
{
	float tPos, tLen, tCount, tFix;

	sepstr_separator = substring(str, 0, 1);

	tLen = strlen(str);
	for (tPos = 1, tFix = 1; tPos < tLen; tPos++)
	{
		if (substring(str, tPos, 1) == sepstr_separator)
		{
			if (tCount == pFrag)
				break;
			tFix = tPos + 1;
			tCount++;
		}
	}

	return substring(str, tFix, tPos-tFix);	
}

// get a next fragment of sepstring
string sepstr_nextfrag(string str, float pPos)
{
	float tPos, tLen;

	sepstr_separator = substring(str, 0, 1);
	tLen = strlen(str);
	for (tPos = pPos; tPos < tLen; tPos++)
		if (substring(str, tPos, 1) == sepstr_separator)
			break;
	return substring(str, pPos, tPos-pPos);
}

// add a sepstring piece
string sepstr_add(string str, string pAdd)
{
	sepstr_separator = substring(str, 0, 1);

	return strcat(str, pAdd, sepstr_separator);
}

// push a sepstring with piece
string sepstr_push(string str, string pAdd)
{
	return strcat(substring(str, 0, 1), pAdd, str);
}

// delete fragment from sepstring
string sepstr_del(string str, float pFrag)
{
	float tPos, tLen, tCount, tFix, tFixEnd, tFixStart;
	string tResult;

	sepstr_separator = substring(str, 0, 1);

	tLen = strlen(str);
	tFix = pFrag + 1;

	// find requested fragment
	for (tPos = 0; tPos < tLen; tPos++)
	{
		if (substring(str, tPos, 1) == sepstr_separator)
		{
			if (pFrag == tCount)
				tFixEnd = tPos;
			else if (tFix == tCount)
				tFixStart = tPos;
			tCount++;
		}
	}

	tResult = substring(str, 0, tFixEnd);
	tResult = strcat(tResult, substring(str, tFixStart, 10000));
	
	return tResult;	
}

// insert a piece in the middle of sepstring
string sepstr_ins(string str, float pFrag, string pElement)
{
	float tPos, tLen, tCount;
	string tResult;

	sepstr_separator = substring(str, 0, 1);
	tLen = strlen(str);

	// find requested fragment
	for (tPos = 1; tPos < tLen; tPos++)
	{
		if (substring(str, tPos, 1) == sepstr_separator)
		{
			if (tCount == pFrag)
				break;
			tCount++;
		}
	}

	// insert
	tResult = strcat(substring(str, 0, tPos+1), pElement, sepstr_separator);
	tResult = strcat(tResult, substring(str, tPos+1, 1000));

	return tResult;	
}

// change fragment of sepstring
string sepstr_set(string str, float pFrag, string pElement)
{
	float tPos, tLen, tCount, tFix;
	string tResult;

	sepstr_separator = substring(str, 0, 1);
	tLen = strlen(str);

	// find requested fragment
	for (tPos = 1, tFix = 1; tPos < tLen; tPos++)
	{
		if (substring(str, tPos, 1) == sepstr_separator)
		{
			if (tCount == pFrag)
				break;
			tFix = tPos + 1;
			tCount++;
		}
	}

	tResult = strcat(substring(str, 0, tFix), pElement);
	tResult = strcat(tResult, substring(str, tPos, 10000));

	return tResult;	
}

// left and right trimming
string strtrim(string tString)
{
	float tPos, tLen;
	string tChar;

	// right trim
	// todo: optimize with do...while
	for (tPos = strlen(tString) - 1; tPos >= 0; tPos--)
	{
		tChar = substring(tString, tPos, 1);
		if (tChar == " " || tChar == "	" || tChar == "\n")
			continue;
		break;
	}
	tString = substring(tString, 0, tPos+1);
	// left trim
	tLen = strlen(tString);
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tChar = substring(tString, tPos, 1);
		if (tChar == " " || tChar == "	" || tChar == "\n")
			continue;
		break;
	}
	tString = substring(tString, tPos, tLen - tPos);
	return tString;
}

// left trim
string strtriml(string tString)
{
	float tPos, tLen;
	string tChar;

	// left trim
	tLen = strlen(tString);
	for (tPos = 0; tPos < tLen; tPos++)
	{
		tChar = substring(tString, tPos, 1);
		if (tChar == " " || tChar == "	" || tChar == "\n")
			continue;
		break;
	}
	tString = substring(tString, tPos, tLen - tPos);

	return tString;
}

// right trim
string strtrimr(string tString)
{
	float tPos, tLen;
	string tChar;

	// right trim
	for (tPos = strlen(tString) - 1; tPos >= 0; tPos--)
	{
		tChar = substring(tString, tPos, 1);
		if (tChar == " "|| tChar == "	" || tChar == "\n")
			continue;
		break;
	}
	tString = substring(tString, 0, tPos+1);

	return tString;
}

// CONSTANT_LENGTH ELEMENTS LUMP STRINGS
// prepare lump for saving (adds " " in the end until reach lump len)
string clumpele_pack(string tLumpElement, float tLumpSize)
{
	float tPos, tLen;
	string tSe;

	tLen = strlen(tLumpElement);
	if (tLen < tLumpSize)
	{
		tPos = tLen;
		for(tPos = tLumpSize; tPos >= 0; tPos -= 40)
			tSe = strcat(tSe, "                                  ");
		tPos = strlen(strcat(tLumpElement, substring(tSe, 0, tLumpSize - tLen)));
		return strcat(tLumpElement, substring(tSe, 0, tLumpSize - tLen));
	}
	if (tLen > tLumpSize)
		return substring(tLumpElement, 0, tLumpSize); 
	return tLumpElement;
}

// trim lump and extract true data
string clumpele_extract(string tLumpElement)
{
	float tPos;
	
	for (tPos = strlen(tLumpElement) - 1; tPos >= 0; tPos--)
		if (substring(tLumpElement, tPos, 1) != " ")
			break;
	return substring(tLumpElement, 0, tPos+1);
}

// returns TRUE if lump element is null
#define clumpele_isnull_s "null"
#define clumpele_isnull(e) (e == clumpele_isnull_s)

// returns true if given string is lump-string
float clump_verify(string tString)
{
	float tLumpLen, tStrLen;

	// check 'lump' caption
	if (substring(tString, 0, 5) != "clum:")
		return 0;

	// get string and lump length
	tLumpLen = stof(substring(tString, 5, 5));
	tStrLen = (strlen(tString) - 10)/tLumpLen;

	if (tStrLen != floor(tStrLen))
		return 0;
	return 1;
}

// creates new lumpstring
string clump_create(float tLumpSize)
{
	// todo: cast warning?
	if (tLumpSize < 0)
		tLumpSize = 1;
	if (tLumpSize > 32768)
		tLumpSize = 32768;

	return strcat("clum:", clumpele_pack(ftos(tLumpSize), 5));
}

// returns lump elements size
#define clump_getsize(s) stof(substring(s, 5, 5))

// return lump length
float clump_getlen(string tString) 
{
	return (strlen(tString) - 10)/stof(substring(tString, 5, 5));
}

// return lump length (quick variant)
#define clump_getlenquick(s,si) ((strlen(s) - 10)/si)

// returns lump element
string clump_get(string tString, float tIndex)
{
	float tLumpSize;

	tLumpSize = clump_getsize(tString);

	return clumpele_extract(substring(tString, 10 + tIndex*tLumpSize, tLumpSize));
}

// returns lump element (quick variant)
// don't forget to clump_extract it if using strings
#define clump_getquick(s,si,i) substring(s, 10 + i*si, si)

// add new element in the ending of lump
string clump_add(string tString, string tValue)
{
	float tLumpSize;

	tLumpSize = clump_getsize(tString);

	return strcat(tString, clumpele_pack(tValue, tLumpSize));
}

// add new element in the ending of lump (quick variant)
#define clump_addquick(s,si,v) strcat(s, clumpele_pack(v, si))

// add new element in the beginning of lump
string clump_push(string tString, string tValue)
{
	float tLumpSize;

	tLumpSize = clump_getsize(tString);

	return strcat(tString, substring(tString, 0, 10), clumpele_pack(tValue, tLumpSize), substring(tString, 10, 10000));
}

// add new element in the beginning of lump (quick variant)
#define clump_pushquick(s,si,v) strcat(s, substring(s, 0, 10), clumpele_pack(v, si), substring(s, 10, 10000))

// set lump element
string clump_set(string tString, float tIndex, string tValue)
{
	float tLumpSize;
	float tLumpLen;
	float tPos;

	if (tIndex < 0)
		return tString;

	tLumpSize = clump_getsize(tString);
	tLumpLen = clump_getlen(tString);

	if (tIndex >= tLumpLen)
		for (tPos = tLumpLen; tPos <= tIndex; tPos++)
			tString = clump_addquick(tString, tLumpSize, "null");

	return strcat(substring(tString, 0, tIndex*tLumpSize + 10), clumpele_pack(tValue, tLumpSize), substring(tString, 10 + tIndex*tLumpSize + tLumpSize, 10000));
}

// set lump element (quick variant)
string clump_setquick(string tString, float tLumpSize, float tIndex, string tValue)
{
	float tLumpLen;
	float tPos;

	tLumpLen = clump_getlen(tString);

	if (tIndex >= tLumpLen)
		for (tPos = tLumpLen; tPos <= tIndex; tPos++)
			tString = clump_addquick(tString, tLumpSize, "null");

	return strcat(substring(tString, 0, tIndex*tLumpSize + 10), clumpele_pack(tValue, tLumpSize), substring(tString, 10 + tIndex*tLumpSize + tLumpSize, 10000));
}

// removes all lump elements
string clump_clear(string tString)
{
	return substring(tString, 0, 10);
}

// removes all lump elements (quick variant)
#define clump_clearquick(s) substring(s, 0, 10)

// convert separator-string to lump
#ifdef TARG_CLIENTPROGS
string clump_cfss(string tStr, string tSeparator, float tLumpSize)
{
	float tNumTokens, tPos;
	string tResult;

	tResult = clump_create(tLumpSize);
	tNumTokens = tokenizebyseparator(tStr, tSeparator);
	for (tPos = 0; tPos < tNumTokens; tPos++)
		tResult = clump_addquick(tResult, tLumpSize, argv(tPos));

	return tResult;
}
#endif

// convert token-string to lump
string clump_cfts(string tStr, float tLumpSize)
{
	float tNumTokens, tPos;
	string tResult;

	tResult = clump_create(tLumpSize);
	tNumTokens = tokenize(tStr);
	for (tPos = 0; tPos < tNumTokens; tPos++)
		tResult = clump_addquick(tResult, tLumpSize, argv(tPos));

	return tResult;
}

/*
======================================================================
 VARIABLE-LENGTH ELEMENTS LUMP STRINGS
 pretty fast in ordered access
 useble for storing of chained information which is processed in loop
======================================================================
*/

// create a lump-string
// maximum length - 9999 characters
#define _lump_name "lmp:"
string lump_pack(string s) { float l; l = strlen(s); if (l < 10) return strcat("000", ftos(l)); if (l < 100) return strcat("00", ftos(l)); if (l < 1000) return strcat("0", ftos(l)); return ftos(l); }

// create new lump
#define newlump() _lump_name

// verify is this is a lump string
#define islump(lump_str) (substring(lump_str,0,4) == _lump_name)

// add element to lump string into the end
#define poplump(lump_str,str) strcat(lump_str,lump_pack(str),str)

// add element to lump string in the beginning
#define pushlump(lump_str,str) strcat(lump_pack(str),str,lump_str)

// get next element length
#define lumpchunk(lump_str,str_pos) stof(substring(lump_str,str_pos,4))

// get next element length
#define lumpread(lump_str,str_pos,ele_len) substring(lump_str,str_pos+4,ele_len)

// get start pos for elements chain
#define lumpstart(lump_str) 4

// advance lump
#define lumpstep(str_pos,ele_len) (str_pos + 4 + ele_len)

// create lump out of parms
string makelump(string s1) { return strcat(_lump_name, lump_pack(s1), s1); }
string makelump2(string s1, string s2) { return strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2); }
string makelump3(string s1, string s2, string s3) { return strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); }
string makelump4(string s1, string s2, string s3, string s4) { string r; r = strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); return strcat(r, lump_pack(s4), s4); }
string makelump5(string s1, string s2, string s3, string s4, string s5) { string r; r = strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); return strcat(r, lump_pack(s4), s4, lump_pack(s5), s5); }
string makelump6(string s1, string s2, string s3, string s4, string s5, string s6) { string r; r = strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); return strcat(r, lump_pack(s4), s4, lump_pack(s5), s5, lump_pack(s6), s6); }
string makelump7(string s1, string s2, string s3, string s4, string s5, string s6, string s7) { string r; r = strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); r = strcat(r, lump_pack(s4), s4, lump_pack(s5), s5, lump_pack(s6), s6); return strcat(r, lump_pack(s7), s7); }
string makelump8(string s1, string s2, string s3, string s4, string s5, string s6, string s7, string s8) { string r; r = strcat(_lump_name, lump_pack(s1), s1, lump_pack(s2), s2, lump_pack(s3), s3); r = strcat(r, lump_pack(s4), s4, lump_pack(s5), s5, lump_pack(s6), s6); return strcat(r, lump_pack(s7), s7, lump_pack(s8), s8); }

/*
=================
 filenames
=================
*/

// load a file and return as stringbuffer
float loadfile(string s)
{
	float fh, bh;
	
	fh = fopen(s, FILE_READ);
	if (fh < 0)
		return -1;
	bh = buf_create();
	for(s = fgets(fh); s; s = fgets(fh))
		bufstr_add(bh, s, 1);
	fclose(fh);
	return bh;
}

// check if file exists
string whichpack(string s);
float file_exist(string s)
{
	float fh;
	
	// check a PAK file first
	if (whichpack(s) != "")
		return 1;
	// check real file
	fh = fopen(s, FILE_READ);
	if (fh < 0)
		return 0;
	fclose(fh);
	return 1;
}

// get base name of file without extension
string basename(string aName)
{
	float tPos, tLen, tStart;
	string tFile, tStr;

	tFile = aName;
	tLen = strlen(tFile);
	// find start position (cut dirs)
	for (tPos=0; tPos < tLen; tPos++)
		if (substring(tFile, tPos, 1) == "/")
			tStart = tPos+1;
	tStr = substring(tFile, tStart, tLen-tStart);
	return tStr;
}

// get path from filename
string basepath(string aName)
{
	float tPos, tLen, tStart;
	string tFile, tStr;
	tFile = aName;
	tLen = strlen(tFile);
	// find start position (cut dirs)
	for (tPos=0; tPos<tLen; tPos++)
		if (substring(tFile, tPos, 1) == "/")
			tStart = tPos+1;
	tStr = substring(tFile, 0, tStart);
	return tStr;
}

// like basepath but no slash in the end
string basefolder(string aName)
{
	float tPos, tLen, tStart;
	string tFile, tStr;
	tFile = aName;
	tLen = strlen(tFile);
	// find start position (cut dirs)
	for (tPos=0; tPos<tLen; tPos++)
		if (substring(tFile, tPos, 1) == "/")
			tStart = tPos;
	tStr = substring(tFile, 0, tStart);
	return tStr;
}

// returns file extension as tempstring
string extension(string aName)
{
	float tPos, tLen;
	string tFile, tExt;

	tFile = aName;
	tLen = strlen(tFile) - 1;
	for (tPos=0; tPos<tLen; tPos++)
		if (substring(tFile, (tLen-tPos), 1) == ".")
			break;
	if (tPos<tLen)
		return substring(tFile, (tLen-tPos)+1, tPos+1);
	return "";
};

// returns file name without extension
string stripextension(string aName)
{
	float tPos, tLen;
	string tFile, tExt;

	tFile = aName;
	tLen = strlen(tFile) - 1;
	// find extension length
	for (tPos=0; tPos<tLen; tPos++)
		if (substring(tFile, (tLen-tPos), 1) == ".")
			break;
	if (tPos == tLen)
		tPos = 0;
	tExt = substring(tFile, 0, (tLen-tPos));
	return tExt;
};

/*
=================
 log files
=================
*/

void Log_Start(string aLogName)
{
	local float tFileHandle;

	if (!cvar("log_enable"))
		return;

	if (substring(aLogName, 0, 1) == "$") // cvar
	{
		aLogName = cvar_string(substring(aLogName, 1, 1000));
		if (!strlen(aLogName))
			return;
	}

	tFileHandle = fopen(strcat("logs/", aLogName), FILE_WRITE);
	if (tFileHandle >= 0)
	{
		fputs(tFileHandle, "// ");
		fputs(tFileHandle, aLogName);
		fputs(tFileHandle, "\n// generated by log script\n \n");
		fclose(tFileHandle);
	}
}

void Log_Write(string aLogName, string aS)
{
	local float tFileHandle;

	if (!cvar("log_enable"))
		return;

	if (substring(aLogName, 0, 1) == "$") // cvar
	{
		aLogName = cvar_string(substring(aLogName, 1, 1000));
		if (!strlen(aLogName))
			return;
	}

	tFileHandle = fopen(strcat("logs/", aLogName), FILE_APPEND);
	if (tFileHandle >= 0)
	{
		fputs(tFileHandle, aS);
		fclose(tFileHandle);
		return;
	}
	tFileHandle = fopen(strcat("logs/", aLogName), FILE_WRITE);
	if (tFileHandle >= 0)
	{
		fputs(tFileHandle, aS);
		fclose(tFileHandle);
	}
}

void Log_WriteLine(string aLogName, string aS)
{
	if (!cvar("log_enable"))
		return;
	Log_Write(aLogName, strcat(aS, "\n"));
}

void Log_WriteEnt(string aLogName, entity aEnt, vector aOrg, string aMessage)
{
	local string tMessage;

	if (!cvar("log_enable"))
		return;

	tMessage = strcat(etos(aEnt), " at ");
	tMessage = strcat(tMessage, vtos(aOrg), ": ", aMessage);

	Log_WriteLine(aLogName, tMessage);
}

#endif