/datum/spell_setup_entry/trigger
	name = "Choose Trigger"
	desc = "Choose a particular event that will be issuing the trigger-cast mechanic."
	category = "Technical"

	setup_word = "Choose"

/datum/spell_setup_entry/trigger/can_setup(mob/user, obj/item/spell/spell_component/holder)
	return TRUE

/datum/spell_setup_entry/trigger/on_setup(mob/user, obj/item/spell/spell_component/holder)
	var/new_trigger = input(user, "Choose an event to be the trigger:", "Trigger") as null|anything in spell_pos_triggers
	if(new_trigger)
		holder.add_flags = list(new_trigger)
		to_chat(user, "<span class='notice'>[holder] is now a [new_trigger].</span>")

/datum/spell_setup_entry/cast_type
	name = "Choose Cast Type"
	desc = "Choose a particular cast type that will be issued by the trigger-cast mechanic."
	category = "Technical"

	setup_word = "Choose"

/datum/spell_setup_entry/cast_type/can_setup(mob/user, obj/item/spell/spell_component/holder)
	return TRUE

/datum/spell_setup_entry/cast_type/on_setup(mob/user, obj/item/spell/spell_component/holder)
	var/new_cast_type = input(user, "Choose the cast type:", "Trigger") as null|anything in wand_comp_casttypes
	if(new_cast_type)
		holder.on_trigger_cast_type = new_cast_type
		to_chat(user, "<span class='notice'>[holder] now casts as [new_cast_type].</span>")



/obj/item/spell/spell_component/trigger
	name = "trigger"
	desc = "It triggers a spell cast on certain conditions."

	category = "Component"

	spell_icon = 'icons/obj/weapons.dmi'
	spell_icon_state = "text"

	mana_cost = 2
	additional_delay = 0

	spawn_entries_types = list(/datum/spell_setup_entry/trigger, /datum/spell_setup_entry/cast_type)

/obj/item/spell/spell_component/timer/get_additional_info()
	var/dat = ..()
	dat += "When applied to spell, the spell will issue a trigger-cast mechanic if certain conditions(\"triggers\") are met.<BR>"
	return dat

/obj/item/spell/spell_component/trigger/proc/on_trigger(obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	var/mob/caster = get_caster(casting_obj)

	if(caster)
		var/obj/item/projectile/cast_trigger/bootleg = new(casting_obj.loc)
		bootleg.dir = casting_obj.dir
		bootleg.firer = caster
		casting_obj = bootleg

		holder.try_casting(on_trigger_cast_type, targets, casting_obj)
		QDEL_IN(bootleg, 1 SECOND)

/obj/item/spell/spell_component/trigger/spell_otherscast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	on_trigger(holder, casting_obj, list(target), cur_mod, next_mod)

/obj/item/spell/spell_component/trigger/spell_selfcast(obj/item/weapon/wand/holder, atom/casting_obj, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	on_trigger(holder, casting_obj, list(casting_obj), cur_mod, next_mod)

/obj/item/spell/spell_component/trigger/spell_meleemagiccast(obj/item/weapon/wand/holder, atom/casting_obj, atom/target, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	on_trigger(holder, casting_obj, list(target), cur_mod, next_mod)

/obj/item/spell/spell_component/trigger/spell_areacast(obj/item/weapon/wand/holder, atom/casting_obj, list/turfs, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	on_trigger(holder, casting_obj, turfs, cur_mod, next_mod)



/obj/item/spell/spell_component/trigger/impact
	add_flags = list(WAND_SPELL_TRIGGER_ON_IMPACT)
	can_be_crafted = FALSE



/obj/item/spell/spell_component/trigger/step
	add_flags = list(WAND_SPELL_TRIGGER_ON_STEP)
	can_be_crafted = FALSE
