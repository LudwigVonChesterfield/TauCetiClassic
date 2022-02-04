/mob/living/carbon/monkey/diona
	var/obj/item/morphed_into

/mob/living/carbon/monkey/diona/atom_init()
	. = ..()
	RegisterSignal(src, list(COMSIG_MOUSEDROP_BY), .proc/mousedropped_onto)

/mob/living/carbon/monkey/diona/Destroy()
	UnregisterSignal(src, list(COMSIG_MOUSEDROP_BY))
	clear_morphed_into()
	return ..()

/mob/living/carbon/monkey/diona/is_vision_obstructed()
	if(ishuman(loc))
		var/mob/living/H = loc
		if(H.get_species() == DIONA)
			return H.is_vision_obstructed()

	if(morphed_into == loc)
		if(ishuman(loc.loc))
			var/mob/living/H = loc
			if(H.get_species() == DIONA)
				return H.is_vision_obstructed()

		return !isturf(loc.loc) && !is_type_in_list(loc.loc, ignore_vision_inside)
	return ..()

/mob/living/carbon/monkey/diona/proc/on_morphed_relaymove(datum/source, mob/M, direction)
	if(ismob(morphed_into.loc) && istype(morphed_into, /obj/item/clothing/shoes))
		if(M.client.move_delay > world.time)
			return

		M.client.UpdateMoveDelay(M)
		step(morphed_into.loc, direction)
		return

	demorph()

/mob/living/carbon/monkey/diona/proc/on_morphed_resist(datum/source)
	demorph()
	return COMPONENT_NO_RESIST

/mob/living/carbon/monkey/diona/proc/on_morphed_click(datum/source, atom/A, list/params)
	if(next_move > world.time)
		return
	if(stat || paralysis || stunned || weakened)
		return

	if(A.loc == null)
		return

	if(A in get_contents())
		return

	if(A == morphed_into)
		morphed_into.attack_self(src)
		return COMPONENT_CANCEL_CLICK

	var/resolved = A.attackby(morphed_into, src, params)
	if(!resolved)
		morphed_into.afterattack(A, src, morphed_into.Adjacent(A), params)
	return COMPONENT_CANCEL_CLICK

/mob/living/carbon/monkey/diona/proc/mousedropped_onto(datum/source, atom/over, atom/with, list/params)
	if(incapacitated())
		return

	if(!morphed_into && with == src)
		if(istype(over, /obj/item))
			morph(over)
		return

	if(morphed_into && morphed_into == with)
		step_towards(morphed_into, over)
		return COMPONENT_NO_MOUSEDROP

// Returns a dionified "copy" of an item for the nymph which is morphing into it.
/mob/living/carbon/monkey/diona/proc/morph(obj/item/target)
	// While a copy of a copy sounds funny, it's not.
	if(target.dionified)
		return
	// Lower than NUTRITION_LEVEL_HUNGRY nutrition will cause the nymph to demorph.
	if(nutrition < NUTRITION_LEVEL_HUNGRY + target.w_class * 10)
		return
	nutrition -= target.w_class * 10

	drop_from_inventory(handcuffed)
	handcuffed = null
	drop_from_inventory(legcuffed)
	legcuffed = null

	if(morphed_into)
		QDEL_NULL(morphed_into)

	var/obj/item/I = target.get_diona_simulacrum()
	I.verbs += /obj/item/proc/poke_nymph
	I.forceMove(loc)
	I.dionified = TRUE

	I.copy_item_icon_info(target)
	I.appearance = target
	I.color = INTENSITY_COLOR(1.5, 1.5, 1.5)
	add_diona_filter(I)

	I.dionify(target)

	morphed_into = I
	RegisterSignal(morphed_into, list(COMSIG_PARENT_QDELETING), .proc/clear_morphed_into)

	if(ismob(loc))
		var/mob/M = loc
		M.put_in_hands(I, M.loc)

	forceMove(I)

	RegisterSignal(I, list(COMSIG_ATOM_RELAYMOVE), .proc/on_morphed_relaymove)
	RegisterSignal(src, list(COMSIG_MOB_CLICK), .proc/on_morphed_click)
	RegisterSignal(src, list(COMSIG_LIVING_RESIST), .proc/on_morphed_resist)

	return I

/mob/living/carbon/monkey/diona/proc/jump_out(atom/movable/AM)
	if(ismob(morphed_into.loc))
		forceMove(morphed_into.loc.loc)
	else
		forceMove(morphed_into.loc)

/mob/living/carbon/monkey/diona/proc/clear_morphed_into()
	UnregisterSignal(morphed_into, list(COMSIG_ATOM_RELAYMOVE))
	UnregisterSignal(src, list(COMSIG_MOB_CLICK, COMSIG_LIVING_RESIST))

	forceMove(morphed_into.loc)

	if(ismob(morphed_into.loc))
		get_scooped(morphed_into.loc)

	update_sight()

	for(var/AM in contents)
		jump_out(AM)

	morphed_into = null

/mob/living/carbon/monkey/diona/proc/demorph()
	UnregisterSignal(morphed_into, list(COMSIG_ATOM_RELAYMOVE, COMSIG_ATOM_RELAYMOVE))
	UnregisterSignal(src, list(COMSIG_MOB_CLICK, COMSIG_LIVING_RESIST))

	forceMove(morphed_into.loc)

	if(ismob(morphed_into.loc))
		get_scooped(morphed_into.loc)

	update_sight()

	for(var/AM in contents)
		jump_out(AM)

	QDEL_NULL(morphed_into)
