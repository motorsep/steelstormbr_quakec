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
void NewCellChain_Add(entity e) =		{	list_newcellchain = LinkedList_Add(e, list_newcellchain, newcellchain, newcellchain_prev);	}
void NewCellChain_Remove(entity e) =	{	list_newcellchain = LinkedList_Remove(e, list_newcellchain, newcellchain, newcellchain_prev);	}

entity GetCellConnection(entity cell, float count, float GETWALL) =
{
	local entity nearcell;

	switch(count)
	{
		case 0:	nearcell = cell.cellconnection_0;	break;
		case 1:	nearcell = cell.cellconnection_1;	break;
		case 2:	nearcell = cell.cellconnection_2;	break;
		case 3:	nearcell = cell.cellconnection_3;	break;
	}	
	
	if(!GETWALL)
	if(nearcell == wall)
		nearcell = world;
	
	return nearcell;
}

void SetCellConnection(entity cell, float count, entity nearcell) =
{
	switch(count)
	{
		case 1:		cell.cellconnection_0 = nearcell;	break;
		case 2:		cell.cellconnection_1 = nearcell;	break;
		case 3:		cell.cellconnection_2 = nearcell;	break;
		case 4:		cell.cellconnection_3 = nearcell;	break;
		
		case -3:	cell.cellconnection_0 = nearcell;	break;
		case -4:	cell.cellconnection_1 = nearcell;	break;
		case -1:	cell.cellconnection_2 = nearcell;	break;
		case -2:	cell.cellconnection_3 = nearcell;	break;		
	}
	
	cell.SendFlags = TRUE;
}

entity GetClosestCell(vector searchorg, vector org, float AVOIDENTS) =
{
	local entity cell, closestcell;
	local float searchradius, ignorecell;
	local vector diff1, diff2;
	
	while(!closestcell && searchradius < 2048)
	{
		searchradius += CELL_MAXFILLDIST_COMBAT;
	
		cell = Chain2(findradius(searchorg, searchradius));
		while(cell)
		{
			if(cell.class == CLASS_CELL)
			{
				diff1 = org - cell.origin;
				diff2 = org - closestcell.origin;
				if(!closestcell || diff1*diff1 < diff2*diff2)
				{
					ignorecell = FALSE;
					if(AVOIDENTS)
						ignorecell = EntityInCellProximity(cell, TRUE);
						
					if(!ignorecell)
						closestcell = cell;
				}
			}
			
			cell = cell.chain2;
		}
	}
	
	if(!closestcell)
	{
		dprint("GetTargetCell: Error: Trying to find cells where there aren't any.\n");
		return world;
	}

	return closestcell;
}

void ClearCellPattern() =
{
	local entity cell, nextcell;
	cell = list_cellchain;
	while(cell)
	{
		nextcell = cell.cellchain;
		cell.pathpattern = 0;
	//	cell.colormod_x = 0;
		cell.cellchain = world;
		cell = nextcell;
	}
}

void RecordCellPath(entity endcell) =
{
	local float count, recordloopcount;
	local entity nearcell, lastendcell;
	
	for(recordloopcount = 0; endcell.pathpattern >= 2 && recordloopcount < 1000; recordloopcount++)
	{
		if(endcell.pathpattern <= CELLPATHPOINTS_MAX+1)
			self.(cellpath[endcell.pathpattern-2]) = endcell.origin;
	
		lastendcell = endcell;
	
		for(count = 0; count < 4; count++)
		{
			nearcell = GetCellConnection(endcell, count, FALSE);
			if(nearcell.pathpattern == endcell.pathpattern-1)
			{
				endcell = nearcell;
				break;
			}
		}
		
		if(endcell == lastendcell)
		{
			dprint("RecordCellPath: Error: Path is not tracing back correctly.\n");
			break;
		}
	}
	
	if(recordloopcount == 1000)
		dprint("RecordCellPath: Warning: Arborted record loop to avoid overflow.\n");
	
	ClearCellPattern();
}

