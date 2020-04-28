/proc/pixel_offset_2_dir(pixel_x, pixel_y, pixel_x_new, pixel_y_new)
	var/x_sign = sign(pixel_x - pixel_x_new)
	var/y_sign = sign(pixel_y - pixel_y_new)

	. = 0
	if(x_sign > 0)
		. |= EAST
	else if(x_sign < 0)
		. |= WEST

	if(y_sign > 0)
		. |= NORTH
	else if(y_sign < 0)
		. |= SOUTH

// This proc is needed to update layers, offsets and etc when a buckled mob is being carried with us.
// TO-DO: Replace with getters setters for: layer, pixel_x, pixel_y
/atom/movable/proc/update_buckle_mob(mob/living/L)
	return

/datum/carry_positions
	// Assoc list of form: dir = list(list(px,py,addlayer), list(px,py,layer), ...)
	var/pos_count
	// If set to true will never rotate dirs.
	var/one_dir = FALSE
	var/list/positions_by_dir

/datum/carry_positions/coffin_four_man
	pos_count = 4
	one_dir = TRUE
	// NORTH: 1 2
	//        4 3
	// SOUTH: 3 4
	//        2 1
	// WEST:  2 3
	//        1 4
	// EAST:  4 1
	//        3 2

/datum/carry_positions/coffin_four_man/New()
	positions_by_dir = list()

	/*
	commented here in case coffins become multidirectional.

	positions_by_dir["[NORTH]"] = list(
		list(-10, 14, 0.0),
		list(10, 14, 0.0),
		list(-10, -10, 0.1),
		list(10, -10, 0.1)
	)
	positions_by_dir["[SOUTH]"] = list(
		list(10, -10, 0.0),
		list(-10, -10, 0.0),
		list(10, 14, 0.1),
		list(-10, 140, 0.1)
	)
	positions_by_dir["[WEST]"] = list(
		list(-14, -5, 0.0),
		list(-14, 9, 0.0),
		list(14, -5, 0.1),
		list(14, 9, 0.1)
	)
	positions_by_dir["[EAST]"] = list(
		list(14, 9, 0.0),
		list(14, -5, 0.0),
		list(-14, 9, 0.1),
		list(-14, -5, 0.1)
	)
	*/
	for(var/dir_ in cardinal)
		// Carefully crafted precision MAGIC NUMBERS to aid in B E A U T Y.
		positions_by_dir["[dir_]"] = list(
		list("px"=13, "py"=-6, "layer"=FLY_LAYER + 0.1),
		list("px"=-12, "py"=-6, "layer"=FLY_LAYER + 0.1),
		list("px"=-14, "py"=6, "layer"=MOB_LAYER),
		list("px"=15, "py"=6, "layer"=MOB_LAYER),
	)

// A component you put on things you want to be bounded to other things.
// Warning! Can only be bounded to one thing at once.
/datum/component/multi_carry
	// This var is used to determine whether carry_obj is currently carried.
	var/carried = FALSE
	// The object that is multi-carried.
	var/atom/movable/carry_obj
	// List of being that carry carry_obj.
	var/list/carriers
	// Assoc list of carrier_ref = list("px"=..., "py"=..., "pz"=..., "layer"=...)
	// Contains data about carry_obj, carriers, carry_obj.buckled
	var/list/carrier_default_pos

	// Whether this entire "structure" is moving due to carrier.
	var/moving = FALSE
	// Block any movement due to animations or something.
	var/can_move = FALSE
	// This var is used to prevent unnecessary position updates.
	var/prev_dir = NORTH
	// When the next move can occur.
	var/next_move = 0
	// So the carry_obj won't waddle 1 * N(carriers am)
	var/next_waddle = 0

	// The pixel_z carry_obj will get, when it starts being carried.
	var/carry_pixel_z = 0
	// The layer carry_obj will get, when it starts being carried. Commented out due to lack of need.
	// var/carry_layer = FLY_LAYER
	// The positions in which carriers should stand, when carrying carry_obj.
	var/datum/carry_positions/positions

