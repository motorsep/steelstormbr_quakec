////////////////////////////////////////
// NetherGen v 1.0 source code
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

#define VUTIL_NETHERGEN

// ABOUT
// Negen (Nether Generator) is a util to help coders
// with making pulsation/time functions via QC
// TODO

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

#define negenwave_t float(float f, float basefrac)
#define negenop_t void(vector op, float gen, float genendparm)

nosave float negeninitalized;
nosave float negennumfunc; // picked automatically
nosave float negennumops; // picked automatically
nosave float negennumopmodes; // picked automatically
nosave float negennumopdist; // picked automatically
nosave float negenmaxfuncparms = 8; // could be increased
nosave float negenmaxrandomfuncsize = 1024; // could be increased
nosave float negenparmsbuf;
nosave float negenfuncnamesbuf;
nosave float negenfuncdefparmsbuf;
nosave float negenopsbuf;
nosave float negenopmodesbuf;
nosave float negenopdistbuf;
nosave float negenmaxrandombuffers = 64;
nosave float negenrandomfuncbuf;
var negenwave_t negenwavefunc;

// generation input/output
float negenrand; // for random function
float negenfloat;
vector negenvector;

////////////////////////////////////////
// CODE
////////////////////////////////////////

// VorteX: hsb2rgb converter
vector NegenHSBtoRGB(vector hsb) 
{
	float h, f, p, q, t;
	vector rgb;
	
	if (hsb_y == 0.0) 
	{
		rgb_x = hsb_z;
		rgb_y = rgb_x;
		rgb_z = rgb_x;
		return rgb; // eeeeasy case
    }
    h = (hsb_x - floor(hsb_x)) * 6.0;
    f = h - floor(h);
    p = hsb_z * (1.0 - hsb_y);
    q = hsb_z * (1.0 - hsb_y * f);
    t = hsb_z * (1.0 - (hsb_y * (1.0 - f)));
    switch (floor(h)) 
	{
        case 0: rgb_x = hsb_z; rgb_y = t; rgb_z = p; break;
        case 1: rgb_x = q; rgb_y = hsb_z; rgb_z = p; break;
        case 2: rgb_x = p; rgb_y = hsb_z; rgb_z = t; break;
        case 3: rgb_x = p; rgb_y = q; rgb_z = hsb_z; break;
		case 4: rgb_x = t; rgb_y = p; rgb_z = hsb_z; break;
        case 5: rgb_x = hsb_z; rgb_y = p; rgb_z = q;
		default: break;
        break;
    }
    return rgb;
}

// VorteX: rgb2hsb converter
vector NegenRGBtoHSB(vector rgb)
{
	vector hsb;
	float m;

	// renormalize color
	if (rgb_x > 1.0)
		rgb = rgb * (1 / rgb_x);
	if (rgb_y > 1.0)
		rgb = rgb * (1 / rgb_y);	
	if (rgb_z > 1.0)
		rgb = rgb * (1 / rgb_z);	
    // brightness
    hsb_z = max(rgb_x, rgb_y, rgb_z);
    m = min(rgb_x, rgb_y, rgb_z);
	// hue
    if(hsb_z == rgb_x && rgb_y >= rgb_z)
        hsb_x = 60*(rgb_y - rgb_z)/(hsb_z - m);
    else if(hsb_z == rgb_x && rgb_y < rgb_z)
        hsb_x = 60*(rgb_y - rgb_z)/(hsb_z - m) + 360;
    else if(hsb_z == rgb_y)
        hsb_x = 60*(rgb_z - rgb_x)/(hsb_z - m) + 120;
    else if(hsb_z == rgb_z)
        hsb_x = 60*(rgb_x - rgb_y)/(hsb_z - m) + 240;
	// saturation
	if (hsb_z == 0)
		hsb_y = 0;
	else
		hsb_y = 1.0 - (m / hsb_z);
    return hsb;
}

// create random buffer
float NegenRandomBuffer(float bufnum, float roughness) =
{
	float buffer;
	
	// get
	if (bufnum < 0 || bufnum >= negenmaxrandombuffers)
		return -1;
	buffer = stof(bufstr_get(negenrandomfuncbuf, bufnum)); 
	// attempt to create 
	if (buffer == -1000)
	{
		buffer = buf_create();
		roughness = bound(1, roughness, negenmaxrandomfuncsize);
		if (buffer < 0)
			warning("NegenRandomBuffer: faield to create buffer!");
		else
		{
			while(roughness > 0)
			{
				bufstr_add(buffer, ftos(random()), 1);
				roughness--;
			}
		}
		bufstr_set(negenrandomfuncbuf, bufnum, ftos(buffer));
		return buffer;
	}
	return buffer;
}

