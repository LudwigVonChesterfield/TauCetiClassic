/datum/destruction_decal/blunt
	name = "blunt"
	dest_type = DEST_PRODE
	pos_sizes = list("0" = 8.0)

/datum/destruction_decal/blunt/on_creation(atom/movable/perp, datum/reagents/R, datum/destruction_measure/DM)
	var/obj/item/dust/D = carrier.create_dust(R, DM.parameters)
	if(D)
		var/list/pos_turfs = RANGE_TURFS(DM.max_range, carrier)
		if(istype(carrier, /atom/movable))
			var/atom/movable/AM = carrier
			AM.newtonian_move(get_dir(perp, AM))
		D.throw_at(pick(pos_turfs), DM.max_range, DM.max_speed)
