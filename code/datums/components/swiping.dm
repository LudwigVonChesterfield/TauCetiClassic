// Please do not add this component directly, and instead use this proc.
// Since AddComponent does not support named arguments.
/proc/make_swipable(atom/A,
					interupt_on_sweep_hit_types=list(/atom), // Which items will cause a stun when hit.
					can_push=FALSE,                          // Whether you can push stuff with this weapon.
					hit_on_harm_push=FALSE,                  // Whether pushing on I_HURT will cause you to hit mobs.
					can_push_on_chair=FALSE,                 // Whether you can go WOOSH on chair-like structures when pushing.

					can_pull=FALSE,                          // Whether you can pull stuff with this weapon.
					hit_on_harm_pull=FALSE,                  // Whether pulling on I_HURT will cause you to hit mobs.

					can_sweep=FALSE,                         // Whether you can sweep at all using this weapon.
					can_spin=FALSE,                          // Whether you can spin-sweep 1 tile around you with this weapon. can_sweep is not required to be able to spin.

					datum/callback/can_sweep_call=null,       // A callback that allows to check for additional conditions before sweeping.
					datum/callback/can_spin_call=null,        // A callback that allows to check for additional conditions before spinning.

					datum/callback/on_sweep_move=null,        // A callback that replaces default_on_sweep_move.
					datum/callback/can_sweep_hit=null,        // A callback that replaces default_can_sweep_hit.
					datum/callback/on_sweep_hit=null,         // A callback that replaces default_on_sweep_hit.
					datum/callback/on_sweep_to_check=null,    // A callback that replaces default_on_sweep_to_check.
					datum/callback/on_sweep_finish=null,      // A callback that replaces default_on_sweep_to_check.
					datum/callback/on_sweep_interupt=null,    // A callback that replaces default_on_sweep_interupt.
					datum/callback/sweep_continue_check=null, // A callback that replaces default_sweep_continue_check.

					datum/callback/on_spin=null,              // A callback that completely replaces the spin logic. Is used in double energy swords.

					datum/callback/can_push_call=null,       // A callback that allows to check for additional conditions before pushing.
					datum/callback/can_pull_call=null,       // A callback that allows to check for additional conditions before pulling.

					datum/callback/on_sweep_push=null,         // A callback that replaces default_sweep_push.
					datum/callback/on_sweep_push_success=null, // A callback that replaces default_sweep_push_success.

					datum/callback/on_sweep_pull=null,         // A callback that replaces default_sweep_pull.
					datum/callback/on_sweep_pull_success=null, // A callback that replaces default_sweep_pull_success.
					)
	A.AddComponent(/datum/component/swiping, interupt_on_sweep_hit_types, can_push, hit_on_harm_push, can_push_on_chair, can_pull,
	               hit_on_harm_pull, can_sweep, can_spin, can_sweep_call, can_spin_call, on_sweep_move, can_sweep_hit, on_sweep_hit,
	               on_sweep_to_check, on_sweep_finish, on_sweep_interupt, sweep_continue_check, on_spin, can_push_call, can_pull_call,
	               on_sweep_push, on_sweep_push_success, on_sweep_pull, on_sweep_pull_success)


/obj/effect/effect/weapon_sweep
	name = "sweep"

/obj/effect/effect/weapon_sweep/atom_init(mapload, obj/item/weapon/sweep_item)
	. = ..()
	name = "sweeping [sweep_item]"
	glide_size = DELAY2GLIDESIZE(sweep_item.sweep_step)

	appearance = sweep_item.appearance


