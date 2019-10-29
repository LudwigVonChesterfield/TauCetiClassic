/obj/item/spell/earthquake
	name = "earthquake spell"
	desc = "This spell makes everything tremble... A lot."

	spell_icon = 'icons/obj/stationobjs.dmi'
	spell_icon_state = "nuclearbomb0"

	spell_components_slots = 1
	compatible_flags = list(WAND_SPELL_TRIGGER_ON_IMPACT = TRUE, WAND_SPELL_TIMER = TRUE)

	mana_cost = 20
	additional_delay = 1

/obj/item/spell/earthquake/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(istype(target, /turf/simulated/floor))
		var/turf/simulated/floor/T = target
		T.shake(3.0 * cur_mod.mult_power + cur_mod.add_power)
	else
		target.shake_act(3.0 * cur_mod.mult_power + cur_mod.add_power)

	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		issue_event(WAND_SPELL_TRIGGER_ON_IMPACT, holder, src, list(target), cur_mod.get_copy(), next_mod.get_copy())



/obj/item/spell/trashify
	name = "trashify spell"
	desc = "This spell things into... Trash."

	spell_icon = 'icons/obj/trash.dmi'
	spell_icon_state = "chips"

	spell_components_slots = 1
	compatible_flags = list(WAND_SPELL_TRIGGER_ON_IMPACT = TRUE, WAND_SPELL_TIMER = TRUE)

	mana_cost = 20
	additional_delay = 2

/obj/item/spell/trashify/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(isobj(target))
		var/obj/O = target
		O.make_old()
	else if(ismob(target))
		var/mob/M = target
		var/obj/item/I = M.get_active_hand()
		if(!I)
			I = M.get_inactive_hand()
		if(I)
			I.make_old()

	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		issue_event(WAND_SPELL_TRIGGER_ON_IMPACT, holder, src, list(target), cur_mod.get_copy(), next_mod.get_copy())



/obj/item/spell/sparks
	name = "sparks spell"
	desc = "This spell creates a bunch of sparks. That's it..."

	spell_icon = 'icons/effects/effects.dmi'
	spell_icon_state = "sparks_static"

	mana_cost = 1
	additional_delay = 0

	spell_components_slots = 1
	compatible_flags = list(WAND_SPELL_TRIGGER_ON_IMPACT = TRUE, WAND_SPELL_TIMER = TRUE)

	on_trigger_cast_type = WAND_COMP_OTHERSCAST

/obj/item/spell/sparks/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	new /obj/effect/effect/sparks(isturf(target) ? target : target.loc)
	if(spell_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		issue_event(WAND_SPELL_TRIGGER_ON_IMPACT, holder, src, list(target), cur_mod.get_copy(), next_mod.get_copy())

/obj/item/spell/sparks/trigger
	spawn_with_component_types = list(/obj/item/spell/spell_component/trigger/impact)
