class HDPowersuitEditor : hdweapon
{
	hdpowersuit suitcore;
	string statusmessage, actionmessage;
	int selected, selectedarm;
	int actionprogress, actiontime;
	array<string> options;
	hdpowersuitarmpickup armitem;
		
	default
	{
		weapon.slotnumber 1;
	}
	
	override void attachtoowner(actor other)
	{
		selected = 0;
		options.push("Left Arm");
		options.push("Right Arm");
		options.push("Battery");
		options.push("Armor");
		options.push("Integrity");
		options.push("Parts");
		
		super.attachtoowner(other);
	}
	
	enum POWERSUIT_PARTS
	{
		SUIT_LEFTARM,
		SUIT_RIGHTARM,
		SUIT_BATTERY,
		SUIT_ARMOR,
		SUIT_INTEGRITY,
		SUIT_PARTS
	};
	
	void resetaction()
	{
		actionmessage = "";
		actionprogress = 0;
		actiontime = -1;
	}
	
	override string gethelptext()
	{
		string returnstring = WEPHELP_FIRE.. "  Next option\n"..
			WEPHELP_ALTFIRE.. "  Previous option\n\n";
			
		bool isleft = false;
		switch(selected)
		{
			default:
				returnstring = returnstring.."AAAAAAAAAAAAAAAAAAAAAAAAAAAGGGGGHHHHHHHHHHHH";
				break;
				
			case SUIT_LEFTARM:
				isleft = true;
			case SUIT_RIGHTARM:
				hdpowersuitarm currentarm;
				if (isleft)
				{
					currentarm = suitcore.torso.leftarm;
				}
				else
				{
					currentarm = suitcore.torso.rightarm;
				}
				
				if (currentarm)
				{
					if (currentarm is "hdpowersuitblankarm")
					{
						returnstring = returnstring..WEPHELP_FIREMODE.." + "..WEPHELP_FIRE.."  Select next weapon\n"..
							WEPHELP_FIREMODE.." + "..WEPHELP_ALTFIRE.. "  Select previous weapon\n"..
							WEPHELP_FIREMODE.." + "..WEPHELP_RELOAD.."  Mount selected weapon";
					}
					else
					{
						returnstring = returnstring..WEPHELP_RELOAD.."  Reload weapon\n"..
							(currentarm.altammotype != "" ? WEPHELP_ALTRELOAD.."  Alt. reload weapon\n" : "")..
							WEPHELP_UNLOAD.."  Unload weapon\n"..
							(currentarm.altammotype != "" ? WEPHELP_ALTRELOAD.." + "..WEPHELP_UNLOAD.."  Alt. unload weapon\n" : "")..
							WEPHELP_FIREMODE.." + "..WEPHELP_UNLOAD.."  Dismount weapon";
					}
				}
				break;
				
			case SUIT_BATTERY:
				returnstring = returnstring..WEPHELP_RELOAD.."  Reload battery 1\n"..
					WEPHELP_FIREMODE.." + "..WEPHELP_RELOAD.."  Reload battery 2\n"..
					WEPHELP_ALTRELOAD.."  Reload shield battery\n\n"..
					WEPHELP_UNLOAD.."  Unload battery 1\n"..
					WEPHELP_FIREMODE.." + "..WEPHELP_UNLOAD.."  Unload battery 2\n"..
					WEPHELP_ALTRELOAD.." + "..WEPHELP_UNLOAD.."  Unload shield battery";
					break;
				
			case SUIT_ARMOR:
				returnstring = returnstring..WEPHELP_RELOAD.."  Repair armor\n(needs battle armor in inventory)";
				break;
				
			case SUIT_INTEGRITY:
				returnstring = returnstring..WEPHELP_RELOAD.."  Repair integrity\n(needs parts)\n\n"..
					WEPHELP_UNLOAD.."  Disassemble HERP for parts\n(needs HERP in inventory)";
				break;
				
			case SUIT_PARTS:
				returnstring = returnstring..WEPHELP_RELOAD.."  Mount arms\n"..
					WEPHELP_FIREMODE.." + "..WEPHELP_RELOAD.."  Mount legs\n\n"..
					WEPHELP_UNLOAD.."  Dismount arms\n"..
					WEPHELP_FIREMODE.." + "..WEPHELP_UNLOAD.."  Dismount legs\n\n"..
					WEPHELP_UNLOAD.." "..WEPHELP_BTCOL.."without limbs"..WEPHELP_RGCOL.."  Pack up torso";
				break;
		}
		
		return returnstring;
	}
	
