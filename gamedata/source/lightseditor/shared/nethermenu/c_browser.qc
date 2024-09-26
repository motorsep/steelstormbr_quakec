////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
Browser

HTML browser using OffscreenGecko
link is url

float gecko_create( string name ) = #487;
void gecko_destroy( string name ) = #488;
void gecko_navigate( string name, string URI ) = #489;
float gecko_keyevent( string name, float key, float eventtype ) = #490;
void gecko_mousemove( string name, float x, float y ) = #491;
void gecko_resize( string name, float w, float h ) = #492;
vector gecko_get_texture_extent( string name ) #493;
*/

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

void() Object_Browser_Draw =
{
	
}

void() Object_Browser_PreUpdate =
{
}

void() Object_Browser_PostUpdate =
{
}

Menu_MethodSetEvent Object_Browser_SetMethod =
{
	if (tMethod == "link")
		return;
	if (tMethod == "url")
	{
		rezone(self.link, tValue);
		gecko_navigate(self.name, self.link);
		return;
	}
	Menu_Sys_SetMethod(tObject, tOp, tMethod, tValue);
}

void() Object_Browser_Destroy =
{
	gecko_destroy(self.name);
}

void() Object_Browser_Spawn =
{
	self.mPreUpdate = Object_Browser_PreUpdate;
	self.mPostUpdate = Object_Browser_PostUpdate;
	self.mDraw = Object_Browser_Draw;
	self.mDestroy = Object_Browser_Destroy;
}

void() Object_Browser_Init =
{
	gecko_create(self.name);
	self.setMethod = Object_Browser_SetMethod;
}

void() Object_Browser =
{
	className = "Browser";
	classInit = Object_Browser_Init;
	classSpawn = Object_Browser_Spawn;
}