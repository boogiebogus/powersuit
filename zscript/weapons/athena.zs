const HDLD_BRONTOARM = "pw3";

class HDPowersuitBrontoArm : hdpowersuitarm
{
	bool canrefire;
	actor scopecam;
	
	default
	{
		scale 0.7;
		
		hdpowersuitarm.maxmags 5;
		hdpowersuitarm.magsize 1;
		hdpowersuitarm.ammotype "brontornisround";
		hdpowersuitarm.reloadtime 40;
		hdpowersuitarm.droppeditemname "hdpowersuitbrontoarmpickup";
		
		tag '"Athena" light cannon';
	}
	
	override void postbeginplay()
	{
		canrefire = false;
		scopecam = spawn("hdpowersuitaimpoint", pos);
		
		super.postbeginplay();
	}
	
	override void tick()
	{
		scopecam.setorigin(pos + (cos(angle) * 4.0, sin(angle * 4.0), 8), true);
		scopecam.angle = angle;
		scopecam.pitch = pitch;
		
		super.tick();
	}
	
	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		texman.setcameratotexture(scopecam, (isleft ? "atencam1" : "atencam2"), 1.4);
		
		if (hpl.player.cmd.buttons & BT_ZOOM)
		{
			sb.drawimage((isleft ? "atencam1" : "atencam2"), ((isleft ? -128 : 128), 38), sb.DI_SCREEN_CENTER | sb.DI_ITEM_HCENTER | sb.DI_ITEM_TOP,
				scale: (0.46, 0.46));
				
			sb.drawimage("libscope", ((isleft ? -128 : 128), 28), sb.DI_SCREEN_CENTER | sb.DI_ITEM_HCENTER | sb.DI_ITEM_TOP,
				scale: (1.2, 1.2));
			sb.drawimage("rlret", ((isleft ? -128 : 128), 32), sb.DI_SCREEN_CENTER | sb.DI_ITEM_HCENTER | sb.DI_ITEM_TOP,
				scale: (1.4, 1.4));
		}
			
		super.drawhudstuff(sb, hdw, hpl);
	}
	
	override void ondestroy()
	{
		if (scopecam)
		{
			scopecam.destroy();
		}
		
		super.ondestroy();
	}	
	
	states
	{
		spawn:
			ATEN A 1
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
					if (checkmags() && canrefire)
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
			}
			loop;
			
		missile:
			ATEN C 3
			{
				if (isleft)
				{
					frame = 2;
				}
				else
				{
					frame = 5;
				}
				
				hdbulletactor.firebullet(self, "hdb_bronto", zofs: 8, speedfactor: 2.0);
				
				a_startsound("weapons/athena/fire", CHAN_WEAPON);
				a_startsound("weapons/athena/fire", CHAN_WEAPON, CHANF_OVERLAP);
				a_startsound("weapons/athena/fire2", CHAN_WEAPON, CHANF_OVERLAP);
				
				bool didspawn;
				actor casing;
				
				[didspawn, casing] = a_spawnitemex("terrorcasing", 0, 0, 8, frandom(-2, -3), 
					(isleft ? frandom(-3, -5) : frandom(3, 5)), 3, 0, SXF_NOCHECKPOSITION | SXF_TRANSFERPITCH);
					
				casing.translation = suitcore.driver.translation;
				
				for (int i = 0; i < 15; i++)
				{
					a_spawnparticle(color(32, 256, 256), SPF_FULLBRIGHT | SPF_RELATIVE, 
						45, 5, 0, 16, 0, 8, frandom(5, 15), frandom(-1, 1), frandom(-1, 1), -0.1, 0, 0,
						1.0, -1, -0.1);
						
					a_spawnparticle(color(256, 256, 256), SPF_FULLBRIGHT | SPF_RELATIVE, 
						25, 5, 0, 16, 0, 8, frandom(10, 25), frandom(-0.5, 0.5), frandom(-0.5, 0.5), -1.0, 0, 0,
						1.0, -1, -0.1);
				}
				
				if (suitcore.driver)
				{
					suitcore.driver.a_alertmonsters();
				}
				
				currentmag--;
				checkmags();
				canrefire = false;
			}
			ATEN BBBBBBBBBBBBBBBBBBBBBBBB 1
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				suitcore.partialcharge -= 35;
				
				a_spawnparticle(color(32, 256, 256), SPF_FULLBRIGHT | SPF_RELATIVE, 
					15, 5, 0, 16, 0, 8, frandom(1, 5), frandom(-1, 1), frandom(-1, 1), 0, 0, 0.3,
					1.0, -1, -0.1);
			}
			ATEN B 0
			{
				if (isleft)
				{
					frame = 1;
				}
				else
				{
					frame = 4;
				}
				
				a_startsound("weapons/rifleclick", CHAN_WEAPON, CHANF_OVERLAP);
				canrefire = false;
			}
			goto spawn;
	}
}

class HDPowersuitBrontoArmPickup : hdpowersuitarmpickup
{
	default
	{
		tag '"Athena" light cannon';
		inventory.pickupmessage 'Picked up an "Athena" mounted light cannon.';
		inventory.icon "ATENZ0";
		hdpowersuitarmpickup.armtype "hdpowersuitbrontoarm";
		hdweapon.refid HDLD_BRONTOARM;
	}
	
	override double weaponbulk()
	{
		return 200;
	}
	
	states
	{
		spawn:
			ATEN Z -1;
			stop;
	}
}
