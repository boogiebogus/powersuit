const HDLD_HEATSINK = "pa0";

class HDPowersuitHeatSink : hdpowersuitshoulder
{
	default
	{
		scale 0.7;
		
		+hdpowersuitshoulder.istool
		hdpowersuitshoulder.droppeditemname "hdpowersuitheatsinkpickup";
		hdpowersuitshoulder.undetachablemessage "heat sink too hot.";
		radius 8;
		height 14;
		//hdpowersuitshoulder.magtype "hd4mmag";
		
		tag 'Mongoose Heat Sink';
	}
	int heattaken;

	override void drawhudstuff(hdstatusbar sb, hdweapon hdw, hdplayerpawn hpl)
	{
		if (isleft)
		{
			if (heattaken < suitcore.maxheat)
			{
				sb.drawrect(-48, -32, -48 
					+ max(min(float(heattaken / float(suitcore.maxheat))* 48, 48), 0), -4);
			}
			else
				sb.fill(color(255, 255, 0, 0), -48, -32, max(float((heattaken - suitcore.maxheat) / float(suitcore.maxheat))* -48, -48), -4,
					sb.DI_SCREEN_CENTER_BOTTOM);
					/*
			if (heattaken > suitcore.maxheat * 2)
				sb.fill(color(255, 255, 0, 0), -48, -32, max(float((heattaken - (suitcore.maxheat * 2)) / float(suitcore.maxheat))* -48, -48), -4,
					sb.DI_SCREEN_CENTER_BOTTOM);
					*/
		
			sb.drawstring(sb.pnewsmallfont, "HTSNK TEMP",
				(-48, -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_RIGHT, font.CR_GRAY, scale: (0.5, 0.5));
		}
		else
		{
			if (heattaken < suitcore.maxheat)
			{
				sb.drawrect(48, -32, 48 
					- max(min(float(heattaken / float(suitcore.maxheat))* 48, 48), 0), -4);
			}
			else
				sb.fill(color(255, 255, 0, 0), 48, -32, min(48, float((heattaken - suitcore.maxheat) / float(suitcore.maxheat))* 48), -4,
					sb.DI_SCREEN_CENTER_BOTTOM);
					/*
			if (heattaken > suitcore.maxheat * 2)
				sb.fill(color(255, 255, 0, 0), 48, -32, min(48, float((heattaken - (suitcore.maxheat * 2)) / float(suitcore.maxheat))* 48), -4,
					sb.DI_SCREEN_CENTER_BOTTOM);
					*/
			
			sb.drawstring(sb.pnewsmallfont, "HTSNK TEMP",
				(48, -32), 
				sb.DI_SCREEN_CENTER_BOTTOM | sb.DI_TEXT_ALIGN_LEFT, font.CR_GRAY, scale: (0.5, 0.5));
		}
	}

	override void tick()
	{
		if (heattaken > 0)
		{
			heattaken -= randompick(0,0,0,0,1,2,1,3,4);
		}
		if((countinv("HDFireEnder")>0)&&heattaken>0){
		heattaken-=random(10,35);
		A_TakeInventory("HDFireEnder",1);
		}
		int heatrate=random(1,8);
		if(suitcore&&suitcore.suitheat>0)heattaken+=heatrate;
		if(suitcore&&(heattaken>=suitcore.maxheat)){
			bisnotdetachable = true;
			if(!random(0,45))damagemobj(self,self,random(1,20),"hot");
		}else bisnotdetachable = false;

		if(suitcore&&suitcore.suitheat>0&&(heattaken<=(suitcore.maxheat*2))){
			suitcore.suitheat-=heatrate;
		}
		
		super.tick();
	}
	
	states
	{
		spawn:
			HTSN K 1;
			loop;
	}
}

class HDPowersuitHeatSinkPickup : hdpowersuitshoulderpickup
{
	default
	{
		tag 'Mongoose Heat Sink';
		inventory.pickupmessage 'Picked up a heat sink for the Mongoose Powersuit.';
		inventory.icon "HTSNZ0";
		+hdpowersuitshoulderpickup.istool
		hdpowersuitshoulderpickup.shouldertype "hdpowersuitheatsink";
		hdweapon.refid HDLD_HEATSINK;
	}
	
	override double weaponbulk()
	{
		return 75;
	}
	
	states
	{
		spawn:
			HTSN Z -1;
			stop;
	}
}
