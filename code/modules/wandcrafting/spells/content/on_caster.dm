/obj/item/spell/on_caster

/obj/item/spell/on_caster/examine(mob/user)
	..()
	to_chat(user, "<span class='warning'>Cast location is always the same as the location of object that cast it.</span>")

/obj/item/spell/on_caster/get_additional_info(obj/item/weapon/storage/spellbook/SB)
	var/dat = ..()
	dat = "<font color='red'>Cast location is always the same as the location of object that cast it.</font>"
	return dat

/obj/item/spell/on_caster/spell_areacast(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	// All subtypes of this spell are cast on casting_obj, so target doesn't matter. That's it.
	spell_otherscast(holder, casting_obj, null, cur_mod, next_mod)



/obj/item/spell/on_caster/explosion
	name = "explosion spell"
	desc = "This spell makes the caster explode."

	spell_icon = 'icons/obj/stationobjs.dmi'
	spell_icon_state = "nuclearbomb0"

	mana_cost = 30
	additional_delay = 2

/obj/item/spell/on_caster/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	// In the face!
	var/turf/epicenter = get_turf(casting_obj)
	var/epicenter_prev_color = epicenter.color
	epicenter.color = "#ff0000"
	var/power = 2.0 * cur_mod.mult_power + cur_mod.add_power
	sleep(3)
	if(QDELING(epicenter))
		return

	epicenter.color = epicenter_prev_color

	explosion(epicenter, 0, 1, power, 0)



/obj/item/spell/on_caster/forcefield
	name = "impenetrable barrier spell"
	desc = "This spell allows passage to none. Not even you."

	spell_icon = 'icons/effects/effects.dmi'
	spell_icon_state = "m_shield"

	mana_cost = 20
	additional_delay = 1

/obj/item/spell/on_caster/forcefield/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/turf/shield_center = get_turf(casting_obj)
	var/to_live = (50 * cur_mod.mult_power) + cur_mod.add_power
	new /obj/effect/forcefield/del_after(shield_center, to_live)
	if(casting_obj.dir == SOUTH || casting_obj.dir == NORTH)
		new /obj/effect/forcefield/del_after(get_step(casting_obj, EAST), to_live)
		new /obj/effect/forcefield/del_after(get_step(casting_obj, WEST), to_live)
	else
		new /obj/effect/forcefield/del_after(get_step(casting_obj, NORTH), to_live)
		new /obj/effect/forcefield/del_after(get_step(casting_obj, SOUTH), to_live)



/obj/item/spell/on_caster/emplosion
	name = "emplosion spell"
	desc = "This spell causes an electromagnetic impulse to happen at caster's location."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "emp"

	mana_cost = 25
	additional_delay = 2

/obj/item/spell/on_caster/emplosion/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/turf/epicenter = get_turf(casting_obj)
	var/epicenter_prev_color = epicenter.color
	epicenter.color = "#0000ff"
	var/power_heavy = 1.0 * cur_mod.mult_power + cur_mod.add_power
	var/power_light = 2.0 * cur_mod.mult_power + cur_mod.add_power

	sleep(3)
	if(QDELING(epicenter))
		return

	epicenter.color = epicenter_prev_color

	empulse(epicenter, power_heavy, power_light)



/obj/item/spell/on_caster/spontaneous_combustion
	name = "spontaneous combustion spell"
	desc = "This spell causes your location to suddenly... Light up."

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "fireball"

	mana_cost = 20
	additional_delay = 2

/obj/item/spell/on_caster/spontaneous_combustion/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/turf/T = get_turf(casting_obj)
	var/amt = 1.0 * cur_mod.mult_power + cur_mod.add_power
	new /obj/effect/decal/cleanable/liquid_fuel(T, amt)
	sleep(1)
	if(QDELING(T))
		return
	new /obj/effect/effect/sparks(T)



/obj/item/spell/on_caster/lumos
	name = "lumos spell"
	desc = "This spell creates a very temporary source of light."

	spell_icon = 'icons/obj/lighting.dmi'
	spell_icon_state = "floor1"

	cast_light = FALSE
	spell_light_range = 3.0
	spell_light_power = 3.0
	spell_light_time_to_live = 2 SECONDS

	mana_cost = 10
	additional_delay = 2

/obj/item/spell/on_caster/lumos/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/obj/item/projectile/cast_trigger/bootleg = new(casting_obj.loc)

	bootleg.invisibility = 101

	var/new_spell_light_range = spell_light_range * cur_mod.mult_power + cur_mod.add_power
	var/new_spell_light_power = spell_light_power * cur_mod.mult_power + cur_mod.add_power
	bootleg.set_light(new_spell_light_range, new_spell_light_power, spell_color)

	var/time_to_live = spell_light_time_to_live * cur_mod.mult_power + cur_mod.add_power

	QDEL_IN(bootleg, time_to_live)
