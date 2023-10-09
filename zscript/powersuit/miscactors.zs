const ENC_POWERSUITPART = 200;

class HDPowersuitTorso : hdactor
{
	hdpowersuitarm leftarm, rightarm;
	hdpowersuitleg leftleg, rightleg;
	playerpawn driver;
	actor aimpoint;
	hdpowersuit suitcore;
	
	default
	{
		+nointeraction
		species "hdpowersuit";
		scale 0.8;
	}
	
	override void tick()
	{		
		if (leftleg)
		{
			leftleg.warp(suitcore, 0 - (leftleg.frame * 1), -8, 0, suitcore.angle,
				WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION | WARPF_ABSOLUTEANGLE);
		}
			
		if (rightleg)
		{
			rightleg.warp(suitcore, 0 - (rightleg.frame * 1), 8, 0, suitcore.angle,
				WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION | WARPF_ABSOLUTEANGLE);
		}
			
		if (suitcore.driver && suitcore.checkusable())
		{
			flinetracedata tracedata;
			linetrace(suitcore.driver.angle, 65535, suitcore.driver.pitch, TRF_THRUSPECIES, 32, 32, 0, tracedata);
			aimpoint.setorigin(tracedata.hitlocation, true);
			
			if (leftarm)
			{
				leftarm.target = aimpoint;
			}
			
			if (rightarm)
			{
				rightarm.target = aimpoint;
			}
		}
		
		if (suitcore.driver && suitcore.driver == players[consoleplayer].camera
			&& !(players[consoleplayer].cheats & CF_CHASECAM))
		{
			a_setrenderstyle(1.0, STYLE_NONE);
		}
		else
		{
			a_setrenderstyle(1.0, STYLE_NORMAL);
		}
		
		super.tick();
	}
	
	states
	{
		spawn:
			PSTO A 1
			{
				if (suitcore.hasarms)
				{
					frame = 0;
				}
				else
				{
					frame = 1;
				}
			}
			loop;
	}
}

class HDPowersuitLeg : hdactor
{
	hdpowersuit suitcore;
	bool isleft;
	bool stomped;
	
	default
	{
		+nointeraction;
		+forceybillboard;
	}
	
	states
	{
		spawn:
			TNT1 A 0 nodelay
			{
				if (isleft)
				{
					setstatelabel("leftlegstill");
				}
				else
				{
					setstatelabel("rightlegstill");
				}
			}
		
		leftlegstill:
			PLGA A 1
			{
				stomped = false;
				
				if (!suitcore.haslegs)
				{
					setstatelabel("leftlegnope");
				}
				else if (suitcore.stepfrequency > 0)
				{
					setstatelabel("leftlegwalk");
				}
			}
			loop;
			
		leftlegwalk:
			PLGA A 1
			{
				if (suitcore.stepfrequency <= 0)
				{
					setstatelabel("leftlegstill");
				}
				
				for (int i = 0; i < 8; i++)
				{
					if (suitcore.nextstep >= i * (suitcore.stepfrequency / 4.0))
					{
						if (suitcore.speed >= 0)
						{
							frame = i / 2;
						}
						else
						{
							frame = 3 - i / 2;
						}
					}
				}
				
				int stompframe, raiseframe;
				
				if (suitcore.speed >= 0)
				{
					stompframe = 0;
					raiseframe = 3;
				}
				else
				{
					stompframe = 2;
					raiseframe = 1;
				}
				
				if (frame == stompframe && !stomped)
				{
					a_startsound("mech/stomp", CHAN_BODY, 0, 1.0);
					stomped =  true;
				}
				else if (frame == raiseframe && stomped)
				{
					a_startsound("mech/legwhir", CHAN_BODY, CHANF_OVERLAP, 0.3, ATTN_NORM, 1.0);
					stomped = false;
				}
				
				if (!suitcore.driver)
				{
					frame = 0;
				}
			}
			loop;
			
		leftlegnope:
			TNT1 A 1
			{
				if (suitcore.haslegs)
				{
					setstatelabel("leftlegstill");
				}
			}
			loop;
			
		rightlegstill:
			PLGB C 1
			{
				if (!suitcore.haslegs)
				{
					setstatelabel("rightlegnope");
				}
				else if (suitcore.stepfrequency > 0)
				{
					setstatelabel("rightlegwalk");
				}
			}
			loop;
			
		rightlegwalk:
			PLGB A 1
			{
				if (suitcore.stepfrequency <= 0)
				{
					setstatelabel("rightlegstill");
				}
				
				for (int i = 0; i < 8; i++)
				{
					if (suitcore.nextstep >= i * (suitcore.stepfrequency / 4.0))
					{
						if (suitcore.speed >= 0)
						{
							frame = i / 2;
						}
						else
						{
							frame = 3 - i / 2;
						}
					}
				}
				
				int stompframe, raiseframe;
				
				if (suitcore.speed >= 0)
				{
					stompframe = 2;
					raiseframe = 1;
				}
				else
				{
					stompframe = 0;
					raiseframe = 3;
				}
				
				if (frame == stompframe && !stomped)
				{
					a_startsound("mech/stomp", CHAN_BODY, 0, 1.0);
					stomped =  true;
				}
				else if (frame == raiseframe && stomped)
				{
					a_startsound("mech/legwhir", CHAN_BODY, CHANF_OVERLAP, 0.3, ATTN_NORM, 1.0);
					stomped = false;
				}
				
				if (!suitcore.driver)
				{
					frame = 2;
				}
			}
			loop;
			
		rightlegnope:
			TNT1 A 1
			{
				if (suitcore.haslegs)
				{
					setstatelabel("rightlegstill");
				}
			}
			loop;
	}
}

