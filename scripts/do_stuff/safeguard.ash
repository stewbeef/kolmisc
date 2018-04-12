//Item Safeguard

import "beefy_tools.ash";


////////////////////////////////
//Global Variables
int [string, item] safeguard_array; //int is # to keep, if 0 it is keep all.
string safeguard_file = "itemflags_array.txt";

////////////////////////////////
//Array Saving

boolean SaveSafeguardList()
{
	print("Saving safeguard_array");
	return map_to_file(safeguard_array,safeguard_file);
}

////////////////////////////////
//Array Retrieval Function
int [string, item] Safeguard_Array()
{
	if (safeguard_array.count() == 0)
	{
		print("safeguard_array Map is empty, attempting to load from file...");
		if(file_to_map(safeguard_file,safeguard_array))
		{
			if (safeguard_array.count() == 0)
			{
				print("file empty, no gearlist settings found...");
			}
			else
			{
				print("loaded safeguard_array settings from file...");
			}
		}
		else
		{
			print("Could not load from " + safeguard_file + ", assuming no safeguard_array settings have been made");
		}
	}
	return safeguard_array;
}

////////////////////////////////
//Existance

boolean is_safeguard_item(string type, item it)
{
	return Safeguard_Array()[type] contains it;
}
boolean is_sg_keep(item it)
{
	return is_safeguard_item("keep", it);
}
boolean is_sg_junk(item it)
{
	return is_safeguard_item("junk", it);
}
boolean is_sg_autosell(item it)
{
	return is_safeguard_item("autosell", it);
}
boolean is_sg_auction(item it)
{
	return is_safeguard_item("auction", it);
}
boolean is_sg_pulverize(item it)
{
	return is_safeguard_item("pulverize", it);
}

	//String versions
boolean is_safeguard_item(string type, string itname)
{
	return is_safeguard_item(type, itname.to_item());
}
boolean is_sg_keep(string itname)
{
	return is_safeguard_item("keep", itname.to_item());
}
boolean is_sg_junk(string itname)
{
	return is_safeguard_item("junk", itname.to_item());
}
boolean is_sg_autosell(string itname)
{
	return is_safeguard_item("autosell", itname.to_item());
}
boolean is_sg_auction(string itname)
{
	return is_safeguard_item("auction", itname.to_item());
}
boolean is_sg_pulverize(string itname)
{
	return is_safeguard_item("pulverize", itname.to_item());
}

////////////////////////////////
//Remove Item
boolean sg_remove(string type, item it)
{
	string [int] word_array;
	word_array[0] = it.to_string();
	word_array[1] = type;
	if(is_safeguard_item(type,it))
	{
		remove safeguard_array [type,it];
		SaveSafeguardList();
		print_html("Safeguard Item %s Removed from list %s", word_array);
		return true;
	}
	return false;
}
boolean sg_remove(string type, string itname)
{
	return sg_remove(type,itname.to_item());
}

boolean sg_remove_keep(item it)
{
	return sg_remove("keep",it);
}
boolean sg_remove_keep(string itname)
{
	return sg_remove("keep",itname.to_item());
}

boolean sg_remove_junk(item it)
{
	return sg_remove("junk",it);
}
boolean sg_remove_junk(string itname)
{
	return sg_remove("junk",itname.to_item());
}

boolean sg_remove_autosell(item it)
{
	return sg_remove("autosell",it);
}
boolean sg_remove_autosell(string itname)
{
	return sg_remove("autosell",itname.to_item());
}

boolean sg_remove_auction(item it)
{
	return sg_remove("auction",it);
}
boolean sg_remove_auction(string itname)
{
	return sg_remove("auction",itname.to_item());
}

boolean sg_remove_pulverize(item it)
{
	return sg_remove("pulverize",it);
}
boolean sg_remove_pulverize(string itname)
{
	return sg_remove("pulverize",itname.to_item());
}

////////////////////////////////
//Add Item

