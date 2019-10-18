/obj/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	. = ..()
	if(isturf(loc) && !anchored && DM.damage_type == BRUTE && DM.damage_zone == HITZONE_LOWER)
		var/step_dirs
		if(demo != src)
			switch(DM.damage_type)
				if(DEST_PRODE, DEST_POKE)
					step_dirs = list(get_dir(demo, src))
				if(DEST_SLASH, DEST_BLUNT)
					step_dirs = list(turn(get_dir(demo, src), pick(-90, 90)))
		else if(DM.damage_type == "shake")
			step_dirs = alldirs

		if(!step_dirs)
			return

		var/est_mass = get_mass()
		if(DM.applied_force > est_mass)
			var/steps = round(DM.applied_force / est_mass)

			if(DM.damage_type == "shake")
				var/msg = ""
				if(steps >= 3.0)
					msg = "<span class='warning'>[src] trembles menacingly!</span>"
				else if(steps == 2.0)
					msg = "<span class'warning'>[src] trembles!</span>"
				else
					msg = "<span class='notice'>[src] shakes a little.</span>"
				visible_message("[bicon(src)] [msg]")

			for(var/i in 1 to steps)
				step(src, pick(step_dirs))

/obj/machinery/constructable_frame/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	if(DM.applied_pressure >= get_mass() && DM.damage_type == BRUTE)
		switch(DM.destruction_type)
			if(DEST_POKE, DEST_SLASH)
				if(state == 2)
					state = 1
					visible_message("<span class='warning'>[src]'s cables are cut!</span>")
					new /obj/item/stack/cable_coil/random(loc, 1)
			if(DEST_PRODE, DEST_BLUNT)
				switch(state)
					if(1)
						anchored = FALSE
					if(2)
						if(circuit)
							circuit.forceMove(loc)
							state = 1
					if(3)
						if(components.len)
							var/obj/item/component_to_knock = pick(components)
							component_to_knock.forceMove(loc)
							components -= component_to_knock
							req_components[component_to_knock.type]++
							update_req_desc()
						else
							state = 2
	return ..()

/obj/machinery/constructable_frame/default_deconstruct()
	on_destroy()

/obj/machinery/update_received_damage()
	if(received_damage >= max_received_damage || destruction_reagents.total_volume <= 0.0)
		on_destroy()
	else if(received_damage >= max_received_damage * 0.5)
		default_deconstruct()

/obj/structure/computerframe/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	if(DM.applied_pressure >= get_mass() && DM.damage_type == BRUTE)
		switch(DM.destruction_type)
			if(DEST_POKE, DEST_SLASH)
				if(state == 3)
					state = 2
					visible_message("<span class='warning'>[src]'s cables are cut!</span>")
					new /obj/item/stack/cable_coil/random(loc, 1)
			if(DEST_PRODE, DEST_BLUNT)
				switch(state)
					if(1)
						anchored = FALSE
						state = 0
					if(2)
						if(circuit)
							circuit.forceMove(loc)
							state = 1
					if(4)
						visible_message("<span class='warning'>[src]'s screen shatters!</span>")
						new /obj/item/weapon/shard(loc)
						state = 3
	return ..()

/obj/structure/door_assembly/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	if(DM.applied_pressure >= get_mass() && DM.damage_type == BRUTE)
		switch(DM.destruction_type)
			if(DEST_POKE, DEST_SLASH)
				if(state == ASSEMBLY_WIRED)
					state = ASSEMBLY_SECURED
					visible_message("<span class='warning'>[src]'s cables are cut!</span>")
					new /obj/item/stack/cable_coil/random(loc, 1)
					update_state()
			if(DEST_PRODE, DEST_BLUNT)
				switch(state)
					if(ASSEMBLY_SECURED)
						anchored = FALSE
					if(ASSEMBLY_NEAR_FINISHED)
						state = ASSEMBLY_WIRED
						var/obj/item/weapon/airlock_electronics/AE
						if(!electronics)
							AE = new /obj/item/weapon/airlock_electronics(loc)
						else
							AE = electronics
							electronics = null
							AE.forceMove(loc)
						update_state()
	return ..()
