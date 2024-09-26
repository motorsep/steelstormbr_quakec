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

entity menu_debug_process;
entity menu_debug_findstartobject;
float menu_debug;	// true if debug is allowed
float menu_debug_area;
float menu_debug_mouse;
float menu_debug_select;
float menu_debug_key;
float menu_debug_hotkey;
float menu_debug_trigger;
float menu_debug_script;

////////////////////////////////////////
// CODE
////////////////////////////////////////

void Menu_Debugger_NewClass(entity tNewClass) =
{
	Menu_Debugger_Log(strcat("Class '", tNewClass.localname, "' is registered as '", tNewClass.name, "'"));
}

/*
================================================================================

   DEBUGGER OBJECTS

================================================================================
*/

void Object_DebuggerQFont_DrawGridCell(vector tPos, vector tSize, vector tBorder, float tHorzIndex, float tVertIndex) =
{
	Draw2D_SetArea(tSize, MENU_ALIGN_TOPCENTER, DRAW2D_TOPLEFT);
	Draw2D_DrawText(tPos, chr2str(tVertIndex*16 + tHorzIndex), Draw2D_FontProcessor.name, tSize, '1 1 1', 1, DRAW2D_ALIGN);
}

void() Object_DebuggerFont_Draw =
{
	vector tGridSize, tGridBorder;
	
	tGridSize_x = self._size_x/16;
	tGridSize_y = self._size_y/16;
	tGridBorder_x = 2*self._scale_x;
	tGridBorder_y = 2*self._scale_y;
	// draw background
	ObjectLib_Background_Draw();
	// draw font grid
	if (self.textFont != "")
		Draw2D_SetFont(self.textFont);
	if (Draw2D_FontProcessor.classname == "Conchars")
	{
		ObjectLib_Picture_Draw();
		Draw2D_DrawGrid(self._absmin, tGridSize, tGridBorder, self._size, '1 1 1', 1, 0, Null_GridCellDraw);
	}
	else
		Draw2D_DrawGrid(self._absmin, tGridSize, tGridBorder, self._size, '1 1 1', 1, 0, Object_DebuggerQFont_DrawGridCell);
	ObjectLib_Foreground_Draw();
}

void() Object_DebuggerFont_Spawn =
{
	self.mDraw = Object_DebuggerFont_Draw;
}

void() Object_DebuggerFont_Init =
{
}

void() Object_DebuggerFont =
{
	className = "DebuggerFont";
	classInit = Object_DebuggerFont_Init;
	classSpawn = Object_DebuggerFont_Spawn;
}

/*
================================================================================

   DEBUGGER PROCESS

================================================================================
*/

void() DebuggerProc =
{
	entity tDrawSpace;
	entity tObject;
	
	// register classes
	Menu_Sys_RegisterClass(menu_proc, Object_DebuggerFont);
	Menu_Sys_SetProcCoordSpace(menu_proc, vec2(640, 480));
	Menu_Sys_SetProcFlags(menu_proc, MENU_PROCFLAG_HIDDEN);
	// spawn objects
	tDrawSpace = Menu_Sys_NewObject(menu_proc, "DrawSpace", "FontView", null_entity);
		tObject = Menu_Sys_NewObject(menu_proc, "DebuggerFont", "Painter", tDrawSpace);
		tObject.setMethod(tObject, MMA_SET, "size", vtos('256 256 0'));
		tObject.setMethod(tObject, MMA_SET, "align", vtos(MENU_ALIGN_MIDCENTER));
		tObject.setMethod(tObject, MMA_SET, "align", vtos('1.5 1.5 1.5'));
		tObject.setMethod(tObject, MMA_SET, "picture", "gfx/conchars");
		tObject.setMethod(tObject, MMA_SET, "bgAlpha", "1");
}

// enable/disable font debugger
void Menu_Debugger_ViewFont(string tFontName)
{
	entity tObject;
	
	// find process and object
	menu_proc = Menu_Sys_GetProc("Debugger");
	if (tFontName == "-")
	{
		Menu_Sys_SetProcFlags(menu_proc, MENU_PROCFLAG_HIDDEN);
		return;
	}
	
	Menu_Sys_SetProcFlags(menu_proc, 0);
	Draw2D_LoadFont(tFontName);
	Draw2D_SetFont(tFontName);
	tObject = Menu_GetItem("::FontView:Painter");
	tObject.setMethod(tObject, MMA_SET, "textFont", tFontName);
}


