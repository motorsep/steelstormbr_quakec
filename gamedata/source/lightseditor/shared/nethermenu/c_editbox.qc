////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
 Editbox
 
 visual object
 draws background and text
 when used becomes pressed state when catches any keys
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

.float _editPos;
.float _editShift;
.float _lastEdit;
.vector _editSize;

.float _state;
enumflags
{
	EDITBOX_STATE_SELECTED,
	EDITBOX_STATE_EDITING,
	_
};

////////////////////////////////////////
// CODE
////////////////////////////////////////

void Object_EditBox_SetCursorPos(float tNewPos)
{
	vector tTextSize, tTextFontSize;
	float tShiftPos;
	
	self._editPos = tNewPos;
	// update cursor shift
	// if shift is bigger than pos, for it to be same
	if (self._editShift >= self._editPos)
		self._editShift = max(0, self._editPos-1);
	else
	{
		// check if we have enough shift to show cursor char at least in the end of line
		// progress by one char
		tTextFontSize_x = self.editFontSize_x*self._scale_x;
		tTextFontSize_y = self.editFontSize_y*self._scale_y;
		tTextSize = Draw2D_GetTextSize(substring(self.edit, self._editShift, self._editPos-self._editShift), self.editFont, tTextFontSize, 0);
		while(tTextSize_x > self.editSize_x)
		{
			self._editShift = self._editShift + 1;
			tTextSize = Draw2D_GetTextSize(substring(self.edit, self._editShift, self._editPos-self._editShift), self.editFont, tTextFontSize, 0);
		}
	}
}

void() Object_EditBox_StartEdit =
{
	self._state = self._state | EDITBOX_STATE_EDITING;
	self._lastEdit = time;
	Object_EditBox_SetCursorPos(strlen(self.edit));
	Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":typing");
}

void Object_EditBox_StopEdit(float tSave) =
{
	self._state = self._state - (self._state & EDITBOX_STATE_EDITING);
	if (tSave)
		Menu_DataSource_SetValue(self, self._datasource, self.edit, self.autoEvent);
	if (self._state & EDITBOX_STATE_SELECTED)	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");
	else
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");
	Menu_RefreshDataObject(self, self._datasource);
}

/*
===================================================

 DATA

===================================================
*/

// void(entity tSource)
Menu_DataRefresh Object_EditBox_RefreshData =
{
	if (tSource.classname == "DataSource_Text")
	{
		rezone(self.edit, tSource.value);
		return;
	}
	if (tSource.classname == "DataSource_Slider")
	{
		rezone(self.edit, tSource._desc);
		return;
	}
	Menu_Warning(self, strcat("Object_EditBox_RefreshData: Unsupported data source type '", tSource.classname, "'"));
}

Menu_MethodSetEvent Object_EditBox_SetMethod =
{
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

/*
===================================================

 KEY & CLICK & MOUSE

===================================================
*/

Menu_SelectEvent Object_EditBox_Select =
{
	if (!(self._state & EDITBOX_STATE_SELECTED))
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":select");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":selected");	
		self._state = self._state | EDITBOX_STATE_SELECTED;
	}
	return 1;
}

Menu_SelectEvent Object_EditBox_Deselect =
{
	if (self._state & EDITBOX_STATE_EDITING)
		return 0; // not allow selecting
	if (self._state & EDITBOX_STATE_SELECTED)
	{
		if (!tSilent)
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":deselect");	
		Menu_Sys_RunState(self, MSU_NORMAL, self.state, ":normal");	
		self._state = self._state - (self._state & EDITBOX_STATE_SELECTED);
	}
	return 1;
}

Menu_KeyEvent Object_EditBox_InputKey =
{
	string tChar, tStr;
	
	// type new char
	tChar = Menu_Sys_RemapChar(tKeyCode);
	if (tChar != "" && (tKeyCode >= 0 && tKeyCode < 256))
	{
		if (tEvent == KEYEVENT_HOLD)
		{
			tStr = substring(self.edit, 0, self._editPos);
			tStr = strcat(tStr, tChar, substring(self.edit, self._editPos, 10000));
			rezone(self.edit, tStr);
			Object_EditBox_SetCursorPos(self._editPos + 1);
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":type");
		}
		return 1;
	}
	return 0;
}