float GetObjectPresenceRadius(entity e) =
{
	local float rad;
	
	if(e.class == CLASS_SHOT)
		rad = 110;
	else
//	if(e.objclass == OBJ_NPC)
		rad = (e.maxs_x+CELL_MAXS_x)*1.25;//sqrt(pow(e.maxs_x+CELL_MAXS_x, 2)*2);
//	else
//		rad = sqrt(pow(e.maxs_x+CELL_MAXS_x, 2));	

	return rad;
}

void RemoveUnusedCells(entity e, vector lastgridpos) =
{
	local entity c, oc;
	local vector diff1;
	local float cellfillradius;

	if(e.behaviorflags & BF_FLIES)
		cellfillradius = max(cellfillradius, CELL_MINFILLDIST_FLIGHT);
	else
	if(e.hadenemylastframe)
		cellfillradius = CELL_MAXFILLDIST_COMBAT;
	else
		cellfillradius = GetObjectPresenceRadius(e)+CELL_MAXS_x*2;
	
	if(lastgridpos != '0 0 0')
	{
		c = findradius(lastgridpos, cellfillradius);
		while(c)
		{
			if(c.class == CLASS_CELL)
			{
				diff1 = c.origin - lastgridpos;
				if(diff1*diff1 <= cellfillradius*cellfillradius)
				if(c.filloccupancy <= 0)
				{
					if(c.cellconnection_0)
						c.cellconnection_0.cellconnection_2 = world;
					if(c.cellconnection_1)
						c.cellconnection_1.cellconnection_3 = world;
					if(c.cellconnection_2)
						c.cellconnection_2.cellconnection_0 = world;
					if(c.cellconnection_3)
						c.cellconnection_3.cellconnection_1 = world;
					oc = c;
					c = c.chain;
					SH_RemoveEnt(oc);
					continue;
				}
			}
			
			c = c.chain;
		}
	}
	
	if(e.enemy && e.cantshootenemy)
		e.hadenemylastframe = TRUE;
	else
		e.hadenemylastframe = FALSE;
}

