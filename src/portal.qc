/*  Copyright (C) 1996-1997  Robert "BOby" Siska

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

//// Constants
float 		PORTAL_ATTACK		= 0.5;
float		PORTAL_REFIRE		= 0.2;
float		PORTAL_BUFFER		= 0.9;
float		PORTAL_KICK		= 120;
float 		PORTAL_RANGE		= 60;

float		CUBE_LIFTED		= 2;
float		CUBE_DROPPED		= 3;

//// Functions
void()		  PortalImpulses;
void()		  PortalPrecache;
void(entity p)	  PortalErase;
void()		  Portal1Touch;
void()		  Portal2Touch;
void()		  PortalDeathTouch;
void(entity org)  PortalTeleportEffect;
void()		  PortalFire;
void()		  GripFire;
void()		  PortalUpdate;
void()		  player_run;
void()		  PortalCubeThink;
void(entity own, entity hit, vector org) T_PortalSpawn;
vector(vector org) portal_face;
vector(entity p)  portal_clip_player;
void() W_SetCurrentAmmo;


//// Global variables
// Entities
entity          portal1_entity;
entity          portal2_entity;
// Counters
float 		portal_global;
float		portal1_exist;
float		portal2_exist;
float		portal_mode; //1 = deathmatch, 0 = cooperative
.entity 	lastport;
.float 		nextportcolour;
.entity		cube;
.float		nextthink1;
.float		grip_dist;
// Models
string		model_portal1;
string		model_portal2;
string		model_portalgun;
// Sounds
string		sound_fire;
string		sound_close;
string		sound_use;

//void() player_light1;

//// Gun animation frames
$frame portal1 portal2 portal3 portal4 portal5
void()  player_portal1 = [$portal1, player_portal2] {self.weaponframe=1;};
void()  player_portal2 = [$portal2, player_portal3] {self.weaponframe=2;};
void()  player_portal3 = [$portal3, player_portal4] {self.weaponframe=3;PortalFire();};
void()  player_portal4 = [$portal4, player_portal5] {self.weaponframe=4;};
void()  player_portal5 = [$portal5, player_run] {self.weaponframe=5;};

$frame grip1 grip2 grip3 grip4 grip5 grip6
void()	player_grip1 = [$grip1, player_grip2] {self.weaponframe=1;};
void()  player_grip2 = [$grip2, player_grip3] {self.weaponframe=2;};
void()  player_grip3 = [$grip3, player_grip4] {self.weaponframe=3;GripFire();};
void()  player_grip4 = [$grip4, player_grip5] {self.weaponframe=4;};
void()	player_grip5 = [$grip5, player_grip6] {self.weaponframe=5;};	
void()  player_grip6 = [$grip6, player_run] {self.weaponframe=6;};

  //////////////
 //// Main Code
//////////////
void() null_die = {};
void() PortalInit = {
	// Initialize global variables
	model_portal1 = "progs/portal1.bsp";
	model_portal2 = "progs/portal2.bsp";
	model_portalgun = "progs/v_portal.mdl";

	sound_fire = "portal/fire.wav";
	sound_close = "portal/close.wav";
	sound_use = "portal/use.wav";

	self.cube = spawn();
	self.cube.cnt = 0;

        portal_global = 0;
        portal1_exist = 0;
        portal2_exist = 0;
        portal_mode = 1; //1 = deathmatch, 0 = cooperative
};

void() PortalPrecache = {
	// Precache models
	precache_model(model_portal1);
	precache_model(model_portal2);
	precache_model(model_portalgun);

	precache_sound(sound_fire);
	precache_sound(sound_close);
	precache_sound(sound_use);
};

vector(vector org) portal_face = {
	// Returns facing for the portal
	local vector v;
	v = trace_plane_normal;
	v_z = v_z * -1;
	return vectoangles(v);
};

vector(entity p) portal_clip_player = {
	// Returns coordinates where the teleported object appears
	local vector org;
	org = p.origin;

	makevectors(p.angles);
	org = org + v_forward*48;
	return org;
};

void() PortalImpulses = {
	// Handles the impulses
	local entity tmp;
	local string str_tmp;
	if (self.impulse == 98) {// Close portals
	    if (self.weapon == IT_PORTAL_GUN) {
                 if (portal_mode == 1) {
		 	 if (self.lastport) {
				 PortalErase(self.lastport);
				 PortalErase(self.lastport.enemy);
				 self.lastport = world;
			 }
		 } else {
			 PortalErase(portal1_entity);
			 PortalErase(portal2_entity);
		 }
	    }
        }
	if (self.impulse == 99) { // sheath portal gun
		self.items = self.items | IT_PORTAL_GUN;
		self.weapon = IT_PORTAL_GUN;
		W_SetCurrentAmmo();
	}
	if (self.impulse == 97) { // Toggle deathmatch/cooperative mode
		if (portal_mode == 0) {
			PortalErase(portal1_entity);
			PortalErase(portal2_entity);
			portal_mode = 1; // set to deathmatch mode
			bprint("portal_gun: Deathmatch mode set.\n");
		} else {
			if (self.lastport) {
				PortalErase(self.lastport);
				if (self.lastport.enemy)
					PortalErase(self.lastport.enemy);
				self.lastport = world;
			}
			portal_mode = 0; // set to cooperative mode
			bprint("portal_gun: Cooperative mode set.\n");
		}
	}
	if (self.impulse == 96) { // Force blue portal
		if (self.weapon == IT_PORTAL_GUN) {
		 if (portal_mode == 1) {
			 if (self.nextportcolour != 0) {
			  self.nextportcolour = 0;
			  tmp = self.lastport.enemy;
			  PortalErase(self.lastport);
			  self.lastport = tmp;
			 }
			 player_portal1();
		 } else {
			portal_global = 0;
			player_portal1();
		 }
		}
	}
	if (self.impulse == 95) { // Force red portal
		if (self.weapon == IT_PORTAL_GUN) {
		 if (portal_mode == 1) {
			 if (self.nextportcolour != 1) {
			  self.nextportcolour = 1;
			  tmp = self.lastport.enemy;
			  PortalErase(self.lastport);
			  self.lastport = tmp;
			 }
			 player_portal1();
		 } else {
			portal_global = 1;
			player_portal1();
		 }
		}
	}
	if (self.impulse == 94) {
		if (self.weapon == IT_PORTAL_GUN)
		if (self.cube.cnt == 0) {
			player_grip1();
		} else {
		 self.cube.cnt = 0; // self.cube is vacant
		 self.cube.enemy.nextthink = self.cube.nextthink;
		 self.cube.enemy.think = self.cube.think;
		 self.cube.enemy.touch = self.cube.touch;
		 self.cube.enemy.flags = (self.cube.enemy.flags | FL_ONGROUND) - FL_ONGROUND;
		 self.cube.enemy.effects = 0;
		 self.cube.enemy.owner = world;
		 makevectors(self.v_angle);
		 self.cube.enemy.velocity = v_forward*200 + v_up*50;
		}
	}
};

void() PortalFire = 
{
	// Finds the destination for the portal
	local vector src;
	local vector dir;

	makevectors(self.v_angle);
	src = self.origin + v_forward*10;
        dir = self.origin + v_forward*100000;//far away in my nose direction

	sound(self,CHAN_WEAPON,sound_fire,1,ATTN_NORM);
	 
        traceline(src,src+dir,FALSE,self);
	if (trace_fraction != 1)
        {
                if (trace_ent.classname == "hardlight")
                {
                     traceline(trace_endpos,dir,TRUE,trace_ent);
                     if (trace_fraction != 1)
                        T_PortalSpawn(self,trace_ent,trace_endpos);
                } else
                {
        		T_PortalSpawn(self,trace_ent,trace_endpos);
                }
        }
	self.attack_finished = time + PORTAL_ATTACK;
};

void() GripFire = {
	// Finds the entity
	local entity e;
	local vector where;
	local float dist,found,i;
	local string tmp;
	
	found = FALSE;
	i = 25;
	
	sound(self,CHAN_WEAPON,sound_fire,1,ATTN_NORM);
	makevectors(self.v_angle);
	
	while ((found == FALSE) && (i != 125)) {
		where = self.origin + v_forward*i;
		e = findradius(where,30+(i/2));
		while ((e != world) && (found == FALSE)) {
			if (visible(e))
			if (infront(e))
			if ((e.movetype == MOVETYPE_TOSS) || (e.classname == "cube")) {
				dist = vlen(e.origin - self.origin + self.view_ofs);
				found = TRUE;
				break;
			}
			if (found == FALSE)
				e = e.chain;
		}
		i = i + 25;
	}
	// e is first found entity
	if (found == FALSE) return;
	if (e == world) return;
	if (self.cube.cnt == 1) return; // already carrying item
	if (e.owner.classname == "player") { // item is carried by someone
		e.owner.cube.cnt = 0;
		e.owner.cube.enemy.nextthink = e.owner.cube.nextthink;
		e.owner.cube.enemy.think = e.owner.cube.think;
		e.owner.cube.enemy.flags = (e.owner.cube.enemy.flags | FL_ONGROUND) - FL_ONGROUND;
		e.owner.cube.enemy.effects = 0;		
//		bprint(e.owner.classname);
	}
	
	WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
	WriteByte(MSG_BROADCAST, TE_LIGHTNING2);
	WriteEntity(MSG_BROADCAST, self);
	WriteCoord(MSG_BROADCAST,self.origin_x);
	WriteCoord(MSG_BROADCAST,self.origin_y);
	WriteCoord(MSG_BROADCAST,self.origin_z+30);
	WriteCoord(MSG_BROADCAST,e.origin_x);
	WriteCoord(MSG_BROADCAST,e.origin_y);
	WriteCoord(MSG_BROADCAST,e.origin_z+16);

	self.cube = spawn();
	self.cube.owner = e.owner;
	self.cube.think = e.think;
	self.cube.nextthink = e.nextthink;
	self.cube.touch = e.touch;
	self.cube.cnt = 1;
	self.cube.enemy = e;
	
	e.owner = self;
	e.cnt = CUBE_LIFTED;
	e.think = PortalCubeThink;
	e.nextthink = 0.02;
	e.touch = SUB_Null;
	e.grip_dist = dist;
	e.effects = EF_BRIGHTFIELD;
};

void(entity own, entity hit, vector org) T_PortalSpawn = {
	// Spawns portals
	local entity p,e;
	local vector dir;
		
        if ( (hit.classname == "portalproof") || (hit.classname == "door") || (hit.classname == "hardlight2") || (hit.classname == "pellet") )
        {
                p = spawn();
                p.fixangle = 1;
                p.angles = portal_face(org);
                setorigin (p, org);
                PortalErase(p);
                return;
        }
       
        if (portal_mode == 1) { // deathmatch mode
		p = spawn();
		p.owner = own;
		p.movetype = MOVETYPE_NONE;
		p.solid = SOLID_TRIGGER;
		p.classname = "portal";
		p.fixangle = 1;
		p.angles = portal_face(org);
                p.punchangle = trace_plane_normal;
		p.touch = PortalDeathTouch;
		p.frags = time - 1;
		p.nextthink = time + 0.1;
		p.think = PortalUpdate;
		p.movetarget = hit;
		p.oldorigin = hit.origin;
//		p.effects = EF_DIMLIGHT;

		if (own.lastport) {
			p.enemy = own.lastport;
			PortalErase(p.enemy.enemy);
			p.enemy.enemy = p;
		}
		own.lastport = p;
		
		if (own.nextportcolour) {
			setmodel(p,model_portal2);
			own.nextportcolour = 0;
		} else {
			setmodel(p,model_portal1);
			own.nextportcolour = 1;
		}
//		setsize(p,p.mins,p.maxs);
		setorigin(p,org);
		
		// Wake entities near the portal gates
		e = findradius(p.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
		}
		e = findradius(p.enemy.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
		}
		return;
	}
	// cooperative mode
	if (portal_global == 0) { // Blue portal
                if (portal1_exist == 1) { // Delete if existing
                        PortalErase(portal1_entity);
                        portal1_exist = 0;
                }       
                portal1_entity = spawn();
		portal1_entity.owner = own;
		portal1_entity.movetype = MOVETYPE_NONE;
		portal1_entity.solid = SOLID_TRIGGER;
		portal1_entity.classname = "portal1";
		portal1_entity.fixangle = 1;
		portal1_entity.angles = portal_face(org);
		portal1_entity.punchangle = trace_plane_normal;
                portal1_entity.touch = Portal1Touch;
		portal1_entity.frags = time - 0.1;
		portal1_entity.nextthink = time + 0.1;
		portal1_entity.think = PortalUpdate;
		portal1_entity.movetarget = hit;
		portal1_entity.oldorigin = hit.origin;
//		portal1_entity.effects = EF_DIMLIGHT; // glowing
		
		setmodel(portal1_entity, model_portal1);
//		setsize(portal1_entity,VEC_HULL_MIN,VEC_HULL_MAX);
		setorigin(portal1_entity,org);

                
		portal1_entity.frame = 4;

                portal1_exist = 1;
                portal_global = 1;

		// Wake the entities near the portal gates
		e = findradius(portal1_entity.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
			
		}
		e = findradius(portal2_entity.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
			
		}
        } else if (portal_global == 1) { // Yellow portal
		if (portal2_exist == 1) {
                        PortalErase(portal2_entity);
                        portal2_exist = 0;
                }       
                portal2_entity = spawn();
		portal2_entity.owner = own;
		portal2_entity.movetype = MOVETYPE_NONE;
		portal2_entity.solid = SOLID_TRIGGER;
		portal2_entity.classname = "portal2";
		portal2_entity.fixangle = 1;
		portal2_entity.angles = portal_face(org);
		portal2_entity.punchangle = trace_plane_normal;
                portal2_entity.touch = Portal2Touch;
		portal2_entity.frags = time - 0.1;
		portal2_entity.nextthink = time + 0.1;
		portal2_entity.think = PortalUpdate;
		portal2_entity.movetarget = hit;
		portal2_entity.oldorigin = hit.origin;
//		portal2_entity.effects = EF_DIMLIGHT;
		
		setmodel(portal2_entity, model_portal2);
//		setsize(portal2_entity,);
		setorigin(portal2_entity,org);

                
		portal2_entity.frame = 4;

                portal2_exist = 1;
                portal_global = 0;

		e = findradius(portal1_entity.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
		}
		e = findradius(portal2_entity.origin, PORTAL_RANGE);
		while (e != world) {
			if (e.movetype == MOVETYPE_TOSS)
			if (e != own) {
				setorigin(e,e.origin + '0 0 10');
				e.flags = (e.flags | FL_ONGROUND) - FL_ONGROUND;
			}
			e = e.chain;
		}

        }
};

void(entity org) PortalTeleportEffect = {
        // Spawns teleport fog
	local entity s;
	
	makevectors(org.angles);
	s = spawn();
        s.origin = org.origin + v_forward*50;
        s.nextthink = time + 0.2;
	s.think = SUB_Remove;

        sound(s, CHAN_WEAPON, sound_use, 1, ATTN_NORM);

        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_TELEPORT);
        WriteCoord(MSG_BROADCAST, s.origin_x);
        WriteCoord(MSG_BROADCAST, s.origin_y);
        WriteCoord(MSG_BROADCAST, s.origin_z);
};

void(entity org) PortalEraseEffect = {
        // Spawns teleport fog
	local entity s;
	
	makevectors(org.angles);
	s = spawn();
        s.origin = org.origin + v_forward*50;
        s.nextthink = time + 0.2;
	s.think = SUB_Remove;

        sound(s, CHAN_WEAPON, sound_close, 1, ATTN_NORM);

/*        WriteByte(MSG_BROADCAST, SVC_TEMPENTITY);
        WriteByte(MSG_BROADCAST, TE_TELEPORT);
        WriteCoord(MSG_BROADCAST, s.origin_x);
        WriteCoord(MSG_BROADCAST, s.origin_y);
        WriteCoord(MSG_BROADCAST, s.origin_z);*/
};


