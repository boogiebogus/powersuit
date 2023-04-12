const HDLD_VULCARM = "pw0";

class HDPowersuitVulcArm : HDPowersuitArm
{
	bool fullerauto;
	array<bool> magissealed;
	bool curmagsealed;
	int spread;
	
	default
	{
		scale 0.7;
		
		hdpowersuitarm.maxmags 7;
		hdpowersuitarm.magsize 50;
		hdpowersuitarm.magtype "hd4mmag";
		hdpowersuitarm.ammotype "hd4mmag";
		hdpowersuitarm.reloadtime 50;
		hdpowersuitarm.droppeditemname "hdpowersuitvulcarmpickup";
		
		tag '"Leonidas" LMG';
	}
	
	override void postbeginplay()
	{
		fullerauto = false;
		firemodestring = "NORM";
		spread = 0;
		
		super.postbeginplay();
	}
	
	override void changefiremode()
	{
		if (fullerauto)
		{
			fullerauto = false;
			firemodestring = "NORM";
		}
		else
		{
			fullerauto = true;
			firemodestring = "SUPR";
		}
	}
	
	override void loadmagazine(int amount, bool usealtammo)
	{		
		if (amount > 50)
		{
			amount = 50;
			
			if (currentmag < 0)
			{
				curmagsealed = true;
			}
			else
			{
				magissealed.push(true);
			}
		}
		else
		{
			if (currentmag < 0)
			{
				curmagsealed = false;
			}
			else
			{
				magissealed.push(false);
			}
		}
		
		super.loadmagazine(amount);
	}
	
	override int handleunload(bool usealtammo)
	{
		int toreturn;
		
		if (currentmag > 0)
		{
			if (curmagsealed && currentmag == 50)
			{
				toreturn = 51;
			}
			else
			{
				toreturn = currentmag;
			}
			
			curmagsealed = false;
			currentmag = -1;
			
			return toreturn;
		}
		else if (mags.size() > 0)
		{
			toreturn = mags[mags.size() - 1];
			if (magissealed[mags.size() - 1] && toreturn == 50)
			{
				toreturn = 51;
			}
			
			magissealed.pop();
			mags.pop();
			
			return toreturn;
		}
		
		return -1;
	}
	
	override void fillmags()
	{
		for (int i = 0; i < maxmags; i++)
		{
			loadmagazine(magsize + 1);
		}
		
		currentmag = -1;
		loadmagazine(magsize + 1);
		curmagsealed = true;
	}
	
	override void spawndroppedarm(out array<int> weaponstatus)
	{
		weaponstatus[0] = mags.size();
		if (currentmag == 50 && curmagsealed)
		{
			weaponstatus[2] = 51;
		}
		else
		{
			weaponstatus[2] = currentmag;
		}
		
		for (int i = 0; i < mags.size(); i++)
		{
			if (mags[i] == 50 && magissealed[i])
			{
				weaponstatus[3 + i] = 51;
			}
			else
			{
				weaponstatus[3 + i] = mags[i];
			}
		}
		
		if (curmagsealed)
		{
			weaponstatus[1] = 1;
		}
		else
		{
			weaponstatus[1] = 0;
		}
	}
	
	override bool checkmags()
	{
		bool success = false;
		
		if (currentmag > 0)
		{
			success = true;
		}
		else if (currentmag <= 0)
		{
			if (currentmag == 0 && magtype != "")
			{
				actor mag = hdmagammo.spawnmag(self, magtype, 0);
				mag.a_changevelocity(frandom(-4, -3), frandom(4, 2) * (isleft ? 1 : -1), 
					frandom(5, 7), CVF_RELATIVE);
			}
			
			if (mags.size() > 0)
			{
				currentmag = mags[mags.size() - 1];
				curmagsealed = magissealed[mags.size() - 1];
				mags.pop();
				magissealed.pop(); 
				
				success = true;
			}
			else
			{
				currentmag = -1;
				
				success = false;
			}
		}
		
		return success;
	}
	
