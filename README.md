Quake Portal Gun
================

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
on the other side of wormhole. This allows you to do big jumps and other tricks.

Teleporting of pickups is possible, which allows interesting strategies (like
gathering pickups on one place and the pick them all up at once; or reaching
distant items just by shooting at them.)

Portal Gun can also be used as item carrier. Simply aim the item and 
press 'f'. To drop carried item, press 'f' again.

```
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
```

Portal gun modes
----------------
Portal gun mod includes two modes: deathmatch and cooperative variant.

- In cooperative, only one wormhole can be created. That's
  pretty useful in quake cooperative mode, when two players can create quick
  link between them - each player creates one portal gate near him. Default mode.

- In deathmatch, every portal gun can create one wormhole;
  so number of possible wormholes in game equals number of players.


Compiling and usage
--------------------
Use any QuakeC compiler. 
The fteqcc (https://github.com/xonotic/fteqcc) is even in debian repositories.

After that, you can run the mod with

`
$ quake -game quake-portal-gun
`

For demonstration, toggle console and type 'playdemo portal'.

Maps can be compiled by Quake Utils.
(https://github.com/id-Software/Quake-Tools/tree/master/qutils)

They use portal.wad, which is included, and base.wad from original game data.


Commands
--------
* impulse 99 - use Portal Gun
* impulse 98 - close portals down
* impulse 97 - toggle deathmatch/cooperative mode
* impulse 96 - fire blue portal
* impulse 95 - fire red portal
* impulse 94 - use item carrier

Portal Gun mod should contain autoexec.cfg file, where he keybindings are set.
Controls defined in autoexec.cfg:

X - use Portal Gun

ALT - close portals

Z - fire blue portal

C - fire red portal

G - use item carrier

'portal_mode' - toggle deathmatch/cooperative mode

