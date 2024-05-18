#include "zscript/attachments/blankshoulder.zs"
#include "zscript/attachments/heatsink.zs"
#include "zscript/attachments/gl67grenadelauncher.zs"
#include "zscript/attachments/rainmodule.zs"

class HDPowersuitShoulderAimPoint : actor
{
	bool isarm, isleft;
	//accuracy is owner player
	
	default
	{
		+nointeraction
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}

class HDPowersuitShoulder : hdactor
{
	int mogshoulderflags;

	flagdef istool:mogshoulderflags,0;
	flagdef isexplosive:mogshoulderflags,1;
	flagdef isnotdetachable:mogshoulderflags,2;
	hdpowersuitshoulderaimpoint shoulderpoint;
	bool isfiring;
	hdpowersuit suitcore;
	array<int> mags;
	int maxmags, magsize;
	string undetachablemessage;
	property undetachablemessage : undetachablemessage;
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
		-solid
		+shootable
		+noblood
		health 2000;
		species "hdpowersuit";
		hdpowersuitshoulder.magtype "";
		hdpowersuitshoulder.undetachablemessage "bruh";
		hdpowersuitshoulder.altammotype "";
		obituary "%o fell for war crimes."; //gross hack
	}
	
	virtual void A_Kaboom(bool forceexplosion = false)
	{
		if(!forceexplosion && !bIsExplosive)return;
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
	
	virtual void spawndroppedshoulder(out array<int> weaponstatus)
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
			//hdpowersuitshoulderpickup droppedarm = hdpowersuitshoulderpickup(spawn(droppeditemname, pos));
			
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
	
	virtual void handlemountammo(hdpowersuitshoulderpickup attachmentitem, playerpawn owner, 
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
			int amountmags = attachmentitem.weaponstatus[0];
			currentmag = attachmentitem.weaponstatus[2];
			
			if (ismagammo)
			{
				for (int i = 0; i < amountmags; i++)
				{
					loadmagazine(attachmentitem.weaponstatus[3 + i], false);
				}
			}
			else
			{
				for (int i = 0; i < attachmentitem.weaponstatus[3]; i++)
				{
					loadmagazine(1, false);
				}
			}
			
			if (takeitem)
			{
				owner.takeinventory(attachmentitem.getclassname(), 1);
			}
		}
	}
	
	virtual ui void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		//too lazy to do this the "right" way
		int reserveshots = 0;
		if(bIsTool)return;
		
