////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

#define MENU_USE_DYNAMIC_TEMPLATING 1

string parsedstate;
float Menu_ParseGeneric(entity tParent);
void Menu_ParseObjectBody(entity tObject);

entity menu_parser_object;
entity menu_parser_parent;

// templates cache, for fast search
entity menu_parser_templates;
.entity _prvtpl;

float MenuParser_PrecompileEvents;
float MenuParser_PrecompileEventsBuf; // a buf containing precompiled script bodies
float MenuParser_PrecompileEventsBufCrc; // a buf containing precompiled script CRC16
float MenuParser_PrecompileEventsBufHandles; // a buf containong precompiled script bufhandles
float MenuParser_PrecompileEventsBufLen;
float MenuParser_PrecompileEventsOpStat;
float MenuParser_ShowStats;
float MenuParser_TimeOpts;

////////////////////////////////////////
// CODE
////////////////////////////////////////

void Menu_Parser_Warning(string str)
{
	float oldwarnings;
	
	oldwarnings = ns_parser_warnings;
	ns_parser_warnings = 1;
	Ns_Parser_Warning(str);
	ns_parser_warnings = oldwarnings;
}

void Menu_Parser_Error(string str)
{
	Ns_Parser_Error(str);
}

/*
===================================================

 TEMPLATES CACHE

===================================================
*/

void Menu_Parser_RegisterTemplate(entity tObject) =
{
	tObject._prvtpl = menu_parser_templates;
	menu_parser_templates = tObject;
	tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_TEMPLATE;
}

float Menu_Parser_FindTemplate(string tTemplateName) =
{
	entity tTemplate;
	for (tTemplate = menu_parser_templates; tTemplate; tTemplate = tTemplate._prvtpl)
	{
		if (tTemplate.localname == tTemplateName)
		{
			foundobject = tTemplate;
			return 1;
		}
	}
	foundobject = null_entity;
	return 0;
}

/*
===================================================

 PARSER

===================================================
*/

void() Menu_ParseSkip =
{
	float numlines;
	
	// now expect object body
	Ns_Parser_Expect("{", 1);
	// parse
	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		Ns_Parser_ReadToken();
		if (ns_parser_token == "}")
		{
			numlines--;
			if (numlines < 0)
				return;
			break; 
		}
		if (ns_parser_token == "{")
			numlines++;
	}
}

float tderivestarted;
entity Menu_ParseDerivedObject(entity parent, float is_template, float is_dynamic) =
{
	string templatename, objname, newclass, newname;
	entity obj, template;
	
	// read class/base template class
	Ns_Parser_ReadToken();
	templatename = ns_parser_token;
	if (!Menu_Parser_FindTemplate(templatename))
		Menu_Parser_Error(strcat("Menu_DeriveObject: cannot find template ", templatename, "\n"));	
	template = foundobject;
	// read name
	Ns_Parser_ReadToken();
	if (ns_parser_token == "{") // no name
	{
		objname = "";
		newclass = "";
	}
	else
	{
		// check for remapclass postfix
		if (ns_parser_token == "NewClass")
			{ Ns_Parser_ReadToken(); newclass = ns_parser_token; Ns_Parser_ReadToken(); }
		if (ns_parser_token == "NewName")
			{ Ns_Parser_ReadToken(); newname = ns_parser_token; Ns_Parser_ReadToken(); }
		objname = ns_parser_token;
		Ns_Parser_RestoreTokens();
		Ns_Parser_Expect("{", 1);
	}
	// create object
	if (isnotentity(template))
		obj = Menu_Sys_NewObject(menu_proc, templatename, objname, parent);
	else
	{
		obj = Menu_Sys_CloneObject(template, objname, parent, MENU_USE_DYNAMIC_TEMPLATING * is_dynamic); // VorteX: dynamic derivation
		if (newclass != "")
			Menu_Sys_SetObjectClass(obj, newclass);
		if (newname != "")
			Menu_Sys_SetObjectName(obj, newname);
	}
	// if template - register in cache
	if (is_template)
		Menu_Parser_RegisterTemplate(obj);
	// parse body
	Ns_Parser_RestoreTokens();
	Menu_ParseObjectBody(obj);
	return obj;
}

