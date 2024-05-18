#include "zscript/weapons/blankarm.zs"
#include "zscript/weapons/leonidaslmg.zs"
#include "zscript/weapons/calinicusagl.zs"
#include "zscript/weapons/jackripper.zs"
#include "zscript/weapons/zmg33.zs"
#include "zscript/weapons/athena.zs"

//weapons that use loose ammo only support a magazine size of 1
//increase capacity by increasing maxmags
//though, you could use something different if you wanted, of course...

class HDPowersuitArm : hdactor
{
	hdpowersuitaimpoint armpoint;
	bool isfiring;
	hdpowersuit suitcore;
	array<int> mags;
	int maxmags, magsize;
	property maxmags : maxmags; //doesn't include the loaded mag
	property magsize : magsize;
	string magtype, ammotype, altammotype; //magtype covers ejected mags only
	property magtype : magtype;
	property ammotype : ammotype;
	property altammotype : altammotype;
	int reloadtime;
	property reloadtime : reloadtime;
	int currentmag;
	string droppeditemname;
	property droppeditemname : droppeditemname;
	bool isleft;
	string firemodestring;
	
	default
	{
		+nointeraction
		species "hdpowersuit";
		hdpowersuitarm.magtype "";
		hdpowersuitarm.altammotype "";
		obituary "%o fell for war crimes."; //gross hack
	}
	
	override string getobituary(actor victim,actor inflictor,name mod,bool playerattack){
		String msg;
		if(master){
			msg="%o fell for "..master.gettag().."'s war crimes.";
			if (!hdlivescounter.livesmode() && !hd_flagpole){
				/*if(teamplay){
					let masterteam = players[friendplayer - 1].getteam();
					for(int i = 0; i  < MAXPLAYERS; i++){
					if((players[i].getteam()) == masterteam)players[i].fragcount++;
					if(((players[i].fragcount) >= fraglimit) && (fraglimit > 0)){
						console.printf("Fraglimit hit.");
						Level.ExitLevel(0, false);
					}
				}
			}else{*/
				players[friendplayer - 1].fragcount++;
				if(((players[friendplayer - 1].fragcount) >= fraglimit) && (fraglimit > 0)){
					console.printf("Fraglimit hit.");
					Level.ExitLevel(0, false);
					}
				//}
			}
		}
		if(msg)return msg;
		return "%o fell for war crimes.";
	}
	
	virtual void fillmags()
	{
		for (int i = 0; i < maxmags; i++)
		{
			mags.push(magsize);
		}
		
		currentmag = magsize;
	}
	
	virtual bool checkmags()
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
				mags.pop();
				
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
	
	virtual void changefiremode()
	{
		return;
	}
	