/*
================================================================================

   DRAW DEBUGGER

================================================================================
*/

float menu_debugger_drawareapos;

// draw object and it's children
void Menu_Debugger_ObjectDrawArea(entity tObject)
{
	entity tChild;
	vector tColor;

	menu_debugger_drawareapos++;
	if (menu_debugger_drawareapos > 100)
		menu_debugger_drawareapos = 0;

	// don't draw hidden or nodraw
	if (menu_debug_area < 2)
		if ((tObject.mFlags & (MENU_FLAG_HIDDEN | MENU_FLAG_NODRAW)))
			return;
	// draw area
	if (menu_debug_area)
	{
		tColor_x = anglemod(menu_debugger_drawareapos*60);
		tColor_y = anglemod(menu_debugger_drawareapos*90);
		tColor_z = anglemod(menu_debugger_drawareapos*120);
		tColor = normalize(tColor);
		tColor = tColor*0.75 + '0.25 0.25 0.25';
		Draw2D_DrawFill(tObject._absmin, tObject._size, tColor, 0.1, DRAW2D_ADDITIVE);
		menu_debugger_drawareapos = menu_debugger_drawareapos + 1;
	}
	// draw selected
	if (menu_debug_select)
	{
		if (tObject._proc.focus == tObject)
			Draw2D_DrawFill(tObject._absmin, tObject._size, '1 0 0', 1, DRAW2D_ADDITIVE);
	}
	// draw children
	if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
		for (tChild = tObject._child; tChild; tChild = tChild._next)
			Menu_Debugger_ObjectDrawArea(tChild);
}

void() Menu_Debugger_DrawAreas =
{
	entity tChild;
	
	menu_debugger_drawareapos = 0;
	for (tChild = menu_debug_process._child; tChild; tChild = tChild._next)
		Menu_Debugger_ObjectDrawArea(tChild);
}

void() Menu_Debugger_DrawMouse =
{
	Draw2D_DrawFill(menu_proc.mousePos - '1 1 0', '12 12 0', '1 1 1', 1, 0);
	Draw2D_DrawFill(menu_proc.mousePos, '10 10 0', '1 0 0', 1, 0);
}

/*
================================================================================

   KEY DEBUGGER

================================================================================
*/

void Menu_Debugger_KeyEvent(float event, float parama, float result) =
{
	string tStr;
	
	if (isnotentity(menu_debug_process))
		return;
	if (!menu_debug_key)
		return;
	if (menu_debug_process.name != 	menu_proc.name)
		return;
	if (menu_debug_key < 2 && !result)
		return;
		
	if (event == KEYEVENT_HOLD)
		tStr = "^3Menu_Key^7: HOLD ";
	else
		tStr = "^3Menu_Key^7: RELEASE ";
	tStr = strcat(tStr, ftos(parama));
	tStr = strcat(tStr, "(", chr2str(parama), ") on ", self.name);
	tStr = strcat(tStr, " = ", ftos(result), "\n");
	print(tStr);
}

string Menu_Debugger_PrintKey(float tKeyNum)
{
	return strcat(ftos(tKeyNum), "-", keynumtostring(tKeyNum));
}

