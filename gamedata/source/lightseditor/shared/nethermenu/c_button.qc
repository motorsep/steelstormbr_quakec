////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
 Button
 
 Draws background->picture->text
 selectable
 text is centered by default
 
 triggers it's target when clicked
 
 can be connected to 'switch' data transformer
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

.float _state;
#define BUTTON_STATE_SELECTED			1
#define BUTTON_STATE_PRESSED			2
#define BUTTON_STATE_BINDING			4
#define BUTTON_STATE_BINDING_KEYPRESSED	8

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
===================================================

 DATA

===================================================
*/

// void(entity tSource)
Menu_DataRefresh Object_Button_RefreshData =
{
	if (self._state & BUTTON_STATE_BINDING)
		return;
	self.setMethod(self, MMA_SET, "text", Menu_DataSource_GetDescValue(self, tSource));
}

Menu_MethodSetEvent Object_Button_SetMethod =
{
	if (tMethod == "text") // update text
		tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT;
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

/*
===================================================

 KEY & CLICK & MOUSE

===================================================
*/

Menu_SelectEvent Object_Button_Select =
{
	if (!(self._state & BUTTON_STATE_SELECTED))
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":select");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");	
		self._state = self._state | BUTTON_STATE_SELECTED;
	}
	return 1; // allow select
}

Menu_SelectEvent Object_Button_Deselect =
{
	if (self._state & BUTTON_STATE_BINDING)
		return 0; // not allow selecting
	if (self._state & BUTTON_STATE_SELECTED)
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":deselect");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");	
		self._state = self._state - BUTTON_STATE_SELECTED;
	}
	return 1; // allow deselect
}

void() Object_Button_BeginKeyBinding =
{
	self._state = self._state | BUTTON_STATE_BINDING;
	Menu_Sys_RunState(self, MSU_EVENT, self.state, ":bindbegin");	
	Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":binding");
}

void() Object_Button_EndKeyBinding = 
{
	self._state = self._state - (self._state & (BUTTON_STATE_BINDING + BUTTON_STATE_BINDING_KEYPRESSED));
	Menu_Sys_RunState(self, MSU_EVENT, self.state, ":bindend");	
	if (self._state & BUTTON_STATE_SELECTED)
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");	
	else
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");	
}

Menu_MouseClickEvent Object_Button_Click =
{
	if (self._state & BUTTON_STATE_BINDING)
		return KR_TRUE;
	
	if (tEvent == KEYEVENT_RELEASE)
	{
		Menu_Sys_RunState(self, MSU_EVENT, self.state, ":release");
		if (self._state & BUTTON_STATE_SELECTED)
			Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");	
		else
			Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");	
		// cast trigger event
		if (tMouseOver && (self._state & BUTTON_STATE_PRESSED))
		{
			Menu_TriggerCast(self);
			self._state = self._state - (self._state & BUTTON_STATE_PRESSED);
			return KR_TRUE;
		}
		return KR_FALSE;
	}
	if (tEvent == KEYEVENT_HOLD && tMouseOver)
	{
		Menu_Sys_RunState(self, MSU_EVENT, self.state, ":press");
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":pressed");
		self._state = self._state | BUTTON_STATE_PRESSED;
		if (isentity(self._datasource))
		{
			if (self._datasource.classname == "DataSource_Slider" || 
				self._datasource.classname == "DataSource_List" || 
				self._datasource.classname == "DataSource_ListCombiner")
			{	
				if (tKeyCode == K_MOUSE1 || tKeyCode == K_ENTER)
					Menu_DataSource_Advance(self, self._datasource, 1, 1, self.autoEvent);
				else if (tKeyCode == K_MOUSE2)
					Menu_DataSource_Advance(self, self._datasource, -1, 1, self.autoEvent);
			}
			else if (self._datasource.classname == "DataSource_BindList" ||
				self._datasource.classname == "DataSource_Text")
				Object_Button_BeginKeyBinding();
		}
		return KR_TRUE;
	}
	return KR_FALSE;
}

Menu_KeyEvent Object_Button_Key = 
{
	float tKeyNum;

	// waiting for bind assign
	if (self._state & BUTTON_STATE_BINDING)
	{
		// VorteX: we catching keys on release event to
		// make full key path (hold-release) assembled
		// otherwise some user-defined constructions with hold/release customisations will glitch
		if (tEvent == KEYEVENT_HOLD)
			self._state = self._state | BUTTON_STATE_BINDING_KEYPRESSED;
		else if (tEvent == KEYEVENT_RELEASE && (self._state & BUTTON_STATE_BINDING_KEYPRESSED))
		{
			Object_Button_EndKeyBinding();
			if (self._datasource.classname == "DataSource_BindList" || self._datasource.classname == "DataSource_Text")
			{
				if (tKeyCode == K_ESCAPE)
					Menu_DataSource_AddBinding(self, self._datasource, "", self.autoEvent);
				else
					Menu_DataSource_AddBinding(self, self._datasource, ftos(tKeyCode), self.autoEvent);
			}
		}
		return KR_TRUE | KR_SEAL_ALL;
	}
	// for bindlisting - clear binding on del and escape
	if (tKeyCode == K_BACKSPACE)
	{
		if (self._datasource.classname == "DataSource_BindList" || self._datasource.classname == "DataSource_Text")
		{
			Menu_DataSource_ClearBindings(self, self._datasource, self.autoEvent);
			return KR_TRUE;
		}
	}
	// click event on enter or mouse click
	if (tKeyCode == K_ENTER)
	{
		Object_Button_Click(tEvent, tKeyCode, KR_FALSE, 1);
		return KR_TRUE;
	}
	if (tKeyCode == K_MOUSE1)
		return Menu_MouseClick(self, tEvent, tKeyCode, 1);
	return KR_FALSE;
}

/*
===================================================

 DRAW

===================================================
*/

void() Object_Button_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Picture_Draw();
	ObjectLib_Text_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_Button_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
}

/*
===================================================

 UPDATE

===================================================
*/

void() Object_Button_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

/*
===================================================

 SPAWN

===================================================
*/

void() Object_Button_Spawn =
{
	self._state = 0;
		
	self.mClick = Object_Button_Click;
	self.mKey = Object_Button_Key;
	self.mSelect = Object_Button_Select;
	self.mDeSelect = Object_Button_Deselect;
	self.mDataRefresh = Object_Button_RefreshData;
	self.mPreUpdate = Object_Button_PreUpdate;
	self.mPostUpdate = Object_Button_PostUpdate;
	self.mDraw = Object_Button_Draw;
	
	Object_DataUser_Spawn();
}

void() Object_Button_Init =
{
	self.setMethod = Object_Button_SetMethod;
	// start defaults
	Menu_Sys_StateMap_AddMethod(self, ":normal", "selectable", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textColor", "'1 1 1'");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textAlign", "'1 1 0'");
}

void() Object_Button =
{
	className = "Button";
	classInit = Object_Button_Init;
	classSpawn = Object_Button_Spawn;
}