/*
================================================================================

  GENERATOR SYSTEM

================================================================================
*/

// parms getting
#define NegenParm(p) stof(bufstr_get(negenparmsbuf, p))
#define NegenParmS(p) bufstr_get(negenparmsbuf, p)
#define NegenParmV(p) stov(bufstr_get(negenparmsbuf, p))

enum
{
	NEGEN_FUNC_TIME,
	NEGEN_FUNC_CVAR,
	NEGEN_FUNC_ONE,
	NEGEN_FUNC_ZERO,
	NEGEN_FUNC_INVERT,
	NEGEN_FUNC_THRESH,
	NEGEN_FUNC_SIN,
	NEGEN_FUNC_TRIANGLE,
	NEGEN_FUNC_TRAPEEZE,
	NEGEN_FUNC_RANDMAP,
	NEGEN_FUNC_RANDOM,
	NEGEN_FUNC_REMAP,
	NEGEN_NUM_FUNC
};

// inputfunctions
float(float basefrac) Negen_InputFunc_Time = { float f, t; f = NegenParm(0); if (!f) return 0; return basefrac*((time - f * floor (time / f)) / f); }
float(float basefrac) Negen_InputFunc_Cvar = { return basefrac*bound(0, cvar(NegenParmS(0)), 1); }
// wavefunctions
float(float basefrac) Negen_WaveFunc_One = { return 1; }
float(float basefrac) Negen_WaveFunc_Zero = { return 0; }
float(float basefrac) Negen_WaveFunc_Invert = { return 1 - basefrac; }
float(float basefrac) Negen_WaveFunc_Threshold = { if (basefrac < 0.5) return 0; return 1; } // parm1: threshold, default is 0.5
float(float basefrac) Negen_WaveFunc_Sin = { return (sin(basefrac*MATH_PI) + 1) / 2; } // sine wave
float(float basefrac) Negen_WaveFunc_Triangle = { if (basefrac < 0.5) return basefrac/0.5; return (1 - basefrac)/0.5; } // parm1: pos, default is 0.5
float(float basefrac) Negen_WaveFunc_Trapeeze = { if (basefrac <= 0.25) return basefrac/0.25; if(basefrac >= 0.75) return (1 - basefrac)/0.25; return 1;} // parm1: grow pos, parm2: fall pos
float(float basefrac) Negen_WaveFunc_Randmap = { float f, f1, f2, b, r; r = NegenParm(1); b = NegenRandomBuffer(NegenParm(0), r); f = basefrac*r; f1 = stof(bufstr_get(b, floor(f))); f2 = stof(bufstr_get(b, ceil(f))); return f1 + (f2 - f1)*(f - floor(f)); }
float(float basefrac) Negen_WaveFunc_Random = { return basefrac*random(); }
float(float basefrac) Negen_WaveFunc_Remap = { float f1, f2; f1 = NegenParm(0); f2 = NegenParm(1); if (basefrac < f1) return 0; if (basefrac >= f2) return 1; return 1 - ((f2 - basefrac)/(f2 - f1)); }

// default wavefunction
negenwave_t negenemptywave = { return basefrac; }
negenwave_t negenwave =
{
	switch(f) {
	// input
	case 0: return Negen_InputFunc_Time(basefrac); break;
	case 1: return Negen_InputFunc_Cvar(basefrac); break;
	// wavefunctions
	case 2: return Negen_WaveFunc_One(basefrac); break;
	case 3: return Negen_WaveFunc_Zero(basefrac); break;
	case 4: return Negen_WaveFunc_Invert(basefrac); break;
	case 5: return Negen_WaveFunc_Threshold(basefrac); break;
	case 6: return Negen_WaveFunc_Sin(basefrac); break;
	case 7: return Negen_WaveFunc_Triangle(basefrac); break;
	case 8: return Negen_WaveFunc_Trapeeze(basefrac); break;
	case 9: return Negen_WaveFunc_Randmap(basefrac); break;
	case 10: return Negen_WaveFunc_Random(basefrac); break;
	case 11: return Negen_WaveFunc_Remap(basefrac); break;
	
	default: return 0; }
};
string negenfuncnames = "time cvar		one zero invert thresh sin triangle trapeeze randmap random remap";
string negenfuncdefparms = "\"\" \"\" 	\"\" \"\" \"\" \"0.5\" \"\" \"0.5\" \"0.25 0.75\" \"0.5 0\" \"\" \"0 1\"";

