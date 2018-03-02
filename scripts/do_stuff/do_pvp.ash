script "do_pvp.ash";

void main()
{
	if(pvp_attacks_left() > 0)
	{
		//maximize("hot spell damage, hot damage",false);
		string pvp = visit_url("peevpee.php?place=fight");
		if(pvp.contains_text("shatter the hippy stone"))
		{
			pvp = visit_url("peevpee.php?confirm=on&action=smashstone&pwd");
		}
		if(pvp.contains_text("Pledge allegiance to"))
		{
			visit_url("peevpee.php?action=pledge&place=fight&pwd");
		}
		item metade = to_item(9513); //meteorite-ade
		int metade_to_use = min(3,item_amount(metade));
		use(metade_to_use,metade);
		//cli_execute("pvp fame That Britney Spears Number");
		outfit("birthday suit");
		cli_execute("pvp fame Barely Dressed");
		
	}
}