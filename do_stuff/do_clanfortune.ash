script "do_clanfortune.ash"

import "beefy_choicephp.ash";
import "beefy_tools.ash";

int _clan_fortune_id = 1278;

record cmd_info
{
	boolean [string] inputs;
	string output;
	string description;
};

record clan_fortune_status
{
	string [string] requests;
	int remaining;
	boolean npc_fortune_done;
};

record clan_fortune_entries
{
	string name;
	string fav_food;
	string fav_char;
	string fav_word;
};

record clan_fortune_transaction
{
	player_info sender_info;
	string send_date; //today_to_string().to_int()
	string send_date_game; // gameday_to_string()
	time send_time;
	int request_number;
	
	string receiver_name;
	player_info receiver_info;
	string response_date; // realworld
	time received_time;
	mail received_mail;
	
	string test_results;
	item [int] received_items;
	string [int] received_items_str;
	
	clan_fortune_entries send_entries;
	clan_fortune_entries received_entries;
	
	boolean complete;
	
	
};


///////////////////////
//global variables
clan_fortune_entries [string] clan_fortune_entries_array;
string _clan_fortune_entries_file = "clan_fortune_templates.txt";

	//YYYYMMDD, transaction #
clan_fortune_transaction [string, int] _clan_fortune_history_array;
string _clan_fortune_history_file = my_name() + "_clan_fortune_history.txt";

///////////////////////
//Record Saving
boolean SaveClanFortuneEntries()
{
	print("Saving clan_fortune_entries_array");
	return map_to_file(clan_fortune_entries_array,_clan_fortune_entries_file);
}

boolean SaveClanFortuneHistory()
{
	print("Saving _clan_fortune_history_array");
	return map_to_file(_clan_fortune_history_array,_clan_fortune_history_file);
}

////////////////////////////////
//Array Retrieval Functions
clan_fortune_entries [string] ClanFortuneEntries_Array()
{
	if (clan_fortune_entries_array.count() == 0)
	{
		print("clan_fortune_entries_array Map is empty, attempting to load from file...");
		if(file_to_map(_clan_fortune_entries_file,clan_fortune_entries_array))
		{
			if (clan_fortune_entries_array.count() == 0)
			{
				log_print("file empty, no clan fortune templates settings found...");
			}
			else
			{
				log_print("loaded clan_fortune_entries_array settings from file...");
			}
		}
		else
		{
			log_print("Could not load from " + _clan_fortune_entries_file + ", assuming no clan fortune template settings have been made");
		}
	}
	return clan_fortune_entries_array;
}

clan_fortune_transaction [string, int] ClanFortuneHistory_Array()
{
	if (_clan_fortune_history_array.count() == 0)
	{
		print("_clan_fortune_history_array Map is empty, attempting to load from file...");
		if(file_to_map(_clan_fortune_history_file,_clan_fortune_history_array))
		{
			if (_clan_fortune_history_array.count() == 0)
			{
				log_print("file empty, no _clan_fortune_history_array settings found...");
			}
			else
			{
				log_print("loaded _clan_fortune_history_array settings from file...");
			}
		}
		else
		{
			log_print("Could not load from " + _clan_fortune_history_file + ", assuming no clan fortune history settings have been made");
		}
	}
	return _clan_fortune_history_array;
}
////////////////////////////////
//Existance
boolean ClanFortuneEntries_Exists(string template)
{
	if(ClanFortuneEntries_Array() contains template)
	{
		print_html("Existence Check: Clan Fortune Template %s exists.",template);
		return true;
	}
	else
	{
		print_html("Existence Check: Clan Fortune Template %s not found.", template);
		return false;
	}
	return false;
}
////////////////////////////////
//Set/Add Records
boolean Set_ClanFortuneTemplate(string name, string fav_food, string fav_char, string fav_word, boolean override)
{
	if(!ClanFortuneEntries_Exists(name) || override)
	{
		clan_fortune_entries new_template;
		new_template.name = name;
		new_template.fav_food = fav_food;
		new_template.fav_char = fav_char;
		new_template.fav_word = fav_word;

		ClanFortuneEntries_Array()[name] = new_template;

		SaveClanFortuneEntries();
		print_html_list("Clan Fortune Template %s made with terms %s", new_template.name, string [int]{new_template.fav_food, new_template.fav_char, new_template.fav_word});
		return true;
	}
	else
	{
		print_html("Error: Can't make Clan Fortune Template %s.  It already exists.", name);
	}
	return false;
}