/datum/component/multi_carry/Initialize(_carry_pixel_z, positions_type)
	carry_obj = parent
	carry_pixel_z = _carry_pixel_z
	positions = new positions_type

	RegisterSignal(carry_obj, list(COMSIG_ATOM_START_PULL), .proc/carrier_join)
	RegisterSignal(carry_obj, list(COMSIG_ATOM_STOP_PULL), .proc/carrier_leave)

/datum/component/multi_carry/_RemoveFromParent()
	if(carried)
		stop_carry()
	carry_obj = null

// This proc is used to register all required signals on carrier.
/datum/component/multi_carry/proc/register_carrier(mob/carrier)
	RegisterSignal(carrier, list(COMSIG_LIVING_MOVE_PULLED), .proc/on_pull)
	RegisterSignal(carrier, list(COMSIG_CLIENTMOB_MOVE), .proc/carrier_move)
	RegisterSignal(carrier, list(COMSIG_CLIENTMOB_POSTMOVE), .proc/carrier_postmove)
	RegisterSignal(carrier, list(COMSIG_MOVABLE_MOVED), .proc/check_proximity)
	RegisterSignal(carrier, list(COMSIG_ATOM_CANPASS), .proc/check_canpass)
	RegisterSignal(carrier, list(COMSIG_MOVABLE_WADDLE), .proc/carrier_waddle)
	RegisterSignal(carrier, list(COMSIG_LIVING_CLICK_CTRL), .proc/on_ctrl_click)
	RegisterSignal(carrier, list(COMSIG_LIVING_CLICK_CTRL_SHIFT), .proc/on_ctrl_shift_click)

// This proc is used to unregister all signals from carrier.
/datum/component/multi_carry/proc/unregister_carrier(mob/carrier)
	UnregisterSignal(carrier, list(
		COMSIG_LIVING_MOVE_PULLED,
		COMSIG_CLIENTMOB_MOVE,
		COMSIG_CLIENTMOB_POSTMOVE,
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_CANPASS,
		COMSIG_MOVABLE_WADDLE,
		COMSIG_LIVING_CLICK_CTRL,
		COMSIG_LIVING_CLICK_CTRL_SHIFT,
	))

/datum/component/multi_carry/proc/on_pull(datum/source, atom/movable/target)
	if(carried)
		return COMPONENT_PREVENT_MOVE_PULLED
	return NONE

// This proc is used to change the positions of carriers when carry_obj is rotated.
/datum/component/multi_carry/proc/rotate_dir(dir_)
	if(!can_move)
		return
	can_move = FALSE

	var/i = 1
	for(var/mob/carrier in carriers)
		var/list/pos = positions.positions_by_dir["[carry_obj.dir]"][i]
		i++

		carrier.face_pixeldiff(carrier.pixel_x, carrier.pixel_y, pos["px"], pos["py"])

		animate(carrier, pixel_x=pos["px"], pixel_y=pos["py"], layer=pos["layer"], time=3)
	sleep(3)
	can_move = TRUE

// This proc is used to swap positions of two carriers.
/datum/component/multi_carry/proc/swap_positions(mob/carrier1, mob/carrier2)
	if(!can_move)
		return
	can_move = FALSE
	var/pos1 = carriers.Find(carrier1)
	var/pos2 = carriers.Find(carrier2)

	carriers[pos1] = carrier2
	carriers[pos2] = carrier1
	can_move = TRUE
	INVOKE_ASYNC(src, .proc/rotate_dir, prev_dir)

// This proc is used to swap positions of all carriers by a full rotation.
/datum/component/multi_carry/proc/rotate_positions()
	if(!can_move)
		return
	can_move = FALSE
	var/list/new_carriers = list()
	// "multi_carry" implies that there are at least 2 carriers.
	for(var/i in 2 to carriers.len)
		new_carriers += carriers[i]
	new_carriers += carriers[1]
	carriers = new_carriers
	can_move = TRUE
	INVOKE_ASYNC(src, .proc/rotate_dir, prev_dir)

