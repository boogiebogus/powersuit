const HDLD_SUITBEACON = "pst";

class hdpowersuitstorage
{
	int integrity;
	int armordurability;
	int batteries[3];
	int repairparts;
	int armorplates;
	
	string leftarmtype, rightarmtype, leftshouldertype, rightshouldertype, leftextra, rightextra, leftsextra, rightsextra;
	array<int> leftstatus, rightstatus, leftsstatus, rightsstatus;
}

class HDPowersuitSpawnHandler : staticeventhandler
{
	array<hdpowersuitstorage> suits;
	array<string> weapontypes;
	array<string> attachmenttypes;

	override void checkreplacement(replaceevent e)
	{
		if (!e.replacement)
		{
			return;
		}
		
		if (e.replacement == "hdmegasphere" && random(0, 100) < 30)
		{
			e.replacement = "hdpowersuitspawnerpickup";
		}
	}

	override void CheckReplacee(ReplacedEvent e)
	{
		switch (e.Replacement.GetClassName())
		{
			case 'hdpowersuitspawnerpickup':
					e.Replacee = "hdmegasphere";
				break;
		}
	}

	
	override void worldthingspawned(worldevent e)
	{
		if (e.thing && e.thing.getclassname() == "hdpowersuitspawnerpickup" && !(hdpowersuitspawnerpickup(e.thing).owner))
		{
			hdpowersuitarmpickup(e.thing.spawn(weapontypes[random(0, weapontypes.size() - 1)], 
				e.thing.pos + (frandom(-16, 16), frandom(-16, 16), 0))).initializewepstats();
				
			hdpowersuitarmpickup(e.thing.spawn("hdpowersuitvulcarmpickup", 
				e.thing.pos + (frandom(-16, 16), frandom(-16, 16), 0))).initializewepstats();
				
			hdpowersuitshoulderpickup(e.thing.spawn(attachmenttypes[random(0, attachmenttypes.size() - 1)], 
				e.thing.pos + (frandom(-16, 16), frandom(-16, 16), 0))).initializewepstats();
				
			hdpowersuitshoulderpickup(e.thing.spawn("hdpowersuitheatsinkpickup", 
				e.thing.pos + (frandom(-16, 16), frandom(-16, 16), 0))).initializewepstats();
		}
	}
	
	override void worldunloaded(worldevent e)
	{
		suits.clear();
		
		for (int i = 0; i < MAXPLAYERS; i++)
		{
			playerinfo p = players[i];
			
			hdpowersuitstorage blanksuit = new("hdpowersuitstorage");
			suits.push(blanksuit);
			if (p && p.mo && p.readyweapon is "hdpowersuitinterface")
			{
				hdpowersuit suit = hdpowersuitinterface(p.mo.findinventory("hdpowersuitinterface")).suitcore;
				
				if (suit)
				{
					suits[i].integrity = suit.integrity;
					suits[i].armordurability = suit.suitarmor.durability;
					suits[i].batteries[0] = suit.batteries[0];
					suits[i].batteries[1] = suit.batteries[1];
					suits[i].batteries[2] = suit.batteries[2];
					suits[i].repairparts = suit.repairparts;
					suits[i].armorplates = suit.armorplates;
					
					suits[i].leftarmtype = suit.torso.leftarm.droppeditemname;
					suits[i].rightarmtype = suit.torso.rightarm.droppeditemname;
					suits[i].leftextra = suit.torso.leftarm.getextradata();
					suits[i].rightextra = suit.torso.rightarm.getextradata();
					
					suits[i].leftshouldertype = suit.torso.leftshoulder.droppeditemname;
					suits[i].rightshouldertype = suit.torso.rightshoulder.droppeditemname;
					suits[i].leftsextra = suit.torso.leftshoulder.getextradata();
					suits[i].rightsextra = suit.torso.rightshoulder.getextradata();
					
					suits[i].leftsstatus.resize(HDWEP_STATUSSLOTS);
					suits[i].rightsstatus.resize(HDWEP_STATUSSLOTS);
					suit.torso.leftshoulder.spawndroppedshoulder(suits[i].leftsstatus);
					suit.torso.rightshoulder.spawndroppedshoulder(suits[i].rightsstatus);
					
					suits[i].leftstatus.resize(HDWEP_STATUSSLOTS);
					suits[i].rightstatus.resize(HDWEP_STATUSSLOTS);
					suit.torso.leftarm.spawndroppedarm(suits[i].leftstatus);
					suit.torso.rightarm.spawndroppedarm(suits[i].rightstatus);
				}
			}
		}
	}
	