void(entity p) PortalErase = {
	// Erases given portal
	local entity t;
        local float play;
	if (!p) return;
	play=0;
	if (portal_mode == 1) { //dm mode
		t = self;
		self = p;
		PortalEraseEffect(p);

		remove(self);
		self = t;
		return;
	}
	//coop mode
	if (p) {
		if (p.classname=="portal1") {
			if (portal1_exist == 1) play=1;
			portal1_exist = 0;
		} else if (p.classname=="portal2") {
			if (portal2_exist == 1) play=1;
			portal2_exist = 0;
		}
		if (play == 1) {
			PortalEraseEffect(p);
		}
		remove(p);
	}
};

void() PortalUpdate = {
	// What do portal gates think (nothing)
	self.nextthink = time + 0.1;
};

void() SUB_teleport = {
	// Safe setorigin (for use in handler functions)
	setorigin(self,self.origin);
	self.nextthink = self.nextthink1;
	self.think = self.think1;
};

void() Portal1Touch = {
	// Handles touch with Blue portal
	local float vel;
	local vector org;
	local vector oldvel;
	local string temp2;
	
	if (portal2_exist==0) return;
	if (self.frags>time) return;

	vel=vlen(other.velocity) + PORTAL_KICK;
	oldvel = other.velocity;
//FIXME: see todo section 4
			
	org=portal_clip_player(portal2_entity);

	// just setorigin can't be used in touch function
	other.origin = org;
	other.nextthink1 = other.nextthink;
	other.nextthink = time + 0.1;
	other.think1 = other.think;
	other.think = SUB_teleport;

	PortalTeleportEffect(self);
	PortalTeleportEffect(portal2_entity);

	self.frags = time + PORTAL_REFIRE;
	portal2_entity.frags = time + PORTAL_REFIRE;

	other.fixangle = 1;
	other.velocity = vel * normalize(portal2_entity.punchangle) * PORTAL_BUFFER;
	if ((other.velocity_x == 0) && (other.velocity_y == 0)) {
//		other.velocity_x = oldvel_x / 2;
//		other.velocity_y = oldvel_y / 2;
                other.fixangle = 0;
	}
	other.angles_x = 0;
	other.angles_y = vectoyaw(other.velocity);
	other.angles_z = 0;
	other.v_angle_z = 0;
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

void() Portal2Touch = {
	// Handles touch with Yellow portal
	local float vel;
	local vector org;
	local vector oldvel;

	if (portal1_exist==0) return;
	if (self.frags > time) return;
	
	vel=vlen(other.velocity) + PORTAL_KICK;
	oldvel = other.velocity;
//FIXME:see todo section 4
		
	org=portal_clip_player(portal1_entity);
		
	other.origin = org;
	other.nextthink1 = other.nextthink;
	other.nextthink = time + 0.1;
	other.think1 = other.think;
	other.think = SUB_teleport;
		
	PortalTeleportEffect(portal1_entity);
	PortalTeleportEffect(self);

	portal1_entity.frags = time + PORTAL_REFIRE;
	self.frags = time + PORTAL_REFIRE;

	other.fixangle = 1;
	other.velocity = vel * normalize(portal1_entity.punchangle) * PORTAL_BUFFER;
	if ((other.velocity_x == 0) && (other.velocity_y == 0)) {
                other.fixangle = 0;
	}
	other.angles_x = 0;
	other.angles_y = vectoyaw(other.velocity);
	other.angles_z = 0;
	other.v_angle_z = 0;
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

void() PortalDeathTouch = {
	// Handles touches in deathmatch mode
	local float vel;
	local vector org;
	local vector oldvel;

	if (!self.enemy) return;
	if (self.frags > time) return;

	vel = vlen(other.velocity) + PORTAL_KICK;
	oldvel = other.velocity;

	self.frags = time + PORTAL_REFIRE;
	self.enemy.frags = time + PORTAL_REFIRE;

	org = portal_clip_player(self.enemy);

	other.origin = org;
	other.nextthink1 = other.nextthink;
	other.nextthink = time + 0.1;
	other.think1 = other.think;
	other.think = SUB_teleport;

	PortalTeleportEffect(self);
	PortalTeleportEffect(self.enemy);

	other.fixangle = 1;
	other.velocity = vel * self.enemy.punchangle * PORTAL_BUFFER;
	if ((other.velocity_x == 0) && (other.velocity_y == 0))
	{
                other.fixangle = 0;
	}
	other.angles_x = 0;
	other.angles_y = vectoyaw(other.velocity);
	other.angles_z = 0;
	other.v_angle_z = 0;
	other.flags = other.flags - other.flags & FL_ONGROUND;
};

void() PortalCubeThink = {
	// What does carried item think
	local vector v,src,org,tmporg;
	local entity e;
	local float dist,out_dist,oldz;
	self.nextthink = time + 0.02;
	
	if (self.cnt == CUBE_DROPPED) return;
	
	e = self.owner;
	
	makevectors(e.v_angle);
	src = e.origin + '0 0 16';
	traceline(src,src+v_forward*125, FALSE,e);
	org = trace_endpos - v_forward*4;
	dist = vlen(org-src+e.view_ofs);

	if (dist < self.grip_dist) 
		out_dist = dist - 10;
	else
		out_dist = self.grip_dist;
	
	e = self.owner;
	makevectors(e.angles);
	self.angles = e.angles;
	self.angles_x = 0;
	if (dist > 10)
		tmporg = e.origin + v_forward*out_dist + v_right*20;
	else {
		tmporg = e.origin;
	}
	tmporg_z = e.origin_z;
	setorigin(self,tmporg);
	
};		
