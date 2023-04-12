class HDPowersuitArmor : HDDamageHandler
{
	int durability;
	
	default
	{
		inventory.maxamount 1;
		hddamagehandler.priority 0;
	}
	
	override double, double onbulletimpact(hdbulletactor bullet, double pen, double penshell,
		double hitangle, double deemedwidth, vector3 hitpos, vector3 vu, bool hitactoristall)
	{
		let hitactor = owner;
		
		if (!owner)
		{
			return 0, 0;
		}
		
		double addpenshell = 30;
		
		int crackseed = int(level.time + angle) & (1 | 2 | 4 | 8 | 16 | 32);
		
		if (crackseed > max(durability, 8))
		{
			addpenshell *= frandom(0.8, 1.1);
		}
		
		double degrade = frandom(-1, (int(min(pen, addpenshell) * bullet.stamina) >> 12));
		if (degrade < 1 && pen > addpenshell)
		{
			degrade = 1;
		}
		
		if (degrade > 0)
		{
			durability = max(durability - degrade, 0);
			
			if (durability < 20 && hdpowersuit(owner).integrity > 0)
			{
				hdpowersuit(owner).integrity = 
					max(hdpowersuit(owner).integrity - degrade * 2, 0);
			}
		}
		
		if (degrade > 2)
		{
			actor p; bool q;
			[q, p] = hitactor.a_spawnitemex("fragpuff", -hitactor.radius * 0.6, 0,
				bullet.pos.z - hitactor.pos.z, 4, 0, 1, 0, 0, 64);
				
			if (p)
			{
				p.vel += hitactor.vel;
			}
		}
		
		if (durability > 0)
		{
			penshell += addpenshell;
		}
		
		return pen, penshell;
	}
}
