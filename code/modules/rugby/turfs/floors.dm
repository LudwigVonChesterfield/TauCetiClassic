/turf/unsimulated/floor/pitch
	icon_state = "grass1"

/turf/unsimulated/floor/pitch/atom_init()
	. = ..()
	icon_state = "grass[rand(1, 4)]"

/turf/unsimulated/floor/sport_facility
	icon_state = "barber"