boolean Add_Transaction(int request_number, string receiver, clan_fortune_entries entries)
{
	clan_fortune_transaction new_transaction;
	new_transaction.sender_info = get_player_info();
	new_transaction.send_date = today_to_string();
	new_transaction.send_time = time_to_string().to_time();
	new_transaction.send_date_game = gameday_to_string();
	new_transaction.request_number = request_number;
	new_transaction.receiver_name = receiver;
	ClanFortuneHistory_Array()[new_transaction.send_date, request_number] = new_transaction;
	
	SaveClanFortuneHistory();
	return true;
}
boolean Add_Transaction(int request_number, string receiver, string fav_food, string fav_char, string fav_word)
{
	clan_fortune_entries entry;
	entry.fav_food = fav_food;
	entry.fav_char = fav_char;
	entry.fav_word = fav_word;
	return Add_Transaction(request_number, receiver, entry);
}

/*
boolean Finish_Transaction(clan_fortune_transaction response_info, clan_fortune_entries entry, string [int] received_items)
{
	mail [string,string,int] cf_mail = get_clanfortune_mail().sort_mail_by_name_date();
	string check_date = today_to_string();
	for back_days from 7 to 0 by -1
	{
		string check_date = previous_day(today_to_string(),back_days);
		if(ClanFortuneHistory_Array() contains check_date)
		{
			mail [int] candidates;
			foreach num in cf_mail
			{
				if(cf_mail[num].date.to_int() >= check_date.to_int())
				{
					candidates()
				}
			}
		}
		
	}
	
	
	
	return true;
}
*/
///////////////////////
//Info Array
cmd_info [string] clan_fortune_info()
{
	cmd_info [string] cf_info;

	//susie
	cmd_info susie;
	susie.inputs["susie, the arena master (npc)"] = true;
	susie.inputs["susie"] = true;
	susie.inputs["arena master"] = true;
	susie.inputs["susie, the arena master"] = true;
	susie.inputs["susie, the arena master (npc)"] = true;
	susie.inputs["familiar"] = true;
	susie.output = "-1";
	susie.description = "A Girl Named Sue: +5 familiar weight, +10 familiar damage, +5 familiar xp/fight";
	
	cf_info["susie"] = susie;

	//hangk
	cmd_info hangk;
	hangk.inputs["hangk"] = true;
	hangk.inputs["hangk (npc)"] = true;
	hangk.inputs["item"] = true;
	hangk.inputs["food"] = true;
	hangk.inputs["booze"] = true;
	hangk.output = "-2";
	hangk.description = "There's No N In Love:  +50% food drops, +50% booze drops, +50% item drops";
	
	cf_info["hangk"] = hangk;

	//meatsmith
	cmd_info meatsmith;
	meatsmith.inputs["meatsmith"] = true;
	meatsmith.inputs["meatsmith (npc)"] = true;
	meatsmith.inputs["the meatsmith (npc)"] = true;
	meatsmith.inputs["the meatsmith"] = true;
	meatsmith.inputs["meat"] = true;
	meatsmith.inputs["gear"] = true;
	meatsmith.output = "-3";
	meatsmith.description = "Meet The Meat:  +50% gear drops, +100% meat drops";
	
	cf_info["meatsmith"] = meatsmith;

	//gunther
	cmd_info gunther;
	gunther.inputs["gunther"] = true;
	gunther.inputs["gunther, lord of the smackdown (npc)"] = true;
	gunther.inputs["lord of the smackdown"] = true;
	gunther.inputs["mus"] = true;
	gunther.inputs["muscle"] = true;
	gunther.inputs["hp"] = true;
	gunther.output = "-4";
	gunther.description = "Gunther Than Thou:  +100% mus, +50% HP, +5 mus stats/fight";
	
	cf_info["gunther"] = gunther;

	//gorgonzola
	cmd_info gorgonzola;
	gorgonzola.inputs["gorgonzola"] = true;
	gorgonzola.inputs["gorgonzola, the chief chef (npc)"] = true;
	gorgonzola.inputs["the chief chef"] = true;
	gorgonzola.inputs["myst"] = true;
	gorgonzola.inputs["mysticality"] = true;
	gorgonzola.inputs["mp"] = true;
	gorgonzola.output = "-5";
	gorgonzola.description = "Everybody Calls Him Gorgon:  +100% myst, +50% MP, +5 myst stats/fight";
	
	cf_info["gorgonzola"] = gorgonzola;

	//shifty
	cmd_info shifty;
	shifty.inputs["shifty"] = true;
	shifty.inputs["shifty, the thief chief (npc)"] = true;
	shifty.inputs["the hief chief "] = true;
	shifty.inputs["mox"] = true;
	shifty.inputs["moxie"] = true;
	shifty.inputs["init"] = true;
	shifty.inputs["initiative"] = true;
	shifty.output = "-6";
	shifty.description = "They Call Me Shifty:  +100% mox, +50% combat init, +5 mox stats/fight";
	
	cf_info["shifty"] = shifty;

	return cf_info;

}
///////////////////////
//help
void print_clan_fortune_help()
{
	cmd_info [string] cf_info = clan_fortune_info();

	print("command in form npc|clan,name|id|choice,food,name,word");
	print("Basically, for npc options: npc,name|choice,food,name,word");
	print("for clan member options: clan,id,food,name,word");
	print("...or: clan,name,food,name,word");
	print("");
	print("For npc options, the following can be entered:");
	foreach name in cf_info
	{
		print_html_list("For NPC %s name/choice = %s",name,cf_info[name].inputs);
		print_html("Results in %s",cf_info[name].description);
	}
	print("");
	print("");
	print("Making default choices:");
	print("defaults,1st contact,<name>  -- saves <name> as first contact when sending requests");
	print("defaults,2nd contact,<name>  -- saves <name> as second contact when sending requests");
	print("defaults,3rd contact,<name>  -- saves <name> as third contact when sending requests");
	print("defaults,1st response,<name>  -- saves <name> as first answer when when responding to requests");
	print("defaults,2nd response,<name>  -- saves <name> as second answer when when responding to requests");
	print("defaults,3rd response,<name>  -- saves <name> as third answer when when responding to requests");
	print("defaults,1st answer,<name>  -- saves <name> as first answer when sending requests");
	print("defaults,2nd answer,<name>  -- saves <name> as second answer when sending requests");
	print("defaults,3rd answer,<name>  -- saves <name> as third answer when sending requests");
	print("");
	print("print defaults -- prints all set defaults");
	print("");
	print("");
	print("quicksend -- sends default answers to each default contact in order");
	print("respond all -- responds to all waiting requests with default answers");
	print("");
	print("status -- shows current status on how many requests you have made and who is waiting for responses");


}
///////////////////////
//Initialize visit

