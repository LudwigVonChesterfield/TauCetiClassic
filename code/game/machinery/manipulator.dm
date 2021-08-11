/*
	      ✞
	Abandon hope.
	      ✞

	Отче наш, сущий на небесах!
	Да святится имя Твоё;
	да приидет Царствие Твоё;
	да будет воля Твоя и на земле,
	как на небе;
	хлеб наш насущный дай нам на сей день;
	и прости нам долги наши,
	как и мы прощаем должникам нашим;
	и не введи нас в искушение, но избавь нас от лукавого.
	Ибо Твоё есть Царство и сила и слава во веки.
	Аминь.
	                                          — Мф. 6:9—13

	Manipulator is machinery that simulates clicking stuff on stuff.
	Currently it creates it's own mob to click stuff with.
	Which is I might say. Sinful.
 */

#define MANIPULATOR_STATE_IDLE "idle"
#define MANIPULATOR_STATE_FAIL "fail"
#define MANIPULATOR_STATE_INTERACTING_FROM "interacting_from"
#define MANIPULATOR_STATE_INTERACTING_TO "interacting_to"

/obj/machinery/manipulator
	name = "manipulator"
	desc = "Manipulates stuff. I think we'll put this thing right here..."

	icon = 'icons/obj/machines/logistic.dmi'
	icon_state = "base"

	var/turf/from_turf
	var/turf/to_turf

	var/turf/fail_turf

	var/mob/living/carbon/human/clicker

	var/state = MANIPULATOR_STATE_IDLE

	var/mirrored
	var/fail_angle = 90

	var/image/decal
	var/atom/movable/hand
	var/atom/movable/item
	var/item_x = 0
	var/item_y = 15
	var/item_scale = 0.75

	var/busy_moving

	// This is here solely for the coolness of manipulators opening crates.
	// If something enters the tile even when manipulator is working, it will remember it,
	// and activate whenver it stops being busy.
	var/remember_trigger = FALSE

/obj/machinery/manipulator/atom_init()
	. = ..()

	var/image/I = image(icon, src, "manipulator", layer + 0.1, dir)

	hand = new(null)
	hand.simulated = FALSE
	hand.anchored = TRUE
	hand.appearance = I

	vis_contents += hand

	decal = image(icon, src, "manip_decor", layer, dir)


	add_overlay(decal)

	set_dir(dir)
	create_clicker()

/obj/machinery/manipulator/Destroy()
	QDEL_NULL(clicker)

	vis_contents -= hand
	if(item)
		hand.vis_contents -= item
	cut_overlay(decal)

	QDEL_NULL(hand)
	QDEL_NULL(item)
	QDEL_NULL(decal)

	from_turf = null
	to_turf = null
	fail_turf = null

	return ..()

/obj/machinery/manipulator/proc/do_sleep(delay)
	busy_moving = TRUE

	var/endtime = world.time + delay

	. = TRUE

	while(world.time < endtime)
		stoplag()
		if(QDELETED(src))
			. = FALSE
			break

		/*
			CHECK POWER IF NOT FORCED MOVEMENT
		*/

	busy_moving = FALSE

/obj/machinery/manipulator/proc/set_mirrored(mirrored)
	src.mirrored = mirrored

	if(mirrored)
		fail_angle = -90

	decal.icon_state = "manip_decor[mirrored ? "-mirrored" : ""]"
	//cut_overlay(decal)
	//add_overlay(decal)

/obj/machinery/manipulator/update_icon()
	if(!clicker)
		return

	var/obj/item/I = clicker.get_active_hand()
	if(!I)
		if(item)
			to_chat(world, "REMOVING ITEM OVERLAY")
			hand.vis_contents -= item
			item = null
		return

	var/image/IM = image(I.icon, src, I.icon_state, layer + 0.11, SOUTH)

	var/matrix/M = matrix()
	M.Scale(item_scale, item_scale)

	IM.transform = M

	if(item)
		return

	item = new(null)
	item.simulated = FALSE
	item.anchored = TRUE

	item.pixel_x = item_x
	item.pixel_y = item_y

	item.appearance = IM
	item.appearance_flags |= KEEP_TOGETHER

	hand.vis_contents += item

/obj/machinery/manipulator/proc/set_state(new_state)
	to_chat(world, "CUR STATE [state] NEW [new_state]")
	if(state == new_state)
		return

	state = new_state

	var/hand_angle = 0
	switch(new_state)
		if(MANIPULATOR_STATE_IDLE)
			hand_angle = 0 // -fail_angle if you want this state to be visible too.
		if(MANIPULATOR_STATE_FAIL)
			hand_angle = fail_angle
		if(MANIPULATOR_STATE_INTERACTING_FROM)
			hand_angle = 0
		if(MANIPULATOR_STATE_INTERACTING_TO)
			hand_angle = 180

	var/matrix/M = matrix()
	M.Turn(hand_angle)

	update_icon()

	animate(hand, time=3, transform=M)
	if(item)
		var/matrix/MI = matrix()
		MI.Turn(hand_angle)
		MI.Scale(item_scale, item_scale)
		var/x = item_x * cos(hand_angle) + item_y * sin(hand_angle)
		var/y = -item_x * sin(hand_angle) +  item_y * cos(hand_angle)
		animate(item, time=3, pixel_x=x, pixel_y=y, transform=MI)

