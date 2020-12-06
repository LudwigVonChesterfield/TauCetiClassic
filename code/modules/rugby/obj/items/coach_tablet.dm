#define CT_STATE_NONE 0
#define CT_STATE_CHOOSE_TEAM_POSITIONS 1

/mob/camera/cursor/pitch
	allowed_area_type = /area/rugby/pitch



/obj/item/device/coach_tablet
	name = "Coach Tablet"
	desc = "placeholder"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_ID | SLOT_FLAGS_BELT

	var/datum/team/team

	var/datum/component/remote_cursor/cursor

/obj/item/device/coach_tablet/atom_init()
	. = ..()
	var/image/view = image('icons/mob/blob.dmi', "marker")

	var/turf/T = get_pitch_cursor_turf()

	cursor = AddComponent(
		/datum/component/remote_cursor,
		/mob/camera/cursor/pitch,
		view,
		list(
			/datum/action/collective/cursor_off,
			/datum/action/collective/cursor/toggle_choose_team_positions
		),
		T,
		CT_STATE_NONE
	)

/obj/item/device/coach_tablet/Destroy()
	team = null
	return ..()

/obj/item/device/coach_tablet/proc/try_in_game_action(mob/user)
	if(!is_in_game())
		to_chat(user, "<span class='warning'>You can not use this action if you're not a coach of a team currently in match.</span>")
		return FALSE

	return try_action(user)

/obj/item/device/coach_tablet/proc/try_action(mob/user)
	if(!team)
		choose_team(user)
		return FALSE

	if(!team.coach)
		team.set_coach(user)
		to_chat(user, "<span class='notice'>You have become the coach of [team.name].</span>")

	if(user.remote_control)
		return FALSE

	return TRUE

/obj/item/device/coach_tablet/proc/is_in_game()
	if(match.red != team && match.blue != team)
		return FALSE
	return TRUE

/obj/item/device/coach_tablet/proc/choose_team(mob/user)
	var/list/options = list()
	for(var/team_name in match.teams)
		var/datum/team/T = match.teams[team_name]
		var/repr = team_name
		if(T.role)
			repr += " "
			repr += "([T.role])"
		options[repr] = T

	var/team_name = input(user, "Choose a team for [src].") as null|anything in options
	if(!team_name)
		return

	var/datum/team/T = options[team_name]

	team = T
	icon_state = T.tablet_icon_state
	name = "[name] ([T.name])"

/obj/item/device/coach_tablet/afterattack(atom/target, mob/user, proximity, params)
	if(!ismob(target))
		return

	if(!try_action(user))
		return

	to_chat(user, "<span class='notice'>Adding [target] to [team.name]!</span>")
	team.add_player(target)

/obj/item/device/coach_tablet/attack_self(mob/user)
	if(!team)
		choose_team(user)
		return

	if(!try_in_game_action(user))
		return

	cursor.grant_control(user)

/obj/item/device/coach_tablet/dropped(mob/user)
	if(user.remote_control)
		cursor.revoke_control(user)

/obj/item/device/coach_tablet/equipped(mob/user, slot)
	if(user.remote_control)
		cursor.revoke_control(user)



/datum/action/collective/cursor/toggle_choose_team_positions
	name = "Toggle Choose Team Positions"
	button_icon = 'icons/mob/actions.dmi'
	button_icon_state = "blink"
	action_type = AB_INNATE

	action_state = CT_STATE_CHOOSE_TEAM_POSITIONS
	require_state = CT_STATE_NONE

	var/datum/palette/classes

/datum/action/collective/cursor/toggle_choose_team_positions/Destroy()
	QDEL_NULL(classes)
	return ..()

