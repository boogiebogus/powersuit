const HDLD_SMGARM = "pw4";

class HDPowersuitSMGArm : HDPowersuitArm
{
	array<int> altmags;
	int altcurrentmag;
	int altmaxmags, altreloadtime, altmagsize;
	property altmaxmags : altmaxmags;
	property altreloadtime : altreloadtime;
	property altmagsize : altmagsize;
	bool fireshotgun;
	
	default
	{
		hdpowersuitarm.maxmags 5;
		hdpowersuitarm.magsize 30;
		hdpowersuitarm.magtype "hd9mmag30";
		hdpowersuitarm.ammotype "hd9mmag30";
		hdpowersuitarm.altammotype "hdshellammo";
		hdpowersuitarm.reloadtime 50;
		hdpowersuitarm.droppeditemname "hdpowersuitsmgarmpickup";
		
		hdpowersuitsmgarm.altmaxmags 39;
		hdpowersuitsmgarm.altreloadtime 16;
		hdpowersuitsmgarm.altmagsize 1;
		
		scale 0.7;
		
		tag '"Jackripper" hybrid machine gun';
	}
	
	override void postbeginplay()
	{
		fireshotgun = false;
		firemodestring = "9MIL";
		
		super.postbeginplay();
	}
	
	override void fillmags()
	{
		for (int i = 0; i < altmaxmags; i++)
		{
			altmags.push(altmagsize);
		}
		
		altcurrentmag = altmagsize;
		
		super.fillmags();
	}
	
	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		super.drawhudstuff(sb, hdw, hpl);
		
