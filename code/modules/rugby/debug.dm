/mob/verb/to_the_pitch()
	set name = "Teleport to the Pitch"
	set category = "Event"

	var/list/T = get_area_turfs(/area/rugby/pitch)
	forceMove(pick(T))

/mob/living/verb/equip_class_gear()
	set name = "Equip class"
	set category = "Event"

	var/chosen_class = input(usr, "Please choose a class to be equipped with.") as null|anything in inventory_crates_by_class

	for(var/obj/item/I in src)
		qdel(I)

	for(var/obj/item/I in inventory_crates_by_class[chosen_class])
		var/obj/item/new_I = new I.type(src)
		if(!equip_to_appropriate_slot(new_I))
			qdel(new_I)