		if (isleft)
		{
			if (currentmag > 0)
			{
				sb.drawrect(-48, -32, float(currentmag / float(magsize)) * -48, -4);
			}
			
			for (int i = 0; i < mags.size(); i++)
			{
				sb.drawrect(-48 + (i * -3), -38, -2, -4);
				
				reserveshots += mags[i];
			}
		
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(currentmag, 0)),
				(-50, -32), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_WHITE, scale: (0.5, 0.5));
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", reserveshots),
				(-54 - (string.format("%i", currentmag).length() * 4), -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_RED, scale: (0.5, 0.5));
				
			sb.drawstring(sb.pnewsmallfont, firemodestring,
				(-58 - ((string.format("%i", currentmag).length() + string.format("%i", reserveshots).length()) * 4), -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_GRAY, scale: (0.5, 0.5));
		}
		else
		{
			if (currentmag > 0)
			{
				sb.drawrect(48, -32, float(currentmag / float(magsize)) * 48, -4);
			}
				
			for (int i = 0; i < mags.size(); i++)
			{
				sb.drawrect(48 + (i * 3), -38, 2, -4);
				reserveshots += mags[i];
			}
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", max(currentmag, 0)),
				(48, -32), sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_WHITE, scale: (0.5, 0.5));
			
			sb.drawstring(sb.pnewsmallfont, string.format("%i", reserveshots),
				(52 + (string.format("%i", currentmag).length() * 4), -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_RED, scale: (0.5, 0.5));
				
			sb.drawstring(sb.pnewsmallfont, firemodestring,
				(56 + ((string.format("%i", currentmag).length() + string.format("%i", reserveshots).length()) * 4), -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_GRAY, scale: (0.5, 0.5));
		}
	}
	
	virtual string getstatustext(playerpawn weaponowner)
	{
		if (!weaponowner)
		{
			return "";
		}
		
		if (bIsTool)
		{
			return  "\cjAttachment: \cd"..gettag().."\n\n\cjThis is a \cdtool attachment\cj.\nNo need to do anything here.";
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
		statusmessage = "\cjAttachment: \cd"..gettag()..(ismagazine ? ( //if it's a mag
			"\n\cjLoaded magazines: \cd"..mags.size() + ((realcurrentmag > 0) ? 1 : 0).."/"..(maxmags + 1)..
			"\n\cjCurrent magazine: \cd"..((realcurrentmag > 0) ? (realcurrentmag.." rounds") : "\cgnone")) : "").. //end of if it's a mag
			"\n\cjTotal rounds: \cd"..((totalrounds > 0) ? totalrounds.."/"..(ismagazine ? ((maxmags + 1) * magsize) : (maxmags + 1)).." rounds" : "\cgnone")..
			"\n\cf"..magstring..((magstring.mid(magstring.length() - 1, 1) == 's') ? " " : "s ")..
			"\cjin inventory: \cd";
				
		if (weaponowner.findinventory(ammotype)&&!bIsTool)
		{
			statusmessage = statusmessage..weaponowner.findinventory(ammotype).amount;
		}
		else if(!bIsTool)
		{
			statusmessage = statusmessage.."\cgnone";
		}
		
		if((altammotype != "")&&!bIsTool)
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
			warp(suitcore, 6, (isleft ? -16 : 16), suitcore.haslegs ? 48 : 28, angle,  
					WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION | WARPF_ABSOLUTEANGLE);			
			vel = (0,0,0);
			master = suitcore.master;
			friendplayer = suitcore.friendplayer;
			angle = suitcore.torso.angle;
			
			if (shoulderpoint && suitcore.driver)
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
					shoulderpoint.setorigin(tracedata.hitlocation, true);
					shoulderpoint.isarm = true;
				}
				else
				{
					shoulderpoint.isarm = false; //turn off if there's no battery
				}
			}
		}
		
		super.tick();
	}
	
	override void ondestroy()
	{
		if (shoulderpoint)
		{
			shoulderpoint.destroy();
		}
		
		super.ondestroy();
	}
	states
	{
		death:
			TNT1 A 1{
				A_Kaboom();
				hdpowersuitshoulder blankshoulder = hdpowersuitshoulder(spawn("hdpowersuitblankshoulder", pos));
				blankshoulder.isleft = isleft;
				blankshoulder.suitcore = suitcore;
				
				if (isleft)
				{
					suitcore.torso.leftshoulder = blankshoulder;
				}
				else
				{
					suitcore.torso.rightshoulder = blankshoulder;
				}
				
				blankshoulder.a_startsound("misc/glassbreak", CHAN_WEAPON);
				for(int i=0;i<random(75,100);i++){
					A_SpawnItemEx("HugeWallChunk",
						frandom((-radius/2),(radius/2)),frandom((-radius/2),(radius/2)),frandom(0,(height/4)),
						frandom(-5,5),frandom(-5,5),frandom(-5,5),frandom(0,359),
						SXF_SETMASTER|SXF_TRANSFERPOINTERS|SXF_ABSOLUTEPOSITION
					);
				}
			}
		stop;
	}
}

class HDPowersuitShoulderPickup : HDWeapon
{	
	string shouldertype;
	property shouldertype : shouldertype;
	int mogshoulderflags;

	flagdef istool:mogshoulderflags,0;
	
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
		