void Menu_Debugger_HotkeyEvent(float event, float parama, float result, float returncode) =
{
	if (isnotentity(menu_debug_process))
		return;
	if (!menu_debug_hotkey)
		return;
	if (menu_debug_process.name != 	menu_proc.name)
		return;

	if (result)
		print("^3Menu_HotKey ", Menu_Debugger_PrintKey(parama), ": accept on "); 
	else if (menu_debug_hotkey > 1)
		print("^3Menu_HotKey ", Menu_Debugger_PrintKey(parama), ": reject on ");
	if (menu_debug_hotkey > 2)
		print(self.name, "(", self.hotkey, ") : ");
	else	
		print(self.localname, "(", self.hotkey, ") : ");
	// print statemap
	if (Menu_Sys_CheckHotkeyState(self._hotkey1))
		print("^2",Menu_Debugger_PrintKey(self._hotkey1),"^3");
	else
		print("^1",Menu_Debugger_PrintKey(self._hotkey1),"^3");
	if (self._hotkey2)
	{	
		if (Menu_Sys_CheckHotkeyState(self._hotkey2))
			print("+^2",Menu_Debugger_PrintKey(self._hotkey2),"^3");
		else
			print("+^1",Menu_Debugger_PrintKey(self._hotkey2),"^3");
	}		
	if (self._hotkey3)
	{
		if (Menu_Sys_CheckHotkeyState(self._hotkey3))
			print("+^2",Menu_Debugger_PrintKey(self._hotkey3),"^3");
		else
			print("+^1",Menu_Debugger_PrintKey(self._hotkey3),"^3");
	}
	print("\n");
}

/*
================================================================================

   TRIGGER DEBUGGER

================================================================================
*/

void Menu_Debugger_TriggerCast(entity tObject)
{
	if (isnotentity(menu_debug_process))
		return;
	if (!menu_debug_trigger)
		return;
	if (tObject._proc.name != menu_debug_process.name) // todo: if call object from another proc via static link?
		return;
	print("^3TriggerCast^7: ", tObject.name, "\n");
}

/*
================================================================================

   MENU SCRIPT DEBUGGER

================================================================================
*/

void Menu_Debug_CompiledMenuScript(float buf) =
{
	float s, statements;
	
	if (isnotentity(menu_debug_process))
		return;
	if (!menu_debug_script)
		return;
	if (menu_proc.name != menu_debug_process.name) // todo: if call object from another proc via static link?
		return;
	if (buf < 0)
		return;
		
	print("=== CompiledMenuScript ===\n");
	statements = buf_getsize(buf);
	for (s = 0; s < statements; s++)
		print(bufstr_get(buf, s), "\n");
	print("=== End ===\n");
}

void Menu_Debug_ExecMenuScript(float buf, string result)  =
{
	float s, statements;
	
	if (isnotentity(menu_debug_process))
		return;
	if (!menu_debug_script)
		return;
	if (menu_proc.name != menu_debug_process.name) // todo: if call object from another proc via static link?
		return;
	if (buf < 0)
		return;
		
	print("=== ExecutedMenuScript ===\n");
	statements = buf_getsize(buf);
	for (s = 0; s < statements; s++)
		print(bufstr_get(buf, s), "\n");
	print("Returned: ", result, "\n");		
	print("=== End ===\n");	
}

/*
================================================================================

   COMMANDS

================================================================================
*/

// custom structure printing
void MenuDebugger_PrintStructure(entity tChild, .string tNameField, .entity tChildField, string tTab, float tPrintChildLevels)
{
	while(tChild)
	{
		print(tTab, tChild.tNameField, "\n");
		if (isentity(tChild.tChildField) && tPrintChildLevels > 0)
		{
			print(tTab, "{\n");
			MenuDebugger_PrintStructure(tChild.tChildField, tNameField, tChildField, strcat("  ", tTab), tPrintChildLevels - 1);
			print(tTab, "}\n");
		}
		tChild = tChild._next;
	}
}

// object structure printing
void MenuDebugger_PrintObjects(entity tChild, string tTab, float tPrintChildLevels)
{
	while(tChild)
	{
		print(tTab, tChild.classname, " ", tChild.localname, "\n");
		if (isentity(tChild._child) && tPrintChildLevels > 0)
		{
			print(tTab, "{\n");
			MenuDebugger_PrintObjects(tChild._child, strcat("  ", tTab), tPrintChildLevels - 1);
			print(tTab, "}\n");
		}
		tChild = tChild._next;
	}
}

// count entities for proc
float MenuDebugger_PrintProcInfo_CountChildren(entity tStart)
{
	float tCount;
	while(tStart)
	{
		tCount++;
		tStart = tStart._next;
	}
	return tCount;
}