	override void worldloaded(worldevent e)
	{
		for (int i = 0; i < allactorclasses.size(); i++)
		{
			if (allactorclasses[i] is "hdpowersuitarmpickup"
				&& !(allactorclasses[i].getclassname() == "hdpowersuitarmpickup"
				|| allactorclasses[i].getclassname() == "hdpowersuitblankarmpickup"))
			{
				weapontypes.push(allactorclasses[i].getclassname());
			}
			
			if (allactorclasses[i] is "hdpowersuitshoulderpickup"
				&& !(allactorclasses[i].getclassname() == "hdpowersuitshoulderpickup"
				|| allactorclasses[i].getclassname() == "hdpowersuitblankshoulderpickup"))
			{
				attachmenttypes.push(allactorclasses[i].getclassname());
			}
		}
		
		if (!e.issavegame)
		{
			for (int i = 0; i < MAXPLAYERS; i++)
			{
				playerinfo p = players[i];
				
				if (p && p.mo && p.readyweapon is "hdpowersuitinterface")
				{
					if (!hdpowersuitinterface(p.readyweapon).suitcore)
					{
						hdpowersuit suit = hdpowersuit(p.mo.spawn("hdpowersuit", p.mo.pos));
						
						suit.driver = p.mo;
						suit.driver.bthruactors = true;
						suit.driver.player.cheats |= CF_FROZEN;
						suit.interface = hdpowersuitinterface(p.readyweapon);
						suit.interface.suitcore = suit;
						hdplayerpawn(suit.driver).tauntsound = "mech/horn";
						p.mo.a_setrenderstyle(1.0, STYLE_NONE);
						
						suit.torso.aimpoint = suit.spawn("hdpowersuitaimpoint", suit.pos);
						
						hdpowersuitarmpickup leftarmpickup, rightarmpickup;
						leftarmpickup = hdpowersuitarmpickup(suit.spawn(suits[i].leftarmtype, suit.pos));
						rightarmpickup = hdpowersuitarmpickup(suit.spawn(suits[i].rightarmtype, suit.pos));
						
						hdpowersuitshoulderpickup leftattachmentpickup, rightattachmentpickup;
						leftattachmentpickup = hdpowersuitshoulderpickup(suit.spawn(suits[i].leftshouldertype, suit.pos));
						rightattachmentpickup = hdpowersuitshoulderpickup(suit.spawn(suits[i].rightshouldertype, suit.pos));
						
						for (int j = 0; j < HDWEP_STATUSSLOTS; j++)
						{
							leftarmpickup.weaponstatus[j] = suits[i].leftstatus[j];
							rightarmpickup.weaponstatus[j] = suits[i].rightstatus[j];
							leftattachmentpickup.weaponstatus[j] = suits[i].leftsstatus[j];
							rightattachmentpickup.weaponstatus[j] = suits[i].rightsstatus[j];
						}
						
						hdpowersuitarm newleftarm = hdpowersuitarm(suit.spawn(leftarmpickup.armtype, suit.torso.leftarm.pos));
						hdpowersuitarm newrightarm = hdpowersuitarm(suit.spawn(rightarmpickup.armtype, suit.torso.rightarm.pos));
													
						newleftarm.isleft = true;
						newrightarm.isleft = false;
						newleftarm.handlemountammo(leftarmpickup, playerpawn(p.mo), false, true, suits[i].leftextra);
						newrightarm.handlemountammo(rightarmpickup, playerpawn(p.mo), false, true, suits[i].rightextra);
						newleftarm.suitcore = suit;
						newrightarm.suitcore = suit;
						
						hdpowersuitshoulder newleftattachment = hdpowersuitshoulder(suit.spawn(leftattachmentpickup.shouldertype, suit.torso.leftshoulder.pos));
						hdpowersuitshoulder newrightattachment = hdpowersuitshoulder(suit.spawn(rightattachmentpickup.shouldertype, suit.torso.rightshoulder.pos));
													
						newleftattachment.isleft = true;
						newrightattachment.isleft = false;
						newleftattachment.handlemountammo(leftattachmentpickup, playerpawn(p.mo), false, true, suits[i].leftsextra);
						newrightattachment.handlemountammo(rightattachmentpickup, playerpawn(p.mo), false, true, suits[i].rightsextra);
						newleftattachment.suitcore = suit;
						newrightattachment.suitcore = suit;
						
						suit.integrity = suits[i].integrity;
						suit.suitarmor.durability = suits[i].armordurability;
						suit.batteries[0] = suits[i].batteries[0];
						suit.batteries[1] = suits[i].batteries[1];
						suit.batteries[2] = suits[i].batteries[2];
						suit.repairparts = suits[i].repairparts;
						suit.armorplates = suits[i].armorplates;
						
						suit.torso.leftarm.destroy();
						suit.torso.rightarm.destroy();
						suit.torso.leftarm = newleftarm;
						suit.torso.rightarm = newrightarm;
						
						suit.torso.leftshoulder.destroy();
						suit.torso.rightshoulder.destroy();
						suit.torso.leftshoulder = newleftattachment;
						suit.torso.rightshoulder = newrightattachment;
						
						if (!(suit.torso.leftarm is "hdpowersuitblankarm"))
						{
							suit.torso.leftarm.armpoint = hdpowersuitaimpoint(suit.spawn("hdpowersuitaimpoint", suit.pos));
							suit.torso.leftarm.armpoint.isarm = true;
							suit.torso.leftarm.armpoint.isleft = true;
							suit.torso.leftarm.armpoint.accuracy = i;
						}
						
						if (!(suit.torso.rightarm is "hdpowersuitblankarm"))
						{
							suit.torso.rightarm.armpoint = hdpowersuitaimpoint(suit.spawn("hdpowersuitaimpoint", suit.pos));
							suit.torso.rightarm.armpoint.isarm = true;
							suit.torso.rightarm.armpoint.isleft = false;
							suit.torso.rightarm.armpoint.accuracy = i;
						}
						
						if (!(suit.torso.leftshoulder is "hdpowersuitblankshoulder"))
						{
							suit.torso.leftshoulder.shoulderpoint = hdpowersuitshoulderaimpoint(suit.spawn("hdpowersuitshoulderaimpoint", suit.pos));
							suit.torso.leftshoulder.shoulderpoint.isarm = true;
							suit.torso.leftshoulder.shoulderpoint.isleft = true;
							suit.torso.leftshoulder.shoulderpoint.accuracy = i;
						}
						
						if (!(suit.torso.rightshoulder is "hdpowersuitblankshoulder"))
						{
							suit.torso.rightshoulder.shoulderpoint = hdpowersuitshoulderaimpoint(suit.spawn("hdpowersuitshoulderaimpoint", suit.pos));
							suit.torso.rightshoulder.shoulderpoint.isarm = true;
							suit.torso.rightshoulder.shoulderpoint.isleft = false;
							suit.torso.rightshoulder.shoulderpoint.accuracy = i;
						}
						
						suit.viewz = suit.driver.player.viewz;
						
						suit.torso.translation = suit.driver.translation;
						suit.torso.leftleg.translation = suit.driver.translation;
						suit.torso.rightleg.translation = suit.driver.translation;
						
						leftarmpickup.destroy();
						rightarmpickup.destroy();
						leftattachmentpickup.destroy();
						rightattachmentpickup.destroy();
					}
				}
			}
		}
	}
}

