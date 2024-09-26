////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

// This is menu internal workaround function
// don't use them in user code

#define MENU_DEBUG_NOCACHE

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

// callbacks
var void Menu_CallBack_SetCursor(float tUseMouse);

// class
.void() mInitClass;
.void() mDestroyClass;
void() NoClassSpawn = { };
void() NoClassInit = { };
void() NoClassShutdown = { };

// mouse-related
float menu_usemouse;
vector menu_mousepos;
vector menu_mousemove;
.vector mousePos;
.vector mouseMove;
.entity cursor; // world if cursor is not used, otherwise a pointer

// events
.void() mMouseMove; 	// mouse moved inside object zone
.void() mMouseEnter;	// mouse entered object zone
.void() mMouseLeave; // mouse leaved object zone
.void() mShow;
.void() mHide;

// exported base function
void() Menu_ProcInit;
void() Menu_ProcFrame;
void() Menu_ProcDraw;
Menu_KeyEvent Menu_ProcKey;
void() Menu_ProcDestroy;
	
// object tagging
.string tag;
.entity _tags;
.entity _tagnext;		// next tagged entity
.entity _tagprev;		// prev tag entity

// object states
.string state; 		// current state
.string state1;
.string state1name;
.string state2;
.string state2name;
.string state3;
.string state3name;
.string state4;
.string state4name;
.string state5;
.string state5name;
.string state6;
.string state6name;
.string state7;
.string state7name;
.string state8;
.string state8name;
.string state9;
.string state9name;
.string state10;
.string state10name;
.string state11;
.string state11name;
.string state12;
.string state12name;
.string state13;
.string state13name;
.string state14;
.string state14name;
.string state15;
.string state15name;
.string state16;
.string state16name;

// a large macro to work with all statemaps
#define TryAllStatemaps try(state1name, state1) try(state2name, state2) try(state3name, state3) try(state4name, state4) try(state5name, state5) try(state6name, state6) try(state7name, state7) try(state8name, state8) try(state9name, state9) try(state10name, state10) try(state11name, state11) try(state12name, state12) try(state13name, state13) try(state14name, state14) try(state15name, state15) try(state16name, state16)

// event pool
entity menu_event; 		// set before calling virtual event
entity menu_eventpool;
.entity thinkevent;
.float thinkcontinue;
.string keypool_target;
.float thinktime;
.float keypool_event;
.float keypool_asc;

// object position fields
.vector _scale;
.vector _pos;
.vector _apos; // arranged pos
.vector _axis;
.vector _size;
.vector _absmin;
.vector _absmax;

// object smart hiding (contains string for reasons, each reason should be 8 chars-len)
// so there can be several reasons to hide object
// objects is hidden when it have at least one reason
.string _hide;

// mouse tracing types
#define MENU_MOUSETRACE_NORMAL		0	// normal tracing against all
#define MENU_MOUSETRACE_SELECT		1	// skip embedded stuff

// characters remapping (WITH SHIFT, WITH ALT ETC)
#define KEYREMAPTABLE_SIZE 144 // 48*3
float keyremaptable[KEYREMAPTABLE_SIZE];
string keyremaptable_s[KEYREMAPTABLE_SIZE];

// developer hoods
#ifdef MENU_DEVELOPER
void() Menu_Debugger_Init;
void() Menu_Debugger_PreFrame;
void() Menu_Debugger_PostFrame;
void() Menu_Debugger_Shutdown;

void Menu_Debugger_Message(string tStr);
void Menu_Debugger_NewClass(entity tEnt);
void Menu_Debugger_KeyEvent(float event, float parama, float result);
void Menu_Debugger_HotkeyEvent(float event, float parama, float result, float returncode); 
void Menu_Debugger_Log(string tStr);
#endif

void() Menu_InitParser;
void() Menu_InitExporter;
void() Menu_ObjectLib_Init;
void() Menu_ObjectLib_Shutdown;

////////////////////////////////////////
// CODE
////////////////////////////////////////

void Menu_Warning(entity tObject, string tStr)
{
	if (isnotentity(tObject))
		tStr = strcat("^3Menu warning: ", tStr, "^7");
	else
	{
		if (tObject.mFlags & MENU_FLAG_NOWARNINGS)
			return;
		tStr = strcat("^5Menu object warning:\n^5On ", tObject.classname, " ", tObject.name, "\n^5", tStr, "^7");	
	}
	warning(tStr);
#ifdef MENU_DEVELOPER
	Menu_Debugger_Message(tStr);
#endif
}

void Menu_Error(string tStr)
{
	tStr = strcat("^1Menu error: ", tStr, "^7");
	print(tStr);
	print("\n");
#ifdef MENU_DEVELOPER
	Menu_Debugger_Message(tStr);
#endif
}

void Menu_Crash(string tStr)
{
	tStr = strcat("^1Menu critical error: ", tStr, "^7");
	error(strcat(tStr, "\n"));
#ifdef MENU_DEVELOPER
	Menu_Debugger_Message(tStr);
#endif
}

void Menu_Message(string tStr)
{
	tStr = strcat("Menu: ", tStr);
	print(tStr);
	print("\n");
#ifdef MENU_DEVELOPER
	Menu_Debugger_Message(tStr);
#endif
}

/*
================================================================================

   EVENT POOL

================================================================================
*/

void Menu_Sys_DestroyEvent(entity tEvent)
{
	// unlink from event list
	Menu_Util_UnlinkFrom(tEvent,null_entity,menu_eventpool,_parent)
	// destroy entity
	strunzone(tEvent.keypool_target);
	// remove
	remove(tEvent);
}

entity Menu_Sys_CreateEvent(string tEventName, float() tEventFunc, string tTargetProc, float tDelay) =
{
	entity tEvent, tNewEvent, tLastEvent;

	tNewEvent = spawn();
	tNewEvent.classname = "menu_virtual_event";
	tNewEvent.name = tEventName;
	tNewEvent.mEvent = tEventFunc;
	Menu_Util_LinkInto(tNewEvent, null_entity, menu_eventpool, _parent) 
	tNewEvent.mDraw = null_function;
	tNewEvent.keypool_target = strzone(tTargetProc);
	tNewEvent.thinktime = time + tDelay;
	return tNewEvent;
}

float Menu_Sys_FindProc(string tProcName);
void() Menu_Sys_RunEvents =
{
	entity tEvent, tNextEvent;
	float tEventEnded;
	
	// walk key pool and check if it is time for keys
	for (tEvent = menu_eventpool; tEvent; tEvent = tNextEvent)
	{
		tNextEvent = tEvent._next;
		if (tEvent.thinktime > time)
			continue; // not a time for event
		// run event
		menu_event = tEvent;
		if (tEvent.keypool_target != "")
		{
			if (Menu_Sys_FindProc(tEvent.keypool_target))
			{
				menu_proc = foundproc;
				tEventEnded = tEvent.mEvent();
			}
			else 
			{
				tEventEnded = 1;
				Menu_Warning(tEvent, strcat("Menu_Sys_RunEvents: targeted process '", tEvent.keypool_target, "' not found!"));
			}
		}
		else 
		{
			tEventEnded = tEvent.mEvent();
		}
		// and destroy it
		if (tEventEnded)
		{
			menu_proc = null_entity;
			Menu_Sys_DestroyEvent(tEvent);
		}
	}
}

// simulate key event
float Menu_Sys_KeyEvent(float tEvent, float tKeyCode); 
float() Menu_Event_KeyEvent =
{
	entity tOldSelf;
	// proc-oriented event
	if (isentity(menu_proc))
	{
		tOldSelf = self;
		self = menu_proc;
		menu_proc.mKey(menu_event.keypool_event, menu_event.keypool_asc, KR_FALSE);
		return 1;
	}
	// system event
	Menu_Sys_KeyEvent(menu_event.keypool_event, menu_event.keypool_asc);
	return 1;
}

// add virtual key event
void Menu_AddKeyEvent(float tEventType, float tKeyAsc, string tTargetProc, float tDelay)
{
	entity tNewEvent;
	
	tNewEvent = Menu_Sys_CreateEvent("event_key", Menu_Event_KeyEvent, tTargetProc, tDelay);
	tNewEvent.keypool_asc = tKeyAsc;
	tNewEvent.keypool_event = tEventType;
}

// run thinks on objects
float() Menu_Event_Think =
{
	entity tOldSelf;
	
	menu_event.thinkcontinue = 0;
	tOldSelf = self;	
	self = menu_event.focus;
	menu_event.mDraw();
	self = tOldSelf;
	if (menu_event.thinkcontinue)
		return 0;
	menu_event.focus.thinkevent = null_entity;
	return 1; 
}

void Menu_SetThink(entity tObject, void() tThink, float tDelay)
{
	entity tEvent;
	
	if (isentity(tObject.thinkevent)) // check if there is think already
	{
		tEvent = tObject.thinkevent;
		tEvent.mDraw = tThink;
		tEvent.thinktime = time + tDelay;
		return;
	}

	tEvent = Menu_Sys_CreateEvent("event_think", Menu_Event_Think, tObject._proc.name, tDelay);
	tEvent.focus = tObject;
	tEvent.mDraw = tThink;
	tEvent.thinktime = time + tDelay;
	tObject.thinkevent = tEvent;
}


/*
================================================================================

   KEYS STUFF

================================================================================
*/

