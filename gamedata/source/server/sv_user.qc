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
float lastclientthink, sv_maxspeed, sv_friction, sv_accelerate, sv_stopspeed;
float sv_edgefriction, sv_rollangle, sv_rollspeed, sv_divspeed;

// LordHavoc:
// Highly optimized port of SV_ClientThink from engine code to QuakeC.
// No behavior changes!  This code is much shorter and probably faster than
// the engine code :)

// note that darkplaces engine will call this function if it finds it,
// so modify for your own mods and enjoy...

// note also, this code uses some builtin functions from dpextensions.qc
// (included with darkplaces engine releases)

void SV_PlayerPhysics() =
{
	local vector wishvel, wishdir, v;
	local float wishspeed, f;

	if (self.movetype == MOVETYPE_NONE)
		return;

	if(activityhalted || self.menus_opened)
		self.movement = '0 0 0';
		
	if (self.punchangle != '0 0 0')
	{
		f = vlen(self.punchangle) - 10 * frametime;
		if (f > 0)
			self.punchangle = normalize(self.punchangle) * f;
		else
			self.punchangle = '0 0 0';
	}

	// if dead, behave differently
	if (self.health <= 0)
		return;

	if (time != lastclientthink)
	{
		lastclientthink = time;
		sv_maxspeed = cvar("sv_maxspeed");
		sv_friction = cvar("sv_friction");
		sv_accelerate = cvar("sv_accelerate");
		sv_stopspeed = cvar("sv_stopspeed");
		sv_edgefriction = cvar("edgefriction");
		// LordHavoc: this * 4 is an optimization
		sv_rollangle = cvar("sv_rollangle") * 4;
		// LordHavoc: this 1 / is an optimization
		sv_rollspeed = cvar("sv_rollspeed");
		if(sv_rollspeed)
			sv_divspeed = 1 / sv_rollspeed;
	}

	// show 1/3 the pitch angle and all the roll angle
//	makevectors(self.angles);
//	self.angles_x = bound(-1, self.velocity * v_forward * sv_divspeed, 1) * sv_rollangle * -1;
//	self.angles_z = bound(-1, self.velocity * v_right * sv_divspeed, 1) * sv_rollangle;
	
	if (!self.fixangle)
	{
	//	self.angles_x = (self.v_angle_x + self.punchangle_x) * -0.333;
		self.angles_y = self.v_angle_y + self.punchangle_y;
	}

	if (self.flags & FL_WATERJUMP )
	{
		self.velocity_x = self.movedir_x;
		self.velocity_y = self.movedir_y;
		if (time > self.teleport_time || self.waterlevel == 0)
		{
			self.flags = self.flags - (self.flags & FL_WATERJUMP);
			self.teleport_time = 0;
		}
		return;
	}

	makevectors(self.v_angle);

	// swim
	if (self.waterlevel >= 2)
	if (self.movetype != MOVETYPE_NOCLIP)
	{
		self.flags = self.flags - (self.flags & FL_ONGROUND);

		if (self.movement == '0 0 0')
			wishvel = '0 0 -60'; // drift towards bottom
		else
			wishvel = v_forward * self.movement_x + v_right * self.movement_y + '0 0 1' * self.movement_z;

		wishspeed = vlen (wishvel);
		if (wishspeed > sv_maxspeed)
			wishspeed = sv_maxspeed;

		wishspeed = wishspeed * 0.7;

		// water friction
		if (self.velocity != '0 0 0')
		{
			f = vlen(self.velocity) * (1 - frametime * sv_friction);
			if (f > 0)
				self.velocity = normalize(self.velocity) * f;
			else
				self.velocity = '0 0 0';
		}
		else
			f = 0;

		// water acceleration
		if (wishspeed <= f)
			return;

		f = min(wishspeed - f, sv_accelerate * wishspeed * frametime);
		self.velocity = self.velocity + normalize(wishvel) * f;
		return;
	}

	// hack to not let you back into teleporter
	if (time < self.teleport_time && self.movement_x < 0)
		wishvel = v_right * self.movement_y;
	else
	{
		// LordHavoc: this NOCLIP check is a fix for the 'not moving while looking straight up/down when noclipping' bug in Quake
		if ((self.flags & FL_ONGROUND) || (self.movetype == MOVETYPE_NOCLIP))
			makevectors (self.v_angle_y * '0 1 0');

		if(self.lockedcamera)
		{
			wishvel_x = self.movement_y;
			wishvel_y = self.movement_x;
		}
		else
			wishvel = v_forward * self.movement_x + v_right * self.movement_y;
	}

	if (self.movetype != MOVETYPE_WALK)
		wishvel_z = self.movement_z;
	else
		wishvel_z = 0;

	wishdir = normalize(wishvel);
	wishspeed = vlen(wishvel);
	if (wishspeed > sv_maxspeed)
		wishspeed = sv_maxspeed;

	if (self.movetype == MOVETYPE_NOCLIP) // noclip
	{
		self.flags = self.flags - (self.flags & FL_ONGROUND);
		self.velocity = wishdir * wishspeed;
	}
	else if (self.flags & FL_ONGROUND) // walking
	{
		// friction
		if (self.velocity_x || self.velocity_y)
		{
			v = self.velocity;
			v_z = 0;
			f = vlen(v);

			// if the leading edge is over a dropoff, increase friction
			v = self.origin + normalize(v) * 16 + '0 0 1' * self.mins_z;

			traceline(v, v + '0 0 -34', TRUE, self);

			// apply friction
			if (trace_fraction == 1.0)
			{
				if (f < sv_stopspeed)
					f = 1 - frametime * (sv_stopspeed / f) * sv_friction * sv_edgefriction;
				else
					f = 1 - frametime * sv_friction * sv_edgefriction;
			}
			else
			{
				if (f < sv_stopspeed)
					f = 1 - frametime * (sv_stopspeed / f) * sv_friction;
				else
					f = 1 - frametime * sv_friction;
			}

			if (f < 0)
				self.velocity = '0 0 0';
			else
				self.velocity = self.velocity * f;
		}

		// acceleration
		f = wishspeed - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * min(f, sv_accelerate * frametime * wishspeed);
	}
	else // airborn
	{
		if (wishspeed < 30)
			f = wishspeed - (self.velocity * wishdir);
		else
			f = 30 - (self.velocity * wishdir);
		if (f > 0)
			self.velocity = self.velocity + wishdir * (min(f, sv_accelerate) * wishspeed * frametime);
	}
}