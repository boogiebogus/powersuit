const HDLD_LIBARM = "pw2";

class HDPowersuitLibArm : HDPowersuitArm
{
	bool automatic, canrefire;
	int spread;
	array<int> recasts;
	int currecasts;
	
	default
	{
		scale 0.7;
	
		hdpowersuitarm.maxmags 3;
		hdpowersuitarm.magsize 30;
		hdpowersuitarm.magtype "hd7mmag";
		hdpowersuitarm.ammotype "hd7mmag";
		hdpowersuitarm.reloadtime 50;
		hdpowersuitarm.droppeditemname "hdpowersuitlibarmpickup";
		
		tag "ZMG33 LMG";
	}
	
	override void postbeginplay()
	{
		automatic = false;
		canrefire = true;
		firemodestring = "SEMI";
		spread = 0;
		
		super.postbeginplay();
	}
	
	override void fillmags()
	{
		for (int i = 0; i < maxmags; i++)
		{
			mags.push(30);
			recasts.push(0);
		}
		
		currentmag = 30;
		currecasts = 0;
	}
	
	override void changefiremode()
	{
		if (automatic)
		{
			automatic = false;
			firemodestring = "SEMI";
		}
		else
		{
			automatic = true;
			firemodestring = "AUTO";
		}
	}
	
	override void loadmagazine(int amount, bool usealtammo)
	{
		int rounds = amount % 100;
		
		if (currentmag < 0)
		{
			currecasts = clamp(30 - (amount / 100), 0, rounds);
		}
		else
		{
			recasts.push(clamp(30 - (amount / 100), 0, rounds));
		}
		
		super.loadmagazine(rounds);
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
				currecasts = recasts[recasts.size() - 1];
				mags.pop();
				recasts.pop();
				
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
	
	override int handleunload(bool usealtammo)
	{
		if (currentmag > 0)
		{
			int amount = currentmag;
			amount += clamp(30 - currecasts, 0, currentmag) * 100;
			
			currentmag = -1;
			currecasts = -1;
			
			return amount;
		}
		else if (mags.size() > 0)
		{
			int amount = mags[mags.size() - 1];
			amount += clamp(30 - recasts[recasts.size() - 1], 0, mags[mags.size() - 1]) * 100;
			
			mags.pop();
			recasts.pop();
			
			return amount;
		}
		
		return -1;
	}
	
	override void spawndroppedarm(out array<int> weaponstatus)
	{
		class<actor> magtype = ammotype;
		
		int amount = currentmag;
		amount += clamp(30 - currecasts, 0, currentmag) * 100;
		
		weaponstatus[0] = mags.size();
		weaponstatus[2] = amount;
		
		for (int i = 0; i < mags.size(); i++)
		{
			amount = mags[i];
			amount += clamp(30 - recasts[i], 0, mags[i]) * 100;
			weaponstatus[3 + i] = amount;
		}
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
			int rounds = spares.getweaponvalue(sparenumber, 2) % 100;
			currentmag = rounds;
			currecasts = clamp(30 - (spares.getweaponvalue(sparenumber, 2) / 100), 0, rounds);

			
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
			int rounds = armitem.weaponstatus[2] % 100;
			currentmag = rounds;
			currecasts = clamp(30 - (armitem.weaponstatus[2] / 100), 0, rounds);
			
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
			
			if (takeitem)
			{
				owner.takeinventory(armitem.getclassname(), 1);
			}
		}
	}
	
	states
	{
		spawn:
			ZMG3 A 1
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
					if (checkmags() &&
						(automatic || canrefire))
					{
						setstatelabel("missile");
					}
					else
					{
						isfiring = false;
					}
				}
				else
				{
					canrefire = true;
				}
				
				if (spread > 0)
				{
					spread--;
				}
			}
			loop;
			
		missile:
			ZMG3 C 1
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
				
				if (hd7mmag.checkrecast(currentmag, currecasts))
				{
					hdbulletactor.firebullet(self, "HDB_776r", zofs: 8, spread: spread / 3);
					currecasts--;
				}
				else
				{
					hdbulletactor.firebullet(self, "HDB_776", zofs: 8, spread: spread / 3);
				}
				
				A_StartSound("weapons/zmg33/fire", CHAN_WEAPON, CHANF_OVERLAP);
				
				if (suitcore.driver)
				{
					suitcore.driver.a_alertmonsters();
				}
				
				bool spawned;
				actor brass;
				
				[spawned, brass] = a_spawnitemex("hdspent7mm", 0, 0, 8,
					frandom(-2, -3), (isleft ? frandom(-3, -5) : frandom(3, 5)), 3, 0,
					SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
				brass.vel += vel;
				brass.a_startsound(brass.bouncesound, volume: 0.4);

				currentmag--;
				
				if (spread < 16)
				{
					spread += 1;
				}
				
				isfiring = false;
			}
			ZMG3 B 1
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				if (!automatic)
				{
					canrefire = false;
					setstatelabel("spawn");
				}
			}
			ZMG3 B 0
			{
				if (checkmags() && automatic && isfiring)
				{
					setstatelabel("missile");
				}
			}
			goto spawn;
	}
}

class HDPowersuitLibArmPickup : HDPowersuitArmPickup
{
	default
	{
		scale 0.8;
		tag "ZMG33 LMG";
		inventory.pickupmessage "Picked up a ZMG33 mounted light machine gun.";
		inventory.icon "ZMG3Z0";
		hdpowersuitarmpickup.armtype "HDPowersuitLibArm";
		hdweapon.refid HDLD_LIBARM;
	}
	
	override double weaponbulk()
	{
		return 200;
	}
	
	states
	{
		spawn:
			ZMG3 Z -1;
			stop;
	}
}
