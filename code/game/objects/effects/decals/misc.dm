/obj/effect/decal/point
	name = "arrow"
	desc = "It's an arrow hanging in mid-air. There may be a wizard about."
	icon = 'icons/mob/screen1.dmi'
	icon_state = "arrow"
	layer = 16.0
	anchored = 1

// Used for spray that you spray at walls, tables, hydrovats etc
/obj/effect/decal/spraystill
	density = 0
	anchored = 1
	layer = 50

/proc/chempuff_spray(obj/effect/decal/chempuff/D, turf/start, turf/target, spray_dist, react_delay, move_delay)
	step_towards(D, start)
	if(D.on_step_callback)
		D.on_step_callback.Invoke()
	sleep(move_delay)
	if(QDELING(D))
		return

	for(var/i in 1 to spray_dist)
		step_towards(D, target)
		if(D.on_step_callback)
			D.on_step_callback.Invoke()
		var/turf/T = get_turf(D)
		D.reagents.reaction(T)
		var/turf/next_T = get_step(T, get_dir(T, target))
		// When spraying against the wall, also react with the wall, but
		// not its contents. BS12
		if(next_T.density)
			D.reagents.reaction(next_T)
			sleep(react_delay)
			if(QDELING(D))
				return
			break
		else
			for(var/atom/A in T)
				D.reagents.reaction(A)
				sleep(react_delay)
				if(QDELING(D))
					return
		sleep(move_delay)
		if(QDELING(D))
			return
	if(D.on_impact_callback)
		D.on_impact_callback.Invoke()
	qdel(D)

//Used by spraybottles.
/obj/effect/decal/chempuff
	name = "chemicals"
	icon = 'icons/obj/chempuff.dmi'
	pass_flags = PASSTABLE | PASSGRILLE

	var/datum/callback/on_impact_callback
	var/datum/callback/on_step_callback

	var/atom/created_by

/obj/effect/decal/chempuff/Destroy()
	QDEL_NULL(on_impact_callback)
	QDEL_NULL(on_step_callback)
	created_by = null
	return ..()