	virtual bool checkload(bool usealtammo = false)
	{
		if (mags.size() < maxmags || currentmag < 1)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	virtual void loadmagazine(int amount, bool usealtammo = false)
	{
		if (currentmag < 0)
		{
			currentmag = amount;
		}
		else
		{
			mags.push(amount);
		}
	}
	
	virtual bool checkunload(bool usealtammo = false)
	{
		if (mags.size() > 0 || currentmag > 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	virtual int handleunload(bool usealtammo = false)
	{
		int toreturn;
		if (currentmag > 0)
		{
			toreturn = currentmag;
			currentmag = -1;
			
			return toreturn;
		}
		else if (mags.size() > 0)
		{
			toreturn = mags[mags.size() - 1];
			mags.pop();
			
			return toreturn;
		}
		
		return -1;
	}
	
	virtual int getreloadtime(bool usealtammo = false, bool unloading = false)
	{
		return reloadtime;
	}
	
	virtual void spawndroppedarm(out array<int> weaponstatus)
	{
		/*standard weaponstatus ammo storage:
		[0] is the amount of primary mags
		this should be 1 if this doesn't feed off mags
		and then the mag provided should be one bigass "mag" of all the rounds loaded
		(this doesn't matter actually lol)
		
		[1] is the amount of secondary mags
		this should be -1 if there's no secondary ammo for the weapon
		otherwise the same as primary mags
		this doesn't actually get used by default so you should implement it yourself
		but default behavior does leave space for it!
		
		[2 to x] is the actual magazines
		the first one in the actual magazines represents the currently loaded mag
		so if we had a gun with 4 primary mags and 3 alt mags
		[2] would be primary currentmag, [3 - 5] would be the mags array
		[6] would be alt currentmag, [7 - 8] would be the alt mags array
		
		obviously this can be changed
		keep in mind weaponstatus only supports 32 ints so if you have more than that
		you better figure out something different
		
		however, anything not in weaponstatus will NOT properly be copied
		through map transitions.*/
		
		if (droppeditemname != "")
		{
			//this happens in suiteditor now
			//hdpowersuitarmpickup droppedarm = hdpowersuitarmpickup(spawn(droppeditemname, pos));
			
			class<actor> magtype = ammotype;
			bool ismagammo = (magtype is "hdmagammo");
			
			weaponstatus[0] = ismagammo ? mags.size() : 1;
			weaponstatus[2] = currentmag;
			
			if (ismagammo)
			{
				for (int i = 0; i < mags.size(); i++)
				{
					weaponstatus[3 + i] = mags[i];
				}
			}
			else
			{
				int reserveammo = 0;
				for (int i = 0; i < mags.size(); i++)
				{
					reserveammo += mags[i];
				}
				
				weaponstatus[3] = reserveammo;
			}
		}
	}
	
	virtual void handlemountammo(hdpowersuitarmpickup armitem, playerpawn owner, 
		bool takeitem = true, bool allowspare = true, string extra = "")
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
			
			if (takeitem)
			{
				owner.takeinventory(armitem.getclassname(), 1);
			}
		}
	}
	
	virtual ui void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		//too lazy to do this the "right" way
		int reserveshots = 0;
		
		if (isleft)
		{
			if (currentmag > 0)
			{
				sb.drawrect(-48, -12, float(currentmag / float(magsize)) * -48, -4);
			}
			
			for (int i = 0; i < mags.size(); i++)
			{
				sb.drawrect(-48 + (i * -3), -18, -2, -4);
				
				reserveshots += mags[i];
			}
		
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(currentmag, 0)),
				(-50, -12), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_WHITE, scale: (0.5, 0.5));
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", reserveshots),
				(-54 - (string.format("%i", currentmag).length() * 4), -12), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_RED, scale: (0.5, 0.5));
				
			sb.drawstring(sb.pnewsmallfont, firemodestring,
				(-58 - ((string.format("%i", currentmag).length() + string.format("%i", reserveshots).length()) * 4), -12), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_GRAY, scale: (0.5, 0.5));
		}
		else
		{
			if (currentmag > 0)
			{
				sb.drawrect(48, -12, float(currentmag / float(magsize)) * 48, -4);
			}
				
			for (int i = 0; i < mags.size(); i++)
			{
				sb.drawrect(48 + (i * 3), -18, 2, -4);
				reserveshots += mags[i];
			}
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(currentmag, 0)),
				(48, -12), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_WHITE, scale: (0.5, 0.5));
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", reserveshots),
				(52 + (string.format("%i", currentmag).length() * 4), -12), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_RED, scale: (0.5, 0.5));
				
			sb.drawstring(sb.pnewsmallfont, firemodestring,
				(56 + ((string.format("%i", currentmag).length() + string.format("%i", reserveshots).length()) * 4), -12), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_GRAY, scale: (0.5, 0.5));
		}
	}
	
	virtual string getstatustext(playerpawn weaponowner)
	{
		if (!weaponowner)
		{
			return "";
		}
		
		class<actor> magtype = ammotype;
		bool ismagazine = (magtype is "hdmagammo");
				
		int realcurrentmag = -69420;
		int totalrounds = 0;
		string statusmessage;
		
		if (ismagazine)
		{
			realcurrentmag = hdmagammo(getdefaultbytype(magtype)).getmaghudcount(currentmag);
			
			for (int i = 0; i < mags.size(); i++)
			{
				totalrounds += hdmagammo(getdefaultbytype(magtype)).getmaghudcount(mags[i]);
			}
			
			if (realcurrentmag >= 0)
			{
				totalrounds += realcurrentmag;
			}
		}
		else
		{
			totalrounds = mags.size();
			if (currentmag > 0)
			{
				totalrounds += currentmag;
			}
		}
		
		string magstring = getdefaultbytype(magtype).gettag();
		
		statusmessage = "\cjWeapon: \cd"..gettag()..(ismagazine ? ( //if it's a mag
			"\n\cjLoaded magazines: \cd"..mags.size() + ((realcurrentmag > 0) ? 1 : 0).."/"..(maxmags + 1)..
			"\n\cjCurrent magazine: \cd"..((realcurrentmag > 0) ? (realcurrentmag.." rounds") : "\cgnone")) : "").. //end of if it's a mag
			"\n\cjTotal rounds: \cd"..((totalrounds > 0) ? totalrounds.."/"..(ismagazine ? ((maxmags + 1) * magsize) : (maxmags + 1)).." rounds" : "\cgnone")..
			"\n\cf"..magstring..((magstring.mid(magstring.length() - 1, 1) == 's') ? " " : "s ")..
			"\cjin inventory: \cd";
				
		if (weaponowner.findinventory(ammotype))
		{
			statusmessage = statusmessage..weaponowner.findinventory(ammotype).amount;
		}
		else
		{
			statusmessage = statusmessage.."\cgnone";
		}
		
		if(altammotype != "")
		{
			class<actor> altmagtype = altammotype;
			string altmagstring = getdefaultbytype(altmagtype).gettag();
			
			statusmessage = statusmessage.."\n\cf"..altmagstring..
			((altmagstring.mid(altmagstring.length() - 1, 1) == 's') ? " " : "s ")..
			"\cjin inventory: \cd";
			
			if (weaponowner.findinventory(altammotype))
			{
				statusmessage = statusmessage..weaponowner.findinventory(altammotype).amount;
			}
			else
			{
				statusmessage = statusmessage.."\cgnone";
			}
		}
		
		return statusmessage;
	}
	
	virtual string getloadsound(bool unload, bool altammo)
	{
		if (unload)
		{
			return "weapons/rifleunload";
		}
		else
		{
			return "weapons/rifleload";
		}
	}
	
	virtual string getextradata()
	{
		return "";
	}
	
	override void tick()
	{				
		if (suitcore)
		{
			warp(suitcore, 12, (isleft ? -24 : 24), suitcore.haslegs ? 28 : 8, angle,  
					WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION | WARPF_ABSOLUTEANGLE);			
			angle = suitcore.torso.angle;
			master = suitcore.master;
			friendplayer = suitcore.friendplayer;
			
			if (armpoint && suitcore.driver)
			{			
				if (suitcore.checkusable())
				{		
					if (pitch - suitcore.driver.pitch > 0)
					{
						if (abs(pitch - suitcore.driver.pitch) < suitcore.armrotationspeed)
						{
							pitch -= abs(pitch - suitcore.driver.pitch);
						}
						else
						{
							pitch -= suitcore.armrotationspeed;
						}
					}
					else if (pitch - suitcore.driver.pitch < 0)
					{
						if (abs(pitch - suitcore.driver.pitch) < suitcore.armrotationspeed)
						{
							pitch += abs(pitch - suitcore.driver.pitch);
						}
						else
						{
							pitch += suitcore.armrotationspeed;
						}
					}
				
					a_facetarget(1, 1);
					
					flinetracedata tracedata;
					linetrace(angle, 65535, pitch, TRF_THRUSPECIES, 8, 0, 0, tracedata);
					armpoint.setorigin(tracedata.hitlocation, true);
					armpoint.isarm = true;
				}
				else
				{
					armpoint.isarm = false; //turn off if there's no battery
				}
			}
		}
		
		super.tick();
	}
	
	override void ondestroy()
	{
		if (armpoint)
		{
			armpoint.destroy();
		}
		
		super.ondestroy();
	}
}

