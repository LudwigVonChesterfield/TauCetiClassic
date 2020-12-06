/area/rugby
	icon = 'code/modules/rugby/rugby.dmi'
	requires_power = 0
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/rugby/pitch
	name = "Pitch"
	icon_state = "pitch_area"
	var/team
	var/min_spawns = 0
	var/max_spawns = 16

/area/rugby/pitch/proc/can_place(class_name, datum/team/T, mob/user)
	if(team != T.role)
		if(user)
			to_chat(user, "<span class='warning'>You can not place positionals in opponent's part of the field!</span>")
		return FALSE

	var/class_am = get_class_amount(class_name)
	if(class_am == T.class_requirements[class_name]["max"])
		if(user)
			to_chat(user, "<span class='warning'>Too many of [class_name]([class_am]/[T.class_requirements[class_name]["max"]])!</span>")
		return FALSE

	var/spawns_am = get_spawns_amount()
	if(spawns_am == max_spawns)
		if(user)
			to_chat(user, "<span class='warning'>Too many players in [name]([spawns_am]/[max_spawns])!</span>")
		return FALSE

	return TRUE

/area/rugby/pitch/proc/check_requirements(datum/team/T, mob/user)
	for(var/class_name in T.class_requirements)
		var/class_am = get_class_amount(class_name)
		if(class_am < T.class_requirements[class_name]["min"])
			if(user)
				to_chat(user, "<span class='warning'>Not enough [class_name]([class_am]/[T.class_requirements[class_name]["min"]])!</span>")
			return FALSE

	var/spawns_am = get_spawns_amount()
	if(spawns_am < min_spawns)
		if(user)
			to_chat(user, "<span class='warning'>Not enough players in [name]([spawns_am]/[min_spawns])!</span>")
		return FALSE

	return TRUE

/area/rugby/pitch/proc/get_spawns_amount()
	. = 0
	for(var/turf/T in contents)
		for(var/obj/effect/landmark/rugby/R in T)
			if(R.name != "Spawn Position")
				continue

			. += 1

/area/rugby/pitch/proc/get_class_amount(class_name)
	. = 0
	for(var/turf/T in contents)
		for(var/obj/effect/landmark/rugby/R in T)
			if(R.name != "Spawn Position")
				continue
			if(R.data["Class"] != class_name)
				continue

			. += 1

/area/rugby/pitch/west_wide_zone
	name = "West Wide Zone"

	max_spawns = 2

/area/rugby/pitch/east_wide_zone
	name = "East Wide Zone"

	max_spawns = 2

/area/rugby/pitch/line_of_scrimmage
	name = "Line of Scrimmage"

	min_spawns = 3

/area/rugby/pitch/west_wide_zone/red
	icon_state = "red_west_wide_zone"
	team = "red"

/area/rugby/pitch/west_wide_zone/blue
	icon_state = "blue_west_wide_zone"
	team = "blue"

/area/rugby/pitch/east_wide_zone/red
	icon_state = "red_east_wide_zone"
	team = "red"

/area/rugby/pitch/east_wide_zone/blue
	icon_state = "blue_east_wide_zone"
	team = "blue"

/area/rugby/pitch/line_of_scrimmage/red
	icon_state = "red_los"
	team = "red"

/area/rugby/pitch/line_of_scrimmage/blue
	icon_state = "blue_los"
	team = "blue"

/area/rugby/end_zone
	var/team

/area/rugby/end_zone/red
	name = "Red end zone"
	icon_state = "red_end_area"
	team = "red"

/area/rugby/end_zone/blue
	name = "Blue end zone"
	icon_state = "blue_end_area"
	team = "blue"

/area/rugby/bounds
	name = "Bounds"
	icon_state = "bounds_area"

/area/rugby/dugout
	name = "Dugout"
	icon_state = "dugout_area"

/area/rugby/spectators
	name = "Spectators"
	icon_state = "spectators_area"

/area/rugby/facility
	name = "Facility"
	icon_state = "facility_area"
