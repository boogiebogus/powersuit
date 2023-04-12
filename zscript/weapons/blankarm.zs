//This one gets special handling.

class HDPowersuitBlankArm : HDPowersuitArm
{
	default
	{
		hdpowersuitarm.droppeditemname "hdpowersuitblankarmpickup";
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}

class HDPowersuitBlankArmPickup : HDPowersuitArmPickup
{
	default
	{
		inventory.pickupmessage "You shouldn't be able to obtain this item normally.";
		hdpowersuitarmpickup.armtype "HDPowersuitBlankArm";
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}