// func operators modes
enum
{
	NEGEN_OPMODE_VAL,
	NEGEN_OPMODE_RGB,
	NEGEN_OPMODE_RGB_R,
	NEGEN_OPMODE_RGB_G,
	NEGEN_OPMODE_RGB_B,
	NEGEN_OPMODE_HSB,
	NEGEN_OPMODE_HSB_H,
	NEGEN_OPMODE_HSB_S,
	NEGEN_OPMODE_HSB_B,
	NEGEN_NUM_OPMODES
};
string negenopmodenames = "val rgb rgb.r rgb.g rgb.b hsb hsb.h hsb.s hsb.b";

// func operators (returned by Negen() func)
enum
{
	NEGEN_OP_SET,
	NEGEN_OP_ADD,
	NEGEN_OP_SUB,
	NEGEN_OP_MUL,
	NEGEN_OP_DIV,
	NEGEN_OP_MIX,
	NEGEN_NUM_OPS
};
string negenopnames = "set add sub mul div mix";

// distribution types
enum
{
	NEGEN_OPDIST_LERP, 	// interpolate between set of values
	NEGEN_OPDIST_SELECT,// select a nearest value
	NEGEN_OPDIST_FLOOR, // select a poorest value
	NEGEN_OPDIST_CEIL, 	// select a highest value
	NEGEN_NUM_OPDIST
};
string negenopdistnames = "lerped select floor ceil";

// applying an opmode operator
negenop_t negenemptyop = {}
negenop_t negenop =
{
	float sdiv, f1, f2, f;
	vector v1, v2, v;
	
	#define opDist(vall,start,end) switch(op_z) { case NEGEN_OPDIST_LERP: vall = start + (end - start)*(sdiv - floor(sdiv)); break; case NEGEN_OPDIST_SELECT: if ((sdiv - floor(sdiv)) > 0.5) vall = end; else vall = start; break; case NEGEN_OPDIST_FLOOR: vall = start; break; case NEGEN_OPDIST_CEIL: vall = end; break; default: break;  }     
	#define getF(vall)  f1 = stof(argv(1 + floor(sdiv))); f2 = stof(argv(1 + ceil(sdiv))); opDist(vall, f1, f2)
	#define getV(vall) v1 = stov(argv(1 + floor(sdiv))); v2 = stov(argv(1 + ceil(sdiv))); opDist(vall, v1, v2)
	#define opFloat(ops,dstVal,srcVal) switch(ops) { case NEGEN_OP_SET: dstVal = srcVal; break; case NEGEN_OP_ADD: dstVal = dstVal + srcVal; break; case NEGEN_OP_SUB: dstVal = dstVal - srcVal; break; case NEGEN_OP_MUL: dstVal = dstVal * srcVal; break; case NEGEN_OP_DIV: dstVal = dstVal / srcVal; break; }
	#define opVec(ops,dstVal,dstVal_x,dstVal_y,dstVal_z,srcVal,srcVal_x,srcVal_y,srcVal_z) switch(ops) { case NEGEN_OP_SET: dstVal = srcVal; break; case NEGEN_OP_ADD: dstVal = dstVal + srcVal; break; case NEGEN_OP_SUB: dstVal = dstVal - srcVal; break; case NEGEN_OP_MUL: dstVal_x = dstVal_x * srcVal_x; dstVal_y = dstVal_y * srcVal_y; dstVal_z = dstVal_z * srcVal_z; break; case NEGEN_OP_DIV: dstVal_x = dstVal_x / srcVal_x; dstVal_y = dstVal_y / srcVal_y; dstVal_z = dstVal_z / srcVal_z; break; case NEGEN_OP_MIX: dstVal = dstVal + (srcVal - dstVal)*gen; break; default: break; }
	sdiv = gen / (1 / ( genendparm - 1 ) ); // for extraction
	if (sdiv < 0 || sdiv > 1)
		print("negenop: input not normalized!\n");
	switch(op_x)
	{
		case NEGEN_OPMODE_VAL:  getF(f) opFloat(op_y, negenfloat, f) break;
		case NEGEN_OPMODE_RGB:  getV(v) opVec(op_y, negenvector, negenvector_x, negenvector_y, negenvector_z, v, v_x, v_y, v_z) break;
		case NEGEN_OPMODE_RGB_R: getF(f) opFloat(op_y, negenvector_x, f) break;
		case NEGEN_OPMODE_RGB_G: getF(f) opFloat(op_y, negenvector_y, f) break;
		case NEGEN_OPMODE_RGB_B: getF(f) opFloat(op_y, negenvector_z, f) break;
		case NEGEN_OPMODE_HSB: getV(v) v = NegenHSBtoRGB(v); opVec(op_y, negenvector, negenvector_x, negenvector_y, negenvector_z, v, v_x, v_y, v_z) break;
		case NEGEN_OPMODE_HSB_H: getF(f) negenvector = NegenRGBtoHSB(negenvector); opFloat(op_y, negenvector_x, f) negenvector = NegenHSBtoRGB(negenvector); break;
		case NEGEN_OPMODE_HSB_S: getF(f) negenvector = NegenRGBtoHSB(negenvector); opFloat(op_y, negenvector_y, f) negenvector = NegenHSBtoRGB(negenvector); break;
		case NEGEN_OPMODE_HSB_B: getF(f) negenvector = NegenRGBtoHSB(negenvector); opFloat(op_y, negenvector_z, f) negenvector = NegenHSBtoRGB(negenvector); break;
		default: break;
	}
	#undef opDist
	#undef getF
	#undef getV
	#undef opFloat
	#undef opVec
}

