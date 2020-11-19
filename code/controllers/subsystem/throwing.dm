#define MAX_THROWING_DIST 512 // 2 z-levels on default width
#define MAX_TICKS_TO_MAKE_UP 3 //how many missed ticks will we attempt to make up for this run.

SUBSYSTEM_DEF(throwing)
	name = "Throwing"

	priority = SS_PRIORITY_THROWING
	wait     = SS_WAIT_THROWING

	flags = SS_NO_INIT | SS_KEEP_TIMING | SS_TICKER

	var/list/currentrun
	var/list/processing

/datum/controller/subsystem/throwing/PreInit()
	processing = list()


/datum/controller/subsystem/throwing/stat_entry()
	..("P:[processing.len]")


/datum/controller/subsystem/throwing/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(length(currentrun))
		var/atom/movable/AM = currentrun[currentrun.len]
		var/datum/thrownthing/TT = currentrun[AM]
		currentrun.len--
		if (!AM || !TT)
			processing -= AM
			if (MC_TICK_CHECK)
				return
			continue

		TT.tick()

		if (MC_TICK_CHECK)
			return

	currentrun = null

/datum/thrownthing
	var/atom/movable/thrownthing
	var/atom/target
	var/turf/target_turf
	var/init_dir
	var/maxrange
	var/speed
	var/mob/thrower
	var/diagonals_first
	var/dist_travelled = 0
	var/start_time
	var/dist_x
	var/dist_y
	var/dx
	var/dy
	var/pure_diagonal
	var/diagonal_error
	var/datum/callback/callback
	var/datum/callback/early_callback // used when you want to call something before throw_impact().
	var/throw_intent = INTENT_HARM

/datum/thrownthing/proc/on_can_pass(datum/source, atom/obstacle, atom/target, height, airgroup)
	if(SEND_SIGNAL(source, COMSIG_MOVABLE_THROW_BEINTERCEPTED, obstacle) & COMPONENT_THROW_INTERCEPT)
		return COMPONENT_CANTPASS
	if(SEND_SIGNAL(obstacle, COMSIG_ATOM_THROW_INTERCEPT, source) & COMPONENT_THROW_INTERCEPT)
		return COMPONENT_CANTPASS

	if(throw_intent == INTENT_HELP)
		return COMPONENT_CANPASS

/datum/thrownthing/proc/tick()
	var/atom/movable/AM = thrownthing
	if (!isturf(AM.loc) || !AM.throwing)
		finalize()
		return

	if (dist_travelled && hit_check()) //to catch sneaky things moving on our tile while we slept
		finalize()
		return

	var/atom/step

	//calculate how many tiles to move, making up for any missed ticks.
	var/tilestomove = CEIL(min(((((world.time + world.tick_lag) - start_time) * speed) - (dist_travelled ? dist_travelled : -1)), speed * MAX_TICKS_TO_MAKE_UP) * (world.tick_lag * SSthrowing.wait))
	while (tilestomove-- > 0)
		if ((dist_travelled >= maxrange || AM.loc == target_turf) && has_gravity(AM, AM.loc))
			finalize()
			return

		if (dist_travelled <= max(dist_x, dist_y)) //if we haven't reached the target yet we home in on it, otherwise we use the initial direction
			step = get_step(AM, get_dir(AM, target_turf))
		else
			step = get_step(AM, init_dir)

		if (!pure_diagonal && !diagonals_first) // not a purely diagonal trajectory and we don't want all diagonal moves to be done first
			if (diagonal_error >= 0 && max(dist_x,dist_y) - dist_travelled != 1) //we do a step forward unless we're right before the target
				step = get_step(AM, dx)
			diagonal_error += (diagonal_error < 0) ? dist_x/2 : -dist_y

		if (!step) // going off the edge of the map makes get_step return null, don't let things go off the edge
			finalize()
			return

		AM.Move(step, get_dir(AM, step))

		if (!AM.throwing) // we hit something during our move
			finalize(hit = TRUE)
			return

		dist_travelled++

		if (dist_travelled > MAX_THROWING_DIST)
			finalize()
			return

/datum/thrownthing/proc/finalize(hit = FALSE, atom/movable/AM)
	set waitfor = 0
	SSthrowing.processing -= thrownthing

	//done throwing, either because it hit something or it finished moving
	if (!QDELETED(thrownthing) && thrownthing.throwing)
		UnregisterSignal(thrownthing, list(COMSIG_MOVABLE_CANPASS))
		thrownthing.throwing = FALSE

		if(early_callback)
			early_callback.Invoke()

		if(AM)
			thrownthing.throw_impact(AM, src)
		else
			if (!hit)
				for (var/thing in get_turf(thrownthing)) //looking for our target on the turf we land on.
					var/atom/A = thing
					if (A == target)
						hit = TRUE
						thrownthing.throw_impact(A, src)
						break
				if (!hit)
					thrownthing.throw_impact(get_turf(thrownthing), src)  // we haven't hit something yet and we still must, let's hit the ground.
					thrownthing.newtonian_move(init_dir)
			else
				thrownthing.newtonian_move(init_dir)
		thrownthing.fly_speed = 0

	if (callback)
		callback.Invoke()

/datum/thrownthing/proc/hit_check()
	for (var/thing in get_turf(thrownthing))
		var/atom/movable/AM = thing
		if (AM == thrownthing)
			continue

		if (isliving(AM))
			var/mob/living/L = AM
			if (L.lying)
				continue

		if(!AM.density || AM.throwpass)
			return FALSE

		if(SEND_SIGNAL(thrownthing, COMSIG_MOVABLE_THROW_BEINTERCEPTED, AM) & COMPONENT_THROW_INTERCEPT)
			return TRUE
		if(SEND_SIGNAL(AM, COMSIG_ATOM_THROW_INTERCEPT, thrownthing) & COMPONENT_THROW_INTERCEPT)
			return TRUE

		if(throw_intent == INTENT_HELP)
			continue

		finalize(null, AM)
		return TRUE
	return TRUE
