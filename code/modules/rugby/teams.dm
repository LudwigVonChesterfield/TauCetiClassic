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

/datum/player/New(number, model)
	src.number = number
	src.model = model



/datum/team
	var/name
	var/role

	var/default_class

	var/list/datum/action/palette_choice/class_choices

	var/mob/living/coach
	var/list/mob/living/players
	var/list/mob/living/reserves

	var/landmark_type

	var/list/pos_numbers
	var/max_number = 0

	var/max_players

	var/tablet_icon_state = "pda"

/datum/team/New()
	class_choices = default_class_choices
	max_players = default_max_players

/datum/team/proc/set_coach(mob/living/L)
	coach = L
	RegisterSignal(L, list(COMSIG_PARENT_QDELETED), .proc/unset_coach)

/datum/team/proc/unset_coach()
	UnregisterSignal(coach, list(COMSIG_PARENT_QDELETED))
	coach = null

/datum/team/proc/add_player(mob/living/L)
	if(get_player(L))
		return

	var/number
	if(pos_numbers)
		number = pos_numbers[1]
		pos_numbers.Cut(1, 2)
	else
		number = max_number + 1
		max_number += 1

	var/datum/player/P = new /datum/player(number, L)
	LAZYADD(players, P)
	LAZYADD(reserves, P)
	RegisterSignal(L, list(COMSIG_PARENT_QDELETED), .proc/remove_player)

/datum/team/proc/remove_player(mob/living/L)
	var/datum/player/to_remove
	for(var/p in players)
		var/datum/player/P = p
		if(P.model != L)
			continue
		to_remove = P
		break

	LAZYADD(pos_numbers, to_remove.number)

	UnregisterSignal(L, list(COMSIG_PARENT_QDELETED))
	LAZYREMOVE(players, to_remove)
	LAZYREMOVE(reserves, to_remove)

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
