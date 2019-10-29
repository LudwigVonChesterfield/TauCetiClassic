var/global/list/dust_icons_hash = list()

/atom/proc/create_dust(datum/reagents/R, list/parameters)
	var/atom/dust_spawn = loc
	if(isturf(src))
		dust_spawn = src

	var/icon/copy_image = icon(icon=icon, icon_state=icon_state)
	var/obj/item/dust/D = new(dust_spawn, copy_image, R, parameters)
	if(D && prob(5))
		var/size = "tiny"
		if(R.total_volume > 15)
			size = "large"
		else if(R.total_volume > 8)
			size = "medium"
		else if(R.total_volume > 2)
			size = "small"

		var/datum/reagent/reag = R.reagent_list[1]
		var/reag_name = reag.name

		visible_message("<span class='warning'>[bicon(src)] A [size] speckle of [lowertext(reag_name)] [pick("pops out of", "splits from", "lunges out of")] [src]!</span>")

	return D

// Return TRUE if icon update is required.
/atom/proc/react_to_dust(obj/item/dust/D)
	if(reagents && is_open_container())
		D.reagents.trans_to(reagents, 1)
		return TRUE
	return FALSE

/turf/simulated/react_to_dust(obj/item/dust/D)
	dirt += 1
	D.reagents.remove_any(1)
	return TRUE

/mob/living/react_to_dust(obj/item/dust/D)
	eye_blurry += 5
	D.reagents.remove_any(1)
	return TRUE

/obj/item/dust
	name = "dust"
	desc = "A speckle of dust."
	icon = 'icons/obj/destructables_dust.dmi'
	icon_state = "dust"

	flags = NOBLUDGEON

	w_class = ITEM_SIZE_TINY
	throwforce = 0
	throw_speed = 2 // Doesn't really want to move.

	force = 0.0
	hit_area_coeff = 0.0

	var/brittle = FALSE

	var/icon/copy_image

	var/icon_shift_x = 0
	var/icon_shift_y = 0

/obj/item/dust/atom_init(mapload, icon/copy_image, datum/reagents/R, list/parameters)
	. = ..()

	if(R.reagent_list.len == 0)
		return INITIALIZE_HINT_QDEL

	reagents = R
	reagents.my_atom = src

	if(parameters && parameters["icon_x"] && parameters["icon_y"])
		icon_shift_x = parameters["icon_x"]
		icon_shift_y = parameters["icon_y"]
	else
		icon_shift_x = rand(-world.icon_size / 2, world.icon_size / 2)
		icon_shift_y = rand(-world.icon_size / 2, world.icon_size / 2)

	for(var/datum/reagent/reag in R.reagent_list)
		if(reag.is_sharp)
			sharp = TRUE
		if(reag.is_brittle)
			brittle = TRUE

	src.copy_image = copy_image

	var/matrix/M = matrix()
	M.Turn(rand(0, 360))
	transform = M

	update_icon()

/obj/item/dust/Destroy()
	QDEL_NULL(copy_image)
	return ..()

/obj/item/dust/react_to_dust(obj/item/dust/D)
	/*
	if(!D.throwing)
		var/datum/reagent/reag = reagents.reagent_list[1]
		var/datum/reagent/D_reag = D.reagents.reagent_list[1]

		if(reag.id == D_reag.id)
			merge_with(D)
			return TRUE
	*/
	var/datum/reagent/reag = reagents.reagent_list[1]
	var/datum/reagent/D_reag = D.reagents.reagent_list[1]

	if(reag.id == D_reag.id)
		merge_with(D)
		return TRUE
	return FALSE

/obj/item/dust/proc/merge_with(obj/item/dust/D)
	icon_shift_x = (icon_shift_x + D.icon_shift_x) * 0.5
	icon_shift_y = (icon_shift_y + D.icon_shift_y) * 0.5

	D.reagents.trans_to(src, D.reagents.total_volume)
	update_icon()

/obj/item/dust/examine(mob/living/user)
	..()
	if(isliving(user))
		user.taste_reagents(reagents, "smell")

/obj/item/dust/attack(mob/living/carbon/human/M, mob/living/carbon/user, def_zone)
	if(def_zone == O_EYES && M.react_to_dust(src))
		update_icon()
	return ..()

/obj/item/dust/Moved(atom/OldLoc, Dir)
	. = ..()
	if(.)
		var/obj/item/dust/D = locate() in loc
		if(D && D.react_to_dust(src))
			update_icon()
			return
		if(loc && loc.react_to_dust(src))
			update_icon()

/obj/item/dust/Crossed(atom/movable/AM)
	if(sharp && isliving(AM))
		var/mob/living/M = AM
		if(prob(5))
			to_chat(M, "<span class='warning'><B>You step on the [src]!</B></span>")
			playsound(src, 'sound/effects/glass_step.ogg', VOL_EFFECTS_MASTER)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.species.flags[IS_SYNTHETIC])
				return

			if(H.wear_suit && (H.wear_suit.body_parts_covered & LEGS) && H.wear_suit.flags & THICKMATERIAL)
				return

			if(H.species.flags[NO_MINORCUTS])
				return

			if(H.buckled)
				return

			if(!H.shoes)
				var/obj/item/organ/external/BP = H.bodyparts_by_name[pick(BP_L_LEG , BP_R_LEG)]
				if(BP.is_robotic())
					return
				BP.take_damage(w_class * 2, 0)
				if(!H.species.flags[NO_PAIN])
					H.Weaken(w_class)
				H.updatehealth()
	if(brittle)
		qdel(src)
		return
	..()

/obj/item/dust/update_icon()
	if(QDELING(src))
		return

	if(reagents.total_volume <= 0.0)
		qdel(src)
		return

	var/size = 0
	w_class = ITEM_SIZE_TINY
	if(reagents.total_volume > 15)
		w_class = ITEM_SIZE_SMALL
		size = 3
	else if(reagents.total_volume > 8)
		size = 2
	else if(reagents.total_volume > 2)
		size = 1

	var/hash = "[copy_image.icon]|[w_class]|[icon_shift_x]|[icon_shift_y]"
	if(global.dust_icons_hash[hash])
		icon = global.dust_icons_hash[hash]
	else
		var/my_icon_state = "[initial(icon_state)]_[size]"

		var/icon/ICO = icon(copy_image)
		var/icon/temp_dust = icon(icon=initial(icon), icon_state=my_icon_state)
		temp_dust.Shift(EAST, icon_shift_x)
		temp_dust.Shift(NORTH, icon_shift_y)

		ICO.Blend(temp_dust, ICON_MULTIPLY)
		ICO.Blend(temp_dust, ICON_ADD)
		ICO.Blend(copy_image, ICON_ADD)

		global.dust_icons_hash[hash] = ICO
		icon = ICO

/obj/item/dust/react_to_damage(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	if(!reagents)
		return

	for(var/datum/reagent/reag in reagents.reagent_list)
		var/knocked_amount = min(DM.applied_force * DM.force_area / reag.density, reag.volume)
		reagents.remove_reagent(reag.id, knocked_amount)

		if(knocked_amount >= 0.0)
			update_icon()
