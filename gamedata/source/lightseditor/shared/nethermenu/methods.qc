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

void Menu_Warning(entity tObject, string tStr);
void Menu_Error(string tStr);
void Menu_Crash(string tStr);
void Menu_Message(string tStr);

#define Menu_MethodSet float(entity tObject, string tValue)
#define Menu_MethodGet string(entity tObject)
#define Menu_MethodSetEvent void(entity tObject, float tOp, string tMethod, string tValue)
#define Menu_MethodGetEvent string(entity tObject, string tMethod)
.Menu_MethodSet mMethodSet; 		// set on method entity, property set
.Menu_MethodGet mMethodGet; 		// set on method entity, property get
.Menu_MethodSetEvent setMethod; 	// set on object, can be separate for each object
.Menu_MethodGetEvent getMethod; 	// set on object, can be separate for each object

// system.qc
float Menu_Sys_StringToKeyNum(string tKeyName);
void Menu_Sys_UnTagObject(entity tObject);
void Menu_Sys_TagObject(entity tObject);
void Menu_Sys_RunState(entity tObject, float tUpdateFlags, string tState, string tSubState);

// base.qc
float Menu_FindObject(entity tProc, entity tStart, string tNameSpace);

////////////////////////////////////////
// CODE
////////////////////////////////////////

// convert string op to numeric
float Menu_Sys_MethodOpForString(string S)
{
	if (S == "+") return MMA_SET;
	if (S == "+") return MMA_ADD;
	if (S == "-") return MMA_SUB;
	if (S == "*") return MMA_MUL;
	if (S == "/") return MMA_DIV;	
	return -1;
}

// convert numeric op to string
string Menu_Sys_MethodStringForOp(float O)
{
	if (O == MMA_ADD) return "+";
	if (O == MMA_SUB) return "-";
	if (O == MMA_MUL) return "*";
	if (O == MMA_DIV) return "/";	
	return "";
}

/*
================================================================================

   SYSTEM STUFF
   
================================================================================
*/

float Menu_Sys_FindMethod(entity tProc, string tName)
{
	entity tMethod;
	float tSubLen;
	
	// check for sub-method
	tSubLen = strlen(tName) - 2;
	if (substring(tName, tSubLen, 1) == "_")
		tName = substring(tName, 0, tSubLen);
	// try find method
	for (tMethod = tProc._methods; tMethod; tMethod = tMethod._next)
	{
		if (tMethod.name == tName)
		{
			foundmethod = tMethod;
			return 1;
		}
	}
	foundmethod = null_entity;
	return 0;
}

void Menu_Sys_RegisterMethod(entity tProc, string tName, float tType, Menu_MethodSet tSet, Menu_MethodGet tGet, float tRunFlags, void() tInit, void() tDestroy)
{
	entity tNewMethod;
	
	// do not register same method twice
	if (Menu_Sys_FindMethod(tProc, tName))
		return;
	// spawn new method
	tNewMethod = spawn();
	tNewMethod.classname = "menu_method";
	tNewMethod.name = strzone(tName);
	tNewMethod.mInit = tInit;
	tNewMethod.mMethodGet = tGet;
	tNewMethod.mMethodSet = tSet;
	tNewMethod.mDestroy = tDestroy;
	tNewMethod.mType = tType;
	tNewMethod.mRunFlags = tRunFlags;
	// link into process
	Menu_Util_LinkInto(tNewMethod, tProc, tProc._methods, _parent)
}

void Menu_Sys_DestroyMethod(entity tMethod)
{
	Menu_Util_UnlinkFrom(tMethod, tMethod._parent, tMethod._parent._methods, _parent)
	strunzone(tMethod.name);
	remove(tMethod);
}

void Menu_Sys_CopyMethods(entity tFrom, entity tTo)
{
	entity tMethod;
	for (tMethod = tFrom._proc._methods; tMethod; tMethod = tMethod._next)
		tMethod.mMethodSet(tTo, tMethod.mMethodGet(tFrom));
}

void Menu_Sys_CopyMethod(string tMethod, entity tFrom, entity tTo)
{
	if (!Menu_Sys_FindMethod(tFrom._proc, tMethod))
	{
		Menu_Warning(tFrom, strcat("Menu_Sys_CopyMethod: unknown method '", tMethod, "'"));
		return;
	}
	foundmethod.mMethodSet(tTo, foundmethod.mMethodGet(tFrom));
}

// default method-get
Menu_MethodGetEvent Menu_Sys_GetMethod =
{
	if (!Menu_Sys_FindMethod(tObject._proc, tMethod))
	{
		warning(strcat("Menu_Sys_GetMethod: unknown method '", tMethod, "' on ", tObject.classname, " - ", tObject.name));
		return "";
	}
	return foundmethod.mMethodGet(tObject);
}

// default method-set
Menu_MethodSetEvent Menu_Sys_SetMethod =
{
	float temp;
	vector v, v2;
	string s;
	entity m;

	// check if method exists
	if (!Menu_Sys_FindMethod(tObject._proc, tMethod))
	{
		warning(strcat("Menu_Sys_SetMethod: unknown method '", tMethod, "' on ", tObject.classname, " - ", tObject.name));
		return;
	}
	m = foundmethod;
	
	// run arithmetic
	if (tOp)
	{
		#define ArithmeticOp(t,stot) if (tOp == MMA_ADD) t = t + stot(tValue); else if (tOp == MMA_SUB) t = t - stot(tValue); else if (tOp == MMA_MUL) t = t * stot(tValue); else if (tOp == MMA_DIV) t = t / stot(tValue);

		if (m.mType == MMT_COLOR || m.mType == MMT_VECTOR)
		{
			temp = strlen(tMethod) - 2;
			if (substring(tMethod, temp, 1) == "_") 
			{	
				// vector component
				s = substring(tMethod, temp+1, 1);
				v = stov(m.mMethodGet(tObject));
				if (s == "r" || s == "x")
					{ ArithmeticOp(v_x, stof) }
				else if (s == "g" || s == "y")
					{ ArithmeticOp(v_y, stof) }
				else if (s == "b"|| s == "z")
					{ ArithmeticOp(v_z, stof) }
				else
				{
					Menu_Warning(tObject, strcat("Menu_Sys_RunMethod: unknown method '", tMethod, "'"));
					return;
				}
				tValue = vtos(v);
			}
			else 
			{
				// vector math
				v = stov(m.mMethodGet(tObject));
				if (tOp == MMA_ADD) 
					v = v + stov(tValue);
				else if (tOp == MMA_SUB) 
					v = v - stov(tValue); 
				else if (tOp == MMA_MUL) 
				{
					v2 = stov(tValue);
					v_x = v_x * v2_x; 
					v_y = v_y * v2_y; 
					v_z = v_z * v2_z; 
				}
				else if (tOp == MMA_DIV) 
				{
					v2 = stov(tValue);
					v_x = v_x / v2_x; 
					v_y = v_y / v2_y; 
					v_z = v_z / v2_z; 
				}
				tValue = vtos(v);
			}
			
		}
		else if (m.mType == MMT_FLOAT || m.mType == MMT_INTEGER)
		{
			// standart math op
			temp = stof(m.mMethodGet(tObject));
			ArithmeticOp(temp, stof)
			tValue = ftos(temp);
		}
		else if (tOp != MMA_SET) // only set is supported for others
			Menu_Warning(tObject, strcat("Menu_Sys_RunMethod: method '", tMethod, "' do not support '", Menu_Sys_MethodStringForOp(tOp), "' Op"));
			
		#undef ArithmeticOp
	}
	else if (m.mType == MMT_COLOR || m.mType == MMT_VECTOR)
	{
		// r/g/b for color, x/y/z for vector, float arithmatic
		temp = strlen(tMethod) - 2;
		if (substring(tMethod, temp, 1) == "_")
		{
			s = substring(tMethod, temp+1, 1);
			v = stov(m.mMethodGet(tObject));
			if (s == "r" || s == "x")
				v_x = stof(tValue);
			else if (s == "g" || s == "y")
				v_y = stof(tValue);
			else if (s == "b"|| s == "z")
				v_z = stof(tValue);
			else
			{
				Menu_Warning(tObject, strcat("Menu_Sys_RunMethod: unknown method '", tMethod, "'"));
				return;
			}
			tValue = vtos(v);
		}
	}
	
	// run method
	if (m.mMethodSet(tObject, tValue))
		tObject.mRunFlags = tObject.mRunFlags | m.mRunFlags;
}

/*
================================================================================

   BASE METHODS

================================================================================
*/