		if (isleft)
		{
			sb.drawrect(-40, -12, -4, -8);
			sb.drawrect(-41, -19, -2, -3);
			
			sb.drawrect(-40, -26, -4, -2);
			sb.drawrect(-40, -29, -4, -7);
			
			if (altmags.size() > 0 || altcurrentmag > 0)
			{
				sb.drawrect(-48, -32, float((altmags.size() + altcurrentmag) / float(altmaxmags + 1)) * -48, -4);
			}
			
			int altreserveshots;
			for (int i = 0; i < altmags.size(); i++)
			{
				altreserveshots += altmags[i];
			}
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(altreserveshots + altcurrentmag, 0)),
				(-50, -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_WHITE, scale: (0.5, 0.5));
		}
		else
		{
			sb.drawrect(40, -12, 4, -8);
			sb.drawrect(41, -19, 2, -3);
			
			sb.drawrect(40, -26, 4, -2);
			sb.drawrect(40, -29, 4, -7);
			
			if (altmags.size() > 0 || altcurrentmag > 0)
			{
				sb.drawrect(48, -32, float((altmags.size() + altcurrentmag) / float(altmaxmags + 1)) * 48, -4);
			}
			
			int altreserveshots;
			for (int i = 0; i < altmags.size(); i++)
			{
				altreserveshots += altmags[i];
			}
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(altreserveshots + altcurrentmag, 0)),
				(48, -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_WHITE, scale: (0.5, 0.5));
		}
	}
	
	override void changefiremode()
	{
		if (fireshotgun)
		{
			fireshotgun = false;
			firemodestring = "9MIL";
		}
		else
		{
			fireshotgun = true;
			firemodestring = "SHOT";
		}
	}
	
	override bool checkmags()
	{
		if (fireshotgun)
		{
			bool success = false;
			
			if (altcurrentmag > 0)
			{
				success = true;
			}
			else if (altcurrentmag <= 0)
			{
				if (altmags.size() > 0)
				{
					altcurrentmag = altmags[altmags.size() - 1];
					altmags.pop();
					
					success = true;
				}
				else
				{
					altcurrentmag = -1;
					
					success = false;
				}
			}
			
			return success;
		}
		else
		{
			return super.checkmags();
		}
	}
	
	override int getreloadtime(bool usealtammo, bool unloading)
	{
		if (usealtammo)
		{
			return altreloadtime;
		}
		else
		{
			return reloadtime;
		}
	}
	
	override bool checkload(bool usealtammo)
	{
		if (usealtammo)
		{
			if (altmags.size() < altmaxmags || altcurrentmag < 1)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return super.checkload(usealtammo);
		}
	}
	
	override void loadmagazine(int amount, bool usealtammo)
	{
		if (usealtammo)
		{
			if (altcurrentmag < 0)
			{
				altcurrentmag = amount;
			}
			else
			{
				altmags.push(amount);
			}
		}
		else
		{
			super.loadmagazine(amount, usealtammo);
		}
	}
	
	override bool checkunload(bool usealtammo)
	{
		if (usealtammo)
		{
			if (altmags.size() > 0 || altcurrentmag > 0)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return super.checkunload(usealtammo);
		}
	}
	
	override int handleunload(bool usealtammo)
	{
		if (usealtammo)
		{
			int toreturn;
			if (altcurrentmag > 0)
			{
				toreturn = altcurrentmag;
				altcurrentmag = -1;
				
				return toreturn;
			}
			else if (altmags.size() > 0)
			{
				toreturn = altmags[altmags.size() - 1];
				altmags.pop();
				
				return toreturn;
			}
			
			return -1;
		}
		else
		{
			return super.handleunload(usealtammo);
		}
	}
	
	override string getstatustext(playerpawn weaponowner)
	{
		int loadedshells = max(0, altcurrentmag);
		for (int i = 0; i < altmags.size(); i++)
		{
			loadedshells += altmags[i];
		}
		
		return super.getstatustext(weaponowner)..
			"\n\cjLoaded shells: \cd"..((loadedshells > 0) ? loadedshells.."/"..(altmaxmags + 1).." shells" : "\cgnone");
	}
	
	override void spawndroppedarm(out array<int> weaponstatus)
	{
		weaponstatus[0] = mags.size();
		weaponstatus[1] = 1;
		weaponstatus[2] = currentmag;
		
		for (int i = 0; i < mags.size(); i++)
		{
			weaponstatus[3 + i] = mags[i];
		}
		
		int reserveammo = 0;
		for (int i = 0; i < altmags.size(); i++)
		{
			reserveammo += altmags[i];
		}
		
		weaponstatus[3 + mags.size()] = altcurrentmag;
		weaponstatus[4 + mags.size()] = reserveammo;
	}
	
	override void handlemountammo(hdpowersuitarmpickup armitem, playerpawn owner, bool takeitem, bool allowspare)
	{
		let spares = spareweapons(owner.findinventory("spareweapons"));
		bool usespare = false;
		int sparenumber;
		
		if (spares)
		{
			for (int i = 0 ; i < spares.weapontype.size(); i++)
			{
				class<actor> type = spares.weapontype[i];
				if (type is "hdpowersuitsmgarmpickup")
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
			
			for (int i = 0; i < amountmags; i++)
			{
				loadmagazine(spares.getweaponvalue(sparenumber, 3 + i), false);
			}
			
			altcurrentmag = spares.getweaponvalue(sparenumber, 3 + amountmags); 
			for (int i = 0; i < spares.getweaponvalue(sparenumber, 4 + amountmags); i++)
			{	
				loadmagazine(1, true);
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
			
			for (int i = 0; i < amountmags; i++)
			{
				loadmagazine(armitem.weaponstatus[3 + i], false);
			}
		
			altcurrentmag = armitem.weaponstatus[3 + amountmags];
			for (int i = 0; i < armitem.weaponstatus[4 + amountmags]; i++)
			{
				loadmagazine(1, true);
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
			JKRP A 1
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
						if (fireshotgun)
						{
							setstatelabel("shootshotgun");
						}
						else
						{
							setstatelabel("shootsmg");
						}
					}
					else
					{
						isfiring = false;
					}
				}
			}
			loop;
			
		shootsmg:
			JKRP C 1
			{
				if (isleft)
				{
					frame = 2;
				}
				else
				{
					frame = 5;
				}
				
				if(suitcore.driver)hdbulletactor.firebullet(suitcore.driver, "HDB_9", zofs: 8, spread: 1, speedfactor: 1.2);
				else hdbulletactor.firebullet(self, "HDB_9", zofs: 8, spread: 1, speedfactor: 1.2);
				a_startsound("weapons/jackripper/smg", CHAN_WEAPON);
				if (suitcore.driver)
				{
					suitcore.driver.a_alertmonsters(200);
				}
				currentmag--;
				checkmags();
				
				a_spawnitemex("hdspent9mm", 0, 0, 4,
					-1, (isleft ? -15 : -1), 5,
					0, SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
				
				isfiring = false;
			}
			JKRP B 0
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
			
		shootshotgun:
			JKRP C 1
			{
				if (isleft)
				{
					frame = 2;
				}
				else
				{
					frame = 5;
				}
				
				double spread = 6.5 - 0.5 * 3;
				double speedfactor = 1.0 + 0.02857 * 3;

				if(suitcore.driver){
				hdbulletactor.firebullet(suitcore.driver, "HDB_wad", zofs: 8);
				hdbulletactor.firebullet(suitcore.driver, "HDB_00", zofs: 8, spread: spread, 
					speedfactor: speedfactor, amount: 10);
				}else{
				hdbulletactor.firebullet(self, "HDB_wad", zofs: 8);
				hdbulletactor.firebullet(self, "HDB_00", zofs: 8, spread: spread, 
					speedfactor: speedfactor, amount: 10);
				}
				a_startsound("weapons/jackripper/shotgun", CHAN_WEAPON);
				if (suitcore.driver)
				{
					suitcore.driver.a_alertmonsters();
				}
				altcurrentmag--;
				checkmags();
				
				a_spawnitemex("hdspentshell", 0, 0, 4,
					frandom(-2, 1), (isleft ? frandom(-5, -3) : frandom(3, 5)), frandom(3, 5), 0,
					SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
				
				isfiring = false;
			}
			JKRP B 3
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
			}
			JKRP B 0
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

class HDPowersuitSMGArmPickup : HDPowersuitArmPickup
{
	default
	{
		tag '"Jackripper" MG';
		inventory.pickupmessage 'Picked up a "Jackripper" hybrid machine gun.';
		inventory.icon "JKRPZ0";
		hdpowersuitarmpickup.armtype "hdpowersuitsmgarm";
		hdweapon.refid HDLD_SMGARM;
	}
	
	override double weaponbulk()
	{
		return 200;
	}
	
	states
	{
		spawn:
			JKRP Z -1;
			stop;
	}
}
