/proc/get_pitch_cursor_turf()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name == "Pitch Cursor")
			return get_turf(L)

/proc/equip_class_gear(mob/L, chosen_class)
	for(var/obj/item/I in inventory_crates_by_class[chosen_class])
		var/obj/item/new_I = new I.type(L)
		if(!L.equip_to_appropriate_slot(new_I))
			qdel(new_I)

/proc/strip_to_closet(mob/L, obj/structure/closet/C)
	for(var/obj/item/I in L)
		L.remove_from_mob(I, C)
