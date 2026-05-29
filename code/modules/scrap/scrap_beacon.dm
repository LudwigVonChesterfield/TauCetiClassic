#define SCRAPFALL_COOLDOWN_SECONDS 8
#define SCRAPFALLS_PER_DEFAULT_APC_CELL 7

// 1000 is how much charge is in a default APC cell.
#define SCRAP_BEACON_ACTIVE_POWER_USAGE ((1000 * CELLRATE) / SCRAPFALLS_PER_DEFAULT_APC_CELL)

#define SCRAP_BEACON_FALL_EVERY_POWER_USED (SCRAP_BEACON_ACTIVE_POWER_USAGE * SCRAPFALL_COOLDOWN_SECONDS)


/obj/machinery/scrap_beacon
	name = "Scrap Beacon"
	desc = "This machine generates directional gravity rays which catch trash orbiting around."
	icon = 'icons/obj/structures/scrap/scrap_beacon.dmi'
	icon_state = "beacon0"
	anchored = TRUE
	density = TRUE
	layer = MOB_LAYER + 1

	active_power_usage = SCRAP_BEACON_ACTIVE_POWER_USAGE
	idle_power_usage = 0

	var/wt_per_scrap_fall = SCRAP_BEACON_FALL_EVERY_POWER_USED
	var/wt_until_next_scrap_fall = SCRAP_BEACON_FALL_EVERY_POWER_USED

	var/min_scrap_per_fall = 1
	var/max_scrap_per_fall = 3

	var/min_scrap_fall_delay = 0
	var/max_scrap_fall_delay = 2

	var/impact_range = 2

	var/active = FALSE

	var/calibrations_required = 5
	var/max_calibrations_required = 5

	var/last_activation = 0
	var/safe_deactivation_cooldown = SCRAPFALL_COOLDOWN_SECONDS * SCRAPFALLS_PER_DEFAULT_APC_CELL

/obj/machinery/scrap_beacon/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/scrap_beacon/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)

	if(!active && !has_enough_power())
		playsound(
			src,
			'sound/machines/buzz-two.ogg',
			volume_channel=VOL_EFFECTS_MASTER,
			vol=30,
			vary=FALSE,
			// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
			// After all, in space, you can't hear scrap beacon start.
			ignore_environment=TRUE,
		)
		visible_message("<span class='warning'>[bicon(src)] emits a sad, unpowered buzz.</span>")
		return

	if(crit_fail)
		playsound(
			src,
			'sound/machines/buzz-two.ogg',
			volume_channel=VOL_EFFECTS_MASTER,
			vol=30,
			vary=FALSE,
			// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
			// After all, in space, you can't hear scrap beacon start.
			ignore_environment=TRUE,
		)
		visible_message("<span class='warning'>[bicon(src)] emits a sad, broken buzz.</span>")
		return

	if(calibrations_required > 0)
		playsound(
			src,
			'sound/machines/buzz-two.ogg',
			volume_channel=VOL_EFFECTS_MASTER,
			vol=30,
			vary=FALSE,
			// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
			// After all, in space, you can't hear scrap beacon start.
			ignore_environment=TRUE,
		)
		visible_message("<span class='warning'>[bicon(src)] emits a sad, uncalibrated buzz.</span>")
		return

	set_active(!active)

// TO-DO: need to go and click corners of the zone with a multitool?
/obj/machinery/scrap_beacon/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/device/multitool))
		try_calibrate_loop(user, W)
		return

	return ..()

/obj/machinery/scrap_beacon/proc/try_calibrate_loop(mob/living/user, obj/item/tool)
	user.visible_message("<span class='notice'>[user] starts calibrating \the [src].</span>")

	if(crit_fail)
		if(!is_skill_competent(user, list(/datum/skill/engineering=SKILL_LEVEL_PRO)))
			to_chat(user, "<span class='warning'>The [src] is too damaged to be repaired by me. I wonder if someone could help?</span>")
			return
		if(tool.use_tool(
			target=src,
			user=user,
			delay=10 SECONDS,
			volume=70,
			quality=QUALITY_PULSING,
			required_skills_override=list(
				/datum/skill/engineering=SKILL_LEVEL_PRO,
			),
			can_move=FALSE,
			particle_type=/particles/tool/wrench,
		))
			crit_fail = FALSE

	if(calibrations_required <= 0)
		to_chat(user, "<span class='notice'>[src] doesn't seem to need any calibrations.</span>")
		return

	var/hard_limit = 20
	for(var/i in 1 to hard_limit)
		if(!tool.use_tool(
			target=src,
			user=user,
			delay=1 SECOND,
			volume=70,
			quality=QUALITY_PULSING,
			required_skills_override=list(
				/datum/skill/engineering=SKILL_LEVEL_MASTER,
			),
			can_move=FALSE,
			particle_type=/particles/tool/wrench,
		))
			return
		if(calibrations_required <= 0)
			return

		calibrations_required = max(0, calibrations_required - 1)