clan_fortune_status init_fortune_visit()
{
	string entry = visit_url("clan_viplounge.php?preaction=lovetester");
	clan_fortune_status my_status;

	string [int][int] request_array = entry.group_string("(clan_viplounge.php\\?preaction=testlove&testlove=\\d*)\">(.*?)</a>");

	foreach num in request_array
	{
		string req_url = request_array[num][1];
		string name = request_array[num][2];
		
		my_status.requests[name] = req_url;
	}
	matcher m = create_matcher("You may still consult Madame Zatara about your relationship with a clanmate (\\d) times? today", entry);
	if(m.find())
	{
		my_status.remaining = m.group(1).to_int();
	}
	else
	{
		my_status.remaining = 0;
	}
	return my_status;
}

mail [int] get_clanfortune_mail()
{
	mail [int] my_mail = get_mail();

	mail [int] fortune_mail;
	int index = 0;
	foreach num in my_mail
	{
		if (my_mail[num].body.contains_rgx("completed your relationship fortune test!.*?Here are your results:"))
		{
			fortune_mail[index] = my_mail[num];
			index++;
		}
	}

	return fortune_mail;
}

///////////////////////
//Print Output
void print_fortune_status()
{
	clan_fortune_status my_status = init_fortune_visit();
	print_html("Incoming Fortune Requests");
	foreach name in my_status.requests
	{
		print_html("%s with url: %s", string[int]{name,my_status.requests[name]});
	}
	print_html("Remaining Outgoing Fortune Requests: %s ", my_status.remaining.to_string());
}

