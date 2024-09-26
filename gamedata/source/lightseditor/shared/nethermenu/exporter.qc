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

entity menu_export_proc;
string menu_export_filename;	// file name
float menu_export_filehandle;	// file pointer
float menu_export_filesize; 	// filesize (for stats)
float menu_export_objects; 		// number of exported objects
float menu_export_methods; 		// number of exported methods
float menu_export_packed; 		// statemaps are packed into lumpstrings (lower tempstring usage when load)
// NS2 exporter specifics
float menu_export_script_bw;
// QC exporter specifics
float menu_export_qc_objlevels; 
float menu_export_qc_templatepass;

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
===================================================

 EXPORTER GENERIC

===================================================
*/

float Menu_ExportInit(string tProcName, string tFileName)
{
	// find proc
	if (!Menu_Sys_FindProc(tProcName))
	{
		Menu_Warning(null_entity, strcat("Menu_Export_Init: proc '", tProcName, "' not found!"));
		menu_export_objects = -1;
		return 0;
	}
	menu_export_proc = foundproc;
	// try to open file
	menu_export_objects = 0;
	menu_export_methods = 0;
	menu_export_filehandle = fopen(tFileName, FILE_WRITE);
	menu_export_filename = tFileName;
	menu_export_filesize = 0;
	if (menu_export_filehandle < 0)
	{
		Menu_Warning(null_entity, strcat("Menu_Export_Init: failed to open '", tFileName, "' for writing!"));
		menu_export_objects = -1;
		return 0;
	}
	return 1; // all ok
}

void() Menu_ExportShutdown =
{
	fclose(menu_export_filehandle);
	print(strcat(ftos(menu_export_filesize), " bytes written to data/", menu_export_filename, ".\n"));
}

void Menu_ExportWrite(string tStr)
{
	menu_export_filesize = menu_export_filesize + strlen(tStr) + 1;
	fputs(menu_export_filehandle, tStr);
	fputs(menu_export_filehandle, "\n");
}

/*
===================================================

 EXPORTER TO SCRIPT FILE

===================================================
*/

void Menu_ExportScript_Write(string tStr)
{
	Menu_ExportWrite(tStr);
	// VorteX: a trick when writing states to netherscript to not write :normal right after {
	menu_export_script_bw = 0; 
}

void Menu_ExportScript_StateMap(entity tObject, string tSpacers, string tStateName, string tStateMap)
{
	float tPos, tLen, tChunkLen;
	string tMethod, tValue;
	
	// packed map!
	if (menu_export_packed)
	{
		Menu_ExportScript_Write(strcat(tSpacers, "	", strmaketoken(tStateName), " ", strmaketoken(tStateMap)));
		return;
	}
	// write map name
	if (!((menu_export_script_bw == 1) && tStateName == ":normal"))
		Menu_ExportScript_Write(strcat(tSpacers, tStateName));
	// cycle all methods in map
	tLen = strlen(tStateMap);
	tPos = lumpstart(tStateMap);
	while(tPos < tLen)
	{
		menu_export_methods++;
		// read method
		tChunkLen = lumpchunk(tStateMap, tPos);
		tMethod = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// read value
		tChunkLen = lumpchunk(tStateMap, tPos);
		tValue = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// write method
		Menu_ExportScript_Write(strcat(tSpacers, "	", strmaketoken(tMethod), " ", strmaketoken(tValue)));
	}
}

void Menu_ExportScript_Object(entity tObject, string tSpacers) =
{
	float tNumStates, tPos;
	string tStr, tName;
	entity tChild;
	
	menu_export_objects++;
	// write object
	tNumStates = Menu_Sys_StateMap_NumStates(tObject);
	if (tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE)
	{
		if (isentity(tObject._template))
			Menu_ExportScript_Write(strcat(tSpacers, "DeriveTemplate ", strmaketoken(tObject._template.localname), " ", strmaketoken(tObject.localname)));
		else
			Menu_ExportScript_Write(strcat(tSpacers, "Template ", strmaketoken(tObject.classname), " ", strmaketoken(tObject.localname)));
	}
	else if (isentity(tObject._template))
		Menu_ExportScript_Write(strcat(tSpacers, "Derive ", strmaketoken(tObject._template.localname), " ", strmaketoken(tObject.localname)));
	else 
		Menu_ExportScript_Write(strcat(tSpacers, "Item ", strmaketoken(tObject.classname), " ", strmaketoken(tObject.localname)));
	Menu_ExportScript_Write(strcat(tSpacers, "{"));
	menu_export_script_bw = 1;
	// write states
	if (tNumStates)
	{
		// write packed header
		if (menu_export_packed)
			Menu_ExportScript_Write(strcat(tSpacers, "	StateMap"));
		#define try(n,m)  if (tObject.n != null_string) Menu_ExportScript_StateMap(tObject, tSpacers, tObject.n, tObject.m);
		TryAllStatemaps
		#undef try
		// write packed footer
		if (menu_export_packed)
			Menu_ExportScript_Write(strcat(tSpacers, "	EndStateMap"));
	}
	// write children		
	for (tChild = tObject._child; tChild; tChild = tChild._next)
		Menu_ExportScript_Object(tChild, strcat(tSpacers, "	"));
	// end-of-object
	Menu_ExportScript_Write(strcat(tSpacers, "}"));
}