/*
================================================================================

  GENERATOR STARTUP

================================================================================
*/

void() InitNegen =
{
	float i, k, b;
	
	if (negeninitalized)
		return;
	// create buffers
	negeninitalized = 1;
	negenparmsbuf = buf_create();
	negenfuncnamesbuf = buf_create();
	negenfuncdefparmsbuf = buf_create();
	negenopsbuf = buf_create();
	negenopmodesbuf = buf_create();
	negenopdistbuf = buf_create();
	negenrandomfuncbuf = buf_create();
	i = negenparmsbuf*negenfuncnamesbuf*negenfuncdefparmsbuf*negenopsbuf*negenopmodesbuf*negenopdistbuf*negenrandomfuncbuf;
	if (i < 0)
		error("InitSky: failed to create negen buffers!\n");
	// fill function names buffer
	for (i = 0; i < negenmaxfuncparms; i++)
		bufstr_set(negenparmsbuf, i, "");
	// func names
	negennumfunc = tokenize(negenfuncnames);
	for (i = 0; i < negennumfunc; i++)
		bufstr_set(negenfuncnamesbuf, i, argv(i));
	// default func parms
	tokenize(negenfuncdefparms);
	for (i = 0; i < negennumfunc; i++)
	{
		tokenize(argv(i));
		b = buf_create();
		if (b < 0)
			error("InitSky: failed to create negen input defparms buffer!\n");
		for (k = 0; k < negenmaxfuncparms; k++)
			bufstr_set(b, k, argv(i));
		bufstr_set(negenfuncdefparmsbuf, i, ftos(b));
		tokenize(negenfuncdefparms);
	}
	// func op class buffer
	negennumopmodes = tokenize(negenopmodenames);
	for (i = 0; i < negennumopmodes; i++)
		bufstr_set(negenopmodesbuf, i, argv(i));
	// func ops buffer
	negennumops = tokenize(negenopnames);
	for (i = 0; i < negennumops; i++)
		bufstr_set(negenopsbuf, i, argv(i));
	// func op distrubutions
	negennumopdist = tokenize(negenopdistnames);
	for (i = 0; i < negennumopdist; i++)
		bufstr_set(negenopdistbuf, i, argv(i));
	// default custom wavefunc
	negenwavefunc = negenemptywave;
	// fill randbuffer
	for (i = 0; i < negenmaxrandombuffers; i++)
		bufstr_set(negenrandomfuncbuf, i, "-1000");
}

