const HDLD_RAINMODULE = "pa2";

class HDPowersuitRAINModule : hdpowersuitshoulder
{
	default
	{
		scale 0.7;
		
		+hdpowersuitshoulder.isexplosive
		hdpowersuitshoulder.droppeditemname "hdpowersuitrainmodulepickup";
		hdpowersuitshoulder.magtype "hdbattery";
		hdpowersuitshoulder.ammotype "hdbattery";
		hdpowersuitshoulder.maxmags 1;
		hdpowersuitshoulder.reloadtime 70;
		hdpowersuitshoulder.magsize 20;
		radius 8;
		height 14;
		
		tag 'Mongoose R.A.I.N. Module';
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
		if(suitcore.integrity > 0)suitcore.integrity-=random(0,25);
	}

	bool isEnabled;
	int targettime;
	override void postbeginplay()
	{
		firemodestring = "OFF";
		isEnabled = false;
		
		super.postbeginplay();
	}
	
	override void changefiremode()
	{
		if (isEnabled)
		{
			isEnabled = false;
			firemodestring = "OFF";
		}
		else
		{
			isEnabled = true;
			firemodestring = "ON";
		}
	}


	int cooldown;
	override void tick(){
		super.tick();
		if(!isEnabled)return;
		if(targettime > 0 && checkmags() && cooldown < 1)targettime--;
		else if(!checkmags())targettime = 0;

		string flash = "HDFlashbangThrown";
		class<HDFragGrenade> flashbang = flash;
		string flashroller = "HDFlashbangRoller";
		class<HDFragGrenadeRoller> flashbangroller = flashroller;

		string gas = "HDGasGrenadeThrown";
		class<HDFragGrenade> stinky = gas;
		string gasroller = "HDGasGrenadeRoller";
		class<HDFragGrenadeRoller> stinkyroller = gasroller;

		if(isfrozen()||health<1||!checkmags())return;
		if(checkmags()&&!random(0,2048))currentmag--;
		if(cooldown>0){cooldown--;return;}
		if(tracer)A_FaceTracer(1,1);
		ThinkerIterator Threats = ThinkerIterator.Create("Actor");
		Actor threat;
		while (threat = Actor(Threats.Next())){
			let fucky=HDFragGrenade(threat);
			let wucky=HDFragGrenadeRoller(threat);
			let uwu=HDFragGrenade(tracer);
			let owo=HDFragGrenadeRoller(tracer);
			if(tracer){
				if(
					distance3d(tracer)>1792
					||!CheckSight(tracer, SF_IGNOREVISIBILITY)
					||tracer.InStateSequence(tracer.CurState, tracer.ResolveState("death"))
					||tracer.findinventory("MogRAINExclusion")
					||(uwu&&uwu.fuze>=999)
					||(owo&&owo.fuze>=999)
					||tracer.findinventory("MogRAINDangerClose")
				)tracer=null;
				else continue;
			}
			if(
				threat.bmissile
				&&(distance3d(threat)<1792)
				&&CheckSight(threat, SF_IGNOREVISIBILITY)
				&&!(threat is 'HDBulletActor')
				&&!(threat is 'HDUPK')
				&&!threat.findinventory("MogRAINExclusion")
				&&!threat.findinventory("MogRAINDangerClose")
				&&!threat.InStateSequence(threat.CurState, threat.ResolveState("death"))
				&&!threat.InStateSequence(threat.CurState, threat.ResolveState("death2"))
				&&!threat.InStateSequence(threat.CurState, threat.ResolveState("splat"))
				&&!threat.InStateSequence(threat.CurState, threat.ResolveState("burn"))
			){
				tracer=threat;
				if((threat.getAge()<=3)&&(distance3d(threat)<384))threat.giveinventory("MogRAINDangerClose",1);
				cooldown=random(1,3);
				targettime = random (0,18);
			}
		}
			if(tracer&&distance3d(tracer)<512&&checkmags()&&cooldown<1&&!tracer.findinventory("MogRAINDangerClose")){
				//if(A_JumpIfTargetInLOS("null",1,JLOSF_DEADNOJUMP)){
				if(targettime < 1){
					spawn("MogRAINCountermeasureEffect",tracer.pos,ALLOW_REPLACE);
					tracer.giveinventory("MogRAINExclusion",1);
					let grenade=HDFragGrenade(tracer);
					let roller=HDFragGrenadeRoller(tracer);
					let slowprojectile=SlowProjectile(tracer);
					if((stinky&&stinkyroller)&&((tracer is stinky)||(tracer is stinkyroller))){
						let gr=spawn("mograinexplosion",tracer.pos,ALLOW_REPLACE);
						gr.target=tracer.target;gr.master=tracer.master;
						tracer.setorigin((99999,99999,0),false); //DO NOT.
						tracer.destroy();
					}else{
						if(grenade)grenade.fuze=999;
						if(roller)roller.fuze=999;
						if((flashbang&&flashbangroller)&&((tracer is flashbang)||(tracer is flashbangroller))){
							let gr=spawn("mograinexplosion",tracer.pos,ALLOW_REPLACE);
							gr.target=tracer.target;gr.master=tracer.master;gr.stamina=1;
						}
					}
					if(SlowProjectile)SlowProjectile.primed=true;
					if(SlowProjectile)SlowProjectile.ExplodeSlowMissile();
					else tracer.ExplodeMissile();
					A_StartSound("weapons/plasidle",CHAN_WEAPON,CHANF_OVERLAP);
					if(checkmags()&&!random(0,1024)){currentmag--;checkmags();}
					cooldown=18;
				}
			}
	}
	
