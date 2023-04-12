const HDLD_ROCKETARM = "pw1";

class HDPowersuitRocketArm : HDPowersuitArm
{
	bool firerockets;
	
	default
	{
		scale 0.7;
		
		hdpowersuitarm.maxmags 11;
		hdpowersuitarm.magsize 1;
		hdpowersuitarm.ammotype "hdrocketammo";
		hdpowersuitarm.reloadtime 30;
		hdpowersuitarm.droppeditemname "hdpowersuitrocketarmpickup";
		
		tag '"Calinicus" AGL';
	}
	
	override void postbeginplay()
	{
		firerockets = false;
		firemodestring = "GREN";
		
		super.postbeginplay();
	}
	
	override void changefiremode()
	{
		if (firerockets)
		{
			firerockets = false;
			firemodestring = "GREN";
		}
		else
		{
			firerockets = true;
			firemodestring = "ROCK";
		}
	}
	
	states
	{
		spawn:
			CLNC A 1
			{
				if (isleft)
				{
					frame = 0;
				}
				else
				{
					frame = 3;
				}
				
				if (isfiring)
				{
					if (checkmags())
					{
						setstatelabel("missile");
					}
					else
					{
						isfiring = false;
					}
				}
			}
			loop;
			
		missile:
			CLNC C 2
			{
				if (isleft)
				{
					frame = 2;
				}
				else
				{
					frame = 5;
				}
				
				if (firerockets)
				{
					a_startsound("weapons/calinicus/ignite", CHAN_WEAPON, CHANF_OVERLAP);
					a_startsound("weapons/calinicus/boom", CHAN_WEAPON, CHANF_OVERLAP);

					let firedrocket = rocketgrenade(spawn("rocketgrenade", pos));
					firedrocket.angle = angle;
					firedrocket.pitch = pitch;
					firedrocket.target = self;
					firedrocket.master = self;
					
					firedrocket.primed = false;
					firedrocket.isrocket = true;

				}
				else
				{
					a_startsound("weapons/calinicus/grenade", CHAN_WEAPON, CHANF_OVERLAP);
				
					let firedgrenade = rocketgrenade(spawn("rocketgrenade", pos + (cos(angle) * 4, sin(angle) * 4, 8)));
					firedgrenade.angle = angle;
					firedgrenade.pitch = pitch;
					firedgrenade.target = self;
					firedgrenade.master = self;
					firedgrenade.primed = false;
				}
				
				if (suitcore.driver)
				{
					suitcore.driver.a_alertmonsters();
				}
				
				currentmag--;
				isfiring = false;
				checkmags();
			}
			CLNC B 0
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				if (firerockets)
				{
					a_settics(16);
				}
				else
				{
					a_settics(12);
				}
			}
			CLNC B 0
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				isfiring = false;
			}
			goto spawn;
	}
}

class HDPowersuitRocketArmPickup : hdpowersuitarmpickup
{
	default
	{
		tag '"Calinicus" AGL';
		inventory.pickupmessage 'Picked up a "Calinicus" automatic grenade launcher.';
		inventory.icon "CLNCZ0";
		hdpowersuitarmpickup.armtype "hdpowersuitrocketarm";
		hdweapon.refid HDLD_ROCKETARM;
	}
	
	override double weaponbulk()
	{
		return 200;
	}
	
	states
	{
		spawn:
			CLNC Z -1;
			stop;
	}
}