#define Menu_MethodSetFloat(p) float tTemp; tTemp = stof(tValue); if (tObject.p == tTemp) return 0; tObject.p = tTemp; return 1
#define Menu_MethodSetFlag(p,f) float tTemp; tTemp = stof(tValue); if (tTemp) { if (tObject.p & f) return 0; tObject.p = tObject.p | f; return 1; } if (!(tObject.p & f)) return 0; tObject.p = tObject.p - f; return 1
#define Menu_MethodSetVector(p) vector tVec; tVec = stov(tValue); if (tObject.p == tVec) return 0; tObject.p = tVec; return 1
#define Menu_MethodSetString(p) if (tObject.p == tValue) return 0; rezone(tObject.p, tValue); return 1
#define Menu_MethodSetScript(p) float v; v = stof(tValue); if (v) tObject.p = v; else tObject.p = MenuScript_Compile(tValue); return 1
#define Menu_MethodSetFont(p) if (tObject.p == tValue) return 0; rezone(tObject.p, tValue); Draw2D_LoadFont(tValue); return 1
#define Menu_MethodGetFloat(p) return ftos(tObject.p)
#define Menu_MethodGetScript(p) return ftos(tObject.p)
#define Menu_MethodGetFlag(p,f) return ftos((tObject.p & f))
#define Menu_MethodGetVector(p) return vtos(tObject.p)
#define Menu_MethodGetString(p) return tObject.p
#define Menu_MethodGetFont(p) return tObject.p

// alpha - set opacity of object
.float alpha;
void() Menu_Method_Alpha_Init = { self.alpha = 1; }
Menu_MethodSet Menu_Method_Alpha = { Menu_MethodSetFloat(alpha); }
Menu_MethodGet Menu_Method_AlphaGet = { Menu_MethodGetFloat(alpha); }

// scale - x and y scaling
.vector scalevec;
void() Menu_Method_Scale_Init = { self.scalevec = '1 1 0'; }
Menu_MethodSet Menu_Method_Scale = { Menu_MethodSetVector(scalevec); }
Menu_MethodGet Menu_Method_ScaleGet = { Menu_MethodGetVector(scalevec); }

// pos - relative to parent and align position
.vector pos;
Menu_MethodSet Menu_Method_Pos = { Menu_MethodSetVector(pos); }
Menu_MethodGet Menu_Method_PosGet = { Menu_MethodGetVector(pos); }

// pad - offset children by value
.vector pad;
Menu_MethodSet Menu_Method_Pad = { Menu_MethodSetVector(pad); }
Menu_MethodGet Menu_Method_PadGet = { Menu_MethodGetVector(pad); }

// size - item size
.vector size;
Menu_MethodSet Menu_Method_Size = { Menu_MethodSetVector(size); }
Menu_MethodGet Menu_Method_SizeGet = { Menu_MethodGetVector(size); }

// align - item align in parent box
.vector align;
Menu_MethodSet Menu_Method_Align = 
{ 
	vector tVec; 
	
	tVec = stov(tValue)*0.5; 
	if (tObject.align == tVec) 
		return 0; 
	tObject.align = tVec; 
	return 1;
}
Menu_MethodGet Menu_Method_AlignGet = { return vtos(tObject.align*2); }

// alignment - parent object will align all childs unless they have align set
.vector alignment;
Menu_MethodSet Menu_Method_Alignment = 
{ 
	vector tVec; 
	
	tVec = stov(tValue)*0.5; 
	if (tObject.alignment == tVec) 
		return 0; 
	tObject.alignment = tVec; 
	return 1;
}
Menu_MethodGet Menu_Method_AlignmentGet = { return vtos(tObject.alignment*2); }

// orient - orientation of object against it's origin
.vector orient;
Menu_MethodSet Menu_Method_Orient = 
{ 
	vector tVec; 
	
	tVec = stov(tValue)*0.5; 
	if (tObject.orient == tVec) 
		return 0; 
	tObject.orient = tVec; 
	return 1;
}
Menu_MethodGet Menu_Method_OrientGet = { return vtos(tObject.orient*2); }

// axis - set alignment and position axis
.vector axis;
Menu_MethodSet Menu_Method_Axis = { Menu_MethodSetVector(axis); }
Menu_MethodGet Menu_Method_AxisGet = { Menu_MethodGetVector(axis); }

// arrangement - objects auto-arrangement
.vector arrangement;
Menu_MethodSet Menu_Method_Arrangement = 
{ 
	vector tVec; 
	
	tVec = stov(tValue); 
	if (tObject.arrangement == tVec) 
		return 0; 
	tObject.arrangement = tVec; 
	if (tObject.arrangement_x || tObject.arrangement_y) 
		tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_ARRANGEMENT;
	else
		tObject.mRunFlags = tObject.mRunFlags - (tObject.mRunFlags & MENU_RUNFLAG_ARRANGEMENT);
	return 1;
}
Menu_MethodGet Menu_Method_ArrangementGet = { Menu_MethodGetVector(arrangement); }

// clip - set object clipping
.float clip;
Menu_MethodSet Menu_Method_Clip = { Menu_MethodSetFloat(clip); }
Menu_MethodGet Menu_Method_ClipGet = { Menu_MethodGetFloat(clip); }
.float clipMarginUp;
Menu_MethodSet Menu_Method_ClipMarginUp = { Menu_MethodSetFloat(clipMarginUp); }
Menu_MethodGet Menu_Method_ClipMarginUpGet = { Menu_MethodGetFloat(clipMarginUp); }
.float clipMarginDown;
Menu_MethodSet Menu_Method_ClipMarginDown = { Menu_MethodSetFloat(clipMarginDown); }
Menu_MethodGet Menu_Method_ClipMarginDownGet = { Menu_MethodGetFloat(clipMarginDown); }
.float clipMarginLeft;
Menu_MethodSet Menu_Method_ClipMarginLeft = { Menu_MethodSetFloat(clipMarginLeft); }
Menu_MethodGet Menu_Method_ClipMarginLeftGet = { Menu_MethodGetFloat(clipMarginLeft); }
.float clipMarginRight;
Menu_MethodSet Menu_Method_ClipMarginRight = { Menu_MethodSetFloat(clipMarginRight); }
Menu_MethodGet Menu_Method_ClipMarginRightGet = { Menu_MethodGetFloat(clipMarginRight); }

// onSpawn
// this script is launched when object is spawned
.float onSpawn;
Menu_MethodSet Menu_Method_OnSpawn = { Menu_MethodSetScript(onSpawn); }
Menu_MethodGet Menu_Method_OnSpawnGet = { Menu_MethodGetScript(onSpawn); }

// onPostSpawn
.float onPreSpawn;
Menu_MethodSet Menu_Method_OnPreSpawn = { Menu_MethodSetScript(onPreSpawn); }
Menu_MethodGet Menu_Method_OnPreSpawnGet = { Menu_MethodGetScript(onPreSpawn); }

// onPreUpdate
// called before object receives update event
.float onPreUpdate;
Menu_MethodSet Menu_Method_OnPreUpdate = { Menu_MethodSetScript(onPreUpdate); }
Menu_MethodGet Menu_Method_OnPreUpdateGet = { Menu_MethodGetScript(onPreUpdate); }

// onPostUpdate
// called after object receives update event
.float onPostUpdate;
Menu_MethodSet Menu_Method_OnPostUpdate = { Menu_MethodSetScript(onPostUpdate); }
Menu_MethodGet Menu_Method_OnPostUpdateGet = { Menu_MethodGetScript(onPostUpdate); }

// onDraw
// called after object got drawed
.float onDraw;
Menu_MethodSet Menu_Method_OnDraw = { Menu_MethodSetScript(onDraw); }
Menu_MethodGet Menu_Method_OnDrawGet = { Menu_MethodGetScript(onDraw); }

// onPostDraw
// called when object and children is drawed
.float onPostDraw;
Menu_MethodSet Menu_Method_OnPostDraw = { Menu_MethodSetScript(onPostDraw); }
Menu_MethodGet Menu_Method_OnPostDrawGet = { Menu_MethodGetScript(onPostDraw); }

// onShow
// called when object goes unhidden
.float onShow;
Menu_MethodSet Menu_Method_OnShow = { Menu_MethodSetScript(onShow); }
Menu_MethodGet Menu_Method_OnShowGet = { Menu_MethodGetScript(onShow); }

// onHide
// called when object or it's parent receives HIDDEN flag
.float onHide;
Menu_MethodSet Menu_Method_OnHide = { Menu_MethodSetScript(onHide); }
Menu_MethodGet Menu_Method_OnHideGet = { Menu_MethodGetScript(onHide); }

