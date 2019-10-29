/atom
	/*
		Interpret received_damage as "structural damage", while
		missing reagents from destruction_reagents as absent materials, that shattered away.

		So you can be structurally sound, yet not have all the neccessary materials,
		and it can be vice-versa, you can be structurally unsound, because the neccesary materials
		are just all clumped together.
	*/
	// <BLOCK> all of the variables in this block should not be changed directly.
	var/is_destructible = FALSE
	var/max_received_damage = 0
	var/received_damage = 0
	// The "threshod" is really determined by how "brittle" materials are.
	// Stop making for-no-reason impervious structures, at least invent something "hard" for them. ~Luduk.
	// var/received_damage_threshold = 0
	var/temperature_threshold = 0

	var/list/damage_resistance = list(BRUTE = 0.0,
	                                  BURN = 0.0,
	                                  "other" = 0.0)

	// Assoc list of decal_type = list(*/datum/destruction_decal*)
	var/list/destruction_decals = list()
	var/datum/reagents/destruction_reagents

	// TODO: use this everywhere, get mass by multiplying this with get_size()
	var/total_density = 0
	// </BLOCK>

	/*
		The below variables determine all the behavior unless you delve deeper into the procs.
	*/

	// Assoc list of form reagent = amount that will initiate in destruction_reagents.
	var/list/spawn_destruction_reagents

/atom/proc/setup_destructability()
	if(spawn_destruction_reagents && !(flags & NODECONSTRUCT))
		is_destructible = TRUE
		destruction_reagents = new(1000)
		destruction_reagents.my_atom = src
		for(var/reagent_name in spawn_destruction_reagents)
			destruction_reagents.add_reagent(reagent_name, spawn_destruction_reagents[reagent_name])

		for(var/datum/reagent/R in destruction_reagents.reagent_list)
			for(var/res_value in R.damage_resistance)
				if(damage_resistance[res_value])
					damage_resistance[res_value] += R.damage_resistance[res_value] * (spawn_destruction_reagents[R.id] / destruction_reagents.total_volume)
				else
					damage_resistance[res_value] = R.damage_resistance[res_value] * (spawn_destruction_reagents[R.id] / destruction_reagents.total_volume)
			total_density += R.density * R.volume
		max_received_damage = destruction_reagents.total_volume

/atom/proc/update_destruction_decals()
	for(var/decal_type in destruction_decals)
		var/list/decals = destruction_decals[decal_type]
		for(var/datum/destruction_decal/DC in decals)
			overlays.Add(DC.decal)

/atom/proc/get_resistance(damage_type)
	if(damage_resistance[damage_type])
		return damage_resistance[damage_type]
	else if(damage_resistance["other"])
		return damage_resistance["other"]
	return 0.0

/atom/proc/getDamageLoss(value)
	return received_damage

/atom/proc/adjustDamageLoss(value)
	var/d = min(max_received_damage - received_damage, value)
	received_damage += d
	if(value > 0.0)
		onDamageLoss(d)

/atom/proc/setDamageLoss(value)
	var/new_received_damage = min(max_received_damage, value)
	var/d = value - new_received_damage
	received_damage = new_received_damage
	if(d > 0.0)
		onDamageLoss(d)

// This proc should handle breaking src apart,
// materials falling off, etc.
/atom/proc/onDamageLoss(value)
	update_received_damage()

/atom/proc/update_received_damage()
	if(received_damage >= max_received_damage || destruction_reagents.total_volume <= 0.0)
		on_destroy()

/atom/proc/crumble_to_dust()
	visible_message("[bicon(src)] <span class='warning'>[src] crumbles down into dust!</span>")

	for(var/reagent_name in spawn_destruction_reagents)
		var/clumps = rand(1, min(round(spawn_destruction_reagents[reagent_name] * 10 / max_received_damage), 10.0))
		for(var/i in 1 to clumps)
			if(spawn_destruction_reagents[reagent_name] / clumps < 0.5)
				continue
			var/datum/reagents/R = new(1000)
			R.add_reagent(reagent_name, min(round(spawn_destruction_reagents[reagent_name] / clumps), 10.0))

			var/list/params_to_pass = list()
			params_to_pass["icon_x"] = rand(-world.icon_size / 2, world.icon_size / 2)
			params_to_pass["icon_y"] = rand(-world.icon_size / 2, world.icon_size / 2)

			create_dust(R, params_to_pass)

/atom/proc/on_destroy()
	// Most of the dust will vanish anyway due to it moving, and dissapearing when moved.
	crumble_to_dust()

	if(reagents && reagents.total_volume)
		var/max_range = 7

		var/turf/my_turf = get_turf(src)
		var/list/pos_turfs = RANGE_TURFS(max_range, my_turf)

		// Since this is a liquid, pressure is the thing that dictates how much should fly out
		// not force.

		var/turf/target = pick(pos_turfs)
		var/turf/start = get_step(my_turf, get_dir(my_turf, target))

		var/sprays = rand(1, 8)

		for(var/i in 1 to sprays)
			INVOKE_ASYNC(reagents, /datum/reagents.proc/spray_at, start, target, max(reagents.total_volume / sprays, 1), max_range)

	QDEL_IN(src, 0.5 SECONDS)