entity	list_tempcell;
.entity	tempcellchain;
void MarkGrid(entity e, float FILLCELLS, float OCCUPYCELLS, vector lastgridpos) =
{
	local float rad_mark, rad_find, cellsexist, cellfillradius;
	local vector diff1, org, pos;

	if(IsAttachedAIClass(e.npcclass))
		return;	
	
	if(e.origin == '0 0 0')
	{
		dprint("MarkGrid Warning: Ent at '0 0 0' trying to mark grid.\n");
		eprint(e);
		return;
	}
//		eprint(e);
	
	pos = e.origin;
	
	cellfiller = e;
//	lastgridpos = e.gridpos;
	if(FILLCELLS != -1)
	{
		e.gridpos = e.origin;	
		if(e.class == CLASS_SHOT)
			e.gridpos = e.gridpos+e.velocity*0.35;
		pos = e.gridpos;	
	/*	if(e.enemy)
		{if(e.objclass)
			print("TRUE\n");
			e.hadenemylastframe = TRUE;
			}
		else
		{if(e.objclass)print("FALSE\n");
			e.hadenemylastframe = FALSE;
			}*/
	}
		
	rad_mark = GetObjectPresenceRadius(e);

	if(e.behaviorflags & BF_FLIES)
		cellfillradius = max(cellfillradius, CELL_MINFILLDIST_FLIGHT);	
	else
	if(e.enemy && e.cantshootenemy)
		cellfillradius = CELL_MAXFILLDIST_COMBAT;
	else
		cellfillradius = rad_mark+CELL_MAXS_x*2;

	if(FILLCELLS == TRUE)
		rad_find = cellfillradius;//+LARGEOBJECT_WIDTH;
	else
		rad_find = rad_mark;
	
	local entity c, oc, closestcell, nextc;
	c = oc = Chain2(findradius(pos, rad_find));
	
	if(FILLCELLS == TRUE)
	{
		while(c && !cellsexist)
		{
			if(c.class == CLASS_CELL)
			{
				diff1 = c.origin - pos;
				if(diff1*diff1 <= cellfillradius*cellfillradius)
					cellsexist = TRUE;
			}
			c = c.chain2;
		}
		
		if(!cellsexist)
		{
			local float gridsize;
			org = pos;
			tracebox(org+'0 0 64', CELL_MINS, CELL_MAXS, org+'0 0 -96', TRUE, e);
			org = trace_endpos;
			gridsize = CELL_MAXS_x*2;
			org_x = gridsize*floor(org_x/gridsize);
			org_y = gridsize*floor(org_y/gridsize);
			CreateCell(org, 0, cellfillradius, 0);
			MarkGrid(e, -1, OCCUPYCELLS, lastgridpos);
			return;
		}
	}

	if(FILLCELLS)
	{
		c = oc;	
		while(c)
		{
			if(c.class == CLASS_CELL)
			{
				diff1 = c.origin - pos;
				if(diff1*diff1 <= cellfillradius*cellfillradius)
				{
					c.tempcellchain = list_tempcell;
					list_tempcell = c;
					
					if(FILLCELLS == TRUE)
					{
						c.filloccupancy += 1;
					//	c.SendFlags = TRUE;
					
						if(!c.cellconnection_0
						|| !c.cellconnection_1
						|| !c.cellconnection_2
						|| !c.cellconnection_3)
						{//c.colormod = '0 1 0';
							CellFill(c, c.origin, cellfillradius, 0);
							}
						//	else
						//	c.colormod = '1 0 1';
					}
				}
			}
			
			c = c.chain2;
		}

		c = list_tempcell;
	}
	else
		c = oc;
			
	if(OCCUPYCELLS)
	while(c)
	{
		if(c.class == CLASS_CELL)
		{
			diff1 = pos - c.origin;
			if(diff1*diff1 <= rad_mark*rad_mark)
			{
			//	if(!closestcell || vlen(c.origin - self.origin) < vlen(closestcell.origin - self.origin))
			//		closestcell = c;
				
				c.colormod = '1 0 0';
				c.occupancy += 1;
			//	c.SendFlags = TRUE;
			}
		}
		
		if(FILLCELLS)
			c = c.tempcellchain;
		else
			c = c.chain2;
	}	
	
	// CLEAR TEMP LISTS
		while(list_tempcell)
		{
			c = list_tempcell;
			list_tempcell = list_tempcell.tempcellchain;
			c.tempcellchain = world;
		}
		
		c = oc;
		while(c)
		{
			nextc = c.chain2;
			c.chain2 = world;
			c = nextc;
		}
	
/*	c = list_largeobjects;
	while(c)
	{
		MarkGrid(c, FALSE);
		c = c.chain;
	}*/
	
//	e.cellzone = closestcell.cellzone;

	if(list_newcellchain)
	{
		ConnectCells();
	//	MarkCellsAroundLargeObjects();	
	}
	
	if(FILLCELLS != FALSE)
		RemoveUnusedCells(e, lastgridpos);
		
	

/*	c = findradius(e.origin, rad_find*2);
	while(c)
	{
		if(c.class == CLASS_CELL)
		if(c.cellconnection_0 == wall
		|| c.cellconnection_1 == wall
		|| c.cellconnection_2 == wall
		|| c.cellconnection_3 == wall)
			c.colormod = '1 0 1';
		else
		if(!c.cellconnection_0
		|| !c.cellconnection_1
		|| !c.cellconnection_2
		|| !c.cellconnection_3)		
			c.colormod = '0 0 1';
		else
			c.colormod = '0 1 0';	
			
		c = c.chain;
	}*/
}