// onDestroy
// this script is launched when object is destroyed
.float onDestroy;
Menu_MethodSet Menu_Method_OnDestroy = { Menu_MethodSetScript(onDestroy); }
Menu_MethodGet Menu_Method_OnDestroyGet = { Menu_MethodGetScript(onDestroy); }

// onKey
// this script is called before actual key event, it could override passed key
// should return KR_* key process flags if key is processed to cancel main event
.float onKey;
Menu_MethodSet Menu_Method_OnKey = { Menu_MethodSetScript(onKey); }
Menu_MethodGet Menu_Method_OnKeyGet = { Menu_MethodGetScript(onKey); }

// onKeyPress
// this script is called after actual key event if key was not processed yet
// should return KR_* key process flags if key is processed
.float onKeyPress;
Menu_MethodSet Menu_Method_OnKeyPress = { Menu_MethodSetScript(onKeyPress); }
Menu_MethodGet Menu_Method_OnKeyPressGet = { Menu_MethodGetScript(onKeyPress); }

// keySeal - key sealing flags in case key is processed by object
.float keySeal;
void() Menu_Method_KeySeal_Init = { self.keySeal = KR_SEAL_ENGINE | KR_SEAL_PROC; }
Menu_MethodSet Menu_Method_KeySeal = { Menu_MethodSetFloat(keySeal); }
Menu_MethodGet Menu_Method_KeySealGet = { Menu_MethodGetFloat(keySeal); }

// hotkey - automatic key event
// maximum of 3 key combinations are allowed
.string hotkey;
.float _hotkey1; 
.float _hotkey2; 
.float _hotkey3; 
float Menu_Method_ReadHotKey(entity tObject, string tKey) =
{
	float tNegate, tKeyNum;

	// check for negating
	if (substring(tKey, 0, 1) == "!")
	{
		tKey = substring(tKey, 1, 10000);
		tNegate = -1;
	}
	else tNegate = 1;
	// assume it is a key num
	if (substring(tKey, 0, 1) == "#")
		return stof(substring(tKey, 1, 10000))*tNegate;
	// assume this is key num like shift, ctrl
	if (tKey == "")
		return 0;
	tKeyNum = Menu_Sys_StringToKeyNum(tKey);
	if (tKeyNum < 0)
		Menu_Warning(tObject, strcat("Menu_Method_HotKey: unknown key name '", tKey, "'"));
	return tKeyNum*tNegate;
}
void() Menu_Method_Hotkey_Init = { self.hotkey = newzone(); }
void() Menu_Method_Hotkey_Shutdown = { self.hotkey = newzone(); }
Menu_MethodSet _Menu_Method_Hotkey = { Menu_MethodSetString(hotkey); }
Menu_MethodSet Menu_Method_Hotkey = 
{ 
	float tLen;
	// parse into buffer
	tLen = tokenizebyseparator(tValue, "+");
	if (tLen > 3)
		Menu_Warning(tObject, "Hotkey: maximum number of 3 synchronous key pressings are allowed");
	tObject._hotkey1 = 0;
	tObject._hotkey2 = 0;
	tObject._hotkey3 = 0;
	if (tLen > 0)
		tObject._hotkey1 = Menu_Method_ReadHotKey(tObject, argv(0));
	if (tLen > 1)
		tObject._hotkey2 = Menu_Method_ReadHotKey(tObject, argv(1));
	if (tLen > 2)
		tObject._hotkey3 = Menu_Method_ReadHotKey(tObject, argv(2));
	// set hotkey
	Menu_MethodSetString(hotkey);
}
Menu_MethodGet Menu_Method_HotkeyGet = { Menu_MethodGetString(hotkey); }

// onHotkey
// this script is launched when hotkey are catched
.float onHotkey;
Menu_MethodSet Menu_Method_OnHotkey = { Menu_MethodSetScript(onHotkey); }
Menu_MethodGet Menu_Method_OnHotkeyGet = { Menu_MethodGetScript(onHotkey); }

// hotkeyEvent
// sets lead action used for hotkey
.float hotkeyEvent;
Menu_MethodSet Menu_Method_HotkeyEvent = { Menu_MethodSetFloat(hotkeyEvent); }
Menu_MethodGet Menu_Method_HotkeyEventGet = { Menu_MethodGetFloat(hotkeyEvent); }

// tag - item unical names and groups
.string tag;
void() Menu_Method_Tag_Init = { self.tag = strzone(""); }
void() Menu_Method_Tag_Shutdown = 
{
	Menu_Sys_UnTagObject(self);
	strunzone(self.tag); 
}
Menu_MethodSet Menu_Method_Tag = 
{
	if (tObject.tag == tValue) 
		return 0; 
	// change tag
	if (tValue == "") 
	{
		Menu_Sys_UnTagObject(tObject);
		return 1;
	}
	// set tag
	Menu_Sys_TagObject(tObject);	
	strunzone(tObject.tag); 
	tObject.tag = strzone(tValue); 
	return 1;
}
Menu_MethodGet Menu_Method_TagGet = { Menu_MethodGetString(tag); }

// custom item state method
void() Menu_Method_State_Init = { self.state = newzone(); }
void() Menu_Method_State_Shutdown = { unzone(self.state); }
Menu_MethodSet Menu_Method_State = 
{ 
	if (tObject.state == tValue) 
		return 0; 
	Menu_Sys_RunState(tObject, MSU_NORMAL, tValue, tObject.substate);
	return 1;
}
Menu_MethodGet Menu_Method_StateGet = { Menu_MethodGetString(state); }

// embed item to parent
Menu_MethodSet _Menu_Method_Embedded = { Menu_MethodSetFlag(mFlags, MENU_FLAG_EMBEDDED); }
Menu_MethodSet Menu_Method_Embedded = 
{ 
	float tTemp; 
	entity tChild;
	
	// set the flag
	tTemp = _Menu_Method_Embedded(tObject, tValue); 
	if (!tTemp) // nothing is changed
		return tTemp;
	// update parent runflags
	if (tObject.mFlags & MENU_FLAG_EMBEDDED)
	{
		if (isentity(tObject._parent) && tObject._parent != tObject._proc)
			tObject._parent.mRunFlags = tObject._parent.mRunFlags | MENU_RUNFLAG_HASEMBEDDED;
		else
			Menu_Warning(tObject, "Menu_Method_Embedded: bad parent!");
		return tTemp;
	}
	// not embedded
	// check is parent still have embedded children
	for (tChild = tObject._parent._child; tChild; tChild = tChild._next)
	{
		if (tChild.mFlags & MENU_FLAG_EMBEDDED)
		{
			// parent still needs to process them
			tObject._parent.mRunFlags = tObject._parent.mRunFlags | MENU_RUNFLAG_HASEMBEDDED;
			return tTemp;
		}
	}
	// no embedded items
	tObject._parent.mRunFlags = tObject._parent.mRunFlags - (tObject._parent.mRunFlags & MENU_RUNFLAG_HASEMBEDDED);
	return tTemp;
}
Menu_MethodGet Menu_Method_EmbeddedGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_EMBEDDED); }

// embed hotkeys
Menu_MethodSet _Menu_Method_EmbeddedHotkey = { Menu_MethodSetFlag(mFlags, MENU_FLAG_EMBEDDEDHOTKEY); }
Menu_MethodSet Menu_Method_EmbeddedHotkey = 
{ 
	float tTemp; 
	entity tChild;
	
	// set the flag
	tTemp = _Menu_Method_EmbeddedHotkey(tObject, tValue); 
	if (!tTemp) // nothing is changed
		return tTemp;
	// update parent runflags
	if (tObject.mFlags & MENU_FLAG_EMBEDDEDHOTKEY)
	{
		if (isentity(tObject._parent) && tObject._parent != tObject._proc)
			tObject._parent.mRunFlags = tObject._parent.mRunFlags | MENU_RUNFLAG_HASEMBEDDEDHOTKEYS;
		else
			Menu_Warning(tObject, "Menu_Method_EmbeddedHotkey: bad parent!");
		return tTemp;
	}
	// not embedded
	// check is parent still have embedded children
	for (tChild = tObject._parent._child; tChild; tChild = tChild._next)
	{
		if (tChild.mFlags & MENU_FLAG_EMBEDDEDHOTKEY)
		{
			// parent still needs to process them
			tObject._parent.mRunFlags = tObject._parent.mRunFlags | MENU_RUNFLAG_HASEMBEDDEDHOTKEYS;
			return tTemp;
		}
	}
	// no embedded items
	tObject._parent.mRunFlags = tObject._parent.mRunFlags - (tObject._parent.mRunFlags & MENU_RUNFLAG_HASEMBEDDEDHOTKEYS);
	return tTemp;
}
Menu_MethodGet Menu_Method_EmbeddedHotkeyGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_EMBEDDEDHOTKEY); }