// [input] [normal] [with shift] 
string defaultkeyremaptable_s[KEYREMAPTABLE_SIZE] =
{
	",", ",", "<", // , and <
	"-", "-", "_", // - and _
	".", ".", ">", // . and >
	"/", "/", "?", // / and ?
	"0", "0", ")", // 0 and )
	"1", "1", "!", // 1 and !
	"2", "2", "@", // 2 and @
	"3", "3", "#", // 3 and #
	"4", "4", "$", // 4 and $
	"5", "5", "%", // 5 and %
	"6", "6", "^", // 6 and ^
	"7", "7", "&", // 7 and &
	"8", "8", "*", // 8 and *
	"9", "9", "(", // 9 and (
	"a", "a", "A", // a
	"b", "b", "B", // b
	"c", "c", "C", // c
	"d", "d", "D", // d
	"e", "e", "E", // e
	"f", "f", "F", // f
	"g", "g", "G", // g
	"h", "h", "H", // h
	"i", "i", "I", // i
	"j", "j", "J", // j
	"k", "k", "K", // k
	"l", "l", "L", // l
	"m", "m", "M", // m
	"n", "n", "N", // n
	"o", "o", "O", // o
	"p", "p", "P", // p
	"q", "q", "Q", // q
	"r", "r", "R", // r
	"s", "s", "S", // s
	"t", "t", "T", // t
	"u", "u", "U", // u
	"v", "v", "V", // v
	"w", "w", "W", // w
	"x", "x", "X", // x
	"y", "y", "Y", // y
	"z", "z", "Z", // z
	"[", "[", "{", // [ and {  
	"\\", "\\", "|", // \ and |
	"]", "]", "}", // ] and }
	"`", "`", "~", // ` and ~
	"=", "=", "+", // = and +
	";", ";", ":", // ; and :
	"'", "'", "\"", // ' and "
	" ", " ", " " // space
};

// query current key state
vector Menu_Sys_KeyQuery(float keycode)
{
	if (keycode < 0)
		return '0 0 0';
	return stov(bufstr_get(menu_keybuffer, keycode));
}

void Menu_Sys_KeyUnpress(float keycode)
{
	vector keyinfo;
	
	keyinfo = stov(bufstr_get(menu_keybuffer, keycode));
	keyinfo_x = 0;
	bufstr_set(menu_keybuffer, keycode, vtos(keyinfo));
}

void Menu_Sys_KeyPress(float keycode)
{
	vector keyinfo;
	
	keyinfo_x = 1;
	keyinfo_y = time;
	bufstr_set(menu_keybuffer, keycode, vtos(keyinfo));
}

// returns true if key is pressed currently
float Menu_Sys_KeyPressed(float keycode)
{
	vector keyinfo;

	keyinfo = stov(bufstr_get(menu_keybuffer, keycode));
	if (keyinfo_x)
	{
		// VorteX: sometimes release events get lost, check fi kay wasn't pressed for a long time
		if ((time - keyinfo_y) > 0.9)
		{
			Menu_Sys_KeyUnpress(keycode);
			return 0;
		}
		return 1;
	}
	return 0;
}

void Menu_Sys_Key(float keyevent, float keycode) =
{
	vector keyinfo;
	
	keyinfo = stov(bufstr_get(menu_keybuffer, keycode));
	if (keyevent == KEYEVENT_HOLD)
	{
		if (!keyinfo_x) 
			keyinfo_y = time;
		keyinfo_x = 1;
	}
	else if (keyevent == KEYEVENT_RELEASE)
	{
		keyinfo_x = 0;
		keyinfo_z = time;
	}
	bufstr_set(menu_keybuffer, keycode, vtos(keyinfo));
}

string Menu_Sys_RemapChar(float keycode)
{
	float p;
	// find key
	for (p = 0; p < KEYREMAPTABLE_SIZE; p += 3)
		if (keyremaptable[p] == keycode)
			break;
	if (p >= KEYREMAPTABLE_SIZE)
		return ""; // not found
	// remap key
	if (Menu_Sys_KeyPressed(K_SHIFT))
	{
		Menu_Sys_KeyPress(K_SHIFT); // FIXME: DP BUG
		p = keyremaptable[p + 2];
	}
	else
		p = keyremaptable[p + 1];
	return chr2str(p);
}

string Menu_Sys_KeyNumToString(float tKeyCode)
{
	return keynumtostring(tKeyCode);
}

// VorteX: stringtokeynum is broken on certain DP builds
// so here is a way to avoid that breaks
float Menu_Sys_StringToKeyNum(string tKeyName)
{
	float tPos;
	if (menu_keynamesbuffer < 0)
		return -1;
	for (tPos = 0; tPos < menu_keynamesbuffer_size; tPos++)
		if(bufstr_get(menu_keynamesbuffer, tPos) == tKeyName)
			return stof(bufstr_get(menu_keynamesbuffer_n, tPos));
	return -1;
}

void() Menu_Sys_InitKeySystem =
{
	float tPos, tPos2;
	string tStr;
	
	// load string remap table
	for (tPos = 0; tPos < KEYREMAPTABLE_SIZE; tPos++)
	{
		tStr = defaultkeyremaptable_s[tPos];
		keyremaptable_s[tPos] = tStr;
	}
	// build char remap table
	for (tPos = 0; tPos < KEYREMAPTABLE_SIZE; tPos++)
	{
		tStr = keyremaptable_s[tPos];
		keyremaptable[tPos] = str2chr(tStr, 0);
	}
	// create key states buffer
	menu_keybuffer = buf_create();
	if (menu_keybuffer < 0)
		warning("Menu_Sys_InitKeySystem: failed to create key states buffer!\n");
	// create key names buffer
	menu_keynamesbuffer_size = 0;
	menu_keynamesbuffer = buf_create();
	menu_keynamesbuffer_n = buf_create();
	if (menu_keynamesbuffer >= 0 && menu_keynamesbuffer_n >= 0)
	{
		for (tPos = 0; tPos < 1024; tPos++)
		{
			tStr = keynumtostring(tPos);
			if (tStr != "<UNKNOWN KEYNUM>")
			{
				bufstr_set(menu_keynamesbuffer, menu_keynamesbuffer_size, tStr);
				bufstr_set(menu_keynamesbuffer_n, menu_keynamesbuffer_size, ftos(tPos));
				menu_keynamesbuffer_size++;
			}
		}
		return;
	}
	warning("Menu_Sys_InitKeySystem: failed to create key names buffer!\n");
}

/*
================================================================================

   ACTIONS

================================================================================
*/
command Cmd_MenuAction =
{
	entity old_menu_proc;
	string cmdname, cmdparms;
	float prog, p;
	
	if (is_help)
	{
		print("usage: ma <procname> <action>\n");
		return;
	}
	// find proc
	if (!Menu_Sys_FindProc(argv(1)))
	{
		print("MenuAction: cannot find prog '", argv(1), "'\n");
		return;
	}
	// run command
	cmdname = argv(2);
	cmdparms = "";
	old_menu_proc = menu_proc;
	menu_proc = foundproc;
	if (numparms >= 3)
	{
		for (p = 3; p < numparms; p++)
			cmdparms = strcat(cmdparms, argv(p), " ");
	}
	if (!MenuScript_RunCommand(cmdname, cmdparms))
		print("MenuAction: cannot run command '", cmdname, "'\n");
	menu_proc = old_menu_proc;
}

void() Menu_InitActions =
{
	RegisterLocalCommand("ma", Cmd_MenuAction, "do menu action");
}

/*
================================================================================

   CLASSES
   
================================================================================
*/

float Menu_Sys_FindClass(entity tProc, string tClassName)
{
	entity tClass;

	for (tClass = tProc._classes; tClass; tClass = tClass._next)
	{
		if (tClass.name == tClassName)
		{
			foundclass = tClass;
			return 1;
		}
	}
	foundclass = null_entity;
	return 0;
}

void Menu_Sys_RegisterClass(entity tProc, void() tClassFunc)
{
	entity tNewClass, tClassEnt, tLastClassEnt;

	// null classfunc?
	if (isnotentity(tProc))
	{
		Menu_Warning(null_entity, "Menu_Sys_RegisterClass: null proc!");
		return;
	}
	if (!tClassFunc)
	{
		Menu_Warning(null_entity, "Menu_Sys_RegisterClass: null class function!");
		return;
	}
	// default noclass globals
	className = "NoClass";
	classSpawn = NoClassSpawn;
	classInit = NoClassInit;
	classShutdown = NoClassShutdown;
	tClassFunc();
	// check if this is duplicate class
	if (Menu_Sys_FindClass(tProc, className))
	{
		Menu_Warning(null_entity, strcat("Menu_Sys_RegisterClass: classname '", className, "' is used"));
		return;
	}
	// spawn
	tNewClass = spawn();
	tNewClass.name = strzone(className);
	tNewClass.localname = strzone(className);
	tNewClass._proc = tProc;
	tNewClass.mDraw = classSpawn;
	tNewClass.mPreUpdate = classInit;
	tNewClass.mPostUpdate = classShutdown;
	// link into class list
	Menu_Util_LinkInto(tNewClass, tProc, tProc._classes, _parent)
	// log
#ifdef MENU_DEVELOPER
	Menu_Debugger_NewClass(tNewClass);
#endif
}

// destroy 
void Menu_Proc_DestroyClass(entity tClass)
{
	// unlink from class list
	Menu_Util_UnlinkFrom(tClass, tClass._parent, tClass._parent._classes, _parent)
	// free fields
	strunzone(tClass.name);
	strunzone(tClass.localname);
	// remove
	remove(tClass);
}

