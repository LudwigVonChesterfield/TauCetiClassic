/obj/effect/effect/area_marker
	alpha = 0
	//animate_movement = NO_STEPS



/datum/area_effect
	var/atom/target

	var/image/overlay

	var/datum/callback/get_area

	var/datum/callback/on_track_turf
	var/datum/callback/on_untrack_turf

	var/datum/callback/can_apply_overlay

	/// Turfs that are tracked for the purpose of this effect.
	var/list/tracking
	/// Markers used to apply/unapply effects.
	var/list/markers

/datum/area_effect/New(
	atom/target,
	get_area,
	on_track_turf,
	on_untrack_turf,
	can_apply_overlay,
	overlay
)
	src.target = target

	src.overlay = overlay

	src.get_area = get_area

	src.on_track_turf = on_track_turf
	src.on_untrack_turf = on_untrack_turf

	src.can_apply_overlay = can_apply_overlay

	apply_to(target)

	create_markers()

	update_effects()

/datum/area_effect/Destroy()
	remove_from(target)
	destroy_markers()

	for(var/T in tracking)
		untrack_turf(T)

	return ..()

/datum/area_effect/proc/update_effects()
	var/list/area_turfs = get_area_turfs()

	for(var/obj/effect/effect/area_marker/ZM in markers)
		if(ZM.loc)
			untrack_turf(ZM.loc)

	for(var/i in 1 to area_turfs.len)
		var/turf/T = area_turfs[i]
		var/obj/effect/effect/area_marker/ZM = markers[i]

		if(can_apply_overlay && !can_apply_overlay.Invoke(T))
			ZM.loc = null
			continue

		ZM.forceMove(T)
		track_turf(T)

/datum/area_effect/proc/create_markers()
	markers = list()

	var/list/area_turfs = get_area_turfs()

	for(var/T in area_turfs)
		var/obj/effect/effect/area_marker/ZM = new /obj/effect/effect/area_marker(T)
		markers += ZM
		RegisterSignal(ZM, list(COMSIG_PARENT_QDELETED), .proc/on_marker_deleted)

	if(!ismob(target))
		return

	for(var/obj/effect/effect/area_marker/ZM in markers)
		var/image/I = image(overlay.icon, overlay.icon_state)
		I.override = TRUE
		I.loc = ZM
		I.appearance = overlay
		I.appearance_flags |= RESET_ALPHA

		ZM.add_alt_appearance(
			/datum/atom_hud/alternate_appearance/basic/one_person,
			"marker_overlay",
			I,
			target
		)
		//var/blahblah/OP = ZM.add_alt_appearance
		//OP.theImage.appearance_flags |= RESET_ALPHA
		//OP.theImage.animate_movement = NO_STEPS

/datum/area_effect/proc/destroy_markers()
	for(var/obj/effect/effect/area_marker/ZM in markers)
		// for some reason they do not correctly get removed on Destroy, if you don't do it explicitly. ~Luduk
		ZM.remove_alt_appearance("marker_overlay")
		UnregisterSignal(ZM, list(COMSIG_PARENT_QDELETED))

	QDEL_LIST(markers)
	markers = null

/datum/area_effect/proc/on_marker_deleted(datum/source)
	destroy_markers()
	create_markers()

/datum/area_effect/proc/get_area_turfs()
	if(get_area)
		return get_area.Invoke()
	return null

/datum/area_effect/proc/apply_to(atom/A)
	RegisterSignal(A, list(COMSIG_ATOM_SET_DIR, COMSIG_MOVABLE_MOVED), .proc/update_effects)

/datum/area_effect/proc/remove_from(atom/A)
	UnregisterSignal(A, list(COMSIG_ATOM_SET_DIR, COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETED))

/datum/area_effect/proc/track_turf(turf/T)
	LAZYADD(tracking, T)

	if(on_track_turf)
		on_track_turf.Invoke(T)

/datum/area_effect/proc/untrack_turf(turf/T)
	if(on_untrack_turf)
		on_untrack_turf.Invoke(T)

	LAZYREMOVE(tracking, T)




/datum/component/area_effect
	/// List of atoms this area effect is applied to.
	var/list/applied_to

	var/image/overlay

	var/datum/callback/get_area

	var/datum/callback/on_track_turf
	var/datum/callback/on_untrack_turf

	var/datum/callback/can_apply_overlay

/datum/component/area_effect/Initialize(
	get_area,
	on_track_turf,
	on_untrack_turf,
	can_apply_overlay,
	overlay
)
	src.overlay = overlay

	src.get_area = get_area

	src.on_track_turf = on_track_turf
	src.on_untrack_turf = on_untrack_turf

	src.can_apply_overlay = can_apply_overlay

/datum/component/area_effect/Destroy()
	for(var/A in applied_to)
		remove_from(A)

	return ..()

/datum/component/area_effect/proc/apply_to(atom/A)
	var/datum/area_effect/E = new /datum/area_effect(
		A,
		get_area,
		on_track_turf,
		on_untrack_turf,
		can_apply_overlay,
		overlay
	)
	LAZYSET(applied_to, A, E)

	RegisterSignal(A, list(COMSIG_PARENT_QDELETED), .proc/remove_from)

/datum/component/area_effect/proc/remove_from(atom/A)
	UnregisterSignal(A, list(COMSIG_PARENT_QDELETED))

	qdel(applied_to[A])
	applied_to[A] = null
	LAZYREMOVE(applied_to, A)
