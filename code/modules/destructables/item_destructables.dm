#define HIT_AREA_COEFF_UNSET -1.0

#define DEFAULT_HIT_AREA_COEFF 1.0
#define SHARP_EDGE_HIT_AREA_COEFF 0.3
#define EDGE_HIT_AREA_COEFF 0.1
#define SHARP_HIT_AREA_COEFF 0.5

/obj/item
	var/hit_area_coeff = HIT_AREA_COEFF_UNSET // How much of our w_class is actually "touching" on attack. If set to 0, item will deal no "realistic" damage.
	// var/weight = 1.0 // force acts as a measure of our "weight", since let's assume that all mobs attack with same acceleration...

/obj/item/weapon/setup_destructability()
	if(hit_area_coeff == HIT_AREA_COEFF_UNSET)
		if(sharp && edge)
			hit_area_coeff = SHARP_EDGE_HIT_AREA_COEFF
		else if(sharp)
			hit_area_coeff = SHARP_HIT_AREA_COEFF
		else if(edge)
			hit_area_coeff = EDGE_HIT_AREA_COEFF
		else
			hit_area_coeff = DEFAULT_HIT_AREA_COEFF

	// -1 is used as "unset", and will automatically pick a value here.
	if(sweep_step == -1)
		sweep_step = w_class + 1

	if(w_class >= ITEM_SIZE_NORMAL)
		can_sweep = TRUE

		if(hit_area_coeff <= SHARP_EDGE_HIT_AREA_COEFF)
			can_push = TRUE
			can_pull = TRUE

			if(force >= 10.0)
				hit_on_harm_push = TRUE
				hit_on_harm_pull = TRUE

	if(w_class >= ITEM_SIZE_LARGE)
		if(hit_area_coeff <= SHARP_EDGE_HIT_AREA_COEFF)
			can_push_on_chair = TRUE

		if(damtype == BRUTE && sharp && edge)
			interupt_on_sweep_hit_types = list(/turf, /obj/machinery/disposal, /obj/structure/table, /obj/structure/rack, /obj/effect/effect/weapon_sweep)

		if(istype(src, /obj/item/weapon/twohanded))
			spin_on_middleclick = TRUE

		can_spin = TRUE

	// Energy weapons shouldn't be stopped by pesky walls.
	if(flags & NOBLOODY || damtype == BURN)
		interupt_on_sweep_hit_types = list(/obj/structure/table, /obj/machinery/disposal, /obj/structure/rack)

	..()
