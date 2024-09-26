////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
Picture

visual object
Draws background->picture->text
if picSize is not set it will be fit to object size
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

// void(entity tSource)
void() Object_Picture_Draw =
{
	ObjectLib_Background_Draw();
	ObjectLib_Picture_Draw();
	ObjectLib_Text_Draw();
	ObjectLib_Foreground_Draw();
}

void() Object_Picture_PostUpdate =
{
	ObjectLib_Text_PostUpdate();
}

void() Object_Picture_Spawn =
{
	self.mPostUpdate = Object_Picture_PostUpdate;
	self.mDraw = Object_Picture_Draw;
}

void() Object_Picture_Init =
{
	Menu_Sys_StateMap_AddMethod(self, ":normal", "textAlign", "'1 1 0'");
}

void() Object_Picture =
{
	className = "Picture";
	classInit = Object_Picture_Init;
	classSpawn = Object_Picture_Spawn;
}