	override void handlemountammo(hdpowersuitarmpickup armitem, playerpawn owner, 
		bool takeitem, bool allowspare, string extra)
	{
		let spares = spareweapons(owner.findinventory("spareweapons"));
		bool usespare = false;
		int sparenumber;
		
		class<actor> magtype = ammotype;
		bool ismagammo = (magtype is "hdmagammo");
		
		if (spares)
		{
			for (int i = 0 ; i < spares.weapontype.size(); i++)
			{
				class<actor> type = spares.weapontype[i];
				if (type is droppeditemname)
				{
					usespare = true;
					sparenumber = i;
					
					break;
				}
			}
		}
		
		if (!allowspare)
		{
			usespare = false;
		}
		
		if (usespare)
		{
			int amountmags = spares.getweaponvalue(sparenumber, 0);
			currentmag = spares.getweaponvalue(sparenumber, 2);
			
			if (ismagammo)
			{
				for (int i = 0; i < amountmags; i++)
				{
					loadmagazine(spares.getweaponvalue(sparenumber, 3 + i), false);
				}
			}
			else
			{
				for (int i = 0; i < spares.getweaponvalue(sparenumber, 3); i++)
				{	
					loadmagazine(1, false);
				}
			}
			
			if (spares.getweaponvalue(sparenumber, 1) == 1)
			{
				curmagsealed = true;
			}
			else
			{
				curmagsealed = false;
			}
			
			if (takeitem)
			{
				spares.weaponbulk.delete(sparenumber);
				spares.weapontype.delete(sparenumber);
				spares.weaponstatus.delete(sparenumber);
			}
		}
		else
		{
			int amountmags = armitem.weaponstatus[0];
			currentmag = armitem.weaponstatus[2];
			
			if (ismagammo)
			{
				for (int i = 0; i < amountmags; i++)
				{
					loadmagazine(armitem.weaponstatus[3 + i], false);
				}
			}
			else
			{
				for (int i = 0; i < armitem.weaponstatus[3]; i++)
				{
					loadmagazine(1, false);
				}
			}
			
			if (armitem.weaponstatus[1] == 1)
			{
				curmagsealed = true;
			}
			else
			{
				curmagsealed = false;
			}
			
			if (takeitem)
			{
				owner.takeinventory(armitem.getclassname(), 1);
			}
		}
	}
	
	states
	{
		spawn:
			LEON A 1
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
				
				if (spread > 0)
				{
					spread--;
				}
			}
			loop;
			
		missile:
			LEON C 1
			{
				if (isleft)
				{
					frame = 2;
				}
				else
				{
					frame = 5;
				}
				
				//the 3 is INTENTIONALLY an integer
				if (curmagsealed || random(0, (fullerauto ? 3 : 7)))
				{
					hdbulletactor.firebullet(self, "HDB_426", zofs: 8, spread: (spread / 3));
					a_startsound("weapons/leonidas/fire", CHAN_WEAPON, CHANF_OVERLAP);
					if (suitcore.driver)
					{
						suitcore.driver.a_alertmonsters();
					}
					currentmag--;
					
					if (spread < (fullerauto ? 9 : 6))
					{
						spread += 2;
					}
				}
				else
				{
					a_startsound("weapons/rifleclick", CHAN_WEAPON, CHANF_OVERLAP);
				}
				
				isfiring = false;
			}
			LEON B 2
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				if (checkmags() && fullerauto && isfiring)
				{
					setstatelabel("missile");
				}
			}
			goto spawn;
	}
}

class HDPowersuitVulcArmPickup : hdpowersuitarmpickup
{
	default
	{
		tag '"Leonidas" LMG';
		inventory.pickupmessage 'Picked up a "Leonidas" mounted light machine gun.';
		inventory.icon "LEONZ0";
		hdpowersuitarmpickup.armtype "hdpowersuitvulcarm";
		hdweapon.refid HDLD_VULCARM;
	}
	
	override double weaponbulk()
	{
		return 200;
	}
	
	states
	{
		spawn:
			LEON Z -1;
			stop;
	}
}