void print_clanfortune_mail()
{
	mail [int] my_mail = get_clanfortune_mail();

	print_html("There are a total of %s fortune messages", my_mail.count().to_string());
	foreach num in my_mail
	{
		print_html("Return Fortune #%s",num.to_string());
		print_html("from: %s (%s)", string[int]{my_mail[num].from_player,my_mail[num].from_id});
		print_html("date: %s", my_mail[num].date);
		print_html("day: %s", my_mail[num].day);
		print_html("time: %s", my_mail[num].time);
		print_html(my_mail[num].body);
		print_html_list("Attached Items: %s", my_mail[num].item_strings);
		print("");
	}
}

void Print_Fortune_Template(clan_fortune_entries template)
{
	print_html_list("%s, entries: %s", template.name, string[int]{template.fav_food,template.fav_char, template.fav_word});
}
void Print_Fortune_Template(string template_name)
{
	if(ClanFortuneEntries_Exists(template_name))
	{
		Print_Fortune_Template(template_name);
	}
	else
	{
		print_html("Clan Fortune Error:  Requested Template %s does not exist", template_name);
	}
}
void Print_Fortune_Templates()
{
	print_html("<b><u>Clan Fortune Templates</b></u>");
	foreach name in ClanFortuneEntries_Array()
	{
		Print_Fortune_Template(ClanFortuneEntries_Array()[name]);
	}

}

void print_clanfortune_defaults()
{
	print_html("Default 1st contact: %s", get_property("clanfortune_1stContact"));
	print_html("Default 2nd contact: %s", get_property("clanfortune_2ndContact"));
	print_html("Default 3rd contact: %s", get_property("clanfortune_3rdContact"));
	print_html("Default 1st response: %s", get_property("clanfortune_1stResponse"));
	print_html("Default 2nd response: %s", get_property("clanfortune_2ndResponse"));
	print_html("Default 3rd response: %s", get_property("clanfortune_3rdResponse"));
	print_html("Default 1st answer: %s", get_property("clanfortune_1stAnswer"));
	print_html("Default 2nd answer: %s", get_property("clanfortune_2ndAnswer"));
	print_html("Default 3rd answer: %s", get_property("clanfortune_3rdAnswer"));
}

///////////////////////
//Initiating Fortunes
	///////////////////////
	//Send to NPC
string npc_fortune(int npc_id, string fav_food, string fav_char, string fav_word)
{
	string [string] choices;
	choices["which"] = npc_id.to_string(); //doing an npc member
	choices["q1"] = fav_food;
	choices["q2"] = fav_char;
	choices["q3"] = fav_word;
	init_fortune_visit();
	return visit_choicephp(1278,choices);
}

string npc_fortune_select(string npc_string, string fav_food, string fav_char, string fav_word)
{
	cmd_info [string] cf_info = clan_fortune_info();
	foreach name in cf_info
	{
		foreach cmd in cf_info[name].inputs
		{
			if(npc_string.to_lower_case() == cmd)
			{
				return npc_fortune(cf_info[name].output.to_int(), fav_food, fav_char, fav_word);
			}
		}
	}
	return "";
}

string npc_fortune_select(string npc_string, clan_fortune_entries template)
{
	return npc_fortune_select(npc_string,template.fav_food,template.fav_char,template.fav_word);
}

string npc_fortune_select(string npc_string, string template_name)
{
	if(ClanFortuneEntries_Exists(template_name))
	{
		return npc_fortune_select(npc_string, ClanFortuneEntries_Array()[template_name]);
	}
	else
	{
		print_html("Clan Fortune Error:  Requested Template %s does not exist", template_name);
	}
	return "";
}

	///////////////////////
	//Send to Name

string clan_member_fortune(string member, string fav_food, string fav_char, string fav_word)
{
	string [string] choices;
	choices["which"] = "1"; //doing a clan member
	choices["whichid"] = member;//clan member id
	choices["q1"] = fav_food;
	choices["q2"] = fav_char;
	choices["q3"] = fav_word;
	clan_fortune_status my_status = init_fortune_visit();
	if(my_status.remaining != 0)
	{
		if(get_property("record_clan_fortune_info") == "true")
		{
			Add_Transaction(4 - my_status.remaining, member, fav_food, fav_char, fav_word);
		}
		string html = visit_choicephp(1278,choices);
		print_html_list("Sent fortune request #%s to %s with answers: %s (food), %s (character), %s (word)", string[int]{my_status.remaining.to_string(), member, fav_food,fav_char,fav_word});
		return html;
	}
	else
	{
		print("No more consultations left today");
	}
	return "";
}
string clan_member_fortune(int id, string fav_food, string fav_char, string fav_word)
{
	return clan_member_fortune(id.to_string(),fav_food,fav_char,fav_word);
}

