# UAC "Mongoose" Light Powersuit
> A mod for [Hideous Destructor](https://codeberg.org/mc776/HideousDestructor/) that adds a mini mech-suit.

## INFO

Contrary to the name, and to both the disappointment and glee of infantry, the Mongoose is not a suit
of power armor, but rather more like a pocket-sized mech. With a modular gun mount on each arm,
the Mongoose brings enough firepower to easily plow through all of the demons commonly encountered
by infantry units. Along with using the same armor plates found in battle armor, and using
systems that can be easily replaced, the Mongoose is incredibly versatile and easy to maintain.
However, it is still a mech, and as a result is not nearly as agile as being on-foot. Loadout code is `pst`.

## SPAWNING

The Mongoose has a chance to replace megaspheres. They will spawn a beacon along with two weapons.
- One of them is always a 4mm LMG, but the other one is random. Activate the beacon in your
inventory in order to teleport in a Mongoose.

## IMPORTANT CONTROLS

Press `Use` on the powersuit to get in.
Press `Crouch` + `Use` while inside the powersuit to get out.
Press `Crouch` + `Use` on the powersuit, while outside, to open up the maintenance menu.
Press `Use Item` on a powersuit weapon to be able to reload/unload it without attaching 
it to the powersuit.

Holding use will bring up controls for everything else. This applies for both the control
interface and the maintenance screen. Note that on the maintenance screen, the controls will
change depending on context, so make sure to check the controls on every option!

## MECHANICS

The powersuit uses tank controls - left and right will turn the legs left and right, rather than
strafing. The torso can rotate independently, however--basically, it's like mechwarrior.

Left click will fire the left arm, while right click will fire the right arm. The places they're
aiming is represented by the cyan reticle and purple reticle, respectively. They'll try to
converge on where you're looking. There's no way to tell whether reticle is in front of or behind
of an object, so be aware of that.

When struck by fire, such as from an imp, the powersuit will gain heat. If it gets hot enough, 
you'll start taking damage. While not inside the powersuit, you can tell if it's still beyond 
this threshold if it is smoking. The powersuit, unfortunately, does not protect very well against 
mancubus/combat slug flamethrowers.

The powersuit has a battery life of 30 minutes, with 15 minutes for each battery. The shields
only have a battery life of 10 minutes while idle, and drain significantly faster when recharging.

Should there be a place you simply can't get the powersuit through, you can disassemble the suit
and transport each of the parts to the destination. In order to place the suit, simply use the
torso inventory item. Note that the limbs can only be dropped from the item manager (press
the mag manager button twice in a row).

## WEAPONS

### Leondias
GZDoom actor name: `HDPowersuitVulcArmPickup`

GZDoom ammo actor names: `HD4mmMag`

Loadout code: `pw0`

The standard weapon for the PST-2947b "Mongoose", the Leondias light machine gun uses 4.26mm magazines for general use in combat and especially in stormtrooper operations.

They were commonly used as they were mass-manufactured by the UAC for the need for a mounted machine gun using the infamous 4.26mm UAC Standard rounds due to how common it was. Much like its smaller cousin, the Vulcanette, it doesn't have the full implementation of the notirious Volt's End User License Agreement. Therefore the reader is still reminded that it is illegal to load 4.26mm UAC Standard rounds into another weapon.

Instructions: Same instructions as the Vulcanette, sans the need for batteries unless noted otherwise.

Protip: There is no durability for the gun, so it will never break so keep on pushing the fight to them. Unless you ran out of ammo. That's gonna be a problem.


### Calinicus
GZDoom actor name: `HDPowersuitRocketArmPickup`

GZDoom ammo actor names: `HDRocketAmmo`

Loadout code: `pw1`

In a similar case of the Leonidas weapons platform, the Callinicus is a heavy platform designed for UAAF personnel carriers to fend off heavier targets. A drum fed Automatic Grenade Launcher, 12 rounds within the drum hand fed to the drum by infantry forces or other attached machinery. It utilizes the Heckler & Mok's Hybrid 40mm Rocket Grenades in either rocket mode or grenade mode.

These rounds pack both functions of RPG and Fragmentation in a deadly and neat digital precise package. It cannot load High Explosive Anti Tank rounds. The rockets can reach out to 1,400 meters and it is capable of Airbursting features. Rapid fire with this platform is often common in combination of short range arched fire. Developed in unison with the Leonidas machine gun.

Instructions: Same instructions as the rocket launcher.


### ZMG33 "Ares" Machine Gun
GZDoom actor name: `HDPowersuitLibArmPickup`

GZDoom ammo actor names: `HD7mMag`

Loadout code: `pw2`

A direct response to the UAAF's development to the Callinicus and Leonidas when soldiers began attaching Liberators to the mech. The weapon is an ancient platform that predates the Liberator was brought out of the inventory of a museum by soldiers using the Mongoose and redesigned to mount four thirty round magazines of 7.76mm full-power rounds. Perhaps the most expensive weapon on the platform due to the extensive abuse of 7mm when the weapon is used. It has a fire toggle between semi-auto and full auto at 1,200rpm. The 7.76mm rounds are well known to crush through shielding systems.

Instructions: Treat it as the 7mm Vulcanette but not *the* Vulcanette found from Masterminds.

Protip: You might wanna be mindful on who you'll shoot with as your trigger might tell you to waste ammo on said target.


### Athena Light Assault Cannon
GZDoom actor name: `HDPowersuitBrontoArmPickup`

GZDoom ammo actor names: `BrontornisRound`

Loadout code: `pw3`

Utilizing heavy, non-self-propelled 35mm hi-ex anti-materiel/incendiary rounds that can punch through most hard targets while remaining highly effective at decisively neutralizing soft targets, the light assault cannon was developed after a few weeks the Freeley Intellectual Properties Group, who invented the Brontornis cannon, was contracted by the UAAF when the Callinicus was not operating at full efficiency, such as when units began discovering the Tyrant utilizing the Mongoose model on extremely rare occasions or often tanks in cramped city spaces. It has a six round tube for the 35mm rounds, sporting a unique look from all of the other weapon platforms. It only fires at semi-automatic.

Protip: Guts. Huge, guts. Kill them. Must, kill them all.


### Jackripper
GZDoom actor name: `HDPowersuitSMGArmPickup`

GZDoom ammo actor names: `HD9mmMag30`, `HDShellAmmo`

Loadout code: `pw4`

The answer by Credible, a small civilian lawfirm company that became an armed private military when the invasions began. When they got hold of one of the Mongoose powersuit units stolen from the UAAF, they have developed and sent in a single weapon platform utilizing the 9×22mm Parumpudicum and 12 gauge rounds respectively.

The purpose was to use weaponry often picked up by the Tyrant forces and a common sidearm by all modern military forces that have become notorious for destroying shields at greater foes. The combination has proved effective and began immediate production within the month, thus leading to the birth of the Jackripper hybrid machine gun. Two weapon systems in one. The shotgun carries a 40-shell drum which brings extreme need for high maintenance at its 640rpm. The 9mm carbine fires at 1200rpm only, using 6 thirty round magazines.

Protip: The Jackripper can perform extremely well against low to mid-tier demons.