void UnmarkGrid(entity e, float FILLCELLS, float OCCUPYCELLS) =
{
	local entity c, oc;
	local float rad_find, rad_mark, cellfillradius;
	local vector diff1;
	
	if(IsAttachedAIClass(self.npcclass))
		return;
	
	if(e.origin == '0 0 0')
		return;
	
	rad_mark = GetObjectPresenceRadius(e);		

	if(e.behaviorflags & BF_FLIES)
		cellfillradius = max(cellfillradius, CELL_MINFILLDIST_FLIGHT);
	else
	if(e.hadenemylastframe)
		cellfillradius = CELL_MAXFILLDIST_COMBAT;
	else
		cellfillradius = rad_mark+CELL_MAXS_x*2;	
	
	if(FILLCELLS)
		rad_find = cellfillradius;
	else
		rad_find = rad_mark;
	
	
	c = findradius(e.gridpos, rad_find);
	while(c)
	{
		if(c.class == CLASS_CELL)
		{
			diff1 = c.origin - e.gridpos;
			if(diff1*diff1 <= cellfillradius*cellfillradius)
			{
				if(FILLCELLS)
				{
					c.filloccupancy -= 1;
				//	c.SendFlags = TRUE;
				}
			
				if(OCCUPYCELLS)
				if(c.occupancy > 0)
				{
					diff1 = e.gridpos - c.origin;
					if(diff1*diff1 <= rad_mark*rad_mark)
					{
						c.occupancy -= 1;
					//	c.SendFlags = TRUE;
						if(!c.occupancy)
							c.colormod = '0 0 0';
					}
				}
			}
		}
		
		c = c.chain;
	}
}

float EntityInCellProximity(entity cell, float AVOIDWALLS) = // rename this to something else
{
	local float maxoccupancy, count;
	local vector diff1;
	
	if(AVOIDWALLS)
	if(self.maxs_x > CELL_MAXS_x) // don't get close to walls if big
	{
		for(count = 0; count < 4; count++)
		{
			if(!GetCellConnection(cell, count, FALSE))
				return TRUE;
		}
	}
	
//	if(cell.pathpattern >= 5)
//	if(cell.occupancy != -1)
//		return FALSE;

//	print(ftos(cell.origin_z - self.origin_z));	print("\n");
		
	local float rad;
	local vector dist;
	
	dist = self.origin - cell.origin;
	rad = GetObjectPresenceRadius(self);

//	print(ftos(dist));	print(" : ");	print(ftos(rad));		print("\n");
	
	if(dist*dist <= rad*rad)
		maxoccupancy++;
//	else
//		print("cell is too far?\n");
		
	if(self.movingtosource)
	{
		diff1 = self.enemy.origin - cell.origin;
		rad = GetObjectPresenceRadius(self.enemy);
		if(diff1*diff1 <= rad*rad)
			maxoccupancy++;
	}
	
//	if(maxoccupancy == 0)
//		print("Don't start at 1 maxoccupancy!\n");
	
	if(cell.occupancy <= maxoccupancy)
		return FALSE;

	return TRUE;
}

void SpreadCellPattern(entity startcell, entity endcell) =
{
	entity lastlistcell, cell, nearcell, closestcell;
	float count, cellblocked, searchloopcount, maxloopcount;
	local vector diff1, diff2;
	
	self.isblocked = FALSE;
	
	cell = lastlistcell = list_cellchain = startcell;
	
	if(startcell == endcell)
	{
		RecordCellPath(endcell);
		return;
	}
	
	maxloopcount = 120;
	
	for(searchloopcount = 0; cell && searchloopcount < maxloopcount; searchloopcount++)
	{
		for(count = 0; count < 4; count++)
		{
			nearcell = GetCellConnection(cell, count, FALSE);
			if(nearcell)
			if(!nearcell.pathpattern)
			{
				if(!self.behaviorflags & BF_FLIES)
					cellblocked = EntityInCellProximity(nearcell, TRUE);

				if(!cellblocked)
				{
					nearcell.pathpattern = cell.pathpattern+1;
					lastlistcell.cellchain = nearcell;
					lastlistcell = nearcell;

					if(nearcell == endcell)
					{
						self.timespathblocked = 0;
						RecordCellPath(endcell);
						return;
					}
					else
					{
						diff1 = nearcell.origin - endcell.origin;
						diff2 = closestcell.origin - endcell.origin;
						if(!closestcell || diff1*diff1 < diff2*diff2)
							closestcell = nearcell;
					}
				}
				else
				{
					if(nearcell == endcell)
					{
						self.isblocked = TRUE;
						ClearCellPattern();
						return;
					}
				}
			}
		}		
		
		cell = cell.cellchain;
	}
	
	if(searchloopcount == maxloopcount || closestcell)
	{
		if(closestcell)
		{
			self.timespathblocked = 0;
			RecordCellPath(closestcell);
			return;
		}

		dprint("SpreadCellPattern: Warning: Search arborted to avoid run away loop. Either increase the grid size or decrease the map size.\n");
	}

	if(!cellblocked)
	{
		self.timespathblocked++;
		self.waittomovetime = time+self.timespathblocked;
		self.roamtime = 0;

		if(self.timespathblocked >= 5)
		{
			dprint("SpreadCellPattern: Error: AI could not find target endcell ");
			dprint(ftos(self.timespathblocked));
			dprint(" times in a row.\n");
		}
	}		

	self.isblocked = TRUE;
	ClearCellPattern();
}