// export process as .NS2 script file
void Menu_ExportScript(string tProcName, string tFileName, float tPacked) =
{
	string tSpacer;
	entity tChild;
	
	// init
	print("Exporting NetherScript 2.0...\n");
	if (!Menu_ExportInit(tProcName, tFileName))
		return;
	if (tPacked)
		print("Enabling statemaps packing\n");
	menu_export_packed = tPacked;
	menu_export_script_bw = 0;
	// begin proc
	tSpacer = "";
	Menu_ExportScript_Write("////////////////////////////////////////");
	Menu_ExportScript_Write("// OPTIONS");
	Menu_ExportScript_Write("////////////////////////////////////////");
	Menu_ExportScript_Write(strcat("CoordSpace ", vtos(Menu_Sys_GetProcCoordSpace(menu_export_proc))));
	Menu_ExportScript_Write("");
	Menu_ExportScript_Write("////////////////////////////////////////");
	Menu_ExportScript_Write("// OBJECTS");
	Menu_ExportScript_Write("////////////////////////////////////////");
	// export all objects
	for (tChild = menu_export_proc._child; tChild; tChild = tChild._next)
		Menu_ExportScript_Object(tChild, tSpacer);
	// shutdown exporter
	Menu_ExportShutdown();
}

/*
===================================================

 QUAKEC EXPORTER

===================================================
*/

void Menu_ExportQC_Write(string tStr)
{
	Menu_ExportWrite(tStr);
}

void Menu_ExportQC_StateMap(entity tObject, string tVarName, string tSpacers, float tLevel, string tStateName, string tStateMap)
{
	float tPos, tLen, tChunkLen;
	string tMethod, tValue;
	
	// packed variant
	if (menu_export_packed)
	{
		Menu_ExportQC_Write(strcat(tSpacers, "	map(", tVarName, ", \"", tStateName, "\", \"", tStateMap, "\");"));
		return;
	}
	// write state header
	if (tStateName != ":normal")
		Menu_ExportQC_Write(strcat(tSpacers, "map(\"", tStateName, "\")"));
	// cycle all methods in map
	tLen = strlen(tStateMap);
	tPos = lumpstart(tStateMap);
	while(tPos < tLen)
	{
		menu_export_methods++;
		// read method
		tChunkLen = lumpchunk(tStateMap, tPos);
		tMethod = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// read value
		tChunkLen = lumpchunk(tStateMap, tPos);
		tValue = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// write method
		tStateName = strreplace("\n", "\\n", tStateName);
		tStateName = strreplace("\"", "\\\"", tStateName);
		tMethod = strreplace("\n", "\\n", tMethod);
		tMethod = strreplace("\"", "\\\"", tMethod);
		tValue = strreplace("\n", "\\n", tValue);
		tValue = strreplace("\"", "\\\"", tValue);
		Menu_ExportQC_Write(strcat(tSpacers, "	prop(", tVarName, ", \"", strcat(tMethod, "\", \"", tValue, "\");")));
	}
}

float() Menu_ExportQC_CountTemplates =
{
	entity tObject;
	float tCount;
	for (tObject = findentity(null_entity, _proc, menu_export_proc); tObject; tObject =  findentity(tObject, _proc, menu_export_proc))
		if (tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE)
			tCount = tCount + 1;
	return tCount;
}

string Menu_ExportQC_TemplateVarForEnt(entity tTemplate) =
{
	entity tObject;
	float tCount;
	string tStr;
	
	tStr = "#ERROR#";
	for (tObject = findentity(null_entity, _proc, menu_export_proc); tObject; tObject =  findentity(tObject, _proc, menu_export_proc))
	{
		if (tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE)
			tCount = tCount + 1;
		if (tObject == tTemplate)
		{
			tStr = strcat("tTp", ftos(tCount));
			break;
		}
	}
	return tStr;
}

