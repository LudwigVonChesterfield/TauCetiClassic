/obj/item/spell
	var/datum/storage_ui/storage_ui

	var/list/spawn_with_component_types

	var/list/spell_components = list()
	var/spell_components_slots = 1

	var/list/spell_flags = list()
	var/list/compatible_flags = list(WAND_SPELL_TIMER = TRUE)

	var/list/cast_on_event = list()

/obj/item/spell/attack_hand(mob/living/user)
	if(user.a_intent != I_HURT && user.get_inactive_hand() == src)
		open(user)
		return
	return ..()

/obj/item/spell/MouseDrop(atom/movable/over_object)
	if(!ishuman(usr) && !ismonkey(usr) && !isIAN(usr))
		return

	if(!over_object)
		return

	if(over_object == usr && Adjacent(usr))
		open(usr)
		return

	if(!istype(over_object, /obj/screen))
		return ..()

	//makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
	//there's got to be a better way of doing this.
	if(!(loc == usr) || (loc && loc.loc == usr))
		return

	if(!usr.restrained() && !usr.stat)
		switch(over_object.name)
			if("r_hand")
				if(!usr.unEquip(src))
					return
				usr.put_in_r_hand(src)
			if("l_hand")
				if(!usr.unEquip(src))
					return
				usr.put_in_l_hand(src)
			if("mouth")
				if(!usr.unEquip(src))
					return
				usr.put_in_active_hand(src)
		add_fingerprint(usr)

/obj/item/spell/proc/open(mob/user)
	if(spell_components_slots == 0)
		return
	storage_ui.prepare_ui()
	storage_ui.on_open(user)
	storage_ui.show_to(user)

/obj/item/spell/proc/close(mob/user)
	if(spell_components_slots == 0)
		return
	close_all()

/obj/item/spell/proc/close_all()
	if(spell_components_slots == 0)
		return
	storage_ui.close_all()

/obj/item/spell/proc/show_to(mob/user)
	if(spell_components_slots == 0)
		return
	storage_ui.show_to(user)

/obj/item/spell/proc/hide_from(mob/user)
	if(spell_components_slots == 0)
		return
	storage_ui.hide_from(user)

/obj/item/spell/proc/can_be_inserted()
	return FALSE

/obj/item/spell/proc/on_insertion(mob/user, obj/item/I)
	return

/obj/item/spell/proc/on_pre_remove(mob/user, obj/item/W)
	if(istype(W, /obj/item/spell/spell_component))
		remove_spell_component(W)

/obj/item/spell/proc/add_spell_component(obj/item/spell/spell_component/SC)
	SC.forceMove(src)
	SC.apply_to_holder(src)

/obj/item/spell/proc/remove_spell_component(obj/item/spell/spell_component/SC)
	var/atom/move_to = loc
	if(istype(move_to, /obj/item/weapon/wand))
		move_to = move_to.loc
	if(ismob(move_to))
		move_to = move_to.loc

	SC.remove_from_holder()
	SC.forceMove(move_to)

// Returns TRUE if it was a spell component, and it got inserted.
/obj/item/spell/proc/handle_modification(obj/item/W, mob/user)
	if(istype(W, /obj/item/spell/spell_component))
		var/obj/item/spell/spell_component/SC = W

		if(spell_components.len >= spell_components_slots)
			to_chat(user, "<span class='notice'>[src] can not contain any more components.</span>")
			return FALSE

		for(var/new_fl in SC.add_flags)
			if(!(new_fl in compatible_flags))
				to_chat(user, "<span class='notice'><b>[SC]</b> is incompatible with <b>[src]</b>, because of it having a <b>[new_fl]</b>.</span>")
				return FALSE

		add_spell_component(W)

		user.remove_from_mob(W)
		user.update_icons()
		W.forceMove(src)

		if(usr.client && usr.s_active != src)
			usr.client.screen -= W
		W.dropped(usr)
		add_fingerprint(usr)

		storage_ui.prepare_ui()
		storage_ui.on_insertion(user)

		return TRUE
	return FALSE

/obj/item/spell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/storage/spellbook))
		var/obj/item/weapon/storage/spellbook/SB = I
		SB.learn_spell(type)
		if(user.machine == SB)
			SB.browse_ui(user)
		return
	if(handle_modification(I, user))
		return
	return ..()

