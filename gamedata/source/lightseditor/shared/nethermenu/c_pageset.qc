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

.entity _oldLink;

////////////////////////////////////////
// CODE
////////////////////////////////////////

/*
================================================================================

   PAGE
   
   automatically fits it's parent
	draws background
	can do arrangement

   onEnter and onExit are called with 'pageset' global set to parent's pageset

================================================================================
*/

void() Object_Page_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_Page_PreUpdate =
{
}

void() Object_Page_PostUpdate =
{
}

Menu_KeyEvent Object_Page_Key =
{
	return 0;
}

void() Object_Page_Spawn =
{
	self.mPreUpdate = Object_Page_PreUpdate;
	self.mPostUpdate = Object_Page_PostUpdate;
	self.mDraw = Object_Page_Draw;
	self.mKey = Object_Page_Key;
}

void() Object_Page_Init = {}

void() Object_Page =
{
	className = "Page";
	classInit = Object_Page_Init;
	classSpawn = Object_Page_Spawn;
}

/*
================================================================================

   PAGE SET
   
   if size is not set it will fit parent
	Draws background

	Frame does not have children (unless you switch off noChildren flag)
	except one child which name should be specified via "link" method

================================================================================
*/

void Object_PageSet_SwitchPage(entity tObject)
{
	// hide old page
	if (isentity(tObject._oldLink))
	{
		// run exit event on page
		if (tObject._oldLink.onExit)
			MenuScript_Run(tObject._oldLink, tObject._oldLink.onExit);
		Menu_Hide(tObject._oldLink, "pageset_");
	}
	Menu_Unhide(tObject._link, "pageset_");
	// run select event on page
	if (tObject._link.onEnter)
		MenuScript_Run(tObject._link, tObject._link.onEnter);
}

Menu_MethodSetEvent Object_PageSet_SetMethod =
{
	if (tMethod == "link")
	{
		tObject._oldLink = tObject._link;
		Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
		Object_PageSet_SwitchPage(tObject);
		tObject.mRunFlags = tObject.mRunFlags | MENU_RUNFLAG_UPDATEOBJECT;
		return;
	}
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
}

void() Object_PageSet_PreUpdate =
{
	// fit parent
	if (!self.size_x)
		self.size_x = (self._parent.size_x - self.pos_x) / self._parent._scale_x;
	if (!self.size_y)
		self.size_y = (self._parent.size_y - self.pos_x) / self._parent._scale_y;
}

void() Object_PageSet_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_PageSet_Spawn =
{
	entity c;
	
	self.mPreUpdate = Object_PageSet_PreUpdate;
	self.mDraw = Object_PageSet_Draw;

	// hide chindren except self.link
	for (c = self._child; c; c = c._next)
		Menu_Hide(c, "pageset_");
	if (isentity(self._link))
		Object_PageSet_SwitchPage(self);
}

void() Object_PageSet_Init =
{
	self.setMethod = Object_PageSet_SetMethod;
}

void() Object_PageSet =
{
	className = "PageSet";
	classInit = Object_PageSet_Init;
	classSpawn = Object_PageSet_Spawn;
}