/obj/machinery/manipulator/set_dir(new_dir)
	. = ..()

	if(from_turf)
		UnregisterSignal(from_turf, list(COMSIG_ATOM_ENTERED))
		from_turf = null

	var/opposite_dir = turn(dir, 180)

	var/fail_dir = turn(dir, fail_angle)

	to_turf = get_step(src, dir)
	from_turf = get_step(src, opposite_dir)
	fail_turf = get_step(src, fail_dir)

	RegisterSignal(from_turf, list(COMSIG_ATOM_ENTERED), .proc/on_from_entered)

	hand.dir = dir
	decal.dir = dir

/obj/machinery/manipulator/proc/on_from_entered(datum/source, atom/movable/entering, atom/oldLoc)
	SIGNAL_HANDLER

	if(state != MANIPULATOR_STATE_IDLE)
		remember_trigger = TRUE
		return

	if(busy_moving)
		remember_trigger = TRUE
		return

	INVOKE_ASYNC(src, .proc/try_interact_from, entering)

/obj/machinery/manipulator/default_change_direction_wrench(mob/user, obj/item/weapon/wrench/W)
	if(istype(W))
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		set_dir(turn(dir,-90))
		to_chat(user, "<span class='notice'>You rotate [src].</span>")
		return 1
	return 0

/obj/machinery/manipulator/attackby(obj/item/I, mob/user, params)
	if(default_change_direction_wrench(user, I))
		return

	return ..()

/obj/machinery/manipulator/proc/create_clicker()
	clicker = new(src)
	clicker.simulated = FALSE
	clicker.name = "manipulator"
	clicker.real_name = "manipulator"
	clicker.status_flags |= GODMODE
	clicker.canmove = FALSE
	clicker.invisibility = INVISIBILITY_ABSTRACT
	clicker.anchored = TRUE
	clicker.density = FALSE

/obj/machinery/manipulator/proc/before_click()
	clicker.forceMove(loc)

/obj/machinery/manipulator/proc/after_click()
	clicker.forceMove(src)

/obj/machinery/manipulator/proc/clickability_from(atom/movable/A)
	return !A.anchored

/obj/machinery/manipulator/proc/clickability_to(atom/A)
	return TRUE

/obj/machinery/manipulator/proc/find_clickable(turf/T, datum/callback/clickability)
	if(!T.contents.len)
		return null

	var/atom/most_clickable

	for(var/C in T.contents)
		var/atom/movable/A = C

		if(A.name == "")
			continue

		if(!A.simulated)
			continue

		if(A.invisibility > clicker.see_invisible)
			continue

		if(clickability && !clickability.Invoke(A))
			continue

		if(!most_clickable)
			most_clickable = A
			continue

		if(A.plane > most_clickable.plane)
			most_clickable = A

		else if(A.plane == most_clickable.plane && A.layer > most_clickable.layer)
			most_clickable = A

	return most_clickable

/obj/machinery/manipulator/proc/DoClick(atom/A, list/params)
	usr = clicker
	clicker.ClickOn(A, params)

/obj/machinery/manipulator/proc/ClickAndCallBack(atom/A, list/params, list/datum/callback/callbacks)
	DoClick(A, params)

	after_click()

	for(var/datum/callback/C in callbacks)
		C.Invoke()

/obj/machinery/manipulator/proc/simulate_click(atom/A, list/datum/callback/callbacks)
	var/static/list/fake_params = "[ICON_X]=16&[ICON_Y]=16"

	before_click()

	INVOKE_ASYNC(src, .proc/ClickAndCallBack, A, fake_params, callbacks)

/obj/machinery/manipulator/proc/after_interact_from()
	var/obj/item/I = clicker.get_active_hand()
	if(!I)
		if(remember_trigger)
			remember_trigger = FALSE
			set_state(MANIPULATOR_STATE_IDLE)
			do_sleep(3)
			try_interact_from()
			return
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(3)
		return

	try_interact_to()

/obj/machinery/manipulator/proc/try_interact_from(atom/target=null)
	if(!target)
		target = find_clickable(from_turf)

	if(!target)
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(3)
		return

	set_state(MANIPULATOR_STATE_INTERACTING_FROM)
	if(!do_sleep(3))
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(3)
		return

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_from)))

/obj/machinery/manipulator/proc/after_interact_to()
	var/obj/item/I = clicker.get_active_hand()
	if(I)
		set_state(MANIPULATOR_STATE_FAIL)
		do_sleep(3)

		clicker.drop_from_inventory(I, fail_turf)

		set_state(MANIPULATOR_STATE_INTERACTING_TO)
		do_sleep(3)

	set_state(MANIPULATOR_STATE_IDLE)
	do_sleep(3)
	try_interact_from()

/obj/machinery/manipulator/proc/try_interact_to(atom/target=null)
	if(!target)
		target = find_clickable(to_turf)

	if(!target)
		var/obj/item/I = clicker.get_active_hand()
		if(I)
			set_state(MANIPULATOR_STATE_INTERACTING_TO)
			if(!do_sleep(3))
				set_state(MANIPULATOR_STATE_IDLE)
				do_sleep(3)
				return

			if(QDELETED(I))
				set_state(MANIPULATOR_STATE_IDLE)
				do_sleep(3)
				return

			clicker.drop_from_inventory(I, to_turf)

		INVOKE_ASYNC(src, .proc/after_interact_to)
		return

	set_state(MANIPULATOR_STATE_INTERACTING_TO)
	if(!do_sleep(3))
		set_state(MANIPULATOR_STATE_IDLE)
		do_sleep(3)
		return

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_to)))

#undef MANIPULATOR_STATE_IDLE
#undef MANIPULATOR_STATE_FAIL
#undef MANIPULATOR_STATE_INTERACTING_FROM
#undef MANIPULATOR_STATE_INTERACTING_TO
