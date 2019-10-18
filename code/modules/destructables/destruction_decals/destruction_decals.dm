/datum/destruction_decal
	var/name = "decal"
	var/dest_type = DEST_BLUNT

	var/radius = 2.0

	var/colored = TRUE

	// Assoc list of format "size" = *max volume*
	// If something is bigger than anything in this list, it'll use "max".
	var/list/pos_sizes = list()
	var/list/pos_variations = list("0")

	var/decal_icon = 'icons/obj/destructables_decals.dmi'

	// What reag can be applied to this decal so it would fade or lessen up.
	var/reag_id = "iron"
	// How much of reag_id is required to completely remove the decal.
	var/volume = 0

	var/icon/decal
	var/decal_icon_x = 0
	var/decal_icon_y = 0

	var/atom/movable/carrier

/datum/destruction_decal/New(atom/target, atom/movable/perp, datum/reagents/R, datum/destruction_measure/DM)
	if(R.reagent_list.len == 0)
		return

	var/datum/reagent/reag = R.reagent_list[1]
	reag_id = reag.id
	volume = reag.volume

	if(DM.parameters && DM.parameters["icon_x"] && DM.parameters["icon_y"])
		decal_icon_x = DM.parameters["icon_x"]
		decal_icon_y = DM.parameters["icon_y"]
	else
		decal_icon_x = rand(-world.icon_size / 2, world.icon_size / 2)
		switch(DM.damage_zone)
			if(HITZONE_UPPER)
				decal_icon_y = rand(world.icon_size / 3, world.icon_size / 2)
			if(HITZONE_MIDDLE)
				decal_icon_y = rand(-world.icon_size / 3, world.icon_size / 3)
			if(HITZONE_LOWER)
				decal_icon_y = rand(-world.icon_size / 2, -world.icon_size / 3)

	if(target.destruction_decals[dest_type])
		for(var/datum/destruction_decal/DD in target.destruction_decals[dest_type])
			if(DD.merge_check(src))
				DD.merge_with(src)
				return

		target.destruction_decals[dest_type] += src
	else
		target.destruction_decals[dest_type] = list(src)

	carrier = target

	on_creation(perp, R, DM)
	update_icon()

/datum/destruction_decal/Destroy()
	carrier.overlays.Remove(decal)
	decal = null

	carrier.destruction_decals[dest_type] -= src
	if(carrier.destruction_decals[dest_type].len == 0)
		carrier.destruction_decals -= type

	carrier = null

	return ..()

/datum/destruction_decal/proc/get_examine_msg(datum/destruction_decal/DD)
	var/am_text = ""
	var/decal_span = "info"
	switch(carrier.destruction_decals[dest_type].len)
		if(1)
			am_text = "Has a single [name]."
		if(2 to 5)
			am_text = "Has a [name] here and there."
		if(5 to 10)
			am_text = "Has a [name] here, and there... and here..."
			decal_span = "warning"
		else
			am_text = "Has a [name] in more places than it should ever have!"
			decal_span = "danger"
	return "<span class=[decal_span]>[am_text]</span>"

/datum/destruction_decal/proc/merge_check(datum/destruction_decal/DD)
	if(DD.reag_id != reag_id)
		return FALSE
	if(DD.decal_icon_x - DD.radius * 0.5 >= decal_icon_x + radius * 0.5)
		return FALSE
	if(DD.decal_icon_x + radius * 0.5 <= decal_icon_x - radius * 0.5)
		return FALSE
	if(DD.decal_icon_y - DD.radius * 0.5 >= decal_icon_y + radius * 0.5)
		return FALSE
	if(DD.decal_icon_y  + radius * 0.5 <= decal_icon_y - radius & 0.5)
		return FALSE
	return TRUE

/datum/destruction_decal/proc/merge_with(datum/destruction_decal/DD)
	volume += DD.volume
	update_icon()

// Here we handle all the different possible effects.
/datum/destruction_decal/proc/on_creation(atom/movable/perp, datum/reagents/R, datum/destruction_measure/DM)
	return

/datum/destruction_decal/proc/repair(datum/reagents/R)
	for(var/datum/reagent/reag in R.reagent_list)
		if(reag.id == reag_id)
			var/d = min(reag.volume, volume)
			R.remove_reagent(reag.id, d)

			volume -= d

			update_icon()
			break

var/global/list/decals_overlay_by_type = list()

/datum/destruction_decal/proc/update_icon()
	if(volume <= 0.0)
		qdel(src)
		return

	if(decal)
		carrier.overlays.Remove(decal)

	var/sz = "max"
	for(var/pos_size in pos_sizes)
		if(volume < pos_sizes[pos_size])
			sz = pos_size
			break

	var/gen_is = "[dest_type]_[pick(pos_variations)]_[sz]"

	var/hash = "[carrier.icon_state]|[carrier.type]|[gen_is]|[decal_icon_x]|[decal_icon_y]"

	if(global.decals_overlay_by_type[hash])
		decal = global.decals_overlay_by_type[hash]
	else
		var/icon/ICO = icon(icon=carrier.icon, icon_state=carrier.icon_state)

		var/icon/temp_decal = icon(icon=decal_icon, icon_state=gen_is)
		temp_decal.Shift(EAST, decal_icon_x)
		temp_decal.Shift(NORTH, decal_icon_y)

		ICO.Blend(temp_decal, ICON_MULTIPLY)
		if(colored)
			ICO.Blend(icon(icon=carrier.icon, icon_state=carrier.icon_state), ICON_ADD)
			ICO.SetIntensity(0.6)

		decal = ICO

		global.decals_overlay_by_type[hash] = decal

	carrier.overlays.Add(decal)