boolean sg_add(string type, item it, int num)
{
	string [int] word_array;
	word_array[0] = it.to_string();
	word_array[1] = type;
	foreach var in Safeguard_Array()
	{
		
		if(var != type && is_safeguard_item(var,it))
		{
			sg_remove(var,it);
		}
		else if (is_safeguard_item(var,it))
		{
			print_html("Safeguard Item %s already in list %s", word_array);
			return true;
		}
	}
	Safeguard_Array()[type,it] = num;
	SaveSafeguardList();
	print_html("Safeguard Item %s added to list %s", word_array);
	return true;	
}
boolean sg_add(string type, string itname, int num)
{
	return sg_add(type,itname.to_item(), num);
}

boolean sg_add_keep(item it)
{
	return sg_add("keep",it, 0);
}
boolean sg_add_keep(string itname)
{
	return sg_add("keep",itname.to_item(), 0);
}

boolean sg_add_junk(item it, int num)
{
	return sg_add("junk",it, num);
}
boolean sg_add_junk(string itname, int num)
{
	return sg_add("junk",itname.to_item(), num);
}

boolean sg_add_autosell(item it, int num)
{
	return sg_add("autosell",it, num);
}
boolean sg_add_autosell(string itname, int num)
{
	return sg_add("autosell",itname.to_item(), num);
}

boolean sg_add_auction(item it, int num)
{
	return sg_add("auction",it, num);
}
boolean sg_add_auction(string itname, int num)
{
	return sg_add("auction",itname.to_item(), num);
}

boolean sg_add_pulverize(item it, int num)
{
	return sg_add("pulverize",it, num);
}
boolean sg_add_pulverize(string itname, int num)
{
	return sg_add("pulverize",itname.to_item(), num);
}
////////////////////////////////
//Misc Functions
int [item] sg_search(string type, string regex)
{
	int [item] results;
	print_html("regex %s", regex);
	foreach it in Safeguard_Array()[type]
	{
		matcher m = create_matcher(regex,it.to_string());
		if(find(m))
		{
			print("match found");
			results[it] = Safeguard_Array()[type,it];
		}
	}
	return results;
}
int [string, item] sg_search(string regex)
{
	int [string,item] results;
	foreach type in Safeguard_Array()
	{
		results[type] = sg_search(type, regex);
	}
	return results;
}
////////////////////////////////
//Safeguarding

void _sg_closet_keeponly(item it, int keepamt)
{
	if(closet_amount(it) < keepamt)
	{
		put_closet(min(item_amount(it),keepamt - closet_amount(it)), it);

	}
	else if (closet_amount(it) > keepamt)
	{
		take_closet(closet_amount(it) - keepamt, it);
	}
}

void sg_closet_items()
{
	foreach it in get_inventory()
	{
		if((it.is_giftable() || it.is_tradeable()) &&  it.is_discardable())
		{
			
			if (it != to_item("Doc Galaktik's Pungent Unguent") && item_amount(it) > 0)
			{
				boolean success = false;
				try
				{
					int it_num = item_amount(it);
					success = put_closet(item_amount(it), it);
				}
				finally
				{
					if(success)
					{
						print_html("Placed %s quantity of %s into closet", string[int] {it_num.to_string(),it.to_string()});
					}
					else
					{
						print_html("Could not confirm placement of %s quantity of %s into closet -- probably worked anyway", string[int] {it_num.to_string(),it.to_string()});
					}
					continue;
				}
			}
		}
	}
	foreach name in Safeguard_Array()
	{
		foreach it in Safeguard_Array()[name]
		{
			if (it != to_item("Doc Galaktik's Pungent Unguent") && item_amount(it) > 0)
			{
				boolean success = false;
				try
				{
					int it_num = item_amount(it);
					success = put_closet(item_amount(it), it);

				}
				finally
				{
					if(success)
					{
						print_html("Placed %s quantity of %s into closet", string[int] {it_num.to_string(),it.to_string()});
					}
					else
					{
						print_html("Could not confirm placement of %s quantity of %s into closet -- probably worked anyway", string[int] {it_num.to_string(),it.to_string()});
					}
					continue;
				}
			}
		}
	}
	GetBuy(50,to_item("Doc Galaktik's Pungent Unguent"));
}