// set target proc for menu debugger
void Menu_Debugger_SetProc(string tProcName)
{
	if (tProcName == "-")
	{
		menu_debug_process = null_entity;
		print("Menu debugger disabled\n");
		return;
	}
	if (Menu_Sys_FindProc(tProcName))
	{
		menu_debug_process = foundproc;
		print("Menu debugger targeted at ", foundproc.name, "\n");
		return;
	}
	print("Menu debugger cannot locate proc '", tProcName, "'\n");
}

// test find function
void Menu_Debugger_FindObject(string tObjectName)
{
	float tResult;
	
	if (isnotentity(menu_debug_process))
	{
		print("Target process not set, set up menu debugger first\n");
		return;
	}
	// find
	tResult = Menu_FindObject(menu_debug_process, menu_debug_findstartobject, tObjectName);
	if (tResult)
	{
		print("^2found: ", foundobject.name, "^7\n");
		return;
	}
	print("^3not found^7\n");
}

// set start object for finding
void Menu_Debugger_FindSetStartObject(string tObjectName) =
{
	entity tOldSelf;
	float tResult;
	
	if (isnotentity(menu_debug_process))
	{
		print("Target process not set, set up menu debugger first\n");
		return;
	}
	// find
	tResult = Menu_FindObject(menu_debug_process, menu_debug_findstartobject, tObjectName);
	if (tResult)
	{
		print("^2new start object = ", foundobject.name, "^7\n");
		menu_debug_findstartobject = foundobject;
		return;
	}
	print("^3not found^7\n");
}

// print all characters to console
void Menu_Debugger_PrintConchars(string tCvar) =
{
	float tPos;
	
	for (tPos = 0; tPos < 256; tPos+=1)
		print(" ", ftos(tPos), ") ", chr2str(tPos), " \n");
}

// print process list
void Menu_Debugger_PrintProcList(string tCvar) =
{
	entity tProc;
	float tPos;

	for (tProc = menu_proclist; tProc; tProc = tProc._next)
	{
		print(" #", ftos(tPos), " ", tProc.name, "\n");
		tPos++;
	}
}

// print info about process
void Menu_Debugger_PrintProcInfo(string tProcName) =
{
	// check if process is existing
	if (!Menu_Sys_FindProc(tProcName))
	{
		print("proc ", tProcName, " not found\n");
		return;
	}
	// print info
	print(" ^3name^7 = ", foundproc.name, "\n");
	if (isentity(foundproc._methods))
	{
		print(" ^3methods^7 = ");
		print(ftos(MenuDebugger_PrintProcInfo_CountChildren(foundproc._methods)));
		print(" entities\n");
		MenuDebugger_PrintStructure(foundproc._methods, name, _child, "  ", 10000);
	}
	else print(" ^3methods^7 = none\n");
	if (isentity(foundproc._classes))
	{
		print(" ^3classes^7 = ");
		print(ftos(MenuDebugger_PrintProcInfo_CountChildren(foundproc._classes)));
		print(" entities\n");
		MenuDebugger_PrintStructure(foundproc._classes, name, _child, "  ", 10000);
	}
	else print(" ^3classes^7 = none\n");
	if (isentity(foundproc._child))
	{
		print(" ^3objects^7 = ");
		print(ftos(MenuDebugger_PrintProcInfo_CountChildren(foundproc._child)));
		print(" entities\n");
		MenuDebugger_PrintObjects(foundproc._child, "  ", 10000);
	}
	else print(" ^3objects^7 = none\n");
}

void Menu_Debugger_PrintFontList(string tCvar) =
{
	entity tFontEntry;
	
	tFontEntry = draw2d_fontlist;
	while(isentity(tFontEntry))
	{
		print(" ^3", tFontEntry.name, "^7 (", tFontEntry.classname, ")\n");
		tFontEntry = tFontEntry._next;
	}
}

void Menu_Debugger_PrintFontInfo(string tFontName)
{
	float tPos;
	
	// check if font is loaded
	if (!Draw2D_FontStorage_FindEntry(tFontName))
	{
		print("font not loaded\n");
		return;
	}
	// print info
	print("name = ", tFontName, "\n");
	print("class = ", draw2d_foundentry.classname, "\n");
}

