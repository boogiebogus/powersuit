# Weapon documentation

## Classes:

- `HDPowersuitArm`: your basic weapon framework, inherit from this
- `HDPowersuitArmPickup`: the pickup of a dismounted arm.
- `HDPowersuitBlankArm`: "weapon" that represents the lack of a weapon. gets special handling.

## Variables:

### HDPowersuitArm:

`armpoint`: the aimpoint actor for the arm.
- `armpoint.isarm`: whether this is rendered in suitlibeye.zs
- `armpoint.isleft`: whether this is for the left or right arm, changes the color
- `armpoint.accuracy`: the number of which player owns it

`isfiring`: the "controller" weapon sets this to true when you press fire/altfire

`suitcore`: pointer to the "main" part of the powersuit

`mags`: array of all of the mags

`maxmags`: the maximum amount of mags in reserve - so the loaded mag is a +1.

`magsize`: the size of a magazine, by default. should not go above 1 if the weapon does not
use magazines.

`magtype`: the actor class of the *EJECTED* magazine. leave blank to eject nothing.
note that the only thing that uses this is checkmags(), so you can fuck with that instead
if you need specific behavior.

`ammotype`: the actor class of the ammo that you load into the weapon. can be mags, or not mags.

`altammotype`: similar to ammotype, but loaded with altreload. leave blank to have no alt ammo.

`reloadtime`: the amount of time needed to reload each mag/round.

`currentmag`: bullets in the current mag.

`droppeditemname`: the pickup spawned when dismounting the weapon.

`isleft`: whether this is a left or right arm.

`firemodestring`: the string displaying on the hud for firemode. set to blank, to show nothing.

### Virtual functions:

- `fillmags()`: instantly fills up ammo. called whenever appropriate.

- `checkmags()`: various handling on ammo, should generally be called while in firing states.
returns true if there is a bullet that can be fired, otherwise false.

- `changefiremode()`: called from the powersuit controller. has no behavior by default, so
you will need to give it custom behavior if you want firemodes.

checkload(bool usealtammo = false): checks if the weapon can fit more ammo.
returns true if it can, false otherwise. usealtammo is not used by default.

- `loadmagazine(int amount, bool usealtammo = false)`: called when loading any sort of ammo, 
from the maintenance menu. amount is the amount of bullets in the mag.
usealtammo is for whether the player loaded alternate ammo, this is not used for
anything by default so you will have to override it to give that behavior.

- `checkunload(bool usealtammo = false)`: checks if the weapon can be unloaded.
returns true if it can, false otherwise. usealtammo is not used by default.

- `handleunload(bool usealtammo = false)`: called when unloading ammo from the maintenance menu.
returns the amount of ammo in the magazine as an int. usealtammo is not normally used.

- `getreloadtime(bool usealtammo = false, bool unloading = false)`: called when unloading or 
reloading ammo from the maintenace menu. returns the amount of time it takes, in tics. 
does not use usealtammo, or unloading by default.

- `spawndroppedarm(out array<int> weaponstatus)`: called when removing a weapon from the maintenance 
menu. the data stored in the array is moved to the weaponstatus array of the dropped item.
also called to move data between maps.[^1]

- `handlemountammo(hdpowersuitarmpickup armitem, playerpawn owner, bool takeitem = true,
	allowspare = true, string extra = "")`:[^1]
called when mounting an arm. this function handles moving ammo variables from the arm item 
to the mounted arm.
also called when spawning into a map.
takeitem controls whether an arm is taken from player inventory.
allowspare determines whether stuff from the spareweapons array may be used
extra is used to bring extra data between maps
however, i encourage you keep stuff in the weaponstatus of the pickup, if at all possible

[^1]:these two have some extra notes on how to properly override them

- `drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)`: 
called from the suit controller drawing UI stuff. pretty much the same as drawhudstuff, basically.

- `getextrastatustext()`:
called from the suit maintenance ui. does nothing by default.

- `getloadsound(bool unload, bool altammo)`:
returns the sound for reloading/unloading. unload is true if unloading, altammo is true if it is alt reloading/unloading

- `getextradata()`:
called ONLY when transitioning through levels, so that you can maybe carry
some extra data through if you *really* need it