//specifically, this is for the arms, not the weapons
class HDPowersuitBothArmsPickup : hdpickup
{
	default
	{
		scale 0.6;
		tag "Powersuit arms";
		inventory.pickupmessage "Picked up a pair of powersuit arms.";
		-inventory.invbar;
		hdpickup.bulk ENC_POWERSUITPART;
		-hdpickup.fitsinbackpack;
	}
	
	states
	{
		spawn:
			PARM Z -1;
			stop;
	}
}

class HDPowersuitLegsPickup : hdpickup
{
	default
	{
		scale 0.6;
		
		tag "Powersuit legs";
		inventory.pickupmessage "Picked up a pair of powersuit legs.";
		-inventory.invbar;
		hdpickup.bulk ENC_POWERSUITPART;
		-hdpickup.fitsinbackpack;
	}
	
	states
	{
		spawn:
			PLGS Z -1;
			stop;
	}
}

class hdpowersuitcorepickup : hdpickup
{
	int integrity;
	int armordurability;
	int batteries[3];
	int repairparts;
	int armorplates;
	
	default
	{
		scale 0.5;
		inventory.maxamount 1;
		tag "Powersuit chassis";
		inventory.pickupmessage "Picked up a powersuit chassis.";
		hdpickup.bulk ENC_POWERSUITPART;
		-hdpickup.fitsinbackpack;
	}
	
	states
	{
		spawn:
			PSTO Z -1;
			stop;
			
		use:
			TNT1 A 0
			{
				hdpowersuit suit = hdpowersuit(spawn("hdpowersuit", (pos.x + cos(angle) * 42.0, pos.y + sin(angle) * 42.0, pos.z)));
				
				if (suit.checkposition((suit.pos.x, suit.pos.y)))
				{
					suit.angle = angle;
					suit.torso.angle = angle;
					suit.integrity = invoker.integrity;
					suit.batteries[0] = invoker.batteries[0];
					suit.batteries[1] = invoker.batteries[1];
					suit.batteries[2] = invoker.batteries[2];
					suit.repairparts = invoker.repairparts;
					suit.armorplates = invoker.armorplates;
					suit.suitarmor.durability = invoker.armordurability;
					suit.torso.translation = translation;
					suit.torso.leftleg.translation = translation;
					suit.torso.rightleg.translation = translation;
					
					suit.hasarms = false;
					suit.haslegs = false;
					
					takeinventory("hdpowersuitcorepickup", 1);
				}
				else
				{
					a_log("There's no space there.", true);
					
					suit.torso.leftarm.destroy();
					suit.torso.rightarm.destroy();
					suit.torso.leftleg.destroy();
					suit.torso.rightleg.destroy();
					suit.torso.destroy();
					suit.destroy();
				}
			}
			fail;
	}
}