class HDPowersuitArmPickup : HDWeapon
{	
	string armtype;
	property armtype : armtype;
	
	string statusmessage, actionmessage;
	int actionprogress, actiontime;
	
	default
	{
		inventory.icon "TROOA1";
		+inventory.invbar;
		-hdweapon.fitsinbackpack;
	}
	
	override void beginplay()
	{
		weaponstatus[2] = -1;
	}
	
	override void attachtoowner(actor other)
	{
		stateprovider.attachtoowner(other);
	}
	
	override bool addspareweapon(actor newowner)
	{
		return addspareweaponregular(newowner);
	}
	
	override hdweapon getspareweapon(actor newowner, bool reverse, bool doselect)
	{
		return getspareweaponregular(newowner, reverse, doselect);
	}
	
	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		sb.drawimage(texman.getname(icon), (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER, scale: (2.0, 2.0));
		
		sb.drawstring(sb.psmallfont, "\cc=== \cqWeapon Manager \cc===\n",
			(0, -96), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
			
		sb.drawstring(sb.psmallfont, statusmessage,
			(8, -64), sb.DI_SCREEN_VCENTER | sb.DI_SCREEN_LEFT | sb.DI_TEXT_ALIGN_LEFT, wrapwidth: 232,
				scale:(0.7, 0.7));
		
		if (actiontime > 0)
		{
			int progress = int((actionprogress / float(actiontime)) * 11);
			string lmao = "=";
			
			for (int i = 0; i < progress; i++)
			{
				lmao = lmao.."=";
			}
			
			sb.drawstring(sb.psmallfont, lmao..actionmessage..lmao, (0, 64),
				sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER, Font.CR_GRAY);
		}
	}
	
	override string gethelptext()
	{
		class<actor> currentarm = armtype;
		
		return WEPHELP_RELOAD.."  Reload weapon\n"..
			(hdpowersuitarm(getdefaultbytype(currentarm)).altammotype != "" ? WEPHELP_ALTRELOAD.."  Alt. reload weapon\n" : "")..
			WEPHELP_UNLOAD.."  Unload weapon\n"..
			(hdpowersuitarm(getdefaultbytype(currentarm)).altammotype != "" ? WEPHELP_ALTRELOAD.." + "..WEPHELP_UNLOAD.."  Alt. unload weapon\n" : "");
	}
	
	bool justpressed(int which)
	{
		int btn = owner.player.cmd.buttons;
		int oldbtn = owner.player.oldbuttons;
		return btn & which && !(oldbtn & which);
		
		return false;
	}
	
	override void loadoutconfigure(string input)
	{
		initializewepstats(true);
		
		super.loadoutconfigure(input);
	}
	
	override void initializewepstats(bool idfa)
	{
		hdpowersuitarm currentarm = hdpowersuitarm(spawn(armtype, pos));
		currentarm.fillmags();
		
		array<int> weaponstatusb;
		weaponstatusb.resize(HDWEP_STATUSSLOTS);
		currentarm.spawndroppedarm(weaponstatusb);
		
		for (int i = 0; i < HDWEP_STATUSSLOTS; i++)
		{
			weaponstatus[i] = weaponstatusb[i];
		}
		
		currentarm.destroy();
	}
	
	states
	{
		ready:
			TNT1 A 1 
			{
				a_weaponready(WRF_NOFIRE | WRF_ALLOWUSER3);
				
				//================================
				//STATUS MESSAGE
				//================================
				
				hdpowersuitarm currentarm = hdpowersuitarm(spawn(invoker.armtype, pos));
				currentarm.handlemountammo(invoker, playerpawn(self), false, false);
					
				class<actor> magtype = currentarm.ammotype;
				bool ismagazine = (magtype is "hdmagammo");
					
				if (player.cmd.buttons & BT_USE)
				{
					invoker.statusmessage = "";
					hdplayerpawn(self).wephelptext = hdweapon(player.readyweapon).gethelptext();
				}
				else
				{
					invoker.statusmessage = currentarm.getstatustext(playerpawn(self));
				}
				
				//================================
				//INTERACTION HANDLING
				//================================
				
				if (player.cmd.buttons & BT_RELOAD || 
					(player.cmd.buttons & BT_USER1 && !(player.cmd.buttons & BT_USER4)))
				{		
					bool usealtammo = false;
					
					if (player.cmd.buttons & BT_USER1 && currentarm.altammotype != "")
					{
						usealtammo = true;
						
						class<actor> altmagtype = currentarm.altammotype;
						ismagazine = (altmagtype is "hdmagammo");
					}
					
					hdmagammo magammo;
					hdammo nonmagammo;
					
					if (ismagazine)
					{
						magammo = hdmagammo(findinventory((usealtammo ? currentarm.altammotype : currentarm.ammotype)));
					}
					else
					{
						nonmagammo = hdammo(findinventory((usealtammo ? currentarm.altammotype : currentarm.ammotype)));
					}
					
					if (currentarm.checkload(usealtammo) && (magammo || nonmagammo))
					{
						invoker.actiontime = currentarm.getreloadtime(usealtammo, false);
						invoker.actionmessage = (usealtammo ? "Alt. " : "").."Reloading";
						
						if (invoker.actionprogress >= invoker.actiontime)
						{
							if (ismagazine)
							{
								currentarm.loadmagazine(magammo.takemag(true), usealtammo);
							}
							else
							{
								currentarm.loadmagazine(1, usealtammo);
								
								takeinventory(nonmagammo.getclassname(), 1);
							}
							
							a_startsound(currentarm.getloadsound(false, usealtammo), CHAN_WEAPON);
						
							invoker.actionmessage = "";
							invoker.actionprogress = 0;
							invoker.actiontime = -1;
						}
						else
						{
							invoker.actionprogress++;
						}
					}
					else
					{
						if (invoker.justpressed(BT_RELOAD) || 
							(invoker.justpressed(BT_USER1) && !invoker.justpressed(BT_USER4)))
						{
							if (!currentarm.checkload(usealtammo))
							{
								A_WeaponMessage("There's no room for any more "..
									(usealtammo ? "alt. " : "").."ammo.",70);
							}
							else if (!magammo && !nonmagammo)
							{
								if (usealtammo)
								{
									A_WeaponMessage("You don't have any alternate ammo.",70);
								}
								else
								{
									A_WeaponMessage("You don't have any ammo.",70);
								}
							}
						}
						
						invoker.actiontime = -1;
					}
				}
				else if (player.cmd.buttons & BT_USER4)
				{
					bool usealtammo = false;
					
					if (player.cmd.buttons & BT_USER1 && currentarm.altammotype != "")
					{
						usealtammo = true;
						
						class<actor> altmagtype = currentarm.altammotype;
						ismagazine = (altmagtype is "hdmagammo");
					}
					
					if (currentarm.checkunload(usealtammo))
					{
						invoker.actiontime = currentarm.getreloadtime(usealtammo, true);
						invoker.actionmessage = (usealtammo ? "Alt. " : "").."Unloading";
							
						if (invoker.actionprogress >= invoker.actiontime)
						{
							if (ismagazine)
							{
								hdmagammo.givemag(self, (usealtammo ? currentarm.altammotype : currentarm.ammotype), 
									currentarm.handleunload(usealtammo));
							}
							else
							{
								giveinventory((usealtammo ? currentarm.altammotype : currentarm.ammotype),
									currentarm.handleunload(usealtammo));
							}
							
							a_startsound(currentarm.getloadsound(true, usealtammo), CHAN_WEAPON);
						
							invoker.actionmessage = "";
							invoker.actionprogress = 0;
							invoker.actiontime = -1;
						}
						else
						{
							invoker.actionprogress++;
						}
					}
					else
					{
						if (invoker.justpressed(BT_USER4))
						{
							if (currentarm is "hdpowersuitblankarm")
							{
								A_WeaponMessage("There's no weapon here.",70);
							}
							else if (!currentarm.checkunload(usealtammo))
							{
								A_WeaponMessage("There's no "..
									(usealtammo ? "alt. " : "").."ammo left in this.",70);
							}
						}
						
						invoker.actiontime = -1;
					}
				}
				else
				{
					invoker.actionmessage = "";
					invoker.actionprogress = 0;
					invoker.actiontime = -1;
				}
				invoker.msgtimer--;
				
				array<int> weaponstatus;
				weaponstatus.resize(HDWEP_STATUSSLOTS);
				currentarm.spawndroppedarm(weaponstatus);
				
				for (int i = 0; i < HDWEP_STATUSSLOTS; i++)
				{
					invoker.weaponstatus[i] = weaponstatus[i];
				}
				
				currentarm.destroy();
			}
			loop;
	}
}
