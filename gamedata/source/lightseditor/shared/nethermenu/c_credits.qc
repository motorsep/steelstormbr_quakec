////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
This is control i quickly make for AQ credits
displaying, i slides down with some speed
it is pretty temporary
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

.float _scroll;
.float _pausetime;

////////////////////////////////////////
// CODE
////////////////////////////////////////

void() Object_Credits_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_Credits_Show =
{
	self._scroll = 3;
	self._pausetime = time + 1;
}

void() Object_Credits_PostUpdate =
{
	if (self._pausetime < time)
	{
		self._scroll = self._scroll - frametime*12;
		if (self._scroll < -1200)
			self._scroll = 10;
	}
	self.mRunFlags = self.mRunFlags | (MENU_RUNFLAG_UPDATEPOS + MENU_RUNFLAG_UPDATEOBJECT);
}

Menu_KeyEvent Object_Credits_Key =
{
	return 0;
}

void() Object_Credits_Spawn =
{
	self.mShow = Object_Credits_Show;
	self.mPostUpdate = Object_Credits_PostUpdate;
	self.mDraw = Object_Credits_Draw;
	self.mKey = Object_Credits_Key;
}

void() Object_Credits_Init =
{
}

void() Object_Credits =
{
	className = "Credits";
	classInit = Object_Credits_Init;
	classSpawn = Object_Credits_Spawn;
}