Menu_KeyEvent Object_EditBox_Key =
{
	string tStr;
	
	// catch keys in pressed state
	if (self._state & EDITBOX_STATE_EDITING)
	{
		// apply changes
		if (tKeyCode == K_ENTER) 
		{
			if (tEvent == KEYEVENT_HOLD)
				Object_EditBox_StopEdit(1);
			return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
		}
		if (tKeyCode == K_ESCAPE) 
		{
			if (tEvent == KEYEVENT_HOLD)
				Object_EditBox_StopEdit(0);	
			return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
		}
		// move cursor forward
		if (tKeyCode == K_RIGHTARROW) 
		{
			if (tEvent == KEYEVENT_HOLD)
			{
				if (self._editPos < strlen(self.edit))
				{
					Object_EditBox_SetCursorPos(self._editPos + 1);
					self._lastEdit = time;
					Menu_Sys_RunState(self, MSU_EVENT, self.state, ":cursor-forward");
				}
			}
			return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
		}
		// move cursor back
		if (tKeyCode == K_LEFTARROW) 
		{
			if (tEvent == KEYEVENT_HOLD)
			{
				if (self._editPos > 0)
				{
					Object_EditBox_SetCursorPos(self._editPos - 1);
					self._lastEdit = time;
					Menu_Sys_RunState(self, MSU_EVENT, self.state, ":cursor-back");
				}
			}
			return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
		}
		// delete 1 char in cursor position
		if (tKeyCode == K_BACKSPACE) 
		{ 
			if (tEvent == KEYEVENT_HOLD)
			{
				if (self._editPos > 0)
				{
					tStr = substring(self.edit, 0, self._editPos - 1);
					tStr = strcat(tStr, substring(self.edit, self._editPos, 10000));
					rezone(self.edit, tStr);
					Object_EditBox_SetCursorPos(self._editPos - 1);
					Menu_Sys_RunState(self, MSU_EVENT, self.state, ":delete");
				}
			}
			return 1;
		}
		// delete 1 char next to cursor position
		if (tKeyCode == K_DEL) 
		{ 
			if (tEvent == KEYEVENT_HOLD)
			{
				if (self._editPos < strlen(self.edit))
				{
					tStr = substring(self.edit, 0, self._editPos);
					tStr = strcat(tStr, substring(self.edit, self._editPos+1, 10000));
					rezone(self.edit, tStr);
					Menu_Sys_RunState(self, MSU_EVENT, self.state, ":delete");
				}
			}
			return 1;
		}
		// run input key
		if (Object_EditBox_InputKey(tEvent, tKeyCode, tKeySealed))
		{
			self._lastEdit = time;
			return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
		}
		return KR_FALSE | KR_SEAL_PARENTS;
	}
	// pressing delete erases whole line
	if (tKeyCode == K_DEL) 
	{ 
		if (tEvent == KEYEVENT_HOLD)
		{
			Object_EditBox_StartEdit();
			rezone(self.edit, "");
			self._editPos = 0;
			Object_EditBox_StopEdit(1);
			Menu_Sys_RunState(self, MSU_EVENT, self.state, ":erase");
		}
		return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
	}
	// go into edit state
	if (tKeyCode == K_ENTER && tEvent == KEYEVENT_HOLD)
	{
		Object_EditBox_StartEdit();
		return KR_TRUE | KR_SEAL_PARENTS | KR_SEAL_ENGINE;
	}
	return KR_FALSE;
}

/*
===================================================

 DRAW

===================================================
*/

void() Object_EditBox_Draw =
{
	vector tTextPos, tTextFontSize, tTextSize, tCursorPos, tEditSize;
	string tDrawStr;
	float tDrawFlag;
	
	ObjectLib_Background_Draw();
	ObjectLib_Text_Draw();
	
	tTextPos_x = self._absmin_x + self.editPos_x*self._scale_x;
	tTextPos_y = self._absmin_y + self.editPos_y*self._scale_y;
	tTextFontSize_x = self.editFontSize_x*self._scale_x;
	tTextFontSize_y = self.editFontSize_y*self._scale_y;
	tDrawFlag = self.editDrawFlag;
	tDrawStr = self.edit;
	if (self._state & EDITBOX_STATE_EDITING)
	{
		tDrawStr = substring(self.edit, self._editShift, 100000);
		tDrawFlag = tDrawFlag - (tDrawFlag & DRAW2D_COLORCODES); // no colorcodes when editing!
		tDrawFlag = tDrawFlag | DRAW2D_CURSOR; // draw cursor
		Draw2D_SetCursor(0, self._editPos - self._editShift, self._lastEdit, 15);
	}
	
	// draw text
	Draw2D_BackUpClipArea();
	if (self.editSize != '0 0 0')
		tEditSize = self.editSize;
	else
	{
		tEditSize_x = self.size_x - self.editPos_x;
		tEditSize_y = self.size_y - self.editPos_y;
	}
	Draw2D_SetClipArea(self._absmin_x + self.editPos_x, self._absmin_y + self.editPos_y, tEditSize_x, tEditSize_y);
	if (self.editShadow)
	{
		Draw2D_SetShadow(self.editShadow, self.editShadowOfs);
		tDrawFlag = tDrawFlag | DRAW2D_SHADOW;
	}
	if (self.editAlign != '0 0 0')
	{
		Draw2D_SetArea(self._size, self.editAlign, DRAW2D_TOPLEFT);
		tDrawFlag = tDrawFlag | DRAW2D_ALIGN;
	}
	self._editSize = Draw2D_DrawText(tTextPos, tDrawStr, self.editFont, tTextFontSize, self.editColor, self.editAlpha*self.alpha, tDrawFlag);
	Draw2D_RestoreClipArea();
	
	// draw foreground
	ObjectLib_Foreground_Draw();
}

/*
===================================================

 UPDATE

===================================================
*/

void() Object_EditBox_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
}

void() Object_EditBox_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

/*
===================================================

 SPAWN

===================================================
*/

void() Object_EditBox_Spawn =
{
	self.mDataRefresh = Object_EditBox_RefreshData;
	self.mPreUpdate = Object_EditBox_PreUpdate;
	self.mPostUpdate = Object_EditBox_PostUpdate;
	self.mDraw = Object_EditBox_Draw;
	self.mKey = Object_EditBox_Key;
	self.mSelect = Object_EditBox_Select;
	self.mDeSelect = Object_EditBox_Deselect;
	
	Object_DataUser_Spawn();
}

void() Object_EditBox_Destroy =
{
	unzone(self.edit);
}

void() Object_EditBox_Init =
{
	self.setMethod = Object_EditBox_SetMethod;
	self.mDestroy = Object_EditBox_Destroy;
	self.edit = newzone();
	// start defaults
	Menu_Sys_StateMap_AddMethod(self, ":normal", "selectable", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textColor", "'1 1 1'");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "editColor", "'1 1 1'");
}

void() Object_EditBox =
{
	className = "EditBox";
	classInit = Object_EditBox_Init;
	classSpawn = Object_EditBox_Spawn;
}
