/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 10
	w_class = ITEM_SIZE_NORMAL
	attack_verb = list("mopped", "bashed", "bludgeoned", "whacked")

	sweep_step = 4

	var/mopping = 0
	var/mopcount = 0

/obj/item/weapon/mop/atom_init()
	create_reagents(5)
	. = ..()
	mop_list += src
	make_swipable(src,
					can_push=TRUE,
					can_push_on_chair=TRUE,

					can_pull=TRUE,

					can_sweep=TRUE,
					can_spin=TRUE,

					on_sweep_to_check=CALLBACK(src, /obj/item/weapon/mop.proc/on_sweep_to_check),
					on_sweep_finish=CALLBACK(src, /obj/item/weapon/mop.proc/on_sweep_finish),

					on_sweep_push=CALLBACK(src, /obj/item/weapon/mop.proc/on_sweep_push),

					on_sweep_pull=CALLBACK(src, /obj/item/weapon/mop.proc/on_sweep_pull),
					)

/obj/item/weapon/mop/Destroy()
	mop_list -= src
	return ..()

/obj/item/weapon/mop/proc/clean(turf/simulated/T, amount)
	if(reagents.has_reagent("water", amount))
		T.clean_blood()
		T.dirt = max(0, T.dirt - amount * 20) // #define MAGICAL_CLEANING_CONSTANT 20
		for(var/obj/effect/O in T)
			if(istype(O,/obj/effect/rune) || istype(O,/obj/effect/decal/cleanable) || istype(O,/obj/effect/overlay))
				qdel(O)
	reagents.reaction(T, TOUCH, amount)
	if(T.reagents)
		reagents.trans_to(T, amount / 3)
	else
		reagents.remove_any(amount / 3)

/obj/item/weapon/mop/proc/on_sweep_finish(turf/current_turf, mob/living/user)
	clean(current_turf, 1)

/obj/item/weapon/mop/proc/on_sweep_to_check(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/living/user, list/directions, i)
	if(istype(target, /obj/item))
		var/obj/item/I = target
		if(I.anchored)
			return
		if(I.w_class <= ITEM_SIZE_NORMAL)
			var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
			if(istype(TR) && TR.can_be_inserted(I))
				TR.handle_item_insertion(I, prevent_warning = TRUE)
			else if(i + 1 <= directions.len)
				step_to(I, get_step(src, directions[i + 1]))

/obj/item/weapon/mop/proc/on_sweep_push(atom/target, turf/T, mob/user)
	var/turf/T_target = get_turf(target)

	for(var/obj/item/I in T)
		if(I == target)
			continue
		if(I.anchored)
			continue
		if(I.w_class <= ITEM_SIZE_NORMAL)
			var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
			if(istype(TR) && TR.can_be_inserted(I))
				TR.handle_item_insertion(I, prevent_warning = TRUE)
			else
				step_to(I, T_target)

/obj/item/weapon/mop/proc/on_sweep_pull(atom/target, turf/T, mob/user)
	var/turf/src_turf = get_turf(src)

	for(var/obj/item/I in T)
		if(I == target)
			continue
		if(I.anchored)
			continue
		if(I.w_class <= ITEM_SIZE_NORMAL)
			var/obj/item/weapon/storage/bag/trash/TR = user.get_inactive_hand()
			if(istype(TR) && TR.can_be_inserted(I))
				TR.handle_item_insertion(I, prevent_warning = TRUE)
			else
				step_to(I, src_turf)

/obj/item/weapon/mop/afterattack(atom/A, mob/living/user, proximity)
	if(!proximity)
		return
	if(istype(A, /turf/simulated) || istype(A, /obj/effect/decal/cleanable) || istype(A, /obj/effect/overlay) || istype(A, /obj/effect/rune))
		if(reagents.total_volume < 1)
			to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		if(user.is_busy(A))
			return

		INVOKE_ASYNC(user, /atom/movable.proc/do_attack_animation, A)
		user.visible_message("<span class='warning'>[user] begins to clean \the [get_turf(A)].</span>")

		if(do_after(user, sweep_step SECONDS, target = A))
			if(A)
				clean(get_turf(A), 10)
			to_chat(user, "<span class='notice'>You have finished mopping!</span>")

/obj/item/weapon/mop/advanced
	desc = "The most advanced tool in a custodian's arsenal. Just think of all the viscera you will clean up with this!"
	name = "advanced mop"
	icon_state = "advmop"
	item_state = "advmop"
	force = 6.0
	throwforce = 10.0
	throw_range = 10.0
	sweep_step = 2

/obj/effect/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/mop) || istype(I, /obj/item/weapon/soap) || istype(I, /obj/item/weapon/kitchen/utensil/fork))
		user.SetNextMove(CLICK_CD_INTERACT)
		return
	return ..()
