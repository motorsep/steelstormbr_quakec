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

.float _sliderPos;

////////////////////////////////////////
// CODE
////////////////////////////////////////

// void(entity tSource)
Menu_DataRefresh Object_Slider_RefreshData =
{
	self.setMethod(self, MMA_SET, "text", Menu_DataSource_GetDescValue(self, tSource));
	if (tSource.classname == "DataSource_Slider")
	{
		self._sliderPos = stof(tSource.value);
		return;
	}
	if (tSource.classname == "DataSource_List" || tSource.classname == "DataSource_ListCombiner")
	{
		self._sliderPos = stof(tSource.value)/ (tSource.valueListSize - 1);
		return;
	}
}

// void(float tEvent, float tKeyCode)
Menu_MouseClickEvent Object_Slider_Click =
{
	vector tRelativePos;
	
	if (!tMouseOver)
		return KR_FALSE;
	if (tEvent == KEYEVENT_RELEASE && tKeyCode == K_MOUSE1)
	{
		tRelativePos = self._proc.mousePos - self._absmin;
		tRelativePos_x = bound(0, tRelativePos_x/self._size_x , 1);
		tRelativePos_y = bound(0, tRelativePos_y/self._size_y, 1);
		Menu_DataSource_SetPos(self, self._datasource, tRelativePos_x, self.autoEvent);
		return KR_TRUE;
	}
	return KR_FALSE;
}

// void(float tEvent, float tKeyCode)
Menu_KeyEvent Object_Slider_Key =
{
	if (tKeyCode == K_LEFTARROW)
	{
		if (tEvent == KEYEVENT_HOLD)
			Menu_DataSource_Advance(self, self._datasource, -1, 0, self.autoEvent);
		return KR_TRUE;
	}
	if (tKeyCode == K_RIGHTARROW)
	{
		if (tEvent == KEYEVENT_HOLD)
			Menu_DataSource_Advance(self, self._datasource, 1, 0, self.autoEvent);
		return KR_TRUE;
	}
	return KR_FALSE;
}

Menu_MethodSetEvent Object_Slider_SetMethod =
{
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
	Object_DataUser_SetMethod(tObject, tOp, tMethod, tValue);
}

void() Object_Slider_Draw =
{
	// calc slider
	self.picPos_x = bound(0, self._sliderPos, 1)*(self.size_x - self.picSize_x);
	self.picPos_y = 0;
	self.picAlign = '0 0 0';
	// draw background using clipping
	Draw2D_BackUpClipArea();
	Draw2D_SetClipArea(self._absmin_x, self._absmin_y, self.picPos_x + self.picSize_x/2, self.size_y);
	ObjectLib_Background_Draw();
	Draw2D_RestoreClipArea();
	// draw text
	ObjectLib_Text_Draw();
	// draw foreground
	ObjectLib_Foreground_Draw();
	// slider is drawn upon even foreground
	ObjectLib_Picture_Draw();
}

void() Object_Slider_PreUpdate =
{
	ObjectLib_Text_PreUpdate();
}

void() Object_Slider_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

void() Object_Slider_Spawn =
{
	self.mDataRefresh = Object_Slider_RefreshData;
	self.mClick = Object_Slider_Click;
	self.mKey = Object_Slider_Key;
	self.mPreUpdate = Object_Slider_PreUpdate;
	self.mPostUpdate = Object_Slider_PostUpdate;
	self.mDraw = Object_Slider_Draw;
	
	Object_DataUser_Spawn();
}

void() Object_Slider_Init =
{
	self.setMethod = Object_Slider_SetMethod;
	// start methods
	Menu_Sys_StateMap_AddMethod(self, ":normal", "selectable", "1");
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textAlpha", "0");
}

void() Object_Slider =
{
	className = "Slider";
	classInit = Object_Slider_Init;
	classSpawn = Object_Slider_Spawn;
}