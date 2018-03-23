//do_gameinform for doing gamerpro dungeon

/*
kolmafia prefs:
gameProBossSpecialPower

items:
GameInformPowerDailyPro magazine 6714 - makes walkthrough
GameInformPowerDailyPro walkthru 6175 quest item - means on quest

*/

script "do_gameinform.ash";

void GetAndUseGameInformMag()
{
	item mag = to_item(6174);
	item walkthru = to_item(6175);

	if(item_amount(mag) > 1)
	{
		//use(1,mag);
	}
	else if(closet_amount(mag) > 1)
	{
		take_closet(1, mag);
		//use(1,mag);
	}
	else if(storage_amount(mag) > 1)
	{
		take_storage(1, mag);
		//use(1,mag);
	}
	else
	{
		cli_execute("mallbuy 1 GameInformPowerDailyPro magazine @ 6000");
		if(item_amount(mag) > 1)
		{
			//use(1,mag);
		}
		else if(storage_amount(mag) > 1)
		{
		take_storage(1, mag);
		}
	}
	use(1,mag);
	visit_url("inv_use.php?pwd&whichitem=6174&confirm=Yep.");
	cli_execute("refresh inv");
	use(1,walkthru);
}

void do_the_game(int max_runs, int turns_remaining)
{
	item walkthru = to_item(6175);
	int completed = 0;
	location game1 = to_location(319); //level 1
	location game2 = to_location(320); //level 2
	location game3 = to_location(321); //level 3
	location current = game1;
	maximize("-combat, acc1, acc2, acc3", false);
	boolean advtest;
	boolean domore = true;
	boolean maybequit = false;
	print("Beginning GameInform Run");

	while(completed < max_runs && domore && my_adventures() > 0)
	{
		if(item_amount(walkthru) == 0 && my_adventures() > turns_remaining)
		{
			print("Using new Magazine");
			GetAndUseGameInformMag();
			current = game1;
			maybequit = false;
		}
		else if (item_amount(walkthru) == 0)
		{
			print("No more Walkthrus and not enough turns remaining");
			domore = false;
		}
		if(domore)
		{
			print("Gameinform adventure");
			advtest = adv1(current,-1,"");
			if(get_property("lastEncounter") == "A Gracious Maze")
			{
				print("Last Encounter was A Gracious Maze, visiting GameInform entrance");
				visit_url("place.php?whichplace=faqdungeon");
			}
			if(advtest == false || current == $location[none])
			{
				switch(current)
				{//get_property("lastAdventure")
					//"Video Game Level 1|2|3
					case game1:
						print("Gameinform moving to level 2");
						current = game2;
						break;
					case game2:
						print("Gameinform moving to level 3");
						current = game3;
						break;
					case game3:
						print("Gameinform done with level 3");
						cli_execute("refresh inv");
						current = $location[none];
						break;
					default:
						print("Gameinform maybe quit?");
						if(maybequit == true)
						{
							abort("do_gamepro error, invalid location");
						}
						maybequit = true;
				}
			}


			if(item_amount(walkthru) == 0)
			{
				completed += 1;
				if(my_adventures() < turns_remaining)
				{
					domore = false;
				}
			}
		}		
	}
	put_closet(item_amount(to_item(6249)),to_item(6249));
	//dungeoneering kits to closet
}

void do_the_game()
{
	int turns = get_property("DoGameInform_turns").to_int();
	int runs = get_property("DoGameInform_maxruns").to_int();
	do_the_game(runs, turns);
}

void test_gameinform()
{
	if(get_property("DoGameInform") == "true")
	{
		do_the_game(1, 30);
	}
}

void main(string setting)
{
	switch(setting.to_lower_case())
	{
		case "on":
			set_property("DoGameInform","true");
			set_property("DoGameInform_turns","30");
			set_property("DoGameInform_maxruns","10");
			set_property("choiceAdventure570","1");
			print("Gameinform Enabled, when executed max runs 10, starting if 30 or more adv remaining");
			break;
		case "off":
			set_property("DoGameInform","false");
			print("Gameinform disabled");
			break;
		case "test":
			print("Testing Gameinform");
			test_gameinform();
			break;
	}
}