// print out all methods of menu
void Menu_Debugger_PrintMethods(string tCvar)
{
	entity m;
	string str;
	float op, printed, i;
	
	print("==== MENU METHODS LISTING ====\n");
	for (m = menu_proc._methods; m; m = m._next)
	{
		if (printed > 128)
		{
			print(str, "\n");
			str = "";
			printed = 0;
		}
		// vectors
		if (m.mType == MMT_COLOR || m.mType == MMT_VECTOR)
		{
			str = strcat(str, m.name, " ");
			str = strcat(str, m.name, "_x ", m.name, "_r ");
			str = strcat(str, m.name, "_y ", m.name, "_g ");
			str = strcat(str, m.name, "_z ", m.name, "_b ");
			printed += 7;
			continue;
		}
		// float, integer, bool, flag, string, script
		str = strcat(str, m.name, " ");	
		printed += 1;
	}
	print(str, "\n");
	print("==== END OF LISTING ====\n");
}

// print out all functions for NetherCode
void Menu_Debugger_PrintScriptFunctions(string tCvar)
{
	string str, func;
	float s, buf, printed;
	
	print("==== MENU NETHERCODE FUNCTIONS LISTING ====\n");
	// system functions
	for (s = 0; s < ncd_num_functions; s++)
	{
		if (printed > 128)
		{
			print(str, "\n");
			str = "";
			printed = 0;
		}
		func = ncd_func_names[s];
		str = strcat(str, func, " ");	
		printed++;
	}
	// prog builtins
	buf = ncd_progbuiltins[menu_debug_process.procScriptProg];
	for (s = 0; s < buf_getsize(buf); s++)
	{
		if (printed > 128)
		{
			print(str, "\n");
			str = "";
			printed = 0;
		}
		func = bufstr_get(buf, s);
		str = strcat(str, func, " ");	
		printed++;
	}
	// custom scripts
	/*
	buf = ncd_progfunctions[menu_debug_process.procScriptProg];
	for (s = 0; s < buf_getsize(buf); s++)
	{
		func = bufstr_get(buf, s);
		str = strcat(str, func, " ");	
	}
	*/
	print(str, "\n");
	print("==== END OF LISTING ====\n");
}

