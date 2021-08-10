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
#define MANIPULATOR_STATE_INTERACTING_FROM "interacting_from"
#define MANIPULATOR_STATE_INTERACTING_TO "interacting_to"

/obj/machinery/manipulator
	name = "manipulator"
	desc = "Manipulates stuff. I think we'll put this thing right here..."

	icon = 'icons/mob/human.dmi'
	icon_state = "abductor_s"

	var/turf/from_turf
	var/turf/to_turf

	var/turf/fail_turf

	var/mob/living/carbon/human/clicker

	var/state = MANIPULATOR_STATE_IDLE

/obj/machinery/manipulator/atom_init()
	. = ..()
	set_dir(dir)
	create_clicker()

/obj/machinery/manipulator/Destroy()
	QDEL_NULL(clicker)

	from_turf = null
	to_turf = null
	fail_turf = null

	return ..()

/obj/machinery/manipulator/set_dir(new_dir)
	. = ..()

	if(from_turf)
		UnregisterSignal(from_turf, list(COMSIG_ATOM_ENTERED))
		from_turf = null

	var/opposite_dir = turn(dir, 180)

	var/fail_dir = turn(dir, 90)

	to_turf = get_step(src, dir)
	from_turf = get_step(src, opposite_dir)
	fail_turf = get_step(src, fail_dir)

	RegisterSignal(from_turf, list(COMSIG_ATOM_ENTERED), .proc/on_from_entered)

/obj/machinery/manipulator/proc/on_from_entered(datum/source, atom/movable/entering, atom/oldLoc)
	SIGNAL_HANDLER

	if(state != MANIPULATOR_STATE_IDLE)
		return

	try_interact_from(entering)

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
	to_chat(world, "TAKING CLICKER OUT")

/obj/machinery/manipulator/proc/after_click()
	clicker.forceMove(src)
	to_chat(world, "HIDING CLICKER BACK IN")

/obj/machinery/manipulator/proc/clickability_from(atom/movable/A)
	return !A.anchored

/obj/machinery/manipulator/proc/clickability_to(atom/A)
	return TRUE

/obj/machinery/manipulator/proc/find_clickable(turf/T, datum/callback/clickability)
	if(!T.contents.len)
		to_chat(world, "There. Is. Nothing.")
		return null

	var/atom/most_clickable

	to_chat(world, "[T.contents.len] is len of possible")

	for(var/C in T.contents)
		var/atom/movable/A = C
		to_chat(world, "CONSIDERING [A.name]([A.type])")

		if(A.name == "")
			to_chat(world, "FAIL, HAS NO NAME")
			continue

		if(!A.simulated)
			to_chat(world, "FAIL, TOO ABSTRACT")
			continue

		if(A.invisibility > clicker.see_invisible)
			to_chat(world, "FAIL, TOO INVISIBLE")
			continue

		if(clickability && !clickability.Invoke(A))
			continue

		if(!most_clickable)
			to_chat(world, "SUCCESS, SAVING [A]")
			most_clickable = A
			continue

		if(A.plane > most_clickable.plane)
			to_chat(world, "OVERRIDING [A]")
			most_clickable = A

		else if(A.plane == most_clickable.plane && A.layer > most_clickable.layer)
			to_chat(world, "OVERRIDING [A]")
			most_clickable = A

	if(most_clickable)
		to_chat(world, "MOST CLICKABLE IS [most_clickable.name]([most_clickable.type])")

	return most_clickable

/obj/machinery/manipulator/proc/DoClick(atom/A, list/params)
	// clicker.ClickOn(A, params)

	usr = clicker

	var/obj/item/W = clicker.get_active_hand()
	if(W == A)
		W.attack_self(clicker)
		W.update_inv_mob()
		return

	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(clicker)) // see adjacent.dm
			if(W)
				// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = A.attackby(W, clicker, params)
				to_chat(world, "AFTER ATTACKBY ([resolved]) with [W]")
				if(!resolved && A && W)
					W.afterattack(A, clicker, TRUE, params) // 1: clicking something Adjacent
					to_chat(world, "AFTER AFTERATTACK WITH [W]")
			else
				clicker.UnarmedAttack(A)
		else // non-adjacent click
			if(W)
				W.afterattack(A, clicker, FALSE, params) // 0: not Adjacent
			else
				clicker.RangedAttack(A, params)

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
		to_chat(world, "CAN'T MANIPULATE, NO ITEM IN HAND.")
		state = MANIPULATOR_STATE_IDLE
		return

	sleep(1)
	try_interact_to()

/obj/machinery/manipulator/proc/try_interact_from(atom/target=null)
	to_chat(world, "TRYING TO INTERACT FROM [target]")

	if(!target)
		target = find_clickable(from_turf)
		to_chat(world, "FOUND OTHER TARGET [target]")

	if(!target)
		to_chat(world, "NO TARGET FOUND, IDLE.")
		state = MANIPULATOR_STATE_IDLE
		return

	state = MANIPULATOR_STATE_INTERACTING_FROM

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_from)))

/obj/machinery/manipulator/proc/after_interact_to()
	var/obj/item/I = clicker.get_active_hand()
	if(I)
		clicker.drop_from_inventory(I, fail_turf)

	sleep(1)
	try_interact_from()

/obj/machinery/manipulator/proc/try_interact_to(atom/target=null)
	to_chat(world, "TRYING TO INTERACT TO [target]")

	if(!target)
		target = find_clickable(to_turf)

		to_chat(world, "FOUND OTHER TARGET [target]")

	if(!target)
		var/obj/item/I = clicker.get_active_hand()
		if(I)
			clicker.drop_from_inventory(I, to_turf)

		to_chat(world, "NO TARGET FOUND, DROPPING.")

		INVOKE_ASYNC(src, .proc/after_interact_to)
		return

	state = MANIPULATOR_STATE_INTERACTING_TO

	simulate_click(target, list(CALLBACK(src, .proc/after_interact_to)))

#undef MANIPULATOR_STATE_IDLE
#undef MANIPULATOR_STATE_INTERACTING_FROM
#undef MANIPULATOR_STATE_INTERACTING_TO
