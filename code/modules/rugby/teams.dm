var/global/list/default_max_players = 16
var/global/list/default_class_choices = list(
	/datum/action/palette_choice/rugby/lineman = list("min" = 0, "max" = 16),
	/datum/action/palette_choice/rugby/blitzer = list("min" = 0, "max" = 4),
	/datum/action/palette_choice/rugby/catcher = list("min" = 0, "max" = 4),
	/datum/action/palette_choice/rugby/thrower = list("min" = 0, "max" = 4)
)


/datum/player
	var/number
	var/mob/living/model
	var/class = "Generic"

/datum/player/New(model)
	src.model = model



/datum/team
	var/name
	var/role

	var/default_class

	var/list/datum/action/palette_choice/class_choices = list()
	var/list/class_requirements = list()

	var/list/class_name_to_loadout = list()

	var/mob/living/coach
	var/list/mob/living/players
	var/list/mob/living/reserves

	var/pitch_area_type

	var/list/pos_numbers
	var/max_number = 0

	var/max_players

	var/tablet_icon_state = "pda"

/datum/team/New()
	var/list/load_choices_from = global.default_class_choices
	for(var/class_type in load_choices_from)
		var/datum/action/palette_choice/PC = class_type
		var/class_name = initial(PC.choice_value)

		class_requirements[class_name] = load_choices_from[class_type]

		class_choices += class_type

	max_players = default_max_players

/datum/team/proc/on_destroy(datum/source)
	remove_player(source)
	if(source == coach)
		unset_coach()

/datum/team/proc/set_coach(mob/living/L)
	coach = L
	if(get_player(L))
		return

	if(role)
		spawn_coach()

	RegisterSignal(L, list(COMSIG_PARENT_QDELETED), .proc/on_destroy)

/datum/team/proc/unset_coach()
	UnregisterSignal(coach, list(COMSIG_PARENT_QDELETED))
	coach = null

/datum/team/proc/add_player(mob/living/L)
	if(get_player(L))
		return

	var/datum/player/P = new /datum/player(L)
	LAZYADD(players, P)
	LAZYADD(reserves, P)
	if(coach == L)
		return
	RegisterSignal(L, list(COMSIG_PARENT_QDELETED), .proc/on_destroy)

/datum/team/proc/remove_player(mob/living/L)
	var/datum/player/to_remove = get_player(L)
	if(!to_remove)
		return

	LAZYADD(pos_numbers, to_remove.number)

	UnregisterSignal(L, list(COMSIG_PARENT_QDELETED))
	LAZYREMOVE(players, to_remove)
	LAZYREMOVE(reserves, to_remove)

/datum/team/proc/add_number()
	if(pos_numbers)
		var/num = pos_numbers[1]
		LAZYREMOVE(pos_numbers, num)
		return num

	max_number += 1
	return max_number

/datum/team/proc/remove_number(n)
	if(n == max_number)
		max_number -= 1
		return

	LAZYADD(pos_numbers, n)

/datum/team/proc/get_player(mob/L)
	for(var/p in players)
		var/datum/player/P = p
		if(P.model == L)
			return P
	return null

/datum/team/proc/get_player_num(n)
	for(var/p in players)
		var/datum/player/P = p
		if(P.number == n)
			return P
	return null

/datum/team/proc/get_spawn_areas()
	. = list()
	for(var/area/rugby/pitch/R in get_areas(/area/rugby/pitch))
		if(R.team != role)
			continue
		. += R

/datum/team/proc/spawn_coach()
	if(!coach)
		return

	for(var/O in landmarks_list)
		var/obj/effect/landmark/rugby/R = O
		if(!istype(R))
			continue

		if(R.name == "Coach Spawn")
			if(role == R.team)
				coach.forceMove(get_turf(R))
