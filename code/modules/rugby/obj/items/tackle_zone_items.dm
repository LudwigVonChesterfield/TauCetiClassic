/obj/item/clothing/glasses/tackle
	name = "tackle tracker"
	desc = "Strangely ancient technology used to help you track down opponent's movement anywhere they be."
	icon_state = "sun"
	item_state = "sunglasses"
	darkness_view = -1

	var/team_color = "#ff0000"

	var/image/zone_overlay

	var/datum/component/area_effect/tackle_zone

/obj/item/clothing/glasses/tackle/atom_init()
	. = ..()
	zone_overlay = image('code/modules/rugby/rugby.dmi', "tackle_zone")
	zone_overlay.color = team_color

	tackle_zone = AddComponent(
		/datum/component/area_effect,
		CALLBACK(src, .proc/get_area),
		CALLBACK(src, .proc/track_effect),
		CALLBACK(src, .proc/untrack_effect),
		CALLBACK(src, .proc/can_apply_overlay),
		zone_overlay
	)

/obj/item/clothing/glasses/tackle/Destroy()
	if(slot_equipped == SLOT_SHOES)
		// Since slot_equipped is changed only when item is worn
		// it's safe to assume loc is a mob.
		stop_tackling(loc)
	return ..()

/obj/item/clothing/glasses/tackle/proc/get_area()
	return list(get_step(loc, loc.dir))

/obj/item/clothing/glasses/tackle/advanced/get_area()
	. = list()
	for(var/d in list(45, 0, -45))
		. += get_step(loc, turn(loc.dir, d))

/obj/item/clothing/glasses/tackle/proc/can_apply_overlay(turf/T)
	return !T.density

/obj/item/clothing/glasses/tackle/proc/start_tackling(mob/user)
	tackle_zone.apply_to(user)

/obj/item/clothing/glasses/tackle/proc/stop_tackling(mob/user)
	tackle_zone.remove_from(user)

/obj/item/clothing/glasses/tackle/equipped(mob/user, slot)
	..()
	if(slot == SLOT_GLASSES)
		start_tackling(user)
	else if(slot_equipped == SLOT_GLASSES)
		stop_tackling(user)

/obj/item/clothing/glasses/tackle/dropped(mob/user)
	..()
	if(slot_equipped == SLOT_GLASSES)
		stop_tackling(user)

/obj/item/clothing/glasses/tackle/proc/track_effect(turf/T)
	RegisterSignal(T, list(COMSIG_ATOM_EXITED), .proc/tackle_mob)

/obj/item/clothing/glasses/tackle/proc/tackle_mob(datum/source, atom/movable/AM, atom/newLoc)
	if(!isliving(AM))
		return

	var/mob/living/victim = AM
	var/mob/living/attacker = loc
	var/combo_value = PUSH_COMBO_POINTS * 2
	attacker.engage_combat(victim, attacker.a_intent, combo_value)

/obj/item/clothing/glasses/tackle/proc/untrack_effect(turf/T)
	UnregisterSignal(T, list(COMSIG_ATOM_EXITED))



/obj/item/clothing/glasses/tackle/red
	team_color = "#ff0000"

/obj/item/clothing/glasses/tackle/blue
	team_color = "#0000ff"

/obj/item/clothing/glasses/tackle/advanced/red
	team_color = "#ff0000"

/obj/item/clothing/glasses/tackle/advanced/blue
	team_color = "#0000ff"