entity Menu_ParseNewObject(entity tParent, float tIsTemplate) =
{
	string tClassName;
	entity tObject;

	// read class/base template class
	Ns_Parser_ReadToken();
	if (ns_parser_token != "") // set default class
		tClassName = ns_parser_token;
	else
	{
		tClassName = "DrawSpace";
		Menu_Parser_Warning("Menu_ParseNewObject: class is not set");
	}
	// try to read name and create object
	Ns_Parser_ReadToken();
	if (ns_parser_token == "{")
	{
		tObject = Menu_Sys_NewObject(menu_proc, tClassName, "", tParent);
		Ns_Parser_RestoreTokens();
	}
	else
	{
		tObject = Menu_Sys_NewObject(menu_proc, tClassName, ns_parser_token, tParent);
		Ns_Parser_RestoreTokens();
		Ns_Parser_Expect("{", 1);
	}
	// if template - register in cache
	if (tIsTemplate)
		Menu_Parser_RegisterTemplate(tObject);
	// parse body
	Menu_ParseObjectBody(tObject);
	return tObject;
}

float() Menu_ParseState =
{
	float tReadArg;
	string tBaseState;
	
	// :substate
	if (ns_parser_token == ":") 
	{
		tReadArg = Ns_Parser_ReadArg();
		if (ns_parser_token == ":") // :: - means :normal:
		{
			parsedstate = ":normal";
			return 1;
		}
		if (!tReadArg || ns_parser_token == ",") // just : or :,
		{
			parsedstate = "";
			Menu_Parser_Warning(strcat("Bad state operator: '", ns_parser_token, "'"));
			return 1;
		}
		parsedstate = strcat(":", ns_parser_token);
		return 1;
	}
	// state:substate:
	tBaseState = ns_parser_token;
	if (Ns_Parser_CheckNext(":", 0)) 
	{
		// read substate
		tReadArg = Ns_Parser_ReadArg();
		if (ns_parser_token == ":") // state:: - means state:normal:
			parsedstate = strcat(tBaseState, ":normal");
		else if (!tReadArg || ns_parser_token == ",") // state: or state:, - still means state:normal:
			parsedstate = strcat(tBaseState, ":normal");
		else
			parsedstate = strcat(tBaseState, ":", ns_parser_token);
		return 1;
	}
	return 0;
}

void Menu_ParseObjectBody(entity tObject)
{
	string tMethod, tBaseState, tState, temp;
	string tStateDest1, tStateDest2, tStateDest3, tStateDest4;
	float tReadArg, tStartTime, i;
	
	// reset state destinations
	tStateDest1 = ":normal";
	tStateDest2 = "";
	tStateDest3 = "";
	tStateDest4 = "";
	// parse body
	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		Ns_Parser_ReadToken();
		// end parse object
		if (ns_parser_token == "}")
			break; 
		// parse childs
		if (Menu_ParseGeneric(tObject))
			continue;
		// parse states
		if (Menu_ParseState())
		{
			// parse first state
			tStateDest1 = parsedstate;
			tStateDest2 = "";
			tStateDest3 = "";
			tStateDest4 = "";
			if (Ns_Parser_CheckNext(",", 0)) 
			{
				if (Ns_Parser_ReadArg())
				{
					Menu_ParseState();
					tStateDest2 = parsedstate;
				}
			}
			if (Ns_Parser_CheckNext(",", 0)) 
			{
				if (Ns_Parser_ReadArg())
				{
					Menu_ParseState();
					tStateDest3 = parsedstate;
				}
			}
			if (Ns_Parser_CheckNext(",", 0)) 
			{
				if (Ns_Parser_ReadArg())
				{
					Menu_ParseState();
					tStateDest4 = parsedstate;
				}
			}
			continue;
		}
		
		// parse property
		tMethod = ns_parser_token;
		Ns_Parser_ReadArg();
		
		// precompile events, all events are 'onX' (onHotkey, onTrigger etc.), also runScript
		// cache compiled temp scripts so they can be reused
		if (MenuParser_PrecompileEvents)
		{
			tStartTime = gettime(TIME_UPTIME);
			temp = substring(tMethod, 2, 1);
			if (tMethod == "runScript" || (substring(tMethod, 0, 2) == "on" && temp == strtoupper(temp)))
			{
				// check if already compiled
				temp = ftos(crc16(0, ns_parser_token));
				for (i = 0; i < MenuParser_PrecompileEventsBufLen; i++)
					if (bufstr_get(MenuParser_PrecompileEventsBufCrc, i) == temp) // crc16 matches
						if (bufstr_get(MenuParser_PrecompileEventsBuf, i) == ns_parser_token) // code matches
							break;
				// found?
				if (i < MenuParser_PrecompileEventsBufLen)
				{
					ns_parser_token = bufstr_get(MenuParser_PrecompileEventsBufHandles, i);
					MenuParser_PrecompileEventsOpStat++;
				}
				else
				{
					// compile and cache
					bufstr_set(MenuParser_PrecompileEventsBuf, MenuParser_PrecompileEventsBufLen, ns_parser_token);
					bufstr_set(MenuParser_PrecompileEventsBufCrc, MenuParser_PrecompileEventsBufLen, temp);
					ns_parser_token = ftos(MenuScript_Compile(ns_parser_token));
					if (ns_parser_token == "-1")
						Menu_Parser_Error("Menu_PrecompileEvent: error happened during precompiling of event, parsing stopped\n");	
					else if (MenuScript_CompileWarnings())
						Menu_Parser_Warning("Menu_PrecompileEvent: warnings during precompiling, see compiler warnings above\n");	
					bufstr_set(MenuParser_PrecompileEventsBufHandles, MenuParser_PrecompileEventsBufLen, ns_parser_token);
					MenuParser_PrecompileEventsBufLen++;
					Ns_Parser_RestoreTokens();
				}
			}
			MenuParser_TimeOpts = MenuParser_TimeOpts + (gettime(TIME_UPTIME)-tStartTime);
		}
		
		// add to statemap
		if (tStateDest1 != "")
			Menu_Sys_StateMap_AddMethod(tObject, tStateDest1, tMethod, ns_parser_token);
		if (tStateDest2 != "")
			Menu_Sys_StateMap_AddMethod(tObject, tStateDest2, tMethod, ns_parser_token);
		if (tStateDest3 != "")
			Menu_Sys_StateMap_AddMethod(tObject, tStateDest3, tMethod, ns_parser_token);
		if (tStateDest4 != "")
			Menu_Sys_StateMap_AddMethod(tObject, tStateDest4, tMethod, ns_parser_token);
	}
}