		sb.drawstring(sb.psmallfont, "\cc=== \cvAttachment Manager \cc===\n",
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
		class<actor> currentshoulder = shouldertype;
		
		if(bIsTool)
		return gettag().."\n\n\cjThis is a tool attachment.\n No need to do anything here.";
		
		return WEPHELP_RELOAD.."  Reload weapon\n"..
			(hdpowersuitshoulder(getdefaultbytype(currentshoulder)).altammotype != "" ? WEPHELP_ALTRELOAD.."  Alt. reload weapon\n" : "")..
			WEPHELP_UNLOAD.."  Unload weapon\n"..
			(hdpowersuitshoulder(getdefaultbytype(currentshoulder)).altammotype != "" ? WEPHELP_ALTRELOAD.." + "..WEPHELP_UNLOAD.."  Alt. unload weapon\n" : "");
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
		hdpowersuitshoulder currentshoulder = hdpowersuitshoulder(spawn(shouldertype, pos));
		currentshoulder.fillmags();
		
		array<int> weaponstatusb;
		weaponstatusb.resize(HDWEP_STATUSSLOTS);
		currentshoulder.spawndroppedshoulder(weaponstatusb);
		
		for (int i = 0; i < HDWEP_STATUSSLOTS; i++)
		{
			weaponstatus[i] = weaponstatusb[i];
		}
		
		currentshoulder.destroy();
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
				
				hdpowersuitshoulder currentshoulder = hdpowersuitshoulder(spawn(invoker.shouldertype, pos));
				currentshoulder.handlemountammo(invoker, playerpawn(self), false, false);
					
				class<actor> magtype = currentshoulder.ammotype;
				bool ismagazine = (magtype is "hdmagammo");
					
				if (player.cmd.buttons & BT_USE)
				{
					invoker.statusmessage = "";
					hdplayerpawn(self).wephelptext = hdweapon(player.readyweapon).gethelptext();
				}
				else
				{
					invoker.statusmessage = currentshoulder.getstatustext(playerpawn(self));
				}
				
				//================================
				//INTERACTION HANDLING
				//================================
				
				if (!invoker.bIsTool&&(player.cmd.buttons & BT_RELOAD || 
					(player.cmd.buttons & BT_USER1 && !(player.cmd.buttons & BT_USER4))))
				{		
					bool usealtammo = false;
					
					if (player.cmd.buttons & BT_USER1 && currentshoulder.altammotype != "")
					{
						usealtammo = true;
						
						class<actor> altmagtype = currentshoulder.altammotype;
						ismagazine = (altmagtype is "hdmagammo");
					}
					
					hdmagammo magammo;
					hdammo nonmagammo;
					
					if (ismagazine)
					{
						magammo = hdmagammo(findinventory((usealtammo ? currentshoulder.altammotype : currentshoulder.ammotype)));
					}
					else
					{
						nonmagammo = hdammo(findinventory((usealtammo ? currentshoulder.altammotype : currentshoulder.ammotype)));
					}
					
					if (currentshoulder.checkload(usealtammo) && (magammo || nonmagammo))
					{
						invoker.actiontime = currentshoulder.getreloadtime(usealtammo, false);
						invoker.actionmessage = (usealtammo ? "Alt. " : "").."Reloading";
						
						if (invoker.actionprogress >= invoker.actiontime)
						{
							if (ismagazine)
							{
								currentshoulder.loadmagazine(magammo.takemag(true), usealtammo);
							}
							else
							{
								currentshoulder.loadmagazine(1, usealtammo);
								
								takeinventory(nonmagammo.getclassname(), 1);
							}
							
							a_startsound(currentshoulder.getloadsound(false, usealtammo), CHAN_WEAPON);
						
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
							if (!currentshoulder.checkload(usealtammo))
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
				else if (!invoker.bIsTool&&(player.cmd.buttons & BT_USER4))
				{
					bool usealtammo = false;
					
					if (player.cmd.buttons & BT_USER1 && currentshoulder.altammotype != "")
					{
						usealtammo = true;
						
						class<actor> altmagtype = currentshoulder.altammotype;
						ismagazine = (altmagtype is "hdmagammo");
					}
					
					if (currentshoulder.checkunload(usealtammo))
					{
						invoker.actiontime = currentshoulder.getreloadtime(usealtammo, true);
						invoker.actionmessage = (usealtammo ? "Alt. " : "").."Unloading";
							
						if (invoker.actionprogress >= invoker.actiontime)
						{
							if (ismagazine)
							{
								hdmagammo.givemag(self, (usealtammo ? currentshoulder.altammotype : currentshoulder.ammotype), 
									currentshoulder.handleunload(usealtammo));
							}
							else
							{
								giveinventory((usealtammo ? currentshoulder.altammotype : currentshoulder.ammotype),
									currentshoulder.handleunload(usealtammo));
							}
							
							a_startsound(currentshoulder.getloadsound(true, usealtammo), CHAN_WEAPON);
						
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
							if (currentshoulder is "hdpowersuitblankshoulder")
							{
								A_WeaponMessage("There's no attachment here.",70);
							}
							else if (!currentshoulder.checkunload(usealtammo))
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
				currentshoulder.spawndroppedshoulder(weaponstatus);
				
				for (int i = 0; i < HDWEP_STATUSSLOTS; i++)
				{
					invoker.weaponstatus[i] = weaponstatus[i];
				}
				
				currentshoulder.destroy();
			}
			loop;
	}
}
