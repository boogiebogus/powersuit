class HDPowersuitAimPoint : actor
{
	bool isarm, isleft;
	//accuracy is owner player
	
	default
	{
		+nointeraction
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}

class HDPowersuitReticleHandler : eventhandler
{
	le_glscreen glproj;
	bool canproject;
	array<actor> mo;
	textureid textureleft, textureright;
	double textoffset;
	le_viewport viewport;
	vector3 basepos;
	
	override void onregister()
	{
		glproj = new("le_glscreen");
		canproject = glproj != null;
		
		textureleft = texman.checkfortexture("ampta0", texman.type_any);
		textureright = texman.checkfortexture("amptb0", texman.type_any);
	}
	
	override void worldthingspawned(worldevent e)
	{
		if (e.thing is "hdpowersuitaimpoint")
		{
			mo.push(e.thing);
		}
	}
	
	override void worldtick()
	{
		for (int i = 0; i < mo.size(); i++)
		{
			if (!mo[i])
			{
				mo.delete(i);
			}
		}
	}
	
	override void renderoverlay(renderevent event)
	{
		if (!canproject)
		{
			return;
		}
		
		let windowaspect = 1.0 * screen.getwidth() / screen.getheight();
		let resolution = 480 * (windowaspect, 1);
		let t = event.fractic;
		
		glproj.cachecustomresolution(resolution);
		glproj.cachefov(players[consoleplayer].fov);
		glproj.orientforrenderoverlay(event);
		glproj.beginprojection();
		
		for (int i = 0; i < mo.size(); i++)
		{
			if (!mo[i] || !(players[consoleplayer].mo.playernumber() == mo[i].accuracy)
				|| !hdpowersuitaimpoint(mo[i]).isarm || automapactive)
			{
				continue;
			}
			
			glproj.projectactorposportal(mo[i], (0, 0, 0), t);
			
			if (glproj.isinfront())
			{
				viewport.fromhud();
				
				let drawpos = viewport.scenetocustom(glproj.projecttonormal(), resolution);
				
				screen.drawtexture((hdpowersuitaimpoint(mo[i]).isleft ? textureleft : textureright), true, drawpos.x, drawpos.y, 
					DTA_KEEPRATIO, true, DTA_VIRTUALWIDTHF, resolution.x, DTA_VIRTUALHEIGHTF, resolution.y);
			}
		}
	}
}