// flag events
void Menu_Hide(entity tObject, string reason);
void Menu_Unhide(entity tObject, string reason);
Menu_MethodSet _Menu_Method_Hidden = { Menu_MethodSetFlag(mFlags, MENU_FLAG_HIDDEN); }
Menu_MethodSet Menu_Method_Hidden = 
{
	float f; 
	// set the flag
	f = _Menu_Method_Hidden(tObject, tValue); 
	if (tObject.mFlags & MENU_FLAG_HIDDEN)
	{
		Menu_Hide(tObject, "hideflag");
		return f;	
	}
	Menu_Unhide(tObject, "hideflag");
	return f;
}

Menu_MethodGet Menu_Method_HiddenGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_HIDDEN); }
Menu_MethodSet Menu_Method_NoDraw = { Menu_MethodSetFlag(mFlags, MENU_FLAG_NODRAW); }
Menu_MethodGet Menu_Method_NoDrawGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_NODRAW); }
Menu_MethodSet Menu_Method_NoWarnings = { Menu_MethodSetFlag(mFlags, MENU_FLAG_NOWARNINGS); }
Menu_MethodGet Menu_Method_NoWarningsGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_NOWARNINGS); }
Menu_MethodSet Menu_Method_Selectable = { Menu_MethodSetFlag(mFlags, MENU_FLAG_SELECTABLE); }
Menu_MethodGet Menu_Method_SelectableGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_SELECTABLE); }
Menu_MethodSet Menu_Method_Container = { Menu_MethodSetFlag(mFlags, MENU_FLAG_CONTAINER); }
Menu_MethodGet Menu_Method_ContainerGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_CONTAINER); }
Menu_MethodSet Menu_Method_NoChildren = { Menu_MethodSetFlag(mFlags, MENU_FLAG_NOCHILDREN); }
Menu_MethodGet Menu_Method_NoChildrenGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_NOCHILDREN); }
Menu_MethodSet Menu_Method_Aligned = { Menu_MethodSetFlag(mFlags, MENU_FLAG_ALIGNED); }
Menu_MethodGet Menu_Method_AlignedGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_ALIGNED); }
Menu_MethodSet Menu_Method_NoArrange = { Menu_MethodSetFlag(mFlags, MENU_FLAG_NOARRANGE); }
Menu_MethodGet Menu_Method_NoArrangeGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_NOARRANGE); }
Menu_MethodSet Menu_Method_BlockMouse = { Menu_MethodSetFlag(mFlags, MENU_FLAG_BLOCKMOUSE); }
Menu_MethodGet Menu_Method_BlockMouseGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_BLOCKMOUSE); }
Menu_MethodSet Menu_Method_MultiLine = { Menu_MethodSetFlag(mFlags, MENU_FLAG_MULTILINE);  }
Menu_MethodGet Menu_Method_MultiLineGet = { Menu_MethodGetFlag(mFlags, MENU_FLAG_MULTILINE); }

/*
================================================================================

  BACKGROUND METHODS
   
================================================================================
*/

.float bgAlpha;
Menu_MethodSet Menu_Method_BgAlpha = { Menu_MethodSetFloat(bgAlpha); }
Menu_MethodGet Menu_Method_BgAlphaGet = { Menu_MethodGetFloat(bgAlpha); }

.float bgDrawFlag;
Menu_MethodSet Menu_Method_BgDrawFlag = { Menu_MethodSetFloat(bgDrawFlag); }
Menu_MethodGet Menu_Method_BgDrawFlagGet = { Menu_MethodGetFloat(bgDrawFlag); }

.vector bgColor;	
void() Menu_Method_BgColor_Init = { self.bgColor = '1 1 1'; }
Menu_MethodSet Menu_Method_BgColor = { Menu_MethodSetVector(bgColor); }
Menu_MethodGet Menu_Method_BgColorGet = { Menu_MethodGetVector(bgColor); }

.string background;	
void() Menu_Method_Background_Init = { self.background = newzone(); }
void() Menu_Method_Background_Shutdown = { strunzone(self.background); }
Menu_MethodSet Menu_Method_Background = { Menu_MethodSetString(background); }
Menu_MethodGet Menu_Method_BackgroundGet = { Menu_MethodGetString(background); }

.vector bgPicSize;	
Menu_MethodSet Menu_Method_BgPicSize = { Menu_MethodSetVector(bgPicSize); }
Menu_MethodGet Menu_Method_BgPicSizeGet = { Menu_MethodGetVector(bgPicSize); }

.vector bgPicPos;
Menu_MethodSet Menu_Method_BgPicPos = { Menu_MethodSetVector(bgPicPos); }
Menu_MethodGet Menu_Method_BgPicPosGet = { Menu_MethodGetVector(bgPicPos); }

.vector bgPicRepeat;
Menu_MethodSet Menu_Method_BgPicRepeat = { Menu_MethodSetVector(bgPicRepeat); }
Menu_MethodGet Menu_Method_BgPicRepeatGet = { Menu_MethodGetVector(bgPicRepeat); }

/*
================================================================================

  PICTURE
   
================================================================================
*/

.float picAlpha;
void() Menu_Method_PicAlpha_Init = { self.picAlpha = 1; }
Menu_MethodSet Menu_Method_PicAlpha = { Menu_MethodSetFloat(picAlpha); }
Menu_MethodGet Menu_Method_PicAlphaGet = { Menu_MethodGetFloat(picAlpha); }

.float picDrawFlag;
Menu_MethodSet Menu_Method_PicDrawFlag = { Menu_MethodSetFloat(picDrawFlag); }
Menu_MethodGet Menu_Method_PicDrawFlagGet = { Menu_MethodGetFloat(picDrawFlag); }

.string picture;	
void() Menu_Method_Picture_Init = { self.picture = newzone(); }
void() Menu_Method_Picture_Shutdown = { strunzone(self.picture); }
Menu_MethodSet Menu_Method_Picture = { Menu_MethodSetString(picture); }
Menu_MethodGet Menu_Method_PictureGet = { Menu_MethodGetString(picture); }

.float picShadow;
Menu_MethodSet Menu_Method_PicShadow = { Menu_MethodSetFloat(picShadow); }
Menu_MethodGet Menu_Method_PicShadowGet = { Menu_MethodGetFloat(picShadow); }

.vector picShadowOfs;
void() Menu_Method_PicShadowOfs_Init = { self.picShadowOfs = '2 2 2'; }
Menu_MethodSet Menu_Method_PicShadowOfs = { Menu_MethodSetVector(picShadowOfs); }
Menu_MethodGet Menu_Method_PicShadowOfsGet = { Menu_MethodGetVector(picShadowOfs); }

.vector picColor;
void() Menu_Method_PicColor_Init = { self.picColor = '1 1 1'; }
Menu_MethodSet Menu_Method_PicColor = { Menu_MethodSetVector(picColor); }
Menu_MethodGet Menu_Method_PicColorGet = { Menu_MethodGetVector(picColor); }

.vector picAlign;
Menu_MethodSet Menu_Method_PicAlign = { Menu_MethodSetVector(picAlign);  }
Menu_MethodGet Menu_Method_PicAlignGet = { Menu_MethodGetVector(picAlign);  }

.vector picSize;
Menu_MethodSet Menu_Method_PicSize = { Menu_MethodSetVector(picSize); }
Menu_MethodGet Menu_Method_PicSizeGet = { Menu_MethodGetVector(picSize); }

.vector picPos;
Menu_MethodSet Menu_Method_PicPos = { Menu_MethodSetVector(picPos); }
Menu_MethodGet Menu_Method_PicPosGet = { Menu_MethodGetVector(picPos); }

/*
================================================================================

  FOREGROUND METHODS
   
================================================================================
*/

.float fgAlpha;
Menu_MethodSet Menu_Method_FgAlpha = { Menu_MethodSetFloat(fgAlpha); }
Menu_MethodGet Menu_Method_FgAlphaGet = { Menu_MethodGetFloat(fgAlpha); }

.float fgDrawFlag;
Menu_MethodSet Menu_Method_FgDrawFlag = { Menu_MethodSetFloat(fgDrawFlag); }
Menu_MethodGet Menu_Method_FgDrawFlagGet = { Menu_MethodGetFloat(fgDrawFlag); }

