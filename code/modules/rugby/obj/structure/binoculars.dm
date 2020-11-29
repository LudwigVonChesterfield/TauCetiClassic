#define SB_STATE_NONE 0
#define SB_STATE_FOLLOWING_PLAYER 1

/obj/structure/spectator_binoculars
	name = "Binoculars"
	desc = "So you can see that touchdown as if it was your face being touched."

	icon = 'code/modules/rugby/icons/structures.dmi'
	icon_state = "binoculars"

	var/datum/component/remote_cursor/cursor

/obj/structure/spectator_binoculars/atom_init()
	. = ..()
	var/image/view = image('icons/mob/blob.dmi', "marker")

	var/turf/T = get_pitch_cursor_turf()

	cursor = AddComponent(
		/datum/component/remote_cursor,
		/mob/camera/cursor/pitch,
		view,
		get_actions(),
		T
	)

/obj/structure/spectator_binoculars/proc/get_actions()
	return list(
		/datum/action/collective/cursor_off,
		/datum/action/collective/cursor/follow_player
	)

/obj/structure/spectator_binoculars/proc/start_using(mob/user)
	cursor.grant_control(user)

	RegisterSignal(user, list(COMSIG_MOVABLE_MOVED), .proc/check_proximity)

/obj/structure/spectator_binoculars/proc/stop_using(mob/user)
	cursor.revoke_control(user)

	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED))

/obj/structure/spectator_binoculars/attack_hand(mob/user)
	start_using(user)

/obj/structure/spectator_binoculars/proc/check_proximity(datum/source, atom/newLoc)
	if(!Adjacent(source))
		stop_using(source)



/datum/action/collective/cursor/follow_player
	name = "Follow Player"
	button_icon = 'icons/mob/screen_ghost.dmi'
	button_icon_state = "orbit"
	action_type = AB_INNATE

	action_state = SB_STATE_FOLLOWING_PLAYER
	require_state = SB_STATE_NONE

	var/atom/following

/datum/action/collective/cursor/follow_player/Destroy()
	if(following)
		unfollow()

	return ..()

/datum/action/collective/cursor/follow_player/Grant(mob/living/T)
	..()
	RegisterSignal(T, list(COMSIG_LIVING_DOUBLE_CLICK), .proc/follow_target)

/datum/action/collective/cursor/follow_player/Remove(mob/living/T)
	UnregisterSignal(T, list(COMSIG_LIVING_DOUBLE_CLICK))
	..()

/datum/action/collective/cursor/follow_player/proc/follow_target(datum/source, atom/target)
	if(follow(target))
		remote.state = SB_STATE_FOLLOWING_PLAYER

/datum/action/collective/cursor/follow_player/start_action(mob/living/user)
	var/list/pos_choices = list()

	var/list/turf/pos_turfs = get_area_turfs(/area/rugby/pitch)
	for(var/t in pos_turfs)
		var/turf/T = t
		for(var/a in T)
			if(istype(a, /mob))
				pos_choices += a
			else if(istype(a, /obj/item))
				pos_choices += a

	to_chat(world, "[pos_turfs.len] is quite empty.")

	var/atom/A = input(user, "Please choose an object to follow.") as anything in null|pos_choices

	if(!A)
		return FALSE

	return follow(A)

/datum/action/collective/cursor/follow_player/proc/follow(atom/A)
	following = A
	if(!move_cursor())
		following = null
		return FALSE

	RegisterSignal(A, list(COMSIG_MOVABLE_MOVED), .proc/move_cursor)
	RegisterSignal(remote.cursor, list(COMSIG_MOVABLE_MOVED), .proc/check_proximity)

	button_icon_state = "orbit_anim"
	background_icon_state = "bg_active"
	for(var/u in users)
		var/mob/living/U = u
		U.update_action_buttons()

/datum/action/collective/cursor/follow_player/proc/unfollow()
	UnregisterSignal(following, list(COMSIG_MOVABLE_MOVED))
	UnregisterSignal(remote.cursor, list(COMSIG_MOVABLE_MOVED))

	following = null

	button_icon_state = "orbit"
	background_icon_state = "bg_default"
	for(var/u in users)
		var/mob/living/U = u
		U.update_action_buttons()

/datum/action/collective/cursor/follow_player/stop_action()
	unfollow()
	return TRUE

/datum/action/collective/cursor/follow_player/proc/move_cursor()
	remote.cursor.setLoc(following.loc)
	return check_proximity()

/datum/action/collective/cursor/follow_player/proc/check_proximity()
	if(following.loc != remote.cursor.loc)
		unfollow()
		remote.state = SB_STATE_NONE
		return FALSE
	return TRUE

#undef SB_STATE_NONE
#undef SB_STATE_FOLLOWING_PLAYER