void Menu_Debugger_PrintHelp(string tCommand)
{
	if (tCommand != "")
	{
		print("^3", tCommand, "^7 ");
		if (tCommand == "mdev_progs")
			print("^3mdev_progs^7 <progname>\nSet target progs for debugger, must be ^3menu^7 or ^3client^7, debugger will not work without that\n");
		else if (tCommand == "mdev_logfile")
			print("^3mdev_logfile^7 <filename>\nSet log file which will catch all messages\n");
		else if (tCommand == "mdev_debug")
			print("^3mdev_debug^7 <procname/#procid>\nEnable debugger and set target proc for it, use '-' procname to disable, for available proc list see mdev_proclist\n");
		else if (tCommand == "mdev_conchars")
			print("^3mdev_conchars^7\nPrint conchars ASCII table, useful when making .qfont files\n");
		else if (tCommand == "mdev_proclist")	
			print("^3mdev_proclist^7\nPrint available proc list\n");
		else if (tCommand == "mdev_procinfo")	
			print("^3mdev_procinfo^7 <procname/#procid>\nPrint extended information about proc - object count, methods etc.\n");	
		else if (tCommand == "mdev_fontlist")		
			print("^3mdev_fontlist^7\nPrint list of fonts loaded by Draw2D module\n");
		else if (tCommand == "mdev_fontinfo")		
			print("^3mdev_fontinfo^7 <fontname>\nPrint extended information about font loaded by Draw2D module\n");	
		else if (tCommand == "mdev_loadqfont")			
			print("^3mdev_loadqfont^7 <fontname>\nLet Draw2D module to load specified .qfont\n");	
		else if (tCommand == "mdev_viewfont")			
			print("^3mdev_viewfont^7 <fontname>\nOpen font in font viewer, useful to debug font character maps, use '-' as fontname to disable\n");	
		else if (tCommand == "mdev_debug_find")			
			print("^3mdev_debug_find^7 <namespace>\nTry to find an object in menu, be aware that for relative searches you must set start object via mdev_debug_setstart\n");	
		else if (tCommand == "mdev_debug_setstart")		
			print("^3mdev_debug_setstart^7 <namespace>\nSet start object for finding\n");	
		else if (tCommand == "mdev_debug_area")
			print("^3mdev_debug_area^7 <0/1>\nShow sizes of all drawable objects\n");
		else if (tCommand == "mdev_debug_key")
			print("^3mdev_debug_key^7 <0/1>\nCast message for any key events\n");
		else if (tCommand == "mdev_debug_hotkey")
			print("^3mdev_debug_hotkey^7 <0/1>\nCast message for hotkey events\n");
		else if (tCommand == "mdev_debug_mouse")
			print("^3mdev_debug_mouse^7 <0/1>\nShow mouse cursor position\n");	
		else if (tCommand == "mdev_debug_select")
			print("^3mdev_debug_select^7 <0/1>\nShow selected objects\n");	
		else if (tCommand == "mdev_debug_trigger")
			print("^3mdev_debug_select^7 <0/1>\nShow trigger events\n");	
		else if (tCommand == "mdev_debug_script")
			print("^3mdev_debug_script^7 <0/1>\nShow menu script compilations and running statistics\n");	
		else
			print("no info\n");	
		return;
	}
	// print usage infp
	print("MENU DEVELOPER CVARS:\n");
	print(" ^3mdev_help^7 <command_or_cvar>\n");
	print(" ^3mdev_progs^7 <progname>\n");
	print(" ^3mdev_logfile^7 <0/1>\n");
	print(" ^3mdev_debug_area^7 <0/1>\n");
	print(" ^3mdev_debug_key^7 <0/1>\n");
	print(" ^3mdev_debug_hotkey^7 <0/1>\n");
	print(" ^3mdev_debug_mouse^7 <0/1>\n");
	print(" ^3mdev_debug_select^7 <0/1>\n");
	print(" ^3mdev_debug_trigger^7 <0/1>\n");
	print(" ^3mdev_debug_script^7 <0/1>\n");
	print(" ^3mdev_debug^7 <procname/#procid>\n");
	print(" ^3mdev_debug_find^7 <namespace>\n");
	print(" ^3mdev_debug_findstart^7 <namespace>\n");
	print(" ^3mdev_conchars^7 1\n");
	print(" ^3mdev_proclist^7 1\n");
	print(" ^3mdev_procinfo^7 <procname/#procid>\n");
	print(" ^3mdev_fontlist^7 1\n");
	print(" ^3mdev_fontinfo^7 <fontname>\n");
	print(" ^3mdev_loadqfont^7 <fontname>\n");
	print(" ^3mdev_viewfont^7 <fontname>\n");
	
}

/*
================================================================================

   EXPORTED API FUNCTIONS

================================================================================
*/

// catch up all messages by debugger
void Menu_Debugger_Message(string tStr) =
{
	if (menu_debug)
		Log_WriteLine("$mdev_logfile", tStr);
}

// write debugger log
void Menu_Debugger_Log(string tStr) =
{
	if (menu_debug)
		Log_WriteLine("$mdev_logfile", tStr);
}

