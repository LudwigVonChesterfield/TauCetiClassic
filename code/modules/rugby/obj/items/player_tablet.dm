#define PT_STATE_NONE 0
#define PT_STATE_CHOOSE_TEAM_POSITIONS 1



/obj/item/device/player_tablet
	name = "Player Tablet"
	desc = "placeholder"
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	item_state = "electronic"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_ID | SLOT_FLAGS_BELT

	var/datum/team/team

	var/datum/component/remote_cursor/cursor

/obj/item/device/player_tablet/atom_init()
	. = ..()
	var/image/view = image('icons/mob/blob.dmi', "marker")

	var/turf/T = get_pitch_cursor_turf()

	cursor = AddComponent(
		/datum/component/remote_cursor,
		/mob/camera/cursor/pitch,
		view,
		list(
			/datum/action/collective/cursor_off
		),
		T,
		PT_STATE_NONE,
		CALLBACK(src, .proc/on_click)
	)

/obj/item/device/player_tablet/Destroy()
	team = null
	return ..()

/obj/item/device/player_tablet/proc/grant_control(mob/user)
	show_spawn_areas(user, src)

	for(var/O in landmarks_list)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name != "Spawn Position")
			continue

		if(R.team == team.role)
			show_landmark_to(user, R)

	cursor.grant_control(user)

/obj/item/device/player_tablet/proc/revoke_control(mob/user)
	for(var/O in landmarks_list)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(R.name == "Spawn Position" && R.team == team.role)
			R.remove_alt_appearance("landmark_overlay")
		else if(R.data && R.data["Spawn Area"])
			R.remove_alt_appearance("spawn_area_overlay")

	cursor.revoke_control(user)

/obj/item/device/player_tablet/proc/on_click(datum/source, atom/A, params)
	. = COMPONENT_CANCEL_CLICK

	var/obj/effect/landmark/rugby/R
	if(isturf(A))
		R = locate() in A
	else if(istype(A, /obj/effect/landmark/rugby))
		R = A

	if(!R)
		return

	if(R.name != "Spawn Position")
		return

	if(R.team != team.role)
		return

	var/datum/player/P = team.get_player(source)
	P.number = R.data["Player"]
	P.class = R.data["Class"]

	match.spawn_player(team, P)
	qdel(R)

/obj/item/device/player_tablet/attack_self(mob/user)
	grant_control(user)

/obj/item/device/player_tablet/dropped(mob/user)
	if(user.remote_control)
		revoke_control(user)

/obj/item/device/player_tablet/equipped(mob/user, slot)
	if(user.remote_control)
		revoke_control(user)

#undef PT_STATE_NONE
#undef PT_STATE_CHOOSE_TEAM_POSITIONS
