/* Aperture Science Cube

   Copyleft (<)2010. 
   None rights reserved.
   DO distribute.

   Inspired by Wazat's code from inside3d.com
*/

void() asscube_think =
{
    self.nextthink = time;
};

void() asscube_push =
{
    local vector vec, selforg, otherorg;
    local float dist; dist = 2;
 
    if (other.classname != "player") return;
    if (other.absmin_z + 4 < self.absmax_z)
    {
           // getting origins this way allows for BSP entities to work too.
           otherorg = 0.5*(other.absmin + other.absmax);
           selforg = 0.5*(self.absmin + self.absmax);

           // Don't move in the direction the player is facing. Instead, always move away from the player.
           vec = normalize(selforg - otherorg); // dir from them toward me
           vec = vectoangles(vec);
//           self.flags = self.flags - FL_ONGROUND;
           walkmove(vec_y, dist);
    }
    else // (touch on top)
    {
           other.flags = other.flags | FL_ONGROUND;
    }
};

/*QUAKED ass_cube (0 0 1) (0 0 0) (32 32 32)
  Companion Cube
*/
void() ass_cube =
{
        local entity new;
        local vector newsize;

        self.mangle = self.angles;
        self.angles = '0 0 0';

        precache_model ("progs/cube.bsp");
        setmodel (self, "progs/cube.bsp");
        setsize (self, '0 0 0', '32 32 32');

        self.classname = "cube";
        self.solid = SOLID_SLIDEBOX;
        self.movetype = MOVETYPE_STEP;
        setorigin (self, self.origin);
        self.oldorigin = self.origin;
        self.touch = asscube_push;
        self.nextthink = time + 0.1;
        self.think = asscube_think;
};