void Menu_Sys_TagObject(entity tObject)
{
	if (tObject.tag != "")
		return; // already tagged
	// add to tags chain
	if (isentity(tObject._proc._tags))
	{
		tObject._proc._tags._tagprev = tObject;
		tObject._tagnext = tObject._proc._tags;
		tObject._tagprev = null_entity;
		tObject._proc._tags = tObject;
		return;
	}
	tObject._proc._tags = tObject;
	tObject._tagprev = null_entity;
	tObject._tagnext = null_entity;
}

void Menu_Sys_UnTagObject(entity tObject)
{
	if (tObject.tag == "")
		return; // already untagged
	// remove from tags chain
	if (tObject._tagnext)
		tObject._tagnext._tagprev = tObject._tagprev;
	if (tObject._tagprev)	
		tObject._tagprev._tagnext = tObject._tagnext;
	if (tObject._proc._tags == tObject)
		tObject._proc._tags = tObject._next;
}

/*
================================================================================

   OBJECT STATES
   
   state = generic_state:sub_state
   
   generic states are = normal, red etc - whatever user tell
   substates = :normal, :selected, :pressed, :inactive
   default substate is :normal
   
   so when set state red_text:selected
   - run :normal (default state)
   if (there is :selected)
		- switch to red_text:selected
	else
		- switch to red_text:normal
		
	todo: perhaps "- run :normal (default state)" is not needed, undo state operation will be faster
	
================================================================================
*/

string foundstatemap;

// apply statemap to an object
void Menu_Sys_StateMap_RunMap(entity tObject, string tStateMap, float tSilent)
{
	float tPos, tLen, tChunkLen, tOp;
	string tMethod, tValue;
	
	// cycle all methods in map
	tLen = strlen(tStateMap);
	tPos = lumpstart(tStateMap);
	while(tPos < tLen)
	{
		// read method
		tChunkLen = lumpchunk(tStateMap, tPos);
		tOp = stof(lumpread(tStateMap, tPos, 1));
		tMethod = lumpread(tStateMap, tPos + 1, tChunkLen - 1);
		tPos = lumpstep(tPos, tChunkLen);
		// read value
		tChunkLen = lumpchunk(tStateMap, tPos);
		tValue = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// run method
		tObject.setMethod(tObject, tOp, tMethod, tValue);
	}
}

// get certain state map from object to process it
// return 1 is success
float Menu_Sys_StateMap_Get(entity tObject, string tStateMapName)
{
	#define try(n,m)  if (tObject.n == tStateMapName) {  foundstatemap = tObject.m; return 1; }
	TryAllStatemaps
	#undef try
	foundstatemap = "";
	return 0;
}

// add all entries of one statemap into another
float Menu_Sys_StateMap_AddMethod(entity tObject, string tStateName, string tMethod, string tValue);
void Menu_Sys_StateMap_MergeInto(entity tObject, string tDestStateName, string tStateName, string tStateMap)
{
	float tPos, tLen, tChunkLen;
	string tMethod, tValue;
	
	while(tPos < tLen)
	{
		// read method
		tChunkLen = lumpchunk(tStateMap, tPos);
		tMethod = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// read value
		tChunkLen = lumpchunk(tStateMap, tPos);
		tValue = lumpread(tStateMap, tPos, tChunkLen);
		tPos = lumpstep(tPos, tChunkLen);
		// add method
		Menu_Sys_StateMap_AddMethod(tObject, tDestStateName, tMethod, tValue);
	}
}

// set new state map, if statemap already exists - override it
// returns false if failed (no free state slots)
float Menu_Sys_StateMap_Set(entity tObject, string tStateName, string tNewStateMap)
{
	// try replace
	#define try(n,m) if(tObject.n==tStateName){if (tObject.m!=null_string)strunzone(tObject.m);if(tNewStateMap!=null_string)tObject.m=strzone(tNewStateMap);else tObject.m=null_string;return 1;}
	TryAllStatemaps
	#undef try
	// allocate new
	#define try(n,m) if (tObject.n == null_string){if(tStateName!=null_string)tObject.n=strzone(tStateName);if(tNewStateMap!=null_string)tObject.m=strzone(tNewStateMap);return 1;}
	TryAllStatemaps
	#undef try
	Menu_Warning(tObject, "Menu_Sys_StateMap_Set: reached MENU_OBJECT_MAX_STATEPMAPS");
	return 0;
}

// check if object has any states
float Menu_Sys_StateMap_NumStates(entity tObject)
{
	float tNumStates;
	#define try(n,m) if (tObject.n != null_string) { tNumStates = tNumStates + 1; }
	TryAllStatemaps
	#undef try
	return tNumStates;
}

void Menu_Sys_StateMap_CopyStates(entity tFrom, entity tTo)
{
	#define try(n,m) if (tTo.n != null_string) { strunzone(tTo.n); tTo.n = null_string; strunzone(tTo.m); tTo.m = null_string; } if (tFrom.n != null_string) { tTo.n = strzone(tFrom.n); tTo.m = strzone(tFrom.m); }
	TryAllStatemaps
	#undef try
}

void Menu_Sys_StateMap_AddStates(entity tFrom, entity tTo)
{
	#define try(n,m) if (tFrom.n != null_string) Menu_Sys_StateMap_MergeInto(tTo, tFrom.n, tFrom.n, tFrom.m);
	TryAllStatemaps
	#undef try
}

// add to existing state map, if statemap not exists - create it
// returns false if failed (no free state slots)
float Menu_Sys_StateMap_AddMethod(entity tObject, string tStateName, string tMethod, string tValue)
{
	string tNewStateMap, tLast;
	float tOp, tLen;
	
	// method arithmetic
	tLen = strlen(tMethod) - 1;
	tOp = Menu_Sys_MethodOpForString(substring(tMethod, tLen, 1));
	if (tOp >= 0)
		tMethod = substring(tMethod, 0, tLen); // cut from name
	else
		tOp = MMA_SET;
	tMethod = strcat(ftos(tOp), tMethod);	
		
	// try existing
	#define try(n,m) if (tObject.n == tStateName) { tNewStateMap = poplump(tObject.m, tMethod);tNewStateMap = poplump(tNewStateMap, tValue); if (tObject.m != null_string) strunzone(tObject.m); tObject.m = strzone(tNewStateMap); return 1; }
	TryAllStatemaps
	#undef try
	// create new
	#define try(n,m) if (tObject.n == null_string) { tObject.n = strzone(tStateName); tNewStateMap = makelump(tMethod);tObject.m = strzone(poplump(tNewStateMap, tValue)); return 1; }
	TryAllStatemaps
	#undef try
	Menu_Warning(tObject, "Menu_Sys_StateMap_AddMethod: reached MENU_OBJECT_MAX_STATEPMAPS");
	return 0;
}

void Menu_Sys_StateMap_RunOnTemplate(entity tTemplate, entity tObject, string tFullState, float tSilent)
{
	// run parent template
	if (isentity(tTemplate._template))
		Menu_Sys_StateMap_RunOnTemplate(tTemplate._template, tObject, tFullState, tSilent);
	// run this template
	if (Menu_Sys_StateMap_Get(tTemplate, tFullState))
		Menu_Sys_StateMap_RunMap(tObject, foundstatemap, tSilent);
}

void Menu_Sys_SetState(entity tObject, float tUpdateFlags, string tState, string tSubState)
{
	string tFullState, tBaseState;
	float tSilent;
	
	tState = strcat(tState, "");
	tFullState = strcat(tState, tSubState); 
	tSilent = (tUpdateFlags & MSU_SILENT);
	
	// eventual state call
	if (tUpdateFlags & MSU_EVENT)
	{
		
		if (isentity(tObject._template))
			Menu_Sys_StateMap_RunOnTemplate(tObject._template, tObject, tFullState, tSilent);
		if (Menu_Sys_StateMap_Get(tObject, tFullState))
			Menu_Sys_StateMap_RunMap(tObject, foundstatemap, tSilent);
		return;
	}
	
	// do not allow twice state change unless forced
	if (tObject.state == tFullState && !(tUpdateFlags & MSU_FORCEUPDATE)) 
		return; 
		
	// always include ':normal' state
	if (isentity(tObject._template))
		Menu_Sys_StateMap_RunOnTemplate(tObject._template, tObject, ":normal", tSilent);
	if (Menu_Sys_StateMap_Get(tObject, ":normal"))
		Menu_Sys_StateMap_RunMap(tObject, foundstatemap, tSilent);
		
	// include state:normal if state != ""
	if (tState != "")
	{
		tBaseState = strcat(tState, ":normal");
		if (isentity(tObject._template))
			Menu_Sys_StateMap_RunOnTemplate(tObject._template, tObject, tBaseState, tSilent);
		if (Menu_Sys_StateMap_Get(tObject, tBaseState))
			Menu_Sys_StateMap_RunMap(tObject, foundstatemap, tSilent);
	}
	
	// try desired state
	if (tFullState != ":normal") // :normal is already done
	{
		if (isentity(tObject._template))
			Menu_Sys_StateMap_RunOnTemplate(tObject._template, tObject, tFullState, tSilent);
		if (Menu_Sys_StateMap_Get(tObject, tFullState))
			Menu_Sys_StateMap_RunMap(tObject, foundstatemap, tSilent);
	}
	
	// set new state
	tObject.substate = tSubState;
	strunzone(tObject.state);
	tObject.state = strzone(tState);
}