/datum/component/swiping
	var/list/interupt_on_sweep_hit_types = list(/atom)

	var/can_push = FALSE
	var/hit_on_harm_push = FALSE
	var/can_push_on_chair = FALSE

	var/can_pull = FALSE
	var/hit_on_harm_pull = FALSE

	var/can_sweep = FALSE
	var/can_spin = FALSE

	var/datum/callback/can_push_call
	var/datum/callback/can_pull_call
	var/datum/callback/can_sweep_call
	var/datum/callback/can_spin_call

	var/datum/callback/on_sweep_move
	var/datum/callback/can_sweep_hit
	var/datum/callback/on_sweep_hit
	var/datum/callback/on_sweep_to_check
	var/datum/callback/on_sweep_finish
	var/datum/callback/on_sweep_interupt

	var/datum/callback/on_spin

	var/datum/callback/sweep_continue_check

	var/datum/callback/on_sweep_push
	var/datum/callback/on_sweep_push_success

	var/datum/callback/on_sweep_pull
	var/datum/callback/on_sweep_pull_success

/datum/component/swiping/Initialize(interupt_on_sweep_hit_types=list(/atom), // Which items will cause a stun when hit.
									can_push=FALSE,                          // Whether you can push stuff with this weapon.
									hit_on_harm_push=FALSE,                  // Whether pushing on I_HURT will cause you to hit mobs.
									can_push_on_chair=FALSE,                 // Whether you can go WOOSH on chair-like structures when pushing.

									can_pull=FALSE,                          // Whether you can pull stuff with this weapon.
									hit_on_harm_pull=FALSE,                  // Whether pulling on I_HURT will cause you to hit mobs.

									can_sweep=FALSE,                         // Whether you can sweep at all using this weapon.
									can_spin=FALSE,                          // Whether you can spin-sweep 1 tile around you with this weapon. can_sweep is not required to be able to spin.

									datum/callback/can_sweep_call=null,       // A callback that allows to check for additional conditions before sweeping.
									datum/callback/can_spin_call=null,        // A callback that allows to check for additional conditions before spinning.

									datum/callback/on_sweep_move=null,        // A callback that replaces default_on_sweep_move.
									datum/callback/can_sweep_hit=null,        // A callback that replaces default_can_sweep_hit.
									datum/callback/on_sweep_hit=null,         // A callback that replaces default_on_sweep_hit.
									datum/callback/on_sweep_to_check=null,    // A callback that replaces default_on_sweep_to_check.
									datum/callback/on_sweep_finish=null,      // A callback that replaces default_on_sweep_to_check.
									datum/callback/on_sweep_interupt=null,    // A callback that replaces default_on_sweep_interupt.
									datum/callback/sweep_continue_check=null, // A callback that replaces default_sweep_continue_check.

									datum/callback/on_spin=null,              // A callback that completely replaces the spin logic. Is used in double energy swords.

									datum/callback/can_push_call=null,       // A callback that allows to check for additional conditions before pushing.
									datum/callback/can_pull_call=null,       // A callback that allows to check for additional conditions before pulling.

									datum/callback/on_sweep_push=null,         // A callback that replaces default_sweep_push.
									datum/callback/on_sweep_push_success=null, // A callback that replaces default_sweep_push_success.

									datum/callback/on_sweep_pull=null,         // A callback that replaces default_sweep_pull.
									datum/callback/on_sweep_pull_success=null, // A callback that replaces default_sweep_pull_success.
									)
	if(!istype(parent, /obj/item/weapon))
		return COMPONENT_INCOMPATIBLE

	src.interupt_on_sweep_hit_types = interupt_on_sweep_hit_types

	if(can_push)
		src.can_push = TRUE
		src.hit_on_harm_push = hit_on_harm_push
		src.can_push_on_chair = can_push_on_chair

		src.can_push_call = can_push_call
		src.on_sweep_push = on_sweep_push
		src.on_sweep_push_success = on_sweep_push_success

		RegisterSignal(parent, list(COMSIG_ITEM_CTRLCLICKWITH), .proc/sweep_push)
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK), .proc/on_push_attack)

	if(can_pull)
		src.can_pull = TRUE
		src.hit_on_harm_pull = hit_on_harm_pull

		src.can_pull_call = can_pull_call
		src.on_sweep_pull = on_sweep_pull
		src.on_sweep_pull_success = on_sweep_pull_success

		RegisterSignal(parent, list(COMSIG_ITEM_CTRLSHIFTCLICKWITH), .proc/sweep_pull)

	src.on_sweep_move = on_sweep_move
	src.can_sweep_hit = can_sweep_hit
	src.on_sweep_hit = on_sweep_hit
	src.on_sweep_to_check = on_sweep_to_check
	src.on_sweep_finish = on_sweep_finish
	src.on_sweep_interupt = on_sweep_interupt
	src.sweep_continue_check = sweep_continue_check

	if(can_sweep)
		src.can_sweep = TRUE
		src.can_sweep_call = can_sweep_call
		RegisterSignal(parent, list(COMSIG_ITEM_ALTCLICKWITH), .proc/sweep_facing)

	if(can_spin)
		src.can_spin = TRUE
		src.can_spin_call = can_spin_call
		src.on_spin = on_spin
		RegisterSignal(parent, list(COMSIG_ITEM_ATTACK_SELF), .proc/sweep_spin)
		RegisterSignal(parent, list(COMSIG_ITEM_MIDDLECLICKWITH), .proc/sweep_spin_click)

	RegisterSignal(parent, list(COMSIG_ITEM_MOUSEDROP_ONTO), .proc/sweep_mousedrop)

