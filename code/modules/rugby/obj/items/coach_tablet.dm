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
		T
	)

/obj/item/device/coach_tablet/Destroy()
	team = null
	return ..()

/obj/item/device/coach_tablet/proc/is_in_game()
	if(match.red != team && match.blue != team)
		return FALSE
	return TRUE

/obj/item/device/coach_tablet/afterattack(atom/target, mob/user, proximity, params)
	if(!ismob(target))
		return

	if(is_in_game())
		return

	if(!team)
		choose_team(user)
		return

	to_chat(user, "<span class='notice'>Adding [target] to [team.name]!</span>")
	team.add_player(target)

/obj/item/device/coach_tablet/proc/choose_team(mob/user)
	var/list/options = list()
	for(var/team_name in match.teams)
		var/datum/team/T = match.teams[team_name]
		var/repr = team_name
		if(T.role)
			repr += " "
			repr += "([T.role])"
		options[repr] = T

	var/team_name = input(user, "Choose a team.") as null|anything in options
	if(!team_name)
		return

	var/datum/team/T = options[team_name]

	team = T
	icon_state = T.tablet_icon_state
	name = "[name] ([T.name])"

/obj/item/device/coach_tablet/attack_self(mob/user)
	if(!team)
		choose_team(user)
		return

	if(is_in_game())
		return

	if(!team.coach)
		team.set_coach(user)

	if(user.remote_control)
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

/datum/action/collective/cursor/toggle_choose_team_positions/proc/show_to(mob/living/L, obj/effect/landmark/rugby/R)
	var/image/I = image('code/modules/rugby/icons/landmarks.dmi', "[R.get_team_color()]_[R.data["Player"]]")
	I.override = TRUE
	I.loc = R
	I.appearance_flags |= RESET_ALPHA
	R.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"landmark_overlay",
		I,
		L
	)

/datum/action/collective/cursor/toggle_choose_team_positions/start_action(mob/living/user)
	var/mob/living/L = user
	var/obj/item/device/coach_tablet/CT = remote.parent

	if(!classes)
		classes = new /datum/palette(user, CT.team.class_choices)

	classes.Grant(user)

	for(var/O in landmarks_list)
		if(!istype(O, CT.team.landmark_type))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name == "Spawn Position")
			show_to(L, R)

	RegisterSignal(L, list(COMSIG_MOB_CLICK), .proc/toggle_position)

	background_icon_state = "bg_active"
	button.UpdateIcon()
	return TRUE

/datum/action/collective/cursor/toggle_choose_team_positions/proc/toggle_position(datum/source, atom/A, params)
	var/mob/living/L = source
	var/obj/item/device/coach_tablet/CT = remote.parent

	var/found_landmark = FALSE

	var/turf/T = get_turf(A)
	for(var/O in T)
		if(!istype(O, CT.team.landmark_type))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name == "Spawn Position")
			found_landmark = TRUE

			for(var/p in CT.team.reserves)
				var/datum/player/P = p
				if(P.number != R.data["Player"])
					continue
				LAZYADD(CT.team.reserves, P)

			R.remove_alt_appearance("landmark_overlay")
			qdel(R)
			break

	if(found_landmark)
		return COMPONENT_CANCEL_CLICK

	if(!CT.team.reserves)
		return COMPONENT_CANCEL_CLICK

	var/list/pos_positions = list()
	for(var/p in CT.team.reserves)
		var/datum/player/P = p
		pos_positions["[P.number] - [P.model.real_name] ([P.class])"] = P.number

	var/position = input(L, "Choose a Player to put on the field.") as null|anything in pos_positions
	if(!position)
		return COMPONENT_CANCEL_CLICK

	position = pos_positions[position]

	for(var/p in CT.team.reserves)
		var/datum/player/P = p
		if(P.number != position)
			continue
		LAZYREMOVE(CT.team.reserves, P)

	var/obj/effect/landmark/rugby/R = new CT.team.landmark_type(T)
	R.name = "Spawn Position"
	R.data = list()
	R.data["Player"] = position

	show_to(L, R)

	return COMPONENT_CANCEL_CLICK

/datum/action/collective/cursor/toggle_choose_team_positions/stop_action(mob/living/user)
	var/mob/living/L = user
	var/obj/item/device/coach_tablet/CT = remote.parent

	classes.Remove(user)

	for(var/O in landmarks_list)
		if(!istype(O, CT.team.landmark_type))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name == "Spawn Position")
			R.remove_alt_appearance("landmark_overlay")

	UnregisterSignal(L, list(COMSIG_MOB_CLICK))

	background_icon_state = "bg_default"
	button.UpdateIcon()
	return TRUE

#undef CT_STATE_NONE
#undef CT_STATE_CHOOSE_TEAM_POSITIONS