void Menu_Sys_RunState(entity tObject, float tUpdateFlags, string tState, string tSubState)
{
	entity tChild;
	
	tState = strcat(tState, ""); // get temp-string state and substate, because self.state could be passed
	Menu_Sys_SetState(tObject, tUpdateFlags, tState, tSubState);
	// if has embedded children - set on them
	if (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDED)
		for (tChild = tObject._child; tChild; tChild = tChild._next)
			if (tChild.mFlags & MENU_FLAG_EMBEDDED)
				Menu_Sys_RunState(tChild, tUpdateFlags, tState, tSubState);
}

/*
================================================================================

   OBJECTS SPAWNING AND FINDING

================================================================================
*/

// create new object
entity Menu_Sys_NewObject(entity tProc, string tClass, string tName, entity tParentObj)
{
	string tFullName, tWarn;
	entity tOldSelf, tObject, tNewObject;
	
	// VorteX: i hope we never get this... (this happens if call internal menu function from normal QC)
	if (isnotentity(tProc))
	{
		Menu_Crash("Menu_Sys_NewObject: proc is not set!\n");
		return null_entity;
	}
	// check class
	if (tClass == "")
	{
		Menu_Crash("Menu_Sys_NewObject: class is not specified!\n");
		return null_entity;
	}
	// get name
	if (isentity(tParentObj))
	{
		if (tName == "")
		{
			tParentObj._uidcounter = tParentObj._uidcounter + 1;
			tName = strcat("Object", ftos(tParentObj._uidcounter));
		}
		tFullName = strcat(tParentObj.name, ":", tName);
		// update parent because new children will arrive
		tParentObj.mRunFlags = tParentObj.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
	}
	else
	{
		if (tName == "")
		{
			tProc._uidcounter = tProc._uidcounter + 1;
			tName = strcat("Object", ftos(tProc._uidcounter));
		}
		tFullName = strcat(tProc.name, "::", tName);
	}
	// check if name is unique
	if (isentity(tObject))
	{
		tWarn = strcat("Menu_Sys_NewObject: name ", tFullName, " is not unique, trying to replace... ");
		while(isentity(tObject))
		{
			tName = strcat(tName, "_");
			tFullName = strcat(tFullName, "_");
			tObject = find(null_entity, name, tFullName);
		}
	}
	// spawn
	tNewObject = spawn();
	tNewObject._proc = tProc;
	tNewObject.classname = strzone(tClass);
	tNewObject.name = strzone(tFullName);
	tNewObject.localname = strzone(tName);
	tNewObject.mInit = null_function;
	tNewObject.mPreUpdate = null_function;	
	tNewObject.mPostUpdate = null_function;	
	tNewObject.mDraw = null_function;	
	tNewObject.mPostDraw = null_function;	
	tNewObject.mDestroy = null_function;	
	tNewObject.mKey = null_keyevent;
	tNewObject.mMouseMove = null_keyevent;
	tNewObject.mMouseEnter = null_keyevent;
	tNewObject.mMouseLeave = null_keyevent;
	tNewObject.setMethod = Menu_Sys_SetMethod;
	tNewObject.getMethod = Menu_Sys_GetMethod;
	tNewObject.mFlags = MENU_FLAG_NEW;
	tNewObject.substate = ":normal";
	tNewObject._hide = strzone("");
	// link into parent
	if (isentity(tParentObj))
		{ Menu_Util_LinkInto(tNewObject, tParentObj, tParentObj._child, _parent) }
	else
		{ Menu_Util_LinkInto(tNewObject, tProc, tProc._child, _parent) }
	tOldSelf = self;
	self = tNewObject;
	// init methods
	for (tObject = tProc._methods; tObject; tObject = tObject._next)
		tObject.mInit();
	// init class
	if (Menu_Sys_FindClass(tProc, tClass))
		foundclass.mPreUpdate();
	self = tOldSelf;
	return tNewObject;
}

// destroy children of object
void Menu_Sys_DestroyObject(entity tObject);
void Menu_Sys_DestroyChildren(entity tObject)
{
	entity tChild, tNextChild;
	
	if (!tObject._child)
		return;
	for (tChild = tObject._child; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyObject(tChild);
	}
}

// destroy object and all children
void Menu_Sys_DestroyObject(entity tObject)
{
	entity tOldSelf, tChild, tNextChild, tMethod;
	
	// destroy children
	Menu_Sys_DestroyChildren(tObject);
	// onDestroy event
	if (tObject.onDestroy)
		MenuScript_Run(tObject, tObject.onDestroy);
	// call destroy, shutdown methods, shutdown class
	tOldSelf = self;
	self = tObject;
	self.mDestroy();
	for (tMethod = tObject._proc._methods; tMethod; tMethod = tMethod._next)
		tMethod.mDestroy();
	if (Menu_Sys_FindClass(self._proc, self.classname))
		foundclass.mPostUpdate();
	self = tOldSelf;
	// unlink from parent
	Menu_Util_UnlinkFrom(tObject, tObject._parent,  tObject._parent._child, _parent)
	// destroy think
	if (isentity(tObject.thinkevent))
		Menu_Sys_DestroyEvent(tObject.thinkevent);
	// unzone string fields
	strunzone(tObject.classname);
	strunzone(tObject.name);
	strunzone(tObject.localname);
	strunzone(tObject._hide);
	// remove object
	remove(tObject);
}

void Menu_Sys_AddStaticStatesFromTemplate_Recursive(entity tObject, entity tTemplate)
{
	// add from parent template first
	if (isentity(tTemplate._template))
		Menu_Sys_AddStaticStatesFromTemplate_Recursive(tObject, tTemplate._template);
	// add from template
	Menu_Sys_StateMap_AddStates(tTemplate, tObject);
}

// derive object from other object
entity Menu_Sys_CloneObject(entity tBase, string tName, entity tParentObj, float tDynamicTemplating)
{
	entity tObject, tChild, tTemplate;
	
	tObject = Menu_Sys_NewObject(tBase._proc, tBase.classname, tName, tParentObj);
	if (!tDynamicTemplating)
		Menu_Sys_AddStaticStatesFromTemplate_Recursive(tObject, tBase);
	else
	{
		Menu_Sys_StateMap_CopyStates(null_entity, tObject);
		tObject._template = tBase;
	}
	// clone children
	for (tChild = tBase._child; tChild; tChild = tChild._next)
		Menu_Sys_CloneObject(tChild, tChild.localname, tObject, tDynamicTemplating);
	return tObject;
}

// set new object class
void Menu_Sys_SetObjectClass(entity tObject, string tClassName)
{
	rezone(tObject.classname, tClassName);
}

// set new object name - with children
void Menu_Sys_SetObjectName_SetParent_Recursive(entity tObject, float tOldNameLen, string tParentName)
{
	string tFullName;
	entity tChild;
	
	// set full name
	tFullName = strcat(tParentName, substring(tObject.name, tOldNameLen, 10000));
	rezone(tObject.name, tFullName);
	// set on children
	for (tChild = tObject._child; isentity(tChild); tChild = tChild._next)
		Menu_Sys_SetObjectName_SetParent_Recursive(tChild, tOldNameLen, tParentName);
}

// set new object name
void Menu_Sys_SetObjectName(entity tObject, string tName)
{
	string tFullName;
	float tOldNameLen;
	entity tChild;
	
	// set full name and localname
	tOldNameLen = strlen(tObject.name);
	tFullName = strcat(substring(tObject.name, 0, strlen(tObject.name) - strlen(tObject.localname)), tName);
	rezone(tObject.name, tFullName);
	rezone(tObject.localname, tName);
	// recalc full name on children
	for (tChild = tObject._child; isentity(tChild); tChild = tChild._next)
		Menu_Sys_SetObjectName_SetParent_Recursive(tChild, tOldNameLen, tObject.name);
}

/*
================================================================================

   OBJECT HIDING/SHOWING

================================================================================
*/

float Menu_IsHidden(entity tObject) =
{
	while (tObject)
	{
		if (tObject.mRunFlags & MENU_RUNFLAG_HIDDEN)
			return 1;
		tObject = tObject._parent;	
	}
	return 0;
}

void Menu_RaiseHideEvent(entity tObject) =
{
	entity oldself;
	
	// system event
	if (tObject.mHide)
	{
		oldself = self;
		self = tObject;
		self.mHide();
		self = oldself;
	}
	
	// script event
	if (tObject.onHide)
		MenuScript_Run(tObject, tObject.onHide);
}

void Menu_Hide(entity tObject, string reason)
{
	float i, len, h;
	string r;

	if (strlen(reason) != 8)
	{
		Menu_Warning(tObject, strcat("hiding reason '", reason, "' is not 8-chars len"));
		return;
	}
	
	// set reason
	for (i = 0, len = strlen(tObject._hide); i < len; i += 8)
	{
		r = substring(tObject._hide, i, 8);
		if (r == reason)
			break;
	}
	if (i >= len)
	{
		r = strcat(tObject._hide, reason);
		rezone(tObject._hide, r);
	}

	// hide object
	if (!(tObject.mRunFlags & MENU_RUNFLAG_HIDDEN))
	{
		Menu_RaiseHideEvent(tObject);
		tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_HIDDEN;
	}
}

void Menu_RaiseShowEvent(entity tObject) =
{
	entity oldself;
	
	// system event
	if (tObject.mShow)
	{
		oldself = self;
		self = tObject;
		self.mShow();
		self = oldself;
	}
	// script event
	if (tObject.onShow)
		MenuScript_Run(tObject, tObject.onShow);
}