/obj/item/spell/proc/get_targets(cast_type, obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod)
	var/atom/target = casting_obj.loc
	if(cur_mod.boomerang)
		target = holder.loc

	var/list/retVal
	switch(cast_type)
		if(WAND_COMP_AREACAST)
			var/turf/T = get_turf(target)
			retVal = list() + T.contents
		if(WAND_COMP_MELEEMAGICCAST)
			if(in_range(casting_obj, target))
				retVal = list(target)
			else
				retVal = list(get_step(casting_obj, get_dir(casting_obj, target)))
		else
			retVal = list(target)

	. = list()
	var/i = 1
	for(var/atom/A in retVal)
		. += cur_mod.apply_dir_effects(A, casting_obj, i)
		i++

/obj/item/spell/proc/issue_event(event_type, obj/item/weapon/wand/holder, atom/casting_obj, list/targets, datum/spell_modifier/cur_mod, datum/spell_modifier/next_mod)
	if(QDELING(src))
		return
	if(QDELING(holder))
		return
	if(QDELING(casting_obj))
		return

	var/list/targs = get_targets(on_trigger_cast_type, holder, casting_obj, targets, cur_mod, on_trigger_cast_type)
	for(var/obj/item/spell/spell_component/reactioner in cast_on_event[event_type])
		INVOKE_ASYNC(reactioner, /obj/item/spell.proc/cast, on_trigger_cast_type, holder, casting_obj, targs, cur_mod, next_mod)



/obj/item/spell/spell_component
	stackable = TRUE

	spell_invocation = "whisper"
	cast_light = FALSE

	spell_components_slots = 0

	compatible_flags = list()

	var/obj/item/spell/holder
	var/list/add_flags = list()

/obj/item/spell/spell_component/examine(mob/user)
	..()
	if(add_flags[WAND_SPELL_TIMER])
		to_chat(user, "<span class='info'>When applied to a spell, it will trigger after a set amount of time.</span>")
	if(add_flags[WAND_SPELL_TRIGGER_ON_IMPACT])
		to_chat(user, "<span class='info'>When applied to a spell, it will trigger upon collision.</span>")
	if(add_flags[WAND_SPELL_TRIGGER_ON_STEP])
		to_chat(user, "<span class='info'>When applied to a spell, it will trigger on each move.</span>")

/obj/item/spell/spell_component/Destroy()
	if(holder)
		remove_from_holder()
	return ..()

/obj/item/spell/spell_component/proc/apply_to_holder(obj/item/spell/S)
	holder = S
	holder.spell_components += src
	holder.mana_cost += mana_cost
	holder.additional_delay += additional_delay

	for(var/fl in add_flags)
		holder.spell_flags[fl] = TRUE

		if(holder.cast_on_event[fl])
			holder.cast_on_event[fl] += src
		else
			holder.cast_on_event[fl] = list(src)

	var/comp_txt = ""
	var/comp_desc = ""
	var/first = TRUE
	for(var/obj/item/spell/spell_component/SC in holder.spell_components)
		if(first)
			comp_txt = " with a [SC.name]"
		else
			comp_txt += ", [SC.name]"

		for(var/fl in SC.add_flags)
			if(first)
				comp_desc = " It seems to have such components: [fl]"
			else
				comp_desc += ", [fl]"
			first = FALSE
		first = FALSE

	if(comp_desc)
		comp_desc += "."

	holder.name = "[initial(holder.name)][comp_txt]"
	holder.desc =  "[initial(holder.desc)][comp_txt]"

/obj/item/spell/spell_component/proc/remove_from_holder()
	holder.spell_components -= src
	holder.mana_cost -= mana_cost
	holder.additional_delay -= additional_delay

	var/list/has_flags = list()
	for(var/obj/item/spell/spell_component/SC in holder.spell_components)
		for(var/fl in SC.add_flags)
			has_flags[fl] = TRUE

	for(var/fl in add_flags)
		holder.cast_on_event[fl] -= src
		if(holder.cast_on_event[fl].len == 0)
			holder.cast_on_event -= fl

	var/comp_txt = ""
	var/comp_desc = ""
	var/first = TRUE
	for(var/obj/item/spell/spell_component/SC in holder.spell_components)
		if(first)
			comp_txt = " with a [SC.name]"
		else
			comp_txt += ", [SC.name]"

		for(var/fl in SC.add_flags)
			if(first)
				comp_desc = " It seems to have such components: [fl]"
			else
				comp_desc += ", [fl]"
			first = FALSE
		first = FALSE

	if(comp_desc)
		comp_desc += "."

	holder.name = "[initial(holder.name)][comp_txt]"
	holder.desc =  "[initial(holder.desc)][comp_txt]"

	holder.spell_flags = has_flags
	holder = null