/obj/machinery/scrap_beacon/proc/set_active(new_state)
	if(active == new_state)
		return

	active = new_state
	update_icon()

	if(active)
		// Odd yes but this coefficient makes it inefficient to turn off-turn on all the time.
		// You'd rather just keep it running.
		last_activation = world.time
		wt_until_next_scrap_fall = wt_per_scrap_fall * 1.5
		set_power_use(ACTIVE_POWER_USE)
		start_processing()
	else
		var/unsafe_activation_coeff = 1.0 - (world.time - last_activation) / safe_deactivation_cooldown
		if(unsafe_activation_coeff > 0.0)
			calibrations_required = ceil(unsafe_activation_coeff * max_calibrations_required)
			if(prob(unsafe_activation_coeff * 10.0))
				crit_fail = TRUE
				playsound(
					src,
					'sound/effects/zzzt.ogg',
					volume_channel=VOL_EFFECTS_MASTER,
					vol=75,
					vary=TRUE,
					// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
					// After all, in space, you can't hear scrap beacon start.
					ignore_environment=TRUE,
				)
				new /obj/effect/effect/smoke(loc)

		color = null
		set_power_use(NO_POWER_USE)
		stop_processing()

/obj/machinery/scrap_beacon/proc/has_enough_power()
	var/area/A = get_turf(src)
	if(!A)
		return FALSE

	if(!powered(STATIC_EQUIP))
		return FALSE

	if(!A.has_power(STATIC_EQUIP, active_power_usage))
		return FALSE

	return TRUE

/obj/machinery/scrap_beacon/process(seconds_per_tick)
	if(!has_enough_power())
		set_active(FALSE)
		return

	if(!active)
		return

	var/additional_brightness_coefficient = 0.25 * (1.0 - wt_until_next_scrap_fall / wt_per_scrap_fall)
	color = COLOR_MATRIX_LIGHTNESS(additional_brightness_coefficient)

	if(prob(50))
		pixel_x = rand(-1, 1)
	if(prob(50))
		pixel_y = rand(-1, 1)

	playsound(
		src,
		'sound/machines/select_boop.ogg',
		volume_channel=VOL_EFFECTS_MASTER,
		vol=60,
		vary=FALSE,
		// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
		// After all, in space, you can't hear scrap beacon start.
		ignore_environment=TRUE,
	)

	// `active_power_usage` is a generous assumption. With current electricity system we have
	// no actual way to know how much power we could've consumed in that tick.
	// The * 0.5 is a sad bootleg because we need to consume as much power as APC does,
	// and it consumes power irregardless of seconds_per_tick, which are usually 2 seconds.
	wt_until_next_scrap_fall -= active_power_usage * seconds_per_tick * 0.5
	if(wt_until_next_scrap_fall <= 0)
		wt_until_next_scrap_fall = wt_per_scrap_fall
		scrap_fall(rand(min_scrap_per_fall, max_scrap_per_fall))

/obj/machinery/scrap_beacon/update_icon()
	icon_state = "beacon[active]"

/obj/machinery/scrap_beacon/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='warning'>You are overloading a dangerous range protocols.</span>")
	emagged = TRUE
	impact_range = 4
	return TRUE

/obj/machinery/scrap_beacon/proc/scrap_fall(amount)
	set waitfor = FALSE

	if(!active)
		return

	do_shake_animation(
		3,
		0.2 SECONDS,
	)

	playsound(
		src,
		'sound/machines/scrap_beacon_start.ogg',
		volume_channel=VOL_EFFECTS_MASTER,
		vol=70,
		vary=FALSE,
		// Let's say it's built into the PDA or something! Otherwise you wouldn't hear it.
		// After all, in space, you can't hear scrap beacon start.
		ignore_environment=TRUE,
	)

	var/list/flooring_near_beacon = list()
	for(var/turf/T in RANGE_TURFS(impact_range, src))
		if(!isfloorturf(T))
			continue
		if((locate(/obj/structure/scrap) in T))
			continue
		flooring_near_beacon += T
	flooring_near_beacon -= src.loc

	for(var/i in 1 to amount)
		if(length(flooring_near_beacon) == 0)
			set_active(FALSE)
			return
		var/turf/newloc = pick(flooring_near_beacon)
		flooring_near_beacon -= newloc
		beam_scrap_at(newloc)

		sleep(rand(min_scrap_fall_delay, max_scrap_fall_delay))

		if(!active)
			return
		if(QDELETED(src))
			return

/obj/machinery/scrap_beacon/proc/beam_scrap_at(turf/T)
	var/has_gravity = gravity_is_on

	var/datum/gas_mixture/env = T.return_air()
	if(!env)
		has_gravity = FALSE
	else
		has_gravity = has_gravity && env.return_pressure() > 0

	new /obj/effect/falling_effect(
		T,
		/obj/random/scrap/moderate_weighted,
		null,
		has_gravity ? 7 : 14,
		!has_gravity,
	)

#undef SCRAPFALL_COOLDOWN_SECONDS
#undef SCRAP_BEACON_ACTIVE_POWER_USAGE
#undef SCRAP_BEACON_FALL_EVERY_POWER_USED
