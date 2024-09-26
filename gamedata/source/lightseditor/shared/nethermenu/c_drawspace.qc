////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
DrawSpace

visual/system object
Always fit it's parent
Not affected by scale
Draws background
Can do arrangement
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

void() Object_DrawSpace_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_DrawSpace_PreUpdate =
{
	self.size_x = (self._parent.size_x - self.pos_x) / self._parent._scale_x;
	self.size_y = (self._parent.size_y - self.pos_x) / self._parent._scale_y;
}

void() Object_DrawSpace_PostUpdate =
{
}

void() Object_DrawSpace_Spawn =
{
	self.mPreUpdate = Object_DrawSpace_PreUpdate;
	self.mPostUpdate = Object_DrawSpace_PostUpdate;
	self.mDraw = Object_DrawSpace_Draw;
}

void() Object_DrawSpace_Init =
{
}

void() Object_DrawSpace =
{
	className = "DrawSpace";
	classInit = Object_DrawSpace_Init;
	classSpawn = Object_DrawSpace_Spawn;
}