// return vector filled with custom function buffer handles
// use with parser helper
vector NegenMakeCustomBuffers(string customfuncnames, string customfuncparms) =
{
	vector custombuffers;
	float i, b, k;
	
	custombuffers_x = buf_create();
	custombuffers_y = buf_create();
	if (custombuffers_x * custombuffers_y < 0)
		error("NegenMakeCustomBuffers: failed to create buffer!\n");
	// func names
	custombuffers_z = tokenize(customfuncnames);
	for (i = 0; i < custombuffers_z; i++)
		bufstr_set(custombuffers_x, i, argv(i));
	// default func parms
	tokenize(customfuncparms);
	for (i = 0; i < custombuffers_z; i++)
	{
		tokenize(argv(i));
		b = buf_create();
		if (b < 0)
			error("NegenMakeCustomBuffers: failed to create negen input defparms buffer!\n");
		for (k = 0; k < negenmaxfuncparms; k++)
			bufstr_set(b, k, argv(i));
		bufstr_set(custombuffers_y, i, ftos(b));
		tokenize(customfuncparms);
	}
	return custombuffers;
}

void() ShutdownNegen =
{
	if (!negeninitalized)
		return;
	if (negenparmsbuf >= 0)
		buf_del(negenparmsbuf);
	if (negenfuncnamesbuf >= 0)
		buf_del(negenfuncnamesbuf);
	if (negenfuncdefparmsbuf >= 0)
		buf_del(negenfuncdefparmsbuf);
	if (negenopsbuf >= 0)
		buf_del(negenopsbuf);	
	if (negennumopdist >= 0)
		buf_del(negennumopdist);	
	// todo: fix many leaks
}

/*
================================================================================

  PARSER

================================================================================
*/

// get full name for op
string NegenNameForOp(vector op)
{
	string s;
	
	s = bufstr_get(negenopmodesbuf, op_x);
	s = strcat(s, " ", bufstr_get(negenopsbuf, op_y));
	s = strcat(s, " ", bufstr_get(negenopdistbuf, op_z));
	
	return s;
}

// get name for function
string NegenNameForFunc(float func)
{
	if (func < 0)
		return "unknown function";
	if (func >= negennumfunc)
		return strcat("custom #", ftos(func - negennumfunc));
	return bufstr_get(negenfuncnamesbuf, func);
}

// evaluate an op/opmide/opdist
float NegenEvaluate(float buf, string s)
{
	float i, n;
	
	if (buf <= 0)
		return -1;
	s = strtolower(s);
	n = buf_getsize(buf);
	for (i = 0; i < n; i++)
		if (bufstr_get(buf, i) == s)
			return i;
	return -1;
}

//  evaluate a function
float NegenEvaluateFunc(vector custombuffers, string s) =
{
	float i, b;
	
	s = strtolower(s);
	// custom wavefunc?
	for (i = 0; i < custombuffers_z; i++)
	{
		if (s == bufstr_get(custombuffers_x, i))
		{
			// evaluated, fill parms buf
			b = stof(bufstr_get(custombuffers_y, i));
			buf_copy(b, negenparmsbuf);
			return negennumfunc + i;
		}
	}
	// check the standart buffers
	for (i = 0; i < negennumfunc; i++)
	{
		if (s == bufstr_get(negenfuncnamesbuf, i))
		{
			// evaluated, fill parms buf
			b = stof(bufstr_get(negenfuncdefparmsbuf, i));
			buf_copy(b, negenparmsbuf);
			return i;
		}
	}
	return -1;
}

// used by parser, see code below
void NegenFillParm(float parm, string s) =
{
	if (s == "-" || parm < 0 || parm >= negenmaxfuncparms)
		return;
	bufstr_set(negenparmsbuf, parm, s);
}

// used by parser, see code below
string() NegenGetAllParms =
{
	float i, writing;
	string s, a;
	
	s = "";
	// VorteX: "don't write tail optimisation"
	for (i = negenmaxfuncparms - 1; i >= 0; i--)
	{
		a = bufstr_get(negenparmsbuf, i);
		if (a != "")
			writing = 1;
		if (writing)
		{
			s = strcat("\"", a, "\" ", s);
			continue;
		}
	}
	return s;
}