class hdpowersuitspawnerpickup : hdpickup
{	
	default
	{
		inventory.pickupmessage "Picked up a powersuit warp-in beacon.";
		inventory.maxamount 1;
		hdpickup.refid HDLD_SUITBEACON;
		-hdpickup.fitsinbackpack;
		tag "Powersuit beacon";
	}
	
	states
	{
		spawn:
			HCAP A -1;
			stop;
			
		use:
			TNT1 A 0
			{			
				actor spawner = spawn("hdpowersuitspawneractual", pos);
				spawner.angle = angle;
				spawner.a_changevelocity(5, 0, 3, CVF_RELATIVE);
				spawner.translation = translation;
			}
			stop;
	}
}

class hdpowersuitspawneractual : actor
{
	default
	{
		radius 4;
		height 12;
	}
	
	states
	{
		spawn:
			HCAP AAA 35 nodelay
			{
				a_startsound("mech/beaconbeep", CHAN_BODY);
			}
			HCAP A 0
			{
				hdpowersuit suit = hdpowersuit(spawn("hdpowersuit", pos));
				
				suit.spawn("telefog", suit.pos);
				suit.targetangle = angle;
				suit.angle = angle;
				suit.torso.angle = angle;
		
				suit.integrity = suit.maxintegrity;
				suit.batteries[0] = 20;
				suit.batteries[1] = 20;
				suit.batteries[2] = -1;
				suit.suitarmor.durability = suit.maxarmor;
				
				hdpowersuitarm newleftarm = hdpowersuitarm(spawn("hdpowersuitblankarm", suit.pos));
				hdpowersuitarm newrightarm = hdpowersuitarm(spawn("hdpowersuitblankarm",  suit.pos));
													
				newleftarm.isleft = true;		
				newrightarm.isleft = false;
				newleftarm.suitcore = suit;
				newrightarm.suitcore = suit;
				
				suit.torso.leftarm.destroy();
				suit.torso.rightarm.destroy();
				suit.torso.leftarm = newleftarm;
				suit.torso.rightarm = newrightarm;
				
				suit.torso.translation = translation;
				suit.torso.leftleg.translation = translation;
				suit.torso.rightleg.translation = translation;
			}
			stop;
	}
}
