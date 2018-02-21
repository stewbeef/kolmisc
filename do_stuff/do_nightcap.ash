//Nightcap for finishing up drinking when logging off

script "do_nightcap.ash";
include "beefy_tools.ash";

item select_next_drink(int ineb_left, item nightcap, item single, int [int,item] fillers)
{
	
}

boolean finish_drinking(boolean force, boolean test)
{
	if(inebriety_left() < 4 || force)
	{
		int [item] my_drinks =  get_consumables();
		item single_fill;
		int [int, item] fill_up_lists;
		item nightcap;
		foreach it in my_drinks
		{
			if(my_level() >= it.levelreq)
			{
				if(it.adventures > nightcap.adventures)
				{
					nightcap = it;
				}
			}
		}
		print_html("Selected %s as nightcap", nightcap.to_string());
		if(inebriety_left() > 0)
		{
			foreach it in my_drinks
			{
				if(my_level() >= it.levelreq)
				{
					if(inebriety_left() == it.inebriety && it.adventures > single_fill.adventures)
					{
						single_fill = it;
					}
					else if(it.inebriety < inebriety_left())
					{

					}
				}
			}
		}
	}
	else
	{
		print_html("Inebriety is %s out of %s, too much for auto-drinking", string[int]{my_inebriety().to_string(),inebriety_limit().to_string()});
	}
}

void main()
{

}