string clan_member_fortune(string member, clan_fortune_entries template)
{
	return clan_member_fortune(member,template.fav_food,template.fav_char,template.fav_word);
}
string clan_member_fortune(int id, clan_fortune_entries template)
{
	return clan_member_fortune(id.to_string(), template);
}

string clan_member_fortune(string member, string template_name)
{
	if(ClanFortuneEntries_Exists(template_name))
	{
		return clan_member_fortune(member, ClanFortuneEntries_Array()[template_name]);
	}
	else
	{
		print_html("Clan Fortune Error:  Requested Template %s does not exist", template_name);
	}
	return "";
}
string clan_member_fortune(int id, string template_name)
{
	return clan_member_fortune(id.to_string(), template_name);
}

string clan_member_fortune(string name)
{
	string fav_food = get_property("clanfortune_1stAnswer");
	string fav_char = get_property("clanfortune_2ndAnswer");
	string fav_word = get_property("clanfortune_3rdAnswer");
	
	return clan_member_fortune(name,fav_food,fav_char,fav_word);
}

///////////////////////
//Returning Fortunes
string process_return_fortune(string url, string fav_food, string fav_char, string fav_word)
{
	buffer url_text;
	url_text.append(url);
	url_text.append("&pwd&option=1");

	string [string] choices;
	choices["q1"] = fav_food;
	choices["q2"] = fav_char;
	choices["q3"] = fav_word;	
	foreach response in choices
	{
		url_text.append("&");
		url_text.append(response);
		url_text.append("=");
		url_text.append(choices[response]);
	}
	//print(url_text);
	return visit_url(url_text,true);
}

	///////////////////////
	//Return to Name
string return_fortune(string name, string fav_food, string fav_char, string fav_word)
{
	clan_fortune_status my_status = init_fortune_visit();
	string response;
	if(my_status.requests contains name)
	{
		string response_url = my_status.requests[name];
		response_url = response_url.replace_string("preaction\=testlove","preaction\=dotestlove");
		//print(response_url);
		response = process_return_fortune(response_url,fav_food,fav_char,fav_word);
	}
	else
	{
		abort("Responding to Fortune Request Error! Invalid name provided: " + name);
	}
	print_html_list("Sent response to %s with responses: %s", name, string[int]{fav_food,fav_char,fav_word});
	return response;
}
string return_fortune(string name, clan_fortune_entries template)
{
	return return_fortune(name, template.fav_food,template.fav_char,template.fav_word);
}
string return_fortune(string name, string template_name)
{
	if(ClanFortuneEntries_Exists(template_name))
	{
		return return_fortune(name, ClanFortuneEntries_Array()[template_name]);
	}
	else
	{
		print_html("Clan Fortune Error:  Requested Template %s does not exist", template_name);
	}
	return "";
}

string return_fortune(string name)
{
	string fav_food = get_property("clanfortune_1stResponse");
	string fav_char = get_property("clanfortune_2ndResponse");
	string fav_word = get_property("clanfortune_3rdResponse");
	
	return return_fortune(name,fav_food,fav_char,fav_word);
}

	///////////////////////
	//Return All
string [string] return_all_fortunes(string fav_food, string fav_char, string fav_word)
{
	clan_fortune_status my_status = init_fortune_visit();
	string [string] responses;
	foreach name in my_status.requests
	{
		responses[name] = return_fortune(name,fav_food,fav_char,fav_word);
	}
	return responses;
}
string [string] return_all_fortunes(clan_fortune_entries template)
{
	return return_all_fortunes(template.fav_food,template.fav_char,template.fav_word);
}
string [string] return_all_fortunes(string template_name)
{
	if(ClanFortuneEntries_Exists(template_name))
	{
		return return_all_fortunes(ClanFortuneEntries_Array()[template_name]);
	}
	else
	{
		print_html("Clan Fortune Error:  Requested Template %s does not exist", template_name);
	}
	string [string] empty;
	return empty;
}