void SetUpCellPath(vector start, entity endcell) =//vector end) =
{
	local entity startcell;//, endcell;
	local float count, range;
	local vector diff1;
	
	for(count = 0; count < CELLPATHPOINTS_MAX; count++)
	{
		self.(cellpath[count]) = '0 0 0';
	}
	
	startcell = GetClosestCell(self.origin, start, FALSE);
//	endcell = GetClosestCell(end, TRUE);

	diff1 = self.origin - endcell.origin;
	range = CELL_MAXS_x*1.5;
	if(diff1*diff1 < range*range)
		return;
	
	if(!startcell || !endcell)
	{
		dprint("SetUpCellPath: Error: Missing start/end cell.\n");
		return;
	}
	
	startcell.pathpattern = 1;
	SpreadCellPattern(startcell, endcell);
}

vector IsReachable(vector start, vector MINS, vector MAXS, vector end, entity reacher, float IGNORE) =
{
	local float minnorm, maxnorm;

	start_z += 64;
	end_z += 64;
	
	minnorm = -0.15;
	maxnorm = 0.15;
	
	reacher.dphitcontentsmask = DPCONTENTS_SOLID | DPCONTENTS_PLAYERCLIP | DPCONTENTS_MONSTERCLIP;
	if(!IGNORE)
		reacher.dphitcontentsmask = reacher.dphitcontentsmask | DPCONTENTS_BODY;
	tracebox(start, MINS, MAXS, end, IGNORE, reacher);
//	traceline(start, end, IGNORE, reacher);
	reacher.dphitcontentsmask = 0;
	
	if(trace_fraction == 1)
	{
	//	tracebox(trace_endpos, MINS, MAXS, trace_endpos + '0 0 -64', IGNORE, reacher);
		traceline(trace_endpos, trace_endpos + '0 0 -96', IGNORE, reacher);
		if(trace_fraction < 1)
		if(trace_plane_normal_x >= minnorm)
		if(trace_plane_normal_x <= maxnorm)
		if(trace_plane_normal_y >= minnorm)
		if(trace_plane_normal_y <= maxnorm)
		if(trace_plane_normal_z >= minnorm)
		if(trace_plane_normal_z <= 1+maxnorm)	
			return trace_endpos;
	}

	return '0 0 0';
}

vector GetFurthestAcessableCellPath() =
{
	local vector start, end;
	local float count;
	
	start = self.origin;

	for(count = CELLPATHPOINTS_MAX-1; count >= 0; count-=1)
	{	
		end = self.(cellpath[count]);
		
		if(end != '0 0 0')
		if(!count || IsReachable(start, self.mins, self.maxs, end, self, FALSE) != '0 0 0')
			return end;
	}

	return '0 0 0';
}

vector GetFourWayForwardVector(float count) =
{
	local vector forward;
	
	if(count == 0)
		forward = '0 1 0';
	else
	if(count == 1)
		forward = '1 0 0';
	else
	if(count == 2)
		forward = '0 -1 0';
	else
	if(count == 3)
		forward = '-1 0 0';
	else
		dprint("GetFourWayForwardVector: Error: Bad count.\n");
		
	return normalize(forward);
}

/*void ObjectMarkGrid(entity e) =
{
	if(e.objclass != CLASS_NPC)
	if(e.solid >= SOLID_BBOX)
	if(e.maxs_x > LARGEOBJECT_WIDTH)
		MarkGrid(e, FALSE, TRUE, e.gridpos);
}*/

