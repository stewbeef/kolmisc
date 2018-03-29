/*
set_propery("do_auto_tasks","consume,daily,bounty,lyle")
set_propery("valueOfAdventure","1000")
*/

script "do_auto.ash";
import "beefy_tools.ash";
import "do_gameinform.ash";
import "daily_key_lime.ash";

void do_lyle()
{
	maximize("10 meat,effective,-ml max 5", false);
	use_familiar(to_familiar("leprechaun"));
	maximize("meat,-weapon", false);
	cli_execute("clanfortune npc,meat");
	if(get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy")
	{
		cli_execute("concert winklered");
	}
	adventure(my_adventures(),to_location(508));
}

void do_daily_dungeon()
{
	if(get_property("_lastDailyDungeonRoom") != "15")
	{
		item picko = to_item("Pick-O-Matic lockpicks");
		item rdbd = to_item("ring of Detect Boring Doors");
		item elevenft = to_item("eleven-foot pole");

		getbuy(1,picko);
		getbuy(1,rdbd);
		getbuy(1,elevenft);

		print("equipping ring of detecting boring doors");
		slot accslot = $slot[acc3];
		item curacc3 = equipped_item(accslot);
		equip(accslot, to_item(6303)); // 6303 is ring of detect boring doors
		cli_execute("condition clear");
		print("adventuring in daily dungeon...");
		while(get_property("_lastDailyDungeonRoom") != "15")
		{
			adventure(1, to_location(325)); // daily dungeon;
		}
		//equip(accslot, curacc3);
		outfit("Main");
		print("daily dungeon complete");
		if(hippy_stone_broken())
		{
			put_closet(1,picko);
			put_closet(1,rdbd);
			put_closet(1,elevenft);
		}
	}
	else
	{
		print("Daily Dungeon already completed");
	}
}

void do_hidden_meat()
{
	if(get_property("_do_meat") != "done")
	{
		print("getting meat...");
		//familiar current = my_familiar();
		use_familiar(to_familiar("leprechaun"));
		maximize("meat,-weapon", false);
		if(get_property("sidequestArenaCompleted") == "hippy" || get_property("sidequestArenaCompleted") == "fratboy")
		{
			cli_execute("concert winklered");
		}
		adventure(20,to_location(343));
		//use_familiar(current);
		use_familiar(to_familiar("lil' barrel mimic"));
		outfit("Main");
		set_property("_do_meat","done");
	}
	else
	{
		print("meat already gathered..skipping");
	}
}
void do_consume()
{
	cli_execute("consume both");
}

void parse_do_auto(string command)
{
	matcher m = create_matcher("setprop(\\s|,)+(.*)",command);


	if(m.find())
	{
		set_property("do_auto_tasks",m.group(2));
	}
	else
	{
		string [int] cmd_array = command.to_lower_case().split_string(",");
		foreach num in cmd_array
		{
			switch(cmd_array[num])
			{
				case "daily":
					do_daily_dungeon();
				break;
				case "bounty":
					cli_execute("call do_bounties.ash");
				break;
				case "gameinform":
					cli_execute("clanfortune npc,item");
					do_the_game();
				break;
				case "hiddenmeat":
					do_hidden_meat();
				break;
				case "lyle":
					do_lyle();
				break;
				case "pies":
					try
					{
						do_dkl();
					}
					finally
					{
						do_dkl();
					}
				break;
				case "consume":
					do_consume();
				break;
				case "byprop":
				//ash 
					string mytasks = get_property("do_auto_tasks");
					parse_do_auto(mytasks);
				break;
				default:
					print(cmd_array[num] + " is not a valid choice)");
					//do_daily_dungeon();
					//cli_execute("call do_bounties.ash");
				break;
			}
		}
	}
}

void main(string cmd)
{
	parse_do_auto(cmd);
	
}