.vector fgColor;	
void() Menu_Method_FgColor_Init = { self.fgColor = '1 1 1'; }
Menu_MethodSet Menu_Method_FgColor = { Menu_MethodSetVector(fgColor); }
Menu_MethodGet Menu_Method_FgColorGet = { Menu_MethodGetVector(fgColor); }

.string foreground;	
void() Menu_Method_Foreground_Init = { self.foreground = newzone(); }
void() Menu_Method_Foreground_Shutdown = { strunzone(self.foreground); }
Menu_MethodSet Menu_Method_Foreground = { Menu_MethodSetString(foreground); }
Menu_MethodGet Menu_Method_ForegroundGet = { Menu_MethodGetString(foreground); }

.vector fgPicSize;	
Menu_MethodSet Menu_Method_FgPicSize = { Menu_MethodSetVector(fgPicSize); }
Menu_MethodGet Menu_Method_FgPicSizeGet = { Menu_MethodGetVector(fgPicSize); }

.vector fgPicPos;
Menu_MethodSet Menu_Method_FgPicPos = { Menu_MethodSetVector(fgPicPos); }
Menu_MethodGet Menu_Method_FgPicPosGet = { Menu_MethodGetVector(fgPicPos); }

.vector fgPicRepeat;
Menu_MethodSet Menu_Method_FgPicRepeat = { Menu_MethodSetVector(fgPicRepeat); }
Menu_MethodGet Menu_Method_FgPicRepeatGet = { Menu_MethodGetVector(fgPicRepeat); }


/*
================================================================================

  TEXT
   
================================================================================
*/

.string text;	
.string textMLC1, textMLC2;
.float textMLC;
void() Menu_Method_Text_Init = { self.text = newzone(); self.textMLC1 = newzone(); self.textMLC2 = newzone(); }
void() Menu_Method_Text_Shutdown = { unzone(self.text); unzone(self.textMLC1); unzone(self.textMLC2); }
Menu_MethodSet Menu_Method_Text = { Menu_MethodSetString(text); }
Menu_MethodGet Menu_Method_TextGet = { Menu_MethodGetString(text); }

.string textFont;	
void() Menu_Method_TextFont_Init = { self.textFont = newzone(); }
void() Menu_Method_TextFont_Shutdown = { unzone(self.textFont); }
Menu_MethodSet Menu_Method_TextFont = { Menu_MethodSetFont(textFont); }
Menu_MethodGet Menu_Method_TextFontGet = { Menu_MethodGetFont(textFont); }

.vector textFontSize;
void() Menu_Method_TextFontSize_Init = { self.textFontSize = '10 10 0'; }
Menu_MethodSet Menu_Method_TextFontSize = { Menu_MethodSetVector(textFontSize); }
Menu_MethodGet Menu_Method_TextFontSizeGet = { Menu_MethodGetVector(textFontSize); }

.float textShadow;
Menu_MethodSet Menu_Method_TextShadow = { Menu_MethodSetFloat(textShadow); }
Menu_MethodGet Menu_Method_TextShadowGet = { Menu_MethodGetFloat(textShadow); }

.vector textShadowOfs;
void() Menu_Method_TextShadowOfs_Init = { self.textShadowOfs = '2 2 2'; }
Menu_MethodSet Menu_Method_TextShadowOfs = { Menu_MethodSetVector(textShadowOfs); }
Menu_MethodGet Menu_Method_TextShadowOfsGet = { Menu_MethodGetVector(textShadowOfs); }

.vector textColor;
void() Menu_Method_TextColor_Init = { self.textColor = '1 1 1'; }
Menu_MethodSet Menu_Method_TextColor = { Menu_MethodSetVector(textColor); }
Menu_MethodGet Menu_Method_TextColorGet = { Menu_MethodGetVector(textColor); }

.vector textAlign;
Menu_MethodSet Menu_Method_TextAlign = { Menu_MethodSetVector(textAlign);  }
Menu_MethodGet Menu_Method_TextAlignGet = { Menu_MethodGetVector(textAlign);  }

.float textAlpha;
void() Menu_Method_TextAlpha_Init = { self.textAlpha = 1; }
Menu_MethodSet Menu_Method_TextAlpha = { Menu_MethodSetFloat(textAlpha); }
Menu_MethodGet Menu_Method_TextAlphaGet = { Menu_MethodGetFloat(textAlpha); }

.float textDrawFlag;
Menu_MethodSet Menu_Method_TextDrawFlag = { Menu_MethodSetFloat(textDrawFlag); }
Menu_MethodGet Menu_Method_TextDrawFlagGet = { Menu_MethodGetFloat(textDrawFlag); }

.vector textPos;
Menu_MethodSet Menu_Method_TextPos = { Menu_MethodSetVector(textPos); }
Menu_MethodGet Menu_Method_TextPosGet = { Menu_MethodGetVector(textPos); }

.vector textSize;
Menu_MethodSet Menu_Method_TextSize = { Menu_MethodSetVector(textSize); }
Menu_MethodGet Menu_Method_TextSizeGet = { Menu_MethodGetVector(textSize); }

.float lineSpacing;
Menu_MethodSet Menu_Method_LineSpacing = { Menu_MethodSetFloat(lineSpacing); }
Menu_MethodGet Menu_Method_LineSpacingGet = { Menu_MethodGetFloat(lineSpacing); }


/*
================================================================================

   TEXT EDIT
   
================================================================================
*/

.string edit;	
void() Menu_Method_Edit_Init = { self.edit = newzone(); }
void() Menu_Method_Edit_Shutdown = { unzone(self.edit); }
Menu_MethodSet Menu_Method_Edit = { Menu_MethodSetString(edit); }
Menu_MethodGet Menu_Method_EditGet = { Menu_MethodGetString(edit); }

.string editFont;	
void() Menu_Method_EditFont_Init = { self.editFont = newzone(); }
void() Menu_Method_EditFont_Shutdown = { unzone(self.editFont); }
Menu_MethodSet Menu_Method_EditFont = { Menu_MethodSetFont(editFont); }
Menu_MethodGet Menu_Method_EditFontGet = { Menu_MethodGetFont(editFont); }

.vector editFontSize;
void() Menu_Method_EditFontSize_Init = { self.editFontSize = '10 10 0'; }
Menu_MethodSet Menu_Method_EditFontSize = { Menu_MethodSetVector(editFontSize); }
Menu_MethodGet Menu_Method_EditFontSizeGet = { Menu_MethodGetVector(editFontSize); }

.float editShadow;
Menu_MethodSet Menu_Method_EditShadow = { Menu_MethodSetFloat(editShadow); }
Menu_MethodGet Menu_Method_EditShadowGet = { Menu_MethodGetFloat(editShadow); }

.vector editShadowOfs;
void() Menu_Method_EditShadowOfs_Init = { self.editShadowOfs = '2 2 2'; }
Menu_MethodSet Menu_Method_EditShadowOfs = { Menu_MethodSetVector(editShadowOfs); }
Menu_MethodGet Menu_Method_EditShadowOfsGet = { Menu_MethodGetVector(editShadowOfs); }

.vector editColor;
void() Menu_Method_EditColor_Init = { self.editColor = '1 1 1'; }
Menu_MethodSet Menu_Method_EditColor = { Menu_MethodSetVector(editColor); }
Menu_MethodGet Menu_Method_EditColorGet = { Menu_MethodGetVector(editColor); }

.vector editAlign;
Menu_MethodSet Menu_Method_EditAlign = { Menu_MethodSetVector(editAlign);  }
Menu_MethodGet Menu_Method_EditAlignGet = { Menu_MethodGetVector(editAlign);  }

.float editAlpha;
void() Menu_Method_EditAlpha_Init = { self.editAlpha = 1; }
Menu_MethodSet Menu_Method_EditAlpha = { Menu_MethodSetFloat(editAlpha); }
Menu_MethodGet Menu_Method_EditAlphaGet = { Menu_MethodGetFloat(editAlpha); }

.float editDrawFlag;
Menu_MethodSet Menu_Method_EditDrawFlag = { Menu_MethodSetFloat(editDrawFlag); }
Menu_MethodGet Menu_Method_EditDrawFlagGet = { Menu_MethodGetFloat(editDrawFlag); }

.vector editPos;
Menu_MethodSet Menu_Method_EditPos = { Menu_MethodSetVector(editPos); }
Menu_MethodGet Menu_Method_EditPosGet = { Menu_MethodGetVector(editPos); }

