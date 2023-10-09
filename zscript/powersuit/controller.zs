class HDPowersuitInterface : nullweapon
{
	hdpowersuit suitcore;
	bool valid;
	bool crouched;
	double zoomamount;
	
	default
	{
		weapon.slotnumber 1;
		+inventory.undroppable;
		tag "Mongoose Powersuit";
		obituary "%o fell for %k's war crimes.";
	}
	
	override string gethelptext()
	{
		return WEPHELP_FIRE.."  Fire left gun\n"..
			WEPHELP_ALTFIRE.."  Fire right gun\n"..
			WEPHELP_FIREMODE.." + "..WEPHELP_FIRE.."  Change firemode (left)\n"..
			WEPHELP_FIREMODE.." + "..WEPHELP_ALTFIRE.."  Change firemode (right)\n"..
			WEPHELP_ZOOM.."  Zoom in\n"..
			WEPHELP_BTCOL.."Sprint"..WEPHELP_RGCOL.." + "..WEPHELP_USE.."  Stomp\n"..
			WEPHELP_BTCOL.."Crouch"..WEPHELP_RGCOL.." + "..WEPHELP_USE.."  Get out\n"..
			WEPHELP_BTCOL.."Jump"..WEPHELP_RGCOL.."  Jump jets\n"..
			WEPHELP_FIREMODE.. " + "..WEPHELP_RELOAD.."  Override emergency shutdown (If overheated)";
	}
	
	override void doeffect()
	{
		if (!suitcore)
		{
			//console.printf("%f", owner.pos.x);
			return;
		}
		
		if (suitcore.checkusable())
		{
			valid = true;
		}
		else
		{
			valid = false;
		}
		
		//i could shorten this, but hey - just in case!
		if (suitcore.driver.player.cmd.buttons & BT_CROUCH
			|| suitcore.driver.player.crouching < 0)
		{
			crouched = true;
		}
		else
		{
			crouched = false;
		}
		
		suitcore.driver.player.cmd.buttons &=~ BT_CROUCH;
		
		super.doeffect();
	}
	
	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		if (!suitcore)
		{
			return;
		}
		
		if (valid)
		{
			//torso angle
			sb.drawrect(0, -52, (suitcore.torso.angle - suitcore.angle) / -4, -4);
			
			//thrusters
			sb.drawrect(-24, -12, -4, float(suitcore.thrusterfuel / float(suitcore.maxfuel)) * -32);
			
			sb.drawrect(-24, -10, -3, 1);
			sb.drawrect(-25, -9, -1, 4);
			
			//heat
			if (suitcore.suitheat < suitcore.maxheat)
			{
				sb.drawrect(-32, -12, -4, -32 
					+ max(min(float(suitcore.suitheat / float(suitcore.maxheat))* 32, 32), 0));
			}
			else
			{
				sb.fill(color(255, 255, 255, 0), -32, -12, -4, max(float((suitcore.suitheat - suitcore.maxheat) / float(suitcore.maxheat))* -32, -32), 
					sb.DI_SCREEN_CENTER_BOTTOM);
			}
			
			if (suitcore.suitheat > suitcore.maxheat * 2)
			{
				sb.fill(color(255, 255, 0, 0), -32, -12, -4, max(float((suitcore.suitheat - (suitcore.maxheat * 2)) / float(suitcore.maxheat))* -32, -32), 
					sb.DI_SCREEN_CENTER_BOTTOM);
			}
			
			sb.drawrect(-32, -10, -1, 5);
			sb.drawrect(-33, -8, -1, 1);
			sb.drawrect(-34, -10, -1, 5);
			
			//left arm
			if (suitcore.torso.leftarm && !(suitcore.torso.leftarm is "hdpowersuitblankarm"))
			{
				suitcore.torso.leftarm.drawhudstuff(sb, hdw, hpl);
			}
			
			//right arm
			if (suitcore.torso.rightarm && !(suitcore.torso.rightarm is "hdpowersuitblankarm"))
			{
				suitcore.torso.rightarm.drawhudstuff(sb, hdw, hpl);
			}
			
			//armor
			if (suitcore.suitarmor)
			{
				sb.drawrect(24, -12, 4, float(suitcore.suitarmor.durability / float(suitcore.maxarmor)) * -32);
			}
			
			sb.drawrect(24, -9, 1, 4);
			sb.drawrect(25, -10, 1, 1);
			sb.drawrect(25, -8, 1, 1);
			sb.drawrect(26, -9, 1, 4);
			
			//shields
			if (suitcore.suitshield)
			{
				sb.drawrect(32, -12, 4, max(float(suitcore.suitshield.amount / float(suitcore.maxshields)), 0) * -32);
			}
			
			sb.drawrect(33, -10, 2, 1);
			sb.drawrect(32, -9, 1, 1);
			sb.drawrect(33, -8, 1, 1);
			sb.drawrect(34, -7, 1, 1);
			sb.drawrect(32, -6, 2, 1);
			
			//warnings
			int warningoffset = 8;
			
			//override
			if (suitcore.shutdownoverride)
			{
				sb.drawstring(sb.psmallfont, "! Shutdown override active !", (0, warningoffset), 
					sb.DI_SCREEN_TOP | sb.DI_SCREEN_HCENTER | sb.DI_TEXT_ALIGN_CENTER, font.CR_RED);
				
				warningoffset += 8;
			}
			
			//battery warning
			if ((suitcore.batteries[0] * suitcore.partialchargemax) +
				(suitcore.batteries[1] * suitcore.partialchargemax) +
				(suitcore.partialcharge) < 35 * 60 * 5)
			{
				int chargetics = (max(suitcore.batteries[0], 0) * suitcore.partialchargemax) +
				(max(suitcore.batteries[1], 0) * suitcore.partialchargemax) +
				(suitcore.partialcharge);
				
				int minutes, seconds, milliseconds;
				minutes = chargetics / (60 * 35);
				chargetics %= (60 * 35);
				seconds = chargetics / 35;
				chargetics %= 35;
				milliseconds = int((chargetics / 35.0) * 100);
				
				sb.drawstring(sb.psmallfont, "! Charge remaining: "..
					sb.formatnumber(minutes, 1, 2, sb.FNF_FILLZEROS)..
					sb.formatnumber(seconds, 2, 2, sb.FNF_FILLZEROS, ":")..
					sb.formatnumber(milliseconds, 2, 2, sb.FNF_FILLZEROS, ":").." !", 
					(0, warningoffset), sb.DI_SCREEN_TOP | sb.DI_SCREEN_HCENTER | sb.DI_TEXT_ALIGN_CENTER,
					(minutes > 0) ? font.CR_GRAY : font.CR_RED);
				
				warningoffset += 8;
			}
			
			//shield battery warning
			if (suitcore.batteries[2] < 4 && 
				(suitcore.batteries[2] >= 0 || (suitcore.batteries[2] == 0 && suitcore.partialshieldcharge > 0)))
			{
				sb.drawstring(sb.psmallfont, "! Low shield battery !", (0, warningoffset), 
					sb.DI_SCREEN_TOP | sb.DI_SCREEN_HCENTER | sb.DI_TEXT_ALIGN_CENTER, font.CR_RED);
				
				warningoffset += 8;
			}
			
			//integrity
			if (suitcore.integrity < 25)
			{
				sb.drawstring(sb.psmallfont, "! Low integrity !", (0, warningoffset), 
					sb.DI_SCREEN_TOP | sb.DI_SCREEN_HCENTER | sb.DI_TEXT_ALIGN_CENTER, font.CR_RED);
				
				warningoffset += 8;
			}
			
			//heat
			if (suitcore.suitheat > ((suitcore.maxheat * 2) + 1) && !suitcore.shutdownoverride)
			{
				sb.drawstring(sb.psmallfont, "! Heat critical !", (0, warningoffset), 
					sb.DI_SCREEN_TOP | sb.DI_SCREEN_HCENTER | sb.DI_TEXT_ALIGN_CENTER, font.CR_RED);
				
				warningoffset += 8;
			}
		}
		else
		{
			sb.fill(color(255, 0, 0, 0), 0, 0, 1920, 1080);
			
			if (suitcore.integrity <= 0)
			{
				sb.drawstring(sb.psmallfont, "\cgINTEGRITY FAILURE",
					(0, 0), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
			}
			else if (suitcore.overheated && ((suitcore.batteries[0] + suitcore.batteries[1]) > 0) && !suitcore.shutdownoverride){
				sb.drawstring(sb.psmallfont, "\cgEMERGENCY SHUTDOWN. OVERHEATED",
					(0, 0), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
			}
			else
			{
				sb.drawstring(sb.psmallfont, "\cgNO BATTERY",
					(0, 0), sb.DI_SCREEN_CENTER | sb.DI_TEXT_ALIGN_CENTER);
			}
		}
	}
	
	override void modifydamage(int damage, name damagetype, out int newdamage,
		bool passive, actor inflictor, actor source, int flags)
	{
		if (damagetype == "melee" || damagetype == "claws"
			|| source is "babuin" || damagetype == "teeth"
			|| damagetype == "jointlock")
		{
			newdamage = 0;
		}
		
		if (damagetype == "falling")
		{
			newdamage = damage / 4;
		}
		
		if (damagetype == "hot")
		{
			newdamage = damage / 2;
		}
		
		if (damagetype == "electrical")
		{
			newdamage = damage / 3;
			suitcore.suitheat += damage * 24;
		}
		
		if (damagetype == "piercing" && !(inflictor == suitcore))
		{
			newdamage = 0;
		}
		
		super.modifydamage(damage, damagetype, newdamage, passive, inflictor, source, flags);
	}
	states
	{
		ready:
			TNT1 A 1 
			{
				//A_SetHelpText();
				a_weaponready(WRF_NOFIRE | WRF_NOSECONDARY | WRF_NOSWITCH | WRF_ALLOWZOOM);
				
				if (player.cmd.buttons & BT_ZOOM && invoker.zoomamount < 3.0)
				{
					invoker.zoomamount += 0.2;
				}
				else if (!(player.cmd.buttons & BT_ZOOM) && invoker.zoomamount > 0.0)
				{
					invoker.zoomamount -= 0.2;
				}
				
				if (invoker.zoomamount < 0.0)
				{
					invoker.zoomamount = 0.0;
				}
				
				a_zoomfactor(1.0 + invoker.zoomamount, ZOOM_INSTANT);
				
				if (player.cmd.buttons & BT_USER2){
					if (invoker.suitcore.justpressed(BT_RELOAD) && invoker.suitcore.overheated){
						invoker.suitcore.shutdownoverride=true;
						invoker.suitcore.a_startsound("mech/powerup", 0, CHANF_OVERLAP);
					}
				}
				if (invoker.suitcore.checkusable())
				{
					if (player.cmd.buttons & BT_USER2)
					{
						if (invoker.suitcore.justpressed(BT_ATTACK) && invoker.suitcore.torso.leftarm)
						{
							invoker.suitcore.torso.leftarm.changefiremode();
						}
						
						if (invoker.suitcore.justpressed(BT_ALTATTACK) && invoker.suitcore.torso.rightarm)
						{
							invoker.suitcore.torso.rightarm.changefiremode();
						}
						if (invoker.suitcore.justpressed(BT_ATTACK) && invoker.suitcore.overheated && !invoker.suitcore.shutdownoverride){
							invoker.suitcore.shutdownoverride=true;
							invoker.suitcore.a_startsound("mech/powerup", 0, CHANF_OVERLAP);
						}
					}
					else
					{
						if (player.cmd.buttons & BT_ATTACK && invoker.suitcore.torso.leftarm)
						{
							invoker.suitcore.torso.leftarm.isfiring = true;
						}
						else
						{
							invoker.suitcore.torso.leftarm.isfiring = false;
						}
						
						if (player.cmd.buttons & BT_ALTATTACK && invoker.suitcore.torso.rightarm)
						{
							invoker.suitcore.torso.rightarm.isfiring = true;
						}
						else
						{
							invoker.suitcore.torso.rightarm.isfiring = false;
						}
					}
				}
			}
			loop;
	}
}
