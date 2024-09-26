////////////////////////////////////////
// Blood Omnicide source codes - dummy csprogs + lights editor
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

////////////////////////////////////////
// HEADERS
////////////////////////////////////////

////////////////////////////////////////
// CODE
////////////////////////////////////////

float CSQC_ConsoleCommand(string cmd)
{
	// custom commands for lights editor
	if (ParseCommand(cmd))
		return 1;
	return 0;
}

float CSQC_InputEventNonMenu(float tEvent, float tKeyCode) =
{
	if (EditLightsKeyEvent(tEvent, tKeyCode))
		return 1;
	return 0;
}

float CSQC_InputEvent(float tEvent, float tKeyCode)
{
	float tMenuAPI, tReturn;
	
	// menu API key
	tMenuAPI = Menu_API_Key(tEvent, tKeyCode);
	switch(tMenuAPI)
	{
		case -1:
			tReturn = 1;
			break;
		case 1:
			tReturn = 0;
			break;
		default:
			tReturn = CSQC_InputEventNonMenu(tEvent, tKeyCode);
			break;
	}
	// enter key should not be blocked in console mode
	if ((input_buttons & B_CONSOLE) && (tKeyCode == K_ENTER))
		return 0;	
	return tReturn;
}

void() CSQC_Init =
{
	// init menu system and lights editor
	Menu_API_Init(setcursormode);
	EditLightsInit();
	// start lights editing
	localcmd("wait;editlights;wait\n");
}

void() CSQC_Shutdown =
{
	Menu_API_Shutdown();
}

/*
================================================================================

  VIEW UPDATE

================================================================================
*/

void() CSQC_UpdateView =
{
	clearscene();
	setview(VF_DRAWWORLD, 1);
	setview(VF_DRAWCROSSHAIR, 0);
	setview(VF_DRAWENGINESBAR, 0);
	addentities(MASK_NORMAL | MASK_ENGINE | MASK_ENGINEVIEWMODELS);
	
	// run lights editor frame
	if (EditLights_Active)
		EditLightsUpdateView();		

	// render scene
	renderscene();
	
	// draw menus
	Menu_API_Frame();		
}

/*
================================================================================

  OPTIONAL STUFF

================================================================================
*/

void CSQC_Ent_Update(float is_new_entity)
{
}

void() CSQC_Ent_Remove =
{
	remove(self);
}

float() CSQC_Parse_TempEntity =
{
	return 0;
}

void CSQC_Parse_CenterPrint(string msg)
{
	cprint(msg);
}

void CSQC_Parse_Print(string msg)
{
	print(msg);
}

void CSQC_Parse_StuffCmd(string cmd)
{	
	localcmd(cmd);
}

