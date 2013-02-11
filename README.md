Type of Mod
------------
Quake C : yes
Sound   : yes
Models  : yes

Format of QuakeC
----------------
.qc files : yes
progs.dat : yes

How to install
--------------
Easily. Just download the portal_gun package, enter your quake directory
and extract it. Then you can run:

$ quake -game portal_gun

For demonstration, toggle console and type 'playdemo portal'.

Description
-----------
	Portal Gun (Handheld Portal Device) is a device that creates
and inter-spatial portal (wormhole) in level. It is quaked version of the
gun from game Portal (part of Orange box) by Valve software <www.valvesoftware.com>
also implemented in some half-life games. Ussage is simple: fire with the portal
gun to the desired locations to opend first and second portals. Now, the wormhole
is created between them. You can enter it, or close it down.

	This mod tries to simulate (poorly) the physic as seen in original Portal game.
That means, when you enter the first portal, your velocity and angles is restored
on the other side of wormhole. This allows you to do big jumps and other tricks (see fig. 1).

	Teleporting of pickups is possible, which allows interesting strategies (like
gathering pickups on one place and the pick them all up at once; or reaching
distant items just by shooting at them.)

	Portal Gun can also be used as item carrier. Simply aim the item and 
press 'f'. To drop carried item, press 'f' again.

Fig. 1 - Example of clever usage of portal gun - power of gravity:
(see 'tricks' file for more)
*EXIT*
  __      ,.,
 |  |   ,'   ',
-|  |--|-----, ',
 |  | \|/   / | |    Create portals, jump to the lower one (arrow 1)
___________/  | 2      ,.,   and the higher one will shoot you up (arrow 2)
          |   | |    ,'   ',  
          |   | |  O       ', 
          |   | |  |-       |
          |  /'-|--/\-,     |
          | /  (_)   / |    |
          |/________/  |    1
                   |   |    |
                   |   |    |
                   |   |   \|/
                   |  /'----'-- - -
                   | /     (_)
                   |/_________ _ _

Portal gun modes
----------------
Portal gun mod includes two modes: deathmatch and cooperative variant.

- In cooperative, only one wormhole can be created. That's
  pretty useful in quake cooperative mode, when two players can create quick
  link between them - each player creates one portal gate near him. Default mode.

- In deathmatch, every portal gun can create one wormhole;
  so number of possible wormholes in game equals number of players.

!! NOTE: please make sure, that all portals are closed before changing mode to
avoid an unexpected behavior.

Why I made it
-------------
That's simple question. My computer is too slow for running the original Valve's
Portal game, but I love the YouTube videos and generally the gameplay of it. 
The first version of portal mod by Lag.Com was designed for making incredible 
fast speed demos (see <http://speeddemosarchive.com> - SDA; great site!).
My mod was made independently and each mod had pros and cons 
(thanks for Mark "Markzilla" Ehlke for summary). 

First version of this mod was v2.0 although there was no 1.0.
It is fusion of two independently made portal gun mods.

Appeal
------
Note, that the mod is still in development phase.
This is my very first quake mod, so I would like to ask anybody for helping me
with models, levels and other things from TODO section.

On the other hand, feel free to use this gun in your mod!
Just give me a credit :)

Commands
--------
impulse 99 - use Portal Gun
impulse 98 - close portals down
impulse 97 - toggle deathmatch/cooperative mode
impulse 96 - fire blue portal
impulse 95 - fire red portal
impulse 94 - use item carrier

Portal Gun mod should contain autoexec.cfg file, where he keybindings are set.
Controls defined in autoexec.cfg:

 [Q][W][E][R] ... [P]
  [A][S][D][F] 

P - use Portal Gun
R - close portals
Q - fire blue portal
E - fire red portal
F - use item carrier
'portal_mode' - toggle deathmatch/cooperative mode