void Menu_Unhide(entity tObject, string reason)
{
	float i, len;
	string r;
	
	if (strlen(reason) != 8)
	{
		Menu_Warning(tObject, strcat("hiding reason '", reason, "' is not 8-chars len"));
		return;
	}
	
	// unset reason
	for (i = 0, len = strlen(tObject._hide); i < len; i += 8)
	{
		r = substring(tObject._hide, i, 8);
		if (r == reason)
		{
			r = substring(tObject._hide, 0, i);
			r = strcat(r, substring(tObject._hide, i + 8, 10000));
			rezone(tObject._hide, r);
			break;
		}
	}

	// unhide object (in there are no reasons left)
	if (tObject._hide == "" && tObject.mRunFlags & MENU_RUNFLAG_HIDDEN)
	{
		Menu_RaiseShowEvent(tObject);
		tObject.mRunFlags = tObject.mRunFlags - MENU_RUNFLAG_HIDDEN;
	}
}

/*
================================================================================

   OBJECT PROCESSING

================================================================================
*/

void Menu_UpdateObjectNode_SpawnClass(entity tObject) =
{
	entity tChild, tNextChild, tOldSelf;
	
	tObject.mFlags = tObject.mFlags - (tObject.mFlags & MENU_FLAG_NEW);
	// prespawn event
	if (tObject.onPreSpawn)
		MenuScript_Run(tObject, tObject.onPreSpawn);
	// spawn children
	for (tChild = tObject._child; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		if (tChild.mFlags & MENU_FLAG_NEW)
			Menu_UpdateObjectNode_SpawnClass(tChild);
	}
	// spawn state
	Menu_Sys_RunState(tObject, MSU_EVENT, tObject.state, ":spawn");
	// spawn this class
	Menu_Sys_RunState(tObject, MSU_SILENT, tObject.state, tObject.substate);
	if (Menu_Sys_FindClass(tObject._proc, tObject.classname))
	{
		tOldSelf = self;
		self = tObject;
		foundclass.mDraw();
		self = tOldSelf;
	}
	else
	{
		Menu_Warning(tObject, strcat("Class '", tObject.classname, "' has no spawn function!"));
	}
	tObject.mRunFlags = tObject.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
	// spawn event
	if (tObject.onSpawn)
		MenuScript_Run(tObject, tObject.onSpawn);
}

// update object positions
float Menu_Sys_UpdateObjectNode_UpdatePos(entity tObject)
{
	entity tChild, tParent;
	vector tVec, tAlign;
	float tScale;
	
	// scale, pos, size
	tParent = tObject._parent;
	tObject._scale_x = tObject.scalevec_x*tParent._scale_x;
	tObject._scale_y = tObject.scalevec_y*tParent._scale_y;
	tObject._pos_x = (tObject.pos_x + tParent.pad_x)*tParent._scale_x;
	tObject._pos_y = (tObject.pos_y + tParent.pad_y)*tParent._scale_y;
	tObject._size_x = tObject.size_x*tObject._scale_x;
	tObject._size_y = tObject.size_y*tObject._scale_y;
	// set axis and align
	if (tObject.mFlags & MENU_FLAG_ALIGNED)
		tAlign = tObject.align;
	else
		tAlign = tParent.alignment;
	if (tObject.axis != '0 0 0')
		tVec = tObject.axis;
	else
		tVec = '1 1 0' - tAlign;
	// calc standart positions
	tObject._pos_x = (tObject._pos_x*tVec_x + max(tParent._size_x - tObject._size_x, 0)*tAlign_x) - tObject._size_x*tObject.orient_x;
	tObject._pos_y = (tObject._pos_y*tVec_y + max(tParent._size_y - tObject._size_y, 0)*tAlign_y) - tObject._size_y*tObject.orient_y;
	// check if this is arranged item
	if ((tParent.mRunFlags & MENU_RUNFLAG_ARRANGEMENT) && Menu_IsArrangeable(tObject))
	{
		if (tParent.arrangement_x)
			tObject._pos_x = tObject._apos_x;
		if (tParent.arrangement_y)	
			tObject._pos_y = tObject._apos_y;
	}
	// set absolute positions
	tObject._absmin_x = tParent._absmin_x + tObject._pos_x;
	tObject._absmin_y = tParent._absmin_y + tObject._pos_y;
	tObject._absmax_x = tObject._absmin_x + tObject._size_x;
	tObject._absmax_y = tObject._absmin_y + tObject._size_y;
	// make arrange positions
	if ((tObject.mRunFlags & MENU_RUNFLAG_ARRANGEMENT) && !(tObject.mFlags & MENU_FLAG_NOCHILDREN))
	{
		tVec_x = tObject.pad_x*tObject._scale_x;
		tVec_y = tObject.pad_y*tObject._scale_y;
		for (tChild = tObject._child; tChild; tChild = tChild._next)
		{
			if (!Menu_IsArrangeable(tChild))
				continue;
			if (tObject.arrangement_x)
			{
				tScale = tChild.scalevec_x*tObject._scale_x;
				tVec_x = tVec_x + tChild.pos_x*tScale;
				tChild._apos_x = tVec_x;
				tVec_x = tVec_x + tChild.size_x*tScale;
			}
			if (tObject.arrangement_y)
			{
				tScale = tChild.scalevec_y*tObject._scale_y;
				tVec_y = tVec_y + tChild.pos_y*tScale;
				tChild._apos_y = tVec_y;
				tVec_y = tVec_y + tChild.size_y*tScale;
			}
		}
		return MENU_RUNFLAG_UPDATEPOS;
	}
	return 0;
}

