/datum/spell_modifier
	var/add_power = 0.0
	var/mult_power = 1.0
	var/add_delay = 0.0
	var/mult_delay = 1.0
	var/add_casts = 0
	// var/mult_casts = 1.0
	var/add_mana_cost = 0.0
	var/mult_mana_cost = 1.0

	var/boomerang = FALSE

	// Will cause each spell to diverge from target into diverge_dir
	var/list/diverge_dirs
	// If add_casts > 0, this will cause the spells to fly into different directions, or whatever.
	var/list/additional_cast_dirs

/datum/spell_modifier/proc/get_copy()
	var/datum/spell_modifier/SM = new type()
	SM.add_power = add_power
	SM.mult_power = mult_power
	SM.add_delay = add_delay
	SM.mult_delay = mult_delay
	SM.add_casts = add_casts
	SM.add_mana_cost = add_mana_cost
	SM.mult_mana_cost = mult_mana_cost
	SM.boomerang = boomerang
	SM.diverge_dirs = diverge_dirs
	SM.additional_cast_dirs = additional_cast_dirs
	return SM

// Returns new target.
/datum/spell_modifier/proc/apply_dir_effects(atom/target, atom/source, i)
	if(diverge_dirs)
		var/div_dirs_len = diverge_dirs.len
		var/datum/diverge_dir/cur_div = diverge_dirs[((i - 1) % div_dirs_len) + 1]
		target = cur_div.get_effect(target, source)
	if(additional_cast_dirs)
		var/add_cast_dirs_len = additional_cast_dirs.len
		var/datum/cast_dir/cur_cast_dir = additional_cast_dirs[((i - 1) % add_cast_dirs_len) + 1]
		target = cur_cast_dir.get_effect(target, source)
	return target