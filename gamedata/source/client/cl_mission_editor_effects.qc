/*
===========================================================================

Steel Storm Burning Retribution QuakeC Source Code
Copyright (C) 2008-2024 Kot-in-Action Creative Artel.

This file is part of the Steel Storm Burning Retribution QuakeC Source Code.

License:
  - You may use, modify, and distribute modifications of this source code under the terms of the Steel Storm Burning Retribution QuakeC Source Code License Agreement.
  - No commercial use of this source code or any derivative works is permitted.
  - All mods and modifications must be distributed for free and include this license header.
 
The full text of the license is included in the license.txt file that came with this source code.

If you have questions concerning this license, you may contact info (at) kot-in-action.com

===========================================================================
*/
void SetEmitterMarkerParticleEffect() =
{
	self.allowpitchadjustment = true;
//	self.allowheightadjustment = true;
//	self.unstackable = true;
	
	self.particleemittereffect = zonecpy(self.particleemittereffect, defaultemittereffectname);
	
	self.particleindex = particleeffectnum(self.particleemittereffect);	
	ParticleEmitterChain_Add(self);
	
}

void ChooseParticleEffect() =
{
	if(admin_editingent)
	{
		admin_editingent.particleemittereffect = zonecpy(admin_editingent.particleemittereffect, active_menu.listitemstring);
		admin_editingent.particleindex = particleeffectnum(admin_editingent.particleemittereffect);	
	}
	else
		defaultemittereffectname = zonecpy(defaultemittereffectname, active_menu.listitemstring);
		
	CloseMenu();	
	
	if(admin_editingent)
		CommitObject(admin_editingent);
	else
		PlaceParticleEmitter();
}

void ListOption_SetParticleEffect(float count) =
{
	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	Menu_Option_Text(active_menu.listitemstring, ChooseParticleEffect);
}

void Draw_SetParticleEffect() =
{
	local float numeffects, numlistoptions, count, windowwidth, listslots;
	
	Menu_Start_OptionMenu("Select an Effect", '400 450 0', __FUNC__);

	local string str_noeffectsfound;
	str_noeffectsfound	= Translate("No effects found.");
	skiptranslation = true;
		
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	listslots = 15;
	numeffects = GetBufferSize(active_menu.buf_list);
	
	if(!numeffects)
	{
		BR();
		Menu_Text(str_noeffectsfound); BR();
	}
	else
		numlistoptions = Draw_ScollingList(numeffects, listslots, 0, windowwidth, listslots+1, listslots, SUB_Null, ListOption_SetParticleEffect);

	skiptranslation = false;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();
}

void AddEffectsFromFileToStringBuffer(string filename) =
{
	local float file, count, buffersize, effectexists;
	local string line;
	file = FileOpen(filename, FILE_READ);
	if(file != -1)
	{
		line = fgets(file);
		while(line)
		{
			tokenize(line);
			if(argv(0) == "effect")
			{
				if(argv(1) != "END")
				{
					buffersize = GetBufferSize(currentmenu.buf_list);
					for(count = 0; count < buffersize && !effectexists; count++)
					{
						if(GetBufferString(currentmenu.buf_list, count) == argv(1))
							effectexists = true;	
					}
				
					if(!effectexists)
						AddBufferString(currentmenu.buf_list, argv(1), 0);
				}
			}
			else
			if(argv(0) == "orientation" || argv(0) == "type")
			if(argv(1) == "beam")
				FreeBufferString(currentmenu.buf_list, GetBufferSize(currentmenu.buf_list)-1);
			
			effectexists = false;
			line = fgets(file);
		}
		
		fclose(file);
	}
}

void Call_SetParticleEffect() =
{
	SetCurrentMenu(Draw_SetParticleEffect);
	currentmenu.menu_style	= STYLE_PRIORITY;
	currentmenu.buf_list = CreateBuffer();
	
	AddEffectsFromFileToStringBuffer("effectinfo.txt");
	AddEffectsFromFileToStringBuffer(strcat(substring(mapname, 0, strlen(mapname)-4), "_effectinfo.txt"));
	
	SortBuffer(currentmenu.buf_list, 99, FALSE);	
}

void SetEmitterMarkerAmbientSound() =
{
	self.ambientsoundeffect = zonecpy(self.ambientsoundeffect, defaultambientsoundname);
	
	self.particleindex = particleeffectnum(self.ambientsoundeffect);	
//	AmbientSoundChain_Add(self);
}

void ChooseAmbientSound() =
{
	if(admin_editingent)
		admin_editingent.ambientsoundeffect = zonecpy(admin_editingent.ambientsoundeffect, active_menu.listitemstring);
	else
		defaultambientsoundname = zonecpy(defaultambientsoundname, active_menu.listitemstring);
		
	CloseMenu();	
	
	if(admin_editingent)
		CommitObject(admin_editingent);
	else
		PlaceAmbientSound();
}

void ListOption_SetAmbientSound(float count) =
{
	active_menu.listitemstring = GetBufferString(active_menu.buf_list, count);
	Menu_Option_Text(active_menu.listitemstring, ChooseAmbientSound);
}

void Draw_SetAmbientSound() =
{
	local float numeffects, numlistoptions, count, windowwidth, listslots;
	
	Menu_Start_OptionMenu("Select a Sound", '400 450 0', __FUNC__);

	local string str_noeffectsfound;
	str_noeffectsfound	= Translate("No effects found.");
	skiptranslation = true;	
	
	windowwidth = active_menu.menusize_x - border_size_x*2 - body_margin_x*2 - 10;
	listslots = 15;
	numeffects = GetBufferSize(active_menu.buf_list);
	
	if(!numeffects)
	{
		BR();
		Menu_Text(str_noeffectsfound); BR();
	}
	else
		numlistoptions = Draw_ScollingList(numeffects, listslots, 0, windowwidth, listslots+1, listslots, SUB_Null, ListOption_SetAmbientSound);

	skiptranslation = false;
	filetextline = 2;
	BeginBottomButtons(1);
	DrawElement_BottomButton("Cancel", CloseMenu, 0, 0, 0, 0, MBT_CANCEL);		
	EndBottomButtons();		
	
	Menu_End();
}

void AddFilesToStringBuffer(float buf, string path) =
{
	local float searchhandle, numfiles, count;
	local string filename;
	
	searchhandle = search_begin(strtolower(path), TRUE, TRUE);
	if(searchhandle == -1)
		return;

	numfiles = search_getsize(searchhandle);	
	
	for(count = 0; count < numfiles; count++)
	{
		filename = search_getfilename(searchhandle, count);
		
		if(!HasDuplicateStringInList(buf, filename))
			AddBufferString(buf, filename, 0);
	}	
	
	search_end(searchhandle);	
}

void Call_SetAmbientSound() =
{
	SetCurrentMenu(Draw_SetAmbientSound);
	currentmenu.menu_style	= STYLE_PRIORITY;
	currentmenu.buf_list = CreateBuffer();	
	
	AddFilesToStringBuffer(currentmenu.buf_list, "sounds/ambient/*.ogg");
	AddFilesToStringBuffer(currentmenu.buf_list, "sounds/ambient/*.wav");
	
	SortBuffer(currentmenu.buf_list, 99, FALSE);	
}

void Draw_MissionEditor_Effects() =
{
	Menu_Start_MissionEditor("Effects", __FUNC__);
	Menu_Option_Text("Particle Emitter", Call_SetParticleEffect);
	Menu_Option_Text("Ambient Sound", Call_SetAmbientSound);
	BR();
	Menu_Option_Text_Cancel("Back", CloseMenu);
	
	Menu_End();
}