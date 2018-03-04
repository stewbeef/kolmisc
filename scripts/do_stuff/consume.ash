//Manage consuming food/drink

script "consume.ash";
import "beefy_tools.ash";

skill saucecraft = to_skill(4006); // advanced saucecrafting
item goatmilk = to_item(330); //glass of goats milk
item milkm = to_item(1650); // milk of magnesium
effect gotmilks = to_effect(211); // got milk

effect booze_effect = to_effect(71); // ode to booze effect
skill booze_skill = to_skill(6014); // ode to booze skill



//////////////////////////////////
//Food/Drink Records

record consumable 
{
	item it;
	float efficiency;
};

record consume_candidates
{
	consumable [int, int] drinks; //list of item and amount
	consumable [int, int] eats; //list of item and amount
	consumable [int, int] chews;
};

record consume_list
{
	int [int,item] drinks;
	int [int,item] eats;
	int [int,item] chews;
};

//////////////////////////////////
//Food/Drink Buffs

void GotOde(item it, int number)
{
	if(have_skill(booze_skill))
	{
		if(have_effect(booze_effect) < it.inebriety * number)
		{
			use_skill(booze_skill);
		}
	}

}

void GotMilk(item it, int number)
{
	if(have_effect(gotmilks) < it.fullness * number)
	{
		if(item_amount(milkm) > 0)
		{
			use(1, milkm);
		}
		else if(closet_amount(milkm) > 0)
		{
			take_closet(1,milkm);
			use(1, milkm);
		}
		else if(item_amount(goatmilk) > 0 && have_skill(saucecraft))
		{
			create(1,milkm);
			use(1, milkm);
		}
		else if(closet_amount(goatmilk) > 0 && have_skill(saucecraft))
		{
			take_closet(1,goatmilk);
			create(1,milkm);
			use(1, milkm);
		}
	}
	
}

//////////////////////////////////
//Food/Drink Buffs

consume_candidates GetConsumeCandidates(boolean [int] advcosts)
{
	consumables stuff = get_consumables();

	consumable [int,int] booze_list;

	foreach drink in stuff.booze
	{//to do, add in npc and craftables
		
		consumable new_drink;
		new_drink.it = drink;
		
		//print_html("Drink %s efficiency %s",string[int]{new_drink.it.to_string(),new_drink.efficiency.to_string()});
		foreach advcost in advcosts
		{
			float efficiency = netgain_per_adv(drink,advcost);
			new_drink.efficiency = efficiency;
			int size = booze_list[advcost].count();
			booze_list[advcost,size] = new_drink;
		}
	}

	consumable [int,int] food_list;

	foreach food in stuff.food
	{//to do, add in npc and craftables	
		consumable new_food;
		new_food.it = food;	
		foreach advcost in advcosts
		{
			float efficiency = netgain_per_adv(food,advcost);
			new_food.efficiency = efficiency;
			print("food %s, efficiency %s", string[int]{food.to_string(),efficiency.to_string()});
			int size = food_list[advcost].count();
			food_list[advcost,size] = new_food;
		}
	}
	int stomach =  fullness_left();
	
	consume_candidates my_candidates;
	my_candidates.drinks = booze_list;
	my_candidates.eats = food_list;
	//print("lists complete");
	return my_candidates;

}
/*
item GetNightCap(boolean [int] advcosts)
{

}
*/

