/datum/spell_setup_entry/timer
	name = "Set Timer"
	desc = "Set the time after cast of this spell that a trigger-cast mechanic will occur."
	category = "Technical"

	setup_word = "Choose"

/datum/spell_setup_entry/trigger/can_setup(mob/user, obj/item/spell/spell_component/timer/holder)
	return TRUE

/datum/spell_setup_entry/trigger/on_setup(mob/user, obj/item/spell/spell_component/timer/holder)
	var/new_time = input(user, "Set the Timer(min: 1, max: 20):", "Timer") as null|num
	if(new_time)
		new_time = CLAMP(new_time, 1, 20)
		holder.trigger_in = new_time
		to_chat(user, "<span class='notice'>[holder] now will trigger after [new_time * 0.1] seconds.</span>")

/obj/item/spell/spell_component/timer
	name = "timer"
	desc = "It triggers a spell cast after some time."

	category = "Component"

	spell_icon = 'icons/mob/actions.dmi'
	spell_icon_state = "time"

	mana_cost = 1
	additional_delay = 0

	spawn_entries_types = list(/datum/spell_setup_entry/timer, /datum/spell_setup_entry/cast_type)

	var/trigger_in = 10

/obj/item/spell/spell_component/timer/get_additional_info()
	var/dat = ..()
	dat += "When applied to spell, the spell will issue a trigger-cast mechanic after a set amount of time.<BR>"

/obj/item/spell/spell_component/timer/proc/after_time(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod)
	if(QDELING(casting_obj) || QDELING(src))
		return

	var/mob/caster = get_caster(casting_obj)

	if(caster)
		var/obj/item/projectile/cast_trigger/bootleg = new(casting_obj.loc)
		bootleg.dir = casting_obj.dir
		bootleg.firer = caster
		casting_obj = bootleg

		var/list/targs = get_targets(on_trigger_cast_type, holder, casting_obj, targets, cur_mod)
		holder.try_casting(on_trigger_cast_type, targs, casting_obj)
		QDEL_IN(bootleg, 1 SECOND)

/obj/item/spell/spell_component/timer/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	addtimer(CALLBACK(src, .proc/after_time, holder, casting_obj, list(target), cur_mod.get_copy()), trigger_in)

/obj/item/spell/spell_component/timer/spell_selfcast(obj/item/weapon/wand/holder, atom/casting_obj, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	addtimer(CALLBACK(src, .proc/after_time, holder, casting_obj, list(casting_obj), cur_mod.get_copy()), trigger_in)

/obj/item/spell/spell_component/timer/spell_meleemagiccast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	addtimer(CALLBACK(src, .proc/after_time, holder, casting_obj, list(target), cur_mod.get_copy()), trigger_in)

/obj/item/spell/spell_component/timer/spell_areacast(obj/item/weapon/wand/holder, atom/casting_obj, list/turfs, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	addtimer(CALLBACK(src, .proc/after_time, holder, casting_obj, turfs, cur_mod.get_copy()), trigger_in)