/*void MarkCellsAroundLargeObjects() =
{
	local entity e;
	e = list_objectchain;
	while(e)
	{
		ObjectMarkGrid(e);
		e = e.objectchain;
	}
}*/

void ConnectCellsOld() =
{
	local entity cell, nearcell, oldcell;
	local vector pos, posB, forward;
	local float count;
	
//	cell = nextent(world);
	cell = list_newcellchain;
	while(cell)
	{
		if(cell.class == CLASS_CELL)
		{
			for(count = 0; count < 4; count++)
			{
				forward = GetFourWayForwardVector(count);
				pos = cell.origin+forward*CELL_MAXS_x*2;
				pos_z += 8;
				posB = cell.origin;
				posB_z += 8;
				tracebox(posB, CELLBBOX_MINS, CELLBBOX_MAXS, pos, TRUE, cell);
				
				if(trace_fraction == 1)
				{
					tracebox(pos, CELLBBOX_MINS, CELLBBOX_MAXS, pos+'0 0 -64', TRUE, cell);
					pos = trace_endpos;
					nearcell = findradius(pos, CELL_MAXS_x*0.5);
					while(nearcell)
					{
						if(nearcell.class == CLASS_CELL)
						if(nearcell != cell)
						{
							SetCellConnection(cell, count+1, nearcell);
							SetCellConnection(nearcell, (count+1)*-1, cell);
							break;
						}
						
						nearcell = nearcell.chain;		
					}
				}
			}
		}
	
	//	cell = nextent(cell);
		oldcell = cell;
		cell = cell.newcellchain;
		NewCellChain_Remove(oldcell);
	}	
}

void ConnectCells() =
{
	local entity cell, nearcell, oldcell, closestcell;
	local vector dist, closestdist, pos, posB, forward;
	local float count, rad;
	
//	cell = nextent(world);
	cell = list_newcellchain;
	while(cell)
	{
		if(cell.class == CLASS_CELL)
		{
			for(count = 0; count < 4; count++)
			{
				forward = GetFourWayForwardVector(count);
				pos = cell.origin+forward*CELL_MAXS_x*2;
				pos_z += CELLBBOX_MAXS_x + 8;
				posB = cell.origin;
				posB_z += CELLBBOX_MAXS_x + 8;
				tracebox(posB, CELLBBOX_MINS, CELLBBOX_MAXS, pos, TRUE, cell);
				
				if(trace_fraction == 1)
				{
					tracebox(pos, CELLBBOX_MINS, CELLBBOX_MAXS, pos+'0 0 -64', TRUE, cell);
					pos = trace_endpos;
					
					closestcell = world;
					closestdist = '0 0 0';
					
					rad = CELLBBOX_MAXS_x*0.5;
					nearcell = findradius(pos, rad);
					while(nearcell)
					{
						if(nearcell.class == CLASS_CELL)
						{
							dist = nearcell.origin - pos;
							if(dist*dist <= rad*rad)
							if(closestdist == '0 0 0' || (closestdist != '0 0 0' && dist*dist < closestdist*closestdist))
							if(nearcell != cell)
							{
								closestcell = nearcell;
								closestdist = dist;
							}
						}
						nearcell = nearcell.chain;
					}
					
					if(closestcell)
					{
						if(closestcell.class == CLASS_CELL)
						{if(closestcell == cell)
							dprint("findradius too big\n");
							SetCellConnection(cell, count+1, closestcell);
							SetCellConnection(closestcell, (count+1)*-1, cell);
						//	break;
						}
						
					//	nearcell = nearcell.chain;		
					}
				}
			}
		}
	
	//	cell = nextent(cell);
		oldcell = cell;
		cell = cell.newcellchain;
		NewCellChain_Remove(oldcell);
	}	
}

