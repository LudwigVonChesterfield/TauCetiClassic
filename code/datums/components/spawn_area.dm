var/global/list/datum/area_group/observer_groups



/datum/area_group
	var/id
	var/list/mob/observers

/datum/area_group/New(id)
	src.id = id

/datum/area_group/Destroy()
	for(var/am in observers)
		deltimer(observers[am])

	observers = null

	LAZYREMOVE(global.observer_groups, id)

	return ..()

/datum/area_group/proc/refresh_observer(mob/living/L, delay)
	var/spawn_timer = addtimer(
		CALLBACK(
			src,
			.proc/TrySpawn,
			L
		),
		delay,
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)
	to_chat(world, "ADDED A CALLBACK FOR [L]")
	LAZYSET(observers, L, spawn_timer)

/datum/area_group/proc/add_observer(mob/living/L, delay)
	refresh_observer(L, delay)

	RegisterSignal(L, list(COMSIG_PARENT_QDELETING), .proc/on_observer_qdel)

/datum/area_group/proc/remove_observer(mob/living/L)
	deltimer(observers[L])
	LAZYREMOVE(observers, L)
	UnregisterSignal(L, list(COMSIG_PARENT_QDELETING))

	to_chat(world, "REMOVING A CALLBACK FOR [L]")

	if(!observers)
		qdel(src)

/datum/area_group/proc/on_observer_qdel(datum/source)
	SIGNAL_HANDLER

	remove_observer(source)

/datum/area_group/proc/TrySpawn(mob/living/L)
	var/area/A = get_area(L)
	if(!A)
		remove_observer(L)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		remove_observer(L)
		return

	SA.TrySpawn(L)
	refresh_observer(L, SA.spawn_frequency)



/datum/component/spawn_area
	var/datum/callback/spawn_callback
	var/datum/callback/despawn_callback
	var/datum/callback/check_spawn_callback

	var/list/atom/movable/despawn_timers

	var/group

	var/spawn_range
	var/instance_distance

	var/spawn_frequency
	var/despawn_frequency

/datum/component/spawn_area/Initialize(
	group,
	datum/callback/spawn_callback,
	datum/callback/despawn_callback,
	datum/callback/check_spawn_callback,
	spawn_range,
	instance_distance,
	spawn_frequency,
	despawn_frequency,
)
	if(!istype(parent, /area))
		return COMPONENT_INCOMPATIBLE

	src.group = group

	src.spawn_callback = spawn_callback
	src.despawn_callback = despawn_callback
	src.check_spawn_callback = check_spawn_callback

	src.spawn_range = spawn_range
	src.instance_distance = instance_distance

	src.spawn_frequency = spawn_frequency
	src.despawn_frequency = despawn_frequency

	RegisterSignal(parent, list(COMSIG_AREA_ENTERED), .proc/on_entry)

/datum/component/spawn_area/Destroy()
	UnregisterSignal(parent, list(COMSIG_AREA_ENTERED))

	for(var/timer in despawn_timers)

	despawn_timers = null

	return ..()

/datum/component/spawn_area/proc/on_entry(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	if(!isliving(entering))
		return

	var/mob/living/L = entering
	if(!L.client)
		return

	register_observer(entering)

/datum/component/spawn_area/proc/on_exit(datum/source, atom/movable/exiting, atom/newLoc)
	SIGNAL_HANDLER

	UnregisterSignal(exiting, list(COMSIG_ATOM_EXITED))

	var/area/A = get_area(newLoc)
	if(!A)
		REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, SPAWN_AREA_TRAIT)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, SPAWN_AREA_TRAIT)
		return

/datum/component/spawn_area/proc/on_instance_exit(datum/source, atom/movable/exiting, atom/newLoc)
	SIGNAL_HANDLER

	var/area/A = get_area(newLoc)
	if(!A)
		on_instance_qdel(exiting)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		on_instance_qdel(exiting)
		return

	transfer_instance(SA, exiting)

/datum/component/spawn_area/proc/on_instance_qdel(datum/source)
	SIGNAL_HANDLER

	deltimer(despawn_timers[source])

	LAZYREMOVE(despawn_timers, source)

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_EXITED))

