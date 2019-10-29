/datum/diverge_dir
	var/angle

/datum/diverge_dir/proc/get_effect(atom/target, atom/source)
	if(angle)
		var/turf/new_targ = get_step(get_turf(target), turn(get_dir(source, target), angle))
		return new_targ
	return target

/datum/cast_dir
	var/angle

// Returns new_target for this cast_dir.
/datum/cast_dir/proc/get_effect(atom/target, atom/source)
	if(angle)
		var/vec_x = target.x - source.x
		var/vec_y = target.y - source.y
		var/new_vec_x = round(cos(angle) * vec_x - sin(angle) * vec_y)
		var/new_vec_y = round(sin(angle) * vec_x + cos(angle) * vec_y)
		var/turf/new_targ = locate(source.x + new_vec_x, source.y + new_vec_y, source.z)
		return new_targ
	return target
