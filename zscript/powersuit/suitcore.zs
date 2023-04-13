class HDPowersuit : hdactor
{
	playerpawn driver;
	hdpowersuittorso torso;
	hdpowersuitinterface interface;
	double targetangle;
	bool canrethrust;
	double thrustpower;
	double targetspeed;
	int thrusterfuel;
	int stepfrequency, nextstep, bobstep;
	int stomptics;
	int suitheat, heatdamagetic;
	vector3 lastvel;
	double viewz;
	hdpowersuitarmor suitarmor;
	hdmagicshield suitshield;
	int integrity;
	int[3] batteries;
	int partialcharge, partialshieldcharge;
	int repairparts;
	bool hasarms, haslegs;
	
	int maxviewrotation;
	int maxtorsorotation;
	double maxarmrotation;
	double torsorotationspeed;
	double armrotationspeed;
	double acceleration;
	int maxfuel;
	int maxheat;
	int maxarmor;
	int maxshields;
	int maxintegrity;
	int partialchargemax;
	int maxparts;
	double turnspeed;
	
	property maxviewrotation : maxviewrotation;
	property maxtorsorotation : maxtorsorotation;
	property maxarmrotation : maxarmrotation;
	property torsorotationspeed : torsorotationspeed;
	property armrotationspeed : armrotationspeed;
	property acceleration : acceleration;
	property maxfuel : maxfuel;
	property maxheat : maxheat;
	property maxarmor : maxarmor;
	property maxshields : maxshields;
	property maxintegrity : maxintegrity;
	property partialchargemax : partialchargemax;
	property maxparts : maxparts;
	property turnspeed : turnspeed;
	
	default
	{
		+solid
		+shootable
		+noblockmonst
		+nofriction
		+slidesonwalls
		+invulnerable
		+noblood
		//+invisible
		+dropoff
		+blockasplayer
		+canpass
		+friendly
		+ismonster
		species "hdpowersuit";
		mass 500;
		radius 18;
		height 54;
		health 100;
		
		hdpowersuit.maxviewrotation 120;
		hdpowersuit.maxtorsorotation 100;
		hdpowersuit.maxarmrotation 1.0;
		hdpowersuit.torsorotationspeed 3.0;
		hdpowersuit.armrotationspeed 1.0;
		hdpowersuit.acceleration 0.2;
		hdpowersuit.maxfuel 140;
		hdpowersuit.maxheat 800;
		hdpowersuit.maxarmor 100;
		hdpowersuit.maxshields 200;
		hdpowersuit.maxintegrity 100;
		hdpowersuit.partialchargemax 1575;
		hdpowersuit.maxparts 50;
		hdpowersuit.turnspeed 2.0;
	}
	
	override void beginplay()
	{
		torso = hdpowersuittorso(spawn("hdpowersuittorso", pos));
		torso.leftarm = hdpowersuitarm(spawn("hdpowersuitblankarm", pos));
		torso.rightarm = hdpowersuitarm(spawn("hdpowersuitblankarm", pos));
		
		torso.leftarm.suitcore = self;
		torso.rightarm.suitcore = self;
		torso.leftarm.isleft = true;
		torso.rightarm.isleft = false;
		
		torso.leftleg = hdpowersuitleg(spawn("hdpowersuitleg", pos));
		torso.rightleg = hdpowersuitleg(spawn("hdpowersuitleg", pos));
		
		torso.leftleg.suitcore = self;
		torso.rightleg.suitcore = self;
		torso.leftleg.isleft = true;
		torso.rightleg.isleft = false;
		
		torso.suitcore = self;
		torso.angle = angle;
		
		targetangle = angle;
		thrustpower = 0;
		thrusterfuel = maxfuel;
		canrethrust = true;
		nextstep = -1;
		suitheat = 0;
		partialcharge = 0;
		partialshieldcharge = 0;
		
		giveinventory("hdpowersuitarmor", 1);
		suitarmor = hdpowersuitarmor(findinventory("hdpowersuitarmor"));
		suitarmor.durability = 0;
		
		giveinventory("hdmagicshield", 1);
		suitshield = hdmagicshield(findinventory("hdmagicshield"));
		suitshield.maxamount = maxshields;
		suitshield.amount = 1;
		
		repairparts = 0;
		
		hasarms = true;
		haslegs = true;
		
		super.beginplay();
	}
	
	override void postbeginplay()
	{
		self.vel = (0, 0, 0);
		
		super.postbeginplay();
	}
	
	override bool used(actor user)
	{
		if (user.player.original_cmd.buttons & BT_CROUCH
			|| user.player.crouching < 0 || (interface && interface.crouched))
		{
			if (user != driver)
			{
				user.giveinventory("hdpowersuiteditor", 1);
				hdpowersuiteditor suiteditor = hdpowersuiteditor(user.findinventory("hdpowersuiteditor"));
				suiteditor.suitcore = self;
				user.a_selectweapon("hdpowersuiteditor");
			}
		}
		
		if (!driver && (user is "playerpawn"
			&& user.player.readyweapon is "hdfist")
			&& !(user.player.original_cmd.buttons & BT_CROUCH))
		{
			if (hasarms && haslegs)
			{
				drivergetin(user);
				
				return true;
			}
			
			user.a_print("It's missing limbs. There's no way you can use this.");
		}
		
		return false;
	}
	
	override void tick()
	{
		if (driver)
		{
			driver.a_changevelocity(0, 0, 0, CVF_REPLACE);
			if (!checkalive())
			{
				ejectdriver();
			}
			else if (driver.player.original_cmd.buttons & BT_CROUCH && 
				driver.player.original_cmd.buttons & BT_USE)
			{
				ejectdriver();
			}
		}
		
		super.tick();
		
		if (driver)
		{
			driver.warp(self, 0, 0, 2, 0, WARPF_USECALLERANGLE | WARPF_INTERPOLATE
				| WARPF_NOCHECKPOSITION | WARPF_COPYVELOCITY);
			
			driver.player.viewz = (bobstep / 4.0) +
				self.pos.z + self.height;
			driver.invsel = null;
			driver.a_selectweapon("hdpowersuitinterface");
			hdplayerpawn(driver).striptime = 1;
			driver.a_setrenderstyle(1.0, STYLE_NONE);
			hdplayerpawn(driver).tauntsound = "mech/horn";
		}
		bool issteering = false;
		
		if (driver && checkusable())
		{
			checkcontrols();
			
			driver.vel = vel;
			
			if (speed != 0)
			{
				stepfrequency = 40 * abs(1.5 / double(speed));
				
				if (steeringleft() || steeringright() || angle != targetangle)
				{
					stepfrequency -= 3;
				}
			}
			else if (steeringleft() || steeringright() || angle != targetangle)
			{
				issteering = true;
				stepfrequency = 16;
			}
			else
			{
				stepfrequency = -1;
			}
			
			if (partialcharge > 0)
			{
				partialcharge--;
			}
			
			//fuck
			
			if (hdplayerpawn(driver).incapacitated > 0)
			{
				hdplayerpawn(driver).a_capacitated();
				driver.a_stopsound(CHAN_VOICE);
				driver.invsel = null;
				hdplayerpawn(driver).incaptimer = 0;
			}
			
			A_AlertMonsters(0, AMF_TARGETEMITTER);
		}
		else if (pos.z <= floorz || bonmobj)
		{
			targetspeed = 0;
			thrustpower = 0;
			vel.x = 0; vel.y = 0;
		}
		
		if ((speed != 0 || issteering) &&
				(pos.z <= floorz || bonmobj))
		{
			nextstep++;
			bobstep++;
							
			if (nextstep > stepfrequency * 2)
			{
				nextstep = 0;
			}
			
			if (bobstep > stepfrequency)
			{
				bobstep = 0;
			}
		}
		else
		{
			if (nextstep == 0 && speed == 0)
			{
				torso.leftleg.a_startsound("mech/stomp", 0, 0, 1.0);
				torso.rightleg.a_startsound("mech/stomp", 0, 0, 1.0);
				nextstep = -1;
			}
			else if (nextstep != -1)
			{
				nextstep = 0;
				bobstep = 0;
			}
		}
		
		if (partialshieldcharge > 0 && batteries[2] >= 0 && checkusable())
		{
			partialshieldcharge--;
			
			if (suitshield.amount < suitshield.maxamount && suitshield.amount > 0)
			{
				suitshield.bquicktoretaliate = true;
				partialshieldcharge -= 2;
			}
		}
		else if (batteries[2] > 0 && checkusable())
		{
			partialshieldcharge = (2 * partialchargemax) / 3;
			batteries[2]--;
			
			suitshield.bquicktoretaliate = true;
			partialshieldcharge--;
			
			if (suitshield.amount < suitshield.maxamount)
			{
				partialshieldcharge -= 2;
			}
		}
		else
		{
			suitshield.bquicktoretaliate = false;
			
			if (suitshield.amount > 0)
			{
				suitshield.amount -= 2;
			}
		}
		
		torso.warp(self, 4, 0, (haslegs ? 20 + (bobstep / 16.0) : 0), torso.angle, WARPF_USECALLERANGLE
			| WARPF_INTERPOLATE | WARPF_NOCHECKPOSITION | WARPF_ABSOLUTEANGLE);
			
		if (speed < targetspeed)
		{
			if (abs(targetspeed - speed) < acceleration)
			{
				speed += abs(targetspeed - speed);
			}
			else
			{
				speed += acceleration;
			}
		}
		else if (speed > targetspeed)
		{
			if (abs(targetspeed - speed) < acceleration)
			{
				speed -= abs(targetspeed - speed);
			}
			else
			{
				speed -= acceleration;
			}
		}
		
		if (thrusterfuel < maxfuel && !jumping())
		{
			thrusterfuel++;
			partialcharge--;
		}
		
		if (lastvel.z != 0 && vel.z == 0)
		{
			a_startsound("mech/stomp", 0, 0, 1.0);
		}
		
		if (batteries[0] <= 0 && batteries[1] <= 0 && partialcharge == 1)
		{
			a_startsound("mech/powerout", 0, CHANF_OVERLAP);
			a_startsound("mech/powerdown", 0, CHANF_OVERLAP);
			partialcharge--;
		}
		
		if (integrity == 0)
		{
			a_startsound("mech/destroyed", 0, CHANF_OVERLAP);
			integrity = -1;
			bKILLED = true;
			health = -1;
		}
		else if (integrity > 0 && bKILLED)
		{
			health = 100;
			bKILLED = false;
		}
		
		lastvel = vel;
		
		checkheat();
	}
	
	override bool cancollidewith(actor other, bool passive)
	{
		if (driver && other == driver)
		{
			return false;
		}
		
		return super.cancollidewith(other, passive);
	}
	
	protected bool steeringleft()
	{
		if (checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			return btn & BT_MOVELEFT && !(btn & BT_MOVERIGHT);
		}
		
		return false;
	}
	
	protected bool steeringright()
	{
		if (checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			return btn & BT_MOVERIGHT && !(btn & BT_MOVELEFT);
		}
		
		return false;
	}
	
	protected bool accelerating()
	{
		if (checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			return btn & BT_FORWARD && !(btn & BT_BACK);
		}
		
		return false;
	}
	
	protected bool decelerating()
	{
		if (checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			return btn & BT_BACK;
		}
		
		return false;
	}
	
	protected bool jumping()
	{	
		if (driver && checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			
			if (thrusterfuel <= 0)
			{
				canrethrust = false;
			}
			
			if (justpressed(BT_JUMP))
			{
				canrethrust = true;
			}
			
			if (canrethrust)
			{
				return btn & BT_JUMP;
			}
			else
			{
				return false;
			}
		}
		
		return false;
	}
	
	bool justpressed(int which)
	{
		if (checkalive())
		{
			int btn = driver.player.original_cmd.buttons;
			int oldbtn = driver.player.original_oldbuttons;
			return btn & which && !(oldbtn & which);
		}
		
		return false;
	}
	
	protected bool checkalive()
	{
		if (driver.health > 0)
		{
			return true;
		}
		
		return false;
	}
	
	protected void checkcontrols()
	{
		if (stomptics > 0)
		{
			targetspeed = 0;
			stomptics--;
			
			if (stomptics == 30)
			{
				a_startsound("mech/legwhir", CHAN_BODY, CHANF_OVERLAP, 0.7, ATTN_NORM, 1.0);
			}
			else if (stomptics == 5)
			{
				speed = 5;
				for (int i = 0; i < 5; i++)
				{
					a_startsound("mech/stomp", CHAN_6, CHAN_OVERLAP, 1.0, ATTN_NORM, 0.5 + (0.2 * i));
				}
				
				a_quake(3, 5, 0, 0);
				let shitsfucked = spawn("hdpowersuitaimpoint", pos);
				flinetracedata tracedata;
				linetrace(angle, 64, pitch, TRF_THRUACTORS, height / 8, 14, data: tracedata);
				shitsfucked.setorigin(tracedata.hitlocation, false);
				shitsfucked.angle = angle;
				shitsfucked.pitch = pitch;
				
				bool bustin = doordestroyer.destroydoor(shitsfucked, random(64, 96), random(4, 24), 8);
				shitsfucked.lineattack(shitsfucked.angle, 8,
					shitsfucked.pitch, 0, "", "bulletpuffbig");
				shitsfucked.destroy();
				
				for (int i = 0; i < 5; i++)
				{
					linetrace((angle - 10) + (i * 5), 96, pitch, 0, height / 12, 14, data: tracedata);
					if (tracedata.hitactor && tracedata.hitactor != driver)
					{
						tracedata.hitactor.damagemobj(self, self, random(700, 1000), "bashing");
					}
				}
			}
			
			bobstep = ((35 * 4) - max(stomptics * 4, 45)) / 1.5;
		}
		else
		{
			if (jumping())
			{
				if (thrusterfuel > 0)
				{
					if (thrustpower <= 0.075)
					{
						thrustpower += 0.005;
					}
					
					a_startsound("mech/thruster", CHAN_5, CHANF_LOOPING);
					targetspeed = 2;
					thrusterfuel -= 2;
				}
			}
			else
			{
				a_stopsound(CHAN_5);
				
				if (driver.player.cmd.buttons & BT_SPEED &&
					driver.player.cmd.buttons & BT_USE)
				{
					stomptics = 35;
					targetangle = angle;
				}
				
				if (accelerating())
				{
					targetspeed = 3.5;
				}
				else if (decelerating())
				{
					targetspeed = -2;
				}
				else if (pos.z <= floorz || bonmobj)
				{
					targetspeed = 0;
				}
				
				if (thrustpower > 0.0)
				{
					thrustpower -= 0.025;
				}
				if (thrustpower < 0)
				{
					thrustpower = 0;
				}
			}	
			
			if (steeringright())
			{
				targetangle = angle - turnspeed;
				driver.angle -= turnspeed;
			}
			else if (steeringleft())
			{
				targetangle = angle + turnspeed;
				driver.angle += turnspeed;
			}
			
			if (abs(driver.angle - angle) > maxviewrotation)
			{
				if (driver.angle - angle < 0)
				{
					driver.angle = angle - maxviewrotation;
				}
				else
				{
					driver.angle = angle + maxviewrotation;
				}
			}
		}
		
		if (justpressed(BT_USER1))
		{
			targetangle = driver.angle;
		}
		
		if (torso.angle - driver.angle > 0)
		{
			if (abs(torso.angle - driver.angle) < torsorotationspeed)
			{
				torso.angle -= abs(torso.angle - driver.angle);
			}
			else
			{
				torso.angle -= torsorotationspeed;
			}
		}
		else if (torso.angle - driver.angle < 0)
		{
			if (abs(torso.angle - driver.angle) < torsorotationspeed)
			{
				torso.angle += abs(torso.angle - driver.angle);
			}
			else
			{
				torso.angle += torsorotationspeed;
			}
		}
		
		if (abs(torso.angle - angle) > maxtorsorotation)
		{
			if (torso.angle - angle < 0)
			{
				torso.angle = angle - maxtorsorotation;
			}
			else
			{
				torso.angle = angle + maxtorsorotation;
			}
		}
		
		//angle = targetangle;
		if (angle < targetangle)
		{
			if (abs(angle - targetangle) < turnspeed)
			{
				angle += turnspeed - (angle - targetangle);
			}
			else
			{
				angle += turnspeed;
			}
		}
		else if (angle > targetangle)
		{
			if (abs(targetangle - angle) < turnspeed)
			{
				angle -= turnspeed - (targetangle - angle);
			}
			else
			{
				angle -= turnspeed;
			}
		}
		
		vector3 newvel;
		newvel.x = speed * cos(angle);
		newvel.y = speed * sin(angle);
		newvel.z = vel.z + thrustpower + (jumping() ? 0.5 : 0);
		
		vel = newvel;
	}
	
	override int damagemobj(actor inflictor, actor source, int damage, name mod, int flags, double angle)
	{
		if (mod == "electrical")
		{
			suitheat += damage * 8;
		}
		
		if (mod == "piercing" && driver)
		{
			if (damage > 1000)
			{
				driver.damagemobj(self, source, damage - 1000, mod, flags, angle);
			}
			
			if (suitarmor.durability <= 0)
			{
				driver.damagemobj(self, source, damage, mod, flags, angle);
			}
		}
		
		if (mod == "balefire")
		{
			suitheat += damage * 12;
		}
		
		return damage;
	}
	
	protected void checkheat()
	{
		heat inventoryheat = heat(findinventory("heat"));
		
		if (inventoryheat)
		{
			suitheat += min(inventoryheat.getamount(self), 10);
		}
		
		if (suitheat > 0)
		{
			suitheat -= 1 + (suitheat / (maxheat / 2));
		}
		
		if (suitheat > maxheat)
		{
			heatdamagetic++;
	
			actor smoke = spawn("hdsmoke", self.pos + (0, 0, 32));
			smoke.vel += (random(-3, 3), random(-3, 3), random(1, 3));
			
			if (heatdamagetic > max(16, 30 - (suitheat / 100)))
			{
				if (driver)
				{
					driver.damagemobj(self, self, 2 + (suitheat / 100), "hot");
				}
				
				heatdamagetic = 0;
			}
		}
		else if (driver)
		{
			heat driverheat = heat(driver.findinventory("heat"));
			
			if (driverheat)
			{
				driver.setinventory("heat", 0);
			}
		}
	}
	
	bool checkusable()
	{
		if (self && checkbattery() && integrity > 0)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	bool checkbattery()
	{
		if (partialcharge <= 0)
		{
			bool valid = false;
			
			if (batteries[0] > 0)
			{
				batteries[0]--;
				valid = true;
			}
			else if (batteries[1] > 0)
			{
				batteries[1]--;
				valid = true;
			}
			
			if (valid)
			{
				partialcharge = partialchargemax;
				return true;
			}
			else
			{
				return false;
			}
		}
		else if (batteries[0] >= 0 || batteries[1] >= 0)
		{
			return true;
		}
		
		return false;
	}
	
	override double bulletresistance(double hitangle)
	{
		return max(0, frandom(0.6, 0.8) - hitangle * 0.01);
	}
	
	void driverGetIn(actor user)
	{
			driver = playerpawn(user);
			driver.bthruactors = true;
			driver.player.cheats |= CF_FROZEN;
			driver.a_setinventory("hdpowersuitinterface", 1);
			interface = hdpowersuitinterface(driver.findinventory("hdpowersuitinterface"));
			interface.suitcore = self;
			
			torso.aimpoint = spawn("hdpowersuitaimpoint", self.pos);
			
			if (!(torso.leftarm is "hdpowersuitblankarm"))
			{
				torso.leftarm.armpoint = hdpowersuitaimpoint(spawn("hdpowersuitaimpoint", self.pos));
				torso.leftarm.armpoint.isarm = true;
				torso.leftarm.armpoint.isleft = true;
				torso.leftarm.armpoint.accuracy = driver.playernumber();
			}
			
			if (!(torso.rightarm is "hdpowersuitblankarm"))
			{
				torso.rightarm.armpoint = hdpowersuitaimpoint(spawn("hdpowersuitaimpoint", self.pos));
				torso.rightarm.armpoint.isarm = true;
				torso.rightarm.armpoint.isleft = false;
				torso.rightarm.armpoint.accuracy = driver.playernumber();
			}
			
			viewz = driver.player.viewz;
			torso.translation = driver.translation;
			torso.leftleg.translation = driver.translation;
			torso.rightleg.translation = driver.translation;
			
			if (checkusable())
			{
				a_startsound("mech/powerup", 0);
				a_startsound("mech/getin", 0);
			}
	}
	
	void ejectDriver()
	{
			driver.a_setinventory("hdpowersuitinterface", 0);
			driver.bthruactors = false;
			driver.player.cheats &=~ CF_FROZEN;
			driver.warp(self, 0 * -sin(angle), 0 * cos(angle),
				0, 0, WARPF_USECALLERANGLE | WARPF_INTERPOLATE
				| WARPF_ABSOLUTEOFFSET);
				
			hdplayerpawn(driver).applyuserskin(true);
			
			driver.a_setrenderstyle(1.0, STYLE_NORMAL);
				
			torso.aimpoint.destroy();
			
			if (torso.leftarm.armpoint)
			{
				torso.leftarm.armpoint.destroy();
			}
			
			if (torso.rightarm.armpoint)
			{
				torso.rightarm.armpoint.destroy();
			}
			
			driver.vel += (cos(self.angle) * 5, sin(self.angle) * 5, 0);
			
			driver = null;
			torso.driver = null;
			interface = null;
			
			if (checkusable())
			{
				a_startsound("mech/powerdown", 0);
			}
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}
