/datum/destruction_decal/scratch
	name = "scratch"
	dest_type = DEST_SLASH
	pos_sizes = list()

/datum/destruction_decal/scratch/on_creation(atom/movable/perp, datum/reagents/R, datum/destruction_measure/DM)
	var/obj/item/dust/D = carrier.create_dust(R, DM.parameters)
	if(D)
		var/attack_dir = get_dir(perp, carrier)
		var/fly_dir = turn(attack_dir, pick(90, -90))

		var/turf/T = get_step(carrier, fly_dir)
		for(var/i in 1 to DM.max_range - 1)
			T = get_step(T, fly_dir)
		D.throw_at(T, DM.max_range, DM.max_speed)