consume_list GetConsumeLists(boolean [int] advcosts)
{
	consume_candidates my_candidates = GetConsumeCandidates(advcosts);
	consume_list my_list;
	foreach advcost in my_candidates.drinks
	{
		sort my_candidates.drinks[advcost] by -value.efficiency;
		int liver_space = inebriety_left();
		int cindex = 0;
		while(liver_space > 0 && cindex < my_candidates.drinks[advcost].count())
		{
			item drink = my_candidates.drinks[advcost,cindex].it;
			int space = drink.inebriety;
			//print_html("candidate drink %s",drink.to_string());
			if(space <= liver_space && drink != $item[none])
			{			
				int number = available_amount(drink);
				//print_html("drink %s",drink.to_string());
				int to_drink = min(liver_space / space, number);
				if(to_drink > 0)
				{
					my_list.drinks[advcost,drink] = to_drink;
					liver_space = liver_space -  to_drink * space;
				}
			}
			cindex++;
		}
	}
	foreach advcost in my_candidates.eats
	{
		sort my_candidates.eats[advcost] by -value.efficiency;
		int food_space = fullness_left();
		int cindex = 0;
		while(food_space > 0 && cindex < my_candidates.eats[advcost].count())
		{
			item food = my_candidates.eats[advcost,cindex].it;
			int space = food.fullness;
			if(space <= food_space && food != $item[none])
			{			
				int number = available_amount(food);
				print_html("food %s",food.to_string());
				int to_eat = min(food_space / space, number);
				if(to_eat > 0)
				{
					my_list.eats[advcost,food] = to_eat;
					food_space = food_space -  to_eat * space;
				}
			}
			cindex++;
		}
	}
	return my_list;
}


void DoDrinking(consume_list list, int cost)
{
	print("Drinking...");
	foreach it in list.drinks[cost]
	{
		int number = list.drinks[cost,it];
		GotOde(it, number);
		drink(number,it);
	}
}

void DoEating(consume_list list, int cost)
{
	print("Eating...");
	foreach it in list.eats[cost]
	{
		int number = list.eats[cost,it];
		GotMilk(it, number);
		eat(number,it);
	}
}

void FillUp(int advcost, boolean eat, boolean drink)
{
	boolean[int] costs;
	costs[advcost] = true;
	consume_list mylist = GetConsumeLists(costs);
	if(eat)
	{
		DoEating(mylist,advcost);
	}
	if(drink)
	{
		DoDrinking(mylist,advcost);
	}
}

void PrintOptions(boolean [int] advcosts)
{
	consume_list mylist = GetConsumeLists(advcosts);
	int [int] drink_adventures;
	int [int] food_adventures;

	foreach advcost in advcosts
	{
		print_html("<u>Consuming costing %s per adventure or less...</u>", advcost.to_string());
		print_html("<u>Drinks...<u>");
		
		foreach drink in mylist.drinks[advcost]
		{
			int drink_num = mylist.drinks[advcost,drink];
			print_html("Drink %s of %s",string [int]{drink_num.to_string(),drink.to_string()});
			drink_adventures[advcost] += drink_num * drink.get_adv();
		}
		print_html("Total Adventures from drinking gained: %s", drink_adventures[advcost].to_string());
		print_html("<u>Food...<u>");
		foreach food in mylist.eats[advcost]
		{
			int eat_num = mylist.eats[advcost,food];
			print_html("Eat %s of %s",string [int]{eat_num.to_string(),food.to_string()});
			food_adventures[advcost] += eat_num * food.get_adv();
		}
		print_html("Total Adventures from eating gained: %s", food_adventures[advcost].to_string());
	}
	print_html("<u>Option Summation...</u>");
	foreach advcost in advcosts
	{
		int total_adv = drink_adventures[advcost] + food_adventures[advcost];
		string [int] adv_array = string[int]{advcost,total_adv.to_string(),drink_adventures[advcost].to_string(),food_adventures[advcost].to_string()};
		print_html("For %s adventure cost, %s adventures gained (%s booze, %s food)",adv_array);
	}
}

/////////////////////////
//Main and Parsing
void Parse_Consume_Command(string command)
{
	string [int] command_array = split_string(command,",");
	int paramnum = command_array.count();
	boolean [int] costs_array = StringInt2BooleanInt(command_array.FromX(1));
	switch(command_array[0])
	{
		//case "candidtes":
		//	PrintCandidates(costs_array);
		//break;
		case "list":
			PrintOptions(costs_array);
		break;
		case "food":
		case "eat":
			FillUp(command_array[1].to_int(),true,false);
		break;
		case "booze":
		case "drink":
			FillUp(command_array[1].to_int(),false,true);
		break;
		case "fillup":
		case "both":
			FillUp(command_array[1].to_int(), true, true);
		break;	
	}
}

void main(string command)
{
	Parse_Consume_Command(command);
}