void Menu_ExportQC_Object(entity tObject, string tParentName, string tSpacers, float tLevel, float tTemplate) =
{
	float tNumStates, tPos;
	string tStr, tName, tLocaName;
	entity tChild;
	
	// discard templates for normal pass for QUAKE
	if ((tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE) && !menu_export_qc_templatepass)
		return; 
	// enlarge levels?
	tLevel++;
	if (tLevel > menu_export_qc_objlevels)
	{
		tStr = strcat(tSpacers, "entity tItem", ftos(tLevel));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+1));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+2));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+3));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+4));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+5));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+6));
		tStr = strcat(tStr, ", tItem", ftos(tLevel+7), ";");
		Menu_ExportQC_Write(tStr);
		menu_export_qc_objlevels = menu_export_qc_objlevels + 8;
	}
	menu_export_objects++;
	// write object
	tNumStates = Menu_Sys_StateMap_NumStates(tObject);
	tStr = tObject.name;
	tPos = strstr(tObject.name, "::");
	if (tPos >= 0)
		tStr = substring(tStr, tPos+2, 10000);
	tStr = strcat("// ", tStr); // name of object as comment
	// get localname and name of object
	tLocaName = strreplace("\n", "\\n", tObject.localname);
	tLocaName = strreplace("\"", "\\\"", tLocaName);
	if (tTemplate)
		tName = Menu_ExportQC_TemplateVarForEnt(tObject);
	else
		tName = strcat("tItem", ftos(tLevel));
	// write line of object constructing
	if (isentity(tObject._template))
		tStr = strcat(tSpacers, tName, " = tpl(", Menu_ExportQC_TemplateVarForEnt(tObject._template), ", \"", tLocaName, strcat("\", ", tParentName , ");", tStr));
	else
		tStr = strcat(tSpacers, tName, " = new(\"", tObject.classname, "\", \"", tLocaName, strcat("\", ", tParentName , ");", tStr));
	Menu_ExportQC_Write(tStr);
	// write template flags
	if (tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE)
		Menu_ExportQC_Write(strcat(tSpacers, tName, ".mRunFlags = ", tName, ".mRunFlags | MENU_RUNFLAG_TEMPLATE;"));
	// write states
	if (tNumStates)
	{
		#define try(n,m)  if (tObject.n != null_string) Menu_ExportQC_StateMap(tObject, tName, tSpacers, tLevel, tObject.n, tObject.m);
		TryAllStatemaps
		#undef try
	}
	// write children		
	for (tChild = tObject._child; tChild; tChild = tChild._next)
		Menu_ExportQC_Object(tChild, tName, strcat(tSpacers, "	"), tLevel, 0);
}

void Menu_ExportQC_Template(entity tObject) =
{
	entity tChild;
	
	// if object is template - export it with children
	if (tObject.mRunFlags & MENU_RUNFLAG_TEMPLATE)
	{
		Menu_ExportQC_Object(tObject, "null_entity", "	", 0, 1);
		return;
	}
	// continue search
	for (tChild = tObject._child; tChild; tChild = tChild._next)
		Menu_ExportQC_Template(tChild);
}