	override void doeffect()
	{
		if (owner.player.readyweapon != self
			|| !suitcore)
		{
			self.destroy();
			return;
		}
		
		if (suitcore && owner)
		{
			if (owner.distance3d(suitcore) > 96)
			{
				owner.a_selectweapon("hdfist");
			}
			
			if (owner.player.cmd.buttons & BT_USE)
			{
				hdplayerpawn(owner).wephelptext = hdweapon(owner.player.readyweapon).gethelptext();
			}
		}
		
		if (!(owner.player.cmd.buttons & BT_USE))
		{
			bool isleftarm = false;
			switch(selected)
			{
				default:
					statusmessage = "\cgThere is no one who loves pain itself, who seeks after it, and wants to have it, simply because it is pain.";
					break;
					
				case SUIT_LEFTARM:
					isleftarm = true;
				case SUIT_RIGHTARM:
					hdpowersuitarm currentarm = isleftarm ? suitcore.torso.leftarm : suitcore.torso.rightarm;
					
					if (currentarm && !(currentarm is "hdpowersuitblankarm"))
					{						
						statusmessage = currentarm.getstatustext(playerpawn(owner));
					}
					else if (suitcore.hasarms)
					{
						statusmessage = "\cgThere's no weapon mounted here."..
							"\n\cjWeapon to mount: \cd";
						
						if (armitem)
						{
							statusmessage = statusmessage..armitem.gettag();
						}
						else
						{
							statusmessage = statusmessage.."\cgnone";
						}
					}
					else
					{
						statusmessage = "\cjThis suit has \cgno arms.";
					}
					
					break;
				
				case SUIT_BATTERY:
					int batt1 = int((suitcore.batteries[0] / 20.0) * 100);
					int batt2 = int((suitcore.batteries[1] / 20.0) * 100);
					int batt3 = int((suitcore.batteries[2] / 20.0) * 100);
					
					if (suitcore.batteries[0] > 0)
					{
						batt1 = min(batt1 + int((suitcore.partialcharge / float(suitcore.partialchargemax)) * 5), 100);
					}
					else
					{
						batt2 = min(batt2 + int((suitcore.partialcharge / float(suitcore.partialchargemax)) * 5), 100);
					}
					batt3 = min(batt3 + int((suitcore.partialshieldcharge / 
						float((2 * suitcore.partialchargemax) / 3)) * 5), 100);
					
					statusmessage = "\cjBattery 1: \cd"..
						((suitcore.batteries[0] >= 0) ? (batt1.."%") : "\cgNone").."\n\cjBattery 2: \cd"..
						((suitcore.batteries[1] >= 0) ? (batt2.."%") : "\cgNone").."\n\cjShield Battery: \cd"..
						((suitcore.batteries[2] >= 0) ? (batt3.."%") : "\cgNone");
					break;
					
				case SUIT_ARMOR:
					statusmessage = "\cjDurability: \cd"..
						int((suitcore.suitarmor.durability / float(suitcore.maxarmor)) * 100).."%";
					break;
					
				case SUIT_INTEGRITY:
					statusmessage = "\cjIntegrity: \cd"..
						((suitcore.integrity > 0) ? (int((suitcore.integrity / float(suitcore.maxintegrity)) * 100).."%") : "\cgCritically damaged")..
						"\n\cjRepair materials: \cd"..((suitcore.repairparts > 0) ? (suitcore.repairparts.."") : "\cgNone").. //don't ask about suitcore.repairparts.."", it just works
						" \cj(max "..suitcore.maxparts..")";
					break;
					
				case SUIT_PARTS:
					statusmessage = "\cjArms: \cd"..(suitcore.hasarms ? "Good" : "\cgNone")..
						"\n\cjLegs: \cd"..(suitcore.haslegs ? "Good" : "\cgNone")..
						"\n\cjCan pack up chassis: \cd"..((!suitcore.hasarms && !suitcore.haslegs) ? "Yes" : "\cgNo");
					break;
			}
		}
		else
		{
			statusmessage = "";
		}
		
		super.doeffect();
	}
	
	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		sb.drawstring(sb.psmallfont, "\cc=== \cqPowersuit Maintenance \cc===\n",
			(0, -96), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
			
		string letter;
		
		/*if (suitcore.integrity > (3 * suitcore.maxintegrity) / 4)
		{
			letter = "A";
		}
		else if (suitcore.integrity > suitcore.maxintegrity / 2)
		{
			letter = "B";
		}
		else if (suitcore.integrity > suitcore.maxintegrity / 4)
		{
			letter = "C";
		}
		else
		{
			letter = "D";
		}*/
		
		// LZDoom compat hack: override CPlayer to translate the image
        let prevCPlayer = sb.CPlayer;
        sb.CPlayer = players[suitcore.torso.translation & 65535];

		if (suitcore.haslegs)
		{	
			sb.drawimage("PSUIA1", (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE,
				scale: (1.8, 1.8));
		}
	
		sb.drawimage("PSUIA2", (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE,
			scale: (1.8, 1.8));
		
		if (suitcore.hasarms)
		{
			sb.drawimage("PSUIA3", (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE,
				scale: (1.8, 1.8));
		}
		
		if (suitcore.torso.rightarm && !(suitcore.torso.rightarm is "hdpowersuitblankarm"))
		{
			sb.drawimage("PSUIA4", (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE,
				scale: (1.8, 1.8));
		}
		
		if (suitcore.torso.leftarm && !(suitcore.torso.leftarm is "hdpowersuitblankarm"))
		{
			sb.drawimage("PSUIA5", (0, 0), sb.DI_SCREEN_CENTER | sb.DI_ITEM_CENTER | sb.DI_TRANSLATABLE,
				scale: (1.8, 1.8));
		}
		
        // restore previous CPlayer
        sb.CPlayer = prevCPlayer;
		
		sb.drawstring(sb.psmallfont, statusmessage,
			(8, -64), sb.DI_SCREEN_LEFT | sb.DI_SCREEN_VCENTER | sb.DI_TEXT_ALIGN_LEFT, wrapwidth: 232,
				scale:(0.7, 0.7));
		
		if (options.size() > 0)
		{
			for (int i = 0; i < options.size(); i++)
			{
				sb.drawstring(sb.psmallfont, options[i], 
					(-8, -64 + (16 * i)), sb.DI_SCREEN_RIGHT | sb.DI_SCREEN_VCENTER | sb.DI_TEXT_ALIGN_RIGHT,
						(selected == i) ? font.CR_WHITE : font.CR_DARKGRAY);
			}
		}
		
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
	
	int valuechange(int amount, int max, bool increase)
	{
		if (amount > max)
		{
			return max;
		}
		
		else if (increase)
		{
			amount++;
			
			if (amount >= max)
			{
				return 0;
			}
			else
			{
				return amount;
			}
		}
		else
		{
			amount--;
			
			if (amount < 0)
			{
				return max - 1;
			}
			else
			{
				return amount;
			}
		}
	}
		
	bool justpressed(int which)
	{
		int btn = owner.player.cmd.buttons;
		int oldbtn = owner.player.oldbuttons;
		return btn & which && !(oldbtn & which);
		
		return false;
	}
	
	states
	{
		ready:
			TNT1 A 1 
			{
				a_weaponready(WRF_NOFIRE);
				
				if (!(player.cmd.buttons & BT_USER2))
				{
					if (invoker.justpressed(BT_ATTACK))
					{
						invoker.selected = invoker.valuechange(invoker.selected, 
							invoker.options.size(), true);
					}
					else if (invoker.justpressed(BT_ALTATTACK))
					{
						invoker.selected = invoker.valuechange(invoker.selected, 
							invoker.options.size(), false);
					}
				}
				
				bool isleftarm = false;
				switch(invoker.selected)
				{
					default:
						invoker.actionmessage = "IM FUCKING SNEEDING!!! IM FUCKING FEEDING!!!";
						break;
						
					case SUIT_LEFTARM:
						isleftarm = true;
					case SUIT_RIGHTARM:
						hdpowersuitarm currentarm = isleftarm ? invoker.suitcore.torso.leftarm : invoker.suitcore.torso.rightarm;
						if (currentarm)
						{
							class<actor> magtype = currentarm.ammotype;
							bool ismagazine = (magtype is "hdmagammo");
							array<hdpowersuitarmpickup> inventoryarms;
							
							if (currentarm is "hdpowersuitblankarm")
							{
								inventory nextinventory = inv;
								
								while(nextinventory)
								{
									if (nextinventory is "hdpowersuitarmpickup")
									{
										inventoryarms.push(hdpowersuitarmpickup(nextinventory));
									}
									
									nextinventory = nextinventory.inv;
								}
							}
							
							if (invoker.selectedarm < inventoryarms.size() && invoker.selectedarm >= 0)
							{
								invoker.armitem = inventoryarms[invoker.selectedarm];
							}
							else if (inventoryarms.size() != 0)
							{
								invoker.selectedarm = invoker.valuechange(invoker.selectedarm, inventoryarms.size(), true);
								invoker.armitem = inventoryarms[invoker.selectedarm];
							}
							else
							{
								invoker.armitem = null;
							}
								
							if (player.cmd.buttons & BT_USER2)
							{
								if (invoker.justpressed(BT_ATTACK))
								{
									invoker.selectedarm = invoker.valuechange(invoker.selectedarm, inventoryarms.size(), true);
								}
								else if (invoker.justpressed(BT_ALTATTACK))
								{
									invoker.selectedarm = invoker.valuechange(invoker.selectedarm, inventoryarms.size(), false);
								}
								
								if (player.cmd.buttons & BT_RELOAD)
								{
									if (currentarm is "hdpowersuitblankarm" &&
										invoker.armitem && invoker.suitcore.hasarms)
									{
										invoker.actiontime = 175;
										invoker.actionmessage = "Mounting "..
											invoker.armitem.gettag();
											
										if (invoker.actionprogress >= invoker.actiontime)
										{
											hdpowersuitarm newarm = hdpowersuitarm(spawn(invoker.armitem.armtype, currentarm.pos));
											
											newarm.isleft = currentarm.isleft;
											newarm.handlemountammo(invoker.armitem, playerpawn(self));
											newarm.suitcore = invoker.suitcore;
											
											currentarm.destroy();
											if (isleftarm)
											{
												invoker.suitcore.torso.leftarm = newarm;
											}
											else
											{
												invoker.suitcore.torso.rightarm = newarm;
											}
											
											newarm.a_startsound("misc/w_pkup", CHAN_WEAPON);
											
											//this has been moved to handlemountammo
											//takeinventory(invoker.armitem.getclassname(), 1);
											invoker.resetaction();
										}
										else
										{
											invoker.actionprogress++;
										}
									}
									else
									{
										if (invoker.justpressed(BT_RELOAD))
										{
											if (!invoker.suitcore.hasarms)
											{
												a_print("There's no arms to mount that on.");
											}
											else if (!(currentarm is "hdpowersuitblankarm"))
											{
												a_print("There's already a weapon mounted here.");
											}
											else if (!invoker.armitem)
											{
												a_print("You don't have any weapons to mount.");
											}
										}
										
										invoker.actiontime = -1;
									}
								}
								else if (player.cmd.buttons & BT_USER4)
								{
									if (!(currentarm is "hdpowersuitblankarm"))
									{
										invoker.actiontime = 175;
										invoker.actionmessage = "Dismounting "..
											currentarm.gettag();
											
										if (invoker.actionprogress >= invoker.actiontime)
										{
											array<int> wepstatdata;
											wepstatdata.resize(32);
											currentarm.spawndroppedarm(wepstatdata);
											hdpowersuitarmpickup droppedarm = hdpowersuitarmpickup(spawn(currentarm.droppeditemname, invoker.suitcore.pos));
											for (int i = 0; i < 32; i++)
											{
												droppedarm.weaponstatus[i] = wepstatdata[i];
											}
											
											droppedarm.angle = invoker.suitcore.torso.angle;
											droppedarm.a_changevelocity(3, 0, 0, CVF_RELATIVE);
											
											hdpowersuitarm blankarm = hdpowersuitarm(spawn("hdpowersuitblankarm", currentarm.pos));
											blankarm.isleft = currentarm.isleft;
											currentarm.destroy();
											
											if (isleftarm)
											{
												invoker.suitcore.torso.leftarm = blankarm;
											}
											else
											{
												invoker.suitcore.torso.rightarm = blankarm;
											}
											
											blankarm.a_startsound("misc/w_pkup", CHAN_WEAPON);
											
											invoker.resetaction();
										}
										else
										{
											if (invoker.justpressed(BT_USER4))
											{
												if (currentarm is "hdpowersuitblankarm")
												{
													a_print("There's no weapon here.");
												}
											}
											
											invoker.actionprogress++;
										}
									}
									else
									{
										invoker.actiontime = -1;
									}
								}
								else
								{
									invoker.resetaction();
								}
							}
							else if (player.cmd.buttons & BT_RELOAD || 
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
									invoker.actionmessage = (usealtammo ? "Alt. " : "").."Reloading "..
										(isleftarm ? "left " : "right ").."arm";
										
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
										
										invoker.suitcore.a_startsound(currentarm.getloadsound(false, usealtammo), CHAN_WEAPON);
									
										invoker.resetaction();
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
										if (currentarm is "hdpowersuitblankarm")
										{
											a_print("There's no weapon here.");
										}
										else if (!currentarm.checkload(usealtammo))
										{
											a_print("There's no room for any more "..
												(usealtammo ? "alt. " : "").."ammo.");
										}
										else if (!magammo && !nonmagammo)
										{
											if (usealtammo)
											{
												a_print("You don't have any alternate ammo.");
											}
											else
											{
												a_print("You don't have any ammo.");
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
									invoker.actionmessage = (usealtammo ? "Alt. " : "").."Unloading "..
										(isleftarm ? "left " : "right ").. "arm";
										
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
										
										invoker.suitcore.a_startsound(currentarm.getloadsound(true, usealtammo), CHAN_WEAPON);
									
										invoker.resetaction();
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
											a_print("There's no weapon here.");
										}
										else if (!currentarm.checkunload(usealtammo))
										{
											a_print("There's no "..
												(usealtammo ? "alt. " : "").."ammo left in this.");
										}
									}
									
									invoker.actiontime = -1;
								}
							}
							else
							{
								invoker.resetaction();
							}
						}
						break;
						
					case SUIT_BATTERY:
						int battnum = 0;
						if (player.cmd.buttons & BT_USER2)
						{
							battnum = 1;
						}
						else if (player.cmd.buttons & BT_USER1)
						{
							battnum = 2;
						}
						
						if (player.cmd.buttons & BT_RELOAD || 
							(player.cmd.buttons & BT_USER1 && !(player.cmd.buttons & BT_USER4)))
						{
							if (invoker.suitcore.batteries[battnum] < 0 && countinv("hdbattery"))
							{
								invoker.actiontime = 70;
								invoker.actionmessage = "Loading "..
									((battnum == 2) ? "shield battery" : 
									("battery "..(battnum + 1)));
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									let battery = hdmagammo(findinventory("hdbattery"));
									if (battery)
									{
										invoker.suitcore.batteries[battnum] = battery.takemag(true);
									}
									
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else
							{
								if (invoker.justpressed(BT_RELOAD) || invoker.justpressed(BT_USER1))
								{
									if (invoker.suitcore.batteries[battnum] >= 0)
									{
										a_print("This slot already has a battery.");
									}
									else if (!countinv("hdbattery"))
									{
										a_print("You don't have any batteries.");
									}
								}
								
								invoker.actiontime = -1;
							}
						}
						else if (player.cmd.buttons & BT_USER4)
						{
							if (invoker.suitcore.batteries[battnum] >= 0)
							{
								invoker.actiontime = 70;
								invoker.actionmessage = "Unloading "..
									((battnum == 2) ? "shield battery" : 
									("battery "..(battnum + 1)));
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									hdmagammo.givemag(self, "hdbattery", invoker.suitcore.batteries[battnum]);
									invoker.suitcore.batteries[battnum] = -1;
									
									invoker.resetaction();
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
									if (invoker.suitcore.batteries[battnum] < 0)
									{
										a_print("There's no battery in that slot.");
									}
								}
								invoker.actiontime = -1;
							}
						}
						else
						{
							invoker.resetaction();
						}
						break;
						
					case SUIT_ARMOR:
						if (player.cmd.buttons & BT_RELOAD)
						{
							let armorvar = hdarmour(findinventory("hdarmour"));
							
							if (invoker.suitcore.suitarmor.durability < invoker.suitcore.maxarmor && armorvar && armorvar.mega)
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Repairing armor";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									if (armorvar)
									{
										int amount = armorvar.takemag(true);
										invoker.suitcore.suitarmor.durability = min(invoker.suitcore.suitarmor.durability + 
											max(random(amount - 5, amount - 15), 0), invoker.suitcore.maxarmor);
									}
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else
							{
								if (invoker.justpressed(BT_RELOAD))
								{
									if (invoker.suitcore.suitarmor.durability >= invoker.suitcore.maxarmor)
									{
										a_print("No need to repair.");
									}
									else if (!armorvar || !armorvar.mega)
									{
										a_print("You don't have any battle armor.");
									}
								}
								
								invoker.actiontime = -1;
							}
						}
						else
						{
							invoker.resetaction();
						}
						break;
					
					case SUIT_INTEGRITY:
						if (player.cmd.buttons & BT_RELOAD)
						{
							if (invoker.suitcore.integrity < invoker.suitcore.maxintegrity && invoker.suitcore.repairparts > 0)
							{
								invoker.actiontime = 105;
								invoker.actionmessage = "Repairing integrity";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									invoker.suitcore.integrity = min(invoker.suitcore.integrity + random(5, 7), invoker.suitcore.maxintegrity);
									invoker.suitcore.repairparts = max(invoker.suitcore.repairparts - random(2, 5), 0);
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else
							{
								if (invoker.justpressed(BT_RELOAD))
								{
									if (invoker.suitcore.integrity >= invoker.suitcore.maxintegrity)
									{
										a_print("No need to repair.");
									}
									else if (invoker.suitcore.repairparts <= 0)
									{	
										a_print("You're out of parts.");
									}
								}
								
								invoker.resetaction();
							}
						}
						else if (player.cmd.buttons & BT_USER4)
						{
							let herpvar = herpusable(findinventory("herpusable"));
							
							if (invoker.suitcore.repairparts < invoker.suitcore.maxparts && herpvar)
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Disassembling HERP";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									if (herpvar)
									{
										let spares = spareweapons(findinventory("spareweapons"));
										int herpstatus = herpvar.weaponstatus[0];
										bool usespare = false;
										int sparenumber;
										
										if (spares)
										{
											for (int i = 0; i < spares.weapontype.size(); i++)
											{
												if (spares.weapontype[i] == "herpusable")
												{
													usespare = true;
													sparenumber = i;
													herpstatus = spares.getweaponvalue(i, 0);
													
													break;
												}
											}
										}
										
										string disassemblestring = "";
										
										if (herpstatus & HERPF_BROKEN)
										{
											invoker.suitcore.repairparts += random(10, 20);
											disassemblestring = disassemblestring.."A lot of parts in that H.E.R.P. were damaged...\n\n";
										}
										else
										{
											invoker.suitcore.repairparts += random(20, 30);
										}
										
										if (invoker.suitcore.repairparts > invoker.suitcore.maxparts)
										{
											invoker.suitcore.repairparts = invoker.suitcore.maxparts;
											
											disassemblestring = disassemblestring.."There wasn't enough storage for all the parts, so you threw some away.\n\n";
										}
										
										bool herphadstuff = false;
										for (int i = 0; i < 3; i++)
										{
											if (usespare && spares.getweaponvalue(sparenumber, HERP_MAG1 + i) > 0)
											{
												int inmag = spares.getweaponvalue(sparenumber, HERP_MAG1 + i);
												
												if (inmag > 100)
												{
													inmag -= 100;
												}
												
												hdmagammo.givemag(self, "hd4mmag", inmag);
												herphadstuff = true;
											}
											else if (herpvar.weaponstatus[HERP_MAG1 + i] > 0)
											{
												int inmag = herpvar.weaponstatus[HERP_MAG1 + i];
												
												if (inmag > 100)
												{
													inmag -= 100;
												}
												
												hdmagammo.givemag(self, "hd4mmag", inmag);
												herphadstuff = true;
											}
										}
										
										if (usespare && spares.getweaponvalue(sparenumber, HERP_BATTERY))
										{
											hdmagammo.givemag(self, "hdbattery", spares.getweaponvalue(sparenumber, HERP_BATTERY));
											herphadstuff = true;
										}
										else if (herpvar.weaponstatus[HERP_BATTERY] > 0)
										{
											hdmagammo.givemag(self, "hdbattery", herpvar.weaponstatus[HERP_BATTERY]);
											herphadstuff = true;
										}
										
										if (herphadstuff)
										{
											disassemblestring = disassemblestring.."The H.E.R.P. had ammo in it, so you put that in your pockets.";
										}
										
										if (disassemblestring != "")
										{
											a_print(disassemblestring);
										}
										
										if (usespare)
										{
											spares.weaponbulk.delete(sparenumber);
											spares.weapontype.delete(sparenumber);
											spares.weaponstatus.delete(sparenumber);
										}
										else
										{
											a_takeinventory("herpusable", 1);
										}
									}
									
									invoker.resetaction();
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
									if (invoker.suitcore.repairparts >= invoker.suitcore.maxparts)
									{
										a_print("That's enough parts for now.");
									}
									else if (!herpvar)
									{
										a_print("You don't have any H.E.R.P. bots.");
									}
								}
								
								invoker.actiontime = -1;
							}
						}
						else
						{
							invoker.resetaction();
						}
						break;
						
					case SUIT_PARTS:
						if (player.cmd.buttons & BT_RELOAD)
						{
							if (!invoker.suitcore.hasarms
								&& findinventory("hdpowersuitbotharmspickup"))
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Attaching arms";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									invoker.suitcore.hasarms = true;
									takeinventory("hdpowersuitbotharmspickup", 1);
									
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else if (!invoker.suitcore.haslegs
								&& findinventory("hdpowersuitlegspickup")
								&& player.cmd.buttons & BT_USER2)
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Attaching legs";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									invoker.suitcore.haslegs = true;
									takeinventory("hdpowersuitlegspickup", 1);
									
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else
							{
								if (invoker.justpressed(BT_RELOAD))
								{
									if (invoker.suitcore.hasarms)
									{
										a_print("There's no need to attach arms.");
									}
									else if (invoker.suitcore.haslegs && player.cmd.buttons & BT_USER2)
									{
										a_print("There's no need to attach legs.");
									}
									else if (!(findinventory("hdpowersuitbotharmspickup")))
									{
										a_print("You don't have a pair of powersuit arms.");
									}
									else if (!(findinventory("hdpowersuitlegspickup")) && player.cmd.buttons & BT_USER2)
									{
										a_print("You don't have a pair of powersuit legs.");
									}
								}
								
								invoker.actiontime = -1;
							}
						}
						else if (player.cmd.buttons & BT_USER4)
						{
							if (invoker.suitcore.haslegs && player.cmd.buttons & BT_USER2
								&& !(invoker.suitcore.driver && self != invoker.suitcore.driver))
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Removing legs";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									invoker.suitcore.haslegs = false;
									hdpowersuitlegspickup legs = hdpowersuitlegspickup(spawn("hdpowersuitlegspickup", invoker.suitcore.pos));
									legs.angle = invoker.suitcore.torso.angle;
									legs.a_changevelocity(3, 0, 0, CVF_RELATIVE);
									legs.translation = invoker.suitcore.torso.translation;
									
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else if (invoker.suitcore.hasarms &&
								(invoker.suitcore.torso.leftarm is "hdpowersuitblankarm" &&
								invoker.suitcore.torso.rightarm is "hdpowersuitblankarm") &&
								!(player.cmd.buttons & BT_USER2)
								&& !(invoker.suitcore.driver && self != invoker.suitcore.driver))
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Removing arms";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									invoker.suitcore.hasarms = false;
									hdpowersuitbotharmspickup arms = hdpowersuitbotharmspickup(spawn("hdpowersuitbotharmspickup", invoker.suitcore.pos));
									arms.angle = invoker.suitcore.torso.angle;
									arms.a_changevelocity(3, 0, 0, CVF_RELATIVE);
									arms.translation = invoker.suitcore.torso.translation;
									
									invoker.resetaction();
								}
								else
								{
									invoker.actionprogress++;
								}
							}
							else if (!invoker.suitcore.haslegs && !invoker.suitcore.hasarms &&
								!(player.cmd.buttons & BT_USER2))
							{
								invoker.actiontime = 350;
								invoker.actionmessage = "Packing up chassis";
								
								if (invoker.actionprogress >= invoker.actiontime)
								{
									hdpowersuitcorepickup droppeditem = hdpowersuitcorepickup(spawn("hdpowersuitcorepickup", invoker.suitcore.pos));
									droppeditem.vel.z += 3;
									droppeditem.integrity = invoker.suitcore.integrity;
									droppeditem.armordurability = invoker.suitcore.suitarmor.durability;
									droppeditem.batteries[0] = invoker.suitcore.batteries[0];
									droppeditem.batteries[1] = invoker.suitcore.batteries[1];
									droppeditem.batteries[2] = invoker.suitcore.batteries[2];
									droppeditem.repairparts = invoker.suitcore.repairparts;
									droppeditem.translation = invoker.suitcore.torso.translation;
									
									invoker.suitcore.torso.leftleg.destroy();
									invoker.suitcore.torso.rightleg.destroy();
									invoker.suitcore.torso.leftarm.destroy();
									invoker.suitcore.torso.rightarm.destroy();
									invoker.suitcore.torso.destroy();
									invoker.suitcore.destroy();
									
									takeinventory("hdpowersuiteditor", 1);
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
									if (invoker.suitcore.driver && self != invoker.suitcore.driver)
									{
										a_print("You can't do that while the driver is still inside.");
									}
									else if (!invoker.suitcore.hasarms && !(player.cmd.buttons & BT_USER2))
									{
										a_print("There's no arms to remove.");
									}
									else if (!invoker.suitcore.haslegs && player.cmd.buttons & BT_USER2)
									{
										a_print("There's no legs to remove.");
									}
									else if (invoker.suitcore.hasarms &&
										(!(invoker.suitcore.torso.leftarm is "hdpowersuitblankarm") ||
										!(invoker.suitcore.torso.rightarm is "hdpowersuitblankarm")))
									{
										a_print("There's still weapons mounted. Remove them first.");
									}
								}
								
								invoker.actiontime = -1;
							}
						}
						else
						{
							invoker.resetaction();
						}
						break;
				}
			}
			loop;
	}
}