// VorteX: 'With' allows non-linear menu object placement
// and template children editing
void Menu_ParseWith(entity tParent) =
{
	string tName, tMethod;
	entity tObject;
	
	// read item name
	Ns_Parser_ReadArg(); 
	tName = ns_parser_token;
	// find name
	if (!Menu_FindObject(menu_proc, tParent, tName))
	{
		Menu_Parser_Warning(strcat("Menu_ParseWith: cannot find object ", strcat(tParent.name, tName), "\n"));	
		Menu_ParseSkip();
		return;
	}
	// check for remapclass postfix
	if (Ns_Parser_CheckNext("NewClass", 1))
		{ Ns_Parser_ReadToken(); Menu_Sys_SetObjectClass(foundobject, ns_parser_token); }
	if (Ns_Parser_CheckNext("NewName", 1))
		{ Ns_Parser_ReadToken(); Menu_Sys_SetObjectName(foundobject, ns_parser_token); }
	// now expect object body
	Ns_Parser_Expect("{", 1);
	Menu_ParseObjectBody(foundobject);
}

// Packed object states
void Menu_ParseStates(entity tObject) =
{
	string tStateName;

	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		Ns_Parser_ReadToken();
		if (ns_parser_token == "EndStateMap")
			break; 
		tStateName = ns_parser_token;
		Ns_Parser_ReadToken();
		Menu_Sys_StateMap_Set(tObject, tStateName, ns_parser_token);
	}
}

// scripts
void Menu_ParseScript(float externaldefinition) =
{
	float numlines, numparms;
	string scriptname, scriptparms, scriptbody;
	
	// function name
	Ns_Parser_ReadToken();
	scriptname = ns_parser_token;
	if (scriptname == "")
		Menu_Parser_Error("Menu_ParseScript: bad script name\n");	

	// read parms
	Ns_Parser_Expect("(", 1);
	scriptparms = newlump();
	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		Ns_Parser_ReadToken();
		if (ns_parser_token == ",") // skip ,
			continue;
		if (ns_parser_token == ")")
			break;

		scriptparms = poplump(scriptparms, ns_parser_token);
		numparms++;	
	}
	if (numparms > NCD_MAX_PARMS)
		Menu_Parser_Warning(strcat("Menu_ParseScript: to many parms on script '", scriptname, "' - ", ftos(numparms), ", parmstring will be truncated to NCD_MAX_PARMS = ", ftos(NCD_MAX_PARMS)));
	
	// parse body
	if (!externaldefinition) 
	{
		Ns_Parser_Expect("{", 1);
		while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			Ns_Parser_ReadToken();
			if (ns_parser_token == "}")
			{
				numlines--;
				if (numlines < 0)
					break;
				continue; 
			}
			scriptbody = strcat(scriptbody, " ", strmaketoken(ns_parser_token));
			if (ns_parser_token == "{")
				numlines++;
		}
	}
	
	// warn redefinition
	//if (MenuScript_FindFunction(scriptname))
	//	Menu_Parser_Warning(strcat("Menu_ParseScript: script '", scriptname, "' redefined"));
	
	// add script
	MenuScript_CreateFunction(scriptname, scriptbody, scriptparms);
}