.vector editSize;
Menu_MethodSet Menu_Method_EditSize = { Menu_MethodSetVector(editSize); }
Menu_MethodGet Menu_Method_EditSizeGet = { Menu_MethodGetVector(editSize); }


/*
===================================================

 TRIGGERS

===================================================
*/

// onTrigger - menuscript that launched before target triggering
.float onTrigger;
Menu_MethodSet Menu_Method_OnTrigger = { Menu_MethodSetScript(onTrigger); }
Menu_MethodGet Menu_Method_OnTriggerGet = { Menu_MethodGetScript(onTrigger); }

// onClick - menuscript that launched if this object is clicked by mouse1 or enter key
.float onClick;
Menu_MethodSet Menu_Method_OnClick = { Menu_MethodSetScript(onClick); }
Menu_MethodGet Menu_Method_OnClickGet = { Menu_MethodGetScript(onClick); }

// onSelect
// onClick - when object is selected
.float onSelect;
Menu_MethodSet Menu_Method_OnSelect = { Menu_MethodSetScript(onSelect); }
Menu_MethodGet Menu_Method_OnSelectGet = { Menu_MethodGetScript(onSelect); }

// onDeselect
// onDeselect - when object is deselected
.float onDeselect;
Menu_MethodSet Menu_Method_OnDeselect = { Menu_MethodSetScript(onDeselect); }
Menu_MethodGet Menu_Method_OnDeselectGet = { Menu_MethodGetScript(onDeselect); }

// onEnter
// onEnter - used on PageSets and other objects
.float onEnter;
Menu_MethodSet Menu_Method_OnEnter = { Menu_MethodSetScript(onEnter); }
Menu_MethodGet Menu_Method_OnEnterGet = { Menu_MethodGetScript(onEnter); }

// onExit
// onExit - used on PageSet's and other objects
.float onExit;
Menu_MethodSet Menu_Method_OnExit = { Menu_MethodSetScript(onExit); }
Menu_MethodGet Menu_Method_OnExitGet = { Menu_MethodGetScript(onExit); }

// link - for item linking
.entity _link;
.string link;
void() Menu_Method_Link_Init = { self.link = newzone(); }
void() Menu_Method_Link_Shutdown = { unzone(self.link); }
Menu_MethodSet Menu_Method_Link = 
{ 
	Menu_FindObject(tObject._proc, tObject, tValue);
	tObject._link = foundobject;
	Menu_MethodSetString(link); 
}
Menu_MethodGet Menu_Method_LinkGet = { Menu_MethodGetString(link); }

// ref - referencing
.string reference;
void() Menu_Method_Reference_Init = { self.reference = newzone(); }
void() Menu_Method_Reference_Shutdown = { unzone(self.reference); }
Menu_MethodSet Menu_Method_Reference = { Menu_MethodSetString(reference); }
Menu_MethodGet Menu_Method_ReferenceGet = { Menu_MethodGetString(reference); }

// playsound - special method, it does not store anything and used to play sound when received, 
// it get procesed when entity changes/initiates self state
Menu_MethodSet Menu_Method_PlaySound = { if (tValue != "") localcmd(strcat("play2 \"", tValue, "\"\n")); return 0; }
Menu_MethodGet Menu_Method_PlaySoundGet = { return ""; }

// runscript - special method, runs script
// it get procesed when entity changes/initiates self state
Menu_MethodSet Menu_Method_RunScript = { float compiled; compiled = MenuScript_Compile(tValue); if (compiled > 0) { MenuScript_Run(tObject, compiled); buf_del(compiled); return 1; }  return 0; }
Menu_MethodGet Menu_Method_RunScriptGet = { return ""; }

/*
===================================================

 DATA

===================================================
*/

.string value;
void() Menu_Method_Value_Init = { self.value = newzone(); }
void() Menu_Method_Value_Shutdown = { unzone(self.value); }
Menu_MethodSet Menu_Method_Value = { Menu_MethodSetString(value); }
Menu_MethodGet Menu_Method_ValueGet = { Menu_MethodGetString(value); }

.string valueList;
.float valueListSize;
void() Menu_Method_ValueList_Init = { self.valueList = newzone(); }
void() Menu_Method_ValueList_Shutdown = { unzone(self.valueList); }
Menu_MethodSet Menu_Method_ValueList = { tObject.valueListSize = altstr_len(tValue); Menu_MethodSetString(valueList);  }
Menu_MethodGet Menu_Method_ValueListGet = { Menu_MethodGetString(valueList); }

.string descList;
void() Menu_Method_DescList_Init = { self.descList = newzone(); }
void() Menu_Method_DescList_Shutdown = { unzone(self.descList); }
Menu_MethodSet Menu_Method_DescList = { Menu_MethodSetString(descList); }
Menu_MethodGet Menu_Method_DescListGet = { Menu_MethodGetString(descList); }

.float valueMin;
Menu_MethodSet Menu_Method_ValueMin = { Menu_MethodSetFloat(valueMin); }
Menu_MethodGet Menu_Method_ValueMinGet = { Menu_MethodGetFloat(valueMin); }

.float valueMax;
Menu_MethodSet Menu_Method_ValueMax = { Menu_MethodSetFloat(valueMax); }
Menu_MethodGet Menu_Method_ValueMaxGet = { Menu_MethodGetFloat(valueMax); }

.float valueSteps;
Menu_MethodSet Menu_Method_ValueSteps = { Menu_MethodSetFloat(valueSteps); }
Menu_MethodGet Menu_Method_ValueStepsGet = { Menu_MethodGetFloat(valueSteps); }

.string defValue;
void() Menu_Method_DefValue_Init = { self.defValue = newzone(); }
void() Menu_Method_DefValue_Shutdown = { unzone(self.defValue); }
Menu_MethodSet Menu_Method_DefValue = { Menu_MethodSetString(defValue); }
Menu_MethodGet Menu_Method_DefValueGet = { Menu_MethodGetString(defValue); }

.string source;
void() Menu_Method_Source_Init = { self.source = newzone(); }
void() Menu_Method_Source_Shutdown = { unzone(self.source); }
Menu_MethodSet Menu_Method_Source = { Menu_MethodSetString(source); }
Menu_MethodGet Menu_Method_SourceGet = { Menu_MethodGetString(source); }

.string map;
void() Menu_Method_Map_Init = { self.map = newzone(); }
void() Menu_Method_Map_Shutdown = { unzone(self.map); }
Menu_MethodSet Menu_Method_Map = { Menu_MethodSetString(map); }
Menu_MethodGet Menu_Method_MapGet = { Menu_MethodGetString(map); }

.float autoEvent;
void() Menu_Method_AutoEvent_Init = { self.autoEvent = -1; }
Menu_MethodSet Menu_Method_AutoEvent = { Menu_MethodSetFloat(autoEvent); }
Menu_MethodGet Menu_Method_AutoEventGet = { Menu_MethodGetFloat(autoEvent); }

.float onFormat;
Menu_MethodSet Menu_Method_OnFormat = { Menu_MethodSetScript(onFormat); }
Menu_MethodGet Menu_Method_OnFormatGet = { Menu_MethodGetScript(onFormat); }

.float onInput;
Menu_MethodSet Menu_Method_OnInput = { Menu_MethodSetScript(onInput);  }
Menu_MethodGet Menu_Method_OnInputGet = { Menu_MethodGetScript(onInput); }

.float onOutput;
Menu_MethodSet Menu_Method_OnOutput = { Menu_MethodSetScript(onOutput); }
Menu_MethodGet Menu_Method_OnOutputGet = { Menu_MethodGetScript(onOutput); }

.float onRefresh;
Menu_MethodSet Menu_Method_OnRefresh = { Menu_MethodSetScript(onRefresh); }
Menu_MethodGet Menu_Method_OnRefreshGet = { Menu_MethodGetScript(onRefresh); }

.string comment;
void() Menu_Method_Comment_Init = { self.comment = newzone(); }
void() Menu_Method_Comment_Shutdown = { strunzone(self.comment); }
Menu_MethodSet Menu_Method_Comment = { Menu_MethodSetString(comment);  }
Menu_MethodGet Menu_Method_CommentGet = { Menu_MethodGetString(comment); }

/*
===================================================

 NAVIGATION

===================================================
*/

.entity navUp;
Menu_MethodSet Menu_Method_NavUp = 
{ 
	Menu_FindObject(tObject._proc, tObject, tValue);
	tObject.navUp = foundobject;
	return 1;
}
Menu_MethodGet Menu_Method_NavUpGet = { return tObject.navUp.name; }

