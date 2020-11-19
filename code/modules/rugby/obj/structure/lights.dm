/obj/machinery/floodlight/pitch
	name = "Floodlight"
	brightness_on = 12
	light_power = 2
	use = 0
	on = TRUE

/obj/machinery/floodlight/pitch/atom_init()
	. = ..()
	set_light(brightness_on)
