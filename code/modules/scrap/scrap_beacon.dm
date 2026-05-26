/obj/machinery/scrap_beacon
	name = "Scrap Beacon"
	desc = "This machine generates directional gravity rays which catch trash orbiting around."
	icon = 'icons/obj/structures/scrap/scrap_beacon.dmi'
	icon_state = "beacon0"
	anchored = TRUE
	density = TRUE
	layer = MOB_LAYER + 1

	active_power_usage = 1000
	idle_power_usage = 0

	var/wt_per_scrap = 10000

	var/summon_cooldown = 1200
	var/impact_speed = 3
	var/impact_prob = 100
	var/impact_range = 2
	var/last_summon = -3000
	var/active = 0
	//var/emagged = FALSE

/obj/machinery/scrap_beacon/Destroy()
	. = ..()
	STOP_PROCESSING(SSobj, src)

/obj/machinery/scrap_beacon/attack_hand(mob/user)
	user.SetNextMove(CLICK_CD_INTERACT)

	set_active(!active)

/obj/machinery/scrap_beacon/proc/set_active(new_state)
	if(active == new_state)
		return
	active = new_state
	update_icon()
	if(active)
		set_power_use(ACTIVE_POWER_USE)
		START_PROCESSING(SSobj, src)
	else
		set_power_use(NO_POWER_USE)
		STOP_PROCESSING(SSobj, src)

/obj/machinery/scrap_beacon/process(seconds_per_tick)
	var/area/A = get_turf(src)
	if(!A)
		set_active(FALSE)
		return



/obj/machinery/scrap_beacon/update_icon()
	icon_state = "beacon[active]"

/obj/machinery/scrap_beacon/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='warning'>You are overloading a dangerous range protocols.</span>")
	emagged = TRUE
	impact_range = 4
	impact_speed = 1
	return TRUE

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
	)

/obj/machinery/scrap_beacon/proc/start_scrap_summon()
	set waitfor = FALSE

	active = 1
	playsound(src, 'sound/machines/scrap_beacon_start.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	update_icon()
	sleep(30)
	var/list/flooring_near_beacon = list()
	for(var/turf/T in RANGE_TURFS(impact_range, src))
		if(!isfloorturf(T))
			continue
		if((locate(/obj/structure/scrap) in T))
			continue
		if(!prob(impact_prob))
			continue
		flooring_near_beacon += T
	flooring_near_beacon -= src.loc
	while(flooring_near_beacon.len > 0)
		sleep(impact_speed)
		var/turf/newloc = pick(flooring_near_beacon)
		flooring_near_beacon -= newloc
		beam_scrap_at(newloc)
	active = 0
	update_icon()
	return