/datum/component/multi_carry/proc/can_carry()
	var/lying_am = 0

	for(var/mob/walker in carriers)
		if(!walker.canmove)
			return FALSE
		if(!isturf(walker.loc))
			return FALSE
		if(!in_range(walker, carry_obj))
			return FALSE
		if(walker.lying)
			lying_am++

	if(lying_am > 0 && lying_am != carriers.len)
		return FALSE
	return TRUE

/datum/component/multi_carry/proc/carrier_join(datum/source, mob/carrier)
	if(carried)
		return

	LAZYADD(carriers, carrier)

	if(carriers.len == positions.pos_count)
		if(can_carry())
			start_carry()
		else
			for(var/mob/walker in carriers)
				walker.stop_pulling(carry_obj)

/datum/component/multi_carry/proc/start_carry()
	var/i = 1
	prev_dir = carry_obj.dir
	for(var/mob/carrier in carriers)
		var/list/pos = positions.positions_by_dir["[carry_obj.dir]"][i]
		i++

		LAZYSET(carrier_default_pos, carrier, list(
			"px"=carrier.pixel_x,
			"py"=carrier.pixel_y,
			"layer"=carrier.layer
		))
		carrier.pixel_x = pos["px"]
		carrier.pixel_y = pos["py"]
		carrier.layer = pos["layer"]
		carrier.loc = carry_obj.loc

		register_carrier(carrier)

	LAZYSET(carrier_default_pos, carry_obj, list(
		"pz"=carry_obj.pixel_z,
		"layer"=carry_obj.layer
	))
	carry_obj.pixel_z = carry_obj.pixel_z + carry_pixel_z
	carry_obj.layer = FLY_LAYER
	if(carry_obj.buckled_mob)
		on_buckle(carry_obj.buckled_mob)
		carry_obj.update_buckle_mob(carry_obj.buckled_mob)

	RegisterSignal(carry_obj, list(COMSIG_ATOM_CANPASS), .proc/check_canpass)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_MOVED), .proc/check_carriers)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_BUCKLE), .proc/on_buckle)
	RegisterSignal(carry_obj, list(COMSIG_MOVABLE_UNBUCKLE), .proc/on_unbuckle)

	carried = TRUE
	can_move = TRUE

/datum/component/multi_carry/proc/carrier_leave(datum/source, mob/carrier)
	if(carried)
		stop_carry()
		return

	LAZYREMOVE(carriers, carrier)

/datum/component/multi_carry/proc/stop_carry()
	if(!carried)
		return
	carried = FALSE
	can_move = FALSE

	for(var/mob/carrier in carriers)
		var/list/pos = carrier_default_pos[carrier]
		carrier.pixel_x = pos["px"]
		carrier.pixel_y = pos["py"]
		carrier.layer = pos["layer"]
		LAZYREMOVE(carrier_default_pos, carrier)

		step(carrier, pick(alldirs))

		unregister_carrier(carrier)
		carrier.stop_pulling()

	UnregisterSignal(carry_obj, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_ATOM_CANPASS,
		COMSIG_MOVABLE_BUCKLE,
		COMSIG_MOVABLE_UNBUCKLE
	))

	var/list/pos_obj = carrier_default_pos[carry_obj]
	carry_obj.pixel_z = pos_obj["pz"]
	carry_obj.layer = pos_obj["layer"]
	LAZYREMOVE(carrier_default_pos, carry_obj)
	if(carry_obj.buckled_mob)
		on_unbuckle(carry_obj.buckled_mob)

	carriers = null

/datum/component/multi_carry/proc/follow_carrier(atom/movable/walker, atom/NewLoc, direction)
	INVOKE_ASYNC(GLOBAL_PROC, .proc/_step, walker, direction)