void sg_closet_remove()
{
	item picko = to_item("Pick-O-Matic lockpicks");
	item rdbd = to_item("ring of Detect Boring Doors");
	item elevenft = to_item("eleven-foot pole");
	item gameinform_mag = to_item("GameInformPowerDailyPro magazine");
	int [item] getem;
	getem[picko] = 1;
	getem[rdbd] = 1;
	getem[elevenft] = 1;
	getem[gameinform_mag] = 1;

	foreach it in getem
	{
		int c_amt = closet_amount(it);
		print_html("Examining needs for %s", it);
		if(item_amount(it) == 0 && c_amt > 0)
		{
			string[int] vars = {it.to_string(),getem[it].to_string(),c_amt.to_string()};

			print_html("For %s desired amount is %s, available is %s", vars);
			take_closet(min(c_amt,getem[it]), it);
		}
		else if(item_amount(it) > 0)
		{
			print_html("Have %s, need none.", item_amount(it));
		}
		else if(c_amt == 0)
		{
			print_html("Have none, and none in closet.");
		}
		else
		{
			print_html("Have sufficient numbers");
		}
	}

}

boolean should_use(item it)
{
	print("test");
	if(it.usable.to_boolean())
	{
		//can use it
		if(it.minhp == 0 && it.minmp == 0)
		{//not a restore
			if(it.fullness == 0 && it.spleen == 0 && it.inebriety == 0)
			{//not food
				if(effect_modifier(it,"effect") == $effect[none])
				{//doesn't produce an effect (not a buff/debuff item)
					return true;
					/*
					if(it.to_effect() == $effect[none])
					{
						return true;
					}
					*/
				}
			}
		}

	}
	return false;
}

void sg_junk_items()
{
	print_html("Junking Items...");
	foreach it in Safeguard_Array()["junk"]
	{
		int except_amount = Safeguard_Array()["junk",it];
		int junk_amount = max(item_amount(it) - except_amount, 0);
		if(junk_amount > 0)
		{
			string [int] word_array;
			word_array[0] = junk_amount.to_string();
			word_array[1] = item_amount(it).to_string();
			word_array[2] = it.to_string();
			if(should_use(it))
			{
				//print("test");
				print_html("Using %s out of %s of %s", word_array);
				use(junk_amount, it);
			}
			else if(it.fullness > 0 || it.inebriety > 0)
			{
				if(get_property("safeguard_junk_to_asdonmartin") == true)
				{
					print_html("Fueling Asdon Martin with %s out of %s of %s", word_array);
					cli_execute("asdonmartin fuel " + junk_amount.to_string() + " " + it.to_string());
				}
				else
				{
					print_html("Autoselling %s out of %s of %s", word_array);
					autosell(junk_amount, it);
				}
			}
			else
			{
				
				print_html("Autoselling %s out of %s of %s", word_array);
				autosell(junk_amount, it);
			}
		}
	}
	foreach it in Safeguard_Array()["autosell"]
	{
		int except_amount = Safeguard_Array()["autosell",it];
		int sell_amount = max(item_amount(it) - except_amount, 0);
		if(sell_amount > 0)
		{
			string [int] word_array;
			word_array[0] = sell_amount.to_string();
			word_array[1] = item_amount(it).to_string();
			word_array[2] = it.to_string();
			print_html("Autoselling %s out of %s of %s", word_array);
			autosell(sell_amount, it);
		}
	}
}
void sg_mall_items()
{
	foreach it in Safeguard_Array()["auction"]
	{
		int keepamt = Safeguard_Array()["auction",it];
		_sg_closet_keeponly(it,keepamt);
		if(item_amount(it) > 0)
		{
			int price = 0;
			string prop = "sg_mall_item." + it.to_string();
			string rec_price_str = get_property(prop);
			if (shop_amount(it) > 0)
			{
				price = shop_price(it);
				set_property(prop,price);
			}
			else if (rec_price_str != "")
			{
				price = rec_price_str.to_int();
			}
			else
			{
				price = mall_price(it);
			}
			put_shop(price,0, item_amount(it),it);
		}

	}
}

void _sg_get_jackhammer()
{
	int[item] camp = get_campground();
	item jackhammer = to_item("warbear jackhammer drill press");
	if(camp contains jackhammer)
	{
		return;
	}
	else if(available_amount( jackhammer ) > 0)
	{
		use(1,jackhammer);
	}

}