// export process as .QC file
void Menu_ExportQC(string tProcName, string tFileName, float tPacked) =
{
	float tNumTemplates, tPos, tTpl;
	entity tChild;
	string tStr;
	
	// init
	print("Exporting QuakeC...\n");
	if (!Menu_ExportInit(tProcName, tFileName))
		return;
	if (tPacked)
		print("Enabling statemaps packing\n");
	menu_export_packed = tPacked;
	menu_export_qc_objlevels = 0;
	menu_export_qc_templatepass = 0;
	// begin proc
	tNumTemplates = Menu_ExportQC_CountTemplates();
	Menu_ExportQC_Write(strcat("void() ", menu_export_proc.name, "SpawnObjects = "));
	Menu_ExportQC_Write("{");
	if (!menu_export_packed)
	{
		Menu_ExportQC_Write("	string tNormal = \":normal\";");
		Menu_ExportQC_Write("	string tState;");
		Menu_ExportQC_Write("");
	}
	Menu_ExportQC_Write(strcat("	Menu_Sys_SetProcCoordSpace(menu_proc, ", vtos(Menu_Sys_GetProcCoordSpace(menu_export_proc)), ");"));
	if (menu_export_packed)
	{
		Menu_ExportQC_Write("	#define new(c,n,p) Menu_Sys_NewObject(menu_proc,c,n,p)");
		if (tNumTemplates)
			Menu_ExportQC_Write("	#define tpl(t,n,p) Menu_Sys_CloneObject(t,n,p,1)");
		Menu_ExportQC_Write("	#define map Menu_Sys_StateMap_Set");
	}
	else
	{
		Menu_ExportQC_Write("	#define new(c,n,p) Menu_Sys_NewObject(menu_proc,c,n,p); tState = tNormal");
		if (tNumTemplates)
			Menu_ExportQC_Write("	#define tpl(t,n,p) Menu_Sys_CloneObject(t,n,p,1); tState = tNormal");
		Menu_ExportQC_Write("	#define prop(o,m,v) Menu_Sys_StateMap_AddMethod(o,tState,m,v)");
		Menu_ExportQC_Write("	#define map(n) tState = n;");
	}
	if (tNumTemplates)
	{
		Menu_ExportQC_Write("	// TEMPLATES");
		// template entities header
		tStr = "	entity ";
		for (tPos = 1, tTpl = 0; tPos <= tNumTemplates; tPos++, tTpl++)
		{
			if (tTpl > 0)
				tStr = strcat(tStr, ", tTp", ftos(tPos));
			else
				tStr = strcat(tStr, "tTp", ftos(tPos));
			if (tTpl == 7)
			{
				tStr = strcat(tStr, ";");
				Menu_ExportQC_Write(tStr);
				tStr = "	entity ";
				tTpl = -1;
			}
		}
		if (tTpl > 0)
		{
			tStr = strcat(tStr, ";");
			Menu_ExportQC_Write(tStr);
		}
		// export templates
		menu_export_qc_templatepass = 1;
		for (tChild = menu_export_proc._child; tChild; tChild = tChild._next)
			Menu_ExportQC_Template(tChild);
		menu_export_qc_templatepass = 0;
	}
	// export all objects
	Menu_ExportQC_Write("	// OBJECTS");
	for (tChild = menu_export_proc._child; tChild; tChild = tChild._next)
		Menu_ExportQC_Object(tChild, "null_entity", "	", 0, 0);
	// undef stuff and end function
	Menu_ExportQC_Write("	#undef new");
	if (tNumTemplates)
		Menu_ExportQC_Write("	#undef tpl");
	if (menu_export_packed)
		Menu_ExportQC_Write("	#undef map");
	else
	{
		Menu_ExportQC_Write("	#undef prop");
		Menu_ExportQC_Write("	#undef map");
	}
	Menu_ExportQC_Write("}");
	// shutdown exporter
	Menu_ExportShutdown();
}

/*
===================================================

 COMMANDS

===================================================
*/

command Cmd_ExportMenuProcess_Script =
{
	if (is_help || numparms < 2)
	{
		print(strcat("usage: ", commandname, " <procname> <filename>\n"));
		return;
	}
	Menu_ExportScript(argv(1), argv(2), 0);
}

command Cmd_ExportMenuProcess_ScriptPacked =
{
	string tFileName, tProcName;
	if (is_help || numparms < 2)
	{
		print(strcat("usage: ", commandname, " <procname> <filename>\n"));
		return;
	}
	Menu_ExportScript(argv(1), argv(2), 1);
}

command Cmd_ExportMenuProcess_QuakeC =
{
	if (is_help || numparms < 2)
	{
		print(strcat("usage: ", commandname, " <procname> <filename>\n"));
		return;
	}
	Menu_ExportQC(argv(1), argv(2), 0);
}

command Cmd_ExportMenuProcess_QuakeCPacked =
{
	if (is_help || numparms < 2)
	{
		print(strcat("usage: ", commandname, " <procname> <filename>\n"));
		return;
	}
	Menu_ExportQC(argv(1), argv(2), 1);
}

/*
===================================================

 API

===================================================
*/

void() Menu_InitExporter =
{
	RegisterCommand("mdev_procexport_script", Cmd_ExportMenuProcess_Script, "export process entities to script file");
	RegisterCommand("mdev_procexport_scriptpacked", Cmd_ExportMenuProcess_ScriptPacked, "export process entities to packed script file (states will be written as methods)");
	RegisterCommand("mdev_procexport_qc", Cmd_ExportMenuProcess_QuakeC, "export process entities to qc file");
	RegisterCommand("mdev_procexport_qcpacked", Cmd_ExportMenuProcess_QuakeCPacked, "export process entities to packed qc file (states will be written as methods)");
}