// pre-draw debug
void() Menu_Debugger_PreFrame =
{
	string tCvar;
	
	// allow debugger?
	tCvar = cvar_string("mdev_progs");
	#ifdef TARG_MENUPROGS
	if (tCvar != "menu")
	{
		menu_debug = 0;
		return;
	}
	menu_debug = 1;
	#else
	if (tCvar != "client")
	{
		menu_debug = 0;
		return;
	}
	menu_debug = 1;
	#endif
	
	// cache cvars
	menu_debug_area = cvar("mdev_debug_area");
	menu_debug_select = cvar("mdev_debug_select");
	menu_debug_mouse = cvar("mdev_debug_mouse");
	menu_debug_key = cvar("mdev_debug_key");
	menu_debug_hotkey = cvar("mdev_debug_hotkey");
	menu_debug_trigger = cvar("mdev_debug_trigger");
	menu_debug_script = cvar("mdev_debug_script");
	
	// pseudo-commands
	#define try(s,f) tCvar = cvar_string(s); if (tCvar != null_string) { f(tCvar); cvar_set(s, null_string); }
	try("mdev_loadqfont", Draw2D_LoadFont)
	try("mdev_fontinfo", Menu_Debugger_PrintFontInfo)
	try("mdev_viewfont", Menu_Debugger_ViewFont)
	try("mdev_fontlist", Menu_Debugger_PrintFontList)
	try("mdev_proclist", Menu_Debugger_PrintProcList)
	try("mdev_procinfo", Menu_Debugger_PrintProcInfo)
	try("mdev_print_methods", Menu_Debugger_PrintMethods)
	try("mdev_print_scriptfunctions", Menu_Debugger_PrintScriptFunctions)
	try("mdev_conchars", Menu_Debugger_PrintConchars)
	try("mdev_debug_setstart", Menu_Debugger_FindSetStartObject)
	try("mdev_debug_find", Menu_Debugger_FindObject)
	try("mdev_debug", Menu_Debugger_SetProc)
	try("mdev_help", Menu_Debugger_PrintHelp)
	#undef try
}

void() Menu_Debugger_PostFrame =
{
	// check if debugging
	if (!menu_debug)
		return;
	if (!isentity(menu_debug_process))
		return;
	if (menu_debug_area || menu_debug_select)
		Menu_Debugger_DrawAreas();
	if (menu_debug_mouse)
		Menu_Debugger_DrawMouse();
}

void() Menu_Debugger_Init =
{
	// register cvars and aliases
	if (cvar_string("mdev_progs") == "")
		localcmd("set \"mdev_progs\" \"menu\"\n");
	if (cvar_string("mdev_logfile") == "")
		localcmd("set \"mdev_logfile\" \"menu.log\"\n");
	if (cvar_string("mdev_debug_area") == "")
		localcmd("set \"mdev_debug_area\" \"1\"\n");
	if (cvar_string("mdev_debug_select") == "")
		localcmd("set \"mdev_debug_select\" \"1\"\n");
	if (cvar_string("mdev_debug_trigger") == "")
		localcmd("set \"mdev_debug_trigger\" \"1\"\n");
	if (cvar_string("mdev_debug_script") == "")
		localcmd("set \"mdev_debug_script\" \"1\"\n");
	if (cvar_string("mdev_debug_mouse") == "")
		localcmd("set \"mdev_debug_mouse\" \"1\"\n");
	if (cvar_string("mdev_debug_key") == "")
		localcmd("set \"mdev_debug_key\" \"1\"\n");
	if (cvar_string("mdev_debug_hotkey") == "")
		localcmd("set \"mdev_debug_hotkey\" \"1\"\n");
	if (cvar_string("mdev_print_methods") == "")
		localcmd("set \"mdev_print_methods\" \"1\"\n");
	if (cvar_string("mdev_print_scriptfunctions") == "")
		localcmd("set \"mdev_print_scriptfunctions\" \"1\"\n");
		
	localcmd("set \"mdev_loadqfont\" \"\"\n");
	localcmd("set \"mdev_fontinfo\" \"\"\n");
	localcmd("set \"mdev_viewfont\" \"\"\n");
	localcmd("set \"mdev_fontlist\" \"\"\n");
	localcmd("set \"mdev_proclist\" \"\"\n");
	localcmd("set \"mdev_procinfo\" \"\"\n");
	localcmd("set \"mdev_conchars\" \"\"\n");
	localcmd("set \"mdev_print_methods\" \"\"\n");
	localcmd("set \"mdev_print_scriptfunctions\" \"\"\n");
	localcmd("set \"mdev_debug_setstart\" \"\"\n");
	localcmd("set \"mdev_debug_find\" \"\"\n");
	localcmd("set \"mdev_debug\" \"\"\n");
	localcmd("set \"mdev_help\" \"\"\n");
	
	Log_Start("$mdev_logfile");
	Menu_Sys_NewProc("Debugger", DebuggerProc, null_function);
}

void() Menu_Debugger_Shutdown =
{
}