/atom/proc/react_to_damage(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	if(!is_destructible)
		return

	// We're probably qdeling or something.
	if(!destruction_reagents)
		to_chat(world, "[demo] has [is_destructible] but no destruction_reagents. huh?")
		return

	if(DM.applied_force <= 0.0)
		return

	var/dam = destruction_reagents.on_destruction(demo, I, DM)

	// Custom damage-receiving code here, such as buckets falling over on a high blunt attack.
	dam += on_destruction(demo, I, DM)
	adjustDamageLoss(dam)

// user, I, and R can all be null.
// user is the one who could initiate the repair, I is what we repair with, R is what reagents we use.
// (R is used to repair decals, otheriwse only received_damage will be repaired).
/atom/proc/react_to_repair(amount, mob/living/user, obj/item/I, datum/reagents/R)
	adjustDamageLoss(-amount)

	if(R)
		for(var/decal_type in destruction_decals)
			var/list/decals = destruction_decals[decal_type]
			for(var/datum/destruction_decal/DC in decals)
				DC.repair(R)

// This proc processes everything related to destruction,
// if I is null, user's strength will be evaluated.
/atom/proc/attack_destructible(mob/living/user, obj/item/I)
	if(is_destructible)
		var/list/click_params = params2list(user.last_click_params)
		var/list/params_to_pass = list()
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return
		params_to_pass["icon_x"] = CLAMP(text2num(click_params["icon-x"]) - 16, -(world.icon_size / 2), world.icon_size / 2)
		params_to_pass["icon_y"] = CLAMP(text2num(click_params["icon-y"]) - 16, -(world.icon_size / 2), world.icon_size / 2)

		var/datum/destruction_measure/DM = new /datum/destruction_measure(,,,,,,params_to_pass)
		DM.evaluate_attack(src, user, I)
		react_to_damage(user, I, DM)

	if(I && !(I.flags & NOBLUDGEON))
		visible_message("<span class='danger'>[src] has been hit by [user] with [I].</span>")
	add_fingerprint(user)

	if(!I || !(I.flags & NOATTACKANIMATION))
		user.do_attack_animation(src)
	user.SetNextMove(CLICK_CD_MELEE)

// Return any additional received "damage", if any.
/atom/proc/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	return 0

/atom/proc/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return TRUE

/atom/proc/disarmReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return TRUE

/atom/proc/grabReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return TRUE

/atom/proc/hurtReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return attack_destructible(attacker)

/atom/proc/attack_unarmed(mob/living/attacker)
	switch(attacker.a_intent)
		if(I_HELP)
			return helpReaction(attacker)
		if(I_DISARM)
			return disarmReaction(attacker)
		if(I_GRAB)
			return grabReaction(attacker)
		if(I_HURT)
			return hurtReaction(attacker)

/atom/proc/attack_hand(mob/living/carbon/human/attacker)
	return attack_unarmed(attacker)

/atom/proc/attack_animal(mob/living/simple_animal/attacker)
	if(attacker.environment_smash)
		return attack_destructible(attacker)
	return TRUE

/atom/proc/attack_paw(mob/living/attacker)
	return attack_destructible(attacker)

/atom/proc/attack_slime(mob/living/attacker)
	return attack_destructible(attacker)

/atom/proc/attack_alien(mob/living/attacker)
	return attack_paw(attacker)

/atom/proc/attack_larva(mob/living/attacker)
	return attack_destructible(attacker)

/atom/proc/attack_facehugger(mob/living/attacker)
	return attack_destructible(attacker)

/atom/proc/hitby(atom/movable/AM)
	var/datum/destruction_measure/DM = new /datum/destruction_measure()
	DM.evaluate_hit(src, AM)
	react_to_damage(AM, null, DM)

/atom/proc/attackby(obj/item/I, mob/user, params)
	return

// Proximity_flag is 1 if this afterattack was called on something adjacent, in your square, or on your person.
// Click parameters is the params string from byond Click() code, see that documentation.
/obj/item/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag && user.a_intent == I_HURT)
		target.attack_destructible(user, src)
		if(enchanted)
			cast_enchantments(list(target))

/atom/proc/blob_act(severity)
	var/datum/destruction_measure/brute_ex = new(src,
		75.0,
		1.0,
		,
		BRUTE,
		DEST_BLUNT)
	react_to_damage(null, null, brute_ex)

/atom/proc/ex_act(legacy_severity, turf/epicenter, severity, pressure_modifier)
	if(!severity)
		severity = (4.0 - legacy_severity) * 3.0
		epicenter = get_turf(src)
		pressure_modifier = 0.0625

	var/datum/destruction_measure/burn_ex
	burn_ex = new(src,
		severity * 5.0,
		1.0,
		,
		HITZONE_MIDDLE,
		BURN)
	react_to_damage(epicenter, null, burn_ex)

	var/datum/destruction_measure/brute_ex = new(src,
		severity * 30.0,
		1.0,
		,
		BRUTE,
		DEST_BLUNT)
	react_to_damage(epicenter, null, brute_ex)

/atom/proc/bullet_act(obj/item/projectile/P, def_zone)
	if(istype(P, /obj/item/projectile/beam/pulse))
		ex_act(2.0)
	else if(istype(P, /obj/item/projectile/bullet/gyro))
		explosion(src, -1, 0, 2)

	var/list/params_to_pass = list()
	params_to_pass["icon_x"] = CLAMP(P.p_x - 16, -(world.icon_size / 2), world.icon_size / 2)
	params_to_pass["icon_y"] = CLAMP(P.p_y - 16, -(world.icon_size / 2), world.icon_size / 2)

	var/datum/destruction_measure/bullet_DM = new /datum/destruction_measure(,,,,,,params_to_pass)
	bullet_DM.evaluate_bullet(src, P, def_zone)

	react_to_damage(P, null, bullet_DM)

	return P.on_hit(src, 0, def_zone)