// update object tree
void Menu_Sys_UpdateObjectNode(entity tObject)
{
	float tUpdFlags, tInheritUpdFlags;
	entity tOldSelf, tChild;
	
	// initialize new object
	if (tObject.mFlags & MENU_FLAG_NEW)
		Menu_UpdateObjectNode_SpawnClass(tObject);
	// hidden object or template won't update at all
	if (tObject.mRunFlags & (MENU_RUNFLAG_HIDDEN + MENU_RUNFLAG_TEMPLATE))
		return; 
	tUpdFlags = tObject.mRunFlags & (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
	// just update children?
	if (!tUpdFlags)
	{
		if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
		{
			for (tChild = tObject._child; tChild; tChild = tChild._next)
			{
				tChild.mRunFlags = tChild.mRunFlags | tInheritUpdFlags;
				Menu_Sys_UpdateObjectNode(tChild);
			}
		}
		return;
	}	
	// run big update
	tOldSelf = self;
	if (tUpdFlags & MENU_RUNFLAG_UPDATEOBJECT)
	{
		// run a pre-update
		if (tObject.onPreUpdate)
			MenuScript_Run(tObject, tObject.onPreUpdate);
		self = tObject;
		self.mPreUpdate();
	}
	// inherit update flags again as they may be changed in mPreUpdate
	tUpdFlags = tObject.mRunFlags & (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
	tObject.mRunFlags = tObject.mRunFlags - tUpdFlags;
	tInheritUpdFlags = (tUpdFlags & MENU_RUNFLAG_UPDATEPOS);
	// position update
	if (tUpdFlags & MENU_RUNFLAG_UPDATEPOS)
		tInheritUpdFlags = tInheritUpdFlags | Menu_Sys_UpdateObjectNode_UpdatePos(tObject);
	// update children
	if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
	{
		for (tChild = tObject._child; tChild; tChild = tChild._next)
		{
			tChild.mRunFlags = tChild.mRunFlags | tInheritUpdFlags;
			Menu_Sys_UpdateObjectNode(tChild);
		}
	}
	// post-update
	if (tUpdFlags & MENU_RUNFLAG_UPDATEOBJECT)
	{
		self = tObject;
		self.mPostUpdate();
		if (tObject.onPostUpdate)
			MenuScript_Run(tObject, tObject.onPostUpdate);
	}
	self = tOldSelf;
}

// draw object and it's children
void Menu_Sys_DrawObjectNode(entity tObject)
{
	entity tOldSelf, tChild;

	// hidden objects won't drawn
	if ((tObject.mRunFlags & (MENU_RUNFLAG_HIDDEN + MENU_RUNFLAG_TEMPLATE)))
		return;
	// check if clipped out
	if (Draw2D_Clip && !(tObject._absmax_x >= Draw2D_ClipPosX && tObject._absmin_x <= Draw2D_ClipSizeX && tObject._absmax_y >= Draw2D_ClipPosY && tObject._absmin_y <= Draw2D_ClipSizeY))
		return;
	//	return;
	// check for clipping
	Draw2D_BackUpClipArea();
	if (tObject.clip)
		Draw2D_ClipClipArea(tObject._absmin_x - tObject.clipMarginLeft, tObject._absmin_y - tObject.clipMarginRight, tObject._size_x + tObject.clipMarginLeft + tObject.clipMarginRight, tObject._size_y + tObject.clipMarginUp + tObject.clipMarginDown);
	// nodraw objects won't receive draw event, not draw embedded and can't clip children
	if (tObject.mFlags & MENU_FLAG_NODRAW)
	{
		if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
			for (tChild = tObject._child; tChild; tChild = tChild._next)
				if (!(tChild.mFlags & MENU_FLAG_EMBEDDED))
					Menu_Sys_DrawObjectNode(tChild);
	}
	else
	{
		// draw self
		tOldSelf = self;
		self = tObject;
		self.mDraw();
		self = tOldSelf;
		// draw embedded children
		if (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDED)
			for (tChild = tObject._child; tChild; tChild = tChild._next)
				if (tChild.mFlags & MENU_FLAG_EMBEDDED)
					Menu_Sys_DrawObjectNode(tChild);
		// onDraw event
		if (self.onDraw)
			MenuScript_Run(self, self.onDraw);
		// draw normal children with clipping
		if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
			for (tChild = tObject._child; tChild; tChild = tChild._next)
				if (!(tChild.mFlags & MENU_FLAG_EMBEDDED))
					Menu_Sys_DrawObjectNode(tChild);
		// post-draw
		tOldSelf = self;
		self = tObject;
		self.mPostDraw();
		self = tOldSelf;
		// onPostDraw event
		if (self.onPostDraw)
			MenuScript_Run(self, self.onPostDraw);
	}
	// restore clipping
	Draw2D_RestoreClipArea();
}

// check current state based on hotkey
float Menu_Sys_CheckHotkeyState(float tKeyCode)
{
	// key #0 is always pressed
	if (!tKeyCode)
		return 1;
		
	// negative keys means that this key should not be pressed
	if (tKeyCode < 0)
	{
		tKeyCode = fabs(tKeyCode);
		if (!Menu_Sys_KeyPressed(tKeyCode))
			return 1;
		return 0;
	}

	// standart check
	return Menu_Sys_KeyPressed(tKeyCode);
}

// process hotkey on object
float Menu_Sys_HotkeyOnNode(entity tObject, float tKeyCode)
{
	entity tOldSelf, tChild;
	float tKeyReturn, tRunHotKey, tHotKey;

	// Process this item
	tRunHotKey = 0;
	if (tKeyCode == fabs(tObject._hotkey1))
	{
		if (Menu_Sys_CheckHotkeyState(tObject._hotkey2) && Menu_Sys_CheckHotkeyState(tObject._hotkey3))
		{
			tKeyReturn = stof(MenuScript_Run(tObject, tObject.onHotkey));
			tRunHotKey = 1;
		}
	}
	else if (tKeyCode == fabs(tObject._hotkey2))
	{
		if (Menu_Sys_CheckHotkeyState(tObject._hotkey1) && Menu_Sys_CheckHotkeyState(tObject._hotkey3))
		{
			tKeyReturn = stof(MenuScript_Run(tObject, tObject.onHotkey));
			tRunHotKey = 1;
		}
	}
	else if (tKeyCode == fabs(tObject._hotkey3))
	{
		if (Menu_Sys_CheckHotkeyState(tObject._hotkey1) && Menu_Sys_CheckHotkeyState(tObject._hotkey2))
		{
			tKeyReturn = stof(MenuScript_Run(tObject, tObject.onHotkey));
			tRunHotKey = 1;
		}
	}
	
	// VorteX: once we have accepted hotkey, clear all or it's states
	if (tRunHotKey)
	{
		if (tObject._hotkey1 == tKeyCode)
			Menu_Sys_KeyUnpress(fabs(tObject._hotkey1));
		if (tObject._hotkey2 == tKeyCode)
			Menu_Sys_KeyUnpress(fabs(tObject._hotkey2));	
		if (tObject._hotkey3 == tKeyCode)
			Menu_Sys_KeyUnpress(fabs(tObject._hotkey3));
	}

	#ifdef MENU_DEVELOPER
	tOldSelf = self;
	self = tObject;
	Menu_Debugger_HotkeyEvent(KEYEVENT_HOLD, tKeyCode, tRunHotKey, tKeyReturn);
	self = tOldSelf;
	#endif
	
	// process embedded hotkeys
	if (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDEDHOTKEYS)
	{
		for (tChild = tObject._child; tChild; tChild = tChild._next)
		{
			if (tChild.mFlags & MENU_FLAG_EMBEDDED)
				continue; // embedded makes full additional key pass, so partial hotkey stuff are no needed
			if (tChild.mFlags & MENU_FLAG_EMBEDDEDHOTKEY)
				tKeyReturn = tKeyReturn | Menu_Sys_HotkeyOnNode(tChild, tKeyCode);
		}
	}
	
	return tKeyReturn;
}

// key event on object
// process key event on self, then on children and then on parent
float Menu_Sys_KeyEventOnNode(entity tObject, float tEvent, float tKeyCode, float tKeySealed, float tProcessEmbedded, float tProcessChildren, float tRaiseParents)
{
	entity tOldSelf, tChild, tParent, tProc;
	float tKeyReturn, tRunHotKey, tReturn;
	
	// keySeal
	tKeyReturn = tKeySealed;
	// hidden items don't process self-children keys, they can only raise parents
	if (!Menu_IsHidden(tObject))
	{
		tReturn = 0;
		tOldSelf = self;
		self = tObject;
		// raise onKey
		if (self.onKey)
		{
			MenuScript_SetVar("key", ftos(tKeyCode));
			MenuScript_SetVar("sealflags", ftos(tKeySealed));
			MenuScript_SetVar("release", ftos(tEvent));
			tReturn = tReturn | stof( MenuScript_Run(self, self.onKey) );
			tKeyCode = stof(MenuScript_GetVar("key"));
			tKeySealed = stof(MenuScript_GetVar("sealflags"));
			tEvent = stof(MenuScript_GetVar("release"));
		}
		// raise self key
		if (!(tReturn & KR_TRUE))
		{
			tOldSelf = self;
			self = tObject;
			tReturn = tReturn | self.mKey(tEvent, tKeyCode, tKeyReturn);
			if (tReturn & KR_TRUE)
				tReturn = tReturn | self.keySeal;
			tKeyReturn = tKeyReturn | tReturn;
			#ifdef MENU_DEVELOPER
			Menu_Debugger_KeyEvent(tEvent, tKeyCode, tKeyReturn);
			#endif
			// raise keyPress
			if (!(tReturn & KR_TRUE))
			{
				if (self.onKeyPress)
				{
					MenuScript_SetVar("key", ftos(tKeyCode));
					MenuScript_SetVar("sealflags", ftos(tKeySealed));
					MenuScript_SetVar("release", ftos(tEvent));
					tReturn = tReturn | stof( MenuScript_Run(self, self.onKeyPress) );
					tKeyCode = stof(MenuScript_GetVar("key"));
					tKeySealed = stof(MenuScript_GetVar("sealflags"));
					tEvent = stof(MenuScript_GetVar("release"));
				}
			}
		}
		self = tOldSelf;
		
		// raise hotkey
		// VorteX: the trick is that we process hotkeys on release
		// so we can have just shift hotkeys and shift+c
		if (tEvent == tObject.hotkeyEvent)
			if ((tObject.hotkey != "" && tObject.onHotkey) || (tProcessEmbedded && (tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDEDHOTKEYS)))
				tKeyReturn = tKeyReturn | Menu_Sys_HotkeyOnNode(tObject, tKeyCode);
		// check if process children
		if (tObject.mFlags & MENU_FLAG_NOCHILDREN)
			return tKeyReturn;
		// run key event on embedded children
		if (tProcessEmbedded && tObject.mRunFlags & MENU_RUNFLAG_HASEMBEDDED)
		{
			for (tChild = tObject._child; tChild && !tKeyReturn; tChild = tChild._next)
				if (tChild.mFlags & MENU_FLAG_EMBEDDED)
					tKeyReturn = tKeyReturn | Menu_Sys_KeyEventOnNode(tChild, tEvent, tKeyCode, tKeyReturn, 1, 1, 0);
		}
		// check if process normal children
		if (!tProcessChildren)
			return tKeyReturn;
		// run key event for normal children
		for (tChild = tObject._child; tChild && !tKeyReturn; tChild = tChild._next)
			if (!(tChild.mFlags & MENU_FLAG_EMBEDDED))
				tKeyReturn = tKeyReturn | Menu_Sys_KeyEventOnNode(tChild, tEvent, tKeyCode, tKeyReturn, 1, 1, 0);
	}
	// raise parents
	if (tRaiseParents)
	{
		tProc = tObject._proc;
		for(tParent = tObject._parent; !tKeyReturn && isentity(tParent) && tParent != tProc; tParent = tParent._parent)
			tKeyReturn = tKeyReturn | Menu_Sys_KeyEventOnNode(tParent, tEvent, tKeyCode, tKeyReturn, 1, 0, 0);
	}
	return tKeyReturn;
}

// process mouse
// returns object mouse pointer points at
entity Menu_Sys_ObjectNodeProcessMouse_Recursive(entity tObject, float tTraceType, float tTraceOnly)
{
	entity tProc, tChild, tSelected, tSelectedChild, tOldSelf;
	
	// not visible or not-active object
	if (tObject.mRunFlags & (MENU_RUNFLAG_HIDDEN + MENU_RUNFLAG_TEMPLATE))
	{
		tObject.mRunFlags = tObject.mRunFlags - (tObject.mRunFlags & MENU_RUNFLAG_MOUSEOVER);
		return null_entity;
	}
	
	// check if mouse pointer is over object
	tProc = tObject._proc;
	if (!sectorsoverlap(tProc.mousePos, tProc.mousePos, tObject._absmin, tObject._absmax))
	{
		// run mouse leave event
		if (!tTraceOnly && tObject.mRunFlags & MENU_RUNFLAG_MOUSEOVER)
		{
			tOldSelf = self;
			self = tObject;
			self.mMouseLeave();
			self = tOldSelf;
			tObject.mRunFlags = tObject.mRunFlags - MENU_RUNFLAG_MOUSEOVER;
			// state event
			Menu_Sys_RunState(tObject, MSU_EVENT, tObject.state, ":mouse-leave");
		}
		// check if mouse pos is on children unless clipping is active
		if (!tObject.clip)
		{
			if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
			{
				tSelectedChild = null_entity;
				for (tChild = tObject._child; tChild; tChild = tChild._next)
				{
					tSelected = Menu_Sys_ObjectNodeProcessMouse_Recursive(tChild, tTraceType, tTraceOnly);
					if (tSelected)
						tSelectedChild = tSelected;
				}
			}
			if (tSelectedChild)
				return tSelectedChild;
		}
		return null_entity;
	}

	// mouse-enter event
	if (!tTraceOnly && !(tObject.mRunFlags & MENU_RUNFLAG_MOUSEOVER))
	{
		tOldSelf = self;
		self = tObject;
		self.mMouseEnter();
		self = tOldSelf;
		tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_MOUSEOVER;
		// state event
		Menu_Sys_RunState(tObject, MSU_EVENT, tObject.state, ":mouse-enter");
	}
	
	// check if mouse pos is on children
	if (!(tObject.mFlags & MENU_FLAG_NOCHILDREN))
	{
		tSelectedChild = null_entity;
		for (tChild = tObject._child; tChild; tChild = tChild._next)
		{
			tSelected = Menu_Sys_ObjectNodeProcessMouse_Recursive(tChild, tTraceType, tTraceOnly);
			if (tSelected)
				tSelectedChild = tSelected;
		}
	}
	
	// run mouse move event
	if (!tTraceOnly)
	{
		tOldSelf = self;
		self = tObject;
		self.mMouseMove();
		self = tOldSelf;
		// state event
		Menu_Sys_RunState(tObject, MSU_EVENT, tObject.state, ":mouse-move");
	}
	
	if (tSelectedChild)
		return tSelectedChild;
	// don't trace against embedded for select trace mode
	if (tTraceType == MENU_MOUSETRACE_SELECT)
		if (tObject.mFlags & MENU_FLAG_EMBEDDED)
			return null_entity;
	if (!Menu_IsSelectable(tObject))
		if (!(tObject.mFlags & MENU_FLAG_BLOCKMOUSE))
			return null_entity;	
	return tObject;
}

// process mouse
// returns object mouse pointer points at
entity Menu_GetItem(string findstring);
entity Menu_Sys_ObjectNodeProcessMouse(entity tObject, float tTraceType, float tTraceOnly)
{
	entity tItem;
	
	tObject = Menu_Sys_ObjectNodeProcessMouse_Recursive(tObject, tTraceType, tTraceOnly);
//	tItem = Menu_GetItem("DrawSpace:Pages:MainIngame:ExitBox:Text");
//	tItem.setMethod(tItem, 0, "text", tObject.name);
	if (Menu_IsSelectable(tObject))
		if (!(tObject.mFlags & MENU_FLAG_BLOCKMOUSE))
			return tObject;	
	return null_entity;
}

/*
================================================================================

   MOUSE STUFF

================================================================================
*/

void() Menu_Sys_InitMouse =
{	
	menu_mousemove = '0 0 0';
	menu_mousepos = '0 0 0';
}

void() Menu_Sys_UpdateMousePos =
{
#ifdef TARG_MENUPROGS
	menu_mousemove = getmousepos();
	menu_mousemove_x = bound(0.0, menu_mousepos_x + menu_mousemove_x, menu_vid_conwidth - 2) - menu_mousepos_x;
	menu_mousemove_y = bound(0.0, menu_mousepos_y + menu_mousemove_y, menu_vid_conheight - 2) - menu_mousepos_y;
	menu_mousepos = menu_mousepos + menu_mousemove;
#else
	vector tNewMousePos;
	
	tNewMousePos = getmousepos();
	menu_mousemove = tNewMousePos - menu_mousepos;
	menu_mousepos = tNewMousePos;
	menu_mousepos_x = bound(0, menu_mousepos_x, menu_vid_conwidth - 2);
	menu_mousepos_y = bound(0, menu_mousepos_y, menu_vid_conheight - 2);
#endif
}

// enables cursor mode if any process uses a mouse
void() Menu_Sys_CheckMouseUse =
{
	entity tProc;
	float tUseMouseAny;
	
	// walk proc and draw them
	for (tProc = menu_proclist; tProc; tProc = tProc._next)
	{
		if (tProc.mFlags & MENU_PROCFLAG_HIDDEN)
			continue;
		if (!(tProc.mFlags & MENU_PROCFLAG_USEMOUSE))
			continue;	
		// found one
		menu_usemouse = 1;
		Menu_CallBack_SetCursor(menu_usemouse);
		return;
	}
	// no one uses a mouse
	menu_usemouse = 0;
	Menu_CallBack_SetCursor(menu_usemouse);
}

// set mouse using on process
void Menu_Sys_SetProcMouse(entity tProc, float tMouse)
{
	if (tMouse)
		tProc.mFlags = tProc.mFlags | MENU_PROCFLAG_USEMOUSE;
	else
		tProc.mFlags = tProc.mFlags - (tProc.mFlags & MENU_PROCFLAG_USEMOUSE);
	Menu_Sys_CheckMouseUse();
}

// set default mouse cursor
void Menu_Sys_SetProcMousecursor(entity tProc, string tCursorName)
{
	tProc.cursor = Draw2D_LoadCursor(tCursorName);
}

/*
================================================================================

   MENU PROCESSING

================================================================================
*/

float Menu_Sys_FindProc(string tProcName)
{
	entity tTarg;
	float tPos, tID;
	
	// by ID
	if (substring(tProcName, 0, 1) == "#")
	{
		tID = stof(substring(tProcName, 1, 1000));
		tPos = 0;
		for (tTarg = menu_proclist; tTarg; tTarg = tTarg._next)
		{
			if (tPos == tID)
			{
				foundproc = tTarg;
				return 1;
			}
			tPos++;
		}
		foundproc = null_entity;
		return 0;
	}
	
	// by Name
	for (tTarg = menu_proclist; tTarg; tTarg = tTarg._next)
	{
		if (tTarg.name == tProcName)
		{
			foundproc = tTarg;
			return 1;
		}
	}
	foundproc = null_entity;
	return 0;
}

entity Menu_Sys_GetProc(string tProcName)
{
	if (Menu_Sys_FindProc(tProcName))
		return foundproc;
	Menu_Crash(strcat("Menu_Sys_GetProc: cannot find ", tProcName, "\n"));
	return null_entity;
}

void Menu_Sys_ClearProc(entity tProc)
{
	entity tChild, tNextChild;
	
	// destroy classes
	for (tChild = tProc._classes; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Proc_DestroyClass(tChild);
	}
	// destroy methods
	for (tChild = tProc._methods; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyMethod(tChild);
	}
	// remove childs
	for (tChild = tProc._child; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyObject(tChild);
	}
}

void Menu_Sys_ClearProcObjects(entity tProc)
{
	entity tChild, tNextChild;
	
	for (tChild = tProc._child; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyObject(tChild);
	}
}

float Menu_Sys_DestroyProc(string tProcName)
{
	entity tProc;
	
	Menu_UtfDisable
	// check is existing
	if (!Menu_Sys_FindProc(tProcName))
	{
		Menu_Error(strcat("Menu_Proc_Destroy: no active processor with name '", tProcName, "'\n"));
		Menu_UtfRestore
		return 0 ;
	}
	tProc = foundproc;
	
	// raise destroy events
	menu_proc = tProc;
	tProc.mDestroy();
	Menu_ObjectLib_Shutdown();
	// clear proc and destroy
	Menu_Sys_ClearProc(tProc);
	Menu_Util_UnlinkFrom(tProc,null_entity,menu_proclist,_parent) 
	strunzone(tProc.name);
	// remove script workspace
	MenuScript_DeleteProg(tProc.procScriptProg);
	remove(tProc);
	Menu_UtfRestore
	return 1;
}
	
void Menu_Sys_SetProcFlags(entity tProc, float tFlags)
{
	float tScript;
	
	Menu_UtfDisable
	// flags < 0 means flag removal
	if (tFlags < 0)
		tFlags = tProc.mFlags - (tProc.mFlags & fabs(tFlags));
	if (tProc.mFlags == tFlags)
		return;
	// update when go out of sleep
	if (tProc.mFlags & MENU_PROCFLAG_HIDDEN)
	{
		if (!(tFlags & MENU_PROCFLAG_HIDDEN))
			tProc.mRunFlags = tProc.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
		MenuScript_RunEvent("Show");
	}
	else if (tFlags & MENU_PROCFLAG_HIDDEN)
		MenuScript_RunEvent("Hide");
	tProc.mFlags = tFlags;	
	// mouse use
	if (tFlags & MENU_PROCFLAG_USEMOUSE)
		Menu_Sys_SetProcMouse(tProc, 1);
	else
		Menu_Sys_SetProcMouse(tProc, 0);
	// check if mouse is enabled
	Menu_Sys_CheckMouseUse();
	Menu_UtfRestore
}

float Menu_Sys_GetProcFlags(entity tProc)
{
	return tProc.mFlags;
}

void Menu_Sys_SetProcCoordSpace(entity tProc, vector tCoordSpace)
{
	tProc._pos = tCoordSpace;
	tProc.size_x = 640;
	tProc.size_y = 480;
	tProc.scalevec_x = 640/tCoordSpace_x;
	tProc.scalevec_y = 480/tCoordSpace_y;
	tProc.mRunFlags = tProc.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
}

void Menu_Sys_SetProcScreenResAdaptation(entity tProc, string tMode)
{
	#define try(m,f) if (tMode == m) { tProc.mEvent = f; return; }
	try("stretch", Menu_Proc_ScreenResAdaptation_Stretch)
	try("con", Menu_Proc_ScreenResAdaptation_Con)
	try("pixelheight", Menu_Proc_ScreenResAdaptation_PixelHeight)
	try("conpixelheight", Menu_Proc_ScreenResAdaptation_ConPixelHeight)
	try("default", Menu_Proc_ScreenResAdaptation_ConPixelHeight)
	try("fix", Menu_Proc_ScreenResAdaptation_Fix)
	#undef try
	Menu_Warning(world, strcat("Menu_Sys_SetProcScreenResAdaptation: unknown mode '", tMode, "', falling back to default"));
	Menu_Sys_SetProcScreenResAdaptation(tProc, "default");
}

vector Menu_Sys_GetProcCoordSpace(entity tProc)
{
	return tProc._pos;
}

void Menu_Sys_SetProcFrameFunc(entity tProc, void() tFunc)
{
	tProc.mFrame = tFunc;
}

// register new menu processor
float Menu_Sys_NewProc(string tProcName, void() tInitFunc, void() tSpawnFunc)
{
	entity tProc, tProcEnt, tLastProcEnt;
	
	// check parameters
	if (!tInitFunc)
	{
		Menu_Error("Menu_Sys_NewProc: bad processor spawn function\n");
		return 0;
	}
	if (Menu_Sys_FindProc(tProcName))
	{
		Menu_Error(strcat("Menu_Sys_NewProc: name '", tProcName, "' already used\n"));
		return 0 ;
	}
	// spawn
	tProc = spawn();
	tProc.classname = "menu_proc";
	tProc.name = strzone(tProcName);
	tProc._uidcounter = 0;
	tProc.size_x = 640;
	tProc.size_y = 480;
	tProc.scalevec = '1 1 0';
	// create script workspace
	MenuScript_CreateProg(tProc, tProcName);
	// set default events
	tProc.mFrame = Menu_ProcFrame;
	tProc.mDestroy = Menu_ProcDestroy;
	tProc.mDraw = Menu_ProcDraw;
	tProc.mKey = Menu_ProcKey;
	Menu_Sys_SetProcCoordSpace(tProc, '1024 768 0');
	Menu_Sys_SetProcFlags(tProc, MENU_PROCFLAG_HIDDEN);
	Menu_Sys_SetProcScreenResAdaptation(tProc, "default");
	tProc.autoEvent = tProc.mEvent();
	Menu_Util_LinkInto(tProc,null_entity,menu_proclist,_parent) 
	// register default methods and run spawn function
	menu_proc = tProc;
	Menu_RegisterMethods();
	Menu_ProcInit();
	Menu_ObjectLib_Init();
	// run proc init
	tInitFunc();
	// run custom init event
	MenuScript_RunEvent("Init");
	// run one frame to make objects init themself
	menu_proc = tProc;
	tProc.mFrame();
	tProc.mDraw();
	// run spawn event
	MenuScript_RunEvent("Spawn");
	// process spawned, run function in case we want to link some stuff
	tSpawnFunc();
	return 1;
}

// returns 1 is menu processed key and it could be passed to the engine
// returns 0 if key was not passed
// returns -1 if key passed and it should not be stuffed to engine
float Menu_Sys_KeyEvent(float tEvent, float tKeyCode) =
{
	entity tProc;
	float tKeyReturnCode, tSealKeys;
	
	Menu_Sys_Key(tEvent, tKeyCode);
	// dont call menu events in console
	if (input_buttons & B_CONSOLE)
		return 0;
	// generate missed RELEASE key event for mouse wheel
	if ((tKeyCode == K_MWHEELDOWN || tKeyCode == K_MWHEELUP) && tEvent == KEYEVENT_RELEASE)
		Menu_AddKeyEvent(KEYEVENT_RELEASE, tKeyCode, "", 0.1);
	// do key event for menu processors
	for (tProc = menu_proclist; tProc; tProc = tProc._next)
	{
		if (tProc.mFlags & MENU_PROCFLAG_HIDDEN)
			continue;
		menu_proc = tProc;
		tKeyReturnCode = tKeyReturnCode | tProc.mKey(tEvent, tKeyCode, tKeyReturnCode);
		if (tProc.mFlags & MENU_PROCFLAG_SEALKEYS)
			tSealKeys = 1;
		if (tKeyReturnCode & KR_SEAL_PROC)
			break;
	}
	// release events are harmless to logic flow generally, and we can pass them to the engine
	if (tEvent == KEYEVENT_RELEASE)
		return 0;
	// return code
	if ((tKeyReturnCode & KR_SEAL_ENGINE) || tSealKeys) // seal engine keys
		return -1;
	if (tKeyReturnCode)
		return 1;
	return 0;
}

/*
================================================================================

   SCREENSPACE ADAPTATION
   
   TODO: FINISH

================================================================================
*/

// no adaptation
float() Menu_Proc_ScreenResAdaptation_Stretch 			= { return 1; }		
float() Menu_Proc_ScreenResAdaptation_Con 				= { return (menu_vid_conwidth/menu_vid_conheight)/(4/3); }		
float() Menu_Proc_ScreenResAdaptation_PixelHeight 		= { return cvar("vid_pixelheight"); }		
float() Menu_Proc_ScreenResAdaptation_ConPixelHeight 	= { return cvar("vid_pixelheight")*(menu_vid_conwidth/menu_vid_conheight)/(4/3); }		
float() Menu_Proc_ScreenResAdaptation_Fix 				= { return (4/3)/(menu_vid_width/menu_vid_height); }		

/*
================================================================================

   MENU API

================================================================================
*/

void Menu_API_Init(void(float tUseMouse) tSetCursorCallback) =
{
	Menu_UtfDisable
	menu_vid_width = cvar("vid_width");
	menu_vid_height = cvar("vid_height");
	menu_vid_conwidth = cvar("vid_conwidth");
	menu_vid_conheight = cvar("vid_conheight");

	Menu_CallBack_SetCursor = tSetCursorCallback;
	
	Menu_Sys_InitKeySystem();
	Menu_Sys_InitMouse();
	Menu_InitParser();
	Menu_InitExporter();
	Menu_InitActions();
#ifdef MENU_DEVELOPER
	Menu_Debugger_Init();
#endif
	Menu_UtfRestore
}

void() Menu_API_Shutdown =
{
	entity tChild, tNextChild;
	
	Menu_UtfDisable
	// destroy all events
	for (tChild = menu_eventpool; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyEvent(tChild);
	}
	menu_eventpool = null_entity;
	// shutdown all processes
	for (tChild = menu_proclist; tChild; tChild = tNextChild)
	{
		tNextChild = tChild._next;
		Menu_Sys_DestroyProc(tChild.name);
	}
	menu_proclist = null_entity;
#ifdef MENU_DEVELOPER
	Menu_Debugger_Shutdown();
#endif
	Menu_UtfRestore
}
	
void() Menu_API_Frame =
{
	entity tProc;
	vector tNewPos;
	float f;
	
	f = gettime(TIME_UPTIME);
	menuframetime = f - menutime;
	menutime = f;
	menu_vid_width = cvar("vid_width");
	menu_vid_height = cvar("vid_height");
	menu_vid_conwidth = cvar("vid_conwidth");
	menu_vid_conheight = cvar("vid_conheight");
	Menu_UtfDisable
	
	// mouse frame
	if (menu_usemouse)
		Menu_Sys_UpdateMousePos();
	// debugger pre draw
#ifdef MENU_DEVELOPER
	Menu_Debugger_PreFrame();
#endif	
	// walk proc and draw them
	for (tProc = menu_proclist; tProc; tProc = tProc._next)
	{
		// screen resolution adaptation mode
		f = tProc.mEvent();
		if (tProc.autoEvent != f)
		{
			tProc.autoEvent = f;
			tProc.mRunFlags = tProc.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
		}
		// frame
		menu_proc = tProc;
		tProc.mFrame();
		if (tProc.mFlags & MENU_PROCFLAG_HIDDEN)
			continue;
		// update mouse pos, convert to proc-space
		if (tProc.mFlags & MENU_PROCFLAG_USEMOUSE)
		{
			tNewPos_x = (menu_mousepos_x/menu_vid_conwidth)*tProc.size_x;
			tNewPos_y = (menu_mousepos_y/menu_vid_conheight)*tProc.size_y ;
			tProc.mouseMove = tNewPos - tProc.mousePos;
			tProc.mousePos = tNewPos;	
		}
		tProc.mDraw();
	}
	// run eventpool
	Menu_Sys_RunEvents();
	// debugger post draw
#ifdef MENU_DEVELOPER
	Menu_Debugger_PostFrame();
#endif
	Menu_UtfRestore
}

float Menu_API_Key(float tEvent, float tKeyCode) =
{
	float tKeyReturnCode;
	
	Menu_UtfDisable
	tKeyReturnCode = Menu_Sys_KeyEvent(tEvent, tKeyCode);
	Menu_UtfRestore
	return tKeyReturnCode;
}

// register new menu processor
float Menu_API_CreateProc(string tProcName, void() tInitFunc, void() tSpawnFunc)
{
	float tReturnCode;
	
	Menu_UtfDisable
	tReturnCode = Menu_Sys_NewProc(tProcName, tInitFunc, tSpawnFunc);
	Menu_UtfRestore
	return tReturnCode;
}

