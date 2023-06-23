/datum/karmatic_factor/lonely
	description = "<span class='warning'>I feel lonely... I better talk to somebody, for real.</span>"
	mood_change = -6

/datum/karmatic_factor/very_lonely
	description = "<span class='boldwarning'>Am I the loneliest being in the universe?... I need to be heard!</span>"
	mood_change = -12

// Food
/datum/karmatic_factor/junk_food
	description = "<span class='warning'>This food is hurting me!</span>"
	mood_change = -2
	timeout = 3 MINUTES

/datum/karmatic_factor/natural_food
	description = "<span class='nicegreen'>Very nice to eat wholesome and natural food.</span>"
	mood_change = 1
	timeout = 3 MINUTES

/datum/karmatic_factor/tasty_food
	description = "<span class='nicegreen'>This food tastes good, I like it.</span>"
	mood_change = 2
	timeout = 3 MINUTES

/datum/karmatic_factor/very_tasty_food
	description = "<span class='bold nicegreen'>This food tastes just divine!</span>"
	mood_change = 4
	timeout = 5 MINUTES


//well it's bascially their need to see heads of staff i guess
/datum/karmatic_factor/blueshield
	description = "<span class='warning'>Нужно проверить моих подопечных.</span>"
	mood_change = -6

/datum/karmatic_factor/blueshield/add_effects()
	var/list/to_protect = list()
	for(var/mob/living/carbon/human/player as anything in human_list)
		if(player.mind && (player.mind.assigned_role in protected_by_blueshield_list))
			to_protect += player.mind

	if(!to_protect.len)
		mood_change = 0
		description = "<span class='notice'>А где главы?</span>"

