/obj/structure/scrap_beacon
	name = "Scrap Beacon"
	desc = "This machine generates directional gravity rays which catch trash orbiting around."
	icon = 'icons/obj/structures/scrap/scrap_beacon.dmi'
	icon_state = "beacon0"
	anchored = TRUE
	density = TRUE
	layer = MOB_LAYER+1
	var/summon_cooldown = 1200
	var/impact_speed = 3
	var/impact_prob = 100
	var/impact_range = 2
	var/next_summon = -3000
	var/active = 0

	var/panel_open = FALSE

	var/datum/wires/scrap_beacon/wires

/obj/structure/scrap_beacon/atom_init()
	. = ..()

	wires = new(src)

/obj/structure/scrap_beacon/proc/can_activate()
	if(next_summon >= world.time)
		return FALSE

	if(active)
		return FALSE

	return TRUE

/obj/structure/scrap_beacon/proc/activate()
	next_summon = world.time + summon_cooldown
	start_scrap_summon()

/obj/structure/scrap_beacon/attack_hand(mob/user)
	if(wires.interact(user))
		return

	user.SetNextMove(CLICK_CD_INTERACT)
	if(!can_activate())
		to_chat(user, "<span class='notice'>[src.name] is not charged yet, or already active.</span>")
		return

	activate()

/obj/structure/scrap_beacon/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		panel_open = !panel_open
		to_chat(user, "<span class='notice'>You [panel_open ? "open" : "close"] the maintenance panel on [src].</span>")
		return

	else if(iswirecutter(I))
		wires.interact(user)
		return

	else if(ismultitool(I))
		wires.interact(user)
		return

	else if(istype(I, /obj/item/device/assembly/signaler))
		wires.interact(user)
		return

	return ..()

/obj/structure/scrap_beacon/update_icon()
	icon_state = "beacon[active]"

/obj/structure/scrap_beacon/proc/start_scrap_summon()
	set waitfor = FALSE

	active = 1
	playsound(src, 'sound/machines/scrap_beacon_start.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	update_icon()
	sleep(30)
	var/list/flooring_near_beacon = list()
	for(var/turf/T in RANGE_TURFS(impact_range, src))
		if(!istype(T,/turf/simulated/floor))
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
		new /obj/effect/falling_effect(newloc, /obj/random/scrap/moderate_weighted)
	active = 0
	update_icon()
	return