/datum/component/swiping/proc/move_sweep_image(turf/target, obj/effect/effect/weapon_sweep/sweep_image)
	var/obj/item/weapon/W = parent
	sleep(W.sweep_step)
	sweep_image.forceMove(target)

/*
	Procs related to pushing.
	Pushing means "swiping" in general direction of click, and if possible - moving the target away from user.
	Some items allow to go WOOSH when pushing while being on chair-like structure that can move.
	Some items allow to hit if your intent is I_HURT when pushing.
*/
/datum/component/swiping/proc/push_on_chair(obj/structure/stool/bed/chair/C, mob/user, movementdirection)
	if(C)
		C.propelled = 4
	step(C, movementdirection)
	sleep(1)
	step(C, movementdirection)
	if(C)
		C.propelled = 3
	sleep(1)
	step(C, movementdirection)
	sleep(1)
	step(C, movementdirection)
	if(C)
		C.propelled = 2
	sleep(2)
	step(C, movementdirection)
	if(C)
		C.propelled = 1
	sleep(2)
	step(C, movementdirection)
	if(C)
		C.propelled = 0
	sleep(3)
	step(C, movementdirection)
	sleep(3)
	step(C, movementdirection)
	sleep(3)
	step(C, movementdirection)

/datum/component/swiping/proc/default_on_sweep_push(atom/target, turf/T, mob/user)
	return

