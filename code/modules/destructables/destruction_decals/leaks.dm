/datum/destruction_decal/leak
	name = "leak"
	dest_type = DEST_POKE
	pos_sizes = list("0" = 8.0)

	colored = FALSE

	var/processing_leak = FALSE

	var/sealed = FALSE // Duct tape can leave the leak, but seal it up.

/datum/destruction_decal/leak/on_creation(atom/movable/perp, datum/reagents/R, datum/destruction_measure/DM)
	var/obj/item/dust/D = carrier.create_dust(R, DM.parameters)
	if(D)
		var/fly_dir = get_dir(carrier, perp)

		var/turf/T = get_step(carrier, fly_dir)
		for(var/i in 1 to DM.max_range - 1)
			T = get_step(T, fly_dir)
		D.throw_at(T, DM.max_range, DM.max_speed)

		process_leak()

/datum/destruction_decal/leak/proc/seal()
	sealed = TRUE

/datum/destruction_decal/leak/proc/unseal()
	sealed = FALSE
	process_leak()

/datum/destruction_decal/leak/proc/process_leak()
	if(processing_leak)
		return

	if(sealed)
		return

	if(QDELING(src) || QDELING(carrier))
		return

	if(!carrier.reagents || carrier.reagents.total_volume <= 0.0)
		return

	processing_leak = TRUE

	if(carrier.is_open_container() || prob(volume))
		var/max_range = max(min(volume * 0.1, 7), 1)

		var/turf/my_turf = get_turf(carrier)
		var/list/pos_turfs = RANGE_TURFS(max_range, my_turf)

		var/to_knock = volume

		// TODO: make it so leaks also thieve through dust of solid reagents?
		for(var/datum/reagent/reag in carrier.reagents.reagent_list)
			if(to_knock <= 0.0)
				break
			if(reag.reagent_state == LIQUID)
				if(prob(5))
					carrier.visible_message("<span class='warning'>[bicon(carrier)] [capitalize(reag.name)] sprays out of [carrier]!</span>")

				// The more leaks an object has, the less it leaks each time...
				var/knocked = CLAMP(volume / (reag.density * carrier.destruction_decals[dest_type].len), 1, 20)
				to_knock -= knocked

				var/turf/target = pick(pos_turfs)
				var/turf/start = get_step(my_turf, get_dir(my_turf, target))

				INVOKE_ASYNC(carrier.reagents, /datum/reagents.proc/spray_at, start, target, knocked, max_range, reag.id)

	var/next_leak = max((10 / volume) SECONDS, 1 SECOND)
	next_leak = rand(next_leak - next_leak * 0.5, next_leak + next_leak * 0.5)
	addtimer(CALLBACK(src, .proc/process_leak), next_leak)
	processing_leak = FALSE
