#define SHAKE_AREA_MIN 2.0
#define SHAKE_FORCE_MIN 10.0

/turf/simulated/floor/proc/shake(max_severity)
	shake_act(max_severity)
	for(var/atom/movable/AM in contents)
		AM.shake_act(max_severity)

	for(var/shake_dir in alldirs)
		var/turf/T = get_step(src, shake_dir)
		T.shake_act(max_severity - 1)

		for(var/atom/movable/AM in T.contents)
			AM.shake_act(max_severity - 1)

	for(var/mob/living/L in player_list)
		if(get_dist(L, src) <= 7)
			shake_camera(L, 1, 1)

/atom/proc/shake_act(severity)
	return

/obj/shake_act(severity)
	if(severity <= 0.0)
		return

	var/datum/destruction_measure/shake_DM = new(
		src,
		severity * SHAKE_FORCE_MIN,
		get_size(),
		HITZONE_LOWER,
		BRUTE,
		"shake")
	react_to_damage(null, null, shake_DM)

/mob/living/shake_act(severity)
	..()
	if(severity >= 1.0 && !throwing)
		if(severity >= 2.0)
			apply_effect(severity * 2.0, STUN, 0)
			apply_effect(severity * 2.0, WEAKEN, 0)
		apply_effect(severity * 4.0, STUTTER, 0)
		shake_camera(src, round(severity* 2), round(severity))

/turf/simulated/floor/on_destruction(atom/movable/demo, obj/item/I, datum/destruction_measure/DM)
	. = ..()
	if(DM.damage_type == BRUTE && (DM.destruction_type in list(DEST_PRODE, DEST_BLUNT)) && DM.force_area >= SHAKE_AREA_MIN && DM.applied_force >= SHAKE_FORCE_MIN)
		var/max_severity = DM.applied_force / SHAKE_FORCE_MIN

		shake(max_severity)