string Negen_NetherScriptParseGenString(float defaultOpMode, float defaultOpDist, vector custombuffers) =
{
	float f, getf, numf, fparms, readed;
	vector op;
	string s;
	
	// parse opmode/op/opdist func
	Ns_Parser_ReadArg();
	op_y = NegenEvaluate(negenopsbuf, ns_parser_token);
	if (op_y < 0) // not an op, so opmode is set!
	{
		Ns_Parser_ReadArg();
		op_x = NegenEvaluate(negenopmodesbuf, ns_parser_token);
		Ns_Parser_ReadArg();
		op_y = NegenEvaluate(negenopsbuf, ns_parser_token);
	}
	else op_x = defaultOpMode;
	// check fop opDist
	Ns_Parser_PredictStart(0);
	op_z = NegenEvaluate(negenopdistbuf, ns_parser_token);
	if (op_z < 0)
	{
		Ns_Parser_PredictEnd((op_z >= 0));
		op_z = defaultOpDist;
	}
	// build op string
	s = strcat("'", ftos(op_x), " ", ftos(op_y), " ", ftos(op_z),"' ");
	// parse until find inputfunc
	numf = 0;
	fparms = 0;
	while(Ns_Parser_ReadArg())
	{
		f = NegenEvaluateFunc(custombuffers, ns_parser_token);
		if (f >= 0)
			break;
		s = strcat(s, "\"", ns_parser_token, "\" ");
	}
	// parse inputfunc
	#define SaveFunc() if (!numf) { s = strcat(s, "$ ", ftos(f), " ", NegenGetAllParms()); } else { s = strcat(s, "# ", ftos(f), " ", NegenGetAllParms()); }
	while(1)
	{
		readed = Ns_Parser_ReadOptionalArg();
		if (readed)
		{
			getf = NegenEvaluateFunc(custombuffers, ns_parser_token);
			if (getf < 0)
			{
				NegenFillParm(fparms, ns_parser_token);
				fparms++;
				continue;
			}
			SaveFunc()
			f = getf;
			// prepare for new func!
			numf++;
			fparms = 0;
			continue;
		}
		SaveFunc()
		break;
	}
	#undef SaveFunc
	return s;
}

/*
================================================================================

  GENERATOR MAIN

================================================================================
*/

// custom batchmode negen, enter a default float and vector value
void NegenStart(negenwave_t wavef, float floatval, vector vectorval)
{
	negenwavefunc = wavef;
	negenfloat = floatval;
	negenvector = vectorval;
}

// custom batchmode negen, parse negen compiled string
void NegenStr(string s) =
{
	float spos, slen, f, fparms, fval, fendparms;
	vector op;
	
	#define gen(basefrac) spos++; f = stof(argv(spos)); fparms=0; while(argv(spos) != "#" && spos < slen) {spos++; bufstr_set(negenparmsbuf, fparms, argv(spos)); fparms++; } if (f >= negennumfunc) fval = negenwavefunc(f-negennumfunc, basefrac); else fval = negenwave(f, basefrac);
	slen = tokenize(s);
	op = stov(argv(0));
	spos = 1;
	while(argv(spos) != "$") { spos++; if (spos > slen) break; }
	fendparms = spos - 1;
	gen(1) // parse the input function
	while(spos < slen) { gen(fval) } // parse other funtions}
	negenop(op, fval, fendparms); // apply op
	#undef gen
}

// parse negen buffer
void Negen(float buffer) =
{
	float spos, slen, f, fparms, fval, fendparms, i;
	vector op;
	string s;

	for (i 	= 0; i < buf_getsize(buffer); i++)
	{
		s = bufstr_get(buffer, i);
		#define gen(basefrac) spos++; f = stof(argv(spos)); fparms=0; while(argv(spos) != "#" && spos < slen) {spos++; bufstr_set(negenparmsbuf, fparms, argv(spos)); fparms++; } if (f >= negennumfunc) fval = negenwavefunc(f-negennumfunc, basefrac); else fval = negenwave(f, basefrac);
		slen = tokenize(s);
		op = stov(argv(0));
		spos = 1;
		while(argv(spos) != "$") { spos++; if (spos > slen) break; }
		fendparms = spos - 1;
		gen(1) // parse the input function
		while(spos < slen) { gen(fval) } // parse other funtions}
		negenop(op, fval, fendparms); // apply op
		#undef gen
	}
}