// script global(s)
void Menu_ParseGlobal(float many) =
{
	string globalname, globalvalue;
	
	// many globals
	if (many)
	{
		Ns_Parser_Expect("{", 1);
		while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
		{
			Ns_Parser_ReadToken();
			if (ns_parser_token == "}")
				return;
			globalname = ns_parser_token;
			if (!Ns_Parser_CheckNext("=", 1))
				globalvalue = "";
			else
			{
				Ns_Parser_ReadToken();
				globalvalue = ns_parser_token;
			}
			MenuScript_SetGlobal(globalname, globalvalue);
		}
		return;
	}
	// single global
	Ns_Parser_ReadToken();
	globalname = ns_parser_token;
	if (!Ns_Parser_CheckNext("=", 1))
		globalvalue = "";
	else
	{
		Ns_Parser_ReadToken();
		globalvalue = ns_parser_token;
	}
	MenuScript_SetGlobal(globalname, globalvalue);
}

float Menu_ParseGeneric(entity tParent)
{
	string tStateName;
	entity tObject;
	
	if (ns_parser_token == "Item")
	{
		Menu_ParseNewObject(tParent, 0);
		return 1;
	}
	if (ns_parser_token == "Template")
	{
		tObject = Menu_ParseNewObject(tParent, 1);
		return 1;
	}
	if (ns_parser_token == "DeriveStatic")
	{
		tObject = Menu_ParseDerivedObject(tParent, 0, 0);
		return 1;
	}
	if (ns_parser_token == "Derive")
	{
		tObject = Menu_ParseDerivedObject(tParent, 0, 1);
		return 1;
	}
	if (ns_parser_token == "DeriveTemplateStatic")
	{
		tObject = Menu_ParseDerivedObject(tParent, 1, 0);
		return 1;
	}
	if (ns_parser_token == "DeriveTemplate")
	{
		tObject = Menu_ParseDerivedObject(tParent, 1, 1);
		return 1;
	}
	if (ns_parser_token == "With")
	{
		Menu_ParseWith(tParent);
		return 1;
	}
	if (ns_parser_token == "StateMap")
	{
		Menu_ParseStates(tParent);
		return 1;
	}
	if (ns_parser_token == "Extern")
	{
		Menu_ParseScript(1);
		return 1;
	}
	if (ns_parser_token == "Script")
	{
		Menu_ParseScript(0);
		return 1;
	}
	if (ns_parser_token == "Global")
	{
		Menu_ParseGlobal(0);
		return 1;
	}
	if (ns_parser_token == "Globals")
	{
		Menu_ParseGlobal(1);
		return 1;
	}
	return 0;
}

void Menu_Precache(string filename)
{
	// VorteX: loadpic not persistent, thats bad
	drawpic('0 0 0', filename, '1 1 0', '1 1 1', 0.01, 0);
//	loadpic(filename);
}

void() Menu_ParseOption =
{
	vector v;
	
	Ns_Parser_ReadArg();
	if (ns_parser_token == "CoordSpace")
	{
		Ns_Parser_ReadArg();
		v = stov(ns_parser_token);
		if (v_x <= 0 || v_y <= 0)
		{
			v = '1024 768 0';
			Menu_Parser_Warning(strcat("Menu_ParseCoordSpace(", ns_parser_token, "): bad coordspace resolution, restoring default '1024 768'"));
		}
		Menu_Sys_SetProcCoordSpace(menu_proc, v);
		return;
	}
	if (ns_parser_token == "ScreenResAdaptation")
	{
		Ns_Parser_ReadArg();
		Menu_Sys_SetProcScreenResAdaptation(menu_proc, ns_parser_token);
		return;
	}
	if (ns_parser_token == "UseMouse")
	{
		Ns_Parser_ReadArg();
		Menu_Sys_SetProcMouse(menu_proc, stof(ns_parser_token));
		return;
	}
	if (ns_parser_token == "MouseCursor")
	{
		Ns_Parser_ReadArg();
		Menu_Sys_SetProcMousecursor(menu_proc, ns_parser_token);
		return;
	}
	if (ns_parser_token == "PrecompileEvents")
	{
		Ns_Parser_ReadArg();
		MenuParser_PrecompileEvents = stof(ns_parser_token);
		return;
	}
	if (ns_parser_token == "ShowStats")
	{
		MenuParser_ShowStats = 1;
		return;
	}
	Menu_Parser_Warning(strcat("Menu_ParseOption: unknown option '", ns_parser_token, "'"));
}