/datum/action/collective/cursor/toggle_choose_team_positions/start_action(mob/living/user)
	if(match.state != GS_POSITIONAL_PLANNING)
		to_chat(user, "<span class='notice'>You cannot choose team positions at this time.</span>")
		return FALSE

	var/mob/living/L = user
	var/obj/item/device/coach_tablet/CT = remote.parent

	if(!classes)
		classes = new /datum/palette(remote, CT.team.class_choices)

	classes.Grant(user)

	show_spawn_areas(user, CT)

	for(var/O in landmarks_list)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name != "Spawn Position")
			continue

		if(R.team == CT.team.role)
			show_landmark_to(L, R)

	RegisterSignal(L, list(COMSIG_MOB_CLICK), .proc/toggle_position)

	background_icon_state = "bg_active"
	button.UpdateIcon()
	return TRUE

/datum/action/collective/cursor/toggle_choose_team_positions/proc/clear_position(datum/source, atom/A, params)
	var/obj/item/device/coach_tablet/CT = remote.parent

	var/turf/T = get_turf(A)

	for(var/O in T)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name != "Spawn Position")
			continue

		if(R.team != CT.team.role)
			continue

		CT.team.remove_number(R.data["Player"])

		R.remove_alt_appearance("landmark_overlay")
		qdel(R)
		return TRUE

	return FALSE

/datum/action/collective/cursor/toggle_choose_team_positions/proc/get_class(mob/living/L)
	if(!remote.data)
		return null

	return remote.data["Class"]

/datum/action/collective/cursor/toggle_choose_team_positions/proc/add_position(datum/source, atom/A, params)
	var/mob/living/L = source
	var/obj/item/device/coach_tablet/CT = remote.parent

	var/turf/T = get_turf(A)

	var/area/area = get_area(A)
	if(!istype(area, /area/rugby/pitch))
		to_chat(L, "<span class='warning'>You can not place positionals there, please stay on the pitch.</span>")
		return FALSE

	if(CT.team.max_number == CT.team.max_players)
		to_chat(L, "<span class='warning'>Maximum number of players placed!</span>")
		return FALSE

	var/class_role = get_class(L)
	if(!class_role)
		return FALSE

	var/area/rugby/pitch/P = area
	if(!P.can_place(class_role, CT.team, L))
		return FALSE

	var/obj/effect/landmark/rugby/R = new /obj/effect/landmark/rugby(T)
	R.name = "Spawn Position"
	R.team = CT.team.role
	R.data = list()
	R.data["Player"] = CT.team.add_number()
	R.data["Class"] = class_role

	show_landmark_to(L, R)
	return TRUE

/datum/action/collective/cursor/toggle_choose_team_positions/proc/toggle_position(datum/source, atom/A, params)
	if(match.state != GS_POSITIONAL_PLANNING)
		stop_action(source)
		return COMPONENT_CANCEL_CLICK

	if(clear_position(source, A, params))
		return COMPONENT_CANCEL_CLICK

	add_position(source, A, params)

	return COMPONENT_CANCEL_CLICK

/datum/action/collective/cursor/toggle_choose_team_positions/stop_action(mob/living/user)
	var/mob/living/L = user
	var/obj/item/device/coach_tablet/CT = remote.parent

	var/list/spawn_areas = CT.team.get_spawn_areas()

	var/proper_setup = TRUE
	for(var/area/rugby/pitch/P in spawn_areas)
		if(!P.check_requirements(CT.team, user))
			proper_setup = FALSE
			break

	for(var/O in landmarks_list)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name == "Spawn Position" && R.team == CT.team.role)
			R.remove_alt_appearance("landmark_overlay")
			if(!proper_setup)
				CT.team.remove_number(R.data["Player"])
				qdel(R)
		else if(R.data && R.data["Spawn Area"])
			R.remove_alt_appearance("spawn_area_overlay")

	classes.Remove(user)

	UnregisterSignal(L, list(COMSIG_MOB_CLICK))

	background_icon_state = "bg_default"
	button.UpdateIcon()
	return TRUE

#undef CT_STATE_NONE
#undef CT_STATE_CHOOSE_TEAM_POSITIONS