void CellFill(entity cell, vector org, float cellfillradius, float loopnum) =
{
	local float count;
	local vector dist1, pos, forward, end;

	for(count = 0; count < 4; count++)
	{
		if(GetCellConnection(cell, count, TRUE))
			continue;
	
		forward = GetFourWayForwardVector(count);
		
		end = org+forward*CELL_MAXS_x*2;

		dist1 = end - cellfiller.origin;
		if(dist1*dist1 > cellfillradius*cellfillradius)
			continue;
	
	//	te_spark(end, '0 0 1000', 100);
		
		pos = IsReachable(org, CELLBBOX_MINS, CELLBBOX_MAXS, end, cell, TRUE);
		
		if(pos != '0 0 0')
		{
			dist1 = pos - cellfiller.origin;
			if(dist1*dist1 > cellfillradius*cellfillradius)
				continue;
		}
		
		if(pos != '0 0 0')
		{
			loopnum++;
			CreateCell(pos, loopnum, cellfillradius, cell.cellzone);
		}
		else
			SetCellConnection(cell, count+1, wall);
		
		pos = '0 0 0';
	}
	
//	numcells-=1;
//	if(!numcells)
//		ConnectCells();
}

//void CellThink() =	{	self.think = SUB_Null;	self.nextthink = 0;	CellFill(self, self.origin, 0);	}

float CreateCell(vector org, float loopnum, float cellfillradius, float zoneid) =
{
	local entity e;
	local vector dist1;
	local float distA;
	
	e = findradius(org, CELL_MAXS_x);//CELL_MAXS_x);
	while(e)
	{
		dist1 = e.origin - org;
		if(dist1*dist1 <= CELL_MAXS_x*CELL_MAXS_x)
		{
			if(e.class == CLASS_CELL)
				return FALSE;
				
			if(e.class == CLASS_OBJECT || e.owner.class == CLASS_OBJECT)
			if(e.objclass != OBJ_NPC || e.behaviorflags & BF_STATIONARY)
			if(e.solid >= SOLID_BBOX)
				return FALSE;
		}
			
		e = e.chain;
	}

	numcells++;

	local entity cell;
	
//	tracebox(org+'0 0 32', CELLBBOX_MINS*0.2, CELLBBOX_MAXS*0.2, org + '0 0 -64', TRUE, e);
//	org = trace_endpos;
	//		PrintNumEntsInList("CREATECELL A");
	cell = spawn();
	//				PrintNumEntsInList("CREATECELL B");
//	cell.id = 999;
	cell.class = CLASS_CELL;
	cell.cellzone = zoneid;
	cell.filloccupancy = 1;
	setorigin(cell, org);

	//THIS LINE MAKES CELLS VISIBLE IF SERVER ENTITY NETWORKING IS ENABLED
//	SetAndPrecacheModel(cell, "models/objects/nav_cell.dpm"); 	cell.scale = CELL_SCALE;
	
	NewCellChain_Add(cell);

	if(list_tempcell)
	{
		cell.tempcellchain = list_tempcell;
		list_tempcell = cell;
	}
	
//	cell.SendEntity = SendCell; // AI DEBUGGING

//	if(loopnum < 50)
		CellFill(cell, org, cellfillradius, loopnum);
/*	else
	{
		cell.think = CellThink;
		cell.nextthink = time +0.01;
	}*/
	
	return TRUE;
}

void info_cell_spawner() =	{	dprint("info_cell_spawner found. please remove this since they are not used anymore\n");	}

/*void InitializeNavigationCells() =
{
	return;
	
	local entity spawner;
	local vector start;
	local float count;
	
	spawner = Chain2(findchain(classname, "info_cell_spawner"));
	if(spawner == world)
		spawner = Chain2(findchainfloat(objclass, CLASS_SPAWNPAD));
	
	if(!spawner)
	{
		dprint("InitializeNavigationCells: Error: Can't find info_cell_spawner to begin placing cells.\n");
		return;
	}
	
	for(count = 0; spawner; count++)
	{
		start = spawner.origin+'0 0 64';
		tracebox(start, CELL_MINS, CELL_MAXS, start+'0 0 -10000', TRUE, self);
		start = trace_endpos;
		
		CreateCell(start, 0, count+1);
		
		spawner = spawner.chain2;
	}
}*/