.entity navDown;
Menu_MethodSet Menu_Method_NavDown = 
{ 
	Menu_FindObject(tObject._proc, tObject, tValue);
	tObject.navDown = foundobject;
	return 1;
}
Menu_MethodGet Menu_Method_NavDownGet = { return tObject.navDown.name; }

.entity navLeft;
Menu_MethodSet Menu_Method_NavLeft = 
{ 
	Menu_FindObject(tObject._proc, tObject, tValue);
	tObject.navLeft = foundobject;
	return 1;
}
Menu_MethodGet Menu_Method_NavLeftGet = { return tObject.navLeft.name; }

.entity navRight;
Menu_MethodSet Menu_Method_NavRight = 
{ 
	Menu_FindObject(tObject._proc, tObject, tValue);
	tObject.navRight = foundobject;
	return 1;
}
Menu_MethodGet Menu_Method_NavRightGet = { return tObject.navRight.name; }

/*
===================================================

 METHODS REGISTERING

===================================================
*/

void() Menu_RegisterMethods =
{
	// base
	Menu_Sys_RegisterMethod(menu_proc, "alpha", MMT_FLOAT, Menu_Method_Alpha, Menu_Method_AlphaGet, 0, Menu_Method_Alpha_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "scale", MMT_VECTOR, Menu_Method_Scale, Menu_Method_ScaleGet, MENU_RUNFLAG_UPDATEPOS, Menu_Method_Scale_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "pos", MMT_VECTOR, Menu_Method_Pos, Menu_Method_PosGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "pad", MMT_VECTOR, Menu_Method_Pad, Menu_Method_PadGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "size", MMT_VECTOR, Menu_Method_Size, Menu_Method_SizeGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "align", MMT_VECTOR, Menu_Method_Align, Menu_Method_AlignGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "alignment", MMT_VECTOR, Menu_Method_Alignment, Menu_Method_AlignmentGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "orient", MMT_VECTOR, Menu_Method_Orient, Menu_Method_OrientGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "axis", MMT_VECTOR, Menu_Method_Axis, Menu_Method_AxisGet, MENU_RUNFLAG_UPDATEPOS, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "arrangement", MMT_VECTOR, Menu_Method_Arrangement, Menu_Method_ArrangementGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "clip", MMT_BOOL, Menu_Method_Clip, Menu_Method_ClipGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "clipMarginUp", MMT_FLOAT, Menu_Method_ClipMarginUp, Menu_Method_ClipMarginUpGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "clipMarginDown", MMT_FLOAT, Menu_Method_ClipMarginDown, Menu_Method_ClipMarginDownGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "clipMarginLeft", MMT_FLOAT, Menu_Method_ClipMarginLeft, Menu_Method_ClipMarginLeftGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "clipMarginRight", MMT_FLOAT, Menu_Method_ClipMarginRight, Menu_Method_ClipMarginRightGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "keySeal", MMT_INTEGER, Menu_Method_KeySeal, Menu_Method_KeySealGet, 0, Menu_Method_KeySeal_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onSpawn", MMT_SCRIPT, Menu_Method_OnSpawn, Menu_Method_OnSpawnGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onPreSpawn", MMT_SCRIPT, Menu_Method_OnPreSpawn, Menu_Method_OnPreSpawnGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onPreUpdate", MMT_SCRIPT, Menu_Method_OnPreUpdate, Menu_Method_OnPreUpdateGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onPostUpdate", MMT_SCRIPT, Menu_Method_OnPostUpdate, Menu_Method_OnPostUpdateGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onDraw", MMT_SCRIPT, Menu_Method_OnDraw, Menu_Method_OnDrawGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onPostDraw", MMT_SCRIPT, Menu_Method_OnPostDraw, Menu_Method_OnPostDrawGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onShow", MMT_SCRIPT, Menu_Method_OnShow, Menu_Method_OnShowGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onHide", MMT_SCRIPT, Menu_Method_OnHide, Menu_Method_OnHideGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onDestroy", MMT_SCRIPT, Menu_Method_OnDestroy, Menu_Method_OnDestroyGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onKey", MMT_SCRIPT, Menu_Method_OnKey, Menu_Method_OnKeyGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onKeyPress", MMT_SCRIPT, Menu_Method_OnKeyPress, Menu_Method_OnKeyPressGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "tag", MMT_STRING, Menu_Method_Tag, Menu_Method_TagGet, 0, Menu_Method_Tag_Init, Menu_Method_Tag_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "state", MMT_STRING, Menu_Method_State, Menu_Method_StateGet, 0, Menu_Method_State_Init, Menu_Method_State_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "hotkey", MMT_STRING, Menu_Method_Hotkey, Menu_Method_HotkeyGet, 0, Menu_Method_Hotkey_Init, Menu_Method_Hotkey_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "onHotkey", MMT_SCRIPT, Menu_Method_OnHotkey, Menu_Method_OnHotkeyGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "hotkeyEvent", MMT_INTEGER, Menu_Method_HotkeyEvent, Menu_Method_HotkeyEventGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "hotkeyEmbed", MMT_FLAG, Menu_Method_EmbeddedHotkey, Menu_Method_EmbeddedHotkeyGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "selectable", MMT_FLAG, Menu_Method_Selectable, Menu_Method_SelectableGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "container", MMT_FLAG, Menu_Method_Container, Menu_Method_ContainerGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "hidden", MMT_FLAG, Menu_Method_Hidden, Menu_Method_HiddenGet, MENU_RUNFLAG_UPDATEOBJECT, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "nodraw", MMT_FLAG, Menu_Method_NoDraw, Menu_Method_NoDrawGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "blockmouse", MMT_FLAG, Menu_Method_BlockMouse, Menu_Method_BlockMouseGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "nowarnings", MMT_FLAG, Menu_Method_NoWarnings, Menu_Method_NoWarningsGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "embedded", MMT_FLAG, Menu_Method_Embedded, Menu_Method_EmbeddedGet, MENU_RUNFLAG_UPDATEOBJECT, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "noChildren", MMT_FLAG, Menu_Method_NoChildren, Menu_Method_NoChildrenGet, MENU_RUNFLAG_UPDATEOBJECT, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "aligned", MMT_FLAG, Menu_Method_Aligned, Menu_Method_AlignedGet, MENU_RUNFLAG_UPDATEOBJECT, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "noArrange", MMT_FLAG, Menu_Method_NoArrange, Menu_Method_NoArrangeGet, MENU_RUNFLAG_UPDATEOBJECT, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "multiLine", MMT_FLAG, Menu_Method_MultiLine, Menu_Method_MultiLineGet, 0, null_function, null_function);
	// navigation
	Menu_Sys_RegisterMethod(menu_proc, "navUp", MMT_STRING, Menu_Method_NavUp, Menu_Method_NavUpGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "navDown", MMT_STRING, Menu_Method_NavDown, Menu_Method_NavDownGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "navLeft", MMT_STRING, Menu_Method_NavLeft, Menu_Method_NavLeftGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "navRight", MMT_STRING, Menu_Method_NavRight, Menu_Method_NavRightGet, 0, null_function, null_function);
	// background
	Menu_Sys_RegisterMethod(menu_proc, "bgAlpha", MMT_FLOAT, Menu_Method_BgAlpha, Menu_Method_BgAlphaGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "bgDrawFlag", MMT_INTEGER, Menu_Method_BgDrawFlag, Menu_Method_BgDrawFlagGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "bgColor", MMT_COLOR, Menu_Method_BgColor, Menu_Method_BgColorGet, 0, Menu_Method_BgColor_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "background", MMT_STRING, Menu_Method_Background, Menu_Method_BackgroundGet, 0, Menu_Method_Background_Init, Menu_Method_Background_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "bgSize", MMT_VECTOR, Menu_Method_BgPicSize, Menu_Method_BgPicSizeGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "bgPos", MMT_VECTOR, Menu_Method_BgPicPos, Menu_Method_BgPicPosGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "bgRepeat", MMT_VECTOR, Menu_Method_BgPicRepeat, Menu_Method_BgPicRepeatGet, 0, null_function, null_function);
	// picture
	Menu_Sys_RegisterMethod(menu_proc, "picAlpha", MMT_FLOAT, Menu_Method_PicAlpha, Menu_Method_PicAlphaGet, 0, Menu_Method_PicAlpha_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picDrawFlag", MMT_INTEGER, Menu_Method_PicDrawFlag, Menu_Method_PicDrawFlagGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picture", MMT_STRING, Menu_Method_Picture, Menu_Method_PictureGet, 0, Menu_Method_Picture_Init, Menu_Method_Picture_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "picColor", MMT_COLOR, Menu_Method_PicColor, Menu_Method_PicColorGet, 0, Menu_Method_PicColor_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picShadow", MMT_FLOAT, Menu_Method_PicShadow, Menu_Method_PicShadowGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picShadowOfs", MMT_VECTOR, Menu_Method_PicShadowOfs, Menu_Method_PicShadowOfsGet, 0, Menu_Method_PicShadowOfs_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picAlign", MMT_VECTOR, Menu_Method_PicAlign, Menu_Method_PicAlignGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picSize", MMT_VECTOR, Menu_Method_PicSize, Menu_Method_PicSizeGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "picPos", MMT_VECTOR, Menu_Method_PicPos, Menu_Method_PicPosGet, 0, null_function, null_function);
	// foreground
	Menu_Sys_RegisterMethod(menu_proc, "fgAlpha", MMT_FLOAT, Menu_Method_FgAlpha, Menu_Method_FgAlphaGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "fgDrawFlag", MMT_INTEGER, Menu_Method_FgDrawFlag, Menu_Method_FgDrawFlagGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "fgColor", MMT_COLOR, Menu_Method_FgColor, Menu_Method_FgColorGet, 0, Menu_Method_FgColor_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "foreground", MMT_STRING, Menu_Method_Foreground, Menu_Method_ForegroundGet, 0, Menu_Method_Foreground_Init, Menu_Method_Foreground_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "fgSize", MMT_VECTOR, Menu_Method_FgPicSize, Menu_Method_FgPicSizeGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "fgPos", MMT_VECTOR, Menu_Method_FgPicPos, Menu_Method_FgPicPosGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "fgRepeat", MMT_VECTOR, Menu_Method_FgPicRepeat, Menu_Method_FgPicRepeatGet, 0, null_function, null_function);
	// text
	Menu_Sys_RegisterMethod(menu_proc, "text", MMT_STRING, Menu_Method_Text, Menu_Method_TextGet, 0, Menu_Method_Text_Init, Menu_Method_Text_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "textFont", MMT_STRING, Menu_Method_TextFont, Menu_Method_TextFontGet, 0, Menu_Method_TextFont_Init, Menu_Method_TextFont_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "textFontSize", MMT_VECTOR, Menu_Method_TextFontSize, Menu_Method_TextFontSizeGet, 0, Menu_Method_TextFontSize_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textShadow", MMT_FLOAT, Menu_Method_TextShadow, Menu_Method_TextShadowGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textShadowOfs", MMT_VECTOR, Menu_Method_TextShadowOfs, Menu_Method_TextShadowOfsGet, 0, Menu_Method_TextShadowOfs_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textColor", MMT_COLOR, Menu_Method_TextColor, Menu_Method_TextColorGet, 0, Menu_Method_TextColor_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textAlign", MMT_VECTOR, Menu_Method_TextAlign, Menu_Method_TextAlignGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textAlpha", MMT_FLOAT, Menu_Method_TextAlpha, Menu_Method_TextAlphaGet, 0, Menu_Method_TextAlpha_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textDrawFlag", MMT_INTEGER, Menu_Method_TextDrawFlag, Menu_Method_TextDrawFlagGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textPos", MMT_VECTOR, Menu_Method_TextPos, Menu_Method_TextPosGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "textSize", MMT_VECTOR, Menu_Method_TextSize, Menu_Method_TextSizeGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "lineSpacing", MMT_FLOAT, Menu_Method_LineSpacing, Menu_Method_LineSpacingGet, 0, null_function, null_function);
	// editbox
	Menu_Sys_RegisterMethod(menu_proc, "edit", MMT_STRING, Menu_Method_Edit, Menu_Method_EditGet, 0, Menu_Method_Edit_Init, Menu_Method_Edit_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "editFont", MMT_STRING, Menu_Method_EditFont, Menu_Method_EditFontGet, 0, Menu_Method_EditFont_Init, Menu_Method_EditFont_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "editFontSize", MMT_VECTOR, Menu_Method_EditFontSize, Menu_Method_EditFontSizeGet, 0, Menu_Method_EditFontSize_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editShadow", MMT_FLOAT, Menu_Method_EditShadow, Menu_Method_EditShadowGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editShadowOfs", MMT_VECTOR, Menu_Method_EditShadowOfs, Menu_Method_EditShadowOfsGet, 0, Menu_Method_EditShadowOfs_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editColor", MMT_COLOR, Menu_Method_EditColor, Menu_Method_EditColorGet, 0, Menu_Method_EditColor_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editAlign", MMT_VECTOR, Menu_Method_EditAlign, Menu_Method_EditAlignGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editAlpha", MMT_FLOAT, Menu_Method_EditAlpha, Menu_Method_EditAlphaGet, 0, Menu_Method_EditAlpha_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editDrawFlag", MMT_INTEGER, Menu_Method_EditDrawFlag, Menu_Method_EditDrawFlagGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editPos", MMT_VECTOR, Menu_Method_EditPos, Menu_Method_EditPosGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "editSize", MMT_VECTOR, Menu_Method_EditSize, Menu_Method_EditSizeGet, 0, null_function, null_function);
	// trigger
	Menu_Sys_RegisterMethod(menu_proc, "link", MMT_STRING, Menu_Method_Link, Menu_Method_LinkGet, 0, Menu_Method_Link_Init, Menu_Method_Link_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "reference", MMT_STRING, Menu_Method_Reference, Menu_Method_ReferenceGet, 0, Menu_Method_Reference_Init, Menu_Method_Reference_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "onTrigger", MMT_SCRIPT, Menu_Method_OnTrigger, Menu_Method_OnTriggerGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onClick", MMT_SCRIPT, Menu_Method_OnClick, Menu_Method_OnClickGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onSelect", MMT_SCRIPT, Menu_Method_OnSelect, Menu_Method_OnSelectGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onDeselect", MMT_SCRIPT, Menu_Method_OnDeselect, Menu_Method_OnDeselectGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onEnter", MMT_SCRIPT, Menu_Method_OnEnter, Menu_Method_OnEnterGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onExit", MMT_SCRIPT, Menu_Method_OnExit, Menu_Method_OnExitGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "playSound", MMT_NULL, Menu_Method_PlaySound, Menu_Method_PlaySoundGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "runScript", MMT_SCRIPT, Menu_Method_RunScript, Menu_Method_RunScriptGet, 0, null_function, null_function);
	// data
	Menu_Sys_RegisterMethod(menu_proc, "value", MMT_STRING, Menu_Method_Value, Menu_Method_ValueGet, 0, Menu_Method_Value_Init, Menu_Method_Value_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "valueList", MMT_STRING, Menu_Method_ValueList, Menu_Method_ValueListGet, 0, Menu_Method_ValueList_Init, Menu_Method_ValueList_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "descList", MMT_STRING, Menu_Method_DescList, Menu_Method_DescListGet, 0, Menu_Method_DescList_Init, Menu_Method_DescList_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "onFormat", MMT_STRING, Menu_Method_OnFormat, Menu_Method_OnFormatGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "valueMin", MMT_STRING, Menu_Method_ValueMin, Menu_Method_ValueMinGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "valueMax", MMT_STRING, Menu_Method_ValueMax, Menu_Method_ValueMaxGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "valueSteps", MMT_STRING, Menu_Method_ValueSteps, Menu_Method_ValueStepsGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "defValue", MMT_STRING, Menu_Method_DefValue, Menu_Method_DefValueGet, 0, Menu_Method_DefValue_Init, Menu_Method_DefValue_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "source", MMT_STRING, Menu_Method_Source, Menu_Method_SourceGet, 0, Menu_Method_Source_Init, Menu_Method_Source_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "map", MMT_STRING, Menu_Method_Map, Menu_Method_MapGet, 0, Menu_Method_Map_Init, Menu_Method_Map_Shutdown);
	Menu_Sys_RegisterMethod(menu_proc, "autoEvent", MMT_INTEGER, Menu_Method_AutoEvent, Menu_Method_AutoEventGet, 0, Menu_Method_AutoEvent_Init, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onInput", MMT_SCRIPT, Menu_Method_OnInput, Menu_Method_OnInputGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onOutput", MMT_SCRIPT, Menu_Method_OnOutput, Menu_Method_OnOutputGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "onRefresh", MMT_SCRIPT, Menu_Method_OnRefresh, Menu_Method_OnRefreshGet, 0, null_function, null_function);
	Menu_Sys_RegisterMethod(menu_proc, "comment", MMT_STRING, Menu_Method_Comment, Menu_Method_CommentGet, 0, Menu_Method_Comment_Init, Menu_Method_Comment_Shutdown);
}