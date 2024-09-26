////////////////////////////////////////
// Nether Menu System source codes
// Property of RazorWind Games
// code written by Pavel P. [VorteX] Timofeyev
//					    email:paul.vortex@gmail.com
// This code is free for non-commercial use, 
// though don't forget to credit me :) 
////////////////////////////////////////

/*
Grid

draws a grid
no finished yet
*/

void() Object_Grid_Draw =
{
	vector tGridSize, tGridBorder;
	
	ObjectLib_Background_Draw();
		
	tGridSize_x = 16*self._scale_x;
	tGridSize_y = 16*self._scale_y;
	tGridBorder_x = 2*self._scale_x;
	tGridBorder_y = 2*self._scale_y;
	Draw2D_DrawGrid(self._absmin, tGridSize, tGridBorder, self._size, '1 1 1', 1, 0, Null_GridCellDraw);
	
	ObjectLib_Foreground_Draw();
}

void() Object_Grid_Spawn =
{
	self.mDraw = Object_Grid_Draw;
}

void() Object_Grid_Init =
{
}

void() Object_Grid =
{
	className = "Grid";
	classInit = Object_Grid_Init;
	classSpawn = Object_Grid_Spawn;
}