/datum/component/multi_carry/proc/carrier_move(datum/source, atom/NewLoc, direction)
	if(!can_move)
		return COMPONENT_CLIENTMOB_BLOCK_MOVE
	if(next_move > world.time)
		return COMPONENT_CLIENTMOB_BLOCK_MOVE

	var/mob/carrier = source

	moving = TRUE
	// carrier_move is called via CLIENTMOB_MOVE, which very much implies a client.
	next_move = carrier.client.move_delay

	var/lying_am = 0
	for(var/mob/walker in carriers.len)
		if(!walker.canmove) // Buckled or something stupid like that.
			stop_carry()
			return NONE
		if(walker.lying)
			lying_am++

	// If any one is lying, but not all are lying, then we're unstable, and fall.
	if(lying_am > 0 && lying_am != carriers.len)
		stop_carry()
		return NONE

	follow_carrier(carry_obj, NewLoc, direction)
	for(var/mob/walker in carriers)
		if(walker == carrier)
			continue
		follow_carrier(walker, NewLoc, direction)
	return NONE

/datum/component/multi_carry/proc/carrier_postmove(datum/source, atom/NewLoc, direction)
	moving = FALSE

/datum/component/multi_carry/proc/carrier_waddle(datum/source, waddle_strength, pz_raise)
	if(next_waddle > world.time)
		return
	next_waddle = world.time + 1

	can_move = FALSE
	if(carry_obj.can_waddle())
		carry_obj.waddle(pick(-waddle_strength, 0, waddle_strength), pz_raise)
		if(carry_obj.buckled_mob)
			carry_obj.buckled_mob.dir = pick(WEST, EAST)
	can_move = TRUE

/datum/component/multi_carry/proc/check_proximity(datum/source)
	var/mob/carrier = source
	if(!moving && carry_obj.loc != carrier.loc)
		stop_carry()
		return FALSE
	return TRUE

/datum/component/multi_carry/proc/check_carriers()
	if(carry_obj.dir != prev_dir && !positions.one_dir)
		prev_dir = carry_obj.dir
		INVOKE_ASYNC(src, .proc/rotate_dir, prev_dir)

	for(var/mob/carrier in carriers)
		if(!check_proximity(carrier))
			return

/datum/component/multi_carry/proc/check_canpass(datum/source, atom/movable/mover, atom/target, height, air_group)
	if(!moving)
		return NONE

	if(mover == carry_obj)
		return COMPONENT_CANPASS
	if(mover in carriers)
		return COMPONENT_CANPASS
	return NONE

/datum/component/multi_carry/proc/on_buckle(mob/buckled)
	LAZYSET(carrier_default_pos, buckled, list(
		"pz"=buckled.pixel_z,
		"layer"=buckled.layer
	))
	buckled.pixel_z = buckled.pixel_z + carry_pixel_z
	buckled.layer = FLY_LAYER + 0.1

/datum/component/multi_carry/proc/on_unbuckle(mob/buckled)
	var/list/pos = carrier_default_pos[buckled]
	buckled.pixel_z = pos["pz"]
	buckled.layer = pos["layer"]
	LAZYREMOVE(carrier_default_pos, buckled)

/datum/component/multi_carry/proc/on_ctrl_click(datum/source, atom/target)
	if(target == carry_obj)
		return NONE

	if(target != source && target in carriers)
		INVOKE_ASYNC(src, .proc/swap_positions, source, target)
		return COMPONENT_CANCEL_CLICK
	// So carrier doesn't get an idea that they can pull something else.
	return COMPONENT_CANCEL_CLICK

/datum/component/multi_carry/proc/on_ctrl_shift_click(datum/source, atom/target)
	if(target == carry_obj)
		carrier_waddle(source, 28, 4)
		return COMPONENT_CANCEL_CLICK

	if(target in carriers)
		INVOKE_ASYNC(src, .proc/rotate_positions)
		return COMPONENT_CANCEL_CLICK
	return NONE