/datum/component/swiping/proc/default_on_sweep_push_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(hit_on_harm_push && user.a_intent != I_HELP)
		var/resolved = target.attackby(parent, user, list())
		if(!resolved && parent)
			var/obj/item/I = parent
			I.afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(parent) && !istype(target, /turf/space))
		step_away(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_away(target, get_turf(parent))

/datum/component/swiping/proc/sweep_push(datum/source, atom/target, mob/user)
	if(can_push_call)
		if(!can_push_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/s_time = W.sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/W_turf = get_turf(W)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(W_turf, get_dir(W_turf, T_target))

	if(on_sweep_push)
		on_sweep_push.Invoke(T_target, T, user)
	else
		default_on_sweep_push(T_target, T, user)

	user.do_attack_animation(T)

	if(can_push_on_chair && istype(get_turf(W), /turf/simulated) && istype(user.buckled, /obj/structure/stool/bed/chair) && !user.buckled.anchored)
		var/obj/structure/stool/bed/chair/buckled_to = user.buckled
		if(!buckled_to.flipped)
			var/direction = turn(get_dir(W_turf, T_target), 180)
			INVOKE_ASYNC(src, .proc/push_on_chair, user.buckled, user, direction)
			return COMSIG_ITEM_CANCEL_CLICKWITH

	if(T.Adjacent(target))
		if(on_sweep_push_success)
			on_sweep_push_success.Invoke(target, user)
		else
			default_on_sweep_push_success(target, user)

	return COMSIG_ITEM_CANCEL_CLICKWITH

// Pushing items have a bonus of knocking people with shields over if hit into the right place(the arm with she shield).
/datum/component/swiping/proc/on_push_attack(datum/source, mob/living/target ,mob/living/user, def_zone)
	var/obj/item/weapon/shield/S
	if(def_zone == BP_L_ARM && istype(target.l_hand, /obj/item/weapon/shield))
		S = target.l_hand
	else if(def_zone == BP_R_ARM && istype(target.r_hand, /obj/item/weapon/shield))
		S = target.r_hand

	if(S && prob(S.Get_shield_chance()))
		user.visible_message("<span class='warning'>[user] knocks [target] down with \a [src]!</span>", "<span class='warning'>You knock [target] down with \a [src]!</span>")
		if(target.buckled)
			target.buckled.user_unbuckle_mob(target)

		target.apply_effect(2, STUN, 0)
		target.apply_effect(2, WEAKEN, 0)
		target.apply_effect(4, STUTTER, 0)
		shake_camera(target, 1, 1)

/*
	Procs related to pulling
	Pulling means "swiping" in general direction of click, and if possible - moving the target towards the user.
	Some items allow to hit if your intent is I_HURT when pulling.
*/
/datum/component/swiping/proc/default_on_sweep_pull(atom/target, turf/T, mob/user)
	return

/datum/component/swiping/proc/default_on_sweep_pull_success(atom/target, mob/user)
	var/turf/T_target = get_turf(target)

	if(hit_on_harm_pull && user.a_intent != I_HELP)
		var/resolved = target.attackby(parent, user, list())
		if(!resolved && parent)
			var/obj/item/I = parent
			I.afterattack(target, user, TRUE, list()) // 1 indicates adjacency

	if(!has_gravity(parent) && !istype(target, /turf/space))
		step_to(user, T_target)
	else if(istype(target, /atom/movable))
		var/atom/movable/AM = target
		if(!AM.anchored)
			step_to(target, get_turf(parent))

/datum/component/swiping/proc/sweep_pull(datum/source, atom/target, mob/user)
	if(can_pull_call)
		if(!can_pull_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/s_time = W.sweep_step * 2
	user.SetNextMove(s_time)

	var/turf/W_turf = get_turf(W)
	var/turf/T_target = get_turf(target)
	var/turf/T = get_step(W_turf, get_dir(W_turf, T_target))

	if(on_sweep_pull)
		on_sweep_pull.Invoke(T_target, T, user)
	else
		default_on_sweep_pull(T_target, T, user)

	user.do_attack_animation(T)

	if(T.Adjacent(target))
		if(on_sweep_pull_success)
			on_sweep_pull_success.Invoke(target, user)
		else
			default_on_sweep_pull_success(target, user)

	return COMSIG_ITEM_CANCEL_CLICKWITH

/*
	Procs related to sweeping(in general)
	Sweeping is moving a *representation* of an object smoothly
	across some tiles.
	When, as user sweep, they encounter an obstacle - if they hit them, they get stunned.

	TODO: make pull and push rely on sweep too?
*/
// Whether user can continue sweeping at all.
/datum/component/swiping/proc/default_sweep_continue_check(mob/user, sweep_delay, turf/current_turf)
	if(can_spin_call)
		if(!can_spin_call.Invoke(user))
			return FALSE
	else if(can_sweep_call)
		if(!can_sweep_call.Invoke(user))
			return FALSE

	var/obj/item/weapon/W = parent
	if(user.is_busy() || !do_after(user, W.sweep_step, target = current_turf, can_move = TRUE, progress = FALSE))
		return FALSE
	return TRUE

// A proc called each new tile we're swiping across, before all the possible checks.
/datum/component/swiping/proc/default_on_sweep_move(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, mob/user)
	user.face_atom(current_turf)

// A proc that checks whether the sweep will hit target.
/datum/component/swiping/proc/default_can_sweep_hit(atom/target, mob/user)
	return target.density || istype(target, /obj/effect/effect/weapon_sweep)

// What happens when we *hit* an atom.
/datum/component/swiping/proc/default_on_sweep_hit(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/user)
	if(user.a_intent == I_HURT && is_type_in_list(target, list(/obj/machinery/disposal, /obj/structure/table, /obj/structure/rack)))
		/*
		A very weird snowflakey thing but very crucial to keeping this fun.
		If we're on I_HURT and we hit anything that should drop our item from the hands,
		we just ignore the click to it.
		*/
		return FALSE

	var/obj/item/weapon/W = parent

	var/is_stunned = is_type_in_list(target, interupt_on_sweep_hit_types)
	if(is_stunned)
		to_chat(user, "<span class='warning'>Your [W] has hit [target]! There's not enough space for broad sweeps here!</span>")

	var/resolved = target.attackby(W, user, list())
	if(!resolved && W)
		W.afterattack(target, user, TRUE, list()) // TRUE indicates adjacency

	return is_stunned

// Something we execute to all atoms on tile we're currently swiping through. e.g.: moving to next tile, if we're sweeping with a mop.
/datum/component/swiping/proc/default_on_sweep_to_check(turf/current_turf, obj/effect/effect/weapon_sweep/sweep_image, atom/target, mob/user, list/directions, i)
	return

// What happens if we swipe through the tile, but don't hit anything.
/datum/component/swiping/proc/default_on_sweep_finish(turf/current_turf, mob/user)
	return

// What happens after we hit something.
/datum/component/swiping/proc/default_on_sweep_interupt(turf/current_turf, mob/living/user)
	if(user.buckled)
		user.buckled.user_unbuckle_mob(user)
	// You hit a wall!
	user.apply_effect(3, STUN, 0)
	user.apply_effect(3, WEAKEN, 0)
	user.apply_effect(6, STUTTER, 0)
	shake_camera(user, 1, 1)
	// here be thud sound

/datum/component/swiping/proc/sweep(list/directions, mob/living/user, sweep_delay)
	if(can_sweep_call && !can_spin) // If it's a spinning thing, it has it's own check.
		if(!can_sweep_call.Invoke(user))
			return NONE

	var/obj/item/weapon/W = parent

	var/turf/start = get_step(W, directions[1])

	user.do_attack_animation(start)
	var/obj/effect/effect/weapon_sweep/sweep_image = new /obj/effect/effect/weapon_sweep(start, W)

	var/i = 0 // So we begin with one.
	for(var/dir_ in directions)
		var/turf/current_turf = get_step(W, dir_)
		i++

		INVOKE_ASYNC(src, .proc/move_sweep_image, current_turf, sweep_image)
		var/continue_sweep = FALSE
		if(sweep_continue_check)
			continue_sweep = sweep_continue_check.Invoke(user, sweep_delay, current_turf)
		else
			continue_sweep = default_sweep_continue_check(user, sweep_delay, current_turf)
		if(!continue_sweep)
			break

		if(on_sweep_move)
			on_sweep_move.Invoke(current_turf, sweep_image, user)
		else
			default_on_sweep_move(current_turf, sweep_image, user)

		var/list/to_check = list()
		to_check += current_turf.contents
		to_check += current_turf
		to_check -= sweep_image
		to_check.Remove(user)

		// Get out of the way, fellows!
		for(var/atom/A in to_check)
			var/hit = FALSE
			if(can_sweep_hit)
				hit = can_sweep_hit.Invoke(A, user)
			else
				hit = default_can_sweep_hit(A, user)

			if(hit)
				if(on_sweep_hit)
					. = on_sweep_hit.Invoke(current_turf, sweep_image, A, user)
				else
					. = default_on_sweep_hit(current_turf, sweep_image, A, user)
				break

			if(on_sweep_to_check)
				on_sweep_to_check.Invoke(current_turf, sweep_image, A, user, directions, i)
			else
				default_on_sweep_to_check(current_turf, sweep_image, A, user, directions, i)
			user.SetNextMove(sweep_delay + 1)

		if(!.)
			if(on_sweep_finish)
				on_sweep_finish.Invoke(current_turf, user)
			else
				default_on_sweep_finish(current_turf, user)
		else
			if(on_sweep_interupt)
				on_sweep_interupt.Invoke(current_turf, user)
			else
				default_on_sweep_interupt(current_turf, user)
			break

	QDEL_IN(sweep_image, sweep_delay)
	return COMSIG_ITEM_CANCEL_CLICKWITH

// Swipe through the two adjacent to target tiles.
/datum/component/swiping/proc/sweep_facing(datum/source, atom/target, mob/user)
	if(can_sweep_call)
		if(!can_sweep_call.Invoke(target, user))
			return NONE

	var/obj/item/weapon/W = parent

	var/turf/T = get_turf(target)
	var/direction = get_dir(get_turf(W), T)
	var/list/directions = list(turn(direction, 45), direction, turn(direction, -45))
	sweep(directions, user, W.sweep_step)
	return COMSIG_ITEM_CANCEL_CLICKWITH

/*
	Procs related to spinning.
	Spinning is a sweep done across all 8 tiles, that surround the user.
*/
// A spin proc, a glorified 2x speed sweep.
/datum/component/swiping/proc/sweep_spin(datum/source, mob/user)
	if(can_spin_call)
		if(!can_spin_call.Invoke(user))
			return NONE

	if(on_spin)
		return on_spin.Invoke(user)

	var/rot_dir = 1
	if(user.dir == SOUTH || user.dir == WEST) // South-west rotate anti-clockwise.
		rot_dir = -1

	var/list/directions = list(user.dir, turn(user.dir, rot_dir * 45), turn(user.dir, rot_dir * 90), turn(user.dir, rot_dir * 135), turn(user.dir, rot_dir * 180), turn(user.dir, rot_dir * 225), turn(user.dir, rot_dir * 270), turn(user.dir, rot_dir * 315), user.dir)

	var/obj/item/weapon/W = parent

	var/saved_sweep_step = W.sweep_step
	W.sweep_step *= 0.5
	sweep(directions, user, W.sweep_step)
	W.sweep_step = saved_sweep_step
	return COMPONENT_NO_INTERACT

// A little bootleg for MiddleClick.
/datum/component/swiping/proc/sweep_spin_click(datum/source, atom/target, mob/user)
	if(sweep_spin(source, user) != NONE)
		return COMSIG_ITEM_CANCEL_CLICKWITH
	return NONE

// This proc processes all different mousedrop combos that activate swiping.
// Per say, swiping diagonally across makes you spin.
// Swiping away from you - to push.
// Swiping towards you - to pull.
// All other possible swipes that have all swipe-tiles in 1 tile range result in just a sweep.
/datum/component/swiping/proc/sweep_mousedrop(datum/source, atom/over, atom/dropping, mob/user)
	if(user.next_move > world.time || user.incapacitated())
		return NONE

	var/turf/over_turf = get_turf(over)
	var/turf/dropping_turf = get_turf(dropping)

	if(get_dir(user, over_turf) == reverse_direction(get_dir(user, dropping_turf)))
		if(can_spin && sweep_spin(user) != NONE)
			return COMPONENT_NO_MOUSEDROP

	if(!istype(over_turf) || !istype(dropping_turf))
		return NONE

	var/list/turfs = getline(dropping_turf, over_turf)
	var/list/directions = list()
	for(var/turf/T in turfs)
		if(!in_range(user, T))
			if(get_dir(dropping, over) == get_dir(user, over))
				if(can_push && sweep_push(over, user) != NONE)
					return COMPONENT_NO_MOUSEDROP
			else
				if(can_pull && sweep_pull(dropping, user) != NONE)
					return COMPONENT_NO_MOUSEDROP
		directions += get_dir(user, T)

	var/obj/item/weapon/W = parent

	if(directions.len == 3 && can_sweep && sweep(directions, user, W.sweep_step) != NONE)
		return COMPONENT_NO_MOUSEDROP
	return NONE
