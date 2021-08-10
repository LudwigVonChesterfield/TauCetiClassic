/datum/component/spawn_area
	// Receives: (turf/spawn_turf) Should return: list/atom/movable of spawned instances.
	var/datum/callback/spawn_callback
	// Receives: (atom/movable/instance) to despawn.
	var/datum/callback/despawn_callback

	// Receives: (turn/spawn_turf) Should return whether instances can spawn on this turn.
	var/datum/callback/check_spawn_callback

	var/list/mob/awaiting_spawn

	var/list/atom/movable/awaiting_despawn

	// Border range at which to spawn stuff.
	var/spawn_range
	// Minimal distance between two spawned instances.
	var/min_spawn_distance

	// Time cooldown of spawns.
	var/spawn_frequency
	// Time cooldown of despawns.
	var/despawn_frequency

/datum/component/spawn_area/Initialize(spawn_callback, check_spawn_callback, despawn_callback, spawn_range, min_spawn_distance, spawn_frequency, despawn_frequency)
	if(!istype(parent, /area))
		return COMPONENT_INCOMPATIBLE

	src.spawn_callback = spawn_callback
	src.check_spawn_callback = check_spawn_callback
	src.despawn_callback = despawn_callback

	src.spawn_frequency = spawn_frequency
	src.despawn_frequency = despawn_frequency

	src.spawn_range = spawn_range
	src.min_spawn_distance = min_spawn_distance

	RegisterSignal(parent, list(COMSIG_AREA_ENTERED), .proc/on_entry)

/datum/component/spawn_area/Destroy()
	UnregisterSignal(parent, list(COMSIG_AREA_ENTERED, COMSIG_AREA_EXITED))

	for(var/m in awaiting_spawn)
		deltimer(awaiting_spawn[m])

	awaiting_spawn = null

	for(var/am in awaiting_despawn)
		deltimer(awaiting_despawn[am])

	awaiting_despawn = null

	return ..()

/datum/component/spawn_area/proc/on_entry(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	if(!istype(entering, /mob/living))
		return

	var/mob/living/L = entering
	if(!L.client)
		return

	RegisterSignal(L, list(COMSIG_ATOM_EXITED), proc/on_exit)

	if(!awaiting_spawn)
		awaiting_spawn = list()

	awaiting_spawn[L] = addtimer(
		CALLBACK(src, .proc/TrySpawn, L),
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)

/datum/component/spawn_area/proc/on_exit(datum/source, atom/movable/exiting, atom/newLoc)
	SIGNAL_HANDLER

	deltimer(awaiting_spawn[exiting])

	awaiting_spawn -= exiting

	if(!awaiting_spawn.len)
		awaiting_spawn = null

/datum/component/spawn_area/proc/TryDespawn(atom/movable/instance)
	var/despawning = TRUE

	for(var/adventurer in awaiting_spawn)
		if(get_dist(instance, adventurer) < spawn_range)
			despawning = FALSE
			break

	if(despawning)
		Despawn(instance)
		return

	awaiting_despawn[instance] = addtimer(
		CALLBACK(src, .proc/TryDespawn, instance),
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)

/datum/component/spawn_area/proc/Despawn(atom/movable/instance)
	despawn_callback.Invoke(instance)

	awaiting_despawn -= instance

	if(!awaiting_despawn.len)
		awaiting_despawn = null

/datum/component/spawn_area/proc/CheckSpawn(turf/T)
	return check_spawn_callback.Invoke(T)

/datum/component/spawn_area/proc/TrySpawn(mob/living/L)
	var/list/pos_turfs = list()
	for(var/t in BORDER_TURFS(spawn_range, L))
		if(!CheckSpawn(t))
			continue

		var/valid = TRUE

		for(var/am in awaiting_despawn)
			if(get_dist(am, t) < min_spawn_distance)
				valid = FALSE
				break

		if(!valid)
			continue

	if(!pos_turfs.len)
		return

	Spawn(pick(pos_turfs))

/datum/component/spawn_area/proc/Spawn(turf/T)
	var/list/atom/movable/instances = spawn_callback.Invoke(T)

	if(!awaiting_despawn)
		awaiting_despawn = list()

	for(var/inst in instances)
		awaiting_despawn[inst] = addtimer(
			CALLBACK(src, .proc/TryDespawn, inst),
			TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
		)