/datum/component/spawn_area/proc/register_observer(mob/living/L)
	// No need to group areas on different Z-levels, since MultiZ travel is not present. CURRENTLY ~Luduk
	var/g = "[group]_[L.z]"

	var/datum/area_group/AG = LAZYACCESS(global.observer_groups, g)

	if(!AG)
		AG = new /datum/area_group(g)
		LAZYSET(global.observer_groups, g, AG)

	AG.add_observer(L, spawn_frequency)

	RegisterSignal(L, list(COMSIG_ATOM_EXITED), .proc/on_exit)

	L.become_area_sensitive(SPAWN_AREA_TRAIT)

/datum/component/spawn_area/proc/unregister_observer(mob/living/L)
	// No need to group areas on different Z-levels, since MultiZ travel is not present. CURRENTLY ~Luduk
	var/g = "[group]_[L.z]"

	var/datum/area_group/AG = observer_groups[g]
	AG.remove_observer(L)

/datum/component/spawn_area/proc/refresh_instance(atom/movable/instance)
	despawn_timers[instance] = addtimer(
		CALLBACK(src, .proc/TryDespawn, instance),
		despawn_frequency,
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)

/datum/component/spawn_area/proc/register_instance(atom/movable/instance)
	RegisterSignal(instance, list(COMSIG_PARENT_QDELETING), .proc/on_instance_qdel)
	RegisterSignal(instance, list(COMSIG_ATOM_EXITED), .proc/on_instance_exit)

/datum/component/spawn_area/proc/transfer_instance(datum/component/spawn_area/new_spawn_area, atom/movable/instance)
	new_spawn_area.register_instance(instance)
	LAZYSET(new_spawn_area.despawn_timers, instance, despawn_timers[instance])
	LAZYREMOVE(despawn_timers, instance)
	UnregisterSignal(instance, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_EXITED))

/datum/component/spawn_area/proc/TrySpawn(mob/living/L)
	var/list/pos_turfs = list()
	for(var/t in BORDER_TURFS(spawn_range, L))
		if(!CheckSpawn(t))
			continue

		var/valid = TRUE

		for(var/inst in despawn_timers)
			if(get_dist(inst, t) < instance_distance)
				valid = FALSE
				break

		if(!valid)
			continue

		for(var/m in get_observers(L))
			if(get_dist(m, t) < spawn_range)
				valid = FALSE
				break

		if(!valid)
			continue

		pos_turfs += t

	to_chat(world, "IN TRYSPAWN")

	if(!pos_turfs.len)
		to_chat(world, "NO SPAWN TURFS FOUND")
		return

	INVOKE_ASYNC(src, .proc/Spawn, pick(pos_turfs))

/datum/component/spawn_area/proc/TryDespawn(atom/movable/instance)
	var/despawning = TRUE

	for(var/observer in get_observers(instance))
		if(get_dist(instance, observer) < spawn_range)
			despawning = FALSE
			break

	if(despawning)
		UnregisterSignal(instance, list(COMSIG_PARENT_QDELETING, COMSIG_ATOM_EXITED))
		INVOKE_ASYNC(src, .proc/Despawn, instance)
		return

	refresh_instance(instance)
	register_instance(instance)

/datum/component/spawn_area/proc/get_observers(atom/movable/AM)
	var/g = "[group]_[AM.z]"
	var/datum/area_group/AG = global.observer_groups[g]
	return AG.observers

/datum/component/spawn_area/proc/Spawn(turf/T)
	to_chat(world, "SPAWNING AT [T.x] [T.y]")
	var/list/atom/movable/instances = spawn_callback.Invoke(T)

	for(var/instance in instances)
		refresh_instance(instance)
		register_instance(instance)

/datum/component/spawn_area/proc/Despawn(atom/movable/instance)
	to_chat(world, "DESPAWNING [instance] [instance.x] [instance.y]")
	return despawn_callback.Invoke(instance)

/datum/component/spawn_area/proc/CheckSpawn(turf/T)
	return check_spawn_callback.Invoke(T)
