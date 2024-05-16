const HDLD_FRAGLAU = "pa1";

class HDPowersuitFragLauncher : HDPowersuitShoulder
{
	bool burstmode;
	bool canrefire;
	int burstinterval;
	
	default
	{
		scale 0.7;
		
		hdpowersuitshoulder.maxmags 17;
		hdpowersuitshoulder.magsize 1;
		hdpowersuitshoulder.magtype "";
		hdpowersuitshoulder.ammotype "hdfraggrenadeammo";
		hdpowersuitshoulder.reloadtime 30;
		hdpowersuitshoulder.droppeditemname "hdpowersuitfraglauncherpickup";
		radius 8;
		height 14;
		
		tag 'GL-67 Frag Grenade Launcher';
	}

	override void A_Kaboom(bool forceexplosion)
	{
		if(!forceexplosion && !bIsExplosive)return;
		doordestroyer.destroydoor(self,42,frandom(3,16));

		//explosion
			A_GiveInventory("Heat",1000);
			A_SprayDecal("Scorch",16);
			A_HDBlast(
				pushradius:256,pushamount:128,fullpushradius:96,
				fragradius:HDCONST_ONEMETRE*(10+0.2*stamina),fragtype:"HDB_frag",
				immolateradius:128,immolateamount:random(3,60),
				immolatechance:25
			);
			actor xpl=spawn("Gyrosploder",pos-(0,0,1),ALLOW_REPLACE);
			xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			distantnoise.make(self,"world/rocketfar");
		A_SpawnChunksFrags("HDB_frag",180,0.8+0.05*stamina);
		if(suitcore.suitarmor.durability > 0)suitcore.suitarmor.durability-=random(25,50);
		else if(suitcore.integrity > 0)suitcore.integrity-=random(10,15);
	}
	
	override void tick(){
	super.tick();
	if(currentmag > 0)bIsExplosive = true;
	else bIsExplosive = false;
	}

	override void postbeginplay()
	{
		firemodestring = "SNGL";
		canrefire = true;
		
		super.postbeginplay();
	}
	
	override void changefiremode()
	{
		if (burstmode)
		{
			burstmode = false;
			firemodestring = "SNGL";
		}
		else
		{
			burstmode = true;
			firemodestring = "BRST";
		}
	}
	
	states
	{
		spawn:
			gl67 a 1
			{
			    if (isfiring && burstmode && burstinterval <= 0)return;
				if (!isfiring && burstmode && burstinterval <= 2)
					burstinterval=3;
				if (isfiring)
				{
					if (checkmags() && canrefire){
						setstatelabel("missile");
						}
					else
						isfiring = false;
				}else{ canrefire = true;
				isfiring = false;
				}
			}
			loop;
			
		missile:
			gl67 a 1
			{
				hdfraggrenade firedgrenade;

					firedgrenade = HDFragGrenade(spawn("HDFragGrenade", pos + (cos(angle) * 4, sin(angle) * 4, 8)));

					firedgrenade.angle = angle;
					firedgrenade.pitch = pitch;
					firedgrenade.vel=vel+(cos(pitch)*(cos(angle),sin(angle)),-sin(pitch))*30;

						firedgrenade.target = self;

					a_startsound("weapons/glfgl/fire", CHAN_WEAPON, CHANF_OVERLAP);
					if (suitcore.driver)
					{
						suitcore.driver.a_alertmonsters();
					}
					currentmag--;
					checkmags();
					if(burstinterval>0&&burstmode){
					burstinterval--;
					}else if (burstmode && burstinterval < 1) canrefire = false;
					
				
			}
			gl67 a 2;
			gl67 a 0
			{
				
				if (burstmode && burstinterval > 0 && canrefire)
				{
					setstatelabel("spawn");
				}
			}
			gl67 a 7;
			goto spawn;
	}
}

class HDPowersuitFragLauncherPickup : hdpowersuitshoulderpickup
{
	default
	{
		tag 'GL-67 Frag Grenade Launcher';
		inventory.pickupmessage 'Picked up a GL-67 Mounted Frag Grenade Launcher.';
		inventory.icon "GL67Z0";
		hdpowersuitshoulderpickup.shouldertype "hdpowersuitfraglauncher";
		hdweapon.refid HDLD_FRAGLAU;
	}
	
	override double weaponbulk()
	{
		return 153;
	}
	
	states
	{
		spawn:
		gl67 z -1;
			stop;
	}
}