void() Menu_ParseCreateFont =
{
	string tFontName, tLine;
	float tBuf;
	
	Ns_Parser_ReadArg();
	tFontName = ns_parser_token;
	if (!Ns_Parser_Expect("{", 1))
		return;
	tBuf = buf_create();
	while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
	{
		if (Ns_Parser_CheckNext("}", 1))
			break;
		Ns_Parser_ReadToken(1);
		tLine = strquickmaketoken(ns_parser_token);
		while(Ns_Parser_ReadOptionalArg())
			tLine = strcat(tLine, " ", strquickmaketoken(ns_parser_token));
		bufstr_add(tBuf, tLine, 1);
	}
	// load font
	Draw2D_LoadFontFromBuffer(1, "", tFontName, tBuf);
}

void() Menu_Parse =
{
	if (ns_parser_token == "Option")
	{
		Menu_ParseOption();
		return;
	}
	if (ns_parser_token == "CreateFont")
	{
		Menu_ParseCreateFont();
		return;
	}
	if (ns_parser_token == "Precache")
	{
		Ns_Parser_ReadToken();
		if (ns_parser_token != "{")
			Menu_Precache(ns_parser_token);
		else
		{
			while(ns_parser_errorcode == NS_PARSER_ERROR_NO)
			{
				Ns_Parser_ReadToken();
				if (ns_parser_token == "{")
				{
					Menu_Parser_Warning("Menu_ParseScript: { unexpected");
					continue;
				}
				if (ns_parser_token == "}")
					break;
				Menu_Precache(ns_parser_token);
			}
		}
		return;
	}
	if (Menu_ParseGeneric(menu_parser_parent))
		return;
	Ns_Parser_Warning(strcat("Menu_Parse: unknown token '", ns_parser_token, "'"));
}

void() Menu_Parser =
{
	ns_parser_pparse = Menu_Parse;
}

/*
===================================================

 API

===================================================
*/

void() Menu_InitParser =
{
}

float Menu_LoadFromFile(entity tParent, string tFile, float tQuiet)
{
	entity tObject;
	float tParsed, tStartTime;

	tStartTime = gettime(TIME_UPTIME);
	menu_parser_templates = null_entity;
	menu_parser_parent = tParent;
	// parser props, init counters
	MenuParser_ShowStats = 0;
	MenuParser_PrecompileEvents = 1;
	MenuParser_PrecompileEventsBuf = buf_create();
	MenuParser_PrecompileEventsBufCrc = buf_create();
	MenuParser_PrecompileEventsBufHandles = buf_create();
	MenuParser_PrecompileEventsBufLen = 0;
	MenuParser_PrecompileEventsOpStat = 0;
	MenuParser_TimeOpts = 0;
	// parse objects
	tParsed = Ns_ParseFile(tFile, Menu_Parser, 0);
	// remove temporaries
	tObject = findflags(null_entity, mFlags, MENU_FLAG_TEMPORARY);
	while(tObject)
	{
		Menu_Sys_DestroyObject(tObject);
		tObject = findflags(tObject, mFlags, MENU_FLAG_TEMPORARY);
	}
	buf_del(MenuParser_PrecompileEventsBuf);
	buf_del(MenuParser_PrecompileEventsBufCrc);
	buf_del(MenuParser_PrecompileEventsBufHandles);
	// show stats
	if (MenuParser_ShowStats)
	{
		print("--- Parsing stats ---\n");
		print("  File: ", tFile, "\n");
		print("  Events reused: ", ftos(MenuParser_PrecompileEventsOpStat), "\n");
		print("  Time spended on Opts: ", ftos(MenuParser_TimeOpts), "s\n");
		print("  Total Time: ", ftos((gettime(TIME_UPTIME)-tStartTime)*1000), "s\n");	
		print("--- End of stats ---\n");
	}
	return tParsed;
}