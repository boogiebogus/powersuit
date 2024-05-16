//This one gets special handling.

class HDPowersuitBlankShoulder : HDPowersuitShoulder
{
	default
	{
		hdpowersuitshoulder.droppeditemname "hdpowersuitblankshoulderpickup";
		+nointeraction
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}

class HDPowersuitBlankShoulderPickup : HDPowersuitShoulderPickup
{
	default
	{
		inventory.pickupmessage "You shouldn't be able to obtain this item normally.";
		hdpowersuitshoulderpickup.shouldertype "HDPowersuitBlankShoulder";
	}
	
	states
	{
		spawn:
			TNT1 A -1;
			stop;
	}
}
