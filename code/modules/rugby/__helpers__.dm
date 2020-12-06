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

/proc/show_spawn_area_to(mob/living/L, obj/effect/landmark/rugby/R, obj/item/device/coach_tablet/CT)

/proc/show_spawn_areas(mob/living/L, obj/item/device/coach_tablet/CT)
	for(var/O in landmarks_list)
		if(!istype(O, /obj/effect/landmark/rugby))
			continue

		var/obj/effect/landmark/rugby/R = O
		if(!R.data || !R.data["Spawn Area"])
			continue

		if(R.team == CT.team.role)
			show_spawn_area_to(L, R, CT)

/proc/show_landmark_to(mob/living/L, obj/effect/landmark/rugby/R)
	var/image/C = image('code/modules/rugby/icons/landmarks.dmi', "[R.data["Class"]]")
	C.appearance_flags |= RESET_ALPHA

	var/image/I = image('code/modules/rugby/icons/landmarks.dmi', "[R.team]_[R.data["Player"]]")
	I.overlays += C
	I.override = TRUE
	I.loc = R
	I.appearance_flags |= RESET_ALPHA
	R.add_alt_appearance(
		/datum/atom_hud/alternate_appearance/basic/one_person,
		"landmark_overlay",
		I,
		L
	)