void sg_pulverize_items()
{
	_sg_get_jackhammer();
	
	foreach it in Safeguard_Array()["pulverize"]
	{
		int keepamt = Safeguard_Array()["pulverize",it];
		_sg_closet_keeponly(it,keepamt);
		cli_execute("pulverize " + item_amount(it) + " " + it.to_string());
	}

}

////////////////////////////////
//Printing
void sg_print(string type, int [item] sg_arr)
{
	print_html("%s list of items", type);
	foreach it in sg_arr
	{
		string itname = it.to_string();
		string numstr = sg_arr[it];
		string[int] word_array;
		word_array[0] = itname;
		word_array[1] = type;
		word_array[2] = numstr;

		print_html("%s, %s all but %s", word_array);
	}
}

void sg_print(int [string,item] sg_arr)
{
	foreach type in sg_arr
	{
		sg_print(type, sg_arr[type]);
	}
}

void sg_print(string type)
{
	print_html("%s list of items", type);
	foreach it in Safeguard_Array()[type]
	{
		string itname = it.to_string();
		string numstr = Safeguard_Array()[type,it];
		string[int] word_array;
		word_array[0] = itname;
		word_array[1] = type;
		word_array[2] = numstr;
		//word_array = string[int]{it.to_string(),type,Safeguard_Array()[type,it]};
		//word_array = string[int]{itname,type,numstr};
		print_html("%s, %s all but %s", word_array);
	}
}
void sg_print_all()
{
	foreach type in Safeguard_Array()
	{
		sg_print(type);
	}
}

void sg_print_mememtos()
{
	sg_print("keep");
}
void sg_print_junk()
{
	sg_print("junk");
}
void sg_print_autosell()
{
	sg_print("autosell");
}
void sg_print_auction()
{
	sg_print("auction");
}
void sg_print_pulverize()
{
	sg_print("pulverize");
}


////////////////////////////////
//Parsing Commands

void Parse_Safeguard_Command(string command)
{
	string [int] command_array = split_string(command,",");
	int paramnum = command_array.count();
		switch(command_array[0])
	{
		case "help":
		case "?":
		case "HELP":
		case "":
			break;
		case "safeguard":
		case "closet":
			sg_closet_items();
			break;
		case "list":
		case "print":
			sg_print_all();
			break;
		case "search":
			if(command_array.count() == 2)
			{
				sg_print(sg_search(command_array[1]));
			}
			else if(command_array.count() == 3)
			{
				string my_search_type = command_array[1];
				sg_print(my_search_type,sg_search(my_search_type,command_array[2]));
			}
			break;
		//keep commands
		case "+keep":
			sg_add_keep(command_array[1]);
			break;
		case "-keep":
			sg_remove_keep(command_array[1]);
			break;
		case "list keep":
		case "print keep":
			sg_print_mememtos();
			break;
		//junk commands
		case "+junk":
			sg_add_junk(command_array[1], command_array[2].to_int());
			break;
		case "-junk":
			sg_remove_junk(command_array[1]);
			break;
		case "list junk":
		case "print junk":
			sg_print_junk();
			break;
		//autosell commands
		case "+autosell":
			sg_add_autosell(command_array[1], command_array[2].to_int());
			break;
		case "-autosell":
			sg_remove_autosell(command_array[1]);
			break;
		case "list autosell":
		case "print autosell":
			sg_print_autosell();
			break;
		//auction commands
		case "+auction":
			sg_add_auction(command_array[1], command_array[2].to_int());
			break;
		case "-auction":
			sg_remove_auction(command_array[1]);
			break;
		case "list auction":
		case "print auction":
			sg_print_auction();
			break;
		//pulverize commands
		case "+pulverize":
			sg_add_pulverize(command_array[1], command_array[2].to_int());
			break;
		case "-pulverize":
			sg_remove_keep(command_array[1]);
			break;
		case "list pulverize":
		case "print pulverize":
			sg_print_mememtos();
			break;
		case "junk it":
			sg_junk_items();
			break;
		default:
			print_html("command %s not recognized", command);
			break;

	
	}
}

void main(string command)
{
	Parse_Safeguard_Command(command);
}