	states
	{
		spawn:
			RNMD A 1{
				if(currentmag < 1 || !isEnabled) frame = 1;
				else frame = 0;
			}
			loop;
	}
}

class HDPowersuitRAINModulePickup : hdpowersuitshoulderpickup
{
	default
	{
		tag 'Mongoose RAIN Module';
		inventory.pickupmessage 'Picked up a Regional Attack Interference Node module for the Mongoose Powersuit.';
		inventory.icon "RNMDY0";
		hdpowersuitshoulderpickup.shouldertype "hdpowersuitrainmodule";
		hdweapon.refid HDLD_RAINMODULE;
	}
	
	override double weaponbulk()
	{
		return 100;
	}
	
	states
	{
		spawn:
			RNMD Z -1;
			stop;
	}
}

class MogRAINCountermeasureEffect : Actor
{
	Default
	{
		Radius 4;
		Height 4;
		Scale 1.2;
		-SOLID
		+NOINTERACTION
		+ZDOOMTRANS
		+NOGRAVITY
		+NODAMAGE
		+NOBLOOD
		+FLOAT
		RenderStyle "Add";
		Alpha 1;
		DeathSound "world/explode";
	}
	States
	{
	Spawn:
		BAL1 A 1 BRIGHT nodelay A_Scream();
		BAL1 CDE 2 BRIGHT;
		Stop;
	}
}

class MogRAINDangerClose : Inventory
{
	Default
	{
		+inventory.undroppable
		RenderStyle "Add";
		inventory.maxamount 1;
	}

	override void tick(){
		super.tick();
		if(!owner){destroy();return;}
		if(!tracer){
		actor thingy = spawn("MogRAINDistanceChecker",owner.pos,ALLOW_REPLACE);
		if(thingy){tracer=thingy;thingy.master=owner;}
		}
	}
}

class MogRAINDistanceChecker : IdleDummy
{
	Default
	{
		+NOINTERACTION
	}

	override void tick(){
		super.tick();
		if(!master){destroy();return;}
		setorigin(master.pos,false);
		ThinkerIterator RAINIterator = ThinkerIterator.Create("HDPowersuitRAINModule");
		Actor RAINNearby;
		while (RAINNearby = HDPowersuitRAINModule(RAINIterator.Next())){
		    if(!target)target = RAINNearby;
			if(target&&(distance3d(target)>640)){master.takeinventory("MogRAINDangerClose",1);destroy();return;}
		}
	}
}

class MogRAINExclusion : Inventory
{
	Default
	{
		+inventory.undroppable
		RenderStyle "Add";
		inventory.maxamount 1;
	}
}

class MogRAINExplosion : IdleDummy
{
	Default
	{
		+NOINTERACTION
	}
	States
	{
	Spawn:
		TNT1 A 0 nodelay A_JumpIf(stamina==1,"ohitsaflash");
		TNT1 A 1{
			bsolid=false;bpushable=false;bmissile=false;bnointeraction=true;bshootable=false;
			HDFragGrenade.FragBlast(self);
			actor xpl=spawn("WallChunker",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			xpl=spawn("HDExplosion",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			A_SpawnChunks("BigWallChunk",14,4,12);
		}
		Stop;

	OhItsAFlash:
		TNT1 A 1 BRIGHT nodelay{
			bsolid=false;bpushable=false;bmissile=false;bnointeraction=true;bshootable=false;
			A_HDBlast(
				pushradius:256,pushamount:128,fullpushradius:96,
				fragradius:HDCONST_ONEMETRE*12,fragments:random(1,5)
			);
			actor xpl=spawn("WallChunker",self.pos-(0,0,1),ALLOW_REPLACE);
				xpl.target=target;xpl.master=master;xpl.stamina=stamina;
			A_SpawnChunks("BigWallChunk",14,4,12);
		}
		Stop;
	}
}