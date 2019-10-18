#define HIT_AREA_POINT 0.1 // If hit_area_coeff of anything is below this, it's a poke/prode.

/datum/destruction_measure
	var/applied_force = 0.0
	var/force_area = 0.0
	var/applied_pressure = 0.0

	var/damage_zone = HITZONE_MIDDLE
	var/damage_type = BRUTE
	var/destruction_type = DEST_BLUNT

	var/max_range = 0
	var/max_speed = 0

	var/list/parameters

/datum/destruction_measure/New(atom/target, force, area, damage_zone, damage_type, destruction_type, list/parameters)
	src.parameters = parameters

	if(!target)
		return
	if(!target.is_destructible)
		return

	var/resistance = target.get_resistance(damage_type)

	applied_force = force
	force_area = min(area, target.get_size())

	applied_force *= max(1.0 - resistance, 0.0)

	src.damage_zone = damage_zone
	src.damage_type = damage_type

	src.destruction_type = destruction_type

	calc_additional_values()

/datum/destruction_measure/proc/calc_additional_values()
	if(!damage_zone)
		if(parameters && parameters["icon_y"])
			switch(parameters["icon_y"])
				if((world.icon_size / 3) to (world.icon_size / 2))
					damage_zone = HITZONE_UPPER
		else
			damage_zone = pick(HITZONE_UPPER, HITZONE_MIDDLE, HITZONE_LOWER)

	if(damage_type == BRUTE)
		if(force_area == 0.0)
			applied_force = 0.0 // We didn't actually even hit them.
			applied_pressure = 0.0
		else
			applied_pressure = applied_force / force_area

		// TODO: insert physics if wished
		max_range = max(min(applied_force * 0.1, 7), 1)
		max_speed = min(applied_force * 0.1, 7)

// This proc will determine all the stats of the attack that happened.
// if I is null, user's strength will be evaluated.
/datum/destruction_measure/proc/evaluate_attack(atom/target, mob/living/user, obj/item/I)
	if(!target.is_destructible)
		return

	applied_force = 0.0
	damage_type = BRUTE
	damage_zone = targetzone2hitzone(user.get_targetzone())

	var/area_multiplier = 1.0
	switch(damage_zone)
		if(HITZONE_UPPER)
			area_multiplier = 0.8
		if(HITZONE_MIDDLE)
			area_multiplier = 1.0
		if(HITZONE_LOWER)
			area_multiplier = 0.8

	if(I)
		applied_force = I.force
		damage_type = I.damtype
		if(I.edge && I.is_sweeping && I.hit_area_coeff > HIT_AREA_POINT)
			destruction_type = DEST_SLASH
		else if(I.sharp)
			destruction_type = DEST_POKE
		else if(I.is_sweeping && I.hit_area_coeff > HIT_AREA_POINT)
			destruction_type = DEST_BLUNT
		else
			destruction_type = DEST_PRODE
	else
		var/list/attack_obj = user.get_unarmed_attack()
		applied_force = attack_obj["damage"]
		damage_type = attack_obj["type"]
		if(attack_obj["flags"] & (DAM_SHARP|DAM_EDGE))
			destruction_type = DEST_POKE
		else
			destruction_type = DEST_PRODE

	var/resistance = target.get_resistance(damage_type)

	applied_force *= max(1.0 - resistance, 0.0)

	if(damage_type == BRUTE)
		if(I)
			force_area = I.hit_area_coeff * area_multiplier * I.w_class
		else
			force_area = area_multiplier
		force_area = min(force_area, target.get_size())

	calc_additional_values()

// This proc will determine all the stats of a hit received from a thrown object demo.
// if I is null, user's strength will be evaluated.
/datum/destruction_measure/proc/evaluate_hit(atom/target, atom/movable/demo)
	if(!target.is_destructible)
		return

	applied_force = 0.0
	damage_type = BRUTE
	damage_zone = pick(HITZONE_UPPER, HITZONE_MIDDLE, HITZONE_LOWER)

	var/area_multiplier = 1.0
	switch(damage_zone)
		if(HITZONE_UPPER)
			area_multiplier = 0.8
		if(HITZONE_MIDDLE)
			area_multiplier = 1.0
		if(HITZONE_LOWER)
			area_multiplier = 0.8

	if(istype(demo, /obj/item))
		var/obj/item/I = demo
		applied_force = I.throwforce
		damage_type = I.damtype

		// It was flying, consider it "swiping".
		if(I.edge && I.hit_area_coeff > HIT_AREA_POINT)
			destruction_type = DEST_SLASH
		else if(I.sharp)
			destruction_type = DEST_POKE
		else if(I.hit_area_coeff > HIT_AREA_POINT)
			destruction_type = DEST_BLUNT
		else
			destruction_type = DEST_PRODE

	var/resistance = target.get_resistance(damage_type)

	applied_force *= max(1.0 - resistance, 0.0)

	if(damage_type == BRUTE)
		if(istype(demo, /obj/item))
			var/obj/item/I = demo
			force_area = I.hit_area_coeff * area_multiplier * I.w_class
		else
			force_area = area_multiplier
		force_area = min(force_area, target.get_size())

	calc_additional_values()

// This proc will determine all the stats of a hit received from a bullet.
// if I is null, user's strength will be evaluated.
/datum/destruction_measure/proc/evaluate_bullet(atom/target, obj/item/projectile/P, target_zone)
	if(!target.is_destructible)
		return

	if(!target_zone)
		target_zone = ran_zone(BP_CHEST)

	applied_force = P.damage + P.impact_force
	damage_type = P.damage_type
	damage_zone = targetzone2hitzone(target_zone)

	var/area_multiplier = 1.0
	switch(damage_zone)
		if(HITZONE_UPPER)
			area_multiplier = 0.8
		if(HITZONE_MIDDLE)
			area_multiplier = 1.0
		if(HITZONE_LOWER)
			area_multiplier = 0.8

	// It was flying, consider it "swiping".
	if(P.edge && P.hit_area_coeff > HIT_AREA_POINT)
		destruction_type = DEST_SLASH
	else if(P.sharp)
		destruction_type = DEST_POKE
	else if(P.hit_area_coeff > HIT_AREA_POINT)
		destruction_type = DEST_BLUNT
	else
		destruction_type = DEST_PRODE

	var/resistance = target.get_resistance(damage_type)

	applied_force *= max(1.0 - resistance, 0.0)

	if(damage_type == BRUTE)
		force_area = P.hit_area_coeff * area_multiplier * P.w_class
		force_area = min(force_area, target.get_size())

	calc_additional_values()
