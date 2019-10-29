/datum/reagent
	// Whether dust formed from this reagent is sharp.
	var/is_sharp = FALSE
	var/is_brittle = FALSE // Whether dust will be destroyed if it's stepped on.
	// We knock the reagents out using "force", so we know a pressumed mass of how much to knock out.
	// We assume that one cubic measuring unit is the unit of volume.
	var/density = 1.0
	// How much pressure needs to apply to this reagent for it to even consider splitting out.
	var/pressure_split = 3.0

	// The minimal amount for a particle to split off.
	var/brittle_amount = 1.0

	// The only must-have here is "other", it is used in case nothing else was found in the list.
	var/list/damage_resistance = list(BRUTE = 0.0,
	                                  BURN = 0.0,
	                                  "other" = 0.0)

// I is an optional var put there in case demo is a mob attacking with an item.
// Return how much more "damage" the destructed object should receive, if any.
/datum/reagent/proc/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM, knocked_amount)
	return 0

// I is an optional var put there in case demo is a mob attacking with an item.
// Return how much "damage" the destructed object should receive, if any.
/datum/reagents/proc/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	. = 0
	if(!my_atom)
		return

	if(!demo) // A blob_act, perhaps.
		demo = my_atom

	if(DM.damage_type == BURN && (isturf(my_atom) || isturf(my_atom.loc)))
		var/turf/T = get_turf(my_atom)
		T.hotspot_expose(DM.applied_force, CELL_VOLUME)
		return

	for(var/datum/reagent/reag in reagent_list)
		if(DM.applied_pressure < reag.pressure_split)
			// to_chat(world, "[bicon(my_atom)] Not enough pressure ([DM.applied_pressure]/[reag.pressure_split]) for [reag.name]")
			continue

		var/knocked_amount = min(DM.applied_force * DM.force_area / reag.density, reag.volume)

		// If it's all it is left - forget about the brittle-stuff and etc.
		// We gotta break the thing somehow anyway.
		if(knocked_amount != reag.volume && knocked_amount < reag.brittle_amount)
			// to_chat(world, "[bicon(my_atom)] Not enough amount ([knocked_amount]/[reag.brittle_amount]) for [reag.name]")
			continue

		. += knocked_amount
		. += reag.on_destruction(demo, I, DM, knocked_amount)

		switch(DM.damage_type)
			if(BRUTE)
				if(reag.reagent_state == SOLID)
					var/to_knock = knocked_amount
					var/min_splinters = 1
					if(DM.destruction_type == DEST_SLASH || DM.destruction_type == DEST_BLUNT)
						min_splinters = max(rand(1, knocked_amount / 5), 1)

					while(to_knock > 0.1)
						// max dust size is 15, but we give it a bit of doubt, so, let's say 20 units.
						var/knocked = min(min(knocked_amount / min_splinters, to_knock), 20)
						to_knock -= knocked

						var/datum/reagents/R = new(1000)
						trans_id_to(R, reag.id, knocked)

						switch(DM.destruction_type)
							if(DEST_POKE)
								new /datum/destruction_decal/leak(my_atom, demo, R, DM)
							if(DEST_SLASH)
								new /datum/destruction_decal/scratch(my_atom, demo, R, DM)
							if(DEST_PRODE)
								new /datum/destruction_decal/blunt(my_atom, demo, R, DM)
							if(DEST_BLUNT)
								new /datum/destruction_decal/crack(my_atom, demo, R, DM)

				else if(reag.reagent_state == LIQUID && DM.destruction_type == DEST_POKE && (isturf(my_atom) || isturf(my_atom.loc)))
					var/max_range = max(min(DM.applied_force / 10, 7), 1)

					var/turf/my_turf = get_turf(my_atom)
					var/list/pos_turfs = RANGE_TURFS(max_range, my_turf)

					if(prob(30))
						my_atom.visible_message("<span class='warning'>[bicon(my_atom)] [capitalize(reag.name)] sprays out of [my_atom]!</span>")

					var/to_knock = knocked_amount
					while(to_knock > 0)
						// Since this is a liquid, pressure is the thing that dictates how much should fly out
						// not force.
						var/knocked = min(DM.applied_pressure / reag.density, 20)
						to_knock -= knocked

						var/turf/target = pick(pos_turfs)
						var/turf/start = get_step(my_turf, get_dir(my_turf, target))

						INVOKE_ASYNC(src, /datum/reagents.proc/spray_at, start, target, knocked, max_range, reag.id)

			if(BURN)
				// TODO: make get_temperature or some shit damage us and cause some reagents to melt and spill out and shit.
				return

/datum/reagents/proc/spray_at(turf/start, turf/target, amount, max_steps, id)
	if(!my_atom)
		return

	var/obj/effect/decal/chempuff/D = new/obj/effect/decal/chempuff(get_turf(my_atom))
	D.create_reagents(amount)
	if(id)
		trans_id_to(D, id, amount)
	else
		trans_to(D, amount)
	D.icon += mix_color_from_reagents(D.reagents.reagent_list)

	chempuff_spray(D, start, target, max_steps, 1, 2)
