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
// self.frame is the interpolation target (new frame)
// self.frame1time is the animation base time for the interpolation target
// self.frame2 is the interpolation start (previous frame)
// self.frame2time is the animation base time for the interpolation start

.float lastlerptime;

void PreviousFrame(vector frames_current, void() framefunc) =
{
	self.framespeed = frames_current_z;

	if(!self.framespeed)
		return;

	self.frame2 = self.frame;	
	self.frame2time = time;
		
	if(self.frame <= frames_current_x || self.frame > frames_current_y) 
		self.frame = frames_current_y; // if playing another animation or on the last frame go to the first frame of intended animation
	else
 		self.frame = self.frame - 1; // otherwise go to the next frame

	if(self.frame == frames_current_x)	
		self.AnimFunc = self.Anim_Default;
	else
		self.AnimFunc = framefunc;
		
	self.frame1time = time + 1/frames_current_z;
}

void NextFrame(vector frames_current, void() framefunc) =
{
	self.framespeed = frames_current_z;

	if(!self.framespeed)
		return;

	self.frame2 = self.frame;	
	self.frame2time = time;
		
	if(self.frame < frames_current_x || self.frame >= frames_current_y) 
		self.frame = frames_current_x; // if playing another animation or on the last frame go to the first frame of intended animation
	else
 		self.frame = self.frame+1; // otherwise go to the next frame

	if(self.frame == frames_current_y)	
		self.AnimFunc = self.Anim_Default;
	else
		self.AnimFunc = framefunc;
		
	self.frame1time = time + 1/frames_current_z;
}

void InterpolateAnimation() =
{
	local float oframe1time;
	
	oframe1time = self.frame1time;

	if(self.frame1time <= time)
	if(IsAssignedFunction(self.AnimFunc))
		self.AnimFunc();

	if(self.framespeed)
	if(time - self.lastlerptime >= (1/60) || oframe1time <= time)
	{
		self.lastlerptime = time;
		self.lerpfrac = 1 - ((time - self.frame2time) / (self.frame1time-self.frame2time));
	}
}

void Predraw() =
{
//	if(self.objclass == OBJ_PORTAL)
//	{
//		print(ftos(self.frame));print("\n");
//}
	InterpolateAnimation();
	
	if(IsAssignedFunction(self.EffectFunc))
		self.EffectFunc();
}

void anim_basic() =
{
	if(self.frame == self.frames_idle_y)
	{
		if(!self.alpha)
			self.alpha = 1;
	
		if(frametime)
			self.alpha -= frametime/0.2;//		1/((1/self.frames_idle_z)/frametime);
		
		if(self.alpha < 0.001)
		{
			SH_RemoveEnt(self);
			return;
		}
		
		self.nextthink = time;
		self.think = anim_basic;
		return;
	}

	NextFrame(self.frames_idle, anim_basic);
}

void anim_movement() =
{	
	local vector frames_current;//, frames_idle, frames_move;

	// x = first frame, y = last frame, z = framerate	
//	frames_idle		= '1 12 12';
//	frames_move		= '13 13 12';
	
	
	
	if(self.angles_x >= 4 || self.angles_x <= -4 || self.angles_z >= 4 || self.angles_z <= -4)
		frames_current = self.frames_move;
	else
		frames_current = self.frames_idle;
		
	NextFrame(frames_current, anim_movement);
}

void player_cannon_idle() =	{	self.frame = 1;		}

/*void shoot_cannon() =
{
	local vector frames_current;
	
	if(self.owner.firingfrom == 0)
		frames_current = self.frames_shoot_cannon_R;
	else
	if(self.owner.firingfrom == 1)
		frames_current = self.frames_shoot_cannon_L;

	NextFrame(frames_current, shoot_cannon);
	
//	if(self.frame == frames_current_y) // on last frame
//		self.owner.firingfrom = !self.owner.firingfrom;		
}*/

// ARE ENEMY FRAMES GOING TO MATCH PLAYER FRAMES?

void shoot_cannon2() =	{	NextFrame('25 36 48', shoot_cannon2);	}

void shoot_miniguns() =	{	NextFrame('61 72 12', shoot_miniguns);	}

void shoot_missiles() =	{	NextFrame('73 84 12', shoot_missiles);	}

void shoot_hmissiles() =
{
	local vector frames_current;
	
	if(self.firingfrom == 0)
		frames_current = self.frames_shoot_hmissiles_R;
	else
	if(self.firingfrom == 1)
		frames_current = self.frames_shoot_hmissiles_L;
	
	NextFrame(frames_current, shoot_hmissiles);
}