string return_all_fortunes()
{
	string fav_food = get_property("clanfortune_1stResponse");
	string fav_char = get_property("clanfortune_2ndResponse");
	string fav_word = get_property("clanfortune_3rdResponse");
	
	return return_all_fortunes(fav_food,fav_char,fav_word);
}

///////////////////////
//Parsing Command Line
void clanfortune_parse(string command)
{
	string [int] cmd_array = split_string(command,",");
	string response;
	string [int] subarray;
	switch(cmd_array[0].to_lower_case())
	{
		case "help":
		case "?":
			print_clan_fortune_help();
			break;
		case "npc":
			switch(cmd_array.count())
			{
				case 2:
					response = npc_fortune_select(cmd_array[1],"send");
					break;
				case 3:
					response = npc_fortune_select(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = npc_fortune_select(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			//print_html(response);
			break;
		case "clan":
			switch(cmd_array.count())
			{
				case 3:
					response = clan_member_fortune(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = clan_member_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			//print_html(response);
			break;
		case "quicksend":
			string my1stsend = clan_member_fortune(get_property("clanfortune_1stContact"));
			string my2ndsend = clan_member_fortune(get_property("clanfortune_2ndContact"));
			string my3rdsend = clan_member_fortune(get_property("clanfortune_3rdContact"));
			break;
		case "status":
			print_fortune_status();
			break;
		case "respond":
		case "return":
			switch(cmd_array.count())
			{
				case 3:
					response = return_fortune(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = return_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			return_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
			break;
		case "respond all":
		case "return all":
			switch(cmd_array.count())
			{
				case 1:
					return_all_fortunes();
					break;
				case 2:
					response = return_all_fortunes(cmd_array[1]);
					break;
				case 4:
					response = return_all_fortunes(cmd_array[1],cmd_array[2],cmd_array[3]);
					break;
			}
			break;
		case "mail":
			print_clanfortune_mail();
			break;
		case "write template":
		case "make template":
		case "mt":
		case "wt":
			Set_ClanFortuneTemplate(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4],false);
			break;
		case "print template":
		case "list template":
		case "lt":
		case "pt":
			switch(cmd_array.count())
			{
				case 1:
					Print_Fortune_Templates();
					break;
				case 2:
					Print_Fortune_Template(cmd_array[1]);
					break;
			}
			break;
		case "favs":
			string [string] fav_consumes = get_favorite_consumes();
			print(fav_consumes["food"]);
			print(fav_consumes["booze"]);
			break;
		case "prevday":
			print(previous_day(cmd_array[1]));
			break;
		case "record":
			switch(cmd_array.count())
			{
				case 1:
					print_html("Recording status: ", get_property("record_clan_fortune_info"));
					break;
				case 2:
					switch(cmd_array[1])
					{
						case "on":
							set_property("record_clan_fortune_info","true");
							print_html("Recording status: %s", get_property("record_clan_fortune_info"));
							break;
						case "off":
							set_property("record_clan_fortune_info","false");
							print_html("Recording status: %s", get_property("record_clan_fortune_info"));
							break;
						default:
							print_html("Record command not recognized");
							break;
					}
					
					break;
				default:
					print_html("Record command not recognized");
					break;
			}
			break;
		case "defaults":
			switch(cmd_array[1])
			{
				case "1st contact":
					set_property("clanfortune_1stContact",cmd_array[2]);
					print_html("Default 1st contact: %s", get_property("clanfortune_1stContact"));
					break;
				case "2nd contact":
					set_property("clanfortune_2ndContact",cmd_array[2]);
					print_html("Default 2nd contact: %s", get_property("clanfortune_2ndContact"));
					break;
				case "3rd contact":
					set_property("clanfortune_3rdContact",cmd_array[2]);
					print_html("Default 3rd contact: %s", get_property("clanfortune_3rdContact"));
					break;
				case "1st response":
					set_property("clanfortune_1stResponse",cmd_array[2]);
					print_html("Default 1st response: %s", get_property("clanfortune_1stResponse"));
					break;
				case "2nd response":
					set_property("clanfortune_2ndResponse",cmd_array[2]);
					print_html("Default 2nd response: %s", get_property("clanfortune_2ndResponse"));
					break;
				case "3rd response":
					set_property("clanfortune_3rdResponse",cmd_array[2]);
					print_html("Default 3rd response: %s", get_property("clanfortune_3rdResponse"));
					break;
				case "1st answer":
					set_property("clanfortune_1stAnswer",cmd_array[2]);
					print_html("Default 1st answer: %s", get_property("clanfortune_1stAnswer"));
					break;
				case "2nd answer":
					set_property("clanfortune_2ndAnswer",cmd_array[2]);
					print_html("Default 2nd answer: %s", get_property("clanfortune_2ndAnswer"));
					break;
				case "3rd answer":
					set_property("clanfortune_3rdAnswer",cmd_array[2]);
					print_html("Default 3rd answer: %s", get_property("clanfortune_3rdAnswer"));
					break;
				case "info":
					set_property("clanfortune_1stResponse","beer");
					set_property("clanfortune_2ndResponse","robin");
					set_property("clanfortune_3rdResponse","thin");
					set_property("clanfortune_1stAnswer","pizza");
					set_property("clanfortune_2ndAnswer","batman");
					set_property("clanfortune_3rdAnswer","thick");
					print_clanfortune_defaults();					
					break;
				default:
					print_html("%s is not default setting", cmd_array[1]);
					break;
			}
			break;
		case "print defaults":
		case "list defaults":
			print_clanfortune_defaults();
			break;
		case "quick defaults":
			set_property("clanfortune_1stContact","AverageChat");
			if(my_name().to_lower_case() == "rabbitfoot")
			{
				set_property("clanfortune_2ndContact","meowserio");
				set_property("clanfortune_3rdContact","Stewbeef");
			}
			else if(my_name().to_lower_case() == "meowserio")
			{
				set_property("clanfortune_2ndContact","Rabbitfoot");
				set_property("clanfortune_3rdContact","Stewbeef");
			}
			else
			{
				set_property("clanfortune_2ndContact","Rabbitfoot");
				set_property("clanfortune_3rdContact","meowserio");
			
			}
			set_property("clanfortune_1stResponse","beer");
			set_property("clanfortune_2ndResponse","robin");
			set_property("clanfortune_3rdResponse","thin");
			set_property("clanfortune_1stAnswer","pizza");
			set_property("clanfortune_2ndAnswer","batman");
			set_property("clanfortune_3rdAnswer","thick");
			
			
			print_clanfortune_defaults();
			break;
		default:
			print("invalid command, type ? or help for help");
			break;
	}
/*	
	switch(cmd_array[0].to_lower_case())
	{
		case "help":
		case "?":
			print_clan_fortune_help();
			break;
		case "npc":
			switch(cmd_array.count())
			{
				case 2:
					response = npc_fortune_select(cmd_array[1],"send");
					break;
				case 3:
					response = npc_fortune_select(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = npc_fortune_select(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			//print_html(response);
			break;
		case "clan":
			switch(cmd_array.count())
			{
				case 3:
					response = clan_member_fortune(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = clan_member_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			//print_html(response);
			break;
		case "quicksend":
			string my1stsend = clan_member_fortune(get_property("clanfortune_1stContact"));
			string my2ndsend = clan_member_fortune(get_property("clanfortune_2ndContact"));
			string my3rdsend = clan_member_fortune(get_property("clanfortune_3rdContact"));
			break;
		case "status":
			print_fortune_status();
			break;
		case "respond":
		case "return":
			switch(cmd_array.count())
			{
				case 3:
					response = return_fortune(cmd_array[1],cmd_array[2]);
					break;
				case 5:
					response = return_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
					break;
			}
			return_fortune(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4]);
			break;
		case "respond all":
		case "return all":
			switch(cmd_array.count())
			{
				case 1:
					return_all_fortunes();
					break;
				case 2:
					response = return_all_fortunes(cmd_array[1]);
					break;
				case 4:
					response = return_all_fortunes(cmd_array[1],cmd_array[2],cmd_array[3]);
					break;
			}
			break;
		case "mail":
			print_clanfortune_mail();
			break;
		case "write template":
		case "make template":
		case "mt":
		case "wt":
			Set_ClanFortuneTemplate(cmd_array[1],cmd_array[2],cmd_array[3],cmd_array[4],false);
			break;
		case "print template":
		case "list template":
		case "lt":
		case "pt":
			switch(cmd_array.count())
			{
				case 1:
					Print_Fortune_Templates();
					break;
				case 2:
					Print_Fortune_Template(cmd_array[1]);
					break;
			}
			break;
		case "favs":
			string [string] fav_consumes = get_favorite_consumes();
			print(fav_consumes["food"]);
			print(fav_consumes["booze"]);
			break;
		case "prevday":
			print(previous_day(cmd_array[1]));
			break;
		case "record":
			switch(cmd_array.count())
			{
				case 1:
					print_html("Recording status: ", get_property("record_clan_fortune_info"));
					break;
				case 2:
					switch(cmd_array[1])
					{
						case "on":
							set_property("record_clan_fortune_info","true");
							print_html("Recording status: %s", get_property("record_clan_fortune_info"));
							break;
						case "off":
							set_property("record_clan_fortune_info","false");
							print_html("Recording status: %s", get_property("record_clan_fortune_info"));
							break;
						default:
							print_html("Record command not recognized");
							break;
					}
					
					break;
				default:
					print_html("Record command not recognized");
					break;
			}
			break;
		case "defaults":
			switch(cmd_array[1])
			{
				case "1st contact":
					set_property("clanfortune_1stContact",cmd_array[2]);
					print_html("Default 1st contact: %s", get_property("clanfortune_1stContact"));
					break;
				case "2nd contact":
					set_property("clanfortune_2ndContact",cmd_array[2]);
					print_html("Default 2nd contact: %s", get_property("clanfortune_2ndContact"));
					break;
				case "3rd contact":
					set_property("clanfortune_3rdContact",cmd_array[2]);
					print_html("Default 3rd contact: %s", get_property("clanfortune_3rdContact"));
					break;
				case "1st response":
					set_property("clanfortune_1stResponse",cmd_array[2]);
					print_html("Default 1st response: %s", get_property("clanfortune_1stResponse"));
					break;
				case "2nd response":
					set_property("clanfortune_2ndResponse",cmd_array[2]);
					print_html("Default 2nd response: %s", get_property("clanfortune_2ndResponse"));
					break;
				case "3rd response":
					set_property("clanfortune_3rdResponse",cmd_array[2]);
					print_html("Default 3rd response: %s", get_property("clanfortune_3rdResponse"));
					break;
				case "1st answer":
					set_property("clanfortune_1stAnswer",cmd_array[2]);
					print_html("Default 1st answer: %s", get_property("clanfortune_1stAnswer"));
					break;
				case "2nd answer":
					set_property("clanfortune_2ndAnswer",cmd_array[2]);
					print_html("Default 2nd answer: %s", get_property("clanfortune_2ndAnswer"));
					break;
				case "3rd answer":
					set_property("clanfortune_3rdAnswer",cmd_array[2]);
					print_html("Default 3rd answer: %s", get_property("clanfortune_3rdAnswer"));
					break;
				default:
					print_html("%s is not default setting", cmd_array[1]);
					break;
			}
			break;
		case "print defaults":
		case "list defaults":
			print_clanfortune_defaults();
			break;
		case "quick defaults":
			set_property("clanfortune_1stContact","AverageChat");
			if(my_name().to_lower_case() == "rabbitfoot")
			{
				set_property("clanfortune_2ndContact","meowserio");
				set_property("clanfortune_3rdContact","Stewbeef");
			}
			else if(my_name().to_lower_case() == "meowserio")
			{
				set_property("clanfortune_2ndContact","Rabbitfoot");
				set_property("clanfortune_3rdContact","Stewbeef");
			}
			else
			{
				set_property("clanfortune_2ndContact","Rabbitfoot");
				set_property("clanfortune_3rdContact","meowserio");
			
			}
			set_property("clanfortune_1stResponse","beer");
			set_property("clanfortune_2ndResponse","robin");
			set_property("clanfortune_3rdResponse","thin");
			set_property("clanfortune_1stAnswer","pizza");
			set_property("clanfortune_2ndAnswer","batman");
			set_property("clanfortune_3rdAnswer","thick");
			
			
			print_clanfortune_defaults();
			break;
		default:
			print("invalid command, type ? or help for help");
			break;
	}
*/
}

void main(string command)
{
	clanfortune_parse(command);
}