script "do_bounties.ash";

void main()
{
	
	cli_execute("condition clear");
	cli_execute("bounty");
	if(get_property("currentEasyBountyItem") == "")
	{
		print("Picking up a new easy bounty");
		cli_execute("bounty easy");
		cli_execute("bounty");
	}
	
	string easyb_string = get_property("currentEasyBountyItem");
	if(easyb_string != "")
	{	
		print("Doing Easy Bounty Done");
		bounty easybounty = to_bounty(easyb_string);
		//while(get_property("currentEasyBountyItem").split_string(":")[1].to_int() != easybounty.number)
		while(get_property("currentEasyBountyItem") != "" && my_adventures() > 0)
		{
			adventure(1,easybounty.location);
		}
		cli_execute("bounty easy");
	}
	print("Easy Bounty Done");
	
	cli_execute("condition clear");
	cli_execute("bounty");
	if(get_property("currentEasyBountyItem") == "")
	{
		print("Picking up a new hard bounty");
		cli_execute("bounty hard");
		cli_execute("bounty");
	}
	
	
	string hardb_string = get_property("currentHardBountyItem");
	if(hardb_string != "")
	{
		print("Doing Hard Bounty Done");
		bounty hardbounty = to_bounty(hardb_string);
	
		//while(get_property("currentHardBountyItem").split_string(":")[1].to_int() != hardbounty.number)
		
		slot accslot = $slot[none];
		item curacc3;
		boolean do_hard_bounty = true;

		//pre checks
		if(hardbounty.location == to_location("the Palindome"))
		{
			item tali = to_item(486); //Talisman o' Namsilat
			if(item_amount(tali) > 0)
			{
				accslot = $slot[acc3];
				curacc3 = equipped_item(accslot);
				equip(accslot, tali); 
			}
			else if (have_equipped(tali) == false)
			{
				do_hard_bounty = false;
			}
		}

		if(do_hard_bounty)
		{
			while(get_property("currentHardBountyItem") != ""  && my_adventures() > 0)
			{
				adventure(1,hardbounty.location);
			}
		}

		//post checks
		if(hardbounty.location == to_location("the Palindome") && accslot != $slot[none])
		{
			equip(accslot, curacc3);
		}
	
		cli_execute("bounty hard");
	}
	cli_execute("condition clear");
	print("Hard Bounty Done");
}